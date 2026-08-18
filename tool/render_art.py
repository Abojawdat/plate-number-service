#!/usr/bin/env python3
"""Generates the animated SVG art in `art/`.

Everything the README shows moving is drawn here, in the same millimetre space
and with the same four-layer relief the Dart painter uses, so the art and the
package cannot drift apart. The glyphs are the very skeletons out of
`lib/src/plate_typeface.dart`, stroked rather than filled for the same reason
they are there: one path, offset four times, is what makes a character read as
stamped aluminium.

    python3 tool/render_art.py

No dependencies. Writes art/*.svg.
"""

import os

OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "art")

# ---------------------------------------------------------------------------
# Colour
# ---------------------------------------------------------------------------


def rgb(c):
    c = c.lstrip("#")
    return tuple(int(c[i : i + 2], 16) for i in (0, 2, 4))


def hexs(t):
    return "#%02x%02x%02x" % tuple(max(0, min(255, round(v))) for v in t)


def mix(a, b, t):
    ra, rb = rgb(a), rgb(b)
    return hexs(tuple(ra[i] + (rb[i] - ra[i]) * t for i in range(3)))


def darken(c, a):
    return mix(c, "#000000", a)


def lighten(c, a):
    return mix(c, "#ffffff", a)


# Straight out of lib/src/iraqi_plate.dart.
CATEGORIES = [
    ("private", "Private", "خصوصي", "#E8EAEC", "#121417", "#F2F4F5", "#121417"),
    ("publicHire", "Public hire", "أجرة", "#C8102E", "#FFFFFF", "#F2F4F5", "#121417"),
    ("government", "Government", "حكومية", "#10499B", "#FFFFFF", "#F2F4F5", "#121417"),
    ("cargo", "Cargo", "حمل", "#F2B705", "#121417", "#F2F4F5", "#121417"),
    ("agricultural", "Agricultural", "زراعي", "#1B7F44", "#FFFFFF", "#F2F4F5", "#121417"),
    ("temporary", "Temporary", "مؤقت", "#E8710A", "#FFFFFF", "#F2F4F5", "#121417"),
    ("security", "Counter-terrorism", "مكافحة الإرهاب", "#15171A", "#F2F4F5", "#1D2024", "#F2F4F5"),
    ("defence", "Defence", "الدفاع", "#0B5D34", "#FFFFFF", "#117843", "#FFFFFF"),
]

CAT = {c[0]: dict(zip(("id", "en", "ar", "band", "bandInk", "field", "fieldInk"), c)) for c in CATEGORIES}

INK = "#0E1116"
PAPER = "#F2F4F5"

# ---------------------------------------------------------------------------
# The typeface — centre-line skeletons, 70 × 100 em, baseline at y = 100.
# ---------------------------------------------------------------------------

_L, _R, _T, _B, _CX = 9, 61, 8.5, 91.5, 35

_ROUND = (
    "M 28 8.5 H 42 A 19 23 0 0 1 61 31.5 V 68.5 A 19 23 0 0 1 42 91.5 "
    "H 28 A 19 23 0 0 1 9 68.5 V 31.5 A 19 23 0 0 1 28 8.5 Z"
)
_BOWL_P = "M 13 91.5 L 13 8.5 L 36 8.5 C 53 8.5 61 18 61 32 C 61 46 53 55 36 55 L 13 55"

