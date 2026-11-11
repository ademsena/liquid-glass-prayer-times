.pragma library

// Strings for the config dialog in the widget's own language.
//
// The Plasma config pages render with the system locale, but the widget has
// its own language setting (cfg_language: 0=Türkçe, 1=English, 2=العربية),
// so the pages read labels from this table with t(lang, key) instead of
// i18n(). Each entry is a [Türkçe, English, العربية] tuple.

var S = {
    // ConfigPrayer — Hesaplama
    country:      ["Ülke:", "Country:", "البلد:"],
    city:         ["Şehir:", "City:", "المدينة:"],
    geoHint:      ["Listeden seçin veya yazın; bilinmeyen şehirler coğrafi konum servisiyle çözülür.", "Pick from the list or type; unknown cities are resolved via the geocoding service.", "اختر من القائمة أو اكتب؛ تُحلّ المدن غير الموجودة عبر خدمة الموقع."],
    method:       ["Hesaplama yöntemi:", "Calculation method:", "طريقة الحساب:"],
    meth0:        ["Diyanet (Türkiye)", "Diyanet (Turkey)", "الديانة (تركيا)"],
    meth1:        ["Mevelvi (MWL)", "Muslim World League", "رابطة العالم الإسلامي"],
    meth2:        ["İsna (Kuzey Amerika)", "ISNA (North America)", "الإسنا (أمريكا الشمالية)"],
    meth3:        ["Umm al-Qura (Mekke)", "Umm al-Qura (Makkah)", "أم القرى (مكة)"],
    meth4:        ["Mısır", "Egypt", "مصر"],
    meth5:        ["Karachi", "Karachi", "كراتشي"],
    meth6:        ["Şii (İsfahan)", "Shia (Isfahan)", "الشيعة (أصفهان)"],

    // ConfigPrayer — Gösterim
    showSection:  ["Gösterim", "Display", "العرض"],
    langLabel:    ["Dil:", "Language:", "اللغة:"],
    clockFormat:  ["Saat biçimi:", "Clock format:", "تنسيق الساعة:"],
    h24:          ["24 saat (05:15)", "24-hour (05:15)", "٢٤ ساعة (05:15)"],
    showWhich:    ["Gösterilecek vakitler:", "Shown prayers:", "الأوقات المعروضة:"],
    noteRefresh:  ["Konum, yöntem veya vakit seçimini değiştirdikten sonra Veri sekmesindeki \u201CŞimdi yenile\u201D düğmesiyle verileri tazeleyin.", "After changing the location, method or prayer list, refresh the data with \u201CRefresh now\u201D in the Veri tab.", "بعد تغيير الموقع أو الطريقة أو قائمة الأوقات، حدّث البيانات بواسطة \u201CDaha الآن\u201D في تبويب البيانات."],
    noteWarning:  ["Uyarı süresi ve parlaklığı Görünüm sekmesindedir.", "Warn minutes and glow opacity live in the Görünüm tab.", "مدة التنبيه وشدته في تبويب المظهر."],
    secCalc:      ["Hesaplama", "Calculation", "الحساب"],

    // ConfigAppearance — Renkler
    colors:       ["Renkler", "Colours", "الألوان"],
    mainAccent:   ["Ana vurgu:", "Main accent:", "اللون الرئيسي:"],
    dlgMain:      ["Ana vurgu rengi", "Main accent colour", "لون التمييز الرئيسي"],
    upcoming:     ["Yaklaşan vakit:", "Next prayer:", "الوقت القادم:"],
    dlgUpcoming:  ["Yaklaşan vakit rengi", "Next-prayer colour", "لون الوقت القادم"],
    warnMinutes:  ["Uyarı süresi (dk):", "Warn minutes (min):", "مدة التنبيه (د):"],
    off:          ["Kapalı", "Off", "مغلق"],
    warnOpacity:  ["Uyarı parlaklığı:", "Glow opacity:", "شدة التوهج:"],
    warnHint:     ["Sıradaki vakte bu kadar kaldığında cam kenarı bu renkte parlar. 0 = kapalı.", "When the next prayer is this close, the glass edge glows in this colour. 0 = off.", "عندما يبقى لهذا القدر من الوقت للصلاة القادمة، يتوهج حد الزجاج بهذا اللون. 0 = مغلق."],

    // ConfigAppearance — Stil
    styleSection: ["Stil", "Style", "النمط"],
    preset:       ["Preset:", "Preset:", "معدة مسبقاً:"],
    copyStyle:    ["Stili kopyala", "Copy style", "نسخ النمط"],
    pasteStyle:   ["Stili yapıştır", "Paste style", "لصق النمط"],
    copied:       ["Kopyalandı!", "Copied!", "تم النسخ!"],
    applied:      ["Uygulandı!", "Applied!", "تم التطبيق!"],
    invalid:      ["Geçersiz ayar metni", "Invalid config string", "نص إعدادات غير صالح"],
    styleLbl:     ["Stil:", "Style:", "النمط:"],
    glass:        ["Cam", "Glass", "زجاج"],
    solid:        ["Düz", "Solid", "صلب"],
    appearance:   ["Görünüm:", "Appearance:", "المظهر:"],
    dark:         ["Koyu", "Dark", "داكن"],
    light:        ["Açık", "Light", "فاتح"],
    followSys:    ["Sistemi izle", "Follow system", "اتبع النظام"],
    cornerRadius: ["Köşe yarıçapı (px):", "Corner radius (px):", "نصف قطر الزاوية (بكسل):"],
    roundness:    ["Yuvarlaklık (×10, 2.0..10.0):", "Roundness (×10, 2.0..10.0):", "الاستدارة (×10):"],

    // ConfigAppearance — Cam efekti
    glassEffect:  ["Cam efekti", "Glass effect", "تأثير الزجاج"],
    refrThickness:["Kırılma kalınlığı (px):", "Refraction thickness (px):", "سماكة الانكسار (بكسل):"],
    refrIndex:    ["Kırılma indisi (×100):", "Index of refraction (×100):", "معامل الانكسار (×100):"],
    refrStrength: ["Kırılma şiddeti:", "Refraction strength:", "شدة الانكسار:"],
    tintAlpha:    ["Renk örtüsü (%):", "Tint alpha (%):", "غطاء اللون (%):"],
    chroma:       ["Kromatik sapma (%):", "Chromatic aberration (%):", "الانحراف اللوني (%):"],
    specular:     ["Parlaklık yansıması (%):", "Specular strength (%):", "الانعكاس اللامع (%):"],
    blurRadius:   ["Bulandırma (px):", "Blur radius (px):", "نصف قطر الضبابية (بكسل):"],
    realtime:     ["Gerçek zamanlı kırılma:", "Realtime refraction:", "الانكسار في الوقت الحقيقي:"],
    realtimeHint: ["Her karede yeniden yakala (video duvar kağıtları için)", "Recapture every frame (for video wallpapers)", "إعادة الرسم في كل إطار (لخلفيات الفيديو)"],

    // ConfigData
    lastFetch:    ["Son çekme:", "Last fetch:", "آخر جلب:"],
    cityLbl:      ["Şehir:", "City:", "المدينة:"],
    methodLbl:    ["Yöntem:", "Method:", "الطريقة:"],
    storedDays:   ["Kayıtlı gün:", "Stored days:", "الأيام المخزنة:"],
    stateLbl:     ["Durum:", "Status:", "الحالة:"],
    lastError:    ["Son hata:", "Last error:", "آخر خطأ:"],
    dash:         ["—", "—", "—"],
    ready:        ["Hazır", "Ready", "جاهز"],
    cachedShow:   ["Önbellek gösteriliyor", "Showing cached data", "عرض البيانات المخزنة"],
    daySuffix:    [" gün", " days", " أيام"],
    dataLbl:      ["Veriler:", "Data:", "البيانات:"],
    refreshNow:   ["Şimdi yenile", "Refresh now", "التحديث الآن"],
    refreshStarted: ["Yenileme başlatıldı", "Refresh started", "بدأ التحديث"],
    dataHint:     ["Widget'a tıklamak da verileri tazeler. Aylık veri önbellekte tutulur, bu yüzden ayda yalnızca bir kez istek atılır.", "Clicking the widget refreshes the data too. A whole month is cached, so only one request per month is made.", "النقر على الوحدة يحدّث البيانات أيضاً. تُخزَّن بيانات الشهر كاملاً، فيُطلب مرة واحدة في الشهر."]
}

function t(lang, key) {
    var row = S[key]
    if (!row) return key
    var i = Math.max(0, Math.min(2, lang | 0))
    return row[i] !== undefined ? row[i] : row[0]
}
