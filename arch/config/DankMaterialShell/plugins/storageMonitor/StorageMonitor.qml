import Quickshell
import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    readonly property var monitoredPaths: ["/", "/home", "/mnt/wingame"]
    readonly property var placeholderRows: monitoredPaths.map(path => ({
        "mount": path,
        "device": "",
        "size": "--",
        "used": "--",
        "avail": "--",
        "percent": null,
        "missing": false
    }))

    property var diskRows: []
    property bool loading: false
    property string lastError: ""

    readonly property var displayRows: diskRows.length > 0 ? diskRows : placeholderRows
    readonly property var primaryBarMount: {
        const mounts = DgopService.diskMounts || [];
        const dgopRoot = mounts.find(mount => mount.mount === "/");
        return dgopRoot || (diskRows.length > 0 ? diskRows[0] : null);
    }
    readonly property real primaryPercent: {
        if (!primaryBarMount || primaryBarMount.percent === undefined || primaryBarMount.percent === null)
            return -1;
        return typeof primaryBarMount.percent === "number" ? primaryBarMount.percent : parseFloat(String(primaryBarMount.percent).replace("%", ""));
    }
    readonly property color usageColor: {
        if (primaryPercent > 90)
            return Theme.tempDanger;
        if (primaryPercent > 75)
            return Theme.tempWarning;
        return Theme.widgetIconColor;
    }

    function refreshData() {
        if (loading)
            return;

        loading = true;
        Proc.runCommand(
            null,
            ["df", "-hP", "--"].concat(monitoredPaths),
            (stdout, exitCode) => {
                if (exitCode !== 0) {
                    lastError = "读取磁盘空间失败（df 退出码 " + exitCode + "）";
                    loading = false;
                    return;
                }

                const parsedRows = [];
                const lines = String(stdout || "").trim().split(/\r?\n/);
                for (let index = 1; index < lines.length; index++) {
                    const line = lines[index].trim();
                    if (!line)
                        continue;

                    const fields = line.split(/\s+/);
                    if (fields.length < 6)
                        continue;

                    parsedRows.push({
                        "device": fields.slice(0, fields.length - 5).join(" "),
                        "size": fields[fields.length - 5],
                        "used": fields[fields.length - 4],
                        "avail": fields[fields.length - 3],
                        "percent": parseFloat(fields[fields.length - 2].replace("%", "")),
                        "mount": fields[fields.length - 1],
                        "missing": false
                    });
                }

                const dgopMounts = DgopService.diskMounts || [];
                parsedRows.forEach(row => {
                    const dgopRow = dgopMounts.find(mount => mount.mount === row.mount)
                        || (row.mount === "/home" ? dgopMounts.find(mount => mount.mount === "/" && mount.device === row.device) : null);
                    if (!dgopRow)
                        return;

                    row.size = dgopRow.size || row.size;
                    row.used = dgopRow.used || row.used;
                    row.avail = dgopRow.avail || row.avail;
                    row.percent = parseFloat(String(dgopRow.percent || row.percent).replace("%", ""));
                });

                const byMount = {};
                parsedRows.forEach(row => byMount[row.mount] = row);
                diskRows = monitoredPaths.map(path => byMount[path] || ({
                    "mount": path,
                    "device": "",
                    "size": "--",
                    "used": "--",
                    "avail": "--",
                    "percent": null,
                    "missing": true
                }));
                lastError = diskRows.some(row => row.missing) ? "部分挂载点暂不可用" : "";
                loading = false;
            },
            100
        );
    }

    function rowPercent(row) {
        if (!row || row.percent === undefined || row.percent === null || isNaN(row.percent))
            return -1;
        return Number(row.percent);
    }

    function rowColor(row) {
        const percent = rowPercent(row);
        if (percent > 90)
            return Theme.error;
        if (percent > 75)
            return Theme.warning;
        return Theme.primary;
    }

    Component.onCompleted: {
        DgopService.addRef(["diskmounts"]);
        refreshData();
    }

    Component.onDestruction: {
        DgopService.removeRef(["diskmounts"]);
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.refreshData()
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: "storage"
                size: Theme.barIconSize(root.barThickness, undefined, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
                color: root.usageColor
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.primaryPercent >= 0 ? root.primaryPercent.toFixed(0) + "%" : "--%"
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                color: Theme.widgetTextColor
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideNone
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
                color: root.usageColor
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: root.primaryPercent >= 0 ? root.primaryPercent.toFixed(0) : "--"
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                color: Theme.widgetTextColor
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideNone
                wrapMode: Text.NoWrap
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            id: diskPopout

            headerText: "磁盘空间"
            detailsText: "实时显示 /、/home 与 /mnt/wingame 三个挂载点。/home 会单独列出，即使它与 / 共用同一文件系统容量。"
            showCloseButton: true

            Item {
                width: parent.width
                implicitHeight: diskColumn.implicitHeight

                Column {
                    id: diskColumn
                    width: parent.width
                    spacing: Theme.spacingS

                    Repeater {
                        model: root.displayRows

                        delegate: StyledRect {
                            required property var modelData

                            width: parent.width
                            height: 92
                            radius: Theme.cornerRadius
                            color: Theme.surfaceContainerHigh
                            border.width: 1
                            border.color: Theme.outlineMedium

                            Row {
                                anchors.fill: parent
                                anchors.margins: Theme.spacingM
                                spacing: Theme.spacingM

                                DankIcon {
                                    name: "storage"
                                    size: Theme.iconSize
                                    color: root.rowColor(modelData)
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    width: parent.width - Theme.iconSize - parent.spacing
                                    spacing: Theme.spacingXXS
                                    anchors.verticalCenter: parent.verticalCenter

                                    Item {
                                        width: parent.width
                                        height: pathText.implicitHeight

                                        StyledText {
                                            id: pathText
                                            anchors.left: parent.left
                                            anchors.right: percentText.left
                                            anchors.rightMargin: Theme.spacingS
                                            text: modelData.mount === "/" ? "根文件系统  /" : modelData.mount
                                            font.pixelSize: Theme.fontSizeMedium
                                            font.weight: Font.Medium
                                            color: Theme.surfaceText
                                            elide: Text.ElideRight
                                            wrapMode: Text.NoWrap
                                        }

                                        StyledText {
                                            id: percentText
                                            anchors.right: parent.right
                                            text: root.rowPercent(modelData) >= 0 ? root.rowPercent(modelData).toFixed(0) + "%" : "--"
                                            font.pixelSize: Theme.fontSizeMedium
                                            font.weight: Font.Medium
                                            color: root.rowColor(modelData)
                                            horizontalAlignment: Text.AlignRight
                                            wrapMode: Text.NoWrap
                                        }
                                    }

                                    StyledText {
                                        width: parent.width
                                        text: modelData.missing ? "挂载点不可用" : modelData.used + " 已用  ·  " + modelData.avail + " 可用  ·  " + modelData.size + " 总计"
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
                                            width: parent.width * Math.max(0, Math.min(1, root.rowPercent(modelData) / 100))
                                            height: parent.height
                                            radius: parent.radius
                                            color: root.rowColor(modelData)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    StyledText {
                        visible: root.loading || root.lastError.length > 0
                        width: parent.width
                        text: root.loading ? "正在刷新磁盘数据…" : root.lastError
                        font.pixelSize: Theme.fontSizeSmall
                        color: root.lastError.length > 0 ? Theme.error : Theme.surfaceVariantText
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
}
