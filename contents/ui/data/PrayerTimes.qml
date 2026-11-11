import QtQuick
import org.kde.plasma.plasmoid
import "Locations.js" as Places

// Prayer time data provider.
//
// Fetches a whole month from the Aladhan API in a single request
// (calendarByCity/{year}/{month}, calculation method 13 = Diyanet
// parameters), keeps it in plasmoid.configuration as a ~2 KB cache so the
// widget only hits the network once per month, and derives the countdown /
// next-prayer state from that month.
// Item rather than QtObject: it needs to own the Timer and Connections
// children below, and only Items have a default property to hold them.
Item {
    id: pt
    visible: false

    // ── Language ───────────────────────────────────────────────────────
    // 0 = Türkçe, 1 = English, 2 = العربية. Everything the card renders comes
    // from `strings`, so switching the language re-renders labels, the hero
    // line, the unit next to the countdown and the status messages.
    readonly property int language: Plasmoid.configuration.language !== undefined
                                    && Plasmoid.configuration.language >= 0
                                    && Plasmoid.configuration.language <= 2
                                  ? Plasmoid.configuration.language : 0

    readonly property var strings: {
        var table = [
            {   // Türkçe
                labels: { Fajr: "İmsak", Sunrise: "Güneş", Dhuhr: "Öğle",
                          Asr: "İkindi", Maghrib: "Akşam", Isha: "Yatsı" },
                suffix: " Vaktine:",
                unit: "dk",
                sep: ".",
                loading: "Yükleniyor…",
                failed: "Vakitler alınamadı",
                notFound: "Şehir bulunamadı",
                timeout: "Sunucu yanıt vermiyor",
                empty: "Veri yok",
                waiting: "Yeni ay verisi bekleniyor…",
                cached: "Önbellek gösteriliyor",
                am: "ÖÖ",
                pm: "ÖS"
            },
            {   // English
                labels: { Fajr: "Fajr", Sunrise: "Sunrise", Dhuhr: "Dhuhr",
                          Asr: "Asr", Maghrib: "Maghrib", Isha: "Isha" },
                suffix: " in:",
                unit: "min",
                sep: ":",
                loading: "Loading…",
                failed: "Could not load times",
                notFound: "City not found",
                timeout: "Server not responding",
                empty: "No data",
                waiting: "Waiting for next month's data…",
                cached: "Showing cached data",
                am: "AM",
                pm: "PM"
            },
            {   // العربية
                labels: { Fajr: "الفجر", Sunrise: "الشروق", Dhuhr: "الظهر",
                          Asr: "العصر", Maghrib: "المغرب", Isha: "العشاء" },
                suffix: ":",
                unit: "د",
                sep: ":",
                loading: "جارٍ التحميل…",
                failed: "تعذر تحميل الأوقات",
                notFound: "تعذر العثور على المدينة",
                timeout: "الخادم لا يستجيب",
                empty: "لا توجد بيانات",
                waiting: "بانتظار بيانات الشهر القادم…",
                cached: "عرض البيانات المخزنة",
                am: "ص",
                pm: "م"
            }
        ]
        return table[language]
    }

    readonly property string unit: strings.unit

    // ── Right-to-left ──────────────────────────────────────────────────
    // Arabic flips the layout (names on the right, times on the left) and
    // renders the digits in Arabic-Indic numerals. Digit order itself stays
    // most-significant-first — that is how numerals are written in Arabic
    // text — only the surrounding blocks mirror.
    readonly property bool rtl: language === 2

    function arabize(s) {
        s = String(s)
        if (!rtl || s.length === 0) return s
        var digits = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"]
        var out = ""
        for (var i = 0; i < s.length; i++) {
            var ch = s.charAt(i)
            out += (ch >= "0" && ch <= "9") ? digits[+ch] : ch
        }
        return out
    }

    // ── Prayer definitions (fixed order = cache column order) ──────────
    readonly property var defs: [
        { key: "Fajr",    label: strings.labels.Fajr,    color: "#5E5CE6" },
        { key: "Sunrise", label: strings.labels.Sunrise, color: "#FF9F0A" },
        { key: "Dhuhr",   label: strings.labels.Dhuhr,   color: "#FFD60A" },
        { key: "Asr",     label: strings.labels.Asr,     color: "#30D158" },
        { key: "Maghrib", label: strings.labels.Maghrib, color: "#FF375F" },
        { key: "Isha",    label: strings.labels.Isha,    color: "#BF5AF2" }
    ]

    // ── Config shorthands ──────────────────────────────────────────────
    // Config stores the index shown in the settings combo; these are the
    // matching Aladhan calculation method ids. Keep in sync with the combo
    // in config/ConfigPrayer.qml.
    readonly property var methodIds: [13, 3, 2, 4, 5, 1, 0]

    readonly property string city: Plasmoid.configuration.city || "Ankara"
    readonly property string country: Plasmoid.configuration.country || "Turkey"
    readonly property int methodIndex: Plasmoid.configuration.methodIndex !== undefined
                                    ? Plasmoid.configuration.methodIndex : 0
    readonly property int method: methodIds[methodIndex] !== undefined
                                ? methodIds[methodIndex] : methodIds[0]
    readonly property bool use24h: Plasmoid.configuration.use24h !== false

    // Edge warning shown when the next prayer is this close. 0 disables it.
    readonly property int warnMinutes: Plasmoid.configuration.warnMinutes !== undefined
                                     ? Plasmoid.configuration.warnMinutes : 15
    readonly property real warnOpacity: (Plasmoid.configuration.warnOpacityPct !== undefined
                                     ? Plasmoid.configuration.warnOpacityPct : 35) / 100

    // Next-prayer accent colour (separate from main accent)
    property bool lightMode: false

    readonly property color nextAccent: {
        var hex = _resolveNextAccent(Plasmoid.configuration.nextAccentHex)
        // On a light card a white (or very pale) highlight vanishes; darken
        // it so the highlighted prayer and the edge glow stay visible while
        // keeping the user's hue.
        return lightMode ? Qt.darker(hex, 2.4) : hex
    }

    function _resolveNextAccent(raw) {
        var hex = (raw || "").trim()
        if (!/^#[0-9a-fA-F]{6}$/.test(hex))
            hex = "#FF3B30"
        return hex
    }

    readonly property var enabledDefs: {
        var raw = Plasmoid.configuration.enabledPrayers
        if (typeof raw === "string")
            raw = raw.split(",").map(function (s) { return s.trim() })
        if (!raw || raw.length === 0)
            return defs
        var out = []
        for (var i = 0; i < defs.length; i++)
            if (raw.indexOf(defs[i].key) !== -1) out.push(defs[i])
        return out.length > 0 ? out : defs
    }

    // ── State ──────────────────────────────────────────────────────────
    property var days: []            // [{ k: "2026-10-01", t: "05:15|06:38|..." }]
    property date now: new Date()
    property bool busy: false
    property string errorText: ""
    property bool loading: false

    // Internal bookkeeping for the month fetch queue.
    property var _pending: []
    property real _retryAfter: 0

    readonly property bool hasData: days.length > 0
    readonly property var todayEntry: _entryFor(now)

    // Once every enabled prayer of today is past, the list rolls over to
    // tomorrow so the widget never shows an all-greyed-out day.
    readonly property bool listIsTomorrow: {
        if (!hasData || enabledDefs.length === 0) return false
        var cur = now.getHours() * 60 + now.getMinutes()
        if (!todayEntry) return false
        var vals = _minutesOf(todayEntry)
        for (var i = 0; i < enabledDefs.length; i++) {
            var m = vals[enabledDefs[i].key]
            if (m !== null && m > cur) return false
        }
        return true
    }

    readonly property var listDate: listIsTomorrow
        ? new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1)
        : now

    // Fall back to the newest cached day during the brief window at a month
    // boundary, so the card is never blank while the next month loads.
    readonly property var lastEntry: days.length > 0 ? days[days.length - 1] : null
    readonly property var listEntry: _entryFor(listDate) || lastEntry

    readonly property var nextPrayer: _computeNext()

    readonly property real remainingMs: {
        if (!nextPrayer) return -1
        return _at(nextPrayer.date, nextPrayer.minutes).getTime() - now.getTime()
    }

    readonly property string countdownText: {
        if (remainingMs < 0) return "--" + strings.sep + "--"
        var total = Math.floor(remainingMs / 60000)
        return _pad2(Math.floor(total / 60)) + strings.sep + _pad2(total % 60)
    }

    // What the card actually draws: Arabic-Indic digits in ال mode.
    readonly property string countdownDisplay: arabize(countdownText)

    // Last stretch before the next prayer: the glass edge glows red. The
    // window and the glow strength are user settings.
    readonly property bool nearNext: warnMinutes > 0 && remainingMs > 0
                                     && remainingMs <= warnMinutes * 60000

    // Short label: the countdown underneath already says "how long", so the
    // hero only needs to name the prayer. Keeping it short is what lets the
    // label stay large on a narrow card instead of shrinking/eliding.
    readonly property string nextLabel: nextPrayer
        ? nextPrayer.def.label + strings.suffix
        : ""

    // Rows for the prayer list: name + time only, next prayer highlighted.
    readonly property var rows: {
        var out = []
        if (!listEntry) return out
        var mins = _minutesOf(listEntry)
        var raws = listEntry.t.split("|")
        var cur = now.getHours() * 60 + now.getMinutes()
        var nextKey = nextPrayer ? nextPrayer.def.key : ""
        var sameDay = nextPrayer
            && nextPrayer.date.getFullYear() === listDate.getFullYear()
            && nextPrayer.date.getMonth() === listDate.getMonth()
            && nextPrayer.date.getDate() === listDate.getDate()
        for (var i = 0; i < enabledDefs.length; i++) {
            var d = enabledDefs[i]
            var m = mins[d.key]
            if (m === null || m === undefined) continue
            var isNext = sameDay && nextKey === d.key
            out.push({
                key: d.key,
                label: d.label,
                color: d.color,
                nextColor: pt.nextAccent,
                time: pt.arabize(_formatString(raws[defs.indexOf(d)])),
                isNext: isNext,
                isPast: !isNext && !listIsTomorrow && m < cur
            })
        }
        return out
    }

    readonly property string statusLine: {
        if (loading && !hasData) return strings.loading
        if (!hasData) return errorText ? strings.failed : strings.empty
        if (!todayEntry) return strings.waiting
        if (errorText) return strings.cached
        return ""
    }

    // ── Lifecycle ──────────────────────────────────────────────────────
    Component.onCompleted: {
        loadCache()
        armMinuteTimer()
        configTimer.start()
        if (needsFetch()) fetch()
    }

    // The countdown shows hours and minutes only, so `now` is refreshed once
    // per minute instead of once per second: nextPrayer / rows are
    // recomputed 60x less often. Re-arming on the wall-clock minute boundary
    // keeps the display flipping exactly when the minute changes.
    function armMinuteTimer() {
        tickTimer.interval = Math.max(250, 60000 - (Date.now() % 60000))
        tickTimer.restart()
    }

    Timer {
        id: tickTimer
        repeat: false
        onTriggered: {
            pt.now = new Date()
            // Month rollover (or a long sleep) needs a fresh request.
            if (pt.needsFetch())
                pt.fetch()
            pt.armMinuteTimer()
        }
    }

    // plasmoid.configuration does not expose change signals for its keys, so
    // the few values that must trigger a refetch are polled. This is a plain
    // comparison loop — it does not touch `now` or any visible binding.
    Timer {
        id: configTimer
        interval: 1000
        repeat: true
        onTriggered: pt.checkConfigChanges()
    }

    // ── Helpers ────────────────────────────────────────────────────────
    function _pad2(n) { return n < 10 ? "0" + n : String(n) }

    function _pad(n) { return n < 10 ? "0" + n : String(n) }

    // The API returns day/month as strings ("01"), year as a string too.
    function _padStr(s) {
        var t = String(s)
        return t.length >= 2 ? t : "0" + t
    }

    function _ym(d) { return d.getFullYear() + "-" + _pad(d.getMonth() + 1) }

    function _key(d) {
        return d.getFullYear() + "-" + _pad(d.getMonth() + 1) + "-" + _pad(d.getDate())
    }

    function _minutesOf(hhmm) {
        var out = {}
        if (!hhmm) return out
        var cols = hhmm.t.split("|")
        for (var i = 0; i < defs.length; i++) {
            var v = cols[i]
            out[defs[i].key] = (v && v.length >= 4) ? _toMinutes(v) : null
        }
        return out
    }

    function _toMinutes(hhmm) {
        var p = hhmm.split(":")
        return parseInt(p[0], 10) * 60 + parseInt(p[1], 10)
    }

    function _at(d, minutes) {
        return new Date(d.getFullYear(), d.getMonth(), d.getDate(), 0, minutes, 0, 0)
    }

    function _entryFor(d) {
        if (!d || days.length === 0) return null
        var k = _key(d)
        for (var i = 0; i < days.length; i++)
            if (days[i].k === k) return days[i]
        return null
    }

    function _formatString(hhmm) {
        if (!hhmm) return "--" + strings.sep + "--"
        return _format(_toMinutes(hhmm))
    }

    function _format(minutes) {
        var h = Math.floor(minutes / 60)
        var m = minutes % 60
        // Turkish idiomatic clock uses a dot ("05.45"); EN/AR keep the colon.
        var sep = strings.sep || ":"
        if (use24h)
            return _pad2(h) + sep + _pad2(m)
        var suffix = h < 12 ? strings.am : strings.pm
        var hh = h % 12
        if (hh === 0) hh = 12
        return hh + sep + _pad2(m) + " " + suffix
    }

    function _computeNext() {
        if (!hasData || enabledDefs.length === 0) return null
        var cur = now.getHours() * 60 + now.getMinutes()
        var e = _entryFor(now)
        if (e) {
            var vals = _minutesOf(e)
            for (var i = 0; i < enabledDefs.length; i++) {
                var d = enabledDefs[i]
                var m = vals[d.key]
                if (m === null || m === undefined) continue
                if (m > cur)
                    return { def: d, minutes: m, date: now }
            }
        }
        // Today's prayers are done → tomorrow's first enabled prayer.
        var tomorrow = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1)
        var te = _entryFor(tomorrow)
        if (te) {
            var tvals = _minutesOf(te)
            var first = enabledDefs[0]
            var fm = tvals[first.key]
            if (fm !== null && fm !== undefined)
                return { def: first, minutes: fm, date: tomorrow }
        }
        return null
    }

    function needsFetch() {
        if (busy || _pending.length > 0) return false
        // Don't hammer the API if the last attempt failed.
        if (_retryAfter > now.getTime()) return false
        return pendingMonths().length > 0
    }

    // Months that must be fetched to cover today *and* tomorrow (the list
    // rolls over at midnight, so tomorrow's prayer times have to be there
    // too — which at the end of a month lives in the next month's payload).
    function pendingMonths() {
        if (days.length === 0)
            return [_ym(now), _ym(new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1))]
        var out = []
        var thisMonth = _ym(now)
        var nextMonth = _ym(new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1))
        if (_entryFor(now) === null)
            out.push(thisMonth)
        if (nextMonth !== thisMonth && _entryFor(new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1)) === null)
            out.push(nextMonth)
        return out
    }

    // plasmoid.configuration is a dynamic object: its change signals are not
    // known at compile time, so Connections cannot hook them. Poll the few
    // values that must trigger a refetch instead — once a second, on the same
    // tick that keeps the countdown alive.
    property string _seenCity: ""
    property string _seenCountry: ""
    property int _seenMethodIndex: -1
    property int _seenRefresh: -1

    function checkConfigChanges() {
        var refresh = Plasmoid.configuration.refreshCounter
        if (refresh === undefined || refresh === null)
            refresh = 0

        if (_seenMethodIndex === -1) {
            _seenCity = city
            _seenCountry = country
            _seenMethodIndex = methodIndex
            _seenRefresh = refresh
            return
        }

        if (refresh !== _seenRefresh) {
            _seenRefresh = refresh
            _seenCity = city
            _seenCountry = country
            _seenMethodIndex = methodIndex
            fetch(true)
            return
        }

        if (city !== _seenCity || country !== _seenCountry || methodIndex !== _seenMethodIndex) {
            _seenCity = city
            _seenCountry = country
            _seenMethodIndex = methodIndex
            invalidate()
        }
    }

    // ── Cache ──────────────────────────────────────────────────────────
    function loadCache() {
        var raw = Plasmoid.configuration.cacheJson
        if (!raw) return
        try {
            var o = JSON.parse(raw)
            if (!o || !o.days || o.days.length === 0) return
            days = o.days
        } catch (e) {
            // Corrupt cache — drop it and refetch.
            Plasmoid.configuration.cacheJson = ""
        }
    }

    function saveCache() {
        Plasmoid.configuration.cacheJson = JSON.stringify({
            v: 1,
            city: city,
            country: country,
            method: method,
            f: Plasmoid.configuration.lastFetch,
            days: days
        })
    }

    function invalidate() {
        // Kill any in-flight request first: the old "if (busy) return" made
        // the widget sit on the loading screen forever when a hung request
        // wedged `busy` on, and a second "Şimdi yenile" click did nothing.
        if (pt._currentXhr) {
            _currentXhr.onreadystatechange = null
            _currentXhr.abort()
            _currentXhr = null
        }
        busy = false
        days = []
        errorText = ""
        _retryAfter = 0
        _pending = []
        Plasmoid.configuration.cacheJson = ""
        Plasmoid.configuration.lastError = ""
        fetch(true)
    }

    // ── Network ────────────────────────────────────────────────────────
    // Two steps. First the stored city/country pair is turned into real
    // coordinates (Open-Meteo geocoder, cached in geoJson) — the Aladhan
    // city search silently answers with junk coordinates for towns like
    // Petropavl, which left those locations broken. Then a month of prayer
    // times is fetched for that exact point, one month at a time from a
    // small queue: at the end of a month the widget needs this month *and*
    // the next one.
    //
    // Every request is covered by the watchdog Timer below: no matter what
    // the network does (DNS hang, dropped connection), busy/loading are
    // released after the deadline.
    function fetch(force) {
        var c = _geoCache()
        if (c) {
            _g = c
            _queueMonths(force)
            return
        }
        _geocode()
    }

    function _geoCache() {
        var raw = Plasmoid.configuration.geoJson
        if (!raw) return null
        try {
            var o = JSON.parse(raw)
        } catch (e) {
            return null
        }
        if (o && o.city === city && o.country === country
                && typeof o.lat === "number" && typeof o.lon === "number")
            return o
        return null
    }

    // pt._g carries the resolved point so the month requests can chain.
    property var _g: null

    function _geocode() {
        busy = true
        loading = true
        var url = "https://geocoding-api.open-meteo.com/v1/search?name="
                  + encodeURIComponent(city) + "&count=10&format=json"
        var xhr = new XMLHttpRequest()
        _currentXhr = xhr
        xhr.open("GET", url)
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (_currentXhr === xhr) _currentXhr = null
            pt.busy = false
            if (xhr.status !== 200) {
                pt._fail("HTTP " + xhr.status)
                return
            }
            var res = []
            try {
                var body = JSON.parse(xhr.responseText)
                res = body.results || []
            } catch (e) {
                pt._fail("" + e)
                return
            }
            var code = Places.countryCode(country)
            var pick = null
            for (var i = 0; i < res.length && !pick; i++) {
                var cc = String(res[i].country_code || "").toUpperCase()
                if (code === "" || cc === code) pick = res[i]
            }
            if (!pick) {
                pt._fail(strings.notFound)
                return
            }
            var g = {
                city: city,
                country: country,
                lat: pick.latitude,
                lon: pick.longitude,
                tz: pick.timezone || ""
            }
            pt._g = g
            Plasmoid.configuration.geoJson = JSON.stringify(g)
            pt._queueMonths(true)
        }
        xhr.send()
    }

    function _queueMonths(force) {
        if (_pending.length === 0) {
            var months = force
                ? [_ym(now), _ym(new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1))]
                : pendingMonths()
            _pending = months.filter(function (m, i) { return months.indexOf(m) === i })
        }
        if (_pending.length === 0) return
        _retryAfter = 0
        _requestNext()
    }

    function _requestNext() {
        if (busy || _g === null || _pending.length === 0) return
        var ym = _pending.shift()
        var parts = ym.split("-")
        var url = "https://api.aladhan.com/v1/calendar/"
            + parts[0] + "/" + parseInt(parts[1], 10)
            + "?latitude=" + _g.lat + "&longitude=" + _g.lon
            + "&method=" + method
        if (_g.tz)
            url += "&timezonestring=" + encodeURIComponent(_g.tz)

        busy = true
        loading = true

        var xhr = new XMLHttpRequest()
        _currentXhr = xhr
        xhr.open("GET", url)
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (pt._currentXhr === xhr) pt._currentXhr = null
            pt.busy = false
            pt.loading = false
            if (xhr.status !== 200) {
                pt._fail("HTTP " + xhr.status)
                pt._pending = []
                return
            }
            try {
                pt.applyPayload(JSON.parse(xhr.responseText))
            } catch (e) {
                pt._fail("" + e)
                pt._pending = []
                return
            }
            pt._requestNext()
        }
        xhr.send()
    }

    // Hang on the wall: whatever the request state, release busy/loading and
    // mark the failure after this deadline so "Yükleniyor…" can never stick.
    property var _currentXhr: null

    Timer {
        id: watchdog
        interval: 20000
        running: pt.busy
        onTriggered: {
            if (pt._currentXhr) {
                pt._currentXhr.onreadystatechange = null
                pt._currentXhr.abort()
                pt._currentXhr = null
            }
            pt.busy = false
            pt._fail(pt.strings.timeout)
        }
    }

    function applyPayload(payload) {
        if (!payload || payload.code !== 200 || !payload.data || payload.data.length === 0)
            throw new Error(payload && payload.status ? payload.status : "bozuk yanıt")

        // Merge so a newly fetched month never drops days we still need
        // (e.g. the last day of the month asking for tomorrow).
        var merged = {}
        for (var i = 0; i < days.length; i++)
            merged[days[i].k] = days[i].t

        for (var d = 0; d < payload.data.length; d++) {
            var g = payload.data[d].date.gregorian
            var key = String(g.year) + "-" + _padStr(g.month.number) + "-" + _padStr(g.day)
            var raw = payload.data[d].timings
            var cols = []
            for (var c = 0; c < defs.length; c++) {
                var v = raw[defs[c].key]
                cols.push(v ? String(v).split(" ")[0] : "")
            }
            merged[key] = cols.join("|")
        }

        var out = []
        for (var k in merged)
            out.push({ k: k, t: merged[k] })
        out.sort(function (a, b) { return a.k < b.k ? -1 : (a.k > b.k ? 1 : 0) })

        days = out
        errorText = ""
        Plasmoid.configuration.lastError = ""
        Plasmoid.configuration.lastFetch = new Date().toISOString().substring(0, 16).replace("T", " ")
        saveCache()
    }

    function _fail(msg) {
        errorText = msg
        Plasmoid.configuration.lastError = msg
        loading = false
        // Back off for a few minutes instead of retrying every tick.
        _retryAfter = now.getTime() + 5 * 60 * 1000
    }
}
