"""floppy/kn5000/formats.py -- the SX-KN5000 file-format describers (interface: floppy/README.md).

describe(ctx) dispatches on the file's extension.  Every describer CHECKS the structure it spells
and returns None (leaving the file one generic .incbin) when the file does not fit it, so a
describer cannot mis-type a file silently.  Formats and evidence:
notes/floppy-kn5000-2026-10-29/README.md.

What the sources hold, and what they do not.  The repository is public and the disks are the
2026-10-18 softlist reconstructions, kept in the private romset.  So the describers type what a
file IS: headers, signatures, names, directories, record framing, cell links and the firmware's
size fields.  The bulk content stays an `.incbin` of the reference with a label and a comment
saying what it is: the event bytes of a cell, a record's parameter bytes, pixels.  Those
`.incbin`s name the file's own copy (ctx.extracted, made by floppy/tools/fat12_extract.py from the
reference), at offsets within the file: llvm-mc reads the file once per `.incbin`, and a 60 KB
file is much cheaper to read 300 times than the 1.44 MB image.  An `.incbin`
whose meaning nobody has established says so (`census: opaque -- unknown-dump: ...`).
"""
import pathlib
import re
import struct
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import events  # noqa: E402
import panel_fields  # noqa: E402
import spec_struct  # noqa: E402

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[2] / 'analysis' / 'disk-format-probes'))
import lsw_voice_selector_names as _voices  # noqa: E402
_TDROM = (pathlib.Path(__file__).resolve().parents[2] / 'original_ROMs' / 'kn5000_table_data.rom').read_bytes()


def sound_name(payload):
    try:
        name, _tone = _voices.option_name(_TDROM, payload[1] & 7, payload[0])
    except Exception:
        return None
    return name

INCLUDES = ['kn5000_files.inc', 'kn5000_panel.inc', 'kn5000_specs.inc']

BOOT_NOTE = [
    'The KN5000 formatter writes these first 32 bytes: FDC_Format2HD_WriteBoot (v10/v9 0xf522f5)',
    'copies FDC_Format2HD_BootSectorHead (v10 0xe450da, v10/maincpu/ui_widgets/widget_descriptors.s),',
    'which is EB 1C 90 "Technics", this BPB and EB FE, byte for byte.  On these images the rest',
    'of the sector, signature word included, is zero.',
]

REPO = pathlib.Path(__file__).resolve().parents[2]
PANEL_C = REPO / 'v10' / 'maincpu' / 'ui_widgets' / 'naka_extension_device.c'


# ---------------------------------------------------------------------------------------------
# helpers

def s_escape(b):
    out = []
    for c in b:
        if c in (0x22, 0x5C):
            out.append('\\' + chr(c))
        elif 0x20 <= c < 0x7F:
            out.append(chr(c))
        else:
            out.append('\\%03o' % c)
    return '"' + ''.join(out) + '"'


def printable(b):
    return all(0x20 <= c < 0x7F for c in b)


class Out:
    """Accumulates a unit's lines and checks that it spells exactly the file, in order."""

    def __init__(self, ctx):
        self.ctx, self.pos, self.lines = ctx, 0, []

    def put(self, line, n):
        self.lines.append(line)
        self.pos += n

    def label(self, name):
        self.lines.append('%s_%s:' % (self.ctx.label, name))

    def comment(self, text=''):
        self.lines.append(('; ' + text).rstrip() if text else '')

    def inc(self, n, what, opaque=None):
        """The next n bytes of the file, as an .incbin of the reference."""
        if n <= 0:
            return
        if opaque:
            self.lines.append('\t; census: opaque -- unknown-dump: %s' % opaque)
        self.put('\t.incbin\t"%s", 0x%x, %d\t; %s' % (self.ctx.extracted, self.pos, n, what), n)

    def media(self, n, what):
        self.put('\t.incbin\t"%s", %d, %d\t; %s' % (self.ctx.extracted, self.pos, n, what), n)

    def ascii(self, b, what=''):
        self.put('\t.ascii\t%s%s' % (s_escape(b), ('\t; ' + what) if what else ''), len(b))

    def raw(self, mnem, vals, n, what=''):
        self.put('\t%s\t%s%s' % (mnem, ', '.join(vals), ('\t; ' + what) if what else ''), n)

    def fill_or_inc(self, b, what):
        if b and len(set(b)) == 1:
            self.put('\t.fill\t%d, 1, 0x%02x\t; %s' % (len(b), b[0], what), len(b))
        else:
            self.inc(len(b), what)

    def struct(self, st, b):
        for line, n in st.lines(b):
            self.put(line, n)

    def fill_or_bytes(self, b, what):
        if not b:
            return
        for line, n in events.raw_lines(b, what):
            self.put(line, n)

    def done(self):
        assert self.pos == len(self.ctx.data), (self.ctx.path, self.pos, len(self.ctx.data))
        return self.lines


