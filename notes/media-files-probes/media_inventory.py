#!/usr/bin/env python3
"""media_inventory.py -- every picture, sound and MIDI item in the sources, the committed media file behind it,
and the build step that converts it.

QUESTION IT ANSWERS
  "For every tree of the data census, which items are pictures, PCM recordings, fonts drawn as bitmaps or
   MIDI streams; is each one's standalone file (PNG, JPEG, BMP, WAV, MID) COMMITTED; does the build read it
   directly or convert it at build time; and is every file a converter derives from it UNTRACKED?"
  Set up 2026-10-30 (lane media-files) for the owner's request: "'Media: pictures and PCM' <== I want these
  to be represented as standalone files that could be opened by the user on normal media viewers / sound
  apps.  Then included in the source listing (maybe with a lossless conversion step if necessary)".
  Extended 2026-10-31 (lane media-build) for the owner's decision: "Images and wav files must be commited
  and the conversion must happen as a build step."

WHAT IT READS
  1. Every `.incbin` of every census tree, through scripts/analysis/data_incbin_census.py (its TREES, its
     classes and markers).  An include is a media item when
       - its file is a media file (class `media`: .png .jpg .bmp .wav .mid ...): read DIRECTLY, or
       - its marker names a media file it is made from (`census: generated -- <tool>, from <file>.png`,
         "from the .png beside it"; the census's `from_media` flag): CONVERTED AT BUILD by <tool>, and the
         include's own file is the converter's output, or
       - it is declared `census: opaque -- pcm` (a PCM body still read from a dump: NOT backed), or
       - its label or path or marker reads like a picture or a sound (vocabulary below) and none of the
         above holds: NOT backed, until it is converted or given a verdict in REVIEWED.
  2. The KN5000 NAKA GUI C pictures (scripts/build/c_bitmaps.py): the C `#include`s a git-ignored .inc that
     the build writes from the PNG.
  3. Typed rows (`.byte` / `.word` / `tab_u8` ... after a label, no `.incbin`) whose label reads like a
     picture or a sound: each must carry a verdict in REVIEWED, else it is reported as a candidate.  This is
     a name heuristic: a picture under a name that says nothing is not seen.  The WSA1R ranges
     wsa1_bitmaps.py REFUSES (geometry not established) are listed as such.
  4. `git ls-files`, for the two counts the decision is about:
       - untracked media: a media file the build reads (directly, or as a converter's input) that is not
         committed;
       - tracked derived outputs: a file a converter writes that IS committed.  Checked three ways: the
         include path of every CONVERTED item, resolved against the tracked files the way the census sizes
         it; the output lists of the converters (kn5000_image_outputs.py, c_bitmaps.py's .inc files,
         wsa1_bitmaps.py outputs, ftbmp_images.py, the WAV manifests' raw items); and every tracked non-media
         file with the same path stem as a tracked picture in the same directory (the shape the 213 tracked
         .bin files of 2026-10-30 had).

VOCABULARY  Bitmap Glyph Font Icon Picture Pixels Logo Wallpaper Image Sprite Cursor Pcm PCM Sample Wave

OUTPUT
  A table per tree (pictures / sounds / MIDI: read directly, converted at build, not backed), the two counts,
  and every item not backed, every untracked media file, every tracked derived output and every candidate
  without a verdict.  Exit 1 when any of those lists is not empty.  --list prints every item.

RUN
  python3 notes/media-files-probes/media_inventory.py            (about 30 s; build the trees first for the
                                                                   byte sizes of converter outputs)
  python3 notes/media-files-probes/media_inventory.py --list
"""
import argparse
import importlib.util
import os
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
     r'DrawBitmapSPFast16_Impl\w*_Table_\d+|'
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


_CANDS = {}


def candidates(name, src, tree):
    """the paths the census's locate() tries for an include `name` of `src`, in its order, plus the tree's
    extra -I directories; repo-relative strings (cached per including directory)"""
    key = (name, str(Path(src).parent), tree)
    if key in _CANDS:
        return _CANDS[key]
    out = []
    chain = []
    d = Path(src).parent
    while True:
        chain.append(d)
        if str(d) in ("", "."):
            break
        d = d.parent
    for i, d in enumerate(chain):
        out += [d / name, d / "media" / name]
        for sub in chain[:i + 1]:
            out.append(d / "build" / sub.relative_to(d) / name)
    for td in CEN.TREES.get(tree, []):
        base = Path(td)
        base = base.parent if base.suffix == ".s" else base
        out += [base / name, base / "includes" / name, base / "build" / name, base.parent / name,
                base.parent.parent / name]
    for d in CEN.EXTRA_INCLUDE.get(tree, ()):
        out.append(Path(d) / name)
    res = []
    for c in out:
        r = os.path.normpath(str(c))
        if r not in res and not r.startswith(".."):
            res.append(r)
    _CANDS[key] = res
    return res


