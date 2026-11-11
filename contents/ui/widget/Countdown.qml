import QtQuick
import QtQuick.Layouts

// Hero block: "<Prayer> Vaktine:" label with the live countdown directly
// beneath it. Both use Barlow Medium — the same typeface and tight letter
// spacing as the macOS clock widget — so the two widgets read as a set.
Item {
    id: root

    // Reference dimension (min(width, height) of the widget) — every size
    // is derived from it so the block scales with the plasmoid size.
    property real u: 200
    property real digitCap: 999
    property real digitScale: 0.25

    property string label: ""
    property string countdown: "--:--"
    property string unit: "dk"            // "dk" / "min" / "د" ("" hides it)
    property bool rtl: false

    property color accent: "#04e4b5"
    property color textColor: "#ffffff"
    property string fontFamily: ""        // list font
    property string countdownFont: ""     // clock-style font (Barlow)

    property real labelSize: Math.max(17, Math.min(Math.round(u * 0.095), 21))
    readonly property real digitSize: Math.max(16, Math.min(Math.round(u * digitScale), digitCap))
    readonly property real gap: Math.max(1, Math.round(u * 0.01))

    // Measured from the fixed line boxes instead of the live text metrics:
    // Arabic falls back to a system font whose line box is taller, and the
    // hero height (and the gap under the countdown) changed with the
    // language switch. Both boxes are now locked to the Barlow metrics.
    implicitHeight: labelText.height + gap + digitsRow.implicitHeight

    Text {
        id: labelText
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        // Lock the label's line box to the Barlow metrics. Arabic falls back
        // to a system font whose line box is far taller; without the fixed
        // height the hero (and the empty space under the label) inflates
        // every time the language switches to Arabic and back.
        height: Math.round(root.labelSize * 1.30)
        verticalAlignment: Text.AlignVCenter
        text: root.label
        color: root.accent
        horizontalAlignment: root.rtl ? Text.AlignRight : Text.AlignLeft
        font.family: root.countdownFont
        font.pixelSize: root.labelSize
        font.weight: Font.Medium
        font.letterSpacing: -root.labelSize * 0.01
        elide: Text.ElideRight
    }

    RowLayout {
        id: digitsRow
        // Opt out of the inherited Arabic mirroring: the digit sequence
        // (hours → colon → minutes → unit) must keep its LTR order — only
        // the whole row's placement flips (hugging the right edge in rtl
        // instead of the left). IMPORTANT: the anchor itself must NEVER
        // flip. Qt 6.12 does not clear an anchor when its binding resolves
        // to undefined, so `left: rtl ? undefined : parent.left` leaves the
        // right anchor from the Arabic phase permanently attached and the
        // stretched row redistributes its children — the hour/minute gap
        // visible after switching Arabic → Turkish. A constant left anchor
        // plus a dynamic leftMargin moves the row without touching the
        // anchor graph.
        LayoutMirroring.enabled: false
        anchors {
            top: labelText.bottom
            topMargin: root.gap
            left: parent.left
            leftMargin: root.rtl ? root.width - width : 0
        }
        spacing: 0

        Text {
            id: hT
            Layout.alignment: Qt.AlignBaseline
            // Fixed line box (Barlow metrics): Arabic-Indic digits come from
            // a fallback font and would otherwise inflate the hero height.
            Layout.preferredHeight: Math.round(root.digitSize * 1.30)
            verticalAlignment: Text.AlignVCenter
            text: root.countdown.length >= 5 ? root.countdown.substring(0, 2) : root.countdown
            color: root.textColor
            font.family: root.countdownFont
            font.pixelSize: root.digitSize
            font.weight: Font.Medium
            font.letterSpacing: -root.digitSize * 0.03
            font.features: ["tnum"]
        }

        Text {
            id: sT
            Layout.alignment: Qt.AlignBaseline
            // Hours white, minutes in the accent colour: with the
            // seconds gone this keeps the two-tone look of the hero.
            // Separator comes straight from the countdown string ("." for
            // Turkish, ":" elsewhere).
            Layout.preferredHeight: Math.round(root.digitSize * 1.30)
            verticalAlignment: Text.AlignVCenter
            text: root.countdown.length >= 5 ? root.countdown.substring(2, 3) : ""
            color: root.textColor
            opacity: 0.5
            font.family: root.countdownFont
            font.pixelSize: root.digitSize
            font.weight: Font.Medium
            font.letterSpacing: -root.digitSize * 0.03
            font.features: ["tnum"]
        }

        Text {
            id: mT
            Layout.alignment: Qt.AlignBaseline
            Layout.preferredHeight: Math.round(root.digitSize * 1.30)
            verticalAlignment: Text.AlignVCenter
            text: root.countdown.length >= 5 ? root.countdown.substring(3) : ""
            color: root.accent
            font.family: root.countdownFont
            font.pixelSize: root.digitSize
            font.weight: Font.Medium
            font.letterSpacing: -root.digitSize * 0.03
            font.features: ["tnum"]
        }

        Text {
            id: uT
            Layout.alignment: Qt.AlignBaseline
            Layout.leftMargin: Math.round(root.digitSize * 0.14)
            visible: root.unit.length > 0 && root.countdown.length >= 5
            text: root.unit
            color: root.accent
            opacity: 0.7
            font.family: root.countdownFont
            font.pixelSize: Math.max(9, Math.round(root.digitSize * 0.34))
            font.weight: Font.Medium
        }
    }
}

