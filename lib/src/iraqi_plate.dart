import 'dart:ui';

/// Domain model for Iraqi vehicle registration plates.
///
/// Sources for the rules encoded here:
///  * en.wikipedia.org/wiki/Vehicle_registration_plates_of_Iraq
///  * matriculasdelmundo.com/en/irak.html
///
/// Two systems are on the road at the same time and both must render:
///
///  * [PlateFormat.modernShort] / [PlateFormat.modernLong] — the format rolled
///    out in the Kurdistan Region in April 2022 and across the rest of Iraq
///    from June 2024. Latin letters, Western digits, `IRQ`/`KR` in the side
///    band, governorate written as a two-digit code instead of its name.
///  * [PlateFormat.legacy] — the 2010-era plate. Eastern-Arabic digits, an
///    Arabic series letter, and the governorate name plus the category word
///    spelled out in Arabic along the bottom. Still valid, still very common.
///
/// The reference photo this renderer was matched against is a Baghdad plate
/// reading `11 A 70634`: governorate 11, transitional series letter `A`, and a
/// five-digit serial carried over from the old system.
enum PlateFormat {
  /// 335 × 155 mm, two rows. The common passenger-car plate.
  modernShort,

  /// 520 × 110 mm, one row. Standard European blank.
  modernLong,

  /// 200 × 125 mm, two rows. Motorcycles and other vehicles that cannot carry
  /// a full-size blank: same registration scheme, shorter and squarer, with a
  /// narrower band and no mounting rivets through the printed area.
  motorcycle,

  /// 335 × 155 mm, Arabic. Pre-2024 issue.
  legacy,
}

/// Which side band a plate carries. Federal plates read `IRQ`; the four
/// Kurdistan Region governorates read `KR`.
enum PlateRegion { federal, kurdistan }

/// The 19 governorate codes of the current system.
///
/// Codes are not alphabetical and not contiguous with any older scheme — they
/// are simply the list published with the 2022/2024 rollout, so they are
/// hard-coded rather than derived.
enum IraqGovernorate {
  baghdad(11, 'بغداد', 'Baghdad'),
  nineveh(12, 'نينوى', 'Nineveh'),
  maysan(13, 'ميسان', 'Maysan'),
  basra(14, 'البصرة', 'Basra'),
  anbar(15, 'الأنبار', 'Al Anbar'),
  qadisiyyah(16, 'القادسية', 'Al-Qadisiyyah'),
  muthanna(17, 'المثنى', 'Muthanna'),
  babil(18, 'بابل', 'Babil'),
  karbala(19, 'كربلاء', 'Karbala'),
  diyala(20, 'ديالى', 'Diyala'),
  sulaymaniyah(21, 'السليمانية', 'Sulaymaniyah', PlateRegion.kurdistan),
  erbil(22, 'أربيل', 'Erbil', PlateRegion.kurdistan),
  halabja(23, 'حلبجة', 'Halabja', PlateRegion.kurdistan),
  duhok(24, 'دهوك', 'Duhok', PlateRegion.kurdistan),
  kirkuk(25, 'كركوك', 'Kirkuk'),
  saladin(26, 'صلاح الدين', 'Saladin'),
  dhiQar(27, 'ذي قار', 'Dhi Qar'),
  najaf(28, 'النجف', 'Najaf'),
  wasit(29, 'واسط', 'Wasit');

  const IraqGovernorate(
    this.code,
    this.arabicName,
    this.englishName, [
    this.region = PlateRegion.federal,
  ]);

  /// Two-digit code stamped on the plate, 11–29.
  final int code;
  final String arabicName;
  final String englishName;

  /// Kurdistan Region governorates get a `KR` band instead of `IRQ`.
  final PlateRegion region;

  /// The code as it appears on the plate, always two digits.
  String get codeText => code.toString().padLeft(2, '0');

  /// Looks up a governorate by its plate code, or `null` if 11–29 does not
  /// cover it (which means the plate is malformed or pre-2022).
  static IraqGovernorate? fromCode(int code) {
    for (final governorate in values) {
      if (governorate.code == code) return governorate;
    }
    return null;
  }
}

/// Vehicle category. On Iraqi plates the category is carried by the colour of
/// the side band, not by the main field — a taxi plate is a white plate with a
/// red band, not a red plate. The two exceptions are the security and defence
/// plates, which colour the whole field and invert the lettering.
enum PlateCategory {
  /// خصوصي — privately owned passenger cars. The default.
  private(
    arabicLabel: 'خصوصي',
    englishLabel: 'Private',
    bandColor: Color(0xFFE8EAEC),
    bandInk: Color(0xFF121417),
    fieldColor: Color(0xFFF2F4F5),
    fieldInk: Color(0xFF121417),
  ),

