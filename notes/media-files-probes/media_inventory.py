#!/usr/bin/env python3
"""media_inventory.py -- every picture, sound and MIDI item in the sources, and the standalone file behind it.

QUESTION IT ANSWERS
  "For every tree of the data census, which items are pictures, PCM recordings, fonts drawn as bitmaps or
   MIDI streams, and does a file that an ordinary viewer or sound program opens (PNG, JPEG, BMP, WAV, MID)
   back each one in the build, or does the source still hold or pull the bytes some other way?"
  Set up 2026-10-30 (lane media-files) for the owner's request: "'Media: pictures and PCM' <== I want these
  to be represented as standalone files that could be opened by the user on normal media viewers / sound
  apps.  Then included in the source listing (maybe with a lossless conversion step if necessary)".

WHAT IT READS
  1. Every `.incbin` of every census tree, through scripts/analysis/data_incbin_census.py (its TREES, its
     classes and markers).  An include is a media item when
       - its file is a media file (class `media`: .png .jpg .bmp .wav .mid ...), or
       - its marker names a media file it is made from (`census: generated -- <tool>, from <file>.png`,
         "from the .png beside it"; the census's `from_media` flag), or
       - it is declared `census: opaque -- pcm` (a PCM body still read from a dump: NOT backed), or
       - its label or path or marker reads like a picture or a sound (vocabulary below) and none of the
         above holds: NOT backed, until it is converted or given a verdict in REVIEWED.
     A backed item names its file; the probe says whether that file is on disk now (WAVs are git-ignored
     and appear after `make waveform-wav` / `make -C kn7000 wave-wav` or a build).
  2. The WSA1R's pictures and fonts, which are `.byte` rows checked against committed PNGs by
     wsa1/scripts/build/wsa1_bitmaps.py and wsa1_fonts.py (`check`, run by `make gate-wsa1`): their manifests
     are imported.  The ranges wsa1_bitmaps.py REFUSES (geometry not established) are listed as such.
  3. Typed rows (`.byte` / `.word` / `tab_u8` ... after a label, no `.incbin`) whose label reads like a
     picture or a sound: each must be covered by 2. or carry a verdict in REVIEWED, else it is reported
     as a candidate.  This is a name heuristic: a picture under a name that says nothing is not seen.

VOCABULARY  Bitmap Glyph Font Icon Picture Pixels Logo Wallpaper Image Sprite Cursor Pcm PCM Sample Wave

OUTPUT
  A table per tree (pictures / sounds / MIDI: backed, not backed) and, below it, every item not backed and
  every candidate without a verdict.  Exit 1 when either list is not empty.  --list prints every item.

RUN
  python3 notes/media-files-probes/media_inventory.py            (about 30 s; build the trees first so the
                                                                   generated files exist, or the "on disk"
                                                                   column reads no)
  python3 notes/media-files-probes/media_inventory.py --list
"""
import argparse
import importlib.util
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


CEN = load("data_incbin_census", ROOT / "scripts/analysis/data_incbin_census.py")
PICT_EXT = {"png", "jpg", "jpeg", "bmp", "gif", "tif", "tiff"}
SOUND_EXT = {"wav", "aif", "aiff"}
MIDI_EXT = {"mid"}
VOC = re.compile(r'(Bitmap|Glyph|Font|Icon|Picture|Pixels|Logo|Wallpaper|Image|Sprite|Cursor)')
# compiled C (KN5000 `includes/generated/`) holds the GUI's records, whose labels name picture classes
# (`NakaWidget_..._Icon`, `..._CursorBox`); there only a name that says "pixels" counts
PIXELS = re.compile(r'(Bitmap\d+x\d+|_Pixels\b|Glyphs\b)')
SOUND = re.compile(r'(\bpcm\b|\bsample data\b|\.wav\b)', re.I)
FROM = re.compile(r'\bfrom\s+(?:the\s+\.(\w+)\s+beside it|(\S+?\.(\w+)))(?=[\s:;,)]|$)', re.I)
LAB = re.compile(rb'^([A-Za-z_][\w.]*):(.*)$')
DATA = re.compile(rb'^\s*(\.byte|\.short|\.hword|\.word|\.long|\.2byte|\.4byte|tab_[us](?:8|16|32)|\.ascii|\.asciz|db|dw)\b')
INSTR = re.compile(rb'^\s+[a-z]')
ADDR_HINT = re.compile(rb';\s*(?:0x)?([0-9A-F]{6})\b')

