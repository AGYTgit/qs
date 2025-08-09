import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import qs.modules.hyprbar.widgets
import qs.modules.clock
import qs.modules.battery
import qs.types

PanelWindow { id: statusBar
    exclusionMode: ExclusionMode.Exclusive
    aboveWindows: true
    focusable: false

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

        ColumnLayout { id: content
            anchors.fill: parent
            ColumnLayout { id: topGroup
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                spacing: 0

                ItemIcon {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 10

                    iconWidth: 24
                    source: "../assets/arch.svg"
                }
                Workspaces {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 15
                }
            }

            Item {
                Layout.fillHeight: true
            }

            ColumnLayout { id: bottomGroup
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom

                Battery {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 6

                    text: capacity
                    capacityActive: true
                    color: "#DDDDDD"
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 6

                    width: 24
                    height: 2
                    color: "#666666"
                }

                Clock { id: time
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 6

                    format: "hh\nmm"
                    use12HourCycle: true
                    interval: 60000
                    font.pixelSize: 20
                    color: "#DDDDDD"
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 6

                    width: 24
                    height: 2
                    color: "#666666"
                }

                Clock { id: date
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 12

                    format: "dd\nMM"
                    interval: 60000
                    font.pixelSize: 20
                    color: "#DDDDDD"
                }
            }
        }
    }
}