  /// أجرة — taxis, buses and anything else carrying fares. The category that
  /// matters most to this app: every driver on the platform should be on one.
  publicHire(
    arabicLabel: 'أجرة',
    englishLabel: 'Public hire',
    bandColor: Color(0xFFC8102E),
    bandInk: Color(0xFFFFFFFF),
    fieldColor: Color(0xFFF2F4F5),
    fieldInk: Color(0xFF121417),
  ),

  /// حكومية — state-owned vehicles.
  government(
    arabicLabel: 'حكومية',
    englishLabel: 'Government',
    bandColor: Color(0xFF10499B),
    bandInk: Color(0xFFFFFFFF),
    fieldColor: Color(0xFFF2F4F5),
    fieldInk: Color(0xFF121417),
  ),

  /// حمل — goods vehicles: trucks, tractors, cranes.
  cargo(
    arabicLabel: 'حمل',
    englishLabel: 'Cargo',
    bandColor: Color(0xFFF2B705),
    bandInk: Color(0xFF121417),
    fieldColor: Color(0xFFF2F4F5),
    fieldInk: Color(0xFF121417),
  ),

  /// زراعي — agricultural and construction machinery.
  agricultural(
    arabicLabel: 'زراعي',
    englishLabel: 'Agricultural',
    bandColor: Color(0xFF1B7F44),
    bandInk: Color(0xFFFFFFFF),
    fieldColor: Color(0xFFF2F4F5),
    fieldInk: Color(0xFF121417),
  ),

  /// Temporary plate issued at customs while a freshly imported vehicle is
  /// cleared. Short-lived, so a driver should never be operating on one.
  temporary(
    arabicLabel: 'مؤقت',
    englishLabel: 'Temporary',
    bandColor: Color(0xFFE8710A),
    bandInk: Color(0xFFFFFFFF),
    fieldColor: Color(0xFFF2F4F5),
    fieldInk: Color(0xFF121417),
  ),

  /// جهاز مكافحة الإرهاب — Counter Terrorism Service. Whole plate is black.
  security(
    arabicLabel: 'مكافحة الإرهاب',
    englishLabel: 'Counter-terrorism',
    bandColor: Color(0xFF15171A),
    bandInk: Color(0xFFF2F4F5),
    fieldColor: Color(0xFF1D2024),
    fieldInk: Color(0xFFF2F4F5),
  ),

  /// الدفاع — Ministry of Defence. White lettering on green.
  defence(
    arabicLabel: 'الدفاع',
    englishLabel: 'Defence',
    bandColor: Color(0xFF0B5D34),
    bandInk: Color(0xFFFFFFFF),
    fieldColor: Color(0xFF117843),
    fieldInk: Color(0xFFFFFFFF),
  );

  const PlateCategory({
    required this.arabicLabel,
    required this.englishLabel,
    required this.bandColor,
    required this.bandInk,
    required this.fieldColor,
    required this.fieldInk,
  });

  /// The category word as it is spelled out on a [PlateFormat.legacy] plate.
  final String arabicLabel;
  final String englishLabel;

  /// Background of the `IRQ`/`KR` side band.
  final Color bandColor;

  /// Ink used for the band lettering and flag frame.
  final Color bandInk;

  /// Background of the main field.
  final Color fieldColor;

  /// Ink used for the registration characters.
  final Color fieldInk;

  /// True when the field is dark, which flips the emboss lighting: raised
  /// characters on a dark plate catch light on their faces, not their walls.
  bool get isDarkField => fieldColor.computeLuminance() < 0.4;

  /// Categories a rider could plausibly be picked up in. Used by the lab
  /// screen to highlight the realistic subset.
  static const List<PlateCategory> rideEligible = [private, publicHire];
}

/// The Arabic series letters used by the legacy system and their Latin
/// equivalents. The modern system assigns Latin letters sequentially as blocks
/// are exhausted, and — per the rollout rules — gives the letter `A` to every
/// registration carried over with five or fewer digits, which is why so many
/// plates on the road today read `A`.
enum PlateSeries {
  alif('ا', 'A'),
  ba('ب', 'B'),
  jim('ج', 'J'),
  dal('د', 'D'),
  ra('ر', 'R'),
  sin('س', 'S'),
  ta('ط', 'T'),
  fa('ف', 'F'),
  kaf('ك', 'K'),
  mim('م', 'M'),
  nun('ن', 'N'),
  ha('هـ', 'H'),
  ya('ى', 'E'),
  qaf('ق', 'Q'),
  lam('ل', 'L'),
  waw('و', 'W'),
  zay('ز', 'Z');

  const PlateSeries(this.arabic, this.latin);

  final String arabic;
  final String latin;

  /// The series for a Latin letter, or `null` if that letter is not part of
  /// the legacy mapping (the modern system may still use it).
  static PlateSeries? fromLatin(String letter) {
    final upper = letter.toUpperCase();
    for (final series in values) {
      if (series.latin == upper) return series;
    }
    return null;
  }
}

