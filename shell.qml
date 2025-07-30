import Quickshell
import QtQuick
import "./modules/audioPopup"
import "./modules/hyprbar"

ShellRoot {
    id: root

    Loader {
        active: false
        sourceComponent: Hyprbar {}
    }
    Loader {
        active: true
        sourceComponent: AudioPopup {}
    }
}
