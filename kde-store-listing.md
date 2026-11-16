# KDE Store listing — Liquid Glass Prayer Times 1.4

Copy the fields below into https://store.kde.org while adding a new product.

---

## Name

```
Liquid Glass Prayer Times
```

## Summary (short description)

```
Liquid-glass prayer times widget for KDE Plasma 6 with a live countdown to the next prayer.
```

## Category

```
Plasma 6 Add-Ons  ->  Widgets (Plasma 6)
```

## Version

```
1.4
```

## License

```
GPL-3.0
```

## Homepage

```
https://github.com/ademsena/liquid-glass-prayer-times
```

## Source code

```
https://github.com/ademsena/liquid-glass-prayer-times
```

## Tags

```
plasma6, widget, prayer times, namaz, liquid glass, countdown, islamic, clock
```

## File to upload

```
dist/liquid-glass-prayer-times-1.4.plasmoid
```

## Screenshot to upload

```
screenshots/preview.png
```

## Description (long)

```
A prayer times widget for KDE Plasma 6, drawn on a liquid-glass card: a live
countdown to the next prayer, today's six times, and a soft glow along the
glass edge when the next prayer is close.

Features

- Worldwide locations: pick a country and city from the built-in lists or
  type your own. Coordinates are resolved through Open-Meteo geocoding and
  the times come from the Aladhan calendar API.
- Three interface languages: English, Turkish and Arabic, the last with a
  full right-to-left layout and Arabic-Indic digits.
- Idiomatic clock format per language: 05.45 in Turkish, 05:45 otherwise.
  No seconds anywhere.
- Prayer list set in Poppins, countdown in Barlow Condensed, matching the
  rest of the liquid-glass widget set.
- Responsive: a portrait card, a wide 3 + 3 arrangement and a slim panel bar,
  chosen automatically from the widget aspect ratio. The corner radius scales
  with the widget size, so the squircle keeps its proportion in every format.
- Light and dark modes. On a light card the text polarity flips to dark and
  the accent colours are darkened automatically, so they stay readable.
- Configurable main accent colour and a separate next-prayer colour, corner
  radius, glass tint, chroma, blur and the warning window in minutes.
- Efficient: the whole month is fetched in a single request and cached
  locally (about 2 KB), so the widget only touches the network once a month.

Installation

Download the .plasmoid file, then in Plasma: Add Widgets ->
Get New Widgets... -> Install from file. Or from a terminal:

  kpackagetool6 -t Plasma/Applet -i liquid-glass-prayer-times-1.4.plasmoid

Requirements: KDE Plasma 6.x and Qt 6.x.

Credits

The liquid-glass visual foundation (backdrop sampling, kawase blur, the
refraction shader and the squircle geometry) is derived from "Liquid Glass -
macOS Widgets for KDE" by Jack Faith (jaxparrow07), used under GPL-3.0:
https://github.com/jaxparrow07/liquidglass-kde-widgets

Credits for that work belong to its author. This project adds prayer times
content and the surrounding logic on top of it. Bundled fonts, Poppins and
Barlow, are under the SIL Open Font License. Prayer times via the Aladhan API.

Türkçe özet: KDE Plasma 6 için liquid-glass görünümünde namaz vakti widget'ı.
Sıradaki vakte canlı geri sayım, dünya çapında konum, Türkçe/İngilizce/Arapça
arayüz, dikey, geniş ve bar yerleşimleri, açık modda okunabilir vurgu renkleri.
Görsel temel Jack Faith (jaxparrow07) tarafından geliştirilen
liquidglass-kde-widgets projesinden GPL-3.0 kapsamında uyarlanmıştır.
```