GLYPHS = {
    "0": _ROUND,
    "1": "M 12 27 L 35 8.5 L 35 91.5",
    "2": "M 11 30 C 11 16 21 8.5 35 8.5 C 49 8.5 60 17 60 30 C 60 42 53 50 40 61 L 10 91.5 L 61 91.5",
    "3": "M 11 27 C 13 15 23 8.5 35 8.5 C 49 8.5 59 16 59 28 C 59 41 49 50 33 50 "
         "C 50 50 61 59 61 72 C 61 84 50 91.5 36 91.5 C 23 91.5 13 85 11 73",
    "4": "M 45 8.5 L 9 64 L 61 64 M 45 8.5 L 45 91.5",
    "5": "M 58 8.5 L 16 8.5 L 13 43 C 24 34 39 33 48 39 C 57 45 61 54 61 66 "
         "C 61 82 50 91.5 35 91.5 C 23 91.5 13 85 10 74",
    "6": "M 53 14 C 45 8.5 35 7 28 11 C 16 18 10 34 10 58 C 10 80 20 91.5 35 91.5 "
         "C 50 91.5 60 82 60 69 C 60 56 50 47 36 47 C 24 47 14 53 10 62",
    "7": "M 10 8.5 L 61 8.5 L 28 91.5",
    "8": "M 35 47 C 21 47 12 39 12 28 C 12 16 22 8.5 35 8.5 C 48 8.5 58 16 58 28 "
         "C 58 39 49 47 35 47 C 19 47 9 56 9 69 C 9 83 20 91.5 35 91.5 "
         "C 50 91.5 61 83 61 69 C 61 56 51 47 35 47 Z",
    "9": "M 17 86 C 25 91.5 35 93 42 89 C 54 82 60 66 60 42 C 60 20 50 8.5 35 8.5 "
         "C 20 8.5 10 18 10 31 C 10 44 20 53 34 53 C 46 53 56 47 60 38",
    "A": "M 6 91.5 L 35 8.5 L 64 91.5 M 17 66 L 53 66",
    "B": "M 13 8.5 L 13 91.5 M 13 8.5 L 36 8.5 C 52 8.5 60 16 60 28 C 60 40 52 48 36 48 "
         "L 13 48 M 13 48 L 38 48 C 54 48 62 57 62 70 C 62 83 54 91.5 38 91.5 L 13 91.5",
    "C": "M 60 27 C 53 13 43 8.5 35 8.5 C 20 8.5 10 22 10 50 C 10 78 20 91.5 35 91.5 "
         "C 43 91.5 53 87 60 73",
    "D": "M 13 8.5 L 13 91.5 L 34 91.5 C 52 91.5 61 77 61 50 C 61 23 52 8.5 34 8.5 Z",
    "E": "M 60 8.5 L 13 8.5 L 13 91.5 L 60 91.5 M 13 50 L 52 50",
    "F": "M 60 8.5 L 13 8.5 L 13 91.5 M 13 50 L 52 50",
    "G": "M 60 27 C 53 13 43 8.5 35 8.5 C 20 8.5 10 22 10 50 C 10 78 20 91.5 35 91.5 "
         "C 50 91.5 60 82 60 65 L 60 56 L 40 56",
    "H": "M 12 8.5 L 12 91.5 M 58 8.5 L 58 91.5 M 12 50 L 58 50",
    "I": "M 18 8.5 L 18 91.5",
    "J": "M 52 8.5 L 52 66 C 52 83 43 91.5 31 91.5 C 18 91.5 10 83 9 70",
    "K": "M 13 8.5 L 13 91.5 M 60 8.5 L 13 53 M 30 42 L 62 91.5",
    "L": "M 14 8.5 L 14 91.5 L 60 91.5",
    "M": "M 8 91.5 L 8 8.5 L 39 63 L 70 8.5 L 70 91.5",
    "N": "M 12 91.5 L 12 8.5 L 58 91.5 L 58 8.5",
    "O": _ROUND,
    "P": _BOWL_P,
    "Q": _ROUND + " M 41 73 L 64 93",
    "R": _BOWL_P + " M 33 55 L 62 91.5",
    "S": "M 59 26 C 53 14 43 8.5 33 8.5 C 20 8.5 12 16 12 27 C 12 39 21 45 38 49 "
         "C 55 54 61 61 61 72 C 61 84 51 91.5 37 91.5 C 25 91.5 15 85 11 74",
    "T": "M 9 8.5 L 61 8.5 M 35 8.5 L 35 91.5",
    "U": "M 12 8.5 L 12 63 C 12 82 21 91.5 35 91.5 C 49 91.5 58 82 58 63 L 58 8.5",
    "V": "M 7 8.5 L 35 91.5 L 63 8.5",
    "W": "M 4 8.5 L 20 91.5 L 40 32 L 60 91.5 L 76 8.5",
    "X": "M 11 8.5 L 59 91.5 M 59 8.5 L 11 91.5",
    "Y": "M 9 8.5 L 35 50 L 61 8.5 M 35 50 L 35 91.5",
    "Z": "M 11 8.5 L 59 8.5 L 11 91.5 L 59 91.5",
}

EM, CAP_U, STROKE_U = 70.0, 100.0, 17.0
ADVANCE = {"I": 36.0, "J": 66.0, "M": 78.0, "W": 80.0}


def advance_of(ch):
    return ADVANCE.get(ch.upper(), EM)


def layout_run(text, cap, top, left, right, align="center", tracking=0.0, group_after=None):
    """Port of `_drawGlyphRun`'s layout. Returns (placements, scale)."""
    group_after = group_after or {}
    scale = cap / CAP_U
    tracking_mm = tracking * cap
    chars = list(text)
    gaps, run_w = [], 0.0
    for i, ch in enumerate(chars):
        run_w += advance_of(ch) * scale
        if i < len(chars) - 1:
            gap = tracking_mm + group_after.get(i + 1, 0.0) * cap
            gaps.append(gap)
            run_w += gap
    available = right - left
    fit = available / run_w if run_w > available else 1.0
    eff = scale * fit
    width = run_w * fit
    start_x = {"left": left, "right": right - width, "center": left + (available - width) / 2}[align]
    start_y = top + (cap - cap * fit) / 2
    out, x = [], start_x
    for i, ch in enumerate(chars):
        adv = advance_of(ch) * eff
        out.append((ch, x, start_y, eff, adv))
        x += adv
        if i < len(gaps):
            x += gaps[i] * fit
    return out, eff


# ---------------------------------------------------------------------------
# SMIL helpers
# ---------------------------------------------------------------------------

EASE = "0.16 0.84 0.3 1"


def fmt(v):
    if isinstance(v, float):
        s = ("%.4f" % v).rstrip("0").rstrip(".")
        return s if s not in ("", "-0") else "0"
    return str(v)


def animate(attr, dur, pairs, ease=True, kind=None, begin=None, repeat="indefinite"):
    """`pairs` is [(seconds, value), ...] over a `dur`-second master loop."""
    times = ";".join(fmt(round(t / dur, 5)) for t, _ in pairs)
    vals = ";".join(fmt(v) for _, v in pairs)
    tag = "animateTransform" if kind else "animate"
    extra = ' type="%s" additive="sum"' % kind if kind else ""
    if ease:
        extra += ' calcMode="spline" keySplines="%s"' % ";".join([EASE] * (len(pairs) - 1))
    if begin is not None:
        extra += ' begin="%ss"' % fmt(begin)
    return (
        '<%s attributeName="%s" dur="%ss" repeatCount="%s" keyTimes="%s" values="%s"%s/>'
        % (tag, "transform" if kind else attr, fmt(dur), repeat, times, vals, extra)
    )


