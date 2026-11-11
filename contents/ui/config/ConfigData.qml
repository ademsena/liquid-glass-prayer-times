import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "./ConfigStrings.js" as Cfg

Kirigami.FormLayout {
    id: root

    // Page labels follow the widget language (committed value).
    readonly property int lang: {
        var v = Plasmoid.configuration.language
        return Math.max(0, Math.min(2, (typeof v === "number" ? v : 0) | 0))
    }
    function _t(key) { return Cfg.t(lang, key) }

    // plasmoid.configuration is a dynamic object; a plain binding to it is
    // not guaranteed to re-evaluate, so the status list is nudged once a
    // second to stay current while the dialog is open.
    property int _tick: 0

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root._tick++
    }

    readonly property var lines: [
        _t("lastFetch"), _t("cityLbl"), _t("methodLbl"),
        _t("storedDays"), _t("stateLbl"), _t("lastError")
    ]
    readonly property var values: {
        _tick // explicit dependency, see _tick above
        return [
            Plasmoid.configuration.lastFetch || _t("dash"),
            (Plasmoid.configuration.city || "Ankara") + " / " + (Plasmoid.configuration.country || "Turkey"),
            methodLabel(Plasmoid.configuration.methodIndex),
            Plasmoid.configuration.cacheJson ? dayCountLabel(Plasmoid.configuration.cacheJson) : _t("dash"),
            Plasmoid.configuration.lastError ? _t("cachedShow") : _t("ready"),
            Plasmoid.configuration.lastError || _t("dash")
        ]
    }

    function methodLabel(idx) {
        var names = ["meth0", "meth1", "meth2", "meth3", "meth4", "meth5", "meth6"]
        var key = (idx === undefined || idx === null) ? "meth0" : (names[idx] || String(idx))
        return key.charAt(0) === "m" ? Cfg.t(lang, key) : key
    }

    function dayCountLabel(json) {
        try {
            var o = JSON.parse(json)
            return (o.days ? o.days.length : 0) + _t("daySuffix")
        } catch (e) {
            return _t("dash")
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        Repeater {
            model: root.lines

            delegate: RowLayout {
                required property int index
                required property string modelData
                Layout.fillWidth: true

                Label {
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 7
                    text: modelData
                    opacity: 0.7
                }

                Label {
                    Layout.fillWidth: true
                    text: root.values[index]
                    elide: Text.ElideRight
                }
            }
        }
    }

    Button {
        id: refreshButton
        Kirigami.FormData.label: _t("dataLbl")
        text: _t("refreshNow")
        icon.name: "view-refresh"
        onClicked: {
            Plasmoid.configuration.refreshCounter = Plasmoid.configuration.refreshCounter + 1
            doneLabel.text = _t("refreshStarted")
            doneTimer.restart()
        }
    }

    Label {
        id: doneLabel
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        font.italic: true
        opacity: 0.7
        text: ""
    }

    Timer {
        id: doneTimer
        interval: 4000
        onTriggered: doneLabel.text = ""
    }

    Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        font.italic: true
        opacity: 0.65
        text: root._t("dataHint")
    }
}
