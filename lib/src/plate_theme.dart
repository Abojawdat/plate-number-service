import 'package:flutter/widgets.dart';

import 'iraqi_plate.dart';
import 'plate_palette.dart';

/// Defaults for every plate below it in the tree. Anything a widget passes
/// directly still wins; the theme only fills in what was left out.
///
/// ```dart
/// IraqiPlateTheme(
///   data: IraqiPlateThemeData(
///     palettes: {
///       PlateCategory.publicHire: PlatePalette.branded(myBrandRed),
///     },
///     defaultWidth: 180,
///   ),
///   child: MyApp(),
/// )
/// ```
class IraqiPlateTheme extends InheritedWidget {
  const IraqiPlateTheme({required this.data, required super.child, super.key});

  final IraqiPlateThemeData data;

  /// The theme above [context], or null if there is none. Prefer this over
  /// [of]: plates work perfectly well with no theme in the tree.
  static IraqiPlateThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<IraqiPlateTheme>()?.data;

  /// The theme above [context]. Asserts if there is none.
  static IraqiPlateThemeData of(BuildContext context) {
    final data = maybeOf(context);
    assert(data != null, 'No IraqiPlateTheme found above this widget.');
    return data!;
  }

  @override
  bool updateShouldNotify(IraqiPlateTheme oldWidget) => data != oldWidget.data;
}

/// The values an [IraqiPlateTheme] carries.
@immutable
class IraqiPlateThemeData {
  const IraqiPlateThemeData({
    this.palettes = const {},
    this.defaultWidth,
    this.showSecurityPrint = true,
  });

  /// Colours per category. Categories left out keep their authentic palette.
  final Map<PlateCategory, PlatePalette> palettes;

  /// Width for plates that do not name one themselves.
  final double? defaultWidth;

  /// Set false to drop the micro-printing, watermarks and guilloche
  /// everywhere. Worth doing when an app shows many small plates at once: it
  /// is the most expensive part of the painter.
  final bool showSecurityPrint;

  /// The override for [category] if one was given, otherwise its own colours.
  PlatePalette paletteFor(PlateCategory category) =>
      palettes[category] ?? category.defaultPalette;

  IraqiPlateThemeData copyWith({
    Map<PlateCategory, PlatePalette>? palettes,
    double? defaultWidth,
    bool? showSecurityPrint,
  }) {
    return IraqiPlateThemeData(
      palettes: palettes ?? this.palettes,
      defaultWidth: defaultWidth ?? this.defaultWidth,
      showSecurityPrint: showSecurityPrint ?? this.showSecurityPrint,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is IraqiPlateThemeData &&
      other.defaultWidth == defaultWidth &&
      other.showSecurityPrint == showSecurityPrint &&
      _sameMap(other.palettes, palettes);

  static bool _sameMap(
    Map<PlateCategory, PlatePalette> a,
    Map<PlateCategory, PlatePalette> b,
  ) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    defaultWidth,
    showSecurityPrint,
    Object.hashAllUnordered(
      palettes.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );
}
