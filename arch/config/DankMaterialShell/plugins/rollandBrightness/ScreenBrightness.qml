import Quickshell
import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    // 设备判断交给 dank-brightness（与 Fn 键同一套逻辑），这里只负责展示和调节
    readonly property string backend: Quickshell.env("HOME") + "/.local/bin/dank-brightness"
    readonly property string kbdDevice: "leds:asus::kbd_backlight"
    readonly property string kbdPath: "/sys/class/leds/asus::kbd_backlight/brightness"
    readonly property var kbdLabels: ["关", "低", "中", "高"]

    property string panelDevice: ""     // backlight:nvidia_0 | backlight:nvidia_wmi_ec_backlight | ""
    property string gpuMode: ""         // direct | hybrid | ""
    property string externalDevice: ""  // ddc:i2c-N | ""
    property int kbdLevel: -1           // 0..3，-1 = 未读到

    readonly property var externalScreen: Quickshell.screens.find(s => !/^(eDP|LVDS|DSI)/i.test(s.name)) || null
    readonly property bool hasKbd: DisplayService.devices.some(d => d.id === kbdDevice)

    function percentOf(device) {
        DisplayService.brightnessVersion;
        return device ? Math.round(DisplayService.getDeviceBrightness(device)) : 0;
    }

    function panelSubtitle() {
        if (gpuMode === "direct")
            return "独显直连 · NVIDIA 背光";
        if (gpuMode === "hybrid")
            return panelDevice ? "Hybrid · EC 背光" : "Hybrid · EC 背光未加载";
        return "未识别内屏";
    }

    function refresh() {
        // id 传 null：多个实例（磁贴、详情面板）各自回调，互不顶掉
        Proc.runCommand(null, [backend, "which"], (stdout, exitCode) => {
            if (exitCode !== 0)
                return;
            const kv = {};
            String(stdout || "").split("\n").forEach(line => {
                const i = line.indexOf(" ");
                if (i > 0)
                    kv[line.slice(0, i)] = line.slice(i + 1).trim();
            });
            root.panelDevice = kv.panel || "";
            root.gpuMode = kv.mode || "";
            root.externalDevice = kv.external || "";
            // 让 DMS 自己的 OSD / 灵动岛也跟着用真正生效的内屏设备（切显卡模式后 session 里会残留旧设备）
            if (root.panelDevice && DisplayService.currentDevice !== root.panelDevice)
                DisplayService.setCurrentDevice(root.panelDevice, true);
        }, 0);
        readKbd();
    }

    function readKbd() {
        Proc.runCommand(null, ["cat", kbdPath], (stdout, exitCode) => {
            root.kbdLevel = exitCode === 0 ? parseInt(String(stdout).trim()) : -1;
        }, 0);
    }

    function setKbd(level) {
        kbdLevel = level;
        // leds 走 IPC 百分比（34/67/100 → 1/2/3 档）；DisplayService.setBrightness 会按 displayMax 截断
        Proc.runCommand(null, ["dms", "ipc", "call", "brightness", "set", String(Math.round(level * 100 / 3)), kbdDevice], () => readKbd(), 0);
    }

    Component.onCompleted: refresh()

    // 插拔显示器、DMS 重新枚举设备时重新判断
    Connections {
        target: Quickshell
        function onScreensChanged() {
            root.refresh();
        }
    }
    Connections {
        target: DisplayService
        function onDevicesChanged() {
            root.refresh();
        }
    }

    // ── 控制中心磁贴 ──────────────────────────────────────────────
    ccWidgetIcon: DisplayService.brightnessIconName(DisplayService.getCurrentDeviceInfoByName(panelDevice), percentOf(panelDevice))
    ccWidgetPrimaryText: "屏幕亮度"
    ccWidgetSecondaryText: {
        const parts = [];
        if (panelDevice)
            parts.push("内屏 " + percentOf(panelDevice) + "%");
        if (externalDevice)
            parts.push("外接 " + percentOf(externalDevice) + "%");
        return parts.length ? parts.join("  ") : "无可调设备";
    }
    ccWidgetIsActive: false
    ccDetailHeight: detailColumnHeight + Theme.spacingM * 2
    property real detailColumnHeight: 260

    // 一行：图标 + 名称/说明 + 右侧数值，下方滑块
    component ScreenRow: Column {
        id: row
        required property string title
        required property string subtitle
        required property string iconName
        required property string device
        width: parent ? parent.width : 320
        spacing: Theme.spacingS

        readonly property var info: DisplayService.getCurrentDeviceInfoByName(device)
        readonly property int level: root.percentOf(device)

        Row {
            width: parent.width
            spacing: Theme.spacingM

            DankIcon {
                name: row.iconName
                size: Theme.iconSize
                color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                width: parent.width - Theme.iconSize - valueText.width - Theme.spacingM * 2
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                    text: row.title
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                }
                StyledText {
                    width: parent.width
                    text: row.subtitle
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    elide: Text.ElideRight
                }
            }

            StyledText {
                id: valueText
                text: row.level + "%"
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Medium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        DankSlider {
            id: slider
            width: parent.width
            minimum: DisplayService.brightnessMinimum(row.info)
            maximum: DisplayService.brightnessMaximum(row.info)
            showValue: false
            wheelEnabled: true
            thumbOutlineColor: Theme.surfaceContainerHigh
            onSliderValueChanged: newValue => DisplayService.setBrightness(newValue, row.device, true)
            Binding on value {
                value: row.level
                when: !slider.isDragging
            }
        }
    }

    ccDetailContent: Component {
        Rectangle {
            implicitHeight: detail.implicitHeight + Theme.spacingM * 2
            radius: Theme.cornerRadius
            color: Theme.surfaceContainerHigh
            onImplicitHeightChanged: root.detailColumnHeight = detail.implicitHeight
            Component.onCompleted: root.refresh()

            Column {
                id: detail
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingL

                ScreenRow {
                    visible: root.panelDevice !== ""
                    title: "内置屏幕"
                    subtitle: root.panelSubtitle()
                    iconName: "laptop"
                    device: root.panelDevice
                }

                // 内屏设备缺失时说明原因，而不是给一个调了没反应的滑块
                Row {
                    visible: root.panelDevice === "" && root.gpuMode !== ""
                    width: parent.width
                    spacing: Theme.spacingM

                    DankIcon {
                        name: "warning"
                        size: Theme.iconSize
                        color: Theme.warning
                    }
                    StyledText {
                        width: parent.width - Theme.iconSize - Theme.spacingM
                        text: root.panelSubtitle() + "：Hybrid 下内屏背光由 EC 控制，需要 /etc/modprobe.d 里 nvidia_wmi_ec_backlight force=1"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                    }
                }

                ScreenRow {
                    visible: root.externalDevice !== ""
                    title: "外接显示器"
                    subtitle: (root.externalScreen ? [root.externalScreen.manufacturer, root.externalScreen.model].filter(s => s).join(" ") + " · " + root.externalScreen.name : "显示器") + " · DDC"
                    iconName: "desktop_windows"
                    device: root.externalDevice
                }

                // 键盘灯只有 4 档，用分段按钮比滑块直观
                Row {
                    visible: root.hasKbd
                    width: parent.width
                    spacing: Theme.spacingM

                    DankIcon {
                        name: "keyboard"
                        size: Theme.iconSize
                        color: Theme.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: "键盘背光"
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Row {
                        id: segs
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        readonly property real segWidth: 44

                        Repeater {
                            model: root.kbdLabels

                            delegate: Rectangle {
                                required property int index
                                required property string modelData
                                readonly property bool selected: root.kbdLevel === index
                                width: segs.segWidth
                                height: 30
                                radius: index === 0 || index === root.kbdLabels.length - 1 ? 15 : 4
                                color: selected ? Theme.primary : (segArea.containsMouse ? Theme.primaryHover : Theme.surfaceContainerHighest)

                                StyledText {
                                    anchors.centerIn: parent
                                    text: parent.modelData
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: parent.selected ? Theme.primaryText : Theme.surfaceText
                                }

                                MouseArea {
                                    id: segArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.setKbd(parent.index)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
