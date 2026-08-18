import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'iraqi_plate.dart';
import 'plate_typeface.dart';

/// Which side of the blank to draw.
///
/// The registration is *stamped* through the aluminium, so the back carries
/// the same characters as a mirrored, concave relief in bare metal — no paint,
/// no colour band, no printed flag. Driven by `PlateViewer3D`.
enum PlateFace { front, back }

/// A photoreal Iraqi registration plate.
///
/// Everything inside the painter is expressed in **millimetres** against the
/// real blank (335 × 155 for the car plate, 520 × 110 for the European one,
/// 200 × 125 for motorcycles) and scaled to the widget at paint time. That
/// keeps every proportion — bolt spacing, band width, cap height — traceable
/// to the physical plate instead of to a screen percentage, and means the
/// widget is correct at any size.
///
/// It is a self-scaling object: give it a [width] in logical pixels and every
/// other dimension follows. Never constrain it by height.
///
/// ```dart
/// IraqiLicensePlate(
///   plate: IraqiPlate.tryParse('11 A 70634')!,
///   width: 220,
/// )
/// ```
class IraqiLicensePlate extends StatelessWidget {
  const IraqiLicensePlate({
    required this.plate,
    this.width,
    this.showShadow = true,
    this.showSecurityPrint = true,
    this.tiltDegrees = 0,
    this.face = PlateFace.front,
    super.key,
  });

  /// Which side of the blank to draw.
  final PlateFace face;

  final IraqiPlate plate;

  /// Rendered width in logical pixels. Defaults to [defaultWidth].
  final double? width;

  /// Width used when [width] is omitted — about the size the plate wants to
  /// be inside a list row or a driver card.
  static const double defaultWidth = 220;

  /// Drop shadow beneath the plate. Turn it off when the plate sits on an
  /// already-elevated surface.
  final bool showShadow;

  /// Micro-printing, map watermarks and guilloche. Below about 90 logical
  /// pixels wide these stop resolving, so the painter skips them anyway; this
  /// flag is for callers that want a clean plate at large sizes.
  final bool showSecurityPrint;

  /// Rotation about the Y axis, in degrees, with perspective. Used by the lab
  /// screen's hero; leave at 0 for in-app use.
  final double tiltDegrees;

  @override
  Widget build(BuildContext context) {
    final spec = _PlateSpec.of(plate.format);
    final resolvedWidth = width ?? defaultWidth;
    final resolvedHeight = resolvedWidth * spec.heightMm / spec.widthMm;
    final radius = resolvedWidth * spec.cornerRadius / spec.widthMm;

    Widget rendered = SizedBox(
      width: resolvedWidth,
      height: resolvedHeight,
      child: CustomPaint(
        painter: _PlatePainter(
          plate: plate,
          spec: spec,
          showSecurityPrint: showSecurityPrint,
          face: face,
        ),
        isComplex: true,
        willChange: false,
      ),
    );

    if (showShadow) {
      rendered = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            //! two shadows: a tight contact shadow so the plate reads as
            //! sitting on the surface, and a wide soft one for the lift
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: resolvedHeight * 0.05,
              offset: Offset(0, resolvedHeight * 0.02),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: resolvedHeight * 0.26,
              offset: Offset(0, resolvedHeight * 0.11),
            ),
          ],
        ),
        child: rendered,
      );
    }

    if (tiltDegrees != 0) {
      rendered = Transform(
        alignment: Alignment.center,
        transform:
            Matrix4.identity()
              ..setEntry(3, 2, 0.0014)
              ..rotateY(tiltDegrees * math.pi / 180),
        child: rendered,
      );
    }

    //! the plate is a physical object, never mirrored by an ambient RTL layout
    return Directionality(textDirection: TextDirection.ltr, child: rendered);
  }
}

// ---------------------------------------------------------------------------
// Geometry
// ---------------------------------------------------------------------------

/// Physical layout of a plate blank. All fields are millimetres.
///
/// The numbers for [PlateFormat.modernShort] were measured off the reference
/// photograph as fractions of the plate and converted to the 335 × 155 blank,
/// which is why they are not round.
class _PlateSpec {
  const _PlateSpec({
    required this.widthMm,
    required this.heightMm,
    required this.cornerRadius,
    required this.frameInset,
    required this.frameStroke,
    required this.bandRight,
    required this.bandCap,
    required this.bandLetterYs,
    required this.flagCenter,
    required this.flagWidth,
    required this.contentLeft,
    required this.contentRight,
    required this.rows,
    required this.bolts,
    required this.boltRadius,
    required this.serialMarkX,
  });

  final double widthMm;
  final double heightMm;
  final double cornerRadius;

  /// Inset of the raised black frame line from the plate edge.
  final double frameInset;
  final double frameStroke;

  /// X of the line dividing the country band from the registration field.
  final double bandRight;

