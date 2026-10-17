import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root
    readonly property var soundState: PluginService.getGlobalVar("rollandSystemSounds", "state", {available: false})
    readonly property var controller: PluginService.getGlobalVar("rollandSystemSounds", "controller", null)
    readonly property var soundSources: PluginService.getGlobalVar("rollandSystemSounds", "sources", [])
    readonly property bool ready: soundState.available === true && controller !== null
    readonly property int disabledCount: soundSources.filter(s => !s.enabled).length
    readonly property var groupOrder: ["system", "tools", "ai", "other"]
    readonly property var groupTitles: ({system: "系统", tools: "工具", ai: "AI 助手", other: "其他"})
    property string expandedId: ""

    // 稳定的数据模型：来源集合不变时只改属性，不重建行（否则拖动中的滑块会被打断）
    ListModel { id: sourceModel }

    function rowData(s) {
        return {
            sid: s.id, label: s.name, group: s.group, status: s.status,
            limited: !!s.limited, boostAllowed: !!s.boost_allowed, enabled: !!s.enabled,
            trimDb: s.trim_db || 0
        };
    }
    function syncModel() {
        // QML 的 sort 不保证稳定：用原始下标做次序键，组内保持后端给出的顺序
        const sorted = soundSources
            .map((s, i) => ({s: s, i: i, g: groupOrder.indexOf(s.group) < 0 ? groupOrder.length : groupOrder.indexOf(s.group)}))
            .sort((a, b) => a.g - b.g || a.i - b.i)
            .map(x => x.s);
        let same = sorted.length === sourceModel.count;
        for (let i = 0; same && i < sorted.length; i++)
            same = sourceModel.get(i).sid === sorted[i].id;
        if (same) {
            sorted.forEach((s, i) => sourceModel.set(i, rowData(s)));
        } else {
            sourceModel.clear();
            sorted.forEach(s => sourceModel.append(rowData(s)));
        }
    }
    onSoundSourcesChanged: syncModel()
    Component.onCompleted: syncModel()

    function dbText(value) {
        const v = Math.round((value || 0) * 10) / 10;
        return (v > 0 ? "+" : v < 0 ? "−" : "") + Math.abs(v) + " dB";
    }
    function noteFor(status, enabled, limited) {
        if (!enabled) return "已关闭";
        if (status !== "已校准") return status;
        return limited ? "已到增益上限" : "";
    }

    ccWidgetIcon: soundState.muted ? "notifications_off" : "notifications_active"
    ccWidgetPrimaryText: "提示音"
    ccWidgetSecondaryText: !soundState.available ? "音频服务不可用"
        : soundState.muted ? "已静音"
        : Math.round(soundState.percent) + "%" + (disabledCount > 0 ? " · 关闭 " + disabledCount + " 项" : "")
    ccWidgetIsActive: soundState.available && !soundState.muted && soundState.percent > 0
    ccDetailHeight: 520
    onCcWidgetToggled: { if (ready) controller.toggleMute(); }
    onCcWidgetExpanded: { if (controller) controller.refreshSources(); }

    ccDetailContent: Component {
        Rectangle {
            color: Theme.surfaceContainerHigh
            radius: Theme.cornerRadius
            implicitHeight: contents.implicitHeight + Theme.spacingM * 2
            Column {
                id: contents
                x: Theme.spacingM
                y: Theme.spacingM
                width: parent.width - Theme.spacingM * 2
                spacing: Theme.spacingS

                // 状态：当前统一音量 + 全局操作
                Row {
                    width: parent.width
                    spacing: Theme.spacingS
                    Column {
                        width: parent.width - headerActions.width - parent.spacing
                        anchors.verticalCenter: parent.verticalCenter
                        StyledText {
                            text: !root.soundState.available ? "不可用" : root.soundState.muted ? "已静音" : Math.round(root.soundState.percent) + "%"
                            color: Theme.surfaceText
                            font.pixelSize: Theme.fontSizeXLarge
                            font.weight: Font.Medium
                        }
                        StyledText {
                            width: parent.width
                            text: root.soundState.available ? "统一管理通知、截图、响铃、AI 提醒；音乐与视频音量独立" : "音频服务不可用，正在重新连接"
                            color: Theme.surfaceVariantText
                            font.pixelSize: Theme.fontSizeSmall
                            wrapMode: Text.WordWrap
                        }
                    }
                    Row {
                        id: headerActions
                        anchors.verticalCenter: parent.verticalCenter
                        DankActionButton {
                            iconName: root.soundState.muted ? "notifications_off" : "notifications_active"
                            tooltipText: root.soundState.muted ? "取消静音" : "静音"
                            enabled: root.ready
                            onClicked: root.controller?.toggleMute()
                        }
                        DankActionButton {
                            iconName: "play_arrow"
                            tooltipText: "试听普通通知"
                            enabled: root.ready && !root.soundState.muted
                            onClicked: root.controller?.preview("notification")
                        }
                    }
                }

                // 操作：音量
                DankSlider {
                    id: volumeSlider
                    objectName: "systemSoundsVolumeSlider"
                    width: parent.width
                    enabled: root.soundState.available
                    minimum: 0; maximum: 100
                    leftIcon: "notifications_active"
                    activeFocusOnTab: true
                    Component.onCompleted: forceActiveFocus()
                    onSliderValueChanged: newValue => { if (root.controller) root.controller.setVolume(newValue); }
                    Keys.onLeftPressed: { if (root.controller) root.controller.setVolume(Math.max(0, value - 5)); }
                    Keys.onRightPressed: { if (root.controller) root.controller.setVolume(Math.min(100, value + 5)); }
                }
                Binding { target: volumeSlider; property: "value"; value: root.soundState.percent || 0; when: !volumeSlider.isDragging }

                Rectangle { width: parent.width; height: 1; color: Theme.outlineVariant }

                // 来源：分组列表。点一行展开「响度微调」滑块（松手自动试听）
                Flickable {
                    width: parent.width
                    height: Math.min(sourceList.implicitHeight, 330)
                    contentWidth: width
                    contentHeight: sourceList.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar {
                        width: 5
                        policy: ScrollBar.AsNeeded
                        contentItem: Rectangle { radius: 2; color: Theme.primary }
                    }
                    Column {
                        id: sourceList
                        width: parent.width - 8
                        Repeater {
                            model: sourceModel
                            Column {
                                id: entry
                                required property int index
                                required property string sid
                                required property string label
                                required property string group
                                required property string status
                                required property bool limited
                                required property bool boostAllowed
                                required property bool enabled
                                required property real trimDb
                                readonly property bool calibrated: status === "已校准"
                                readonly property bool expanded: root.expandedId === sid && calibrated
                                readonly property bool firstInGroup: index === 0 || sourceModel.get(index - 1).group !== group
                                width: sourceList.width

                                StyledText {
                                    visible: entry.firstInGroup
                                    text: root.groupTitles[entry.group] || entry.group
                                    color: Theme.primary
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.Medium
                                    topPadding: entry.index === 0 ? 0 : Theme.spacingS
                                    bottomPadding: Theme.spacingXXS
                                }

                                Item {
                                    width: parent.width
                                    height: 44
                                    DankToggle {
                                        id: enableSwitch
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        hideText: true
                                        checked: entry.enabled
                                        enabled: root.ready
                                        onToggled: value => root.controller?.setEnabled(entry.sid, value)
                                    }
                                    // 名称区：点击展开/收起微调
                                    MouseArea {
                                        id: nameArea
                                        anchors.left: enableSwitch.right
                                        anchors.leftMargin: Theme.spacingS
                                        anchors.right: trimBadge.left
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        enabled: entry.calibrated
                                        cursorShape: entry.calibrated ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: root.expandedId = entry.expanded ? "" : entry.sid
                                        Column {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.verticalCenter: parent.verticalCenter
                                            opacity: entry.enabled ? 1 : 0.5
                                            StyledText {
                                                width: parent.width
                                                text: entry.label
                                                color: Theme.surfaceText
                                                elide: Text.ElideRight
                                            }
                                            StyledText {
                                                width: parent.width
                                                visible: text !== ""
                                                text: root.noteFor(entry.status, entry.enabled, entry.limited)
                                                color: Theme.surfaceVariantText
                                                font.pixelSize: Theme.fontSizeSmall
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }
                                    StyledText {
                                        id: trimBadge
                                        anchors.right: playButton.left
                                        anchors.rightMargin: Theme.spacingXS
                                        anchors.verticalCenter: parent.verticalCenter
                                        visible: entry.calibrated && entry.trimDb !== 0
                                        text: root.dbText(entry.trimDb)
                                        color: Theme.primary
                                        font.pixelSize: Theme.fontSizeSmall
                                    }
                                    DankActionButton {
                                        id: playButton
                                        anchors.right: expandButton.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        visible: entry.calibrated
                                        iconName: "play_arrow"
                                        buttonSize: 30
                                        tooltipText: "试听"
                                        enabled: root.ready && !root.soundState.muted
                                        onClicked: root.controller?.preview(entry.sid)
                                    }
                                    DankActionButton {
                                        id: expandButton
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        visible: entry.calibrated
                                        iconName: entry.expanded ? "expand_less" : "tune"
                                        buttonSize: 30
                                        tooltipText: entry.expanded ? "收起" : "调整这个来源的响度"
                                        onClicked: root.expandedId = entry.expanded ? "" : entry.sid
                                    }
                                }

                                // 展开：响度微调滑块（0.5 dB 一格，范围 ±6 dB，中点 0）
                                Item {
                                    width: parent.width
                                    height: entry.expanded ? 48 : 0
                                    visible: entry.expanded
                                    clip: true
                                    Timer {
                                        id: commitTimer
                                        interval: 220
                                        onTriggered: root.controller?.trim(entry.sid, trimSlider.dbValue, false)
                                    }
                                    DankSlider {
                                        id: trimSlider
                                        readonly property real dbValue: (value - 12) / 2
                                        anchors.left: parent.left
                                        anchors.leftMargin: Theme.spacingS
                                        anchors.right: dbLabel.left
                                        anchors.rightMargin: Theme.spacingS
                                        anchors.verticalCenter: parent.verticalCenter
                                        minimum: 0; maximum: 24
                                        showValue: false
                                        enabled: root.ready
                                        // 随拖动实时提交（去抖），松手立即提交并自动试听
                                        onSliderValueChanged: newValue => commitTimer.restart()
                                        onSliderDragFinished: finalValue => {
                                            commitTimer.stop();
                                            root.controller?.trim(entry.sid, (finalValue - 12) / 2, true);
                                        }
                                    }
                                    // 外部状态（面板刷新）同步到滑块，拖动或待提交时不覆盖
                                    Binding {
                                        target: trimSlider
                                        property: "value"
                                        value: Math.round(12 + entry.trimDb * 2)
                                        when: !trimSlider.isDragging && !commitTimer.running
                                    }
                                    StyledText {
                                        id: dbLabel
                                        anchors.right: resetButton.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 56
                                        horizontalAlignment: Text.AlignRight
                                        text: root.dbText(trimSlider.dbValue)
                                        color: trimSlider.dbValue === 0 ? Theme.surfaceVariantText : Theme.primary
                                        font.pixelSize: Theme.fontSizeSmall
                                    }
                                    DankActionButton {
                                        id: resetButton
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        iconName: "restart_alt"
                                        buttonSize: 30
                                        tooltipText: "恢复默认响度"
                                        enabled: root.ready && entry.trimDb !== 0
                                        onClicked: { commitTimer.stop(); root.controller?.trim(entry.sid, 0, true); }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
