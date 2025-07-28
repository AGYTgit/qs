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
        objects: [
            Pipewire.defaultAudioSink,
            // Pipewire.defaultAudioSource
        ]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio

        function onVolumeChanged() {
            root.audioPopupVisible = true
            hideTimer.restart();
        }
    }

    Timer {
        id: hideTimer
        interval: 1000
        // onTriggered: root.audioPopupVisible = false
    }

    PanelWindow {
        id: panel

        exclusiveZone: 0
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true
        focusable: false
        mask: Region {}

        anchors {
            right: true
        }

        implicitHeight: 416 / 2
        implicitWidth: 48

        color: "#00000000"

        Rectangle {
            // add blur
            id: bg

            anchors.fill: parent
            color: "#0b0a0f"
            topLeftRadius: parent.width
            bottomLeftRadius: parent.width

            Column {
                id: c

                spacing: (parent.height - outputSlider.height - inputSlider.height) / 3

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: (parent.width - width) / 2
                }

                Slider {
                    id: outputSlider

                    from: 0
                    to: 100
                    value: Math.round((Pipewire.defaultAudioSink?.audio.volume ?? 0) * 100)

                    orientation: Qt.Vertical

                    width: 12
                    height: 150

                    background: Rectangle {
                        implicitWidth: parent.availableWidth
                        implicitHeight: parent.availableHeight
                        radius: width
                        color: "#bdbebf"

                        Rectangle {
                            width: parent.width
                            height: parent.visualPosition * parent.height
                            color: "#21be2b"
                            radius: 2
                        }
                    }

                    handle: Rectangle {
                        x: parent.availableWidth / 2 - width / 2
                        y: parent.visualPosition * (parent.availableHeight - height)
                        implicitWidth: parent.availableWidth
                        implicitHeight: parent.availableHeight / 4
                        radius: width
                        color: parent.pressed ? "#f0f0f0" : "#f6f6f6"

                        Behavior on y {
                            NumberAnimation {
                                duration: 150 // Adjust duration for desired smoothness (in milliseconds)
                                easing.type: Easing.OutCubic // Choose an easing curve for a natural feel
                            }
                        }
                    }
                }
            }
        }
    }
}
