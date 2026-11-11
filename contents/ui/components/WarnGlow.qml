import QtQuick

// Soft red halo hugging the glass edge. Shown when the next prayer is within
// the configured warning window; the strength pulses very gently so it reads
// as "attention" without flashing.
//
// Works over both the glass shader and the flat fallback/solid background
// because it is a separate overlay that only draws the edge band.
Item {
    id: root

    property real radius: 100
    property real roundness: 7.5

    // Peak alpha of the halo at the very edge.
    property real maxOpacity: 0.35
    property color glowColor: "#FF453A"

    // 0..1, animated below.
    property real strength: 1.0

    readonly property real bandWidth: Math.max(10, Math.round(Math.min(width, height) * 0.14))

    ShaderEffect {
        anchors.fill: parent
        fragmentShader: Qt.resolvedUrl("shaders/warn_glow.frag.qsb")

        property size size: Qt.size(Math.max(1, root.width), Math.max(1, root.height))
        property real radius: root.radius
        property real roundness: root.roundness
        property real bandWidth: Math.min(root.bandWidth, Math.min(root.width, root.height) * 0.3)
        property vector4d glowColor: Qt.vector4d(root.glowColor.r,
                                                 root.glowColor.g,
                                                 root.glowColor.b,
                                                 root.maxOpacity)
        property real strength: root.strength
    }

    SequentialAnimation on strength {
        running: root.visible && root.maxOpacity > 0
        loops: Animation.Infinite
        NumberAnimation {
            from: 0.72; to: 1.0
            duration: 2200
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            from: 1.0; to: 0.72
            duration: 2200
            easing.type: Easing.InOutSine
        }
    }
}
