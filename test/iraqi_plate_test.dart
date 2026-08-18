// Unit tests for the plate data model.
//
// Pure Dart — no widgets, no rasterisation, no golden files. This is the suite
// that should run in CI on every push; the visual harness in tool/ is for
// eyeballing renders by hand.
import 'package:flutter_test/flutter_test.dart';
import 'package:iraqi_license_plate/iraqi_license_plate.dart';

void main() {
  group('tryParse', () {
    test('reads the three separator styles', () {
      for (final input in ['11 A 70634', '11A70634', '11-A-70634']) {
        final plate = IraqiPlate.tryParse(input);
        expect(plate, isNotNull, reason: input);
        expect(plate!.governorate, IraqGovernorate.baghdad);
        expect(plate.letter, 'A');
        expect(plate.serial, '70634');
      }
    });

    test('reads Eastern-Arabic and Persian digits', () {
      expect(IraqiPlate.tryParse('١١ A ٧٠٦٣٤')?.serial, '70634');
      // Persian block — a fair number of Iraqi keyboards emit it.
      expect(IraqiPlate.tryParse('۱۱ A ۷۰۶۳۴')?.serial, '70634');
    });

    test('upper-cases a lowercase series letter', () {
      expect(IraqiPlate.tryParse('11 a 70634')?.letter, 'A');
    });

    test('returns null rather than throwing on junk', () {
      for (final input in [
        '',
        'hello',
        '11 A', // no serial
        '99 A 70634', // 99 is not a governorate
        '11 A 706341', // six digits
        '1 A 70634', // one-digit governorate
      ]) {
        expect(IraqiPlate.tryParse(input), isNull, reason: input);
      }
    });
  });

  group('validation', () {
    test('accepts the reference plate', () {
      expect(IraqiPlate.reference.isValid, isTrue);
      expect(IraqiPlate.reference.validationError, isNull);
    });

    test('explains each failure instead of throwing', () {
      IraqiPlate withSerial(String s) =>
          IraqiPlate.reference.copyWith(serial: s);

      expect(withSerial('').validationError, contains('required'));
      expect(withSerial('706341').validationError, contains('five'));
      expect(withSerial('7O634').validationError, contains('digits'));
      expect(
        IraqiPlate.reference.copyWith(letter: 'AB').validationError,
        contains('single'),
      );
      expect(
        IraqiPlate.reference.copyWith(letter: '4').validationError,
        contains('A–Z'),
      );
    });
  });

  group('governorates', () {
    test('codes are unique and two digits', () {
      final codes = IraqGovernorate.values.map((g) => g.code).toList();
      expect(codes.toSet().length, codes.length, reason: 'duplicate code');
      for (final g in IraqGovernorate.values) {
        expect(g.codeText.length, 2, reason: g.name);
      }
    });

    test('fromCode round-trips, and rejects codes outside 11-29', () {
      for (final g in IraqGovernorate.values) {
        expect(IraqGovernorate.fromCode(g.code), g);
      }
      expect(IraqGovernorate.fromCode(10), isNull);
      expect(IraqGovernorate.fromCode(30), isNull);
    });

    test('the four Kurdistan governorates carry a KR band', () {
      const kr = [
        IraqGovernorate.sulaymaniyah,
        IraqGovernorate.erbil,
        IraqGovernorate.halabja,
        IraqGovernorate.duhok,
      ];
      for (final g in IraqGovernorate.values) {
        final plate = IraqiPlate.reference.copyWith(governorate: g);
        expect(
          plate.bandText,
          kr.contains(g) ? 'KR' : 'IRQ',
          reason: g.englishName,
        );
      }
    });
  });

  group('digit conversion', () {
    test('round-trips Western to Eastern-Arabic and back', () {
      expect(IraqiPlate.toArabicDigits('70634'), '٧٠٦٣٤');
      expect(IraqiPlate.fromArabicDigits('٧٠٦٣٤'), '70634');
      expect(
        IraqiPlate.fromArabicDigits(IraqiPlate.toArabicDigits('0123456789')),
        '0123456789',
      );
    });

    test('leaves non-digits untouched', () {
      expect(IraqiPlate.toArabicDigits('11 A 70634'), '١١ A ٧٠٦٣٤');
    });
  });

  group('series letters', () {
    test('fromLatin maps the legacy set and rejects the rest', () {
      expect(PlateSeries.fromLatin('A'), PlateSeries.alif);
      expect(PlateSeries.fromLatin('a'), PlateSeries.alif);
      // Not part of the legacy mapping, though the modern system may use it.
      expect(PlateSeries.fromLatin('X'), isNull);
    });

    test('letterArabic falls back to the Latin letter when unmapped', () {
      expect(IraqiPlate.reference.letterArabic, 'ا');
      expect(IraqiPlate.reference.copyWith(letter: 'X').letterArabic, 'X');
    });
  });

  group('value semantics', () {
    test('equal plates compare equal and hash alike', () {
      final a = IraqiPlate.tryParse('11 A 70634')!;
      final b = IraqiPlate.tryParse('11A70634')!;
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('copyWith changes one field and leaves the rest', () {
      final taxi = IraqiPlate.reference.copyWith(
        category: PlateCategory.publicHire,
      );
      expect(taxi.category, PlateCategory.publicHire);
      expect(taxi.serial, IraqiPlate.reference.serial);
      expect(taxi, isNot(IraqiPlate.reference));
    });

    test('formatted is the human-readable registration', () {
      expect(IraqiPlate.reference.formatted, '11 A 70634');
    });
  });

  group('categories', () {
    test('isDarkField is set only for the two full-field plates', () {
      for (final c in PlateCategory.values) {
        final dark = c == PlateCategory.security || c == PlateCategory.defence;
        expect(c.isDarkField, dark, reason: c.englishLabel);
      }
    });

    test('rideEligible is the subset a passenger could be picked up in', () {
      expect(PlateCategory.rideEligible, [
        PlateCategory.private,
        PlateCategory.publicHire,
      ]);
    });
  });
}
