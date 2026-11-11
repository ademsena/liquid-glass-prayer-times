import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import "components"
import "data"
import "widget"

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    MacOSColors {
        id: colors
        styleMode: plasmoid.configuration.styleMode
        appearance: plasmoid.configuration.appearance
    }

    // Prayer list typeface — the same Poppins used by the date/calendar
    // widget on the desktop, so the list matches the rest of the pack.
    FontLoader {
        id: listFont
        source: Qt.resolvedUrl("../fonts/Poppins.ttf")
    }

    // Same typeface as the macOS clock widget, so the countdown reads as part
    // of the same set.
    FontLoader {
        id: barlowMedium
        source: Qt.resolvedUrl("../fonts/barlow_medium.ttf")
    }

    // Month cache + countdown state.
    PrayerTimes {
        id: prayerData
        lightMode: colors.effectiveLight
    }

    // User-configurable accent; anything that is not #rrggbb falls back to
    // the default mint so a typo can never make text invisible. On a light
    // card the accent is darkened: mint (#04e4b5) and other bright hues are
    // unreadable on white glass, which is why the colour looked broken in
    // light mode.
    readonly property color accent: {
        var hex = _resolveAccent(plasmoid.configuration.accentHex)
        return colors.effectiveLight ? Qt.darker(hex, 1.75) : hex
    }

    function _resolveAccent(raw) {
        var hex = (raw || "").trim()
        if (!/^#[0-9a-fA-F]{6}$/.test(hex))
            hex = "#04e4b5"
        return hex
    }

    fullRepresentation: Item {
        id: full

        Layout.preferredWidth: 208
        Layout.preferredHeight: 416
        Layout.minimumWidth: 150
        Layout.minimumHeight: 110

        // Everything is sized off the short edge, so the widget looks the
        // same at any aspect ratio — only the arrangement changes.
        readonly property real u: Math.min(full.width, full.height)

        // The corner radius is configured for a 208 px reference short edge
        // and scaled from there, so portrait, wide and bar keep the same
        // squircle proportion. A fixed pixel radius looks over-rounded on the
        // slim bar and too square when the card is enlarged.
        readonly property real cornerRadius: {
            var base = plasmoid.configuration.cornerRadius
            var scaled = base * (full.u / 208)
            return Math.max(0, Math.min(scaled, full.u * 0.5))
        }

        readonly property real ar: full.width / Math.max(1, full.height)
        readonly property string layoutName: ar >= 3.0 ? "bar"
                                                 : (ar >= 1.55 ? "wide" : "stack")

        LiquidGlass {
            id: glass
            anchors.fill: parent
            radius: full.cornerRadius
            roundness: plasmoid.configuration.roundnessX10 / 10
            refractThickness: plasmoid.configuration.refractThickness
            refractIOR: plasmoid.configuration.refractIORx100 / 100
            refractScale: plasmoid.configuration.refractScale
            tint: colors.glassTint
            // A light card needs a much stronger white tint: at the dark-mode
            // value the wallpaper shows through and dark text becomes
            // unreadable on it.
            tintAlpha: colors.effectiveLight
                ? Math.max(0.78, plasmoid.configuration.tintAlphaPct / 100)
                : plasmoid.configuration.tintAlphaPct / 100
            chromaStrength: plasmoid.configuration.chromaStrengthPct / 100
            specStrength: plasmoid.configuration.specStrengthPct / 100
            blurRadius: plasmoid.configuration.blurRadiusPx
            realtimeRefraction: plasmoid.configuration.realtimeRefraction
            fallbackOpacity: colors.glassFallbackOpacity
            solidMode: colors.isSolid
            solidColor: colors.solidBackground
        }

        // Last minutes before the next prayer: a soft red halo along the
        // glass edge. Sits above the glass, below the content.
        WarnGlow {
            anchors.fill: parent
            radius: glass.radius
            roundness: glass.roundness
            visible: prayerData.nearNext
            maxOpacity: prayerData.warnOpacity
            glowColor: prayerData.nextAccent
        }

        // Below the content: click the widget to refetch the month.
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: prayerData.fetch()
        }

        StackLayout {
            anchors.fill: parent
            visible: full.layoutName !== "bar"
            enabled: visible

            u: full.u
            columns: full.layoutName === "wide" ? 2 : 1

            countdown: prayerData.countdownDisplay
            unit: prayerData.unit
            nextLabel: prayerData.nextLabel
            statusLine: prayerData.statusLine
            rows: prayerData.rows
            rtl: prayerData.rtl

            accent: root.accent
            nextAccent: prayerData.nextAccent
            textColor: colors.foreground
            fontFamily: listFont.name
            countdownFont: barlowMedium.name
        }

        // Repositioning the applet changes root.x/root.y; update the glass
        // backdrop immediately instead of waiting for the fallback poll.
        Connections {
            target: root
            function onXChanged() { glass.updateGeometry() }
            function onYChanged() { glass.updateGeometry() }
        }

        BarLayout {
            anchors.fill: parent
            visible: full.layoutName === "bar"
            enabled: visible

            u: full.u

            countdown: prayerData.countdownDisplay
            unit: prayerData.unit
            nextLabel: prayerData.nextLabel
            statusLine: prayerData.statusLine
            rows: prayerData.rows
            rtl: prayerData.rtl

            accent: root.accent
            nextAccent: prayerData.nextAccent
            textColor: colors.foreground
            fontFamily: listFont.name
            countdownFont: barlowMedium.name
        }
    }
}
