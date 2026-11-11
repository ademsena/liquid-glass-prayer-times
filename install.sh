#!/usr/bin/env bash
# Liquid Glass Prayer Times — install / reinstall the plasmoid for the current user.
set -euo pipefail

ID="com.adems.macoswidgets.namaz"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.local/share/plasma/plasmoids/$ID"

if ! command -v kpackagetool6 >/dev/null 2>&1; then
    echo "Hata: kpackagetool6 bulunamadı (plasma-workspace kurulu değil mi?)." >&2
    exit 1
fi

# Remove the previous copy so the reinstall is a clean replace.
kpackagetool6 --type Plasma/Applet --remove "$ID" >/dev/null 2>&1 || true

kpackagetool6 --type Plasma/Applet --install "$SRC"

echo
echo "Kuruldu: $DEST"
echo "On the desktop: right-click → Add Widgets → \"Liquid Glass Prayer Times\"."
echo "Listede görünmezse: kquitapp6 plasmashell && kstart6 plasmashell"
