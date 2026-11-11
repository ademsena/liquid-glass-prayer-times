import QtQuick
import QtQuick.Layouts

// Prayer list. columns = 1 stacks the rows (portrait), columns = 2 splits
// them into "3 on the left, 3 on the right" (landscape) — column-major, so
// the reading order stays İmsak → Yatsı.
//
// The grid fills whatever height it is given: the rows share the height
// equally, so a tall card spreads its list over the whole free area instead
// of leaving one big empty band at the bottom. Rows never shrink below their
// text height (Layout.minimumHeight) — on very small cards the list clips at
// the bottom edge instead of the rows overlapping each other.
Item {
    id: grid

    clip: true

    property var model: []
    property int columns: 1
    // Arabic: mirrored flow — first column on the right, times on the left.
    property bool rtl: false

    LayoutMirroring.enabled: grid.rtl
    LayoutMirroring.childrenInherit: true

    property color textColor: "#ffffff"
    property color accentColor: "#04e4b5"
    property color nextAccentColor: "#FF3B30"
    property string fontFamily: ""
    property real nameSize: 12
    property real timeSize: 11
    property bool showLabels: true

    readonly property real spacing: Math.max(1, Math.round(nameSize * 0.12))
    readonly property int perColumn: Math.max(1, Math.ceil(model.length / columns))
    readonly property real rowHeight: Math.round(nameSize * 1.65)

    implicitHeight: model.length > 0
                    ? perColumn * rowHeight + (perColumn - 1) * spacing
                    : 0

    function _slice(col) {
        var out = []
        var start = col * perColumn
        var end = Math.min(model.length, start + perColumn)
        for (var i = start; i < end; i++)
            out.push(model[i])
        return out
    }

    ColumnLayout {
        id: leftColumn
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: grid.columns === 2 ? (parent.width - grid.spacing) / 2 : parent.width
        spacing: grid.spacing

        Repeater {
            model: grid.columns === 2 ? grid._slice(0) : grid.model

            delegate: PrayerRow {
                required property var modelData
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: grid.rowHeight
                Layout.minimumHeight: grid.rowHeight

                rtl: grid.rtl
                fontFamily: grid.fontFamily
                nameSize: grid.nameSize
                timeSize: grid.timeSize
                textColor: grid.textColor
                accentColor: grid.accentColor
                nextAccentColor: grid.nextAccentColor
                showLabel: grid.showLabels

                label: modelData.label
                timeText: modelData.time
                isNext: modelData.isNext
                isPast: modelData.isPast
            }
        }
    }

    ColumnLayout {
        id: rightColumn
        visible: grid.columns === 2
        anchors {
            left: leftColumn.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            leftMargin: grid.spacing
        }
        spacing: grid.spacing

        Repeater {
            model: rightColumn.visible ? grid._slice(1) : []

            delegate: PrayerRow {
                required property var modelData
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: grid.rowHeight
                Layout.minimumHeight: grid.rowHeight

                rtl: grid.rtl
                fontFamily: grid.fontFamily
                nameSize: grid.nameSize
                timeSize: grid.timeSize
                textColor: grid.textColor
                accentColor: grid.accentColor
                nextAccentColor: grid.nextAccentColor
                showLabel: grid.showLabels

                label: modelData.label
                timeText: modelData.time
                isNext: modelData.isNext
                isPast: modelData.isPast
            }
        }
    }
}
