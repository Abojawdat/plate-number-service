// Frame renderer for the spinning-plate animation.
//
// Renders ONE frame of the turn and exits, because a `flutter test` process
// wedges at 0% CPU on its second call to RenderRepaintBoundary.toImage — see
// tool/render_plates.dart. The frame index comes from the environment:
//
//   PLATE_SPIN_FRAME=7 flutter test tool/render_spin.dart
//
// Writes raw RGBA to render/.frames/. Use tool/render_spin.sh, which drives
// every frame and then calls tool/assemble_gif.dart to build the GIF.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iraqi_license_plate/iraqi_license_plate.dart';

const double _width = 300;

/// Total frames in a full revolution. 24 is 15° a frame — smooth enough to
/// read as motion, few enough that 24 process launches stay bearable.
const int totalFrames = 24;

const String framesDir = 'render/.frames';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final path = Platform.environment['PLATE_RENDER_FONT'];
    if (path != null && File(path).existsSync()) {
      final loader = FontLoader(
        'Almarai',
      )..addFont(File(path).readAsBytes().then((b) => ByteData.view(b.buffer)));
      await loader.load();
    }
  });

  testWidgets('frame', timeout: Timeout.none, (tester) async {
    final index =
        int.tryParse(Platform.environment['PLATE_SPIN_FRAME'] ?? '0') ?? 0;
    final angle = index / totalFrames * 2 * math.pi;

    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1;

    final key = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(),
          //! The background belongs INSIDE the boundary. Captured from
          //! outside it, the frame comes back transparent where the plate is
          //! not, and GIF has no alpha to store it in — every empty pixel
          //! lands on black and the plate's soft shadow fringes against it.
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: ColoredBox(
                color: const Color(0xFF2B3242),
                child: SizedBox(
                  width: 420,
                  height: 250,
                  child: Center(child: _SpunPlate(angle: angle)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final width = image.width;
    final height = image.height;
    image.dispose();

    Directory(framesDir).createSync(recursive: true);
    final name = index.toString().padLeft(2, '0');
    File('$framesDir/$name.rgba').writeAsBytesSync(data!.buffer.asUint8List());
    // Dimensions travel beside the pixels so the assembler needs no Flutter.
    File('$framesDir/$name.dim').writeAsStringSync('$width $height');
    stdout.writeln('frame $name  ${width}x$height');

    exit(0);
  });
}

/// The plate at one angle of its turn, matching what `PlateViewer3D` shows:
/// the front until the blank passes edge-on, then the stamped reverse.
class _SpunPlate extends StatelessWidget {
  const _SpunPlate({required this.angle});

  final double angle;

  /// Tilted slightly so the rotation reads as three-dimensional rather than a
  /// horizontal squash.
  static const double _tiltX = -0.18;

  @override
  Widget build(BuildContext context) {
    // The plate normal's z-component; positive means the face is toward us.
    final front = math.cos(_tiltX) * math.cos(angle) > 0;

    return Transform(
      alignment: Alignment.center,
      transform:
          Matrix4.identity()
            ..setEntry(3, 2, 0.0013)
            ..rotateX(_tiltX)
            ..rotateY(angle)
            //! The back face is drawn the right way round in its own space, so it
            //! needs flipping to stay legible once the parent has turned away.
            ..rotateY(front ? 0 : math.pi),
      child: IraqiLicensePlate(
        plate: IraqiPlate.reference,
        width: _width,
        face: front ? PlateFace.front : PlateFace.back,
      ),
    );
  }
}
