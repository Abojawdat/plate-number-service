#!/usr/bin/env bash
#
# Regenerates render/06_spin.gif — the plate turning through a full revolution,
# front face to stamped reverse and back.
#
#   ./tool/render_spin.sh
#
# One `flutter test` process per frame, which is slow (a couple of minutes) but
# unavoidable: a test process wedges at 0% CPU on its second call to
# RenderRepaintBoundary.toImage. Each process renders one frame to raw RGBA and
# exits; tool/assemble_gif.dart then builds the GIF in pure Dart.
set -uo pipefail

cd "$(dirname "$0")/.."

FRAMES=24
DIR=render/.frames

if [ -z "${PLATE_RENDER_FONT:-}" ]; then
  for candidate in \
    "/System/Library/Fonts/Supplemental/Arial Unicode.ttf" \
    "/Library/Fonts/Arial Unicode.ttf" \
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
  do
    [ -f "$candidate" ] && { export PLATE_RENDER_FONT="$candidate"; break; }
  done
fi

rm -rf "$DIR"
mkdir -p "$DIR"

echo "Rendering $FRAMES frames…"
for i in $(seq 0 $((FRAMES - 1))); do
  name=$(printf '%02d' "$i")

  #! Neither the exit code nor the reporter is trustworthy — the renderer
  #! calls exit(0) the moment the frame is on disk, sooner than the test
  #! reporter expects, so every frame is announced as a failure. The file
  #! appearing is the only honest signal.
  PLATE_SPIN_FRAME="$i" flutter test tool/render_spin.dart --reporter compact \
    >/dev/null 2>&1

  if [ -s "$DIR/$name.rgba" ]; then
    printf '\r  %s/%s frames' "$((i + 1))" "$FRAMES"
  else
    printf '\n  frame %s failed\n' "$name"
    exit 1
  fi
done

echo
echo "Assembling…"
dart run tool/assemble_gif.dart || exit 1

rm -rf "$DIR"
