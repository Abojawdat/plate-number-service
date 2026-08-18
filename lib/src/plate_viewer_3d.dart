import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'iraqi_plate.dart';
import 'iraqi_license_plate.dart';

class PlateViewer3D extends StatefulWidget {
  const PlateViewer3D({
    required this.plate,
    this.width = 260,
    this.thickness,
    this.initialRotationX = -0.20,
    this.initialRotationY = -0.55,
    super.key,
  });

  final IraqiPlate plate;
  final double width;
  final double? thickness;

  final double initialRotationX;
  final double initialRotationY;

  @override
  State<PlateViewer3D> createState() => _PlateViewer3DState();
}

class _PlateViewer3DState extends State<PlateViewer3D>
    with SingleTickerProviderStateMixin {
  late double _rotX = widget.initialRotationX;
  late double _rotY = widget.initialRotationY;

  /// Radians per second, decayed by [_friction] while the spin runs.
  double _spinX = 0;
  double _spinY = 0;

  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  /// Angular velocity retained per second: a flick settles in ~1.5 s.
  static const double _friction = 0.12;

  /// Below this the spin is not worth a frame.
  static const double _restThreshold = 0.05;

  /// Layers stacked between the two faces to read as the cut edge. Eight is
  /// where the banding stops showing on a phone screen.
  static const int _slabLayers = 8;

  /// Perspective strength — the `[3][2]` entry of the projection matrix.
  static const double _perspective = 0.0013;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt =
        _lastTick == Duration.zero
            ? 1 / 60
            : (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;

    final decay = math.pow(_friction, dt).toDouble();
    setState(() {
      _rotY += _spinY * dt;
      _rotX += _spinX * dt;
      _spinY *= decay;
      _spinX *= decay;
    });

    if (_spinX.abs() < _restThreshold && _spinY.abs() < _restThreshold) {
      _stopSpin();
    }
  }

  void _stopSpin() {
    if (_ticker.isActive) _ticker.stop();
    _lastTick = Duration.zero;
    _spinX = 0;
    _spinY = 0;
  }

  void _startSpin(double vx, double vy) {
    _spinY = vx;
    _spinX = vy;
    _lastTick = Duration.zero;
    if (!_ticker.isActive) _ticker.start();
  }

  /// Eases into a settled pose. Used by the flip and the reset.
  void _glideTo({double? x, double? y}) {
    _stopSpin();
    final fromX = _rotX;
    final fromY = _rotY;
    final toX = x ?? _rotX;
    final toY = y ?? _rotY;
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    final curve = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );
    void listener() {
      setState(() {
        _rotX = fromX + (toX - fromX) * curve.value;
        _rotY = fromY + (toY - fromY) * curve.value;
      });
    }

    controller
      ..addListener(listener)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.dispose();
        }
      })
      ..forward();
  }

  /// True while the front faces the camera: the plate normal `(0,0,1)` under
  /// `rotateX(a)` then `rotateY(b)` has z-component `cos a · cos b`.
  bool get _frontVisible => math.cos(_rotX) * math.cos(_rotY) > 0;

  Matrix4 _matrix(double z) =>
      Matrix4.identity()
        ..setEntry(3, 2, _perspective)
        ..rotateX(_rotX)
        ..rotateY(_rotY)
        ..translateByDouble(0, 0, z, 1);

  @override
  Widget build(BuildContext context) {
    final spec = _aspectFor(widget.plate.format);
    final height = widget.width / spec;
    final thickness = widget.thickness ?? widget.width * 0.016;
    final radius = widget.width * 0.027;

    // The plate sweeps a larger box while rotating; reserve for it so the
    // corners are not clipped mid-spin.
    final boxWidth = widget.width * 1.12;
    final boxHeight = height + widget.width * 0.42;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (_) => _stopSpin(),
      onPanUpdate: (details) {
        setState(() {
          _rotY += details.delta.dx * 0.011;
          _rotX -= details.delta.dy * 0.011;
        });
      },
      onPanEnd: (details) {
        final v = details.velocity.pixelsPerSecond;
        if (v.distance > 200) _startSpin(v.dx * 0.0035, -v.dy * 0.0035);
      },
      onDoubleTap: () => _glideTo(y: _rotY + math.pi),
      onLongPress: () => _glideTo(x: 0, y: 0),
      child: SizedBox(
        width: boxWidth,
        height: boxHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _GroundShadow(
              width: widget.width,
              rotationX: _rotX,
              rotationY: _rotY,
              plateHeight: height,
            ),
            // Each face keeps its own side of the slab; only the paint order
            // changes. A Stack has no depth buffer, so the farther face has to
            // be drawn first.
            ...(_frontVisible
                ? [
                  _backFace(thickness),
                  ..._slabs(thickness, height, radius, true),
                  _frontFace(thickness),
                ]
                : [
                  _frontFace(thickness),
                  ..._slabs(thickness, height, radius, false),
                  _backFace(thickness),
                ]),
          ],
        ),
      ),
    );
  }

  /// The printed face, on the `+z` side of the slab.
  Widget _frontFace(double thickness) => Transform(
    alignment: Alignment.center,
    transform: _matrix(thickness / 2),
    child: IraqiLicensePlate(
      plate: widget.plate,
      width: widget.width,
      showShadow: false,
    ),
  );

  /// The bare reverse, on the `-z` side.
  Widget _backFace(double thickness) => Transform(
    alignment: Alignment.center,
    transform: _matrix(-thickness / 2),
    child: IraqiLicensePlate(
      plate: widget.plate,
      width: widget.width,
      showShadow: false,
      face: PlateFace.back,
    ),
  );

  /// The slab between the faces, emitted back-to-front for the current pose.
  /// The layers sit strictly between `±thickness/2` so neither hides a face.
  List<Widget> _slabs(
    double thickness,
    double height,
    double radius,
    bool frontNearest,
  ) {
    final layers = <Widget>[];
    for (var i = 0; i < _slabLayers; i++) {
      final t = (i + 1) / (_slabLayers + 1);
      final index = frontNearest ? i : _slabLayers - 1 - i;
      final depth = (index + 1) / (_slabLayers + 1);
      layers.add(
        Transform(
          alignment: Alignment.center,
          transform: _matrix(
            -thickness / 2 + thickness * (frontNearest ? t : 1 - t),
          ),
          child: _EdgeSlab(
            width: widget.width,
            height: height,
            radius: radius,
            depth: depth,
          ),
        ),
      );
    }
    return layers;
  }

  static double _aspectFor(PlateFormat format) => switch (format) {
    PlateFormat.modernShort || PlateFormat.legacy => 335 / 155,
    PlateFormat.modernLong => 520 / 110,
    PlateFormat.motorcycle => 200 / 125,
  };
}