def hold_schedule(values, dur, hold=0.72, wrap=True):
    """Step through `values` over `dur`, holding each then cross-fading.

    `wrap=False` ends on the last value instead of easing back to the first,
    so the loop restart snaps rather than rewinding through every step.
    """
    n = len(values)
    slot = dur / n
    pairs = []
    for i, v in enumerate(values):
        pairs.append((i * slot, v))
        pairs.append(((i + hold) * slot, v))
    pairs.append((dur, values[0] if wrap else values[-1]))
    return pairs


# ---------------------------------------------------------------------------
# The plate — modernShort geometry, in millimetres, out of _PlateSpec._short
# ---------------------------------------------------------------------------

W, H = 335.0, 155.0
CORNER, F_INSET, F_STROKE = 9.0, 5.0, 2.4
BAND_R, BAND_CAP, BAND_YS = 44.0, 15.0, [28.0, 51.0, 74.0]
FLAG_C, FLAG_W = (24.5, 120.0), 26.0
CONTENT = (74.0, 301.0)
ROWS = [(15.0, 55.0), (82.0, 60.0)]
BOLTS = [(59.0, 76.0), (313.0, 76.0)]
BOLT_R, SERIAL_MARK_X = 7.0, 325.0
F_RADIUS = CORNER - F_INSET * 0.5
INNER = F_INSET + F_STROKE * 0.5
DEPTH = 1.15
BACK_METAL = "#B9BEC4"

IRAQ = ("M 1 7 L 4 4 L 7 2 L 10 3 L 12 2 L 14.5 4 L 17 7 L 18 10.5 L 16.8 13 "
        "L 19 17 L 16 17.4 L 13 15 L 6 12 L 2 9 Z")


class Pal:
    """A colour that may cycle through a list of categories over the loop."""

    def __init__(self, cats, dur, hold=0.72):
        self.cats = cats if isinstance(cats, list) else [cats]
        self.dur = dur
        self.hold = hold

    @property
    def one(self):
        return self.cats[0]

    def paint(self, attr, fn):
        """Returns (initial_value, animation_markup) for `attr`."""
        vals = [fn(c) for c in self.cats]
        if len(set(vals)) == 1:
            return vals[0], ""
        return vals[0], animate(attr, self.dur, hold_schedule(vals, self.dur, self.hold), ease=False)


def el(tag, inner="", **attrs):
    a = "".join(' %s="%s"' % (k.replace("_", "-"), v) for k, v in attrs.items() if v is not None)
    return "<%s%s>%s</%s>" % (tag, a, inner, tag) if inner else "<%s%s/>" % (tag, a)


def emboss(uid, use_id, stroke_w, face_fn, ground_fn, pal, back=False, depth_scale=1.0, grad_span=None):
    """The four-layer relief, exactly as `_emboss` stacks it."""
    d = DEPTH * depth_scale
    s = -1.0 if back else 1.0
    gid = "%s-g" % use_id
    out = []

    def use(dx, dy, stroke, anim="", **extra):
        return el(
            "use", anim,
            href="#" + use_id,
            transform="translate(%s %s)" % (fmt(dx), fmt(dy)) if (dx or dy) else None,
            fill="none", stroke=stroke, stroke_width=fmt(stroke_w),
            stroke_linecap="butt", stroke_linejoin="round", stroke_miterlimit="2",
            **extra,
        )

    out.append(use(d * 1.45 * s, d * 1.85 * s, "#000000",
                   opacity="0.20" if back else "0.30", filter="url(#%s-blur)" % uid))

    c2, a2 = pal.paint("stroke", lambda c: darken(ground_fn(c), 0.42))
    out.append(use(d * 0.85 * s, d * 1.0 * s, c2, a2))

    c3, a3 = pal.paint("stroke", lambda c: lighten(ground_fn(c), 0.75))
    out.append(use(-d * 0.5 * s, -d * 0.62 * s, c3, a3))

    if grad_span:
        y0, y1 = grad_span
        stops = []
        for off, f in ((0, lambda c: lighten(face_fn(c), 0.16)),
                       (0.45, face_fn),
                       (1, lambda c: darken(face_fn(c), 0.25))):
            col, anim = pal.paint("stop-color", f)
            stops.append(el("stop", anim, offset=fmt(off), stop_color=col))
        out.append(el("defs", el("linearGradient", "".join(stops), id=gid,
                                 gradientUnits="userSpaceOnUse",
                                 x1="0", y1=fmt(y0), x2="0", y2=fmt(y1))))
        out.append(use(0, 0, "url(#%s)" % gid))
    else:
        c4, a4 = pal.paint("stroke", face_fn)
        out.append(use(0, 0, c4, a4))
    return "".join(out)


def glyph_defs(uid, run, tag):
    """A `<g>` per glyph plus one holding the whole run, ready for `<use>`."""
    per, whole = [], []
    for i, (ch, x, y, sc, _) in enumerate(run):
        d = GLYPHS.get(ch.upper())
        if not d:
            continue
        p = el("path", d=d, transform="translate(%s %s) scale(%s)" % (fmt(x), fmt(y), fmt(sc)),
               vector_effect=None)
        per.append(el("g", p, id="%s-%s%d" % (uid, tag, i)))
        whole.append(el("use", href="#%s-%s%d" % (uid, tag, i)))
    return "".join(per), el("g", "".join(whole), id="%s-%s" % (uid, tag))


