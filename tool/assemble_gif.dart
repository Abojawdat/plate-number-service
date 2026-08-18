// Assembles the raw frames written by tool/render_spin.dart into an animated
// GIF. Pure Dart — no Flutter, so it runs as:
//
//   dart run tool/assemble_gif.dart
//
// The GIF encoder is written out here by hand. Encoding it ourselves keeps the
// package's dependency list empty, which is most of why it scores well on
// pub.dev, and means a contributor needs no ffmpeg to regenerate a picture.
import 'dart:convert' show ascii;
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

/// Hundredths of a second per frame, which is how GIF measures delay.
const int _delayCs = 7;

const String _framesDir = 'render/.frames';

/// Must match the ColoredBox in tool/render_spin.dart.
const ({int r, int g, int b}) _backdrop = (r: 0x2B, g: 0x32, b: 0x42);

void main() {
  final dir = Directory(_framesDir);
  if (!dir.existsSync()) {
    stderr.writeln('No frames in $_framesDir. Run ./tool/render_spin.sh.');
    exit(1);
  }

  final raw =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.rgba'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  if (raw.isEmpty) {
    stderr.writeln('No .rgba frames in $_framesDir.');
    exit(1);
  }

  final frames = <_Frame>[];
  for (final file in raw) {
    final dims = File(
      file.path.replaceAll('.rgba', '.dim'),
    ).readAsStringSync().trim().split(' ');
    frames.add(
      _Frame(file.readAsBytesSync(), int.parse(dims[0]), int.parse(dims[1])),
    );
  }

  final out = File('render/06_spin.gif');
  out.writeAsBytesSync(_encodeGif(frames, delayCs: _delayCs));
  stdout.writeln(
    'wrote ${out.path} — ${frames.length} frames, '
    '${out.lengthSync() ~/ 1024} KB',
  );
}

class _Frame {
  _Frame(this.rgba, this.width, this.height);
  final Uint8List rgba;
  final int width;
  final int height;
}

// ---------------------------------------------------------------------------
// GIF encoding
// ---------------------------------------------------------------------------

/// Encodes RGBA frames as an animated GIF89a.
///
/// GIF is limited to 256 colours per frame, so the plate — which is mostly
/// metallic greys plus the flag — is quantised to a fixed 6×7×6 colour cube
/// with a grey ramp in the spare entries. That handles this subject well; it
/// is not a general-purpose quantiser.
Uint8List _encodeGif(List<_Frame> frames, {required int delayCs}) {
  final out = BytesBuilder();
  final first = frames.first;

  // Header and logical screen descriptor.
  out.add(ascii.encode('GIF89a'));
  out.add(_u16(first.width));
  out.add(_u16(first.height));
  out.add([
    0xF7, // global colour table, 256 entries, 8 bits per channel
    0, // background colour index
    0, // pixel aspect ratio
  ]);
  out.add(_palette());

  // Netscape looping extension.
  out.add([0x21, 0xFF, 0x0B]);
  out.add(ascii.encode('NETSCAPE2.0'));
  out.add([0x03, 0x01, 0x00, 0x00, 0x00]);

  for (final frame in frames) {
    // Graphic control extension: frame delay.
    out.add([0x21, 0xF9, 0x04, 0x00]);
    out.add(_u16(delayCs));
    out.add([0x00, 0x00]);

    // Image descriptor.
    out.add([0x2C]);
    out.add(_u16(0));
    out.add(_u16(0));
    out.add(_u16(frame.width));
    out.add(_u16(frame.height));
    out.add([0x00]); // no local colour table

    out.add(_lzwEncode(_quantise(frame), 8));
  }

  out.add([0x3B]); // trailer
  return out.toBytes();
}

/// A 6×6×6 colour cube (216 entries) plus a 40-step grey ramp.
///
/// The plate is mostly brushed aluminium with a red-white-black flag on it, so
/// the spare 40 entries go to greys rather than more hues: the cube alone
/// gives only six steps along the neutral diagonal, which visibly bands across
/// the metal gradients and the emboss shading.
Uint8List _palette() {
  final table = Uint8List(256 * 3);
  var i = 0;
  for (var r = 0; r < 6; r++) {
    for (var g = 0; g < 6; g++) {
      for (var b = 0; b < 6; b++) {
        table[i++] = r * 51;
        table[i++] = g * 51;
        table[i++] = b * 51;
      }
    }
  }
  for (var k = 0; k < 39; k++) {
    final v = k * 255 ~/ 38;
    table[i++] = v;
    table[i++] = v;
    table[i++] = v;
  }
  //! The backdrop gets the last slot outright. It is the single largest area
  //! in every frame and the cube cannot express it — rounded to the nearest
  //! cube entry it comes back flat grey, losing the blue the stills are shot
  //! against.
  table[i++] = _backdrop.r;
  table[i++] = _backdrop.g;
  table[i++] = _backdrop.b;
  return table;
}