/// One layer of the slab between the two faces. Stacked, these read as the cut
/// edge of the aluminium.
class _EdgeSlab extends StatelessWidget {
  const _EdgeSlab({
    required this.width,
    required this.height,
    required this.radius,
    required this.depth,
  });

  final double width;
  final double height;
  final double radius;

  /// 0 at the back of the slab, 1 at the front. Drives the shading so the
  /// edge is darker where it recedes.
  final double depth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(
              const Color(0xFFE3E7EA),
              const Color(0xFF9AA1A8),
              1 - depth,
            )!,
            Color.lerp(
              const Color(0xFF9AA1A8),
              const Color(0xFF5E656C),
              1 - depth,
            )!,
          ],
        ),
      ),
    );
  }
}

/// Soft contact shadow that slides and squashes as the plate turns.
class _GroundShadow extends StatelessWidget {
  const _GroundShadow({
    required this.width,
    required this.plateHeight,
    required this.rotationX,
    required this.rotationY,
  });

  final double width;
  final double plateHeight;
  final double rotationX;
  final double rotationY;

  @override
  Widget build(BuildContext context) {
    final foreshorten = math.cos(rotationY).abs().clamp(0.25, 1.0);
    return Transform.translate(
      offset: Offset(
        math.sin(rotationY) * width * 0.06,
        plateHeight * 0.62 + math.sin(rotationX) * width * 0.05,
      ),
      child: Container(
        width: width * foreshorten * 0.92,
        height: plateHeight * 0.34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.elliptical(width * 0.5, plateHeight * 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.38),
              blurRadius: width * 0.14,
              spreadRadius: width * 0.005,
            ),
          ],
          color: Colors.black.withValues(alpha: 0.30),
        ),
      ),
    );
  }
}
