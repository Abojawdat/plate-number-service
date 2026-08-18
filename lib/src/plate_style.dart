import 'package:flutter/foundation.dart';

import 'iraqi_plate.dart';
import 'plate_palette.dart';

/// A named, ready-made look: a blank, a set of colours, and a storable id.
///
/// Unlike the [PlateFormat] and [PlateCategory] enums, this is an ordinary
/// value, so the catalogue in [IraqiPlateStyles] can be filtered, extended and
/// persisted:
///
/// ```dart
/// PlateStylePicker(
///   styles: IraqiPlateStyles.rideEligible,
///   selected: _style,
///   onSelected: (style) => setState(() => _style = style),
/// )
/// ```
@immutable
class PlateStyle {
  const PlateStyle({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.format,
    required this.palette,
    this.category = PlateCategory.private,
  });

  /// Builds a style from a category's authentic colours.
  PlateStyle.fromCategory(
    this.category, {
    required this.id,
    required this.name,
    required this.nameArabic,
    this.format = PlateFormat.modernShort,
  }) : palette = category.defaultPalette;

  /// Stable identifier, safe to store. Ids never change once published, so a
  /// stored value still resolves through [IraqiPlateStyles.byId] after an
  /// upgrade.
  final String id;

  final String name;
  final String nameArabic;

  /// Which blank to draw.
  final PlateFormat format;

  /// What to paint it in.
  final PlatePalette palette;

  /// Decides the band colour and the Arabic wording along the bottom of a
  /// [PlateFormat.legacy] blank.
  final PlateCategory category;

  /// Applies this style to a registration.
  IraqiPlate applyTo(IraqiPlate plate) =>
      plate.copyWith(format: format, category: category);

  PlateStyle copyWith({
    String? id,
    String? name,
    String? nameArabic,
    PlateFormat? format,
    PlatePalette? palette,
    PlateCategory? category,
  }) {
    return PlateStyle(
      id: id ?? this.id,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      format: format ?? this.format,
      palette: palette ?? this.palette,
      category: category ?? this.category,
    );
  }

  @override
  String toString() => 'PlateStyle($id)';

  @override
  bool operator ==(Object other) =>
      other is PlateStyle &&
      other.id == id &&
      other.name == name &&
      other.nameArabic == nameArabic &&
      other.format == format &&
      other.palette == palette &&
      other.category == category;

  @override
  int get hashCode =>
      Object.hash(id, name, nameArabic, format, palette, category);
}

/// Every style this package ships, as values you can pick from.
abstract final class IraqiPlateStyles {
  /// خصوصي — the ordinary private car plate.
  static final PlateStyle privateCar = PlateStyle.fromCategory(
    PlateCategory.private,
    id: 'private',
    name: 'Private',
    nameArabic: 'خصوصي',
  );

  /// أجرة — taxis, buses, anything carrying fares. Red band.
  static final PlateStyle taxi = PlateStyle.fromCategory(
    PlateCategory.publicHire,
    id: 'taxi',
    name: 'Public hire',
    nameArabic: 'أجرة',
  );

  /// حكومية — state-owned vehicles. Blue band.
  static final PlateStyle government = PlateStyle.fromCategory(
    PlateCategory.government,
    id: 'government',
    name: 'Government',
    nameArabic: 'حكومية',
  );

  /// حمل — trucks, tractors, cranes. Yellow band.
  static final PlateStyle cargo = PlateStyle.fromCategory(
    PlateCategory.cargo,
    id: 'cargo',
    name: 'Cargo',
    nameArabic: 'حمل',
  );

  /// زراعي — farm and construction machinery. Green band.
  static final PlateStyle agricultural = PlateStyle.fromCategory(
    PlateCategory.agricultural,
    id: 'agricultural',
    name: 'Agricultural',
    nameArabic: 'زراعي',
  );

  /// مؤقت — issued at customs while an import clears. Orange band.
  static final PlateStyle temporary = PlateStyle.fromCategory(
    PlateCategory.temporary,
    id: 'temporary',
    name: 'Temporary',
    nameArabic: 'مؤقت',
  );

  /// مكافحة الإرهاب — Counter Terrorism Service. The whole plate is black.
  static final PlateStyle counterTerrorism = PlateStyle.fromCategory(
    PlateCategory.security,
    id: 'counter_terrorism',
    name: 'Counter-terrorism',
    nameArabic: 'مكافحة الإرهاب',
  );

  /// الدفاع — Ministry of Defence. White lettering on green.
  static final PlateStyle defence = PlateStyle.fromCategory(
    PlateCategory.defence,
    id: 'defence',
    name: 'Defence',
    nameArabic: 'الدفاع',
  );

  /// The 520×110 European blank, one row.
  static final PlateStyle european = PlateStyle.fromCategory(
    PlateCategory.private,
    id: 'european',
    name: 'European',
    nameArabic: 'أوروبي',
    format: PlateFormat.modernLong,
  );

  /// The 200×125 motorcycle blank: shorter, squarer, no rivets.
  static final PlateStyle motorcycle = PlateStyle.fromCategory(
    PlateCategory.private,
    id: 'motorcycle',
    name: 'Motorcycle',
    nameArabic: 'دراجة نارية',
    format: PlateFormat.motorcycle,
  );

  /// The pre-2024 Arabic plate: Eastern-Arabic digits, Arabic series letter,
  /// governorate and category spelled out along the bottom.
  static final PlateStyle legacyArabic = PlateStyle.fromCategory(
    PlateCategory.private,
    id: 'legacy',
    name: 'Legacy Arabic',
    nameArabic: 'اللوحة القديمة',
    format: PlateFormat.legacy,
  );

  /// Every style, in the order a picker should show them.
  static final List<PlateStyle> all = List.unmodifiable([
    privateCar,
    taxi,
    government,
    cargo,
    agricultural,
    temporary,
    counterTerrorism,
    defence,
    european,
    motorcycle,
    legacyArabic,
  ]);

  /// The styles using a current-system blank.
  static final List<PlateStyle> modern = List.unmodifiable(
    all.where((s) => s.format != PlateFormat.legacy),
  );

  /// The styles a passenger could plausibly be picked up in.
  static final List<PlateStyle> rideEligible = List.unmodifiable([
    privateCar,
    taxi,
  ]);

  /// Looks a style up by [PlateStyle.id], or null if nothing matches.
  static PlateStyle? byId(String id) {
    for (final style in all) {
      if (style.id == id) return style;
    }
    return null;
  }
}