/// Nearest palette entry for one colour.
///
/// Checks the cube by rounding, then the grey ramp, and keeps whichever is
/// closer — so neutral pixels reach the fine ramp instead of snapping to the
/// cube's coarse diagonal.
int _indexFor(int r, int g, int b) {
  final cube = ((r + 25) ~/ 51) * 36 + ((g + 25) ~/ 51) * 6 + ((b + 25) ~/ 51);
  final cr = ((r + 25) ~/ 51) * 51;
  final cg = ((g + 25) ~/ 51) * 51;
  final cb = ((b + 25) ~/ 51) * 51;
  final cubeError =
      (r - cr) * (r - cr) + (g - cg) * (g - cg) + (b - cb) * (b - cb);

  final luma = (r * 30 + g * 59 + b * 11) ~/ 100;
  final step = (luma * 38 + 127) ~/ 255;
  final gv = step * 255 ~/ 38;
  final greyError =
      (r - gv) * (r - gv) + (g - gv) * (g - gv) + (b - gv) * (b - gv);

  final dr = r - _backdrop.r;
  final dg = g - _backdrop.g;
  final db = b - _backdrop.b;
  final backdropError = dr * dr + dg * dg + db * db;

  if (backdropError <= cubeError && backdropError <= greyError) return 255;
  return greyError < cubeError ? 216 + step : cube;
}

Uint8List _quantise(_Frame frame) {
  final pixels = frame.width * frame.height;
  final indexed = Uint8List(pixels);
  for (var p = 0; p < pixels; p++) {
    final o = p * 4;
    //! GIF has no alpha channel. toImage returns premultiplied RGBA, so a
    //! partly transparent pixel — the plate's soft shadow — arrives already
    //! darkened toward black; compositing the remainder over the backdrop
    //! puts it back where it belongs.
    final a = frame.rgba[o + 3];
    indexed[p] =
        a == 255
            ? _indexFor(frame.rgba[o], frame.rgba[o + 1], frame.rgba[o + 2])
            : _indexFor(
              frame.rgba[o] + _backdrop.r * (255 - a) ~/ 255,
              frame.rgba[o + 1] + _backdrop.g * (255 - a) ~/ 255,
              frame.rgba[o + 2] + _backdrop.b * (255 - a) ~/ 255,
            );
  }
  return indexed;
}

/// Variable-code-width LZW, as GIF specifies it, emitted in 255-byte blocks.
Uint8List _lzwEncode(Uint8List indexed, int minCodeSize) {
  final clearCode = 1 << minCodeSize;
  final endCode = clearCode + 1;

  var codeSize = minCodeSize + 1;
  var nextCode = endCode + 1;
  var dict = <String, int>{};

  final bits = _BitWriter();
  bits.write(clearCode, codeSize);

  var prefix = '';
  for (final byte in indexed) {
    final candidate = prefix.isEmpty ? '$byte' : '$prefix,$byte';
    if (prefix.isEmpty || dict.containsKey(candidate)) {
      prefix = candidate;
      continue;
    }

    bits.write(_codeOf(prefix, dict, clearCode), codeSize);
    dict[candidate] = nextCode++;

    if (nextCode > (1 << codeSize)) {
      if (codeSize < 12) {
        codeSize++;
      } else {
        bits.write(clearCode, codeSize);
        dict = <String, int>{};
        nextCode = endCode + 1;
        codeSize = minCodeSize + 1;
      }
    }
    prefix = '$byte';
  }

  if (prefix.isNotEmpty) bits.write(_codeOf(prefix, dict, clearCode), codeSize);
  bits.write(endCode, codeSize);

  final payload = bits.close();
  final out = BytesBuilder();
  out.add([minCodeSize]);
  for (var i = 0; i < payload.length; i += 255) {
    final end = math.min(i + 255, payload.length);
    out.add([end - i]);
    out.add(payload.sublist(i, end));
  }
  out.add([0]); // block terminator
  return out.toBytes();
}

int _codeOf(String sequence, Map<String, int> dict, int clearCode) {
  final known = dict[sequence];
  if (known != null) return known;
  // A single, never-added symbol is its own code.
  return int.parse(sequence.split(',').last);
}

class _BitWriter {
  final BytesBuilder _bytes = BytesBuilder();
  int _accumulator = 0;
  int _bitCount = 0;

  void write(int code, int width) {
    _accumulator |= code << _bitCount;
    _bitCount += width;
    while (_bitCount >= 8) {
      _bytes.addByte(_accumulator & 0xFF);
      _accumulator >>= 8;
      _bitCount -= 8;
    }
  }

  Uint8List close() {
    if (_bitCount > 0) _bytes.addByte(_accumulator & 0xFF);
    return _bytes.toBytes();
  }
}

List<int> _u16(int value) => [value & 0xFF, (value >> 8) & 0xFF];
