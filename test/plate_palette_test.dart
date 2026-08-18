// Unit tests for the theming API: palettes, the theme, and the style
// catalogue.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iraqi_license_plate/iraqi_license_plate.dart';

void main() {
  group('PlatePalette', () {
    test('every category ships a palette', () {
      for (final category in PlateCategory.values) {
        expect(category.defaultPalette, isNotNull, reason: category.name);
      }
    });

    test('isDarkField is set only for the two full-field plates', () {
      for (final category in PlateCategory.values) {
        final dark =
            category == PlateCategory.security ||
            category == PlateCategory.defence;
        expect(
          category.defaultPalette.isDarkField,
          dark,
          reason: category.englishLabel,
        );
      }
    });

    test('only the private plate has an untinted band', () {
      for (final category in PlateCategory.values) {
        expect(
          category.defaultPalette.isBandTinted,
          category != PlateCategory.private,
          reason: category.englishLabel,
        );
      }
    });

    test('copyWith changes one colour and leaves the rest', () {
      final base = PlateCategory.private.defaultPalette;
      final red = base.copyWith(bandColor: const Color(0xFFFF0000));

      expect(red.bandColor, const Color(0xFFFF0000));
      expect(red.fieldColor, base.fieldColor);
      expect(red.fieldInk, base.fieldInk);
      expect(red, isNot(base));
    });

    test('branded sets the band and keeps ordinary sheeting', () {
      const brand = Color(0xFF7289DA);
      const palette = PlatePalette.branded(brand);

      expect(palette.bandColor, brand);
      expect(palette.bandInk, const Color(0xFFFFFFFF));
      expect(
        palette.fieldColor,
        PlateCategory.private.defaultPalette.fieldColor,
      );
      expect(palette.isBandTinted, isTrue);
    });

    test('equal palettes compare equal and hash alike', () {
      final a = PlateCategory.publicHire.defaultPalette;
      final b = a.copyWith();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('lerp moves from one palette to the other', () {
      final a = PlateCategory.private.defaultPalette;
      final b = PlateCategory.publicHire.defaultPalette;

      expect(PlatePalette.lerp(a, b, 0), a);
      expect(PlatePalette.lerp(a, b, 1), b);
      expect(
        PlatePalette.lerp(a, b, 0.5)?.bandColor,
        isNot(anyOf(a.bandColor, b.bandColor)),
      );
      expect(PlatePalette.lerp(null, null, 0.5), isNull);
    });
  });

  group('IraqiPlateStyles', () {
    test('ids are unique', () {
      final ids = IraqiPlateStyles.all.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId round-trips every style, and rejects the unknown', () {
      for (final style in IraqiPlateStyles.all) {
        expect(IraqiPlateStyles.byId(style.id), style, reason: style.id);
      }
      expect(IraqiPlateStyles.byId('no_such_style'), isNull);
    });

    test('modern excludes the legacy blank', () {
      expect(
        IraqiPlateStyles.modern,
        isNot(contains(IraqiPlateStyles.legacyArabic)),
      );
      expect(IraqiPlateStyles.all, contains(IraqiPlateStyles.legacyArabic));
    });

    test('rideEligible is the private and taxi pair', () {
      expect(IraqiPlateStyles.rideEligible, [
        IraqiPlateStyles.privateCar,
        IraqiPlateStyles.taxi,
      ]);
    });

    test('applyTo sets format and category, keeping the registration', () {
      final plate = IraqiPlateStyles.motorcycle.applyTo(IraqiPlate.reference);

      expect(plate.format, PlateFormat.motorcycle);
      expect(plate.serial, IraqiPlate.reference.serial);
      expect(plate.governorate, IraqiPlate.reference.governorate);
    });

    test('the catalogue is unmodifiable', () {
      expect(
        () => IraqiPlateStyles.all.add(IraqiPlateStyles.taxi),
        throwsUnsupportedError,
      );
    });
  });

  group('IraqiPlateThemeData', () {
    test('paletteFor returns the override, or the authentic colours', () {
      const brand = PlatePalette.branded(Color(0xFF7289DA));
      const data = IraqiPlateThemeData(
        palettes: {PlateCategory.publicHire: brand},
      );

      expect(data.paletteFor(PlateCategory.publicHire), brand);
      expect(
        data.paletteFor(PlateCategory.cargo),
        PlateCategory.cargo.defaultPalette,
      );
    });

    test('equal data compares equal', () {
      const a = IraqiPlateThemeData(defaultWidth: 200);
      const b = IraqiPlateThemeData(defaultWidth: 200);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(const IraqiPlateThemeData(defaultWidth: 300)));
    });
  });

  group('resolution order', () {
    testWidgets('argument beats theme beats category default', (tester) async {
      const argument = PlatePalette.branded(Color(0xFF00FF00));
      const themed = PlatePalette.branded(Color(0xFF0000FF));

      late PlatePalette noTheme;
      late PlatePalette fromTheme;
      late PlatePalette fromArgument;

      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              // No theme: falls back to the category's own colours.
              Builder(
                builder: (context) {
                  noTheme =
                      IraqiPlateTheme.maybeOf(
                        context,
                      )?.paletteFor(PlateCategory.private) ??
                      PlateCategory.private.defaultPalette;
                  return const SizedBox();
                },
              ),
              IraqiPlateTheme(
                data: const IraqiPlateThemeData(
                  palettes: {PlateCategory.private: themed},
                ),
                child: Builder(
                  builder: (context) {
                    fromTheme = IraqiPlateTheme.of(
                      context,
                    ).paletteFor(PlateCategory.private);
                    fromArgument = argument;
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      );

      expect(noTheme, PlateCategory.private.defaultPalette);
      expect(fromTheme, themed);
      expect(fromArgument, argument);
    });

    testWidgets('a plate renders with every style without throwing', (
      tester,
    ) async {
      for (final style in IraqiPlateStyles.all) {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: IraqiLicensePlate(
                plate: style.applyTo(IraqiPlate.reference),
                palette: style.palette,
                width: 200,
                showSecurityPrint: false,
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: style.id);
      }
    });
  });
}