  /// Cap height of the `IRQ` / `KR` letters.
  final double bandCap;

  /// Vertical centres of the band letters, one per letter. Chosen by
  /// [_bandLetterYsFor] so a two-letter `KR` band stays balanced.
  final List<double> bandLetterYs;
  final Offset flagCenter;
  final double flagWidth;

  final double contentLeft;
  final double contentRight;

  /// Baseline boxes for the registration rows: (top, capHeight).
  final List<_Row> rows;

  final List<Offset> bolts;
  final double boltRadius;

  /// X of the vertical manufacturer serial printed near the right edge.
  final double serialMarkX;

  double get aspect => widthMm / heightMm;
  double get frameRadius => cornerRadius - frameInset * 0.5;

  static _PlateSpec of(PlateFormat format) => switch (format) {
    PlateFormat.modernShort => _short,
    PlateFormat.legacy => _short,
    PlateFormat.modernLong => _long,
    PlateFormat.motorcycle => _motorcycle,
  };

  /// 335 × 155 two-row blank — the ordinary passenger-car plate and the one in
  /// the reference photograph.
  static const _short = _PlateSpec(
    widthMm: 335,
    heightMm: 155,
    cornerRadius: 9,
    frameInset: 5,
    frameStroke: 2.4,
    bandRight: 44,
    bandCap: 15,
    bandLetterYs: [28, 51, 74],
    flagCenter: Offset(24.5, 120),
    flagWidth: 26,
    contentLeft: 74,
    contentRight: 301,
    rows: [_Row(top: 15, cap: 55), _Row(top: 82, cap: 60)],
    //! centred in the gutters either side of the registration, not crowded
    //! against the band divider (44) or the frame (327.6)
    bolts: [Offset(59, 76), Offset(313, 76)],
    boltRadius: 7,
    serialMarkX: 325,
  );

  /// 520 × 110 single-row blank — the standard European size Iraq also issues.
  static const _long = _PlateSpec(
    widthMm: 520,
    heightMm: 110,
    cornerRadius: 7,
    frameInset: 4,
    frameStroke: 2,
    bandRight: 42,
    bandCap: 13,
    bandLetterYs: [22, 45, 68],
    flagCenter: Offset(23, 90),
    flagWidth: 24,
    contentLeft: 66,
    contentRight: 492,
    rows: [_Row(top: 22, cap: 66)],
    bolts: [Offset(54, 55), Offset(504, 55)],
    boltRadius: 5.5,
    serialMarkX: 514,
  );

  /// 200 × 125 two-row blank for motorcycles.
  ///
  /// The registration scheme is identical to a car's — the blank is simply
  /// shorter and squarer. Two consequences worth knowing: the band is narrower
  /// so the `IRQ` letters and flag shrink with it, and there are no rivets,
  /// because a bike plate bolts through its corners rather than through the
  /// field. Cap heights are set so a five-digit serial fits the content box
  /// without the shrink-to-fit in [_drawGlyphRun] engaging.
  static const _motorcycle = _PlateSpec(
    widthMm: 200,
    heightMm: 125,
    cornerRadius: 7,
    frameInset: 4,
    frameStroke: 2,
    bandRight: 26,
    bandCap: 11,
    bandLetterYs: [20, 38, 56],
    flagCenter: Offset(13, 96),
    flagWidth: 17,
    contentLeft: 34,
    contentRight: 190,
    rows: [_Row(top: 12, cap: 44), _Row(top: 64, cap: 46)],
    bolts: [],
    boltRadius: 4,
    serialMarkX: 195,
  );

  /// Spreads [count] band letters over the same vertical run the three-letter
  /// `IRQ` band occupies, so `KR` does not sit lopsided.
  List<double> bandLetterYsFor(int count) {
    if (count == bandLetterYs.length) return bandLetterYs;
    final first = bandLetterYs.first;
    final last = bandLetterYs.last;
    if (count == 1) return [(first + last) / 2];
    final step = (last - first) / (count - 1);
    return List.generate(count, (i) => first + step * i);
  }
}

class _Row {
  const _Row({required this.top, required this.cap});