# Verdicts for typed-row candidates and media-looking includes that are not media.  (regex on the label,
# verdict).  "picture" verdicts would be pictures without a file; none is left.
REVIEWED = [
    (r'((^|_)Palette(_\w+)?|ShadeRamp|^WallpaperRamp_\w+)$',
     "a palette (colour table), not a picture; the pictures' PNGs carry their palettes"),
    (r'^(AccWave_BankTable|BrassSound_SamplePtr_Table|PercInst_\d+_Wave\d+|ToneRec_\w+_WaveSel\d|'
     r'Eff2[67]_WaveReverb\d_Param\w+|DspFxRecs_26_WaveReverb1|SineWaveWindowProc\w*|TestSampleFunc\w*)$',
     "parameter or pointer records of a sound or an effect; 'Wave' / 'Sample' names the sound, the rows hold no samples"),
    (r'^(AcSndImageProc_Table|DrawBitmapSPFast16_Impl\w*_Table|DrawIcons_PixelPairTable|ResBitmapTable|ResIconTable|'
     r'ResFontTable|ResFont05Kern|Font5_KernTable|FontDescriptor_Table|FontTable|IconBitmapNamePtrTable|'
     r'IconIDProc_NameTable|OrganTabImages|RhythmImages|SoundImages|TcdImages|PictureDirectory|TableRomImageEnd|'
     r'VwIconListProc_Records|RoundCornerPixels|CMPMSPCMN_ResNames)$',
     "a directory, lookup, kerning or dispatch table about pictures or fonts, not pixels (the pixels it names are files)"),
    (r'^(DSP_DefaultEffectConfig_Image|SndParamRam_DefaultImage|WorkRamInit_Image|OldDataImage|FatMountFailImage)$',
     "an image of memory (initial values copied to RAM), not a picture"),
    (r'^Tbl_NoteValueGlyphs$', "LCD character codes (text), not pixels"),
    (r'^ToneGen_Voice_Active_Bitmap$', "a bit mask of active voices, not a picture"),
    (r'^(Display_CopyAndRenderBitmaps_Str_HK|NakaClass_PsCursorBox_PropNames|SeApplyConfirm_CursorRec)$',
     "strings or a record whose name mentions a picture class, not pixels"),
    (r'^NakaWidget_\w+_Bitmap$', "a NAKA GUI widget record (compiled C) of class Bitmap, not its pixels"),
    (r'^(UIState_RenderBitmapData)$', "code"),
    (r'^VersionScreen_Glyphs$', "WSA1R: the 208 bytes are Bitmap_F82BB0 + Bitmap_F82C00 of wsa1_bitmaps.py (PNG-backed)"),
    (r'^AcMixerVol_GroupIconBitmap$', "a table of icon numbers (sound group -> BitmapDescriptorTable index), not pixels"),
    (r'_Draw\w*Cursor_DL\d*$', "WSA1R: a display list (drawing commands for a cursor), not pixels"),
    (r'(_DataImage|ResetImage(_B)?|StageBImage(_B)?|NotePool8Image(_B)?|RamStateImage|BootRamImage_Head|'
     r'^DiskImage_HardDisk_\w+)$', "WSA1R: an image of memory or of a disk sector (initial values), not a picture"),
    (r'^(OldBuild2?_)?ValueGlyph_(Table|Quantiser|QuantiserTail)$',
     "WSA1R: the value glyphs' pointer table or quantiser, not pixels (the glyphs are PNG-backed)"),
    (r'^DLText_GlyphPairs_\w+$', "WSA1R: character codes of a display-list text, not pixels"),
    (r'^(ParamCursorRects|ParamCursorRect_Single|OctaveIcon_BlackKeyX|CurveBitmapSelector)$',
     "WSA1R: rectangles, key offsets or a pointer table about a picture, not pixels"),
    (r'^Bitmap_Drawbar[AB]$', "WSA1R: REFUSED by wsa1_bitmaps.py, its picture geometry is not established (listed below)"),
    (r'_(paintok|onoff|sel_num|aicok|cursor|list|selected)$', "a GUI object's state field, not pixels"),
    (r'^(FnName_|Str_|IconBitmapName_)', "a name or text string, not pixels"),
    (r'^SqStep_CellFlagGlyphs$', "three character codes (' ', '*', 0x91), not pixels"),
    (r'^ValueGlyph_Bitmaps$', "WSA1R: the 29 value glyphs, ValueGlyph_00..28 of wsa1_bitmaps.py (PNG-backed)"),
]


