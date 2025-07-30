import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes

Scope {
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio

        function onVolumeChanged() {
            isVisible = true
            hideTimer.restart();
        }
    }

    Timer { id: hideTimer
        interval: 1000
        onTriggered: isVisible = false
    }
    property bool isVisible: false

    PanelWindow { id: panel
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true
        focusable: false
        mask: Region {}

        anchors {
            left: true
            bottom: true
            top: true
            right: true
        }

        color: "#00000000"

        Rectangle { id: volumeSliderPopup

            x: isVisible ? Screen.width - width : Screen.width
            y: Screen.height / 2 - height / 2

            Behavior on x {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            width: 48
            height: 416 / 2

            topLeftRadius: width
            bottomLeftRadius: width

            color: "#0b0a0f"
            // add blur

            Slider { id: outputSlider
                //anchors.centerIn: parent
                x: parent.width / 2 - width / 2
                y: parent.height / 2 - height / 2

                width: 12
                height: 150

                from: 0
                to: 100
                value: Math.round((Pipewire.defaultAudioSink?.audio.volume ?? 0) * 100)

                orientation: Qt.Vertical

                background: Rectangle {
                    implicitWidth: parent.availableWidth
                    implicitHeight: parent.availableHeight
                    radius: width
                    color: "#bdbebf"

                    Rectangle {
                        width: parent.width
                        height: (1 - parent.parent.visualPosition) * parent.height
                        x: parent.x
                        y: parent.height * parent.parent.visualPosition
                        radius: width
                        color: "#33ccff"
                    }
                }

                handle: Rectangle {
                    x: parent.availableWidth / 2 - width / 2
                    y: parent.visualPosition * (parent.availableHeight - height)
                    implicitWidth: parent.availableWidth
                    implicitHeight: parent.availableHeight / 4
                    radius: width
                    color: "#5d5e5f"

                    Behavior on y {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