  final double top;
  final double cap;
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class _PlatePainter extends CustomPainter {
  _PlatePainter({
    required this.plate,
    required this.spec,
    required this.showSecurityPrint,
    this.face = PlateFace.front,
  });

  final IraqiPlate plate;
  final _PlateSpec spec;
  final bool showSecurityPrint;
  final PlateFace face;

  bool get _isBack => face == PlateFace.back;

  /// Bare aluminium of the unpainted reverse.
  static const Color _backMetal = Color(0xFFB9BEC4);

  /// Millimetres-to-pixels, set once per paint.
  late double _px;

  /// One "depth unit" for the emboss, in mm. Real characters stand about
  /// 1.2 mm proud of the sheeting.
  static const double _depth = 1.15;

  @override
  void paint(Canvas canvas, Size size) {
    _px = size.width / spec.widthMm;
    canvas.save();
    canvas.scale(_px);

    if (_isBack) {
      //! the reverse is the same stamping seen from behind, so mirror the whole
      //! coordinate system: once the viewer rotates the plate 180° the two
      //! mirrorings cancel and the relief lines up with the front exactly
      canvas.translate(spec.widthMm, 0);
      canvas.scale(-1, 1);
    }

    final plateRect = Rect.fromLTWH(0, 0, spec.widthMm, spec.heightMm);
    final outer = RRect.fromRectXY(
      plateRect,
      spec.cornerRadius,
      spec.cornerRadius,
    );

    canvas.save();
    canvas.clipRRect(outer);

    _paintField(canvas, plateRect);
    if (_isBack) {
      //! nothing is printed on the reverse — no sheeting, no band, no flag.
      //! Just rolled aluminium and the back of the stamping.
      _paintBrushing(canvas, plateRect);
    } else {
      _paintBeads(canvas, plateRect);
      if (showSecurityPrint && size.width > 90) {
        _paintSecurityPrint(canvas);
      }
      _paintBand(canvas);
    }
    _paintSpecular(canvas, plateRect);
    _paintFrame(canvas);
    _paintBandContent(canvas);
    _paintRegistration(canvas);
    _paintBolts(canvas);
    if (_isBack && size.width > 120) _paintBackStamp(canvas);
    _paintRim(canvas, outer);

    canvas.restore();
    canvas.restore();
  }

  // — surfaces ————————————————————————————————————————————————————————

  /// Aluminium under retroreflective sheeting. The gradient is derived from the
  /// category colour so a black CTS plate or a green defence plate comes out
  /// metallic too, rather than flat.
  void _paintField(Canvas canvas, Rect rect) {
    final base = _ground;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lighten(base, 0.55),
            _lighten(base, 0.12),
            _darken(base, 0.05),
            _lighten(base, 0.22),
            _darken(base, 0.13),
          ],
          stops: const [0, 0.16, 0.48, 0.78, 1],
        ).createShader(rect),
    );
  }

  /// The glass-bead layer of the reflective sheeting. Invisible individually,
  /// but it is what stops the plate reading as flat vector art.
  void _paintBeads(Canvas canvas, Rect rect) {
    final beads = _beadCache.putIfAbsent(spec.widthMm, () {
      //! fixed seed: the bead field must be identical on every rebuild
      final random = math.Random(20240601);
      return List<Offset>.generate(
        1400,
        (_) => Offset(
          random.nextDouble() * spec.widthMm,
          random.nextDouble() * spec.heightMm,
        ),
      );
    });
    final light =
        plate.category.isDarkField
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.white.withValues(alpha: 0.55);
    final dark = Colors.black.withValues(alpha: 0.05);
    canvas.drawPoints(
      ui.PointMode.points,
      beads,
      Paint()
        ..strokeWidth = 0.8
        ..strokeCap = StrokeCap.round
        ..color = light,
    );
    canvas.drawPoints(
      ui.PointMode.points,
      beads.reversed.take(500).map((o) => o.translate(0.9, 0.9)).toList(),
      Paint()
        ..strokeWidth = 0.7
        ..strokeCap = StrokeCap.round
        ..color = dark,
    );
  }

  static final Map<double, List<Offset>> _beadCache = {};

  /// The surface the relief is lit against: sheeting on the front, bare rolled
  /// aluminium on the back.
  Color get _ground => _isBack ? _backMetal : plate.category.fieldColor;

  /// Rolling marks on the unpainted reverse — fine horizontal streaks, which
  /// is what distinguishes bare aluminium from the bead-blasted front.
  void _paintBrushing(Canvas canvas, Rect rect) {
    final random = math.Random(7717);
    final paint =
        Paint()
          ..strokeWidth = 0.35
          ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 220; i++) {
      final y = random.nextDouble() * rect.height;
      final x0 = random.nextDouble() * rect.width * 0.5;
      final x1 = x0 + rect.width * (0.2 + random.nextDouble() * 0.6);
      final light = random.nextBool();
      canvas.drawLine(
        Offset(x0, y),
        Offset(math.min(x1, rect.width), y),
        paint
          ..color = (light ? Colors.white : Colors.black).withValues(
            alpha: 0.03 + random.nextDouble() * 0.05,
          ),
      );
    }
  }

  /// Die and batch marks struck into the reverse.
  void _paintBackStamp(Canvas canvas) {
    final stamp = _textPainter(
      _manufacturerStamp,
      fontSize: 6,
      color: Colors.black.withValues(alpha: 0.22),
      weight: FontWeight.w700,
      letterSpacing: 1.2,
    );
    stamp.paint(
      canvas,
      Offset(
        spec.widthMm - spec.frameInset - 10 - stamp.width,
        spec.heightMm - spec.frameInset - 10 - stamp.height,
      ),
    );
  }

  /// Micro-printing, repeated map-of-Iraq watermarks and a guilloche wave —
  /// the three security features visible on the reference plate.
  void _paintSecurityPrint(Canvas canvas) {
    final fieldRect = Rect.fromLTRB(
      spec.bandRight,
      spec.frameInset,
      spec.widthMm - spec.frameInset,
      spec.heightMm - spec.frameInset,
    );
    canvas.save();
    canvas.clipRect(fieldRect);

    final inkAlpha = plate.category.isDarkField ? 0.10 : 0.075;

    // Repeated country name, alternating Latin and Arabic, offset row to row.
    final line = _microTextPainter(inkAlpha);
    const rowStep = 12.0;
    var row = 0;
    for (var y = fieldRect.top - 4; y < fieldRect.bottom; y += rowStep) {
      final offset = (row.isEven ? 0.0 : -line.width / 3);
      for (
        var x = fieldRect.left + offset;
        x < fieldRect.right;
        x += line.width
      ) {
        line.paint(canvas, Offset(x, y));
      }
      row++;
    }

    // Repeated map of Iraq, ghosted into the sheeting in neutral grey.
    final mapGrey =
        plate.category.isDarkField
            ? const Color(0xFFB9C0C7)
            : const Color(0xFF6E767F);
    final mapFill =
        Paint()
          ..color = mapGrey.withValues(alpha: inkAlpha * 2.2)
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;
    final mapEdge =
        Paint()
          ..color = mapGrey.withValues(alpha: inkAlpha * 3.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.45
          ..strokeJoin = StrokeJoin.round
          ..isAntiAlias = true;
    const mapSize = 18.0;
    for (var y = fieldRect.top + 5; y < fieldRect.bottom; y += 46) {
      for (var x = fieldRect.left + 10; x < fieldRect.right; x += 62) {
        final map = _iraqPath(Rect.fromLTWH(x, y, mapSize, mapSize));
        canvas.drawPath(map, mapFill);
        canvas.drawPath(map, mapEdge);
      }
    }

    // Guilloche across the lower third.
    final wave =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.55
          ..color = (plate.category.isDarkField ? Colors.white : Colors.black)
              .withValues(alpha: inkAlpha);
    for (var i = 0; i < 3; i++) {
      final path = Path();
      final baseY = fieldRect.bottom - 12 + i * 3.4;
      for (var x = fieldRect.left; x <= fieldRect.right; x += 3) {
        final y = baseY + math.sin((x / 26) + i * 0.8) * 3.2;
        if (x == fieldRect.left) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, wave);
    }

    // Manufacturer serial, printed vertically by the right edge.
    canvas.save();
    canvas.translate(spec.serialMarkX, spec.heightMm * 0.5);
    canvas.rotate(-math.pi / 2);
    final stamp = _textPainter(
      _manufacturerStamp,
      fontSize: 5,
      color: (plate.category.isDarkField ? Colors.white : Colors.black)
          .withValues(alpha: 0.20),
      weight: FontWeight.w600,
      letterSpacing: 0.6,
    );
    stamp.paint(canvas, Offset(-stamp.width / 2, -stamp.height / 2));
    canvas.restore();

    canvas.restore();
  }

  /// Deterministic per-plate die/batch stamp, in the style of the `M07 S8889`
  /// on the reference plate. Stable for a given registration so the plate does
  /// not "shimmer" between rebuilds.
  String get _manufacturerStamp {
    final seed = plate.formatted.hashCode.abs();
    final die = (seed % 90 + 10).toString();
    final batch = (seed ~/ 90 % 9000 + 1000).toString();
    return 'M$die S$batch';
  }

  TextPainter _microTextPainter(double alpha) {
    return _textPainter(
      '  REPUBLIC OF IRAQ  جمهورية العراق  كۆماری عێراق',
      fontSize: 4.2,
      color: (plate.category.isDarkField ? Colors.white : Colors.black)
          .withValues(alpha: alpha),
      weight: FontWeight.w500,
      letterSpacing: 0.2,
    );
  }

  /// The coloured category band down the left edge. Private plates have no
  /// tint — bare sheeting, exactly as on the reference photograph.
  ///
  /// The tint is confined to the area *inside* the raised black frame: on a
  /// real plate the colour is printed on the sheeting, and the sheeting stops
  /// at the frame. Letting it run to the plate edge merges the band with the
  /// rolled rim and destroys the sense of a border.
  void _paintBand(Canvas canvas) {
    if (!_bandIsTinted) return;
    final rect = Rect.fromLTRB(0, 0, spec.bandRight, spec.heightMm);
    final base = plate.category.bandColor;
    canvas.save();
    canvas.clipRRect(_frameInnerRRect);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_lighten(base, 0.24), base, _darken(base, 0.14)],
          stops: const [0, 0.45, 1],
        ).createShader(rect),
    );
    canvas.restore();
  }

  /// The area enclosed by the raised frame, taken to the centre of the frame
  /// stroke so nothing shows through as a hairline along the inside edge.
  RRect get _frameInnerRRect {
    final inset = spec.frameInset + spec.frameStroke * 0.5;
    return RRect.fromRectXY(
      Rect.fromLTRB(inset, inset, spec.widthMm - inset, spec.heightMm - inset),
      spec.frameRadius,
      spec.frameRadius,
    );
  }

  bool get _bandIsTinted =>
      plate.category.bandColor != PlateCategory.private.bandColor;

  /// Broad diagonal highlight — the reason the plate looks like it is being
  /// lit rather than printed.
  void _paintSpecular(Canvas canvas, Rect rect) {
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: const Alignment(-1, -1.4),
          end: const Alignment(1, 1.4),
          colors: [
            Colors.white.withValues(alpha: 0.34),
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.16),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0, 0.34, 0.56, 0.9],
        ).createShader(rect),
    );
  }

  // — relief ——————————————————————————————————————————————————————————

  /// The raised black frame line, plus the divider between band and field.
  void _paintFrame(Canvas canvas) {
    final inset = spec.frameInset + spec.frameStroke / 2;
    final frame =
        Path()..addRRect(
          RRect.fromRectXY(
            Rect.fromLTRB(
              inset,
              inset,
              spec.widthMm - inset,
              spec.heightMm - inset,
            ),
            spec.frameRadius,
            spec.frameRadius,
          ),
        );
    _emboss(canvas, frame, spec.frameStroke, _frameInk, depthScale: 0.55);

    final divider =
        Path()
          ..moveTo(spec.bandRight, spec.frameInset + spec.frameStroke)
          ..lineTo(
            spec.bandRight,
            spec.heightMm - spec.frameInset - spec.frameStroke,
          );
    _emboss(canvas, divider, spec.frameStroke, _frameInk, depthScale: 0.55);
  }

  Color get _frameInk {
    if (_isBack) return _darken(_backMetal, 0.10);
    return plate.category.isDarkField
        ? const Color(0xFFE9ECEE)
        : const Color(0xFF14171A);
  }

  /// `IRQ` (federal) or `KR` (Kurdistan Region), stacked, plus the flag tile.
  void _paintBandContent(Canvas canvas) {
    final text = plate.format == PlateFormat.legacy ? 'IRAQ' : plate.bandText;
    final letters = text.split('');
    final ys = spec.bandLetterYsFor(letters.length);
    final scale = spec.bandCap / PlateTypeface.cap;
    final ink =
        _isBack
            ? _darken(_backMetal, 0.10)
            : (_bandIsTinted
                ? plate.category.bandInk
                : plate.category.fieldInk);

    for (var i = 0; i < letters.length; i++) {
      final glyph = PlateTypeface.glyph(letters[i]);
      if (glyph == null) continue;
      final advance = PlateTypeface.advanceOf(letters[i]) * scale;
      final path = glyph.transform(
        (Matrix4.identity()
              ..translateByDouble(
                spec.bandRight / 2 - advance / 2,
                ys[i] - spec.bandCap / 2,
                0,
                1,
              )
              ..scaleByDouble(scale, scale, 1, 1))
            .storage,
      );
      _emboss(
        canvas,
        path,
        PlateTypeface.stroke * scale,
        ink,
        depthScale: 0.5,
        surface: (_bandIsTinted && !_isBack) ? plate.category.bandColor : null,
      );
    }

    //! the flag is printed on the sheeting, so it simply is not there on the back
    if (!_isBack) _paintFlag(canvas);
  }

  /// The Iraqi flag tile at the foot of the band.
  void _paintFlag(Canvas canvas) {
    final height = spec.flagWidth * 2 / 3;
    final rect = Rect.fromCenter(
      center: spec.flagCenter,
      width: spec.flagWidth,
      height: height,
    );
    final rrect = RRect.fromRectXY(rect, 1.2, 1.2);

    canvas.drawRRect(
      rrect.shift(Offset(_depth * 0.5, _depth * 0.6)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.9),
    );

    canvas.save();
    canvas.clipRRect(rrect);
    final third = height / 3;
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top, rect.width, third),
      Paint()..color = const Color(0xFFCE1126),
    );
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top + third, rect.width, third),
      Paint()..color = const Color(0xFFF5F5F5),
    );
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top + third * 2, rect.width, third),
      Paint()..color = const Color(0xFF14171A),
    );
    //! takbir in the white band — at this size it is a green mark, which is
    //! exactly how it reads on a real plate at arm's length
    final takbir = _textPainter(
      'الله أكبر',
      fontSize: third * 0.82,
      color: const Color(0xFF007A3D),
      weight: FontWeight.w800,
      direction: TextDirection.rtl,
      family: 'Almarai',
    );
    takbir.paint(
      canvas,
      Offset(
        rect.center.dx - takbir.width / 2,
        rect.top + third + (third - takbir.height) / 2,
      ),
    );
    canvas.restore();

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = Colors.black.withValues(alpha: 0.35),
    );
  }

  /// The registration itself: governorate code + series letter on the top row,
  /// serial beneath. The long blank puts all of it on one line.
  void _paintRegistration(Canvas canvas) {
    if (plate.format == PlateFormat.legacy) {
      _paintLegacyRegistration(canvas);
      return;
    }

    if (spec.rows.length == 1) {
      final row = spec.rows.first;
      _drawGlyphRun(
        canvas,
        '${plate.governorate.codeText}${plate.letter}${plate.serial}',
        cap: row.cap,
        top: row.top,
        left: spec.contentLeft,
        right: spec.contentRight,
        align: _RunAlign.center,
        tracking: 0.10,
        //! wider gaps around the series letter keep the three fields legible
        groupAfter: {2: 0.55, 3: 0.55},
      );
      return;
    }

    final top = spec.rows[0];
    final bottom = spec.rows[1];

    _drawGlyphRun(
      canvas,
      plate.governorate.codeText,
      cap: top.cap,
      top: top.top,
      left: spec.contentLeft,
      right: spec.contentRight,
      align: _RunAlign.left,
      tracking: 0.06,
    );
    _drawGlyphRun(
      canvas,
      plate.letter,
      cap: top.cap,
      top: top.top,
      left: spec.contentLeft,
      //! the letter sits inboard of the serial's right edge on the real plate
      right: spec.contentRight - (spec.contentRight - spec.contentLeft) * 0.13,
      align: _RunAlign.right,
      tracking: 0,
    );
    _drawGlyphRun(
      canvas,
      plate.serial,
      cap: bottom.cap,
      top: bottom.top,
      left: spec.contentLeft,
      right: spec.contentRight,
      align: _RunAlign.center,
      tracking: 0.06,
    );
  }

  /// Pre-2024 plate: Eastern-Arabic serial with an Arabic series letter, and
  /// the category word and governorate name spelled out along the bottom.
  void _paintLegacyRegistration(Canvas canvas) {
    final ink = _isBack ? _darken(_backMetal, 0.10) : plate.category.fieldInk;
    const rowTop = 22.0;
    const rowCap = 62.0;

    final serial = _textPainter(
      plate.serialArabicDigits,
      fontSize: rowCap,
      color: ink,
      weight: FontWeight.w800,
      family: 'Almarai',
      letterSpacing: 2,
    );
    final letter = _textPainter(
      plate.letterArabic,
      fontSize: rowCap * 0.86,
      color: ink,
      weight: FontWeight.w800,
      family: 'Almarai',
      direction: TextDirection.rtl,
    );

    _embossText(canvas, letter, Offset(spec.contentLeft - 6, rowTop), ink);
    _embossText(
      canvas,
      serial,
      Offset(spec.contentRight - serial.width, rowTop),
      ink,
    );

    // Bottom strip: category on the left, governorate on the right.
    final category = _textPainter(
      plate.category.arabicLabel,
      fontSize: 17,
      color: ink,
      weight: FontWeight.w700,
      family: 'Almarai',
      direction: TextDirection.rtl,
    );
    final governorate = _textPainter(
      plate.governorate.arabicName,
      fontSize: 17,
      color: ink,
      weight: FontWeight.w700,
      family: 'Almarai',
      direction: TextDirection.rtl,
    );
    const stripY = 118.0;
    _embossText(
      canvas,
      category,
      Offset(spec.contentLeft - 6, stripY),
      ink,
      depthScale: 0.45,
    );
    _embossText(
      canvas,
      governorate,
      Offset(spec.contentRight - governorate.width, stripY),
      ink,
      depthScale: 0.45,
    );
  }

  /// Lays out [text] as a single stroked path and embosses it in one pass.
  void _drawGlyphRun(
    Canvas canvas,
    String text, {
    required double cap,
    required double top,
    required double left,
    required double right,
    required _RunAlign align,
    required double tracking,
    Map<int, double> groupAfter = const {},
  }) {
    if (text.isEmpty) return;
    final scale = cap / PlateTypeface.cap;
    final trackingMm = tracking * cap;

    // Advance table, including any extra gaps between logical groups.
    final chars = text.split('');
    final gaps = <double>[];
    var runWidth = 0.0;
    for (var i = 0; i < chars.length; i++) {
      runWidth += PlateTypeface.advanceOf(chars[i]) * scale;
      if (i < chars.length - 1) {
        final gap = trackingMm + (groupAfter[i + 1] ?? 0) * cap;
        gaps.add(gap);
        runWidth += gap;
      }
    }

    // Shrink to fit rather than overflow the field — a nine-digit serial is
    // invalid, but a wrong plate must never bleed over the frame.
    final available = right - left;
    final fit = runWidth > available ? available / runWidth : 1.0;
    final effectiveScale = scale * fit;
    final effectiveWidth = runWidth * fit;

    final startX = switch (align) {
      _RunAlign.left => left,
      _RunAlign.right => right - effectiveWidth,
      _RunAlign.center => left + (available - effectiveWidth) / 2,
    };
    //! keep the row optically centred on its box when it was shrunk
    final startY = top + (cap - cap * fit) / 2;

    final combined = Path();
    var x = startX;
    for (var i = 0; i < chars.length; i++) {
      final glyph = PlateTypeface.glyph(chars[i]);
      final advance = PlateTypeface.advanceOf(chars[i]) * effectiveScale;
      if (glyph != null) {
        combined.addPath(
          glyph.transform(
            (Matrix4.identity()
                  ..translateByDouble(x, startY, 0, 1)
                  ..scaleByDouble(effectiveScale, effectiveScale, 1, 1))
                .storage,
          ),
          Offset.zero,
        );
      }
      x += advance;
      if (i < gaps.length) x += gaps[i] * fit;
    }

    _emboss(
      canvas,
      combined,
      PlateTypeface.stroke * effectiveScale,
      _isBack ? _darken(_backMetal, 0.10) : plate.category.fieldInk,
    );
  }

  /// Four-layer relief: contact shadow, extruded wall, lit top edge, painted
  /// face. Drawing the *same* stroked path at sub-millimetre offsets is what
  /// sells the stamping — a flat fill plus a drop shadow does not.
  void _emboss(
    Canvas canvas,
    Path path,
    double strokeWidth,
    Color face, {
    double depthScale = 1,
    Color? surface,
  }) {
    final d = _depth * depthScale;
    final ground = surface ?? _ground;

    Paint stroked() =>
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt
          ..strokeJoin = StrokeJoin.round
          ..strokeMiterLimit = 2
          ..isAntiAlias = true;

    //! On the reverse the relief is the same stamping seen from behind, so it
    //! is concave: every offset flips sign and the lit wall swaps to the
    //! bottom-right. Same four layers, mirrored lighting.
    final sign = _isBack ? -1.0 : 1.0;

    // 1. shadow the character casts onto the surface (an ambient occlusion
    //    pool inside the recess, on the back)
    canvas.drawPath(
      path.shift(Offset(d * 1.45 * sign, d * 1.85 * sign)),
      stroked()
        ..color = Colors.black.withValues(alpha: _isBack ? 0.20 : 0.30)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, d * 1.3),
    );
    // 2. the wall turned away from the light
    canvas.drawPath(
      path.shift(Offset(d * 0.85 * sign, d * 1.0 * sign)),
      stroked()..color = _darken(ground, 0.42),
    );
    // 3. the wall catching the light
    canvas.drawPath(
      path.shift(Offset(-d * 0.5 * sign, -d * 0.62 * sign)),
      stroked()..color = _lighten(ground, 0.75),
    );
    // 4. the painted face, very slightly graded top to bottom
    final bounds = path.getBounds().inflate(strokeWidth);
    canvas.drawPath(
      path,
      stroked()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_lighten(face, 0.16), face, _darken(face, 0.25)],
          stops: const [0, 0.45, 1],
        ).createShader(bounds),
    );
  }

  /// [_emboss] for text runs, which cannot share one path because the colour
  /// is baked into the [TextPainter].
  void _embossText(
    Canvas canvas,
    TextPainter face,
    Offset offset,
    Color ink, {
    double depthScale = 1,
  }) {
    final d = _depth * depthScale;
    final ground = _ground;
    final sign = _isBack ? -1.0 : 1.0;
    face
      ..text = TextSpan(
        text: (face.text as TextSpan).text,
        style: (face.text as TextSpan).style!.copyWith(
          color: _darken(ground, 0.42),
        ),
      )
      ..layout();
    face.paint(canvas, offset + Offset(d * 0.85 * sign, d * 1.0 * sign));
    face
      ..text = TextSpan(
        text: (face.text as TextSpan).text,
        style: (face.text as TextSpan).style!.copyWith(
          color: _lighten(ground, 0.75),
        ),
      )
      ..layout();
    face.paint(canvas, offset + Offset(-d * 0.5 * sign, -d * 0.62 * sign));
    face
      ..text = TextSpan(
        text: (face.text as TextSpan).text,
        style: (face.text as TextSpan).style!.copyWith(color: ink),
      )
      ..layout();
    face.paint(canvas, offset);
  }

  /// Mounting rivets. Two on the short blank, at the outer edges of the field.
  void _paintBolts(Canvas canvas) {
    if (_isBack) {
      //! from behind you see the hole, not the rivet head
      for (final centre in spec.bolts) {
        canvas.drawCircle(
          centre,
          spec.boltRadius - 1.6,
          Paint()..color = const Color(0xFF35393E),
        );
        canvas.drawCircle(
          centre,
          spec.boltRadius - 1.6,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = _lighten(_backMetal, 0.6),
        );
      }
      return;
    }
    for (final centre in spec.bolts) {
      final rect = Rect.fromCircle(center: centre, radius: spec.boltRadius);
      // recessed ring
      canvas.drawCircle(
        centre,
        spec.boltRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..color = Colors.black.withValues(alpha: 0.28),
      );
      // washer
      canvas.drawCircle(
        centre,
        spec.boltRadius - 0.4,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.45, -0.5),
            colors: const [
              Color(0xFFFDFDFD),
              Color(0xFFD3D8DC),
              Color(0xFF8F969D),
            ],
            stops: const [0, 0.55, 1],
          ).createShader(rect),
      );
      // inner shadow under the top lip
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: spec.boltRadius - 1.2),
        math.pi * 0.9,
        math.pi * 1.2,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = Colors.black.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.7),
      );
    }
  }

  /// Rolled edge of the blank: a bright top lip and a dark bottom one.
  void _paintRim(Canvas canvas, RRect outer) {
    canvas.drawRRect(
      outer.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.85),
            Colors.white.withValues(alpha: 0.05),
            Colors.black.withValues(alpha: 0.30),
          ],
          stops: const [0, 0.5, 1],
        ).createShader(outer.outerRect),
    );
  }

  // — helpers —————————————————————————————————————————————————————————

  TextPainter _textPainter(
    String text, {
    required double fontSize,
    required Color color,
    FontWeight weight = FontWeight.w400,
    double letterSpacing = 0,
    TextDirection direction = TextDirection.ltr,
    String? family,
  }) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: weight,
          letterSpacing: letterSpacing,
          fontFamily: family,
          height: 1,
        ),
      ),
      textDirection: direction,
      maxLines: 1,
    )..layout();
  }

  /// Silhouette of Iraq, normalised into [box].
  ///
  /// Traced clockwise from the Syria/Turkey corner in the north-west. The
  /// vertices are the country's real border turning-points projected from
  /// lon/lat — `x = (lon - 38.80) / 9.80`, `y = (37.38 - lat) / 8.28` — which
  /// works as an equirectangular projection here because Iraq's bounding box is
  /// very nearly square on the ground (about 910 × 920 km).
  ///
  /// Recognisable features, in order: the Turkish border across the top, the
  /// Penjwen bulge into Iran, the tail down the Shatt al-Arab to Faw, the
  /// Kuwait notch, the long straight Saudi border running north-west, the beak
  /// pointing at Jordan, and the Syrian border back up to the start.
  static Path _iraqPath(Rect box) {
    const points = <Offset>[
      Offset(36.2, 3.4), // Fishkhabur — Syria/Turkey corner
      Offset(41.8, 0.0), // Zakho, northernmost point
      Offset(52.0, 1.9),
      Offset(61.2, 4.0),
      Offset(64.3, 9.4), // Turkey/Iran tri-point
      Offset(68.9, 17.3),
      Offset(75.0, 26.9), // Penjwen — easternmost bulge
      Offset(71.9, 34.2),
      Offset(68.9, 41.4),
      Offset(73.0, 48.7),
      Offset(68.4, 52.3),
      Offset(75.5, 54.7),
      Offset(84.7, 60.1),
      Offset(88.3, 66.2),
      Offset(90.8, 73.4),
      Offset(92.9, 78.3),
      Offset(95.9, 84.9),
      Offset(100.0, 89.7), // Faw, on the Gulf
      Offset(94.4, 88.5), // Kuwait notch
      Offset(88.3, 87.9),
      Offset(79.1, 100.0), // Saudi/Kuwait tri-point, southernmost
      Offset(32.7, 75.8), // the straight Saudi border
      Offset(3.6, 63.2),
      Offset(0.0, 48.3), // Trebil — westernmost, facing Jordan
      Offset(19.4, 35.7),
      Offset(25.0, 25.7),
      Offset(25.5, 13.0),
    ];
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final p = Offset(
        box.left + points[i].dx / 100 * box.width,
        box.top + points[i].dy / 100 * box.height,
      );
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  static Color _darken(Color c, double amount) =>
      Color.lerp(c, const Color(0xFF000000), amount)!;

  static Color _lighten(Color c, double amount) =>
      Color.lerp(c, const Color(0xFFFFFFFF), amount)!;

  @override
  bool shouldRepaint(covariant _PlatePainter old) =>
      old.plate != plate ||
      old.spec != spec ||
      old.showSecurityPrint != showSecurityPrint;
}

enum _RunAlign { left, center, right }
