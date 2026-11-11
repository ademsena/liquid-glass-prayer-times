import QtQuick
import QtQuick.Layouts

// Ultra-wide layout (aspect >= 3, e.g. 448x80): compact countdown on the
// left, all prayers in a single row on the right.
Item {
    id: bar

    property real u: 80
    property string countdown: "--:--"
    property string unit: "dk"
    property string nextLabel: ""
    property string statusLine: ""
    property var rows: []
    // Arabic (rtl): countdown block on the right, prayer row starts from
    // the right, times stay on the left inside each cell (PrayerRow.rtl).
    property bool rtl: false

    LayoutMirroring.enabled: rtl
    LayoutMirroring.childrenInherit: true

    property color accent: "#04e4b5"
    property color nextAccent: "#FF3B30"
    property color textColor: "#ffffff"
    property string fontFamily: ""
    property string countdownFont: ""

    readonly property real margin: Math.round(Math.max(u, 40) * 0.07)
    readonly property real nameSize: Math.max(10, Math.min(Math.round(u * 0.19), 17))
    readonly property real timeSize: Math.max(10, Math.min(Math.round(u * 0.17), 15))
    readonly property real digitSize: Math.max(18, Math.round(Math.min(u * 0.4, bar.height * 0.5)))
    readonly property real labelSize: Math.max(10, Math.round(bar.digitSize * 0.30))

    // The bar has no room for the full sentence; show just the prayer name.
    readonly property string shortLabel: bar.nextLabel.replace(/\s*(Vaktine:|in:|:)\s*$/, "")

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: bar.margin
        anchors.rightMargin: bar.margin
        spacing: Math.max(8, Math.round(bar.margin * 1.8))

        ColumnLayout {
            spacing: 1
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: bar.shortLabel.length > 0 ? bar.shortLabel : bar.statusLine
                color: bar.accent
                font.family: bar.countdownFont
                font.pixelSize: bar.labelSize
                font.weight: Font.Medium
                font.letterSpacing: -bar.labelSize * 0.01
                elide: Text.ElideRight
                Layout.maximumWidth: Math.min(implicitWidth, bar.width * 0.30)
            }

            RowLayout {
                spacing: 0
                // Digit order must stay hours→minutes: opt out of the
                // inherited Arabic mirroring (the countdown column itself
                // already moved to the right edge via the outer mirror).
                LayoutMirroring.enabled: false

                Text {
                    Layout.alignment: Qt.AlignBaseline
                    text: bar.countdown
                    color: bar.textColor
                    font.family: bar.countdownFont
                    font.pixelSize: bar.digitSize
                    font.weight: Font.Medium
                    font.letterSpacing: -bar.digitSize * 0.03
                    font.features: ["tnum"]
                }

                Text {
                    Layout.alignment: Qt.AlignBaseline
                    Layout.leftMargin: Math.round(bar.digitSize * 0.14)
                    visible: bar.unit.length > 0 && bar.countdown.length >= 5
                    text: bar.unit
                    color: bar.accent
                    opacity: 0.7
                    font.family: bar.countdownFont
                    font.pixelSize: Math.max(9, Math.round(bar.digitSize * 0.34))
                    font.weight: Font.Medium
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            // Cells are dot+time only, so the gap between cells must be wider
            // than the dot→time gap inside a cell; otherwise the dot of the
            // next prayer reads as a trailing bullet of the previous time
            // ("05.43• 07.05"). Keep it proportional to the time text.
            spacing: Math.max(10, Math.round(bar.timeSize * 1.1))

            Repeater {
                model: bar.rows

                delegate: PrayerRow {
                    id: barRow
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    // No room for names in an ultra-wide bar — dot + time
                    // reads cleanly on its own.
                    showLabel: false

                    label: modelData.label
                    timeText: modelData.time
                    isNext: modelData.isNext
                    isPast: modelData.isPast

                    // The engine resolves outer-id references from inside
                    // Binding elements reliably even when plain delegate
                    // property assignments evaluate in a broken scope.
                    Binding { target: barRow; property: "rtl"; value: bar.rtl }
                    Binding { target: barRow; property: "fontFamily"; value: bar.fontFamily }
                    Binding { target: barRow; property: "nameSize"; value: bar.nameSize }
                    Binding { target: barRow; property: "timeSize"; value: bar.timeSize }
                    Binding { target: barRow; property: "textColor"; value: bar.textColor }
                    Binding { target: barRow; property: "accentColor"; value: bar.accent }
                    Binding { target: barRow; property: "nextAccentColor"; value: bar.nextAccent }
                }
            }
        }
    }
}
