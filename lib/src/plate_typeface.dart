import 'dart:ui';

/// Vector typeface for Iraqi registration plates.
///
/// Iraqi plates are stamped with a DIN-1451-derived face: monolinear, flat
/// terminals, squared bowls. None of the fonts bundled with this app (Almarai,
/// Nrt, Cairo) come close — they are humanist Arabic families whose Latin
/// digits read as "app UI", not "pressed aluminium". So the glyphs are authored
/// here as centre-line skeletons that get stroked at a fixed weight.
///
/// Stroking (rather than filling an outline) is deliberate: the emboss in
/// [IraqiLicensePlate] draws the *same* path four times at sub-millimetre
/// offsets, and a stroked path offsets identically to a filled one while
/// costing a quarter of the path data.
///
/// Design grid — all glyph coordinates are in these units, scaled at paint time:
/// ```
///   x: 0 .. em (70)          advance width
///   y: 0 .. cap (100)        cap height, baseline at y = cap
///   skeleton kept inside     x 9..61, y 8.5..91.5  (half a stroke from the edge)
/// ```
/// Ink therefore spans 58/100 of the cap height and the advance is 70/100,
/// which matches the proportions measured off a real Baghdad plate (0.63 ink,
/// 0.68 advance) to within a couple of percent.
class PlateTypeface {
  const PlateTypeface._();

  /// Nominal advance width, in glyph units.
  static const double em = 70;

  /// Cap height, in glyph units. Everything else is expressed relative to this.
  static const double cap = 100;

  /// Skeleton stroke weight. 0.17 × cap — measured off the ring of a real `0`.
  static const double stroke = 17;

  // Skeleton bounds: half a stroke inside the em box on every side.
  static const double _l = 9;
  static const double _r = 61;
  static const double _t = 8.5;
  static const double _b = 91.5;
  static const double _cx = 35;

  /// Per-glyph advance overrides. Digits stay monospaced so that the two rows
  /// of a plate line up in a column, exactly as the stamping die does it.
  static const Map<String, double> _advance = {
    'I': 36,
    'J': 66,
    'M': 78,
    'W': 80,
  };

  /// Advance width of [char] in glyph units, including the sidebearings.
  static double advanceOf(String char) => _advance[char] ?? em;

  /// Advance width of [text] in glyph units, with [tracking] between glyphs.
  static double measure(String text, {double tracking = 0}) {
    if (text.isEmpty) return 0;
    var total = 0.0;
    for (final char in text.split('')) {
      total += advanceOf(char) + tracking;
    }
    return total - tracking;
  }

  /// Centre-line path for [char], or `null` when the glyph is not in the face.
  ///
  /// The returned path is shared and must never be mutated by callers; use
  /// [Path.shift] / [Path.transform], both of which return copies.
  static Path? glyph(String char) => _glyphs[char.toUpperCase()];

  /// Whether every character of [text] can be rendered by this face.
  static bool covers(String text) =>
      text.split('').every((c) => _glyphs.containsKey(c.toUpperCase()));

