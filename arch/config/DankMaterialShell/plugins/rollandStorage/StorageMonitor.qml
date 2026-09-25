import Quickshell
import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    // 数据全部来自 DgopService（DMS 本就在轮询，这里零额外进程）。
    // /home 与 / 同为一个 btrfs 分区时 dgop 只给出 /，所以只有 /home 独立挂载时才会单列。
    // 超阈值告警由 disk-space-guard.timer 负责，这里只做展示。
    readonly property var monitoredPaths: ["/", "/home", "/mnt/wingame"]
    readonly property var optionalPaths: ["/home"] // 不存在时静默省略，而不是显示「未挂载」

    function toPercent(value) {
        if (value === undefined || value === null)
            return -1;
        const n = typeof value === "number" ? value : parseFloat(String(value).replace("%", ""));
        return isNaN(n) ? -1 : n;
    }

    readonly property var mounts: DgopService.diskMounts || []
    readonly property var rootMount: mounts.find(m => m.mount === "/") || null
    readonly property real rootPercent: toPercent(rootMount?.percent)
    readonly property bool homeSeparate: mounts.some(m => m.mount === "/home")

    readonly property var rows: monitoredPaths.map(path => {
        const m = mounts.find(x => x.mount === path);
        if (!m)
            return optionalPaths.indexOf(path) >= 0 ? null : { "mount": path, "missing": true };
        return {
            "mount": path,
            "fstype": m.fstype || "",
            "size": m.size || "--",
            "used": m.used || "--",
            "avail": m.avail || "--",
            "percent": toPercent(m.percent),
            "missing": false
        };
    }).filter(r => r !== null)

    function mountTitle(row) {
        if (row.mount === "/")
            return homeSeparate ? "根分区  /" : "根分区  /（含 /home）";
        return row.mount;
    }

    function levelColor(percent, normal) {
        if (percent > 90)
            return Theme.error;
        if (percent > 75)
            return Theme.warning;
        return normal;
    }

    readonly property color pillColor: rootPercent > 90 ? Theme.tempDanger : (rootPercent > 75 ? Theme.tempWarning : Theme.widgetIconColor)

    Component.onCompleted: DgopService.addRef(["diskmounts"])
    Component.onDestruction: DgopService.removeRef(["diskmounts"])

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: "storage"
                size: Theme.barIconSize(root.barThickness, undefined, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
                color: root.pillColor
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.rootPercent >= 0 ? root.rootPercent.toFixed(0) + "%" : "--%"
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                color: Theme.widgetTextColor
                anchors.verticalCenter: parent.verticalCenter
                wrapMode: Text.NoWrap
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: 1

            DankIcon {
                name: "storage"
                size: Theme.barIconSize(root.barThickness, undefined, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
                color: root.pillColor
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: root.rootPercent >= 0 ? root.rootPercent.toFixed(0) : "--"
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                color: Theme.widgetTextColor
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.NoWrap
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            id: diskPopout

            headerText: "磁盘空间"
            detailsText: root.rootMount ? "根分区还剩 " + root.rootMount.avail + "。点击条目用文件管理器打开。" : "点击条目用文件管理器打开。"
            showCloseButton: true

            Item {
                width: parent.width
                implicitHeight: diskColumn.implicitHeight

                Column {
                    id: diskColumn
                    width: parent.width
                    spacing: Theme.spacingS

                    Repeater {
                        model: root.rows

                        delegate: StyledRect {
                            id: card
                            required property var modelData
                            readonly property color accent: modelData.missing ? Theme.surfaceVariantText : root.levelColor(modelData.percent, Theme.primary)

                            width: parent.width
                            height: 92
                            radius: Theme.cornerRadius
                            color: cardMouse.containsMouse && !modelData.missing ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
                            border.width: 1
                            border.color: Theme.outlineMedium

                            Row {
                                anchors.fill: parent
                                anchors.margins: Theme.spacingM
                                spacing: Theme.spacingM

                                DankIcon {
                                    name: card.modelData.mount === "/" ? "hard_drive" : "storage"
                                    size: Theme.iconSize
                                    color: card.accent
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    width: parent.width - Theme.iconSize - parent.spacing
                                    spacing: Theme.spacingXXS
                                    anchors.verticalCenter: parent.verticalCenter

                                    Item {
                                        width: parent.width
                                        height: titleText.implicitHeight

                                        StyledText {
                                            id: titleText
                                            anchors.left: parent.left
                                            anchors.right: percentText.left
                                            anchors.rightMargin: Theme.spacingS
                                            text: root.mountTitle(card.modelData)
                                            font.pixelSize: Theme.fontSizeMedium
                                            font.weight: Font.Medium
                                            color: Theme.surfaceText
                                            elide: Text.ElideRight
                                            wrapMode: Text.NoWrap
                                        }

                                        StyledText {
                                            id: percentText
                                            anchors.right: parent.right
                                            text: card.modelData.missing ? "" : card.modelData.percent.toFixed(0) + "%"
                                            font.pixelSize: Theme.fontSizeMedium
                                            font.weight: Font.Medium
                                            color: card.accent
                                            wrapMode: Text.NoWrap
                                        }
                                    }

                                    StyledText {
                                        width: parent.width
                                        text: card.modelData.missing ? "未挂载" : card.modelData.used + " 已用  ·  " + card.modelData.avail + " 可用  ·  " + card.modelData.size + " 总计  ·  " + card.modelData.fstype
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                        elide: Text.ElideRight
                                        wrapMode: Text.NoWrap
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 6
                                        radius: height / 2
                                        color: Theme.withAlpha(Theme.surfaceVariant, 0.45)

                                        Rectangle {
                                            width: parent.width * (card.modelData.missing ? 0 : Math.max(0, Math.min(1, card.modelData.percent / 100)))
                                            height: parent.height
                                            radius: parent.radius
                                            color: card.accent
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: cardMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: !card.modelData.missing
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    Quickshell.execDetached(["xdg-open", card.modelData.mount]);
                                    if (diskPopout.closePopout)
                                        diskPopout.closePopout();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
