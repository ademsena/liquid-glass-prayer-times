import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "./ConfigStrings.js" as Cfg
import "../data/Locations.js" as Places

// Prayer settings: location, the calculation method, what is shown and in
// which language. Colours, the glass look and the warning settings live in
// the Görünüm tab (ConfigAppearance.qml).
Kirigami.FormLayout {
    id: root

    // The stored config value is the combo's index; PrayerTimes maps it to
    // the Aladhan method id (see methodIds there — keep both lists in sync).
    property alias cfg_methodIndex: methodCombo.currentIndex

    // Location: combos list known places but stay editable, so any other
    // country/city can be typed in.
    property string cfg_country: "Turkey"
    property string cfg_city: "Ankara"

    property alias cfg_use24h: time24Check.checked

    // 0 = Türkçe, 1 = English, 2 = العربية (PrayerTimes.strings + Cfg table)
    property alias cfg_language: langCombo.currentIndex

    // StringList — Plasma config passes this as a JS array (comma string on
    // some KDE versions), so normalise both shapes before reading.
    property var cfg_enabledPrayers: []

    // Guard while the city model is being swapped: the model reset clears
    // editText, which must not wipe the configured city.
    property bool _modelSync: false

    // Page labels follow the widget language (lives with the combo — the
    // other pages read the committed value and catch up after Apply).
    readonly property int lang: Math.max(0, Math.min(2, cfg_language | 0))
    function _t(key) { return Cfg.t(lang, key) }

    readonly property var keys: ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]
    readonly property var labelsByLang: [
        ["İmsak", "Güneş", "Öğle", "İkindi", "Akşam", "Yatsı"],
        ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"],
        ["الفجر", "الشروق", "الظهر", "العصر", "المغرب", "العشاء"]
    ]
    readonly property var labels: labelsByLang[lang]

    function _list() {
        var list = cfg_enabledPrayers
        if (typeof list === "string")
            list = list.split(",").map(function(s) { return s.trim() })
        return list
    }

    // Keep the canonical order so the cached column order never changes.
    function _ordered(parts, on, key) {
        var merged = parts.filter(function (k) { return k !== key })
        if (on)
            merged.push(key)
        var out = []
        for (var i = 0; i < keys.length; i++)
            if (merged.indexOf(keys[i]) !== -1) out.push(keys[i])
        return out
    }

    function _toggleKey(key, on) {
        cfg_enabledPrayers = _ordered(_list(), on, key)
    }

    // The stored city may not be in the list (typed by the user) — present
    // it through the edit field instead of the index in that case.
    function _syncCountry() {
        var idx = Places.countryNames.indexOf(cfg_country)
        if (idx >= 0) {
            if (countryCombo.currentIndex !== idx)
                countryCombo.currentIndex = idx
        } else if (countryCombo.editText !== cfg_country) {
            countryCombo.editText = cfg_country
        }
        // Assigning the model (also takes over the declarative binding) then
        // pointing the combo at the configured city — by index when the city
        // is listed, otherwise via the edit field. While _modelSync is set
        // the combo's text churn cannot wipe the configured value.
        _modelSync = true
        cityCombo.model = Places.citiesFor(cfg_country)
        var cidx = cityCombo.find(cfg_city, Qt.MatchExactly)
        if (cidx >= 0) {
            if (cityCombo.currentIndex !== cidx)
                cityCombo.currentIndex = cidx
        } else if (cityCombo.editText !== cfg_city) {
            cityCombo.editText = cfg_city
        }
        _modelSync = false
    }

    // Sync runs on the NEXT event-loop pass (Qt.callLater): Plasma sets the
    // cfg_* values right around component creation, and a direct sync fired
    // from a creation-time change handler raced the combo's own model reset —
    // the combo slipped back to its first row ("Adana" instead of the stored
    // "Ankara" on every reopen). Deferring makes every path converge on one
    // idempotent pass that sees the final stored values.
    Component.onCompleted: Qt.callLater(_syncCountry)

    onCfg_countryChanged: Qt.callLater(_syncCountry)

    onCfg_cityChanged: {
        if (!_modelSync && cityCombo !== undefined && cityCombo !== null
                && cityCombo.editText !== cfg_city)
            cityCombo.editText = cfg_city
    }

    // ── Hesaplama ────────────────────────────────────────────────────────
    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: root._t("secCalc")
    }

    ComboBox {
        id: countryCombo
        Kirigami.FormData.label: root._t("country")
        editable: true
        model: Places.countryNames
        onActivated: root.cfg_country = countryCombo.currentText
        onAccepted: root.cfg_country = countryCombo.editText
    }

    ComboBox {
        id: cityCombo
        Kirigami.FormData.label: root._t("city")
        editable: true
        model: Places.citiesFor(root.cfg_country)
        onEditTextChanged: {
            if (!root._modelSync)
                root.cfg_city = cityCombo.editText
        }
        onActivated: root.cfg_city = cityCombo.currentText
    }

    Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        opacity: 0.65
        font.italic: true
        text: root._t("geoHint")
    }

    ComboBox {
        id: methodCombo
        Kirigami.FormData.label: root._t("method")
        model: [
            root._t("meth0"),
            root._t("meth1"),
            root._t("meth2"),
            root._t("meth3"),
            root._t("meth4"),
            root._t("meth5"),
            root._t("meth6")
        ]
    }

    // ── Gösterim ─────────────────────────────────────────────────────────
    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: root._t("showSection")
    }

    ComboBox {
        id: langCombo
        Kirigami.FormData.label: root._t("langLabel")
        model: ["Türkçe", "English", "العربية"]
    }

    CheckBox {
        id: time24Check
        Kirigami.FormData.label: root._t("clockFormat")
        text: root._t("h24")
    }

    // The size warning label without a spacer: the FormLayout already
    // separates rows, and an extra Item breaks the packed page height.
    ColumnLayout {
        Kirigami.FormData.label: root._t("showWhich")
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        spacing: 2

        Repeater {
            model: root.keys

            delegate: CheckBox {
                required property int index
                required property string modelData

                text: root.labels[index]
                checked: root._list().indexOf(modelData) !== -1
                onToggled: root._toggleKey(modelData, checked)
            }
        }
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
    }

    Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        opacity: 0.65
        font.italic: true
        text: root._t("noteRefresh")
    }

    Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        opacity: 0.65
        font.italic: true
        text: root._t("noteWarning")
    }
}
