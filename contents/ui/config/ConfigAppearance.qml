import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "./ConfigStrings.js" as Cfg

// Everything visual lives here: colours, the glass look and the warning glow.
// One FormLayout (instead of nested layouts) keeps the page height correct, so
// the config dialog can scroll all the way down.
Kirigami.FormLayout {
    id: root

    // Page labels follow the widget language (see Ayarlar page; this page
    // reads the committed value, so it catches up after Apply/reopen).
    readonly property int lang: {
        var v = Plasmoid.configuration.language
        return Math.max(0, Math.min(2, (typeof v === "number" ? v : 0) | 0))
    }
    function _t(key) { return Cfg.t(lang, key) }

    property alias cfg_styleMode: styleCombo.currentIndex
    property alias cfg_appearance: appearanceCombo.currentIndex
    property alias cfg_cornerRadius: radiusSpin.value
    property alias cfg_roundnessX10: roundnessSpin.value
    property alias cfg_refractThickness: thicknessSpin.value
    property alias cfg_refractIORx100: iorSpin.value
    property alias cfg_refractScale: scaleSpin.value
    property alias cfg_tintAlphaPct: tintSpin.value
    property alias cfg_chromaStrengthPct: chromaSpin.value
    property alias cfg_specStrengthPct: specStrengthSpin.value
    property alias cfg_blurRadiusPx: blurRadiusSpin.value
    property alias cfg_realtimeRefraction: realtimeCheck.checked

    // Colours: main accent (countdown, label) and the next-prayer accent
    // (highlighted row + warning edge). Warning timing/opacity live here too.
    property string cfg_accentHex: "#04e4b5"
    property string cfg_nextAccentHex: "#FF3B30"
    property alias cfg_warnMinutes: warnMinutesSpin.value
    property int cfg_warnOpacityPct: 35

    readonly property var presets: ["#04e4b5", "#FF3B30", "#0A84FF", "#30D158", "#BF5AF2", "#FFFFFF"]

    function _isHex(h) {
        return typeof h === "string" && /^#[0-9a-fA-F]{6}$/.test(h)
    }

    function _setAccent(h) {
        if (!_isHex(h)) return false
        cfg_accentHex = h.toLowerCase()
        return true
    }

    function _setNextAccent(h) {
        if (!_isHex(h)) return false
        cfg_nextAccentHex = h.toLowerCase()
        return true
    }

    onCfg_accentHexChanged: {
        if (accentField.text !== cfg_accentHex)
            accentField.text = cfg_accentHex
    }

    onCfg_nextAccentHexChanged: {
        if (nextAccentField.text !== cfg_nextAccentHex)
            nextAccentField.text = cfg_nextAccentHex
    }

    // ── Renkler ──────────────────────────────────────────────────────────
    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: _t("colors")
    }

    RowLayout {
        Kirigami.FormData.label: _t("mainAccent")

        Rectangle {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 2
            Layout.preferredHeight: Kirigami.Units.gridUnit * 1.4
            radius: Kirigami.Units.smallSpacing
            color: root.cfg_accentHex
            border.width: 1
            border.color: Qt.alpha(Kirigami.Theme.textColor, 0.3)

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: accentDialog.open()
            }
        }

        TextField {
            id: accentField
            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
            text: root.cfg_accentHex
            placeholderText: "#04e4b5"
            selectByMouse: true
            onEditingFinished: {
                if (!root._setAccent(text))
                    text = root.cfg_accentHex
            }
        }

        Repeater {
            model: root.presets

            delegate: Rectangle {
                required property string modelData
                width: Kirigami.Units.gridUnit
                height: Kirigami.Units.gridUnit
                radius: width / 2
                color: modelData
                border.width: modelData.toLowerCase() === root.cfg_accentHex.toLowerCase() ? 2 : 1
                border.color: modelData.toLowerCase() === root.cfg_accentHex.toLowerCase()
                              ? Kirigami.Theme.highlightColor
                              : Qt.alpha(Kirigami.Theme.textColor, 0.3)
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root._setAccent(modelData)
                }
            }
        }
    }

    ColorDialog {
        id: accentDialog
        title: _t("dlgMain")
        selectedColor: root.cfg_accentHex
        onAccepted: root._setAccent(accentDialog.selectedColor.toString())
    }

    RowLayout {
        Kirigami.FormData.label: _t("upcoming")

        Rectangle {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 2
            Layout.preferredHeight: Kirigami.Units.gridUnit * 1.4
            radius: Kirigami.Units.smallSpacing
            color: root.cfg_nextAccentHex
            border.width: 1
            border.color: Qt.alpha(Kirigami.Theme.textColor, 0.3)

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: nextAccentDialog.open()
            }
        }

        TextField {
            id: nextAccentField
            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
            text: root.cfg_nextAccentHex
            placeholderText: "#FF3B30"
            selectByMouse: true
            onEditingFinished: {
                if (!root._setNextAccent(text))
                    text = root.cfg_nextAccentHex
            }
        }

        Repeater {
            model: root.presets

            delegate: Rectangle {
                required property string modelData
                width: Kirigami.Units.gridUnit
                height: Kirigami.Units.gridUnit
                radius: width / 2
                color: modelData
                border.width: modelData.toLowerCase() === root.cfg_nextAccentHex.toLowerCase() ? 2 : 1
                border.color: modelData.toLowerCase() === root.cfg_nextAccentHex.toLowerCase()
                              ? Kirigami.Theme.highlightColor
                              : Qt.alpha(Kirigami.Theme.textColor, 0.3)
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root._setNextAccent(modelData)
                }
            }
        }
    }

    ColorDialog {
        id: nextAccentDialog
        title: _t("dlgUpcoming")
        selectedColor: root.cfg_nextAccentHex
        onAccepted: root._setNextAccent(nextAccentDialog.selectedColor.toString())
    }

    SpinBox {
        id: warnMinutesSpin
        Kirigami.FormData.label: _t("warnMinutes")
        from: 0; to: 60; stepSize: 5
        textFromValue: function(value) { return value === 0 ? _t("off") : value }
    }

    RowLayout {
        Kirigami.FormData.label: _t("warnOpacity")
        Slider {
            id: warnOpacitySlider
            Layout.fillWidth: true
            from: 0; to: 100; stepSize: 5
            value: root.cfg_warnOpacityPct
            onMoved: root.cfg_warnOpacityPct = Math.round(value)
        }
        Label {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 2
            horizontalAlignment: Text.AlignRight
            text: "%" + root.cfg_warnOpacityPct
        }
    }

    Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        opacity: 0.65
        font.italic: true
        text: _t("warnHint")
    }

    // ── Stil ─────────────────────────────────────────────────────────────
    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: _t("styleSection")
    }

    RowLayout {
        Kirigami.FormData.label: _t("preset")

        Button {
            icon.name: "edit-copy"
            text: _t("copyStyle")
            onClicked: {
                _hiddenField.text = root._serialize()
                _hiddenField.selectAll()
                _hiddenField.copy()
                pasteStatus.text = _t("copied")
                pasteStatus.visible = true
                statusTimer.restart()
            }
        }

        Button {
            icon.name: "edit-paste"
            text: _t("pasteStyle")
            onClicked: {
                _hiddenField.text = ""
                _hiddenField.paste()
                root._deserialize(_hiddenField.text)
            }
        }
    }

    TextField {
        id: _hiddenField
        visible: false
    }

    Label {
        id: pasteStatus
        visible: false
        font.italic: true
        opacity: 0.7
    }

    ComboBox {
        id: styleCombo
        Kirigami.FormData.label: _t("styleLbl")
        model: [_t("glass"), _t("solid")]
    }

    ComboBox {
        id: appearanceCombo
        Kirigami.FormData.label: _t("appearance")
        model: [_t("dark"), _t("light"), _t("followSys")]
    }

    SpinBox {
        id: radiusSpin
        Kirigami.FormData.label: _t("cornerRadius")
        from: 0; to: 200; stepSize: 1
    }

    SpinBox {
        id: roundnessSpin
        Kirigami.FormData.label: _t("roundness")
        from: 20; to: 100; stepSize: 1
    }

    // ── Cam efekti ───────────────────────────────────────────────────────
    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: _t("glassEffect")
        visible: styleCombo.currentIndex === 0
    }

    SpinBox {
        id: thicknessSpin
        visible: styleCombo.currentIndex === 0
        Kirigami.FormData.label: _t("refrThickness")
        from: 1; to: 80; stepSize: 1
    }

    SpinBox {
        id: iorSpin
        visible: styleCombo.currentIndex === 0
        Kirigami.FormData.label: _t("refrIndex")
        from: 100; to: 400; stepSize: 5
    }

    SpinBox {
        id: scaleSpin
        visible: styleCombo.currentIndex === 0
        Kirigami.FormData.label: _t("refrStrength")
        from: 0; to: 300; stepSize: 5
    }

    SpinBox {
        id: tintSpin
        visible: styleCombo.currentIndex === 0
        Kirigami.FormData.label: _t("tintAlpha")
        from: 0; to: 100; stepSize: 1
    }

    SpinBox {
        id: chromaSpin
        visible: styleCombo.currentIndex === 0
        Kirigami.FormData.label: _t("chroma")
        from: 0; to: 100; stepSize: 1
    }

    SpinBox {
        id: specStrengthSpin
        visible: styleCombo.currentIndex === 0
        Kirigami.FormData.label: _t("specular")
        from: 0; to: 100; stepSize: 5
    }

    SpinBox {
        id: blurRadiusSpin
        visible: styleCombo.currentIndex === 0
        Kirigami.FormData.label: _t("blurRadius")
        from: 0; to: 100; stepSize: 1
    }

    CheckBox {
        id: realtimeCheck
        visible: styleCombo.currentIndex === 0
        Kirigami.FormData.label: _t("realtime")
        text: _t("realtimeHint")
    }

    // ── Style helpers ────────────────────────────────────────────────────
    Timer {
        id: statusTimer
        interval: 3000
        onTriggered: pasteStatus.visible = false
    }

    function _serialize() {
        return JSON.stringify({
            s: styleCombo.currentIndex,
            a: appearanceCombo.currentIndex,
            cr: radiusSpin.value,
            rn: roundnessSpin.value,
            rt: thicknessSpin.value,
            ri: iorSpin.value,
            rs: scaleSpin.value,
            ta: tintSpin.value,
            ca: chromaSpin.value,
            ss: specStrengthSpin.value,
            br: blurRadiusSpin.value,
            rr: realtimeCheck.checked
        })
    }

    function _deserialize(text) {
        try {
            var o = JSON.parse(text)
            if (o.s  !== undefined) styleCombo.currentIndex      = o.s
            if (o.a  !== undefined) appearanceCombo.currentIndex  = o.a
            if (o.cr !== undefined) radiusSpin.value              = o.cr
            if (o.rn !== undefined) roundnessSpin.value           = o.rn
            if (o.rt !== undefined) thicknessSpin.value           = o.rt
            if (o.ri !== undefined) iorSpin.value                 = o.ri
            if (o.rs !== undefined) scaleSpin.value               = o.rs
            if (o.ta !== undefined) tintSpin.value                = o.ta
            if (o.ca !== undefined) chromaSpin.value              = o.ca
            if (o.ss !== undefined) specStrengthSpin.value        = o.ss
            if (o.br !== undefined) blurRadiusSpin.value          = o.br
            if (o.rr !== undefined) realtimeCheck.checked         = o.rr
            pasteStatus.text = _t("applied")
        } catch(e) {
            pasteStatus.text = _t("invalid")
        }
        pasteStatus.visible = true
        statusTimer.restart()
    }
}
