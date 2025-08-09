import Quickshell
import QtQuick
import qs.modules.audioPopup
import qs.modules.hyprbar

ShellRoot {
    id: root

    Loader {
        active: true
        sourceComponent: Hyprbar {}
    }
    Loader {
        active: true
        sourceComponent: AudioPopup {}
    }
}