def tracked():
    out = subprocess.run(["git", "ls-files", "-z"], cwd=ROOT, capture_output=True, check=True).stdout
    return [p.decode() for p in out.split(b"\0") if p]


def verdict(label):
    for rx, v in REVIEWED:
        if re.search(rx, label):
            return v
    return None


def tree_of(path):
    for t, dirs in CEN.TREES.items():
        if any(path == d or path.startswith(d.rstrip("/") + "/") for d in dirs):
            return t
    return None


_LINES = {}


def lines_of(src):
    if src not in _LINES:
        _LINES[src] = (ROOT / src).read_bytes().split(b"\n")
    return _LINES[src]


def label_of(src, ln):
    lines = lines_of(src)
    m = LAB.match(lines[ln - 1])
    if m:
        return m.group(1).decode("latin-1")
    for k in range(ln - 2, max(ln - 14, -1), -1):
        m = LAB.match(lines[k])
        if m and not m.group(2).strip().startswith((b".incbin", b"\t.incbin")):
            return m.group(1).decode("latin-1")
    return ""


def resolve(name, src, tree):
    """the media file a marker names, on disk, or None"""
    cands = [ROOT / name, (ROOT / src).parent / name]
    for d in CEN.TREES.get(tree, []):
        base = ROOT / d
        base = base.parent if base.suffix == ".s" else base
        cands += [base / name, base / "includes" / name, base.parent / name, base.parent.parent / name]
    for c in cands:
        if c.is_file():
            return c
    return None


def incbin_items(res):
    items = []
    for tree, rows in res.items():
        for r in rows:
            path, why, cls = r["path"], r["why"], r["class"]
            ext = path.rsplit(".", 1)[-1].lower() if "." in path else ""
            lab = None
            kind, backed, file = None, None, None
            if cls == "media":
                kind = "picture" if ext in PICT_EXT else "sound" if ext in SOUND_EXT else "midi" if ext in MIDI_EXT else "other"
                backed, file = True, path
                on = CEN.locate(path, r["file"], CEN.TREES[tree], CEN.EXTRA_INCLUDE.get(tree, ())) is not None
            elif cls == "generated" and r.get("from_media"):
                m = FROM.search(why)
                if m and m.group(1):
                    mext = m.group(1).lower()
                    file = str(Path(path).with_suffix("." + mext))
                    f = resolve(file, r["file"], tree)
                else:
                    mext = (m.group(3) or "").lower() if m else ""
                    file = m.group(2) if m else "?"
                    f = resolve(file, r["file"], tree)
                kind = "picture" if mext in PICT_EXT else "sound" if mext in SOUND_EXT else "midi" if mext in MIDI_EXT else "other"
                backed, on = True, f is not None
            elif cls == "opaque" and why.startswith("pcm"):
                kind, backed, on = "sound", False, False
            else:
                lab = label_of(r["file"], r["line"])
                probe = f"{lab} {path} {why}"
                compiled = cls == "generated" and why == "compiled C"
                stem = Path(path).stem
                if (PIXELS.search(lab) if compiled else (VOC.search(probe) or SOUND.search(why))) \
                        and not verdict(lab) and not verdict(stem):
                    if re.search(r'midi|\.mid\b|smf', why, re.I):
                        kind = "midi"
                    elif SOUND.search(why):
                        kind = "sound"
                    else:
                        kind = "picture?"
                    backed, on = False, False
            if kind:
                items.append(dict(tree=tree, src=f'{r["file"]}:{r["line"]}', label=lab or label_of(r["file"], r["line"]),
                                  kind=kind, backed=backed, file=file, on_disk=on, size=r["size"] or 0, how="incbin"))
    return items