# ---------------------------------------------------------------------------------------------
# TXT: the disk's table of contents, plain text (CR LF lines)

def describe_txt(ctx):
    d = ctx.data
    o = Out(ctx)
    o.comment('Plain text, CR LF line ends: the disk\'s table of contents, read by people, not by')
    o.comment('the instrument (no KN5000 file type is .TXT: FileIO_TypeExtensions, v10 0xea0340).')
    o.comment('Bytes above 0x7e are code page 437/850 (0xe4 = a umlaut).')
    o.label('Text')
    for line in re.split(b'(?<=\n)', d):
        if line:
            o.ascii(line)
    return o.done()


# ---------------------------------------------------------------------------------------------
# BMP: Windows bitmap; the KN5000's own screenshot / wallpaper format

def describe_bmp(ctx):
    d = ctx.data
    if len(d) < 54 or d[:2] != b'BM':
        return None
    size, r1, r2, off = struct.unpack_from('<IHHI', d, 2)
    hsz, w, h, planes, bpp, comp, isz, xp, yp, cu, ci = struct.unpack_from('<IiiHHIIiiII', d, 14)
    if hsz != 40 or off < 54 or off > len(d):
        return None
    o = Out(ctx)
    o.comment('A Windows BMP, 8 bpp.  The KN5000 writes and reads this form itself: CaptureLcd')
    o.comment('(v10 0xfaf030) emits bfSize 0x13036 = 77,878 bytes (320 x 240, 256-entry palette) and')
    o.comment('Gfx_LoadSplashBMP (v10 0xfae86d) loads it as the LCD wallpaper into Custom Data Flash')
    o.comment('0x3c0000 (technics-docs custom-data-flash.md).  Header fields as stored.')
    if size != len(d):
        o.comment('bfSize says %d; the file is %d bytes.' % (size, len(d)))
    o.label('FileHeader')
    o.raw('bmp_file_header', [str(size), str(r1), str(r2), str(off)], 14)
    o.label('InfoHeader')
    o.raw('bmp_info_header', [str(w), str(h), str(planes), str(bpp), str(comp), str(isz),
                              str(xp), str(yp), str(cu), str(ci)], 40)
    if off > 54:
        o.label('Palette')
        o.media(off - 54, 'palette: %d BGR0 entries' % ((off - 54) // 4))
    o.label('Pixels')
    o.media(len(d) - off, 'pixels: %d x %d, bottom-up rows' % (w, h))
    return o.done()


# ---------------------------------------------------------------------------------------------
# Panel records: LSW (CURRENT PANEL) and the 80 panel memories of PMT (PANEL MEMORY)

def panel_layouts():
    """(tag, len) per record of PanelTlv_Block0_Layout / _Block1_Layout, read from the C source."""
    src = PANEL_C.read_bytes().decode('latin-1')
    out = {}
    for blk in ('PanelTlv_Block0_Layout', 'PanelTlv_Block1_Layout'):
        i = src.index('.%s = {' % blk)
        body = src[i:src.index('\n    },', i)]
        recs = re.findall(r'\{\s*0x[0-9A-Fa-f]+,\s*[^,]+\),\s*0x([0-9A-Fa-f]+),\s*(0x[0-9A-Fa-f]+|\d+)\s*\}', body)
        out[blk] = [(int(t, 16), int(n, 0)) for t, n in recs]
    return out


_LAYOUT = None


def layout():
    global _LAYOUT
    if _LAYOUT is None:
        _LAYOUT = panel_layouts()
    return _LAYOUT


def tlv_records(d, start, end):
    """Walk tag/len records from start; return [(off, tag, len)] up to and including FF FF, or None."""
    recs, p = [], start
    while p + 2 <= end:
        t, n = d[p], d[p + 1]
        recs.append((p, t, n))
        if t == 0xFF and n == 0xFF:
            return recs, p + 2
        p += 2 + n
    return None, None


def match_layout(d, start, end, want):
    """How many records of the firmware list `want` open the block, and where they stop."""
    p, k = start, 0
    for t, n in want:
        size = 2 if (t, n) == (0xFF, 0xFF) else 2 + n
        if p + size > end or (d[p], d[p + 1]) != (t, n):
            break
        p += size
        k += 1
    return k, p


def emit_block(o, d, start, end, blkname, title):
    """Type one panel block as records: the run of the firmware's record list it opens with, then
    whatever tag/length records continue up to an FF FF end mark, then the rest of the block."""
    want = layout()[blkname]
    k, p = match_layout(d, start, end, want)
    if k == len(want):
        o.comment('%s: %d records, the tag and length list of %s exactly.' % (title, k, blkname))
    else:
        o.comment('%s: the first %d of the %d records of %s; the rest differ (an older firmware\'s' %
                  (title, k, len(want), blkname))
        o.comment('block, [INFERENCE]: the v5..v10 lists are all the same).')
    q = start
    recs = []
    for i in range(k):
        t, n = want[i]
        recs.append((q, t, n, True))
        q += 2 if t == 0xFF else 2 + n
    if k < len(want):
        more, stop = tlv_records(d, q, end)
        if more:
            recs += [(r, t, n, False) for (r, t, n) in more]
            q = stop
    for (r, t, n, inlist) in recs:
        if t == 0xFF and n == 0xFF:
            o.raw('panel_tlv', ['0xff', '0xff'], 2, 'end of block')
            continue
        pay = d[r + 2:r + 2 + n]
        line = panel_fields.record_line(t, n, pay, sound_name(pay) if t in panel_fields.PART_TAGS and n == 24 else None) \
            if inlist else None
        o.put(line or panel_fields.raw_line(t, n, pay), 2 + n)
    o.fill_or_bytes(d[q:end], 'rest of the block')
    return True


def describe_lsw(ctx):
    d = ctx.data
    if len(d) != 0xE40 or d[4:6] != b'HK':
        return None
    o = Out(ctx)
    o.comment('CURRENT PANEL, file type 0.  FileIO_SaveRegion0_VRAM (v10 0xf87af6) writes 0x640 bytes')
    o.comment('of the live panel area 0xf980..0xffc0 (header, block 0 at 0xf9a0, block 1 at 0xfd60)')
    o.comment('and the 0x800 bytes at 0x1e7800, between PreLswSave and PostLswSave.')
    o.label('Header')
    o.raw('.byte', ['0x%02x' % c for c in d[0:4]], 4, 'header +0..+3')
    o.ascii(d[4:6], 'FileIO_CheckRegionSignature(0) requires "HK" at +4')
    o.fill_or_inc(d[6:0x20], 'header +6..+0x1f')
    o.label('Block0')
    emit_block(o, d, 0x20, 0x3E0, 'PanelTlv_Block0_Layout', 'Block 0 (RAM 0xf9a0)')
    o.label('Block1')
    emit_block(o, d, 0x3E0, 0x640, 'PanelTlv_Block1_Layout', 'Block 1 (RAM 0xfd60)')
    o.label('Ram1E7800')
    o.inc(0x800, 'RAM 0x1e7800..0x1e8000',
          opaque='what the firmware keeps at RAM 0x1e7800..0x1e8000 is not identified '
                 '(docs/kn-disk-file-formats.md, "still unmapped")')
    return o.done()


def describe_pmt(ctx):
    d = ctx.data
    if len(d) < 0xB0 or d[:3] != b'HK ':
        return None
    slot = struct.unpack_from('<H', d, 0x0D)[0]
    count = d[0x0F]
    if slot != 960 or len(d) != 0xB0 + count * slot:
        return None
    o = Out(ctx)
    o.comment('PANEL MEMORY, file type 1.  FileIO_SaveRegion1_VRAM (v10 0xf87b88) writes RAM 0x1ed350')
    o.comment('up to 0x200000 (all 80 memories), or the size at 0x1ed350 + 13 (one bank), between')
    o.comment('PrePmSave and PostPmSave.  Each memory is a panel block 0 (960 B = 0x3c0) at')
    o.comment('0x1ed400 + 960 * n, the record list of PanelTlv_Block0_Layout.')
    o.label('Header')
    o.ascii(d[0:3], 'signature')
    o.fill_or_inc(d[3:0x0D], 'header +3..+0x0c')
    o.raw('.short', [str(slot)], 2, 'bytes per memory (read through 0x1ed350 + 13)')
    o.raw('.byte', [str(count)], 1, 'memories in this file')
    o.label('BankNames')
    for k in range(10):
        nm = d[0x10 + 16 * k:0x20 + 16 * k]
        if printable(nm):
            o.ascii(nm, 'bank %d name' % (k + 1))
        else:
            o.inc(16, 'bank %d name field' % (k + 1))
    for k in range(count):
        base = 0xB0 + k * slot
        o.label('Memory_%d_%d' % (k // 8 + 1, k % 8 + 1))
        emit_block(o, d, base, base + slot, 'PanelTlv_Block0_Layout', 'Bank %d memory %d' % (k // 8 + 1, k % 8 + 1))
    return o.done()


# ---------------------------------------------------------------------------------------------
# TM: SOUND MEMORY, the 0x72aa-byte RAM image at 0x1e0000

SS = spec_struct.structs()
SOUND_RAM_MAGICS = (b'KN5000 SOUND RAM', b'KN3000 SOUND RAM', b'KN1500 SOUND RAM')


def describe_tm(ctx):
    d = ctx.data
    if d[:16] in SOUND_RAM_MAGICS and len(d) != 0x72AA:
        o = Out(ctx)
        o.comment('A sound RAM image of another model (the KN5000 imports it: its loader accepts')
        o.comment('the "KN3000 SOUND RAM" / "KN1500 SOUND RAM" headers, SendPartDataBlock_InitVal4).')
        o.comment('Its %d-byte layout is not established.' % len(d))
        o.label('Header')
        o.ascii(d[:16], 'model signature')
        o.inc(len(d) - 16, 'body', opaque='a foreign model\'s sound RAM layout, not decoded '
              '(only the KN5000\'s own 0x72aa-byte image is typed here)')
        return o.done()
    if len(d) != 0x72AA or d[:16] not in SOUND_RAM_MAGICS:
        return None
    o = Out(ctx)
    o.comment('SOUND MEMORY, file type 4.  FileIO_SaveRegion4_VRAM (v10 0xf87e41) writes RAM')
    o.comment('0x1e0000, 0x72aa bytes, between PreTmSave and PostTmSave; at boot the firmware compares')
    o.comment('the 16-byte header with "KN5000 SOUND RAM" and sends the image to sub-CPU 0x7800')
    o.comment('(SendPartDataBlock_ClearByte4).  40 records of 470 bytes follow it, the size of the')
    o.comment('Flash section-7 small slots (Flash_CopyBlocksToSlots): the sub-CPU\'s own 426-byte tone')
    o.comment('record plus four 11-byte velocity-split records; then the kit record (128 user drum')
    o.comment('instruments of 80 B) ending with the edit index and the image checksum.  Field map, with')
    o.comment('evidence per field: notes/floppy-kn5000-2026-10-29/specs/tm_sound_record.json.')
    o.label('Header')
    o.ascii(d[:16], 'checked at boot')
    p = 16
    for k in range(40):
        nm = d[p:p + 16]
        o.label('Sound_%d' % (k + 1))
        o.struct(SS['tm_sound'], d[p:p + 470])
        p += 470
    o.label('Kit')
    h, e, t = SS['tm_kit_head'], SS['tm_kit_entry'], SS['tm_kit_tail']
    o.struct(h, d[p:p + h.size])
    for n in range(128):
        q = p + e.base + 80 * n
        o.comment('drum instrument for note %d' % n)
        o.struct(e, d[q:q + 80])
    o.struct(t, d[p + t.base:p + t.base + t.size])
    return o.done()


# ---------------------------------------------------------------------------------------------
# Style banks: CMP (COMPOSER) and the sections of RCM (RHYTHM CUSTOM)

DIR0, NREC, REC = 0x60, 30, 0x60
# The bank's field layout, shared with scripts/build/style_events.py (the IC19 banks): one module names
# every field for both, with the evidence for each (STYLE_SECTION 0..29 in AccDemo_LoadVariation_EntryLoop_
# Data's order, the header, the section records, the chord maps and the measure-start table).
sys.path.insert(0, str(REPO / 'scripts' / 'build'))
import style_bank_layout as SBL  # noqa: E402
SECTION_ROLE = SBL.SECTION_ROLE


# Cell pointers count blocks from block 20 of the bank (bank + 0x1400), in every bank on these
# disks: no other base makes 1/10 as many links mutual (probe kn5000_floppy_formats.py, BASE), and
# AccPatch_InitSlotChain allocates the cells from base + 0x1400.  Three CMPs hold cell-shaped
# bytes below that base, in the measure-start table's area; they are spelled as bytes there.
CELL_BASE_BLOCK = 20


def is_cell(b):
    return len(b) == 256 and b[0] in (0x80, 0x00) and b[5] == 0x87 and b[255] == 0x87


def emit_style_bank(o, d, base, end, title):
    """One IC19-format style bank at d[base:end]: header, directory, then 256-byte blocks."""
    if d[base:base + 4] != b'H\0K\0':
        return False
    o.comment('%s: one Composer style image (the bank layout of scripts/build/style_bank_layout.py,' % title)
    o.comment('shared with the IC19 custom-data banks): header, 30 STYLE_SECTION records, chord maps and')
    o.comment('measure-start table, the fill-in cell at +0x13c0, then 256-byte cells from +0x1400.')
    o.ascii(d[base:base + 4], 'bank magic')
    hb = {nm: (off, n) for off, n, nm in SBL.HEADER_BYTES}

    def hdr_bytes(nm, what):
        off, n = hb[nm]
        o.fill_or_bytes(d[base + off:base + off + n], '%s: %s' % (nm, what))

    hdr_bytes('reserved_04', '0 in every bank; no reader')
    hdr_bytes('reserved_0b', '5a 5a 5a in every bank (Demo_StyleRhythmData); no reader')
    o.put('\tstyle_bank_mode\t0x%04x, %d\t; password (0 = none), %s MODE' % (
        struct.unpack_from('<H', d, base + SBL.PASSWORD)[0], d[base + SBL.COMPOSER_MODE],
        {0: 'NORMAL', 1: 'EXPAND'}.get(d[base + SBL.COMPOSER_MODE], '?')), 3)
    hdr_bytes('reserved_11', '0 in every bank; no reader')
    hdr_bytes('reserved_15', '01 01 01 01 02 02 02 02 in every bank (Demo_StyleRhythmData); no reader')
    hdr_bytes('reserved_1d', '0; no reader')
    w = struct.unpack_from('<9H', d, base + 0x1E)
    o.put('\tstyle_bank_sizes\t0x%04x, 0x%02x, 0x%02x, %d, 0x%03x, %d, 0x%02x, 0x%04x, 0x%04x' % w, 18)
    o.fill_or_bytes(d[base + 0x30:base + 0x60], 'reserved_30: 0 in every bank; no reader')
    for k in range(NREC):
        r = base + DIR0 + k * REC
        v = struct.unpack_from('<6H', d, r)
        key, minor, a7, b7, hi = SBL.rec_chord_fields(d[r + 0x0E])
        o.put('\tstyle_section_head\t%s, %d, %d, %d, %d, %d, %d, %d, 0x%02x, 0x%02x, %d'
              '\t; section %d %s: %s, %d measures, key %s' % (
                  ', '.join('0x%04x' % x for x in v), d[r + 0x0C], d[r + 0x0D], key, minor, a7, b7, hi,
                  d[r + 0x0F], d[r + 0x10], d[r + 0x11], k, SECTION_ROLE[k], SBL.time_sig_name(d[r + 0x0C]),
                  d[r + 0x0D] + 1, SBL.key_name(key)), 0x12)
        o.fill_or_bytes(d[r + 0x12:r + 0x18], 'reserved_12')
        for i, pt in enumerate(SBL.PARTS):
            q = r + SBL.PART_BASE + SBL.PART_SIZE * i
            b8 = d[q:q + 8]
            vals = [str(b8[0]), str(b8[1]), str(b8[2]), str(b8[3]), '0x%02x' % b8[4], str(b8[5]),
                    '0x%02x' % b8[6], str(b8[7])]
            o.put('\tstyle_part\t%s\t; %s' % (', '.join(vals), pt), 8)
        o.put('\tstyle_section_name\t%s' % s_escape(d[r + SBL.NAME_OFF:r + SBL.NAME_OFF + 16]), 16)
        o.fill_or_bytes(d[r + SBL.TAIL_OFF:r + REC], 'reserved_50: no reader')
    cm = d[base + SBL.CHORD_MAP_OFF:base + SBL.MEASURE_OFF]
    maps_ok = all(cm[32 * n + 4:32 * n + 16] == bytes(12) and all(x < 12 or x == 0xFF for x in cm[32 * n:32 * n + 4])
                  for n in range(SBL.CHORD_MAPS))
    if not any(cm):
        o.fill_or_bytes(cm, 'chord_map[5]: the five COMPOSER CHORD MAPs, all zero here')
    elif maps_ok:
        o.comment('The five COMPOSER CHORD MAPs (+0xba0): the four variations each plays, 0xff = none.')
        for n in range(SBL.CHORD_MAPS):
            c = cm[32 * n:32 * n + 32]
            o.put('\tstyle_chord_map\t%s, %s' % (', '.join('0x%02x' % x if x == 0xFF else str(x) for x in c[:4]),
                                                  s_escape(c[16:])), 32)
    else:
        o.fill_or_bytes(cm, 'chord_map[5] area, not in the chord-map shape here')
    mt = d[base + SBL.MEASURE_OFF:base + SBL.FILLIN_OFF]
    rows = [struct.unpack_from('<16H', mt, 32 * j) for j in range(SBL.MEASURE_VARS * SBL.MEASURE_PARTS)]
    table_ok = all(row[2 * m] < 0x154 and row[2 * m + 1] < 0x100 for row in rows for m in range(8))
    if not any(mt):
        o.fill_or_bytes(mt, 'measure_start[12][5][8]: all zero here')
    elif table_ok:
        o.comment('The measure-start table (+0xc40): per variation and part, the {cell, offset} where each of')
        o.comment('the eight measures starts (AccVoice_GetMeasureStartBlock, AccPatch_StoreMeasureCursor).')
        for j, row in enumerate(rows):
            o.put('\tstyle_measure_starts\t%s\t; variation %d %s' % (
                ', '.join('%d' % x for x in row), j // 5, SBL.PARTS[j % 5]), 32)
    else:
        o.fill_or_bytes(mt, 'measure_start table area: holds bytes that are no {cell, offset} table '
                        '(stale cell-shaped data of an older layout)')
    f = base + 0x13C0
    if d[f + 5] == 0x87:
        o.raw('style_cell', ['0x%02x' % d[f]] + ['0x%04x' % x for x in struct.unpack_from('<HH', d, f + 1)], 6,
              'the 64-byte fill-in cell (AccDemo_LoadFillIn copies 0x40 bytes here)')
        stream = d[f + 6:f + 0x40]
        for line, n in events.cut(stream, events.tokenize_style(stream), [(0, len(stream))])[0]:
            o.put(line, n)
    else:
        o.fill_or_bytes(d[f:f + 0x40], 'the fill-in cell area, not cell-shaped here')
    blk = base + 0x1400
    cells = []
    c = blk
    while c + 256 <= end and is_cell(d[c:c + 256]):
        cells.append(c)
        c += 256
    emit_style_cells(o, d, base, cells)
    blk = cells[-1] + 256 if cells else blk
    while blk + 256 <= end:
        b = d[blk:blk + 256]
        j = blk
        while len(set(b)) == 1 and j + 256 <= end and d[j:j + 256] == b:
            j += 256
        if j > blk:
            o.fill_or_inc(d[blk:j], 'blocks %d..%d, uniform' % ((blk - base) // 256, (j - base) // 256 - 1))
            blk = j
            continue
        o.inc(256, 'block %d: not a cell (not established)' % ((blk - base) // 256))
        blk += 256
    o.fill_or_inc(d[blk:end], 'bank tail')
    return True


def emit_style_cells(o, d, base, cells):
    """The cell run of a style bank, its events typed one per line, chain by chain."""
    if not cells:
        return
    first = CELL_BASE_BLOCK
    cs = set(cells)
    owner = {}
    chains = []

    def at(v):
        return base + ((v & 0xFFF) + first) * 256

    for h in cells:
        if d[h] != 0x80 or struct.unpack_from('<H', d, h + 1)[0] != 0xFFFF:
            continue
        seq, c = [], h
        while c in cs and c not in owner:
            owner[c] = (len(chains), len(seq))
            seq.append(c)
            nxt = struct.unpack_from('<H', d, c + 3)[0]
            c = at(nxt) if nxt != 0xFFFF else None
        chains.append(seq)
    for c in cells:                       # templates and cells no head reaches: alone
        if c not in owner:
            owner[c] = (len(chains), 0)
            chains.append([c])
    lines = {}
    for seq in chains:
        stream = b''.join(d[c + 6:c + 255] for c in seq)
        toks = events.tokenize_style(stream)
        bounds = [(249 * k, 249 * (k + 1)) for k in range(len(seq))]
        for c, part in zip(seq, events.cut(stream, toks, bounds)):
            lines[c] = part
    for c in cells:
        mark, prev, nxt = d[c], *struct.unpack_from('<HH', d, c + 1)
        ch, k = owner[c]
        what = 'block %d, chain %d cell %d' % ((c - base) // 256, ch, k) if d[c] == 0x80 else \
            'block %d, unlinked template block' % ((c - base) // 256)
        o.raw('style_cell', ['0x%02x' % mark, '0x%04x' % prev, '0x%04x' % nxt], 6, what)
        for line, n in lines[c]:
            o.put(line, n)
        o.raw('style_cell_end', [], 1)


def describe_cmp(ctx):
    d = ctx.data
    if d[:4] != b'H\0K\0' or len(d) % 256:
        return None
    o = Out(ctx)
    o.comment('COMPOSER, file type 3: one accompaniment-style bank.  FileIO_SaveRegion3_ExtMem')
    o.comment('(v10 0xf87d2c) writes RHYTHM_PATTERN_BUF_A for the size cmp_sv_mae returns.  The')
    o.comment('bank is the IC19 custom-data style format (docs/accompaniment-style-format.md; cell')
    o.comment('grammar in scripts/build/style_events.py, which decodes it with zero malformed events).')
    o.label('Bank')
    if not emit_style_bank(o, d, 0, len(d), 'Style bank'):
        return None
    return o.done()


def describe_rcm(ctx):
    d = ctx.data
    if d[:4] != b'H\0K\0' or len(d) != 0x72C00:
        return None
    lens = struct.unpack_from('<9I', d, 0x40)
    if lens[0] != 0x400 or 0x400 + sum(lens[1:8]) + 0xF400 != len(d):
        return None
    o = Out(ctx)
    o.comment('RHYTHM CUSTOM, file type 6: the Initial Data Disk\'s image of Custom Data Flash')
    o.comment('sections 0..7.  FileIO_LoadRegion6_Simple (v10 0xf87913) -> FileIO_LoadRcmToFlash')
    o.comment('(v10 0xf186a9) copies eight chunks, lengths from the table at +0x40 (entry 0 = this')
    o.comment('header; the last chunk is a hard-coded 0xf400), to the flash sections 0x300000,')
    o.comment('0x319800, 0x330000, 0x349800, 0x360000, 0x379800, 0x390000 and 0x3b0000, stamping the')
    o.comment('section number into the directory pointers on the way (Pack12BitValueWithBank 0xf1710c).')
    o.label('Header')
    o.ascii(d[:4], 'magic')
    o.raw('.long', ['0x%x' % x for x in struct.unpack_from('<15I', d, 4)], 60,
          'header +4..+0x3f as u32 words (TODO: not named; FileIO_LoadRcmToFlash reads only the table at +0x40)')
    o.label('ChunkLengths')
    o.raw('.long', ['0x%x' % x for x in lens], 36, 'header, sections 0..6, unused (0xf400 is used)')
    o.fill_or_inc(d[0x64:0x400], 'rest of the header')
    p = 0x400
    for k in range(8):
        n = lens[k + 1] if k < 7 else 0xF400
        o.label('Section%d' % k)
        if k < 7:
            if not emit_style_bank(o, d, p, p + n, 'Section %d, to flash' % k):
                o.inc(n, 'section %d (not a style bank)' % k)
        else:
            o.comment('Section 7, the block slot store (technics-docs custom-data-flash.md):')
            o.comment('"H\\0K\\0", slot counts at +8 / +0xa, owner maps at +0x10 / +0x50.')
            o.ascii(d[p:p + 4], 'magic')
            o.raw('.short', ['0x%04x' % x for x in struct.unpack_from('<2H', d, p + 4)], 4,
                  'header +4..+7 (TODO: not named)')
            o.raw('.short', [str(x) for x in struct.unpack_from('<2H', d, p + 8)], 4,
                  'small slots, large slots')
            o.fill_or_bytes(d[p + 12:p + 0x10], 'header +0xc..+0xf (TODO: not named)')
            o.fill_or_bytes(d[p + 0x10:p + 0x38], 'owner byte per small slot, 0 = free (Flash_WriteSlotOwnerMap)')
            o.fill_or_bytes(d[p + 0x38:p + 0x50], 'between the owner maps (TODO: not named)')
            o.fill_or_bytes(d[p + 0x50:p + 0x54], 'owner byte per large slot')
            o.fill_or_bytes(d[p + 0x54:p + 0x410], 'up to the slots (TODO: not named)')
            for k in range(40):
                q = p + 0x410 + 470 * k
                o.fill_or_bytes(d[q:q + 470], 'small slot %d (a sound-memory record, 470 B; erased here)' % k)
            for k in range(4):
                q = p + 0x4D80 + 10535 * k
                o.fill_or_bytes(d[q:q + 10535], 'large slot %d (10,535 B; erased here)' % k)
            o.fill_or_bytes(d[p + 0x4D80 + 4 * 10535:p + n], 'rest of the sector chunk')
        p += n
    return o.done()


# ---------------------------------------------------------------------------------------------
# SQT: SEQUENCER -- song slots, then the event memory in linked 256-byte cells

def describe_sqt(ctx):
    d = ctx.data
    if d[:4] != b'ZZZZ' or d[5:7] != b'\x01\x08' or len(d) % 256:
        return None
    nslots = 10 if d[4] == 1 else 1
    if d[4] not in (0, 1) or len(d) < nslots * 0x800:
        return None
    o = Out(ctx)
    o.comment('Slot fields: notes/floppy-kn5000-2026-10-29/specs/sqt_slot_header.json (RAM image of the')
    o.comment('current-song record 0xf180; the +0xd0 track table gives each present track\'s first cell).')
    o.comment('SEQUENCER, file type 2.  Song-slot headers of 0x800 bytes (RAM SEQ_SONG_SLOTS 0xab000,')
    o.comment('10 slots), then the event memory as linked 256-byte cells.  +4 = 1: all 10 slots, as')
    o.comment('FileIO_SaveRegion2_ExtMem (v10 0xf87cac) writes them (0x5000, then the event memory')
    o.comment('from 0xb0000 for the size SeqSavePre returns); +4 = 0: one song.  "01 08" at +5 is')
    o.comment('the signature HD-AE5000 checks (technics-docs hdae5000-filesystem.md).')
    for s in range(nslots):
        b = s * 0x800
        o.label('Song_%d' % (s + 1))
        o.ascii(d[b:b + 4], 'slot signature')
        o.raw('.byte', ['%d' % d[b + 4], '0x%02x' % d[b + 5], '0x%02x' % d[b + 6]], 3,
              'all-songs flag, signature')
        o.struct(SS['sqt_slot_a'], d[b + 7:b + 0x100])
        nm = d[b + 0x100:b + 0x110]
        if printable(nm):
            o.ascii(nm, 'song name')
        else:
            o.inc(16, 'song name field, not text')
        hd, tl = SS['sqt_slot_b_head'], SS['sqt_slot_b_tail']
        o.struct(hd, d[b + 0x110:b + 0x110 + hd.size])
        pb, pn = tl.panel
        emit_block(o, d, b + pb, b + pb + pn, 'PanelTlv_Block0_Layout',
                   'The song\'s copy of panel block 0 (taken when the song is recorded)')
        o.struct(tl, d[b + pb + pn:b + 0x800])
    p = nslots * 0x800
    o.label('Events')
    o.comment('Event cells: +0 flags, +1 PREV, +3 NEXT (one-based), 251 bytes of events (the')
    o.comment('demo-song grammar; analysis/disk-format-probes/disk_seq_chains.py).  A chain starts at')
    o.comment('a cell whose PREV is 0 and byte 0 is not 0; which track each chain is, the slot header')
    o.comment('says somewhere not yet established.  Byte-0 = 0 cells are the free list.')
    n = (len(d) - p) // 256
    base = p

    def cell(c):                          # one-based cell number -> offset
        return base + (c - 1) * 256

    owner, chains = {}, []
    for h in range(1, n + 1):             # a chain starts at a cell with PREV = 0
        if struct.unpack_from('<H', d, cell(h) + 1)[0] != 0 or d[cell(h)] == 0x00:
            continue
        seq, c = [], h
        while 1 <= c <= n and c not in owner:
            owner[c] = (len(chains), len(seq), 'chain from cell %d' % h)
            seq.append(c)
            c = struct.unpack_from('<H', d, cell(c) + 3)[0]
        chains.append(seq)
    for c in range(1, n + 1):
        if c not in owner:
            owner[c] = (len(chains), 0, 'in no chain (free list)' if d[cell(c)] == 0 else 'in no chain')
            chains.append([c])
    lines = {}
    for seq in chains:
        stream = b''.join(d[cell(c) + 5:cell(c) + 256] for c in seq)
        toks = events.tokenize_seq(stream)
        bounds = [(251 * k, 251 * (k + 1)) for k in range(len(seq))]
        for c, part in zip(seq, events.cut(stream, toks, bounds)):
            lines[c] = part
    for c in range(1, n + 1):
        b = d[cell(c):cell(c) + 256]
        prev, nxt = struct.unpack_from('<HH', b, 1)
        ch, k, who = owner[c]
        o.raw('seq_cell', ['0x%02x' % b[0], str(prev), str(nxt) if nxt != 0xFFFF else '0xffff'], 5,
              'cell %d: %s, cell %d of its chain' % (c, who, k + 1))
        for line, m in lines[c]:
            o.put(line, m)
    return o.done()


DESCRIBERS = {
    'TXT': describe_txt, 'BMP': describe_bmp, 'LSW': describe_lsw, 'PMT': describe_pmt,
    'TM': describe_tm, 'CMP': describe_cmp, 'RCM': describe_rcm, 'SQT': describe_sqt,
}


def describe(ctx):
    ext = ctx.entry.ext.decode('latin-1').strip().upper()
    f = DESCRIBERS.get(ext)
    return f(ctx) if f else None
