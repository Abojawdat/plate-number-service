import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'iraqi_license_plate.dart';
import 'iraqi_plate.dart';
import 'plate_viewer_3d.dart';

/// A ready-made explorer for everything in this package.
///
/// Drop it into any app to browse the formats, categories, governorates and
/// series letters, and to check a plate renders the way you expect:
///
/// ```dart
/// Navigator.of(context).push(
///   MaterialPageRoute(builder: (_) => const PlateGalleryScreen()),
/// );
/// ```
///
/// It depends on nothing but Flutter's own Material widgets, so it will pick up
/// the ambient [Theme] and works in either brightness.
class PlateGalleryScreen extends StatefulWidget {
  const PlateGalleryScreen({this.initialPlate, super.key});

  /// Plate to open with. Defaults to [IraqiPlate.reference].
  final IraqiPlate? initialPlate;

  @override
  State<PlateGalleryScreen> createState() => _PlateGalleryScreenState();
}

class _PlateGalleryScreenState extends State<PlateGalleryScreen> {
  late IraqiPlate _plate = widget.initialPlate ?? IraqiPlate.reference;
  late final TextEditingController _serial = TextEditingController(
    text: _plate.serial,
  );

  @override
  void dispose() {
    _serial.dispose();
    super.dispose();
  }

  void _set(IraqiPlate next) => setState(() => _plate = next);

  @override
  Widget build(BuildContext context) {
    final error = _plate.validationError;
    return Scaffold(
      appBar: AppBar(title: const Text('Iraqi plates')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          _Stage(plate: _plate),
          _Group(
            title: 'Format',
            child: _Chips<PlateFormat>(
              values: PlateFormat.values,
              selected: _plate.format,
              label: _formatLabel,
              onTap: (v) => _set(_plate.copyWith(format: v)),
            ),
          ),
          _Group(
            title: 'Category',
            caption:
                'The side band carries the category, not the whole plate — '
                'except for the counter-terrorism and defence blanks.',
            child: _Chips<PlateCategory>(
              values: PlateCategory.values,
              selected: _plate.category,
              label: (c) => '${c.englishLabel}  ${c.arabicLabel}',
              swatch: (c) => c.bandColor,
              onTap: (v) => _set(_plate.copyWith(category: v)),
            ),
          ),
          _Group(
            title: 'Governorate',
            caption:
                'Codes 11–29. The four Kurdistan Region governorates switch '
                'the band from IRQ to KR.',
            child: _Chips<IraqGovernorate>(
              values: IraqGovernorate.values,
              selected: _plate.governorate,
              label: (g) => '${g.codeText}  ${g.englishName}',
              onTap: (v) => _set(_plate.copyWith(governorate: v)),
            ),
          ),
          _Group(
            title: 'Series letter',
            caption:
                'Registrations carried over from the old system all took the '
                'letter A. The Arabic glyph is the legacy equivalent.',
            child: _Chips<String>(
              values: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''),
              selected: _plate.letter,
              label: (l) {
                final legacy = PlateSeries.fromLatin(l);
                return legacy == null ? l : '$l  ${legacy.arabic}';
              },
              onTap: (v) => _set(_plate.copyWith(letter: v)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _serial,
              keyboardType: TextInputType.number,
              maxLength: 5,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Serial',
                border: const OutlineInputBorder(),
                counterText: '',
                errorText: error,
              ),
              onChanged: (v) => _set(_plate.copyWith(serial: v)),
            ),
          ),
          _Group(
            title: 'Every category',
            child: Column(
              children: [
                for (final category in PlateCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      children: [
                        IraqiLicensePlate(
                          plate: _plate.copyWith(category: category),
                          width: 280,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${category.englishLabel} · ${category.arabicLabel}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          _Group(
            title: 'Every format',
            child: Column(
              children: [
                for (final format in PlateFormat.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: IraqiLicensePlate(
                      plate: _plate.copyWith(format: format),
                      width: format == PlateFormat.modernLong ? 330 : 260,
                    ),
                  ),
              ],
            ),
          ),
          _Group(
            title: 'Sizes',
            caption:
                'Security printing is skipped below ~90 px wide, so small '
                'plates stay clean instead of turning to mush.',
            child: Column(
              children: [
                for (final w in <double>[70, 110, 160, 240])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: IraqiLicensePlate(plate: _plate, width: w),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatLabel(PlateFormat format) => switch (format) {
    PlateFormat.modernShort => 'Car 335×155',
    PlateFormat.modernLong => 'Long 520×110',
    PlateFormat.motorcycle => 'Motorcycle 200×125',
    PlateFormat.legacy => 'Legacy (Arabic)',
  };
}

class _Stage extends StatelessWidget {
  const _Stage({required this.plate});

  final IraqiPlate plate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B1F2A), Color(0xFF2B3242)],
        ),
      ),
      child: Column(
        children: [
          PlateViewer3D(plate: plate, width: 280),
          Text(
            'drag to rotate · double-tap to flip · long-press to reset',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            plate.formatted,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
          Text(
            '${plate.governorate.englishName} · ${plate.category.englishLabel}'
            ' · ${plate.bandText}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.child, this.caption});

  final String title;
  final String? caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (caption != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
              child: Text(
                caption!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _Chips<T> extends StatelessWidget {
  const _Chips({
    required this.values,
    required this.selected,
    required this.label,
    required this.onTap,
    this.swatch,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final Color Function(T)? swatch;
  final ValueChanged<T> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final value = values[index];
          return ChoiceChip(
            selected: value == selected,
            onSelected: (_) => onTap(value),
            avatar:
                swatch == null
                    ? null
                    : CircleAvatar(backgroundColor: swatch!(value), radius: 8),
            label: Text(label(value)),
          );
        },
      ),
    );
  }
}
