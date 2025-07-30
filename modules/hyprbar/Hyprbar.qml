import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes

Scope {
    PanelWindow { id: statusBar
        anchors {
            left: true
            bottom: true
            top: true
        }

        implicitWidth: 64

        color: "#00000000"

        Rectangle { id: bg
            anchors.fill: parent

            color: "#0b0a0f"

            Column {
                anchors.fill: parent
                Item { id: logoWrapper
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: x / 2
                    implicitWidth: 24
                    implicitHeight: implicitWidth

                    Image { id: logo
                        source: "../../assets/arch.svg"
                        anchors.fill: parent
                    }
                }
                Item { id: logoWrapper2
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: x / 2
                    implicitWidth: 24
                    implicitHeight: implicitWidth

                    Image { id: logo2
                        source: "../../assets/arch.svg"
                        anchors.fill: parent
                    }
                }

                Row { id: workspaces
                    Column { id: workspacesMain
                    }
                    Column { id: workspacesSecond
                    }
                }

                Item { id: time
                }
                Item { id: date
                }
            }
        }
    }
}
