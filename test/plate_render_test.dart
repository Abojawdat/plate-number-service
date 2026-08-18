// Visual harness: renders every plate variant to PNG files so they can be
// eyeballed without booting a device or a simulator.
//
//   flutter test test/plate_render_test.dart
//
// Writes to ./render by default. Override with PLATE_RENDER_OUT.
// Point PLATE_RENDER_FONT at an Arabic .ttf to make the legacy blank and the
// flag's takbir render as real glyphs — the headless test engine ships no
// Arabic font, so without it they come out as empty boxes. The modern formats
// are pure vector and need no font at all.
//
// This is not an assertion test. It never fails on appearance; it just writes
// files for you to look at.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_iraqi_plate_package/number_iraqi_plate_package.dart';

String get _outDir => Platform.environment['PLATE_RENDER_OUT'] ?? 'render';

/// Output scale. Kept at 1 because `flutter test` rasterises on the CPU with no
/// GPU behind it, and the Gaussian blur in the plate's emboss is the single
/// most expensive thing in the painter. At 2x the multi-plate sheets take
/// minutes; at 1x they take seconds. Raise it for a one-off hero shot.
double get _pixelRatio =>
    double.tryParse(Platform.environment['PLATE_RENDER_SCALE'] ?? '') ?? 1;

Future<void> _shoot(WidgetTester tester, String name, Widget child) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: Center(child: RepaintBoundary(key: key, child: child)),
      ),
    ),
  );
  await tester.pumpAndSettle();
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: _pixelRatio);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  Directory(_outDir).createSync(recursive: true);
  File('$_outDir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  // ignore: avoid_print
  print('wrote $_outDir/$name.png');
}

Future<void> _loadFont() async {
  final path = Platform.environment['PLATE_RENDER_FONT'];
  if (path == null || !File(path).existsSync()) return;
  final loader = FontLoader('Almarai')
    ..addFont(File(path).readAsBytes().then((b) => ByteData.view(b.buffer)));
  await loader.load();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFont();
  });

  testWidgets(timeout: const Timeout(Duration(minutes: 4)), '01 front and back', (tester) async {
    tester.view.physicalSize = const Size(2600, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _shoot(
      tester,
      '01_front_and_back',
      Container(
        color: const Color(0xFF2B3242),
        padding: const EdgeInsets.all(36),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IraqiLicensePlate(plate: IraqiPlate.reference, width: 820),
            SizedBox(height: 30),
            // the concave, unpainted reverse
            IraqiLicensePlate(
              plate: IraqiPlate.reference,
              width: 620,
              face: PlateFace.back,
            ),
          ],
        ),
      ),
    );
  });

  testWidgets(timeout: const Timeout(Duration(minutes: 4)), '02 every category', (tester) async {
    tester.view.physicalSize = const Size(2200, 4200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _shoot(
      tester,
      '02_categories',
      Container(
        color: const Color(0xFFEBEEF5),
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final category in PlateCategory.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: IraqiLicensePlate(
                  plate: IraqiPlate.reference.copyWith(category: category),
                  width: 300,
                ),
              ),
          ],
        ),
      ),
    );
  });

  testWidgets(timeout: const Timeout(Duration(minutes: 4)), '03 every format', (tester) async {
    tester.view.physicalSize = const Size(2200, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _shoot(
      tester,
      '03_formats',
      Container(
        color: const Color(0xFFEBEEF5),
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // car
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: IraqiLicensePlate(
                plate: IraqiPlate.reference,
                width: 340,
              ),
            ),
            // European blank
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: IraqiLicensePlate(
                plate: IraqiPlate.reference.copyWith(
                  format: PlateFormat.modernLong,
                ),
                width: 500,
              ),
            ),
            // motorcycle
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: IraqiLicensePlate(
                plate: IraqiPlate.reference.copyWith(
                  format: PlateFormat.motorcycle,
                ),
                width: 250,
              ),
            ),
            // Kurdistan Region — the band becomes KR
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: IraqiLicensePlate(
                plate: IraqiPlate.reference.copyWith(
                  governorate: IraqGovernorate.erbil,
                  letter: 'B',
                  serial: '4821',
                ),
                width: 340,
              ),
            ),
            // pre-2024 Arabic blank
            IraqiLicensePlate(
              plate: IraqiPlate.reference.copyWith(
                format: PlateFormat.legacy,
                governorate: IraqGovernorate.diyala,
                serial: '37809',
              ),
              width: 340,
            ),
          ],
        ),
      ),
    );
  });

  testWidgets(timeout: const Timeout(Duration(minutes: 4)), '04 size ladder', (tester) async {
    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _shoot(
      tester,
      '04_sizes',
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(22),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IraqiLicensePlate(plate: IraqiPlate.reference, width: 80),
            SizedBox(height: 12),
            IraqiLicensePlate(plate: IraqiPlate.reference, width: 120),
            SizedBox(height: 12),
            IraqiLicensePlate(plate: IraqiPlate.reference, width: 170),
            SizedBox(height: 12),
            IraqiLicensePlate(plate: IraqiPlate.reference, width: 250),
          ],
        ),
      ),
    );
  });

  testWidgets(timeout: const Timeout(Duration(minutes: 4)), '05 typeface', (tester) async {
    tester.view.physicalSize = const Size(2400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _shoot(
      tester,
      '05_typeface',
      const SizedBox(
        width: 1020,
        height: 480,
        child: CustomPaint(painter: _GlyphSheetPainter()),
      ),
    );
  });
}

/// Draws the whole vector face on a grid, with each glyph's advance box in red
/// so spacing problems are obvious.
class _GlyphSheetPainter extends CustomPainter {
  const _GlyphSheetPainter();

  static const _rows = ['0123456789', 'ABCDEFGHIJ', 'KLMNOPQRST', 'UVWXYZ'];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    const scale = 0.9;
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = PlateTypeface.stroke * scale
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.round
      ..strokeMiterLimit = 2
      ..color = const Color(0xFF101214)
      ..isAntiAlias = true;
    final box = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x33FF0000);

    var y = 10.0;
    for (final row in _rows) {
      var x = 12.0;
      for (final char in row.split('')) {
        final advance = PlateTypeface.advanceOf(char) * scale;
        canvas.drawRect(
          Rect.fromLTWH(x, y, advance, PlateTypeface.cap * scale),
          box,
        );
        canvas.drawPath(
          PlateTypeface.glyph(char)!.transform(
            (Matrix4.identity()
                  ..translateByDouble(x, y, 0, 1)
                  ..scaleByDouble(scale, scale, 1, 1))
                .storage,
          ),
          ink,
        );
        x += advance + 8;
      }
      y += PlateTypeface.cap * scale + 16;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
