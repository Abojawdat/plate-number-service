import 'dart:ui';

/// The four colours a plate is painted in.
///
/// Every [PlateCategory] ships its authentic colours as `defaultPalette`, so
/// this is only needed to draw a plate in your own. Pass one to
/// `IraqiLicensePlate`, or set it on an `IraqiPlateTheme` to restyle every
/// plate at once.
class PlatePalette {
  const PlatePalette({
    required this.bandColor,
    required this.bandInk,
    required this.fieldColor,
    required this.fieldInk,
  });

  /// A plate in a single accent colour, with the field left as white sheeting.
  const PlatePalette.branded(Color accent, {Color onAccent = _white})
    : bandColor = accent,
      bandInk = onAccent,
      fieldColor = _defaultField,
      fieldInk = _defaultInk;

  /// Background of the `IRQ`/`KR` side band.
  final Color bandColor;

  /// Ink for the band lettering and the flag frame.
  final Color bandInk;

  /// Background of the main field.
  final Color fieldColor;

  /// Ink for the registration characters.
  final Color fieldInk;

  static const Color _white = Color(0xFFFFFFFF);
  static const Color _defaultField = Color(0xFFF2F4F5);
  static const Color _defaultInk = Color(0xFF121417);

  /// True when the field is dark, which flips the emboss lighting.
  bool get isDarkField => fieldColor.computeLuminance() < 0.4;

  /// True when the band is a colour rather than plain sheeting. A tinted band
  /// uses [bandInk]; an untinted one reuses [fieldInk].
  bool get isBandTinted => bandColor != _defaultBandColor;

  static const Color _defaultBandColor = Color(0xFFE8EAEC);

  PlatePalette copyWith({
    Color? bandColor,
    Color? bandInk,
    Color? fieldColor,
    Color? fieldInk,
  }) {
    return PlatePalette(
      bandColor: bandColor ?? this.bandColor,
      bandInk: bandInk ?? this.bandInk,
      fieldColor: fieldColor ?? this.fieldColor,
      fieldInk: fieldInk ?? this.fieldInk,
    );
  }

  /// Interpolates between two palettes. `t` of 0 gives [a], 1 gives [b].
  static PlatePalette? lerp(PlatePalette? a, PlatePalette? b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return b;
    if (b == null) return a;
    return PlatePalette(
      bandColor: Color.lerp(a.bandColor, b.bandColor, t)!,
      bandInk: Color.lerp(a.bandInk, b.bandInk, t)!,
      fieldColor: Color.lerp(a.fieldColor, b.fieldColor, t)!,
      fieldInk: Color.lerp(a.fieldInk, b.fieldInk, t)!,
    );
  }

  @override
  String toString() =>
      'PlatePalette(band: $bandColor on $bandInk, '
      'field: $fieldColor on $fieldInk)';

  @override
  bool operator ==(Object other) =>
      other is PlatePalette &&
      other.bandColor == bandColor &&
      other.bandInk == bandInk &&
      other.fieldColor == fieldColor &&
      other.fieldInk == fieldInk;

  @override
  int get hashCode => Object.hash(bandColor, bandInk, fieldColor, fieldInk);
}
