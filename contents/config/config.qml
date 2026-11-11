import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.configuration

ConfigModel {
    id: configModel

    ConfigCategory {
        name: i18n("Görünüm")
        icon: "preferences-desktop-theme"
        source: "config/ConfigAppearance.qml"
    }

    ConfigCategory {
        name: i18n("Ayarlar")
        icon: "configure"
        source: "config/ConfigPrayer.qml"
    }

    ConfigCategory {
        name: i18n("Veri")
        icon: "view-refresh"
        source: "config/ConfigData.qml"
    }
}
