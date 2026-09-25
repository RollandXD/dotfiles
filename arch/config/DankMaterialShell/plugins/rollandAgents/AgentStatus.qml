import Quickshell
import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    // 状态由各 agent 的 hook / 扩展写入，agent-status list 负责汇总并清理死进程
    readonly property string backend: Quickshell.env("HOME") + "/.local/bin/agent-status"
    readonly property var agentNames: ({ "codex": "Codex", "claude": "Claude", "pi": "Pi" })

    property var sessions: []
    property real nowEpoch: Date.now() / 1000

    readonly property int waitingCount: sessions.filter(s => s.state === "waiting").length
    readonly property int runningCount: sessions.filter(s => s.state === "running").length
    readonly property int doneCount: sessions.filter(s => s.state === "done" || s.state === "idle").length
    readonly property color pillColor: waitingCount > 0 ? Theme.warning : (runningCount > 0 ? Theme.primary : Theme.widgetIconColor)
    readonly property string pillText: waitingCount > 0 ? waitingCount + "!" : (runningCount > 0 ? String(runningCount) : "")

    function stateColor(state) {
        if (state === "waiting")
            return Theme.warning;
        if (state === "running")
            return Theme.primary;
        return Theme.surfaceVariantText;
    }

    function stateText(state) {
        if (state === "waiting")
            return "等你确认";
        if (state === "running")
            return "运行中";
        if (state === "idle")
            return "空闲";
        return "已完成";
    }

    function elapsed(since) {
        const sec = Math.max(0, Math.round(nowEpoch - since));
        if (sec < 60)
            return sec + " 秒";
        if (sec < 3600)
            return Math.floor(sec / 60) + " 分钟";
        return Math.floor(sec / 3600) + " 小时 " + Math.floor((sec % 3600) / 60) + " 分";
    }

    function refresh() {
        Proc.runCommand("rollandAgents.list", [backend, "list"], (stdout, exitCode) => {
            root.nowEpoch = Date.now() / 1000;
            if (exitCode !== 0)
                return;
            try {
                root.sessions = JSON.parse(String(stdout || "[]"));
            } catch (e) {
                root.sessions = [];
            }
        }, 0);
    }

    function focusSession(s) {
        Proc.runCommand(null, [backend, "focus", s.agent, s.session], () => {}, 0, 8000);
    }

    Component.onCompleted: refresh()

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: root.waitingCount > 0 ? "front_hand" : "smart_toy"
                size: Theme.barIconSize(root.barThickness, undefined, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
                color: root.pillColor
                opacity: root.sessions.length > 0 ? 1 : 0.55
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                visible: root.pillText !== ""
                text: root.pillText
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                color: root.pillColor
                anchors.verticalCenter: parent.verticalCenter
                wrapMode: Text.NoWrap
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: 1

            DankIcon {
                name: root.waitingCount > 0 ? "front_hand" : "smart_toy"
                size: Theme.barIconSize(root.barThickness, undefined, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
                color: root.pillColor
                opacity: root.sessions.length > 0 ? 1 : 0.55
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                visible: root.pillText !== ""
                text: root.pillText
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                color: root.pillColor
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.NoWrap
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            id: popout

            headerText: "AI Agents"
            detailsText: root.sessions.length === 0 ? "" : root.waitingCount + " 个等你 · " + root.runningCount + " 个运行中 · " + root.doneCount + " 个空闲/已完成。点击条目跳到对应终端，后台任务无法跳转。"
            showCloseButton: true

            Item {
                width: parent.width
                implicitHeight: list.implicitHeight

                Column {
                    id: list
                    width: parent.width
                    spacing: Theme.spacingS

                    StyledText {
                        visible: root.sessions.length === 0
                        width: parent.width
                        text: "没有活动中的 Codex / Claude / Pi 会话"
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceVariantText
                        horizontalAlignment: Text.AlignHCenter
                        topPadding: Theme.spacingL
                        bottomPadding: Theme.spacingL
                    }

                    Repeater {
                        model: root.sessions

                        delegate: StyledRect {
                            id: row
                            required property var modelData

                            width: parent.width
                            height: 68
                            opacity: modelData.background ? 0.6 : 1
                            radius: Theme.cornerRadius
                            color: rowMouse.containsMouse && !modelData.background ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
                            border.width: 1
                            border.color: modelData.state === "waiting" ? Theme.warning : Theme.outlineMedium

                            Row {
                                anchors.fill: parent
                                anchors.margins: Theme.spacingM
                                spacing: Theme.spacingM

                                // 状态指示点
                                Rectangle {
                                    width: 10
                                    height: 10
                                    radius: 5
                                    color: root.stateColor(row.modelData.state)
                                    anchors.verticalCenter: parent.verticalCenter

                                    SequentialAnimation on opacity {
                                        running: row.modelData.state === "running" || row.modelData.state === "waiting"
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 0.3; duration: 700 }
                                        NumberAnimation { to: 1; duration: 700 }
                                    }
                                }

                                Column {
                                    width: parent.width - 10 - parent.spacing
                                    spacing: Theme.spacingXXS
                                    anchors.verticalCenter: parent.verticalCenter

                                    Item {
                                        width: parent.width
                                        height: titleText.implicitHeight

                                        StyledText {
                                            id: titleText
                                            anchors.left: parent.left
                                            anchors.right: stateLabel.left
                                            anchors.rightMargin: Theme.spacingS
                                            text: (root.agentNames[row.modelData.agent] || row.modelData.agent) + (row.modelData.background ? "（后台）" : "") + "  ·  " + (row.modelData.project || "~")
                                            font.pixelSize: Theme.fontSizeMedium
                                            font.weight: Font.Medium
                                            color: Theme.surfaceText
                                            elide: Text.ElideRight
                                            wrapMode: Text.NoWrap
                                        }

                                        StyledText {
                                            id: stateLabel
                                            anchors.right: parent.right
                                            text: root.stateText(row.modelData.state) + " " + root.elapsed(row.modelData.since)
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: root.stateColor(row.modelData.state)
                                            wrapMode: Text.NoWrap
                                        }
                                    }

                                    StyledText {
                                        width: parent.width
                                        text: (row.modelData.state === "waiting" && row.modelData.detail) ? row.modelData.detail : (row.modelData.task || row.modelData.cwd || "")
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                        elide: Text.ElideRight
                                        wrapMode: Text.NoWrap
                                    }
                                }
                            }

                            MouseArea {
                                id: rowMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: !row.modelData.background
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.focusSession(row.modelData);
                                    if (popout.closePopout)
                                        popout.closePopout();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