def c_bitmap_items():
    """the KN5000 maincpu pictures held as C initializers that scripts/build/c_bitmaps.py writes from PNGs"""
    cb = load("c_bitmaps", ROOT / "scripts/build/c_bitmaps.py")
    items = []
    for t, name in cb.items():
        p = cb.png_path(t, name)
        path, lines, i, j, d = cb.find(t, name)
        n = 1
        for x in d:
            n *= x
        items.append(dict(tree=f"kn5000-{t}", src=str(path.relative_to(ROOT)), label=name, kind="picture",
                          backed=True, file=str(p.relative_to(ROOT)), on_disk=p.is_file(), size=n,
                          how="C initializer written from PNG"))
    return items


def wsa1_items():
    sys.path.insert(0, str(ROOT / "wsa1/scripts/build"))
    wb = load("wsa1_bitmaps", ROOT / "wsa1/scripts/build/wsa1_bitmaps.py")
    wf = load("wsa1_fonts", ROOT / "wsa1/scripts/build/wsa1_fonts.py")
    items, ranges = [], []
    for e in wb.build_manifest():
        n = e["bc"] * e["hl"]
        p = wb.png_path(e)
        ranges.append((e["img"], e["addr"], e["addr"] + n))
        items.append(dict(tree="wsa1", src=f"prom_{e['img']} {e['addr']:#08x}", label=e["name"], kind="picture",
                          backed=True, file=str(p.relative_to(ROOT)), on_disk=p.is_file(), size=n,
                          how="rows checked against PNG"))
    for name, base, pitch, w, cells, svc, note in wf.FACES:
        p = wf.sheet_path(name)
        ranges.append(("b", base, base + pitch * cells))
        items.append(dict(tree="wsa1", src=f"prom_b {base:#08x}", label=name, kind="picture (font)", backed=True,
                          file=str(p.relative_to(ROOT)), on_disk=p.is_file(), size=pitch * cells,
                          how="rows checked against PNG"))
    refused = [(a, b) for a, b in wb.REFUSED]
    return items, ranges, refused