/// One rendered plate.
///
/// Immutable and cheap to build; [copyWith] is what the lab screen drives.
class IraqiPlate {
  const IraqiPlate({
    required this.governorate,
    required this.serial,
    this.letter = 'A',
    this.category = PlateCategory.private,
    this.format = PlateFormat.modernShort,
  });

  /// The plate from the reference photograph, kept as a known-good sample.
  static const reference = IraqiPlate(
    governorate: IraqGovernorate.baghdad,
    letter: 'A',
    serial: '70634',
  );

  final IraqGovernorate governorate;

  /// Series letter, a single Latin character.
  final String letter;

  /// Registration serial. Four digits under the current scheme; five on
  /// registrations carried over from the legacy system.
  final String serial;

  final PlateCategory category;
  final PlateFormat format;

  PlateRegion get region => governorate.region;

  /// `IRQ` for federal plates, `KR` for the Kurdistan Region.
  String get bandText => region == PlateRegion.kurdistan ? 'KR' : 'IRQ';

  /// Human-readable form, e.g. `11 A 70634`.
  String get formatted => '${governorate.codeText} $letter $serial';

  /// Eastern-Arabic rendering of the serial, for [PlateFormat.legacy].
  String get serialArabicDigits => toArabicDigits(serial);

  /// Arabic series letter for [PlateFormat.legacy], falling back to the Latin
  /// letter when it has no legacy counterpart.
  String get letterArabic => PlateSeries.fromLatin(letter)?.arabic ?? letter;

  /// `null` when the plate is well formed, otherwise why it is not.
  ///
  /// Deliberately returns a message rather than throwing: this is meant to
  /// back a text field in the lab screen and, later, driver-document review.
  String? get validationError {
    if (letter.length != 1) {
      return 'The series letter must be a single character.';
    }
    final code = letter.codeUnitAt(0);
    final isLatinLetter =
        (code >= 0x41 && code <= 0x5A) || (code >= 0x61 && code <= 0x7A);
    if (!isLatinLetter) {
      return 'The series letter must be A–Z.';
    }
    if (serial.isEmpty) return 'The serial is required.';
    if (serial.length > 5) return 'The serial cannot exceed five digits.';
    if (!RegExp(r'^\d+$').hasMatch(serial)) {
      return 'The serial must be digits only.';
    }
    return null;
  }

  bool get isValid => validationError == null;

  /// Parses `11 A 70634`, `11A70634` or `11-A-70634`.
  ///
  /// Returns `null` on anything it cannot read, so callers can fall back to
  /// showing the raw string rather than a wrong plate.
  static IraqiPlate? tryParse(
    String input, {
    PlateCategory category = PlateCategory.private,
    PlateFormat format = PlateFormat.modernShort,
  }) {
    final cleaned = fromArabicDigits(
      input,
    ).toUpperCase().replaceAll(RegExp(r'[\s\-_/]'), '');
    final match = RegExp(r'^(\d{2})([A-Z])(\d{1,5})$').firstMatch(cleaned);
    if (match == null) return null;
    final governorate = IraqGovernorate.fromCode(int.parse(match.group(1)!));
    if (governorate == null) return null;
    return IraqiPlate(
      governorate: governorate,
      letter: match.group(2)!,
      serial: match.group(3)!,
      category: category,
      format: format,
    );
  }

  IraqiPlate copyWith({
    IraqGovernorate? governorate,
    String? letter,
    String? serial,
    PlateCategory? category,
    PlateFormat? format,
  }) {
    return IraqiPlate(
      governorate: governorate ?? this.governorate,
      letter: letter ?? this.letter,
      serial: serial ?? this.serial,
      category: category ?? this.category,
      format: format ?? this.format,
    );
  }

  static const _arabicDigits = '٠١٢٣٤٥٦٧٨٩';

  /// `70634` → `٧٠٦٣٤`.
  static String toArabicDigits(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x30 && rune <= 0x39) {
        buffer.write(_arabicDigits[rune - 0x30]);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  /// `٧٠٦٣٤` → `70634`. Handles the Persian digit block too, because a
  /// fair number of Iraqi keyboards emit it.
  static String fromArabicDigits(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x0660 && rune <= 0x0669) {
        buffer.write(rune - 0x0660);
      } else if (rune >= 0x06F0 && rune <= 0x06F9) {
        buffer.write(rune - 0x06F0);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  @override
  String toString() => 'IraqiPlate($formatted, ${category.englishLabel})';

  @override
  bool operator ==(Object other) =>
      other is IraqiPlate &&
      other.governorate == governorate &&
      other.letter == letter &&
      other.serial == serial &&
      other.category == category &&
      other.format == format;

  @override
  int get hashCode =>
      Object.hash(governorate, letter, serial, category, format);
}
