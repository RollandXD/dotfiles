import Quickshell
import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    // 计划本身由 logind 保管（dank-shutdown 调 sudo shutdown），这里只读 D-Bus 属性展示
    readonly property string backend: Quickshell.env("HOME") + "/.local/bin/dank-shutdown"
    readonly property var presets: [
        { "label": "30 分钟", "args": ["in", "30m"], "icon": "timer" },
        { "label": "1 小时", "args": ["in", "1h"], "icon": "timer" },
        { "label": "2 小时", "args": ["in", "2h"], "icon": "timer" },
        { "label": "今晚 23:30", "args": ["at", "23:30"], "icon": "bedtime" },
        { "label": "1 小时后重启", "args": ["-r", "in", "1h"], "icon": "restart_alt" }
    ]

    property string schedMode: ""      // poweroff | reboot | ""
    property real schedEpoch: 0        // 秒
    property real nowEpoch: Date.now() / 1000
    property bool busy: false

    readonly property bool hasPlan: schedMode !== "" && schedEpoch > 0
    readonly property int secondsLeft: hasPlan ? Math.max(0, Math.round(schedEpoch - nowEpoch)) : 0
    readonly property string modeText: schedMode === "reboot" ? "重启" : "关机"
    readonly property color stateColor: {
        if (!hasPlan)
            return Theme.surfaceVariantText;
        if (secondsLeft <= 120)
            return Theme.error;
        if (secondsLeft <= 600)
            return Theme.warning;
        return Theme.primary;
    }

    function pad(n) {
        return n < 10 ? "0" + n : String(n);
    }

    function shortLeft(sec) {
        const h = Math.floor(sec / 3600);
        const m = Math.floor((sec % 3600) / 60);
        if (h > 0)
            return h + ":" + pad(m);
        if (m > 0)
            return m + "m";
        return sec + "s";
    }

    function longLeft(sec) {
        const h = Math.floor(sec / 3600);
        const m = Math.floor((sec % 3600) / 60);
        if (h > 0)
            return h + " 小时 " + m + " 分钟";
        if (m > 0)
            return m + " 分钟";
        return "不到 1 分钟";
    }

    function clockText(epoch) {
        const d = new Date(epoch * 1000);
        return pad(d.getHours()) + ":" + pad(d.getMinutes());
    }

    function refresh() {
        Proc.runCommand("rollandShutdown.read", ["busctl", "get-property", "org.freedesktop.login1", "/org/freedesktop/login1", "org.freedesktop.login1.Manager", "ScheduledShutdown"], (stdout, exitCode) => {
            root.nowEpoch = Date.now() / 1000;
            // 形如 (st) "poweroff" 1785000000000000；无计划时 (st) "" 18446744073709551615
            const m = String(stdout || "").match(/"([a-z-]*)"\s+(\d+)/);
            if (exitCode !== 0 || !m || m[1] === "" || m[2] === "18446744073709551615") {
                root.schedMode = "";
                root.schedEpoch = 0;
                return;
            }
            root.schedMode = m[1];
            root.schedEpoch = Number(m[2].slice(0, -6)); // 微秒 → 秒，避开 double 精度问题
        }, 0);
    }

    function run(args) {
        if (busy)
            return;
        busy = true;
        // DANK_SHUTDOWN_UI=gui：结果与错误走 DMS toast
        Proc.runCommand(null, ["env", "DANK_SHUTDOWN_UI=gui", backend].concat(args), () => {
            root.busy = false;
            root.refresh();
        }, 0, 30000);
    }

    function runCustom(text) {
        const spec = String(text || "").replace(/\s+/g, "");
        if (spec === "")
            return;
        run([spec.indexOf(":") >= 0 ? "at" : "in", spec]);
    }

    pillRightClickAction: () => {
        if (root.hasPlan)
            root.run(["cancel"]);
    }

    Component.onCompleted: refresh()

    Timer {
        // 有计划时刷得勤一点，保证倒计时跟手；没计划时 30 秒看一眼外部（终端里设的）变更
        interval: root.hasPlan ? 5000 : 30000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: root.hasPlan ? (root.schedMode === "reboot" ? "restart_alt" : "power_settings_new") : "schedule"
                size: Theme.barIconSize(root.barThickness, undefined, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
                color: root.hasPlan ? root.stateColor : Theme.widgetIconColor
                opacity: root.hasPlan ? 1 : 0.55
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                visible: root.hasPlan
                text: root.shortLeft(root.secondsLeft)
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                color: root.stateColor
                anchors.verticalCenter: parent.verticalCenter
                wrapMode: Text.NoWrap
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: 1

            DankIcon {
                name: root.hasPlan ? (root.schedMode === "reboot" ? "restart_alt" : "power_settings_new") : "schedule"
                size: Theme.barIconSize(root.barThickness, undefined, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
                color: root.hasPlan ? root.stateColor : Theme.widgetIconColor
                opacity: root.hasPlan ? 1 : 0.55
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                visible: root.hasPlan
                text: root.shortLeft(root.secondsLeft)
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                color: root.stateColor
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.NoWrap
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            id: popout

            headerText: "定时关机"
            detailsText: "计划由系统 shutdown 保管，重启 DMS 或登出都不影响；关机前 10 分钟和 1 分钟会弹提醒。右键胶囊可直接取消。"
            showCloseButton: true

            Item {
                width: parent.width
                implicitHeight: body.implicitHeight

                Column {
                    id: body
                    width: parent.width
                    spacing: Theme.spacingM

                    // 当前状态
                    StyledRect {
                        width: parent.width
                        height: 72
                        radius: Theme.cornerRadius
                        color: Theme.surfaceContainerHigh
                        border.width: 1
                        border.color: root.hasPlan ? root.stateColor : Theme.outlineMedium

                        Row {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingM

                            DankIcon {
                                name: root.hasPlan ? (root.schedMode === "reboot" ? "restart_alt" : "power_settings_new") : "schedule"
                                size: Theme.iconSizeLarge
                                color: root.stateColor
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Theme.spacingXXS

                                StyledText {
                                    text: root.hasPlan ? root.clockText(root.schedEpoch) + " " + root.modeText : "没有定时计划"
                                    font.pixelSize: Theme.fontSizeLarge
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }

                                StyledText {
                                    text: root.hasPlan ? "还有 " + root.longLeft(root.secondsLeft) : "选一个预设，或在下面输入时间"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                }
                            }
                        }
                    }

                    DankButton {
                        visible: root.hasPlan
                        width: parent.width
                        text: "取消" + root.modeText + "计划"
                        iconName: "cancel"
                        backgroundColor: Theme.withAlpha(Theme.error, 0.18)
                        textColor: Theme.error
                        onClicked: root.run(["cancel"])
                    }

                    // 预设
                    Flow {
                        width: parent.width
                        spacing: Theme.spacingS

                        Repeater {
                            model: root.presets

                            delegate: DankButton {
                                required property var modelData
                                text: modelData.label
                                iconName: modelData.icon
                                buttonHeight: 36
                                enabled: !root.busy
                                opacity: enabled ? 1 : 0.5
                                onClicked: root.run(modelData.args)
                            }
                        }
                    }

                    DankTextField {
                        id: customField
                        width: parent.width
                        placeholderText: "自定义：23:30 或 90m / 1h30m，回车确认"
                        leftIconName: "edit_calendar"
                        onAccepted: {
                            root.runCustom(text);
                            text = "";
                        }
                    }

                    StyledText {
                        visible: root.busy
                        width: parent.width
                        text: "正在提交…"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
}