def rel(p):
    return Path(p).resolve().relative_to(ROOT).as_posix()


def resolve(name, src, tree):
    """the media file a marker names, on disk, or None"""
    for c in candidates(name, src, tree):
        if (ROOT / c).is_file():
            return ROOT / c
    return None


def tracked_match(name, src, tree, tracked_set):
    """the first candidate path of `name` that is a tracked file, or None"""
    for c in candidates(name, src, tree):
        if c in tracked_set:
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
            how, tool = None, None
            if cls == "media":
                kind = "picture" if ext in PICT_EXT else "sound" if ext in SOUND_EXT else "midi" if ext in MIDI_EXT else "other"
                backed, file = True, path
                on = CEN.locate(path, r["file"], CEN.TREES[tree], CEN.EXTRA_INCLUDE.get(tree, ())) is not None
                how = "direct"
            elif cls == "generated" and r.get("from_media"):
                how, tool = "converted at build", why.split(",")[0].split(" from ")[0].strip()
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
                                  kind=kind, backed=backed, file=file, on_disk=on, size=r["size"] or 0,
                                  how=how or "not backed", tool=tool, inc=path, inc_src=r["file"]))
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
                          how="converted at build", tool="scripts/build/c_bitmaps.py (C #include)",
                          derived=str(cb.inc_path(t, name).relative_to(ROOT))))
    return items


def wsa1_ranges():
    """the WSA1R picture and font ranges (for the typed-row filter) and the ranges wsa1_bitmaps.py refuses"""
    sys.path.insert(0, str(ROOT / "wsa1/scripts/build"))
    wb = load("wsa1_bitmaps", ROOT / "wsa1/scripts/build/wsa1_bitmaps.py")
    wf = load("wsa1_fonts", ROOT / "wsa1/scripts/build/wsa1_fonts.py")
    ranges = [(e["img"], e["addr"], e["addr"] + e["bc"] * e["hl"]) for e in wb.build_manifest()]
    ranges += [("b", base, base + pitch * cells) for _n, base, pitch, _w, cells, _s, _x in wf.FACES]
    return ranges, list(wb.REFUSED), wb, wf


def converter_outputs(wb, wf):
    """(output, converter) for every file a media converter writes, from the converters' own lists"""
    out = []
    sys.path.insert(0, str(ROOT / "scripts/build"))
    ko = load("kn5000_image_outputs", ROOT / "scripts/build/kn5000_image_outputs.py")
    out += [(o, "kn5000_image_outputs.py") for o in ko.outputs()]
    ft = load("ftbmp_images", ROOT / "scripts/build/ftbmp_images.py")
    out += [(rel(ft.IMAGES / f"{n}.BMP"), "ftbmp_images.py") for n in ft.NAMES]
    cb = load("c_bitmaps", ROOT / "scripts/build/c_bitmaps.py")
    out += [(rel(cb.inc_path(t, n)), "c_bitmaps.py") for t, n in cb.items()]
    out += [(rel(wb.bin_path(e)), "wsa1_bitmaps.py") for e in wb.build_manifest()]
    out += [(rel(wf.sheet_path(n[0]).with_suffix(".bin")), "wsa1_fonts.py") for n in wf.FACES]
    pw = load("pcm_wav", ROOT / "scripts/build/pcm_wav.py")
    for man, pcmdir in (("waveform/wav_manifest.tsv", "waveform/build/pcm"),
                        ("kn7000/src/wave/main_wav.tsv", "kn7000/build/wav_pcm/main"),
                        ("kn7000/src/wave/sub_wav.tsv", "kn7000/build/wav_pcm/sub")):
        out += [(f"{pcmdir}/{r['label']}.pcm", "pcm_wav.py") for r in pw.read_manifest(ROOT / man)]
    return out


