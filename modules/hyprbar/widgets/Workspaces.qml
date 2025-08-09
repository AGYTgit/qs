import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes

Row { id: workspaces
    spacing: 8

    Column { id: wsMain
        spacing: 10

        Repeater {
            model: Hyprland.workspaces

            Image {
                // visible: (modelData.monitor.id == 0 ? true : false)
                visible: (modelData.id <= 5 ? true : false)

                source: {
                    // "../../../assets/workspaces/c/c" + "<window-count>" + ".svg"
                    "../../../assets/workspaces/c/c" + 1 + ".svg"
                }
                width: 12
                height: width
                sourceSize.width: 12
                sourceSize.height: 12
            }
        }
    }
    Column { id: wsSec
        spacing: 10

        Repeater {
            model: Hyprland.workspaces

            Image {
                // visible: (modelData.monitor.id == 0 ? true : false)
                visible: (modelData.id > 5 ? true : false)

                source: {
                    // "../../../assets/workspaces/c/c" + "<window-count>" + ".svg"
                    "../../../assets/workspaces/c/c" + 1 + ".svg"
                }
                width: 12
                height: width
                sourceSize.width: 12
                sourceSize.height: 12
            }
        }
    }
}
