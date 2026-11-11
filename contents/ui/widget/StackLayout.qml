import QtQuick
import QtQuick.Layouts

// Portrait / square / landscape layout: the countdown hero pinned to the top
// edge, the prayer list filling the space underneath (one column, or 3 + 3
// when the widget is wide).
//
// Every size is derived from the short edge (u) AND from the height budget:
// the hero shrinks before the list does, and the list rows shrink (down to a
// readable floor) before anything is allowed to overlap. That keeps a 416x208
// landscape card as clean as a 208x416 portrait one.
Item {
    id: root

    property real u: 200
    property int columns: 1
    // Arabic (rtl): hero and grid mirror to the right; countdown digits keep
    // their internal LTR order (standard for numerals in Arabic text).
    property bool rtl: false

    LayoutMirroring.enabled: root.rtl
    LayoutMirroring.childrenInherit: true

    property string countdown: "--:--"
    property string unit: "dk"
    property string nextLabel: ""
    property string statusLine: ""
    property var rows: []

    property color accent: "#04e4b5"
    property color nextAccent: "#FF3B30"
    property color textColor: "#ffffff"
    property string fontFamily: ""
    property string countdownFont: ""

    readonly property real margin: Math.max(10, Math.round(u * 0.075))
    readonly property real gap: Math.max(6, Math.round(u * 0.035))

    // --- vertical budget -------------------------------------------------
    // Line boxes are ~1.28x the pixel size; using the real factor (instead of
    // the old 1.06 guess) stops the countdown digits from bleeding into the
    // first list row.
    readonly property real lineFactor: 1.28
    readonly property real rowFactor: 1.65

    readonly property int perColumn: Math.max(1, Math.ceil(rows.length / Math.max(1, columns)))

    readonly property real _labelSize: Math.max(17, Math.min(Math.round(u * 0.095), 21))
    readonly property real _nameW: Math.max(11, Math.min(Math.round(u * 0.085), 18))
    readonly property real _timeW: Math.max(10, Math.min(Math.round(u * 0.078), 17))
    readonly property real _spacingEst: Math.max(1, Math.round(_nameW * 0.12))

    // Smallest hero worth drawing: label + an 18px countdown.
    readonly property real _minHeroH: _labelSize * lineFactor + 1 + 16 * lineFactor
    readonly property real _availForList: Math.max(0, height - 2 * margin - gap - _minHeroH)
    readonly property real _fitName: (_availForList - (perColumn - 1) * _spacingEst)
                                     / (perColumn * rowFactor)

    // The "Kalan Süre" label stays readable at every widget size.
    readonly property real labelSize: _labelSize

    readonly property real nameSize: Math.max(8, Math.min(_nameW, _fitName))
    readonly property real timeSize: Math.max(8, Math.min(_timeW, nameSize))

    readonly property real spacing: Math.max(1, Math.round(nameSize * 0.12))
    readonly property real rowHeight: Math.round(nameSize * rowFactor)
    readonly property real gridH: perColumn * rowHeight + (perColumn - 1) * spacing

    // Leftover height for the hero once the list has its minimum rows.
    readonly property real _heroRoom: height - 2 * margin - gap - gridH
                                      - labelSize * lineFactor - 1

    // Wide layouts have horizontal room to spare; tall ones get a bigger
    // countdown because dropping the seconds left fewer digits to fit.
    readonly property real digitScale: columns === 2 ? 0.26 : 0.28
    readonly property real digitCap: Math.max(14, Math.min(Math.round(u * 0.30),
                                                           height * 0.34,
                                                           _heroRoom / lineFactor))

    readonly property real statusHeight: Math.round(Math.max(7, u * 0.032) * 1.6)
    readonly property bool hasStatus: root.statusLine !== "" && root.rows.length > 0

    Countdown {
        id: hero
        visible: root.rows.length > 0
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: root.margin
            rightMargin: root.margin
            topMargin: root.margin
        }
        u: root.u
        digitCap: root.digitCap
        digitScale: root.digitScale
        label: root.nextLabel
        countdown: root.countdown
        unit: root.unit
        accent: root.accent
        textColor: root.textColor
        fontFamily: root.fontFamily
        countdownFont: root.countdownFont
        labelSize: root.labelSize
        rtl: root.rtl
    }

    PrayerGrid {
        id: grid
        visible: root.rows.length > 0
        anchors {
            left: parent.left
            right: parent.right
            top: hero.bottom
            bottom: parent.bottom
            leftMargin: root.margin
            rightMargin: root.margin
            topMargin: root.gap
            bottomMargin: root.margin + (root.hasStatus ? root.statusHeight : 0)
        }
        model: root.rows
        columns: root.columns
        rtl: root.rtl
        textColor: root.textColor
        accentColor: root.accent
        nextAccentColor: root.nextAccent
        fontFamily: root.fontFamily
        nameSize: root.nameSize
        timeSize: root.timeSize
    }

    // Non-blocking hints (cache in use, waiting for next month's data).
    Text {
        visible: root.hasStatus
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: root.margin
            bottomMargin: Math.max(2, Math.round(root.margin * 0.45))
        }
        text: root.statusLine
        color: root.textColor
        opacity: 0.55
        font.family: root.fontFamily
        font.pixelSize: Math.max(7, Math.round(root.u * 0.032))
    }

    // Nothing loaded / offline with no cache — keep the card readable.
    Text {
        anchors.centerIn: parent
        visible: root.statusLine !== "" && root.rows.length === 0
        text: root.statusLine
        color: root.textColor
        opacity: 0.7
        font.family: root.fontFamily
        font.pixelSize: Math.max(10, Math.round(root.u * 0.05))
        horizontalAlignment: Text.AlignHCenter
    }
}
