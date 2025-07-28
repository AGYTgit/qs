import Quickshell
import QtQuick
import "./modules/audioPopup"

ShellRoot {
    id: root

    property bool audioPopupVisible: true
    Loader {
        id: audioLoader

        active: audioPopupVisible
        sourceComponent: AudioPopup {}
    }
}
