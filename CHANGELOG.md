# Changelog

## 0.2.0

- Arabic series letters are supported: any Arabic letter, not only the 17 of
  the old system, is kept and drawn exactly as written, never swapped for a
  Latin one. Each is measured and spaced on its own, so wide letters such as
  س and ط never collide.
- `tryParse` reads old-style registrations such as `12456 ز` and `ز 12456`.
  An Arabic letter defaults the plate to the legacy blank, and the new
  `governorate:` argument fills in a governorate the string leaves out.
- **Breaking:** `IraqiPlate.governorate` is nullable. A plate without one draws
  without its code, or on the legacy blank without the governorate name.
- `validationError` accepts Arabic letters.
- When both rows of a two-row plate overflow, they shrink to one shared size
  and close up together instead of drifting apart.
- README and pub.dev: a render of every character a plate can carry.

## 0.1.1

- README: an Arabic section covering install, usage, live API data, colours and
  the style picker, so the package reads in the language most of its users work
  in.

## 0.1.0

- Initial release.
- `IraqiLicensePlate` renderer: four blanks (car 335×155, European 520×110,
  motorcycle 200×125, legacy Arabic), four-layer stamped relief, retroreflective
  sheeting, micro-printing, tiled map-of-Iraq watermark, guilloche, die stamp,
  rivets and flag tile.
- `PlateViewer3D`: drag to rotate, flick to spin, double-tap to flip, with a
  real slab edge and a concave bare-metal reverse.
- `PlateTypeface`: vector plate face, digits and A–Z.
- Data model: 19 governorate codes, 8 categories, 17 legacy series letters,
  Eastern-Arabic digit conversion, parsing and validation.
- Theming: `PlatePalette` holds the four colours a plate is painted in, so a
  plate can be drawn in any colours rather than only the eight issued sets.
  Resolved per widget, then from an `IraqiPlateTheme`, then from the
  category's own `defaultPalette`.
- `PlateStyle` and `IraqiPlateStyles`: every look the package ships, as values
  rather than enum cases, so a caller can offer a subset, store a style by id
  and add styles of their own.
- `PlateStylePicker`: a horizontal strip of real plates to choose from.
