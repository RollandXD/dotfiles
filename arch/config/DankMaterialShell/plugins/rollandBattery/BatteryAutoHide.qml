import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    // 原生 battery 组件写死了 visible: true，没有「插电隐藏」开关，所以自己包一层。
    // 插电时借 PluginComponent 的可见性覆盖把胶囊收成 0 宽（带收起动画），电量去控制中心看。
    readonly property bool shouldShow: BatteryService.batteryAvailable && !BatteryService.isPluggedIn

    onShouldShowChanged: setVisibilityOverride(shouldShow)
    Component.onCompleted: setVisibilityOverride(shouldShow)

    readonly property color iconColor: {
        if (BatteryService.isCriticalBattery)
            return Theme.error;
        if (BatteryService.isLowBattery)
            return Theme.warning;
        return Theme.widgetIconColor;
    }

    // 电池弹窗是 LazyLoader，先激活再在下一拍 toggle（此时 PopoutService.batteryPopout 已就位）
    pillClickAction: (x, y, width, section, screen) => {
        const loader = PopoutService.batteryPopoutLoader;
        if (loader)
            loader.active = true;
        Qt.callLater(() => PopoutService.toggleBattery(x, y, width, section, screen));
    }

    horizontalBarPill: Component {
        Row {
            spacing: 2

            DankIcon {
                name: BatteryService.getBatteryIcon()
                size: Theme.barIconSize(root.barThickness, -4, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
                color: root.iconColor
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: Math.round(BatteryService.batteryLevel) + "%"
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
                name: BatteryService.getBatteryIcon()
                size: Theme.barIconSize(root.barThickness, undefined, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
                color: root.iconColor
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: Math.round(BatteryService.batteryLevel)
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                color: Theme.widgetTextColor
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.NoWrap
            }
        }
    }
}
