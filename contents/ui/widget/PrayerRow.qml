import QtQuick

// One prayer in the list: white dot + name, with the time right next to it.
// In Arabic (rtl) the whole content flips: dot hugs the right edge, the name
// sits right-most and the time lands on the left — as the language reads.
//
// The ring used to pulse forever, which kept the whole widget repainting at
// 60 fps around the clock. It is static now: same visual marker, no idle GPU
// work (the glass shaders can stay cached until something actually changes).
//
// Positions are computed in _relayout() instead of anchors: anchors do not
// mirror explicitly computed x values, and this keeps every placement derived
// from measured text widths in both directions.
Item {
    id: row

    property string label: ""
    property string timeText: ""
    property bool showLabel: true
    property bool rtl: false
    property color dotColor: "#ffffff"
    property color accentColor: "#04e4b5"
    property color nextAccentColor: "#FF3B30"
    property color textColor: "#ffffff"
    property bool isNext: false
    property bool isPast: false

    property string fontFamily: ""
    property real nameSize: 12
    property real timeSize: 11

    readonly property real dimOpacity: 0.55
    readonly property real rowOpacity: isPast ? dimOpacity : (isNext ? 1.0 : 0.85)
    readonly property real gap: Math.round(nameSize * 0.55)
    readonly property real nameTimeGap: Math.round(nameSize * 0.5)

    implicitHeight: Math.round(nameSize * 1.65)

    // Static ring — only on the prayer being counted down to.
    Rectangle {
        id: halo
        anchors.centerIn: dot
        width: dot.width * 2.6
        height: width
        radius: width / 2
        color: "transparent"
        border.width: 1
        border.color: row.nextAccentColor
        opacity: 0.45
        visible: row.isNext
    }

    Rectangle {
        id: dot
        // Vertically centered on the row's own line: in the bar the delegate
        // is stretched to the full height, and an explicit y would leave the
        // dot floating mid-air while the texts ran along the top edge.
        anchors.verticalCenter: row.verticalCenter
        width: Math.round(row.nameSize * 0.26)
        height: width
        radius: width / 2
        color: row.textColor
        opacity: row.isPast ? 0.6 : 1.0
    }

    Text {
        id: nameText
        anchors.verticalCenter: row.verticalCenter
        visible: row.showLabel
        text: row.label
        color: row.isNext ? row.nextAccentColor : row.textColor
        opacity: row.rowOpacity
        font.family: row.fontFamily
        font.pixelSize: row.nameSize
        font.weight: row.isNext ? Font.DemiBold : Font.Normal
        elide: Text.ElideRight
        onImplicitWidthChanged: row._relayout()
        onVisibleChanged: row._relayout()
    }

    Text {
        id: timeText
        anchors.verticalCenter: row.verticalCenter
        text: row.timeText
        color: row.textColor
        opacity: row.isPast ? row.dimOpacity * 0.95 : (row.isNext ? 0.95 : 0.72)
        font.family: row.fontFamily
        font.pixelSize: row.timeSize
        font.features: ["tnum"]
        onImplicitWidthChanged: row._relayout()
    }

    function _relayout() {
        var w = row.width
        var dw = dot.width
        var tw = timeText.implicitWidth
        if (!row.showLabel) {
            // Dot + time only (ultra-wide bar): the two read as one pair, and
            // the *gap between cells* (BarLayout spacing) separates prayers.
            // With rtl the pair flips as the language reads.
            if (row.rtl) {
                dot.x = w - dw
                timeText.x = dot.x - row.gap - tw
            } else {
                dot.x = 0
                timeText.x = dot.x + dw + row.gap
            }
            return
        }
        var avail = w - dw - row.gap - tw - row.nameTimeGap - row.gap
        var nw = Math.max(0, Math.min(nameText.implicitWidth, avail))
        nameText.width = nw
        if (row.rtl) {
            // dot → name → time, laid out from the right edge; time on left.
            dot.x = w - dw
            nameText.x = dot.x - row.gap - nw
            timeText.x = nameText.x - row.nameTimeGap - tw
        } else {
            dot.x = 0
            nameText.x = dot.x + dw + row.gap
            timeText.x = nameText.x + nw + row.nameTimeGap
        }
    }

    onWidthChanged: _relayout()
    onRtlChanged: _relayout()
    onShowLabelChanged: _relayout()
    Component.onCompleted: _relayout()
}