def stamp_wrap(inner, cx, cy, dur, t0, drop=0.34):
    """A die coming down: the character lands, squashes flat, settles."""
    a = animate("transform", dur, [(0, "1 1"), (t0, "1.14 1.22"), (t0 + drop, "0.985 0.97"),
                                   (t0 + drop + 0.16, "1 1"), (dur, "1 1")], kind="scale")
    o = animate("opacity", dur, [(0, 0), (max(0, t0 - 0.001), 0), (t0 + 0.1, 1), (dur, 1)], ease=False)
    g = el("g", inner, transform="translate(%s %s)" % (fmt(-cx), fmt(-cy)))
    g = el("g", g + a, transform="translate(%s %s)" % (fmt(cx), fmt(cy)))
    return el("g", g + o)


def plate(uid, gov="11", letter="A", serial="70634", cats="private", band_text="IRQ",
          back=False, dur=10.0, stamp=None, sweep=None, security=True, hold=0.72):
    """One photoreal plate, as a `<g>` in millimetre space (335 × 155)."""
    pal = Pal([CAT[c] if isinstance(c, str) else c for c in
               (cats if isinstance(cats, list) else [cats])], dur, hold)
    one = pal.one
    ground_fn = (lambda c: BACK_METAL) if back else (lambda c: c["field"])
    ink_fn = (lambda c: darken(BACK_METAL, 0.10)) if back else (lambda c: c["fieldInk"])
    frame_fn = (lambda c: darken(BACK_METAL, 0.10)) if back else (
        lambda c: "#E9ECEE" if c["id"] in ("security", "defence") else "#14171A")

    o, defs = [], []
    defs.append(el("filter", el("feGaussianBlur", stdDeviation=fmt(DEPTH * 1.3)),
                   id="%s-blur" % uid, x="-40%", y="-40%", width="180%", height="180%"))
    defs.append(el("clipPath", el("rect", x="0", y="0", width=fmt(W), height=fmt(H),
                                  rx=fmt(CORNER), ry=fmt(CORNER)), id="%s-clip" % uid))
    defs.append(el("clipPath", el("rect", x=fmt(INNER), y=fmt(INNER), width=fmt(W - 2 * INNER),
                                  height=fmt(H - 2 * INNER), rx=fmt(F_RADIUS), ry=fmt(F_RADIUS)),
                   id="%s-inner" % uid))

    # field
    fc, fa = pal.paint("stop-color", lambda c: lighten(ground_fn(c), 0.55 if back else 0.16))
    fc2, fa2 = pal.paint("stop-color", ground_fn)
    fc3, fa3 = pal.paint("stop-color", lambda c: darken(ground_fn(c), 0.10))
    defs.append(el("linearGradient",
                   el("stop", fa, offset="0", stop_color=fc)
                   + el("stop", fa2, offset="0.55", stop_color=fc2)
                   + el("stop", fa3, offset="1", stop_color=fc3),
                   id="%s-field" % uid, x1="0", y1="0", x2="0", y2="1"))

    body = []
    body.append(el("rect", x="0", y="0", width=fmt(W), height=fmt(H),
                   rx=fmt(CORNER), ry=fmt(CORNER), fill="url(#%s-field)" % uid))

    if back:
        # rolled aluminium: fine horizontal brushing
        lines = "".join(el("path", d="M 0 %s H %s" % (fmt(y), fmt(W)), stroke="#000000",
                           stroke_width="0.3", opacity="0.05") for y in range(3, int(H), 5))
        body.append(el("g", lines))
    else:
        if security:
            micro = el("g",
                       "".join(el("rect", x=fmt(i * 4.6), y="0", width="2.6", height="0.9", rx="0.3")
                               for i in range(6)),
                       fill=one["fieldInk"], opacity="0.07")
            defs.append(el("pattern", micro, id="%s-micro" % uid, width="27.6", height="7.4",
                           patternUnits="userSpaceOnUse"))
            defs.append(el("pattern",
                           el("path", d=IRAQ, fill=one["fieldInk"], opacity="0.04",
                              transform="translate(6 5) scale(1.15)"),
                           id="%s-map" % uid, width="52", height="38", patternUnits="userSpaceOnUse"))
            body.append(el("rect", x="0", y="0", width=fmt(W), height=fmt(H),
                           fill="url(#%s-micro)" % uid))
            body.append(el("rect", x="0", y="0", width=fmt(W), height=fmt(H),
                           fill="url(#%s-map)" % uid))
            wave = " ".join("Q %s %s %s %s" % (fmt(x + 11), fmt(120 + (14 if (x // 22) % 2 else -14)),
                                               fmt(x + 22), fmt(120)) for x in range(44, 320, 22))
            body.append(el("path", d="M 44 120 " + wave, fill="none", stroke=one["fieldInk"],
                           stroke_width="0.5", opacity="0.06"))
        # side band, clipped to the inside of the frame
        bc, ba = pal.paint("stop-color", lambda c: lighten(c["band"], 0.24))
        bc2, ba2 = pal.paint("stop-color", lambda c: c["band"])
        bc3, ba3 = pal.paint("stop-color", lambda c: darken(c["band"], 0.14))
        defs.append(el("linearGradient",
                       el("stop", ba, offset="0", stop_color=bc)
                       + el("stop", ba2, offset="0.45", stop_color=bc2)
                       + el("stop", ba3, offset="1", stop_color=bc3),
                       id="%s-bandfill" % uid, x1="0", y1="0", x2="0", y2="1"))
        body.append(el("g", el("rect", x="0", y="0", width=fmt(BAND_R), height=fmt(H),
                               fill="url(#%s-bandfill)" % uid), clip_path="url(#%s-inner)" % uid))

    # broad diagonal highlight
    defs.append(el("linearGradient",
                   el("stop", offset="0", stop_color="#ffffff", stop_opacity="0.34")
                   + el("stop", offset="0.34", stop_color="#ffffff", stop_opacity="0")
                   + el("stop", offset="0.56", stop_color="#ffffff", stop_opacity="0.16")
                   + el("stop", offset="0.9", stop_color="#ffffff", stop_opacity="0"),
                   id="%s-spec" % uid, x1="0", y1="0", x2="1", y2="1"))
    body.append(el("rect", x="0", y="0", width=fmt(W), height=fmt(H), fill="url(#%s-spec)" % uid))

    o.append(el("g", "".join(body), clip_path="url(#%s-clip)" % uid))

    # frame + band divider
    frame_d = ("M %s %s H %s A %s %s 0 0 1 %s %s V %s A %s %s 0 0 1 %s %s H %s "
               "A %s %s 0 0 1 %s %s V %s A %s %s 0 0 1 %s %s Z") % (
        fmt(INNER + F_RADIUS), fmt(INNER), fmt(W - INNER - F_RADIUS),
        fmt(F_RADIUS), fmt(F_RADIUS), fmt(W - INNER), fmt(INNER + F_RADIUS),
        fmt(H - INNER - F_RADIUS), fmt(F_RADIUS), fmt(F_RADIUS), fmt(W - INNER - F_RADIUS),
        fmt(H - INNER), fmt(INNER + F_RADIUS), fmt(F_RADIUS), fmt(F_RADIUS), fmt(INNER),
        fmt(H - INNER - F_RADIUS), fmt(INNER + F_RADIUS), fmt(F_RADIUS), fmt(F_RADIUS),
        fmt(INNER + F_RADIUS), fmt(INNER))
    defs.append(el("g", el("path", d=frame_d) + el("path", d="M %s %s V %s" % (
        fmt(BAND_R), fmt(F_INSET + F_STROKE), fmt(H - F_INSET - F_STROKE))), id="%s-frame" % uid))
    o.append(emboss(uid, "%s-frame" % uid, F_STROKE, frame_fn, ground_fn, pal,
                    back=back, depth_scale=0.55))

    if not back:
        # IRQ / KR, stacked down the band
        letters = list(band_text)
        ys = BAND_YS if len(letters) == 3 else (
            [BAND_YS[0] + (BAND_YS[-1] - BAND_YS[0]) * i / (len(letters) - 1) for i in range(len(letters))]
            if len(letters) > 1 else [(BAND_YS[0] + BAND_YS[-1]) / 2])
        sc = BAND_CAP / CAP_U
        run = [(ch, BAND_R / 2 - advance_of(ch) * sc / 2, y, sc, 0) for ch, y in zip(letters, ys)]
        per, whole = glyph_defs(uid, run, "bandtxt")
        defs.append(per + whole)
        band_ink = (lambda c: c["bandInk"] if c["band"] != CAT["private"]["band"] else c["fieldInk"])
        band_ground = (lambda c: c["band"])
        o.append(emboss(uid, "%s-bandtxt" % uid, STROKE_U, band_ink, band_ground, pal, depth_scale=0.45))

        # flag tile
        fx, fy = FLAG_C[0] - FLAG_W / 2, FLAG_C[1] - FLAG_W / 3
        fh = FLAG_W * 2 / 3
        flag = (el("rect", x=fmt(fx), y=fmt(fy), width=fmt(FLAG_W), height=fmt(fh / 3), fill="#CE1126")
                + el("rect", x=fmt(fx), y=fmt(fy + fh / 3), width=fmt(FLAG_W), height=fmt(fh / 3), fill="#F5F5F5")
                + el("rect", x=fmt(fx), y=fmt(fy + 2 * fh / 3), width=fmt(FLAG_W), height=fmt(fh / 3), fill="#14171A"))
        for i in range(3):
            flag += el("rect", x=fmt(fx + FLAG_W * (0.22 + i * 0.22)), y=fmt(fy + fh * 0.42),
                       width=fmt(FLAG_W * 0.13), height=fmt(fh * 0.16), rx="0.4", fill="#007A3D")
        flag += el("rect", x=fmt(fx), y=fmt(fy), width=fmt(FLAG_W), height=fmt(fh), fill="none",
                   stroke=one["bandInk"] if one["band"] != CAT["private"]["band"] else "#14171A",
                   stroke_width="0.6", opacity="0.55")
        o.append(el("g", flag))

        # vertical die stamp by the right edge
        o.append(el("g", "".join(el("rect", x=fmt(SERIAL_MARK_X), y=fmt(112 + i * 3.2),
                                    width="2.6", height="1.2", rx="0.3") for i in range(6)),
                    fill=one["fieldInk"], opacity="0.14"))

    # the registration itself
    top_row, bottom_row = ROWS
    run_top, _ = layout_run(gov, top_row[1], top_row[0], CONTENT[0], CONTENT[1], "left", 0.06)
    run_let, _ = layout_run(letter, top_row[1], top_row[0], CONTENT[0],
                            CONTENT[1] - (CONTENT[1] - CONTENT[0]) * 0.13, "right", 0.0)
    run_ser, _ = layout_run(serial, bottom_row[1], bottom_row[0], CONTENT[0], CONTENT[1], "center", 0.02)
    runs = [("t", run_top, top_row), ("l", run_let, top_row), ("s", run_ser, bottom_row)]

    order = []
    for tag, run, row in runs:
        per, whole = glyph_defs(uid, run, tag)
        defs.append(per)
        if stamp is None:
            defs.append(whole)
            o.append(emboss(uid, "%s-%s" % (uid, tag), STROKE_U, ink_fn, ground_fn,
                            pal, back=back, grad_span=(row[0], row[0] + row[1])))
        else:
            for i, (ch, x, y, sc, adv) in enumerate(run):
                order.append(("%s%d" % (tag, i), x + adv / 2, y + row[1] / 2, sc, row))

    if stamp is not None:
        t0, step = stamp
        order.sort(key=lambda g: (g[4][0], g[1]))
        for i, (gid, cx, cy, sc, row) in enumerate(order):
            body = emboss(uid, "%s-%s" % (uid, gid), STROKE_U, ink_fn, ground_fn, pal,
                          back=back, grad_span=(row[0], row[0] + row[1]))
            o.append(stamp_wrap(body, cx, cy, dur, t0 + i * step))

    # rivets
    defs.append(el("radialGradient",
                   el("stop", offset="0", stop_color="#FDFDFD")
                   + el("stop", offset="0.55", stop_color="#D3D8DC")
                   + el("stop", offset="1", stop_color="#8F969D"),
                   id="%s-bolt" % uid, cx="0.36", cy="0.32", r="0.75"))
    for bx, by in BOLTS:
        if back:
            o.append(el("circle", cx=fmt(bx), cy=fmt(by), r=fmt(BOLT_R * 0.32), fill="#5C6268"))
        else:
            o.append(el("circle", cx=fmt(bx), cy=fmt(by), r=fmt(BOLT_R), fill="url(#%s-bolt)" % uid))
            o.append(el("circle", cx=fmt(bx), cy=fmt(by), r=fmt(BOLT_R), fill="none",
                        stroke="#000000", stroke_width="0.5", opacity="0.25"))

    # the light travelling over the sheeting
    if sweep:
        passes = sweep if isinstance(sweep[0], (tuple, list)) else [sweep]
        defs.append(el("linearGradient",
                       el("stop", offset="0", stop_color="#ffffff", stop_opacity="0")
                       + el("stop", offset="0.45", stop_color="#ffffff", stop_opacity="0.5")
                       + el("stop", offset="0.55", stop_color="#ffffff", stop_opacity="0.5")
                       + el("stop", offset="1", stop_color="#ffffff", stop_opacity="0"),
                       id="%s-sweep" % uid, x1="0", y1="0", x2="1", y2="0"))
        bars = ""
        for s0, s1 in passes:
            move = animate("transform", dur, [(0, -190), (s0, -190), (s1, W + 130), (dur, W + 130)],
                           kind="translate", ease=False)
            bars += el("rect", move, x="0", y="-60", width="90", height=fmt(H + 120),
                       fill="url(#%s-sweep)" % uid, transform="skewX(-18)")
        o.append(el("g", bars, clip_path="url(#%s-clip)" % uid, opacity="0.75"))

    return el("defs", "".join(defs)) + "".join(o)


# ---------------------------------------------------------------------------
# Page furniture
# ---------------------------------------------------------------------------

MONO = "ui-monospace,'SF Mono','Cascadia Code',Menlo,Consolas,monospace"
SANS = "-apple-system,'Segoe UI',Inter,Roboto,Helvetica,Arial,sans-serif"
ARAB = "'Segoe UI','Geeza Pro','Noto Naskh Arabic','Noto Sans Arabic',Tahoma,sans-serif"

BG = "#0B0E13"
DIM = "#7C8794"
BRIGHT = "#EDF1F5"


def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def text(x, y, s, size=16, fill=BRIGHT, family=SANS, weight=None, anchor=None,
         spacing=None, opacity=None, anim="", **extra):
    return el("text", esc(s) + anim, x=fmt(x), y=fmt(y), font_family=family,
              font_size=fmt(size), fill=fill, font_weight=weight, text_anchor=anchor,
              letter_spacing=spacing, opacity=opacity, **extra)


def svg(w, h, label, inner):
    return ('<svg xmlns="http://www.w3.org/2000/svg" width="%s" height="%s" '
            'viewBox="0 0 %s %s" role="img" aria-label="%s">%s</svg>'
            % (fmt(w), fmt(h), fmt(w), fmt(h), esc(label), inner))


def backdrop(w, h, r=20):
    d = []
    d.append(el("defs",
                el("radialGradient", el("stop", offset="0", stop_color="#1B7F44", stop_opacity="0.20")
                   + el("stop", offset="1", stop_color="#1B7F44", stop_opacity="0"),
                   id="glow-a", cx="0.14", cy="0.12", r="0.62")
                + el("radialGradient", el("stop", offset="0", stop_color="#C8102E", stop_opacity="0.16")
                     + el("stop", offset="1", stop_color="#C8102E", stop_opacity="0"),
                     id="glow-b", cx="0.88", cy="0.9", r="0.6")))
    for f in ("%s" % BG, "url(#glow-a)", "url(#glow-b)"):
        d.append(el("rect", x="0", y="0", width=fmt(w), height=fmt(h), rx=fmt(r), fill=f))
    d.append(el("rect", x="0.5", y="0.5", width=fmt(w - 1), height=fmt(h - 1), rx=fmt(r - 0.5),
                fill="none", stroke="#1D232C"))
    return "".join(d)


def enter(dur, t0, dy=14):
    """Fade and rise into place, then hold for the rest of the loop."""
    return (animate("opacity", dur, [(0, 0), (t0, 0), (t0 + 0.55, 1), (dur, 1)])
            + animate("transform", dur, [(0, "0 %s" % fmt(dy)), (t0, "0 %s" % fmt(dy)),
                                         (t0 + 0.7, "0 0"), (dur, "0 0")], kind="translate"))


def chip(x, y, s, w=None, size=12.5, fill=DIM, stroke="#232A33", dur=None, t0=None):
    w = w or len(s) * size * 0.66 + 26
    g = (el("rect", x=fmt(x), y=fmt(y), width=fmt(w), height="27", rx="13.5",
            fill="#11161D", stroke=stroke)
         + text(x + 13, y + 18, s, size=size, fill=fill, family=MONO))
    return el("g", g + (enter(dur, t0) if dur else ""))


# ---------------------------------------------------------------------------
# 1. banner.svg — the plate stamps itself, then the light rolls over it
# ---------------------------------------------------------------------------


def banner():
    w, h, dur = 1280, 360, 16.0
    o = [backdrop(w, h)]

    o.append(el("g", text(72, 96, "FLUTTER PACKAGE", size=12, fill="#5E6B79",
                          family=MONO, weight="600", spacing="4.6") + enter(dur, 0.15)))
    o.append(el("defs", el("linearGradient",
                           el("stop", offset="0", stop_color="#FFFFFF")
                           + el("stop", offset="0.62", stop_color="#CBD5DF")
                           + el("stop", offset="1", stop_color="#7E8B99"),
                           id="title", x1="0", y1="0", x2="1", y2="1")))
    o.append(el("g", text(70, 156, "iraqi_license_plate", size=45, fill="url(#title)",
                          family=MONO, weight="700") + enter(dur, 0.3)))
    o.append(el("g", text(72, 202, "Photoreal Iraqi registration plates, drawn by one CustomPainter.",
                          size=17.5, fill="#9AA6B3") + enter(dur, 0.45)))
    o.append(el("g", text(72, 230, "Every millimetre traceable to the physical blank.",
                          size=17.5, fill="#63707E") + enter(dur, 0.55)))

    x = 72
    for i, (s, w_) in enumerate((("zero dependencies", 152), ("no images", 106),
                                 ("no fonts", 96), ("no network", 112))):
        o.append(chip(x, 262, s, w=w_, dur=dur, t0=0.7 + i * 0.09))
        x += w_ + 10

    scale = 1.62
    px, py = 700.0, 62.0
    o.append(el("ellipse", cx=fmt(px + W * scale / 2), cy=fmt(py + H * scale + 26),
                rx=fmt(W * scale * 0.44), ry="16", fill="#000000", opacity="0.5"))
    body = plate("bn", cats="private", dur=dur, stamp=(0.55, 0.105), sweep=[(2.2, 5.4), (8.8, 12.0)])
    o.append(el("g", body, transform="translate(%s %s) scale(%s)" % (fmt(px), fmt(py), fmt(scale))))

    o.append(el("g", text(704, 340, "IraqiLicensePlate(plate: IraqiPlate.reference, width: 220)",
                          size=14.5, fill="#5A6773", family=MONO) + enter(dur, 1.7)))
    return svg(w, h, "iraqi_license_plate — an Iraqi plate stamping itself, character by character", "".join(o))


# ---------------------------------------------------------------------------
# 2. categories.svg — the band colour walking through PlateCategory
# ---------------------------------------------------------------------------


def categories():
    w, h, dur = 1200, 440, 20.0
    slot = dur / 8
    o = [backdrop(w, h)]
    o.append(text(60, 54, "PlateCategory", size=19, fill=BRIGHT, family=MONO, weight="700"))
    o.append(text(212, 54, "— the category is the colour of the band, not of the plate",
                 size=14.5, fill="#5E6B79"))

    scale = 1.62
    px, py = 52.0, 96.0
    o.append(el("ellipse", cx=fmt(px + W * scale / 2), cy=fmt(py + H * scale + 22),
                rx=fmt(W * scale * 0.44), ry="14", fill="#000000", opacity="0.45"))
    cats = [c[0] for c in CATEGORIES]
    body = plate("ct", cats=cats, dur=dur, sweep=None)
    o.append(el("g", body, transform="translate(%s %s) scale(%s)" % (fmt(px), fmt(py), fmt(scale))))

    lx, ly, step = 656.0, 104.0, 38.0
    rows = []
    ys = [ly + i * step for i in range(8)]
    marker = el("rect",
                animate("y", dur, hold_schedule([fmt(y - 20) for y in ys], dur, 0.86, wrap=False), ease=False)
                + animate("stroke", dur, hold_schedule([lighten(CAT[c]["band"], 0.3) for c in cats], dur, 0.86,
                                                     wrap=False), ease=False),
                x=fmt(lx - 14), y=fmt(ys[0] - 20), width="510", height="30", rx="8",
                fill="#141A22", stroke=lighten(CAT[cats[0]]["band"], 0.3), stroke_opacity="0.6")
    rows.append(marker)
    for i, key in enumerate(cats):
        c, y = CAT[key], ys[i]
        lo, hi = 0.3, 1.0
        pairs = [(0, hi if i == 0 else lo)]
        if i:
            pairs += [(max(0.001, i * slot - 0.25), lo), (i * slot + 0.2, hi)]
        pairs += [((i + 0.86) * slot, hi), ((i + 1) * slot, lo)]
        pairs += [(dur - 0.35, lo), (dur, hi)] if i == 0 else [(dur, lo)]
        a = animate("opacity", dur, pairs, ease=False)
        dot = (el("rect", x=fmt(lx), y=fmt(y - 13), width="16", height="16", rx="4",
                  fill=c["band"], stroke="#59636D")
               if key != "private" else
               el("rect", x=fmt(lx), y=fmt(y - 13), width="16", height="16", rx="4",
                  fill="#E8EAEC", stroke="#8A939C"))
        g = (dot
             + text(lx + 28, y, c["id"], size=15, fill=BRIGHT, family=MONO)
             + text(lx + 208, y, c["en"], size=14, fill="#8B96A2")
             + text(lx + 468, y, c["ar"], size=15, fill="#8B96A2", family=ARAB, anchor="end")
             + a)
        rows.append(el("g", g))
    o.append("".join(rows))
    o.append(text(60, 424, "security and defence recolour the whole field — everything else keeps "
                           "the white plate and moves only the band", size=15, fill="#586573"))
    return svg(w, h, "The eight PlateCategory values cycling through the side band of one plate", "".join(o))


# ---------------------------------------------------------------------------
# 4. anatomy.svg — what tryParse takes, and what the three fields are
# ---------------------------------------------------------------------------


def anatomy():
    w, h, dur = 1200, 400, 12.0
    o = [backdrop(w, h)]
    o.append(text(56, 52, "IraqiPlate.tryParse", size=19, fill=BRIGHT, family=MONO, weight="700"))
    o.append(text(296, 52, "— four spellings, one registration", size=14.5, fill="#5E6B79"))

    o.append(el("rect", x="56", y="76", width="520", height="82", rx="12",
                fill="#10151C", stroke="#1D232C"))
    variants = ["'11 A 70634'", "'11A70634'", "'11-A-70634'", "'١١ A ٧٠٦٣٤'"]
    for i, v in enumerate(variants):
        a = animate("opacity", dur, [(0, 1 if i == 0 else 0), (i * 3, 1), ((i + 1) * 3, 0),
                                     (dur, 1 if i == 0 else 0)], ease=False)
        a = a.replace("<animate", '<animate calcMode="discrete"', 1)
        fam = ARAB if i == 3 else MONO
        o.append(el("g", text(84, 128, v, size=27, fill="#DCE4EC", family=fam) + a))
    o.append(el("rect", animate("opacity", dur, [(0, 0.15), (0.5, 0.9), (1.0, 0.15)], ease=False,
                               repeat="indefinite").replace('dur="12s"', 'dur="1.1s"'),
                x="536", y="106", width="12", height="30", fill="#34E3D0", opacity="0.6"))

    o.append(text(56, 196, "↓", size=20, fill="#3C4854", family=MONO))
    o.append(text(84, 196, "returns null rather than throwing, so a bad string degrades",
                 size=15, fill="#5A6773"))

    scale = 1.612
    px, py = 620.0, 84.0
    body = plate("an", cats="private", dur=dur, sweep=(6.5, 10.5))

    # the highlight travels between the three fields of the registration
    top_row, bottom_row = ROWS
    r_gov, _ = layout_run("11", top_row[1], top_row[0], CONTENT[0], CONTENT[1], "left", 0.06)
    r_let, _ = layout_run("A", top_row[1], top_row[0], CONTENT[0],
                          CONTENT[1] - (CONTENT[1] - CONTENT[0]) * 0.13, "right", 0.0)
    r_ser, _ = layout_run("70634", bottom_row[1], bottom_row[0], CONTENT[0], CONTENT[1], "center", 0.02)

    def box(run, row, pad=4.0):
        x0 = run[0][1] + 1
        x1 = run[-1][1] + run[-1][4] - 1
        return (x0 - pad, row[0] - pad, x1 - x0 + 2 * pad, row[1] + 2 * pad)

    boxes = [box(r_gov, top_row), box(r_let, top_row), box(r_ser, bottom_row)]
    marks = ""
    for i, attr in enumerate(("x", "y", "width", "height")):
        marks += animate(attr, dur, hold_schedule([fmt(b[i]) for b in boxes], dur, 0.8), ease=False)
    body += el("rect", marks, x=fmt(boxes[0][0]), y=fmt(boxes[0][1]), width=fmt(boxes[0][2]),
               height=fmt(boxes[0][3]), rx="3", fill="none",
               stroke="#34E3D0", stroke_width="1.3", stroke_opacity="0.9")
    o.append(el("g", body, transform="translate(%s %s) scale(%s)" % (fmt(px), fmt(py), fmt(scale))))

    fields = [("governorate", "11", "IraqGovernorate.baghdad · band IRQ"),
              ("letter", "A", "a block, not a vehicle type"),
              ("serial", "70634", "up to five digits")]
    for i, (name, val, note) in enumerate(fields):
        y = 244 + i * 44
        pairs = [(0, 1.0 if i == 0 else 0.32)]
        if i:
            pairs += [(max(0.001, i * 4 - 0.3), 0.32), (i * 4 + 0.2, 1.0)]
        pairs += [((i + 0.8) * 4, 1.0), ((i + 1) * 4, 0.32)]
        pairs += [(dur - 0.35, 0.32), (dur, 1.0)] if i == 0 else [(dur, 0.32)]
        a = animate("opacity", dur, pairs, ease=False)
        g = (el("rect", x="56", y=fmt(y - 22), width="520", height="34", rx="8", fill="#141A22")
             + text(72, y, name, size=14, fill="#7E8B99", family=MONO)
             + text(232, y, val, size=15, fill="#34E3D0", family=MONO, weight="700")
             + text(330, y, note, size=14, fill="#75818E")
             + a)
        o.append(el("g", g))
    return svg(w, h, "Every spelling tryParse accepts, and the three fields of an Iraqi registration",
               "".join(o))


# ---------------------------------------------------------------------------

ART = {"banner.svg": banner, "categories.svg": categories, "anatomy.svg": anatomy}

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for name, fn in ART.items():
        path = os.path.join(OUT, name)
        with open(path, "w", encoding="utf-8") as f:
            f.write(fn())
        print("%-16s %6.1f kB" % (name, os.path.getsize(path) / 1024))
