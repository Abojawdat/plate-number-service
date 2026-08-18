import 'dart:ui';

import 'plate_palette.dart';

/// Which blank a plate is issued on.
///
/// Both the current system (rolled out in the Kurdistan Region in April 2022
/// and across the rest of Iraq from June 2024) and the 2010-era Arabic plate
/// are on the road, so both must render.
///
/// Rules per en.wikipedia.org/wiki/Vehicle_registration_plates_of_Iraq and
/// matriculasdelmundo.com/en/irak.html.
enum PlateFormat {
  /// 335 × 155 mm, two rows. The common passenger-car plate.
  modernShort,

  /// 520 × 110 mm, one row. Standard European blank.
  modernLong,

  /// 200 × 125 mm, two rows. Motorcycles: same scheme on a shorter, squarer
  /// blank with a narrower band and no rivets.
  motorcycle,

  /// 335 × 155 mm, Arabic. Pre-2024 issue.
  legacy,
}

/// Which side band a plate carries. Federal plates read `IRQ`; the four
/// Kurdistan Region governorates read `KR`.
enum PlateRegion { federal, kurdistan }

/// The 19 governorate codes of the current system, as published with the
/// 2022/2024 rollout.
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

  /// Looks up a governorate by its plate code, or `null` outside 11–29.
  static IraqGovernorate? fromCode(int code) {
    for (final governorate in values) {
      if (governorate.code == code) return governorate;
    }
    return null;
  }
}

/// Vehicle category, carried by the colour of the side band rather than the
/// main field — a taxi is a white plate with a red band. The security and
/// defence plates are the exceptions: they colour the field too.
enum PlateCategory {
  /// خصوصي — privately owned passenger cars. The default.
  private(
    arabicLabel: 'خصوصي',
    englishLabel: 'Private',
    defaultPalette: PlatePalette(
      bandColor: Color(0xFFE8EAEC),
      bandInk: Color(0xFF121417),
      fieldColor: Color(0xFFF2F4F5),
      fieldInk: Color(0xFF121417),
    ),
  ),

  /// أجرة — taxis, buses and anything else carrying fares.
  publicHire(
    arabicLabel: 'أجرة',
    englishLabel: 'Public hire',
    defaultPalette: PlatePalette(
      bandColor: Color(0xFFC8102E),
      bandInk: Color(0xFFFFFFFF),
      fieldColor: Color(0xFFF2F4F5),
      fieldInk: Color(0xFF121417),
    ),
  ),

  /// حكومية — state-owned vehicles.
  government(
    arabicLabel: 'حكومية',
    englishLabel: 'Government',
    defaultPalette: PlatePalette(
      bandColor: Color(0xFF10499B),
      bandInk: Color(0xFFFFFFFF),
      fieldColor: Color(0xFFF2F4F5),
      fieldInk: Color(0xFF121417),
    ),
  ),

  /// حمل — goods vehicles: trucks, tractors, cranes.
  cargo(
    arabicLabel: 'حمل',
    englishLabel: 'Cargo',
    defaultPalette: PlatePalette(
      bandColor: Color(0xFFF2B705),
      bandInk: Color(0xFF121417),
      fieldColor: Color(0xFFF2F4F5),
      fieldInk: Color(0xFF121417),
    ),
  ),

  /// زراعي — agricultural and construction machinery.
  agricultural(
    arabicLabel: 'زراعي',
    englishLabel: 'Agricultural',
    defaultPalette: PlatePalette(
      bandColor: Color(0xFF1B7F44),
      bandInk: Color(0xFFFFFFFF),
      fieldColor: Color(0xFFF2F4F5),
      fieldInk: Color(0xFF121417),
    ),
  ),

  /// مؤقت — issued at customs while an imported vehicle is cleared.
  temporary(
    arabicLabel: 'مؤقت',
    englishLabel: 'Temporary',
    defaultPalette: PlatePalette(
      bandColor: Color(0xFFE8710A),
      bandInk: Color(0xFFFFFFFF),
      fieldColor: Color(0xFFF2F4F5),
      fieldInk: Color(0xFF121417),
    ),
  ),

  /// مكافحة الإرهاب — Counter Terrorism Service. The whole plate is black.
  security(
    arabicLabel: 'مكافحة الإرهاب',
    englishLabel: 'Counter-terrorism',
    defaultPalette: PlatePalette(
      bandColor: Color(0xFF15171A),
      bandInk: Color(0xFFF2F4F5),
      fieldColor: Color(0xFF1D2024),
      fieldInk: Color(0xFFF2F4F5),
    ),
  ),

  /// الدفاع — Ministry of Defence. White lettering on green.
  defence(
    arabicLabel: 'الدفاع',
    englishLabel: 'Defence',
    defaultPalette: PlatePalette(
      bandColor: Color(0xFF0B5D34),
      bandInk: Color(0xFFFFFFFF),
      fieldColor: Color(0xFF117843),
      fieldInk: Color(0xFFFFFFFF),
    ),
  );

  const PlateCategory({
    required this.arabicLabel,
    required this.englishLabel,
    required this.defaultPalette,
  });

  /// The category word as it is spelled out on a [PlateFormat.legacy] plate.
  final String arabicLabel;
  final String englishLabel;

  /// The authentic colours for this category, as issued.
  final PlatePalette defaultPalette;

  /// True when the field is dark, which flips the emboss lighting.
  bool get isDarkField => defaultPalette.isDarkField;

  /// The categories a passenger could plausibly be picked up in.
  static const List<PlateCategory> rideEligible = [private, publicHire];
}

/// The Arabic series letters of the legacy system and their Latin equivalents.
///
/// The current system assigns Latin letters sequentially, and gave `A` to every
/// registration carried over with five or fewer digits — which is why so many
/// plates on the road read `A`.
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

  /// The series for a Latin letter, or `null` if it has no legacy counterpart.
  static PlateSeries? fromLatin(String letter) {
    final upper = letter.toUpperCase();
    for (final series in values) {
      if (series.latin == upper) return series;
    }
    return null;
  }
}

/// One registration: governorate, series letter, serial, category and blank.
class IraqiPlate {
  const IraqiPlate({
    required this.governorate,
    required this.serial,
    this.letter = 'A',
    this.category = PlateCategory.private,
    this.format = PlateFormat.modernShort,
  });

  /// A known-good sample plate, taken from the reference photograph.
  static const reference = IraqiPlate(
    governorate: IraqGovernorate.baghdad,
    letter: 'A',
    serial: '70634',
  );

  final IraqGovernorate governorate;

  /// Series letter, a single Latin character.
  final String letter;

  /// Four digits under the current scheme, five on carried-over registrations.
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

  /// Arabic series letter for [PlateFormat.legacy], falling back to [letter].
  String get letterArabic => PlateSeries.fromLatin(letter)?.arabic ?? letter;

  /// `null` when the plate is well formed, otherwise why it is not. Returns a
  /// message rather than throwing so it can back a text field directly.
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

  /// Parses `11 A 70634`, `11A70634` or `11-A-70634`, returning `null` on
  /// anything it cannot read.
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

  /// `٧٠٦٣٤` → `70634`. Also handles the Persian digit block, which a fair
  /// number of Iraqi keyboards emit.
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