def row_candidates(files, wsa1_ranges):
    out = []
    for f in files:
        if not f.endswith((".s", ".inc")):
            continue
        tree = tree_of(f)
        if tree is None:
            continue
        L = (ROOT / f).read_bytes().split(b"\n")
        for i, l in enumerate(L):
            m = LAB.match(l)
            if not m or not VOC.search(m.group(1).decode("latin-1")):
                continue
            name = m.group(1).decode("latin-1")
            if name.startswith(("Str_", ".L", "FuncName", "IconName", "WidgetPropStr")) or b".incbin" in m.group(2):
                continue
            kind, n, hint = None, 0, None
            for k, x in enumerate([m.group(2)] + L[i + 1:i + 40]):
                if k > 0 and LAB.match(x):
                    break
                code = x.split(b";")[0].split(b"#")[0]
                if hint is None:
                    h = ADDR_HINT.search(x)
                    hint = int(h.group(1), 16) if h else None
                if not code.strip():
                    continue
                if b".incbin" in code:
                    kind = "incbin"
                    break
                if (DATA.match(code) if k > 0 else re.search(rb'(\.byte|\.short|\.word|\.long|tab_u8|tab_u16)\b', code)):
                    kind = "data"
                    n += code.count(b",") + 1
                elif k > 0 and INSTR.match(code):
                    kind = kind or "code"
                    break
            if kind != "data" or n < 16:
                continue
            if tree == "wsa1" and hint is not None:
                img = "a" if "/prom_a/" in f else "b" if "/prom_b/" in f else "c" if "/prom_c/" in f else "?"
                if any(i_ == img and a <= hint < b for i_, a, b in wsa1_ranges):
                    continue          # inside a PNG-backed WSA1R picture or font
            out.append(dict(tree=tree, src=f"{f}:{i + 1}", label=name, verdict=verdict(name), wsa1_hint=hint))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--list", action="store_true")
    a = ap.parse_args()
    res = CEN.census()
    c_items = c_bitmap_items()
    c_names = {it["label"] for it in c_items}
    items = [it for it in incbin_items(res) if it["label"] not in c_names] + c_items
    w_items, w_ranges, refused = wsa1_items()
    items += w_items
    cands = row_candidates(tracked(), w_ranges)
    by = defaultdict(lambda: defaultdict(lambda: [0, 0, 0, 0]))
    for it in items:
        k = it["kind"].split()[0].rstrip("?")
        c = by[it["tree"]][k]
        c[0 if it["backed"] else 1] += 1
        c[2 if it["backed"] else 3] += it["size"]
    kinds = ["picture", "sound", "midi"]
    head = ["tree"] + [f"{k}s backed" for k in kinds] + [f"{k}s NOT backed" for k in kinds]
    body = []
    for t in CEN.TREES:
        if t not in by:
            continue
        c = by[t]
        body.append([t] + [f"{c[k][0]} / {c[k][2]:,}" for k in kinds] + [f"{c[k][1]} / {c[k][3]:,}" for k in kinds])
    w = [max(len(r[i]) for r in [head] + body) for i in range(len(head))]
    print("items / bytes; backed = a standalone media file is the build's input (directly or through a converter)\n")
    print("| " + " | ".join(h.ljust(w[i]) for i, h in enumerate(head)) + " |")
    print("|" + "|".join("-" * (x + 2) for x in w) + "|")
    for r in body:
        print("| " + " | ".join(x.ljust(w[i]) for i, x in enumerate(r)) + " |")
    tot = [sum(1 for it in items if it["backed"]), sum(1 for it in items if not it["backed"])]
    print(f"\nall trees: {tot[0]} items backed by a standalone file, {tot[1]} not")
    missing = [it for it in items if it["backed"] and not it["on_disk"]]
    if missing:
        print(f"  ({len(missing)} backing files are not on disk now: generated ones appear after a build, "
              f"e.g. {missing[0]['file']})")
    bad = [it for it in items if not it["backed"]]
    if bad:
        print("\nNOT BACKED:")
        for it in bad:
            print(f"  {it['tree']:18} {it['kind']:9} {it['label']:40} {it['src']}")
    print(f"\nWSA1R pictures that wsa1_bitmaps.py refuses to draw (geometry not established; their bytes stay rows):")
    for what, why in refused:
        print(f"  {what}: {why[:140]}{'...' if len(why) > 140 else ''}")
    open_c = [c for c in cands if not c["verdict"]]
    print(f"\ntyped-row candidates (label reads like a picture or a sound): {len(cands)}, "
          f"{len(cands) - len(open_c)} with a verdict in REVIEWED, {len(open_c)} without")
    for c in open_c:
        print(f"  {c['tree']:18} {c['label']:40} {c['src']}" + (f"  (address {c['wsa1_hint']:#08x})" if c["wsa1_hint"] else ""))
    if a.list:
        print("\nEVERY ITEM:")
        for it in items:
            print(f"{it['tree']}\t{it['kind']}\t{'backed' if it['backed'] else 'NOT backed'}\t{it['label']}\t{it['src']}\t"
                  f"{it['file'] or '-'}\t{'on disk' if it['on_disk'] else 'not on disk'}\t{it['size']}\t{it['how']}")
        for c in cands:
            if c["verdict"]:
                print(f"{c['tree']}\tcandidate\treviewed\t{c['label']}\t{c['src']}\t{c['verdict']}")
    return 1 if bad or open_c else 0


if __name__ == "__main__":
    sys.exit(main())
