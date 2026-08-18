import 'package:flutter/material.dart';

import 'iraqi_license_plate.dart';
import 'iraqi_plate.dart';
import 'plate_style.dart';

/// A horizontal strip of real plates to choose from, so the user picks by
/// looking at the plate rather than reading a label.
///
/// Pass [styles] to narrow the list — `IraqiPlateStyles.rideEligible`, or your
/// own list, including styles you built yourself.
///
/// ```dart
/// PlateStylePicker(
///   plate: driver.plate,
///   selected: _style,
///   onSelected: (style) => setState(() => _style = style),
/// )
/// ```
class PlateStylePicker extends StatelessWidget {
  const PlateStylePicker({
    required this.selected,
    required this.onSelected,
    this.styles,
    this.plate,
    this.itemWidth = 132,
    this.showLabels = true,
    this.labelsInArabic = false,
    super.key,
  });

  /// Styles to offer. Defaults to [IraqiPlateStyles.all].
  final List<PlateStyle>? styles;

  /// The currently chosen style, or null for nothing chosen yet.
  final PlateStyle? selected;

  final ValueChanged<PlateStyle> onSelected;

  /// The registration to draw in each swatch. Defaults to
  /// [IraqiPlate.reference].
  final IraqiPlate? plate;

  /// Width of each plate in the strip.
  final double itemWidth;

  final bool showLabels;

  /// Show `أجرة` rather than `Public hire`.
  final bool labelsInArabic;

  @override
  Widget build(BuildContext context) {
    final options = styles ?? IraqiPlateStyles.all;
    final sample = plate ?? IraqiPlate.reference;
    final theme = Theme.of(context);

    return SizedBox(
      // The motorcycle blank is the squarest, so it sets the height.
      height: itemWidth * 0.78 + (showLabels ? 26 : 0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final style = options[i];
          final isSelected = style == selected;

          return Semantics(
            button: true,
            selected: isSelected,
            label: labelsInArabic ? style.nameArabic : style.name,
            child: InkWell(
              onTap: () => onSelected(style),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: IraqiLicensePlate(
                        plate: style.applyTo(sample),
                        palette: style.palette,
                        width: itemWidth,
                        showShadow: false,
                        // Too small to resolve, and a repaint per item.
                        showSecurityPrint: false,
                      ),
                    ),
                    if (showLabels) ...[
                      const SizedBox(height: 5),
                      Text(
                        labelsInArabic ? style.nameArabic : style.name,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w400,
                          color:
                              isSelected
                                  ? theme.colorScheme.primary
                                  : theme.textTheme.labelSmall?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
