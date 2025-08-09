import QtQuick
import QtQuick.Controls
import qs.types

StyledLabel { id: root
    required property string format
    required property int interval
    property bool use12HourCycle: false

    Timer {
        interval: root.interval
        running: true
        repeat: true
        onTriggered: updateTime()
    }

    Component.onCompleted: {
        updateTime()
    }

    function updateTime() {
        var now = new Date();
        var timeString = Qt.formatDateTime(now, root.format);

        if (use12HourCycle) {
            var hour24 = now.getHours();
            var minute = now.getMinutes();
            var second = now.getSeconds();

            // Convert to 12-hour cycle (1-12)
            var hour12 = hour24 % 12;
            if (hour12 === 0) {
                hour12 = 12;
            }

            // Determine if the format needs a leading zero for the hour
            var formattedHour12;
            if (root.format.includes("hh")) {
                formattedHour12 = hour12 < 10 ? "0" + hour12 : hour12.toString();
            } else {
                formattedHour12 = hour12.toString();
            }

            // Find the 24-hour string in the formatted output
            var hour24String = hour24 < 10 ? "0" + hour24 : hour24.toString();

            // Replace the 24-hour string with our 12-hour string
            root.text = timeString.replace(hour24String, formattedHour12);
        } else {
            root.text = timeString;
        }
    }
}
