#!/usr/bin/env bash
#
# Regenerates every PNG in render/ — the images the README and the pub.dev
# listing point at.
#
#   ./tool/render_all.sh
#
# One `flutter test` process per plate, on purpose. The first call to
# RenderRepaintBoundary.toImage in a process works; every call after it blocks
# forever at 0% CPU with the file already written, so tool/render_plates.dart
# renders a single shot and exits. Driving it one shot at a time is what makes
# the whole set reproducible.
#
# Env:
#   PLATE_RENDER_SCALE=2   larger output; slow, the emboss blur is CPU-bound
#   PLATE_RENDER_FONT=…    an Arabic .ttf, so the legacy blank and the flag's
#                          takbir render as glyphs instead of empty boxes
set -uo pipefail

cd "$(dirname "$0")/.."

# The headless test engine ships no Arabic font, so without one the legacy
# blank and the flag's takbir come out as empty boxes. Find a system font with
# Arabic coverage unless the caller named one.
if [ -z "${PLATE_RENDER_FONT:-}" ]; then
  for candidate in \
    "/System/Library/Fonts/Supplemental/Arial Unicode.ttf" \
    "/Library/Fonts/Arial Unicode.ttf" \
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf" \
    "/usr/share/fonts/truetype/freefont/FreeSerif.ttf"
  do
    if [ -f "$candidate" ]; then
      export PLATE_RENDER_FONT="$candidate"
      break
    fi
  done
fi

if [ -n "${PLATE_RENDER_FONT:-}" ]; then
  echo "Arabic font: $PLATE_RENDER_FONT"
else
  echo "No Arabic font found — the legacy blank will render as empty boxes."
  echo "Set PLATE_RENDER_FONT to an Arabic .ttf to fix it."
fi

#            test name          | file it writes
SHOTS=(
  "01 front and back|01_front_and_back"
  "02 every category|02_categories"
  "03 every format|03_formats"
  "04 size ladder|04_sizes"
  "05 typeface|05_typeface"
  "07 character set|07_character_set"
)

OUT="${PLATE_RENDER_OUT:-render}"

failed=0
for entry in "${SHOTS[@]}"; do
  shot="${entry%%|*}"
  file="$OUT/${entry##*|}.png"
  rm -f "$file"

  #! Both the exit code and the reporter lie here, so neither is checked.
  #! The generator calls exit(0) as soon as the PNG is on disk — sooner than
  #! the reporter expects — so every shot is announced as a failure, and the
  #! `wrote …` line is often lost with the unflushed pipe. The file appearing
  #! on disk is the only honest signal, so that is what is tested.
  flutter test tool/render_plates.dart --plain-name "$shot" --reporter compact \
    >/dev/null 2>&1

  if [ -s "$file" ]; then
    printf '  \033[32m✓\033[0m %-20s %s\n' "$shot" "$file"
  else
    printf '  \033[31m✗\033[0m %-20s did not render\n' "$shot"
    failed=1
  fi
done

echo
if [ "$failed" -eq 0 ]; then
  echo "All plates rendered into $OUT/."
else
  echo "Some plates did not render. Run one on its own to see why:"
  echo "  flutter test tool/render_plates.dart --plain-name '01 front and back'"
fi
exit $failed
