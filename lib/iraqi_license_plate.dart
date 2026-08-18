/// Photoreal Iraqi vehicle registration plates for Flutter.
///
/// Every plate is drawn by a single `CustomPainter` against the real blank
/// dimensions in millimetres — no images, no fonts, no plugins, no network.
/// The package depends on nothing but Flutter itself and runs on all six
/// platforms.
///
/// ```dart
/// IraqiLicensePlate(
///   plate: IraqiPlate.tryParse('11 A 70634')!,
///   width: 220,
/// )
/// ```
///
/// Start with [IraqiLicensePlate] for a static plate, [PlateViewer3D] for the
/// interactive one, or [PlateGalleryScreen] to browse everything the package
/// can draw. [IraqiPlate] is the data model behind all three.
///
/// Written by Abojawdat (Mohammad Othman).
/// Source, issues and examples: https://github.com/Abojawdat/plate-number-service
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
export 'src/plate_typeface.dart' show PlateTypeface;
export 'src/plate_viewer_3d.dart' show PlateViewer3D;
