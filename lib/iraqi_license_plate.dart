/// Photoreal Iraqi vehicle registration plates for Flutter.
///
/// Every plate is drawn by a single `CustomPainter` against the real blank
/// dimensions in millimetres — no images, no fonts, no plugins, no network.
///
/// ```dart
/// IraqiLicensePlate(
///   plate: IraqiPlate.tryParse('11 A 70634')!,
///   width: 220,
/// )
/// ```
///
/// See [IraqiLicensePlate] for a static plate, [PlateViewer3D] for the
/// interactive one, [PlateGalleryScreen] to browse everything, and
/// [IraqiPlate] for the data model behind all three.
///
/// https://github.com/Abojawdat/plate-number-service
library;

export 'src/iraqi_license_plate.dart' show IraqiLicensePlate, PlateFace;
export 'src/iraqi_plate.dart'
    show
        IraqGovernorate,
        IraqiPlate,
        PlateCategory,
        PlateFormat,
        PlateRegion,
        PlateSeries;
export 'src/plate_gallery_screen.dart' show PlateGalleryScreen;
export 'src/plate_palette.dart' show PlatePalette;
export 'src/plate_style.dart' show IraqiPlateStyles, PlateStyle;
export 'src/plate_style_picker.dart' show PlateStylePicker;
export 'src/plate_theme.dart' show IraqiPlateTheme, IraqiPlateThemeData;
export 'src/plate_typeface.dart' show PlateTypeface;
export 'src/plate_viewer_3d.dart' show PlateViewer3D;