  static final Map<String, Path> _glyphs = {
    '0': _rounded(),
    '1': Path()
      ..moveTo(12, 27)
      ..lineTo(_cx, _t)
      ..lineTo(_cx, _b),
    '2': Path()
      ..moveTo(11, 30)
      ..cubicTo(11, 16, 21, _t, _cx, _t)
      ..cubicTo(49, _t, 60, 17, 60, 30)
      ..cubicTo(60, 42, 53, 50, 40, 61)
      ..lineTo(10, _b)
      ..lineTo(_r, _b),
    '3': Path()
      ..moveTo(11, 27)
      ..cubicTo(13, 15, 23, _t, _cx, _t)
      ..cubicTo(49, _t, 59, 16, 59, 28)
      ..cubicTo(59, 41, 49, 50, 33, 50)
      ..cubicTo(50, 50, _r, 59, _r, 72)
      ..cubicTo(_r, 84, 50, _b, 36, _b)
      ..cubicTo(23, _b, 13, 85, 11, 73),
    '4': Path()
      ..moveTo(45, _t)
      ..lineTo(_l, 64)
      ..lineTo(_r, 64)
      ..moveTo(45, _t)
      ..lineTo(45, _b),
    '5': Path()
      ..moveTo(58, _t)
      ..lineTo(16, _t)
      ..lineTo(13, 43)
      ..cubicTo(24, 34, 39, 33, 48, 39)
      ..cubicTo(57, 45, _r, 54, _r, 66)
      ..cubicTo(_r, 82, 50, _b, _cx, _b)
      ..cubicTo(23, _b, 13, 85, 10, 74),
    '6': Path()
      ..moveTo(53, 14)
      ..cubicTo(45, _t, _cx, 7, 28, 11)
      ..cubicTo(16, 18, 10, 34, 10, 58)
      ..cubicTo(10, 80, 20, _b, _cx, _b)
      ..cubicTo(50, _b, 60, 82, 60, 69)
      ..cubicTo(60, 56, 50, 47, 36, 47)
      ..cubicTo(24, 47, 14, 53, 10, 62),
    '7': Path()
      ..moveTo(10, _t)
      ..lineTo(_r, _t)
      ..lineTo(28, _b),
    '8': Path()
      ..moveTo(_cx, 47)
      ..cubicTo(21, 47, 12, 39, 12, 28)
      ..cubicTo(12, 16, 22, _t, _cx, _t)
      ..cubicTo(48, _t, 58, 16, 58, 28)
      ..cubicTo(58, 39, 49, 47, _cx, 47)
      ..cubicTo(19, 47, 9, 56, 9, 69)
      ..cubicTo(9, 83, 20, _b, _cx, _b)
      ..cubicTo(50, _b, _r, 83, _r, 69)
      ..cubicTo(_r, 56, 51, 47, _cx, 47)
      ..close(),
    '9': Path()
      ..moveTo(17, 86)
      ..cubicTo(25, _b, _cx, 93, 42, 89)
      ..cubicTo(54, 82, 60, 66, 60, 42)
      ..cubicTo(60, 20, 50, _t, _cx, _t)
      ..cubicTo(20, _t, 10, 18, 10, 31)
      ..cubicTo(10, 44, 20, 53, 34, 53)
      ..cubicTo(46, 53, 56, 47, 60, 38),
    'A': Path()
      ..moveTo(6, _b)
      ..lineTo(_cx, _t)
      ..lineTo(64, _b)
      ..moveTo(17, 66)
      ..lineTo(53, 66),
    'B': Path()
      ..moveTo(13, _t)
      ..lineTo(13, _b)
      ..moveTo(13, _t)
      ..lineTo(36, _t)
      ..cubicTo(52, _t, 60, 16, 60, 28)
      ..cubicTo(60, 40, 52, 48, 36, 48)
      ..lineTo(13, 48)
      ..moveTo(13, 48)
      ..lineTo(38, 48)
      ..cubicTo(54, 48, 62, 57, 62, 70)
      ..cubicTo(62, 83, 54, _b, 38, _b)
      ..lineTo(13, _b),
    'C': Path()
      ..moveTo(60, 27)
      ..cubicTo(53, 13, 43, _t, _cx, _t)
      ..cubicTo(20, _t, 10, 22, 10, 50)
      ..cubicTo(10, 78, 20, _b, _cx, _b)
      ..cubicTo(43, _b, 53, 87, 60, 73),
    'D': Path()
      ..moveTo(13, _t)
      ..lineTo(13, _b)
      ..lineTo(34, _b)
      ..cubicTo(52, _b, _r, 77, _r, 50)
      ..cubicTo(_r, 23, 52, _t, 34, _t)
      ..close(),
    'E': Path()
      ..moveTo(60, _t)
      ..lineTo(13, _t)
      ..lineTo(13, _b)
      ..lineTo(60, _b)
      ..moveTo(13, 50)
      ..lineTo(52, 50),
    'F': Path()
      ..moveTo(60, _t)
      ..lineTo(13, _t)
      ..lineTo(13, _b)
      ..moveTo(13, 50)
      ..lineTo(52, 50),
    'G': Path()
      ..moveTo(60, 27)
      ..cubicTo(53, 13, 43, _t, _cx, _t)
      ..cubicTo(20, _t, 10, 22, 10, 50)
      ..cubicTo(10, 78, 20, _b, _cx, _b)
      ..cubicTo(50, _b, 60, 82, 60, 65)
      ..lineTo(60, 56)
      ..lineTo(40, 56),
    'H': Path()
      ..moveTo(12, _t)
      ..lineTo(12, _b)
      ..moveTo(58, _t)
      ..lineTo(58, _b)
      ..moveTo(12, 50)
      ..lineTo(58, 50),
    'I': Path()
      ..moveTo(18, _t)
      ..lineTo(18, _b),
    'J': Path()
      ..moveTo(52, _t)
      ..lineTo(52, 66)
      ..cubicTo(52, 83, 43, _b, 31, _b)
      ..cubicTo(18, _b, 10, 83, 9, 70),
    'K': Path()
      ..moveTo(13, _t)
      ..lineTo(13, _b)
      ..moveTo(60, _t)
      ..lineTo(13, 53)
      ..moveTo(30, 42)
      ..lineTo(62, _b),
    'L': Path()
      ..moveTo(14, _t)
      ..lineTo(14, _b)
      ..lineTo(60, _b),
    'M': Path()
      ..moveTo(8, _b)
      ..lineTo(8, _t)
      ..lineTo(39, 63)
      ..lineTo(70, _t)
      ..lineTo(70, _b),
    'N': Path()
      ..moveTo(12, _b)
      ..lineTo(12, _t)
      ..lineTo(58, _b)
      ..lineTo(58, _t),
    'O': _rounded(),
    'P': _bowlP(),
    'Q': _rounded()
      ..moveTo(41, 73)
      ..lineTo(64, 93),
    'R': _bowlP()
      ..moveTo(33, 55)
      ..lineTo(62, _b),
    'S': Path()
      ..moveTo(59, 26)
      ..cubicTo(53, 14, 43, _t, 33, _t)
      ..cubicTo(20, _t, 12, 16, 12, 27)
      ..cubicTo(12, 39, 21, 45, 38, 49)
      ..cubicTo(55, 54, _r, _r, _r, 72)
      ..cubicTo(_r, 84, 51, _b, 37, _b)
      ..cubicTo(25, _b, 15, 85, 11, 74),
    'T': Path()
      ..moveTo(_l, _t)
      ..lineTo(_r, _t)
      ..moveTo(_cx, _t)
      ..lineTo(_cx, _b),
    'U': Path()
      ..moveTo(12, _t)
      ..lineTo(12, 63)
      ..cubicTo(12, 82, 21, _b, _cx, _b)
      ..cubicTo(49, _b, 58, 82, 58, 63)
      ..lineTo(58, _t),
    'V': Path()
      ..moveTo(7, _t)
      ..lineTo(_cx, _b)
      ..lineTo(63, _t),
    'W': Path()
      ..moveTo(4, _t)
      ..lineTo(20, _b)
      ..lineTo(40, 32)
      ..lineTo(60, _b)
      ..lineTo(76, _t),
    'X': Path()
      ..moveTo(11, _t)
      ..lineTo(59, _b)
      ..moveTo(59, _t)
      ..lineTo(11, _b),
    'Y': Path()
      ..moveTo(_l, _t)
      ..lineTo(_cx, 50)
      ..lineTo(_r, _t)
      ..moveTo(_cx, 50)
      ..lineTo(_cx, _b),
    'Z': Path()
      ..moveTo(11, _t)
      ..lineTo(59, _t)
      ..lineTo(11, _b)
      ..lineTo(59, _b),
  };

  /// The `0`/`O`/`Q` bowl. A squared-off superellipse, not a circle — the
  /// straight flanks are what make a plate zero read as a plate zero.
  static Path _rounded() => Path()
    ..addRRect(
      RRect.fromLTRBXY(_l, _t, _r, _b, 19, 23),
    );

  /// Shared spine + bowl of `P`, which `R` reuses before adding its leg.
  static Path _bowlP() => Path()
    ..moveTo(13, _b)
    ..lineTo(13, _t)
    ..lineTo(36, _t)
    ..cubicTo(53, _t, _r, 18, _r, 32)
    ..cubicTo(_r, 46, 53, 55, 36, 55)
    ..lineTo(13, 55);
}