def stem_twins(files):
    """tracked non-media files with the same path stem as a tracked picture or sound in the same directory"""
    media = {f.rsplit(".", 1)[0] for f in files if f.rsplit(".", 1)[-1].lower() in PICT_EXT | SOUND_EXT}
    return [f for f in files if "." in f and f.rsplit(".", 1)[-1].lower() not in PICT_EXT | SOUND_EXT | MIDI_EXT
            and f.rsplit(".", 1)[0] in media and not f.endswith((".md", ".txt", ".json", ".tsv"))]


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
    files = tracked()
    tset = set(files)
    res = CEN.census()
    c_items = c_bitmap_items()
    c_names = {it["label"] for it in c_items}
    items = [it for it in incbin_items(res) if it["label"] not in c_names] + c_items
    w_ranges, refused, wb, wf = wsa1_ranges()
    cands = row_candidates(files, w_ranges)

    # committed?  and the converter output of every converted item, tracked or not
    untracked_media, tracked_derived = [], []
    for it in items:
        if not it["backed"]:
            continue
        if it.get("inc_src") and it["how"] == "direct":
            f = tracked_match(it["inc"], it["inc_src"], it["tree"], tset)
            it["committed"] = f is not None
        else:
            f = it["file"] if it["file"] in tset else (rel(ROOT / it["file"]) if (ROOT / it["file"]).exists() else None)
            if it["file"] and f is None and it.get("inc_src"):
                g = resolve(it["file"], it["inc_src"], it["tree"])
                f = rel(g) if g is not None else None
            it["committed"] = f is not None and f in tset
        if not it["committed"]:
            untracked_media.append(it)
        if it["how"] == "converted at build" and it.get("inc_src"):
            # the include names the converter's output: it must not resolve to a tracked file
            d = tracked_match(it["inc"], it["inc_src"], it["tree"], tset)
            if d is not None:
                tracked_derived.append((d, f"{it['tree']} {it['src']} ({it['tool']})"))
        if it.get("derived") and it["derived"] in tset:
            tracked_derived.append((it["derived"], f"{it['tree']} {it['label']} ({it['tool']})"))
    for o, tool in converter_outputs(wb, wf):
        if o in tset:
            tracked_derived.append((o, tool))
    for f in stem_twins(files):
        tracked_derived.append((f, "same stem as a tracked picture or sound beside it"))
    tracked_derived = sorted(set(tracked_derived))

    by = defaultdict(lambda: defaultdict(lambda: [0, 0, 0, 0, 0, 0]))
    for it in items:
        k = it["kind"].split()[0].rstrip("?")
        c = by[it["tree"]][k]
        slot = 0 if it["how"] == "direct" else 1 if it["how"] == "converted at build" else 2
        c[slot] += 1
        c[3 + slot] += it["size"]
    kinds = ["picture", "sound", "midi"]
    head = ["tree"] + [f"{k}s: direct / converted / NOT backed" for k in kinds]
    body = []
    for t in CEN.TREES:
        if t not in by:
            continue
        c = by[t]
        body.append([t] + [f"{c[k][0]} / {c[k][1]} / {c[k][2]}" for k in kinds])
    w = [max(len(r[i]) for r in [head] + body) for i in range(len(head))]
    print("items; direct = the build reads the committed media file itself (JPEG, BMP, MID);\n"
          "converted = a committed converter turns the committed media file (PNG, WAV) into the bytes at build time\n")
    print("| " + " | ".join(h.ljust(w[i]) for i, h in enumerate(head)) + " |")
    print("|" + "|".join("-" * (x + 2) for x in w) + "|")
    for r in body:
        print("| " + " | ".join(x.ljust(w[i]) for i, x in enumerate(r)) + " |")
    nd = sum(1 for it in items if it["how"] == "direct")
    nc = sum(1 for it in items if it["how"] == "converted at build")
    bad = [it for it in items if not it["backed"]]
    print(f"\nall trees: {nd + nc} items backed by a committed media file ({nd} read directly, "
          f"{nc} converted at build), {len(bad)} not backed")
    print(f"untracked media files the build reads: {len(untracked_media)}")
    print(f"tracked files a converter derives from media: {len({f for f, _ in tracked_derived})}")
    if bad:
        print("\nNOT BACKED:")
        for it in bad:
            print(f"  {it['tree']:18} {it['kind']:9} {it['label']:40} {it['src']}")
    if untracked_media:
        print("\nUNTRACKED MEDIA (the build reads them, git does not have them):")
        for it in untracked_media[:50]:
            print(f"  {it['tree']:18} {it['label']:40} {it['file']}")
    if tracked_derived:
        print("\nTRACKED DERIVED OUTPUTS:")
        for f, why in tracked_derived[:80]:
            print(f"  {f}  <- {why}")
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
            print(f"{it['tree']}\t{it['kind']}\t{it['how']}\t{it['label']}\t{it['src']}\t{it['file'] or '-'}\t"
                  f"{'committed' if it.get('committed') else 'NOT committed'}\t{it['size']}\t{it.get('tool') or '-'}")
        for c in cands:
            if c["verdict"]:
                print(f"{c['tree']}\tcandidate\treviewed\t{c['label']}\t{c['src']}\t{c['verdict']}")
    return 1 if bad or open_c or untracked_media or tracked_derived else 0


if __name__ == "__main__":
    sys.exit(main())
