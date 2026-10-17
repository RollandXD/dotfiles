import QtQuick
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root
    readonly property string soundPluginId: "rollandSystemSounds"
    property var state: ({available: false, percent: 50, muted: false})
    property var sourceData: []
    property var pending: []
    property var preparing: null
    property string commandOutput: ""
    property string prepareOutput: ""
    property var mappedSources: ({})
    property var failedSources: ({})
    property int desiredVolume: -1
    property string previewAfterTrim: ""
    property var panelHost: null

    function expandPanel(item) {
        if (!item) return false;
        if (String(item).startsWith("ControlCenterContent") && item.host) {
            const widget = SettingsData.controlCenterWidgets.find(w => w.id === "plugin_rollandSystemSounds");
            item.host.expandedWidgetData = widget;
            item.host.expandedWidgetIndex = SettingsData.controlCenterWidgets.findIndex(w => w.id === widget.id);
            item.host.expandedSection = widget.id;
            return true;
        }
        for (const child of (item.children || [])) {
            if (expandPanel(child)) return true;
        }
        return false;
    }
    function focusPanel(item) {
        if (!item) return false;
        if (item.objectName === "systemSoundsVolumeSlider") {
            item.forceActiveFocus();
            return true;
        }
        for (const child of (item.children || [])) {
            if (focusPanel(child)) return true;
        }
        return false;
    }

    function publish(next) {
        state = next;
        if (next.available) {
            // Qt AudioOutput 使用线性幅度，Pulse 百分比使用立方根刻度。
            AudioService.notificationsVolume = Math.pow(Math.min(100, next.percent) / 100, 3);
            AudioService.notificationsAudioMuted = next.muted;
        }
        PluginService.setGlobalVar(soundPluginId, "state", next);
    }
    function enqueue(args) {
        pending.push(args);
        startNext();
    }
    function startNext() {
        if (commands.running || pending.length === 0)
            return;
        commandOutput = "";
        commands.command = ["system-sounds"].concat(pending.shift());
        commands.running = true;
    }
    function setVolume(value) {
        desiredVolume = Math.max(0, Math.min(100, Math.round(value)));
        volumeDebounce.restart();
    }
    function toggleMute() { enqueue(["mute", "toggle"]); }
    function preview(name) {
        if (previewProcess.running) return;
        // --force：来源被关闭时仍可试听；统一静音始终生效
        previewProcess.command = ["system-sounds", "play", name || "notification", "--force"];
        previewProcess.running = true;
    }
    function trim(name, value, thenPreview) {
        // 队列里同一来源的旧微调直接丢弃：拖动时只关心最后一个值
        pending = pending.filter(args => !(args[0] === "trim" && args[1] === name));
        if (thenPreview) previewAfterTrim = name;
        enqueue(["trim", name, String(value)]);
    }
    // 微调只影响一个来源：直接换那个 DMS 播放器的音源，不必让所有播放器重新走一遍 prepare
    function applyTrim(result) {
        for (const item of players()) {
            if (item.id !== result.name || !item.player) continue;
            item.player.source = "file://" + result.file;
            mappedSources[item.id] = result.original;
        }
    }
    function refreshSources() { enqueue(["audit"]); }
    function setEnabled(name, enabled) {
        enqueue([enabled ? "enable" : "disable", name]);
        refreshSources();
    }
    // 关闭的来源：DMS 内置播放器靠各自 AudioOutput 静音实现（DMS 自己不碰这个属性）；
    // 脚本类来源由 system-sounds play 自行判断。
    function applyEnabled() {
        const off = {};
        for (const row of sourceData)
            off[row.id] = !row.enabled;
        for (const item of players()) {
            if (item.player)
                item.player.audioOutput.muted = !!off[item.id];
        }
    }
    function unmutePlayers() {
        for (const item of players()) {
            if (item.player)
                item.player.audioOutput.muted = false;
        }
    }
    function installControl() {
        const widgets = SettingsData.controlCenterWidgets.slice();
        if (!widgets.some(item => item.id === "plugin_rollandSystemSounds")) {
            widgets.splice(1, 0, {id: "plugin_rollandSystemSounds", enabled: true, width: 50});
            SettingsData.set("controlCenterWidgets", widgets);
        }
    }
    function players() {
        return [
            {id: "volume", event: "audio-volume-change", player: AudioService.volumeChangeSound},
            {id: "notification", event: "message", player: AudioService.normalNotificationSound},
            {id: "critical", event: "message-new-instant", player: AudioService.criticalNotificationSound},
            {id: "login", event: "desktop-login", player: AudioService.loginSound},
            {id: "power-plug", event: "power-plug", player: AudioService.powerPlugSound},
            {id: "power-unplug", event: "power-unplug", player: AudioService.powerUnplugSound}
        ];
    }
    function prepareNext() {
        if (prepareProcess.running)
            return;
        for (const item of players()) {
            if (!item.player)
                continue;
            const original = String(AudioService.getSoundPath(item.event));
            if (failedSources[item.id] === original)
                continue;
            if (mappedSources[item.id] === original && String(item.player.source).includes("/system-sounds/"))
                continue;
            preparing = {id: item.id, event: item.event, original: original};
            prepareOutput = "";
            prepareProcess.command = ["system-sounds", "prepare", item.id, original];
            prepareProcess.running = true;
            return;
        }
        refreshSources();
    }
    function restorePlayers() {
        for (const item of players()) {
            if (!item.player || !String(item.player.source).includes("/system-sounds/"))
                continue;
            const eventName = item.event;
            item.player.source = Qt.binding(() => AudioService.getSoundPath(eventName));
        }
    }

    Timer {
        id: volumeDebounce
        interval: 120
        onTriggered: root.enqueue(["volume", "set", String(root.desiredVolume)])
    }
    Timer { id: reconnect; interval: 3000; onTriggered: watch.running = true }
    Timer { id: prepareTimer; interval: 150; onTriggered: root.prepareNext() }
    Timer { id: panelTimer; interval: 200; onTriggered: { root.expandPanel(root.panelHost?.contentItem); panelFocus.restart(); } }
    Timer { id: panelFocus; interval: 400; onTriggered: root.focusPanel(root.panelHost?.contentItem) }

    Process {
        id: watch
        command: ["system-sounds", "watch"]
        stdout: SplitParser {
            onRead: data => {
                try { root.publish(JSON.parse(data)); } catch (e) { console.warn("SystemSounds: invalid state"); }
            }
        }
        onExited: exitCode => {
            root.publish({available: false, percent: root.state.percent, muted: root.state.muted});
            reconnect.restart();
        }
    }
    Process {
        id: commands
        stdout: StdioCollector { onStreamFinished: root.commandOutput = text }
        onExited: exitCode => {
            if (exitCode !== 0) {
                ToastService.showError("提示音操作失败", "请检查音频服务或 system-sounds 日志");
            } else if (root.commandOutput.trim()) {
                try {
                    const result = JSON.parse(root.commandOutput);
                    if (result.available !== undefined)
                        root.publish(result);
                    if (result.sources) {
                        root.sourceData = result.sources;
                        PluginService.setGlobalVar(root.soundPluginId, "sources", result.sources);
                        root.applyEnabled();
                    }
                    if (result.trim_db !== undefined && result.file) {
                        root.applyTrim(result);
                        root.refreshSources();
                        if (root.previewAfterTrim === result.name) {
                            root.previewAfterTrim = "";
                            root.preview(result.name);
                        }
                    }
                } catch (e) { console.warn("SystemSounds: invalid response"); }
            }
            Qt.callLater(root.startNext);
        }
    }
    Process {
        id: previewProcess
        onExited: exitCode => {
            if (exitCode !== 0) ToastService.showError("提示音试听失败", "请检查该来源和音频服务");
        }
    }
    Process {
        id: prepareProcess
        stdout: StdioCollector { onStreamFinished: root.prepareOutput = text }
        onExited: exitCode => {
            const request = root.preparing;
            if (exitCode === 0) {
                try {
                    const result = JSON.parse(root.prepareOutput);
                    if (String(AudioService.getSoundPath(request.event)) === request.original) {
                        for (const item of root.players()) {
                            if (item.id === request.id && item.player) {
                                item.player.source = "file://" + result.file;
                                root.mappedSources[request.id] = request.original;
                            }
                        }
                    }
                } catch (e) { console.warn("SystemSounds: calibration response invalid"); }
                prepareTimer.restart();
            } else {
                console.warn("SystemSounds: sound calibration failed", request.id);
                root.failedSources[request.id] = request.original;
                prepareTimer.restart();
            }
        }
    }
    Connections {
        target: AudioService
        function onVolumeChangeSoundChanged() { prepareTimer.restart(); }
        function onNormalNotificationSoundChanged() { prepareTimer.restart(); }
        function onCriticalNotificationSoundChanged() { prepareTimer.restart(); }
        function onPowerPlugSoundChanged() { prepareTimer.restart(); }
        function onPowerUnplugSoundChanged() { prepareTimer.restart(); }
        function onLoginSoundChanged() { prepareTimer.restart(); }
        function onSoundFilePathsChanged() { root.mappedSources = ({}); root.failedSources = ({}); prepareTimer.restart(); }
        function onCurrentSoundThemeChanged() { root.mappedSources = ({}); root.failedSources = ({}); prepareTimer.restart(); }
    }
    Connections {
        target: SettingsData
        function onUseSystemSoundThemeChanged() { root.mappedSources = ({}); root.failedSources = ({}); prepareTimer.restart(); }
    }
    IpcHandler {
        target: "system-sounds"
        function open(screen: string): string {
            const router = PopoutService.dankIslandRouter;
            const host = router?.hostForScreen(screen);
            if (host) {
                root.panelHost = host;
                router.openActivityOn(host, "controlcenter", "plugin_rollandSystemSounds");
                panelTimer.restart();
                return "opened";
            }
            return "请从控制中心展开提示音";
        }
        function status(): string { return JSON.stringify(root.state); }
        function install(): string { root.installControl(); return "installed"; }
        function sources(): string { return JSON.stringify(root.sourceData); }
        function setvolume(value: string): string {
            const percent = Number(value);
            if (!isFinite(percent) || percent < 0 || percent > 100) return "invalid volume";
            root.setVolume(percent); return "queued";
        }
        function mute(): string { root.toggleMute(); return "queued"; }
        function trim(source: string, db: string): string {
            const value = Number(db);
            if (!isFinite(value) || value < -6 || value > 6) return "invalid trim";
            root.trim(source, value, true); return "queued";
        }
        function enable(source: string): string { root.setEnabled(source, true); return "queued"; }
        function disable(source: string): string { root.setEnabled(source, false); return "queued"; }
        function preview(source: string): string { root.preview(source); return "queued"; }
        function calibrated(): string {
            return JSON.stringify(root.players().filter(item => item.player).map(item => ({id: item.id, source: String(item.player.source)})));
        }
        function audio(): string { return JSON.stringify({volume: AudioService.notificationsVolume, muted: AudioService.notificationsAudioMuted, players: root.players().filter(item => item.player).map(item => ({id:item.id,volume:item.player.audioOutput.volume,muted:item.player.audioOutput.muted}))}); }
    }
    Component.onCompleted: {
        PluginService.setGlobalVar(soundPluginId, "controller", root);
        AudioService.notificationsAudioMuted = true;
        AudioService.ensurePlayers();
        watch.running = true;
        refreshSources();
        prepareTimer.restart();
    }
    Component.onDestruction: {
        reconnect.stop();
        restorePlayers();
        unmutePlayers();
        AudioService.notificationsVolume = 1.0;
        AudioService.notificationsAudioMuted = false;
        PluginService.setGlobalVar(soundPluginId, "controller", null);
        PluginService.setGlobalVar(soundPluginId, "state", {available: false});
    }
}
