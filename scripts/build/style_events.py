#!/usr/bin/env python3
r"""style_events.py -- IC19 accompaniment style data <-> readable event listings, ROUND TRIP.

QUESTION ANSWERED: can the KN5000's custom accompaniment styles be read as music instead of as
four opaque 160KB blobs, and still rebuild the ROM byte for byte?

The format is documented in docs/accompaniment-style-format.md and proved by
scripts/analysis/style_cell_chains.py. In short: 256-byte cells in doubly-linked chains, a
249-byte event payload each, and a self-delimiting event grammar.

    status         args  meaning
    0x81 BEAT         0  advance one beat
    0x83 END          -  end of the chain's stream
    0x90 NOTE         5  pos, note, velocity, dur_ticks, dur_beats   (96 ticks per beat)
    0x91 NOTE2        7  the same five, plus two trailing bytes (range 0..25)
    0xD1 CTL1         2  pos, value
    0xD2 CTL2         2  pos, value  -- value clusters 61..64
    0xD3 CTL3         2  pos, value  -- value is 0 or 127 only, i.e. a switch

Events are emitted per CHAIN, because an event may straddle a cell boundary; the listing records
which cells a chain occupies so `build` can re-split the rendered bytes at 249-byte boundaries
and put them back. Bytes after 0x83 are preserved verbatim as PAD -- they are not always zero.

⚠ A SECOND CELL MARKER, found 2026-09-01: 816 blocks across all four banks are shaped exactly
like a cell (byte[5]==0x87, byte[255]==0x87) but carry byte[0]==0x00 where a chain cell carries
0x80. Every one of them has prev=next=0xFFFF (a trivial, unlinked, single-block "chain"), and
813 of 816 decode with ZERO malformed events under the SAME grammar. Better: 811 of the 816 are
one single 256-byte block, byte-for-byte IDENTICAL in every section (all of section_3_4's and
section_5_6's, 124/126 of section_0's, 254/257 of section_1_2's) -- an ascending eight-note run,
0x30..0x37, one BEAT after each note, then END, then zero PAD to the block's end. The other
three hit an unrecognised status a few bytes in and are exported as one big PAD run instead of
being decoded -- honestly inert, not silently wrong. Nothing here says what 0x00 MEANS (a
factory-blank template slot is a plausible guess, not a claim); `cells_of` just stops requiring
byte[0]==0x80 and lets the same event grammar speak for itself.

BANK LAYOUT (format 3 of the listing, 2026-10-31).  A bank is one Composer style image: the RAM layout
of RHYTHM_PATTERN_BUF_A, which FileIO_SaveRegion3_ExtMem (v10 0xF87D2C) saves as a .CMP file and
FileIO_SaveRcmFromFlash / FileIO_LoadRcmToFlash move between an .RCM file and these flash sections.  The
field layout and the evidence for every field are in scripts/build/style_bank_layout.py, which the KN5000
floppy describer (floppy/kn5000/formats.py) imports too, so both name every field the same way.
In short: header +0x00 magic, +0x0e password, +0x10 composer_mode, the size words +0x1e..+0x2f, reserved
bytes; 30 section records from +0x60 (part cells, time_sig, last_measure, rec_chord, edit_flags, the
section's style pair, five 8-byte part settings DRUM BASS ACCOMP1-3, name); the five chord maps at +0xba0
and the measure-start table at +0xc40 (both zero in the factory banks); the fill-in cell at +0x13c0; the
256-byte cells from +0x1400 (AccPatch_InitSlotChain: base + 0x1400; the first 0x96 = 150 are the head
entries, 30 sections x 5 parts, the rest the continuation cells from +0xaa00).

THE LISTING (format 3): `#` lines are comments; `SIZE n` first; then, in address order,
  FILL a-b xx            blocks a..b all byte xx
  BANK b                 a bank at block b; its indented lines type its first 20 blocks:
    reserved_04 / _0b / _11 / _15 / _1d <hex|zero>, password, composer_mode, capacity16, dir_offset,
    record_size, record_count, cell_size, cell_count, name_offset, reserved_2c, used_size16,
    reserved_30 <hex|zero>;
    SECTION k cells=drum,bass,acc1,acc2,acc3 reserved_02=wwww name="..." (\0, \xNN, \\, \" escapes), with
      time_sig t, last_measure m, rec_chord key= minor= accomp_7th= bass_7th= bit7=, edit_flags xx,
      style number= group=, reserved_12 <hex|zero>, part <drum|bass|acc1|acc2|acc3> sound= bank= pan=
      reverb= pc_byte4= pitch_point= high_key= reserved_7=, reserved_50 <hex|zero>;
    CHORDMAP n variations=v0,v1,v2,v3 reserved=<hex|zero> name="..." (five), or chord_maps zero;
    MEASURES s part c:o c:o ... (eight cell:offset pairs; 60 lines), or measure_starts zero;
    FILLIN mark= prev= next= and its events
  CELL b mark=mm prev=pppp next=nnnn   one 256-byte cell (byte 5 and byte 255 are 0x87)
  RAW b + 8 hex lines    a block nothing above describes (none in the factory banks)
then one CHAIN per chain head (prev = 0xffff), its events one per line: st_beat, st_end,
st_note pos note vel dur_ticks dur_beats, st_note2 (+2), st_ctl1..st_ctl5 pos value (the floppy lane's
mnemonics; st_ctl4/5 occur only on floppies), PAD <hex> after st_end, UNDECODED <hex> from a byte the grammar
cannot start an event with.  Which cells a chain occupies follows from the CELL links, exactly as export()
found them.  The three UNDECODED chains (0x0EA in section_0, 0x0E5 in section_1_2, 0x0FE in the Composer image)
begin with data bytes: single cells with prev = 0xffff whose payload starts inside an event.

    python3 scripts/build/style_events.py export   # blobs -> .styles listings (run once)
    python3 scripts/build/style_events.py build    # listings -> blobs (build step)
    python3 scripts/build/style_events.py verify   # assert the round trip is byte-exact

⚠ WHAT THIS DOES NOT CLAIM. NOTE2's two trailing bytes and the three controller values are
NAMED, not understood: the argument counts are confirmed across all 50,245 events but nobody has
established what they select. They are emitted as numbers, never as invented labels. Nor does the
0x00-marker cell's MEANING: only its shape and decodability are established.
"""
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import style_bank_layout as L  # noqa: E402  (the shared field layout)

REPO = pathlib.Path(__file__).resolve().parent.parent.parent
INC = REPO / 'custom_data' / 'includes'
OUT = REPO / 'custom_data' / 'styles'
# blob -> (offset into original_ROMs/kn5000_custom_data.ic19, length). The chip is the 1 MB
# at ROM 0x300000, so the offset is the section's ROM address minus 0x300000.
SECTIONS = {'section_0':    (0x00000, 0x17000),
            'section_1_2':  (0x19000, 0x2E000),
            'section_3_4':  (0x49000, 0x2E000),
            'section_5_6':  (0x79000, 0x2E000)}
ROM = REPO / 'original_ROMs' / 'kn5000_custom_data.ic19'

# One more bank in the SAME format, living inside table_data rather than IC19:
# Composer_FactoryMemoryImage, the 64 KB at ROM 0x9B4000 (it was a slice of the deleted
# includes/icons_to_strings.bin; export and verify read it from original_ROMs/kn5000_table_data.rom). It was
# classified "partially understood -- no field spec, no parser" until the IC19 container was
# solved; the identical rules decode it with 168/168 pointers, 84/84 back-links and 7,457
# events, none malformed. Its section nibble is 0 rather than 1.
EXTRA = {'Composer_FactoryMemoryImage':
         (REPO / 'original_ROMs' / 'kn5000_table_data.rom', 0x9B4000 - 0x800000, 0x10000,
          REPO / 'table_data' / 'includes' / 'generated')}
PAYLOAD = 249
ARGS = {0x90: 5, 0x91: 7, 0x81: 0, 0xD1: 2, 0xD2: 2, 0xD3: 2}
NAME = {0x90: 'NOTE', 0x91: 'NOTE2', 0x81: 'BEAT', 0x83: 'END',
        0xD1: 'CTL1', 0xD2: 'CTL2', 0xD3: 'CTL3'}
CODE = {v: k for k, v in NAME.items()}


def hk_sections(d):
    hks = [i for i in range(0, len(d) - 4, 0x100) if d[i:i + 4] == b'H\x00K\x00']
    for k, s in enumerate(hks):
        yield s, (hks[k + 1] if k + 1 < len(hks) else len(d))


def cells_of(d, s, e):
    # byte[0] is 0x80 on a chain cell and 0x00 on the second marker documented above; both
    # shapes are required to also close with a second 0x87 at byte[255], which every one of the
    # 1564 originally-known cells already does (proven by scripts/analysis/style_cell_chains.py),
    # so adding it costs nothing there and is what keeps this from also matching random bytes.
    return [o for o in range(s, e - 255, 256)
            if d[o] in (0x80, 0x00) and d[o + 5] == 0x87 and d[o + 255] == 0x87]


def chains_of(d, cells, base):
    cs = set(cells)
    out = []
    for h in [o for o in cells if (d[o + 1] | (d[o + 2] << 8)) == 0xFFFF]:
        seq, o, seen = [], h, set()
        while o is not None and o not in seen:
            seen.add(o)
            seq.append(o)
            nx = d[o + 3] | (d[o + 4] << 8)
            o = ((nx & 0xFFF) + base) * 256 if nx != 0xFFFF else None
            if o is not None and o not in cs:
                break
        out.append(seq)
    return out


def sources():
    """(name, bytes) for every bank this script owns."""
    for sec, (off, ln) in SECTIONS.items():
        yield sec, ROM.read_bytes()[off:off + ln]
    for name, (src, off, ln, _) in EXTRA.items():
        yield name, src.read_bytes()[off:off + ln]


# --- The typed listing (format 3, 2026-10-31) ------------------------------------------------
# Field names and their evidence: scripts/build/style_bank_layout.py (shared with floppy/kn5000/formats.py).
SECTION_ROLE = L.SECTION_ROLE
# The listing's event grammar: the IC19 grammar above plus the two controllers only the floppy CMP/RCM
# banks use (0xd4 / 0xd5, two data bytes; floppy/kn5000/events.py).  Mnemonics are the floppy lane's.
ST_ARGS = {**ARGS, 0xD4: 2, 0xD5: 2}
ST_NAME = {0x81: 'st_beat', 0x83: 'st_end', 0x90: 'st_note', 0x91: 'st_note2',
           0xD1: 'st_ctl1', 0xD2: 'st_ctl2', 0xD3: 'st_ctl3', 0xD4: 'st_ctl4', 0xD5: 'st_ctl5'}
ST_CODE = {v: k for k, v in ST_NAME.items()}
HDR_BLOCKS = 20             # cells start at bank + 0x1400 (AccPatch_InitSlotChain: base + 0x1400)
HEADER_U16 = L.HEADER_U16
U16_DEC = {'record_count', 'cell_count'}
HDR_BYTES = {nm: (off, n) for off, n, nm in L.HEADER_BYTES}
REC_LINES = {'time_sig', 'last_measure', 'rec_chord', 'edit_flags', 'style', 'reserved_12', 'part', 'reserved_50'}


def q(b):
    """bytes -> a quoted Latin-1 string; \\0, \\\\, \\" and \\xNN for the rest."""
    o = []
    for c in b:
        if c == 0:
            o.append('\\0')
        elif c in (0x22, 0x5c):
            o.append('\\' + chr(c))
        elif 0x20 <= c < 0x7f:
            o.append(chr(c))
        else:
            o.append('\\x%02x' % c)
    return '"' + ''.join(o) + '"'


def unq(t):
    assert t[0] == '"' and t[-1] == '"', t
    t, o, i = t[1:-1], bytearray(), 0
    while i < len(t):
        if t[i] == '\\':
            n = t[i + 1]
            if n == '0':
                o.append(0); i += 2
            elif n == 'x':
                o.append(int(t[i + 2:i + 4], 16)); i += 4
            else:
                o.append(ord(n)); i += 2
        else:
            o.append(ord(t[i])); i += 1
    return bytes(o)


def hexorzero(b):
    return 'zero' if not any(b) else b.hex()


def unhexorzero(t, n):
    b = bytes(n) if t == 'zero' else bytes.fromhex(t)
    assert len(b) == n, (t, n)
    return b


def event_lines(pay, indent):
    """One event per line over a payload; PAD after st_end, UNDECODED at a status outside the grammar."""
    out, i = [], 0
    while i < len(pay):
        st = pay[i]
        n = ST_ARGS.get(st) if st != 0x83 else 0
        if n is None or i + 1 + n > len(pay):
            break
        out.append(indent + ST_NAME[st] + ''.join(' %d' % x for x in pay[i + 1:i + 1 + n]))
        i += 1 + n
        if st == 0x83:
            break
    kind = 'PAD' if out and out[-1].strip() == 'st_end' else 'UNDECODED'
    for k in range(i, len(pay), 32):
        out.append(indent + kind + ' ' + pay[k:k + 32].hex())
    return out


def parse_event(t):
    w = t.split()
    if w[0] in ('PAD', 'UNDECODED'):
        return bytes.fromhex(w[1])
    return bytes([ST_CODE[w[0]]] + [int(x) for x in w[1:]])


def blocks_uniform(d, a, e):
    """end of the run of identical uniform 256-byte blocks starting at a (a itself if not uniform)."""
    b = d[a:a + 256]
    if len(b) < 256 or len(set(b)) != 1:
        return a
    j = a
    while j + 256 <= e and d[j:j + 256] == b:
        j += 256
    return j


def u16(d, o):
    return d[o] | (d[o + 1] << 8)


def kv_of(words):
    return dict(x.split('=', 1) for x in words if '=' in x)


def export_bank_header(d, s):
    """Lines for the bank's first 20 blocks: header, 30-section directory, the area to +0x1400."""
    out = [f'BANK {s >> 8:03X}']
    assert d[s:s + 4] == b'H\x00K\x00'
    out.append('  # +0x00 magic "H\\0K\\0"; fields: scripts/build/style_bank_layout.py')
    for off, n, nm in L.HEADER_BYTES:
        out.append(f'  {nm} ' + hexorzero(d[s + off:s + off + n]))
    out.append('  password 0x%04x' % u16(d, s + L.PASSWORD))
    out.append('  composer_mode %d' % d[s + L.COMPOSER_MODE])
    for off, nm in HEADER_U16:
        v = u16(d, s + off)
        out.append(f'  {nm} ' + (str(v) if nm in U16_DEC else '0x%04x' % v))
    out.append('  reserved_30 ' + hexorzero(d[s + 0x30:s + 0x60]))
    for k in range(30):
        r = s + 0x60 + 0x60 * k
        w = [u16(d, r + 2 * i) for i in range(6)]
        out.append(f'  # section {k}: {SECTION_ROLE[k]}')
        out.append(f'  SECTION {k} cells=' + ','.join('%04x' % x for x in (w[0],) + tuple(w[2:])) +
                   ' reserved_02=%04x' % w[1] + ' name=' + q(d[r + L.NAME_OFF:r + L.NAME_OFF + 16]))
        out.append(f'    time_sig {d[r + 0x0c]}' + (f'  # {L.time_sig_name(d[r + 0x0c])}'))
        out.append(f'    last_measure {d[r + 0x0d]}')
        key, minor, a7, b7, hi = L.rec_chord_fields(d[r + 0x0e])
        out.append(f'    rec_chord key={key} minor={minor} accomp_7th={a7} bass_7th={b7} bit7={hi}'
                   f'  # {L.key_name(key)}')
        out.append('    edit_flags 0x%02x' % d[r + 0x0f])
        out.append('    style number=0x%02x group=%d' % (d[r + 0x10], d[r + 0x11]))
        out.append('    reserved_12 ' + hexorzero(d[r + 0x12:r + 0x18]))
        for i, pt in enumerate(L.PARTS):
            o = r + L.PART_BASE + L.PART_SIZE * i
            out.append(f'    part {pt} ' + ' '.join(
                f'{f}=' + ('0x%02x' % d[o + j] if f in ('high_key', 'pc_byte4') else str(d[o + j]))
                for j, f in enumerate(L.PART_FIELDS)))
        out.append('    reserved_50 ' + hexorzero(d[r + L.TAIL_OFF:r + 0x60]))
    cm = d[s + L.CHORD_MAP_OFF:s + L.MEASURE_OFF]
    if not any(cm):
        out.append('  chord_maps zero')
    else:
        for n in range(L.CHORD_MAPS):
            c = s + L.CHORD_MAP_OFF + L.CHORD_MAP_SIZE * n
            out.append(f'  CHORDMAP {n} variations=' + ','.join('%d' % x for x in d[c:c + 4]) +
                       ' reserved=' + hexorzero(d[c + 4:c + 16]) + ' name=' + q(d[c + 16:c + 32]))
    mt = d[s + L.MEASURE_OFF:s + L.FILLIN_OFF]
    if not any(mt):
        out.append('  measure_starts zero')
    else:
        for v in range(L.MEASURE_VARS):
            for i, pt in enumerate(L.PARTS):
                o = s + L.MEASURE_OFF + 160 * v + 32 * i
                out.append(f'  MEASURES {v} {pt} ' + ' '.join(
                    '%x:%x' % (u16(d, o + 4 * m), u16(d, o + 4 * m + 2)) for m in range(L.MEASURES)))
    f = s + L.FILLIN_OFF
    assert d[f + 5] == 0x87, hex(f)
    out.append('  FILLIN mark=%02x prev=%04x next=%04x' % (d[f], u16(d, f + 1), u16(d, f + 3)))
    out += event_lines(d[f + 6:f + 0x40], '    ')
    return out


def export():
    OUT.mkdir(parents=True, exist_ok=True)
    for sec, d in sources():
        L = [f'# {sec}: {len(d)} bytes, {len(d) // 256} blocks of 256',
             '# Produced by scripts/build/style_events.py (format 3); scripts/build/style_bank_layout.py defines',
             '# every field and its evidence.  docs/accompaniment-style-format.md',
             '# describes the cells and the event grammar.', '',
             f'SIZE {len(d)}']
        banks = list(hk_sections(d))
        cellset, chainlist = set(), []
        for s, e in banks:
            cells = cells_of(d, s, e)
            assert cells and cells[0] == s + HDR_BLOCKS * 256, (sec, hex(s))
            cellset.update(cells)
            chainlist += chains_of(d, cells, cells[0] >> 8)
        starts = {s for s, _ in banks}
        off = 0
        while off < len(d):
            if off in starts:
                L += export_bank_header(d, off)
                off += HDR_BLOCKS * 256
                continue
            if off in cellset:
                b = d[off:off + 6]
                L.append('CELL %03X mark=%02x prev=%04x next=%04x' % (off >> 8, b[0], b[1] | (b[2] << 8), b[3] | (b[4] << 8)))
                off += 256
                continue
            j = blocks_uniform(d, off, min([x for x in starts if x > off] + [len(d)]))
            if j > off:
                L.append('FILL %03X-%03X %02x' % (off >> 8, (j >> 8) - 1, d[off]))
                off = j
                continue
            L.append(f'RAW {off >> 8:03X}')
            L += ['  ' + d[off + i:off + i + 32].hex() for i in range(0, 256, 32)]
            off += 256
        L.append('')
        for seq in chainlist:
            pay = b''.join(d[o + 6:o + 255] for o in seq)
            L.append(f'CHAIN {seq[0] >> 8:03X} cells={len(seq)}')
            L += event_lines(pay, '  ')
            L.append('')
        (OUT / f'{sec}.styles').write_text('\n'.join(L) + '\n', encoding='utf-8')
        print(f"  wrote {sec}.styles")


def rebuild(sec):
    txt = [l for l in (OUT / f'{sec}.styles').read_text(encoding='utf-8').splitlines()
           if l.strip() and not l.lstrip().startswith('#')]
    size = int(txt[0].split()[1]) if txt[0].startswith('SIZE ') else None
    assert size, f'{sec}: no SIZE line (format 1 listing?)'
    out = bytearray(size)
    cells, chains = [], {}
    bank = None
    i = 1

    while i < len(txt):
        l = txt[i]
        w = l.split()
        if l.startswith('BANK '):
            s = int(w[1], 16) * 256
            out[s:s + 4] = b'H\x00K\x00'
            bank, rec = s, None
            i += 1
            continue
        if bank is not None and rec is not None and l.startswith('    ') and not l.startswith('     ') and \
                w[0] in REC_LINES:
            r = rec
            kv = kv_of(w[1:])
            if w[0] == 'time_sig':
                out[r + 0x0c] = int(w[1])
            elif w[0] == 'last_measure':
                out[r + 0x0d] = int(w[1])
            elif w[0] == 'rec_chord':
                out[r + 0x0e] = L.rec_chord_byte(int(kv['key']), int(kv['minor']), int(kv['accomp_7th']),
                                                 int(kv['bass_7th']), int(kv['bit7']))
            elif w[0] == 'edit_flags':
                out[r + 0x0f] = int(w[1], 16)
            elif w[0] == 'style':
                out[r + 0x10] = int(kv['number'], 0)
                out[r + 0x11] = int(kv['group'], 0)
            elif w[0] == 'reserved_12':
                out[r + 0x12:r + 0x18] = unhexorzero(w[1], 6)
            elif w[0] == 'reserved_50':
                out[r + L.TAIL_OFF:r + 0x60] = unhexorzero(w[1], 16)
            else:
                o = r + L.PART_BASE + L.PART_SIZE * L.PARTS.index(w[1])
                kv = kv_of(w[2:])
                for j, fn in enumerate(L.PART_FIELDS):
                    out[o + j] = int(kv[fn], 0)
            i += 1
            continue
        if l.startswith('  ') and not l.startswith('    ') and bank is not None:
            s = bank
            if w[0] in HDR_BYTES:
                off, n = HDR_BYTES[w[0]]
                out[s + off:s + off + n] = unhexorzero(w[1], n)
            elif w[0] == 'password':
                out[s + L.PASSWORD:s + L.PASSWORD + 2] = int(w[1], 0).to_bytes(2, 'little')
            elif w[0] == 'composer_mode':
                out[s + L.COMPOSER_MODE] = int(w[1])
            elif w[0] == 'reserved_30':
                out[s + 0x30:s + 0x60] = unhexorzero(w[1], 0x30)
            elif w[0] in dict((n, o) for o, n in HEADER_U16):
                o = dict((n, o) for o, n in HEADER_U16)[w[0]]
                out[s + o:s + o + 2] = int(w[1], 0).to_bytes(2, 'little')
            elif w[0] == 'SECTION':
                k = int(w[1])
                rec = s + 0x60 + 0x60 * k
                kv = kv_of(w[2:4])
                p = [int(x, 16) for x in kv['cells'].split(',')]
                words = [p[0], int(kv['reserved_02'], 16)] + p[1:]
                for n, v in enumerate(words):
                    out[rec + 2 * n:rec + 2 * n + 2] = v.to_bytes(2, 'little')
                out[rec + L.NAME_OFF:rec + L.NAME_OFF + 16] = unq(l.split(' name=', 1)[1])
            elif w[0] in ('chord_maps', 'measure_starts'):
                assert w[1] == 'zero', l
            elif w[0] == 'CHORDMAP':
                c = s + L.CHORD_MAP_OFF + L.CHORD_MAP_SIZE * int(w[1])
                kv = kv_of(w[2:4])
                out[c:c + 4] = bytes(int(x) for x in kv['variations'].split(','))
                out[c + 4:c + 16] = unhexorzero(kv['reserved'], 12)
                out[c + 16:c + 32] = unq(l.split(' name=', 1)[1])
            elif w[0] == 'MEASURES':
                o = s + L.MEASURE_OFF + 160 * int(w[1]) + 32 * L.PARTS.index(w[2])
                for m, pr in enumerate(w[3:3 + L.MEASURES]):
                    c, off = (int(x, 16) for x in pr.split(':'))
                    out[o + 4 * m:o + 4 * m + 2] = c.to_bytes(2, 'little')
                    out[o + 4 * m + 2:o + 4 * m + 4] = off.to_bytes(2, 'little')
            elif w[0] == 'FILLIN':
                kv = dict(x.split('=') for x in w[1:])
                f = s + 0x13C0
                out[f] = int(kv['mark'], 16)
                out[f + 1:f + 3] = int(kv['prev'], 16).to_bytes(2, 'little')
                out[f + 3:f + 5] = int(kv['next'], 16).to_bytes(2, 'little')
                out[f + 5] = 0x87
                b = bytearray()
                i += 1
                while i < len(txt) and txt[i].startswith('    '):
                    b += parse_event(txt[i].strip())
                    i += 1
                assert len(b) == 0x40 - 6, f'{sec} FILLIN at {f:#x}: {len(b)} B'
                out[f + 6:f + 0x40] = b
                continue
            else:
                raise ValueError(f'{sec}: unknown bank line {l!r}')
            i += 1
            continue
        bank = None
        if l.startswith('CELL '):
            blk = int(w[1], 16)
            kv = dict(x.split('=') for x in w[2:])
            o = blk * 256
            out[o] = int(kv['mark'], 16)
            out[o + 1:o + 3] = int(kv['prev'], 16).to_bytes(2, 'little')
            out[o + 3:o + 5] = int(kv['next'], 16).to_bytes(2, 'little')
            out[o + 5] = out[o + 255] = 0x87
            cells.append(o)
            i += 1
            continue
        if l.startswith('FILL '):
            a, b = (int(x, 16) for x in w[1].split('-'))
            out[a * 256:(b + 1) * 256] = bytes([int(w[2], 16)]) * ((b + 1 - a) * 256)
            i += 1
            continue
        if l.startswith('RAW '):
            blk = int(w[1], 16)
            out[blk * 256:blk * 256 + 256] = bytes.fromhex(''.join(txt[i + 1 + k].strip() for k in range(8)))
            i += 9
            continue
        if l.startswith('CHAIN '):
            head = int(w[1], 16) * 256
            b = bytearray()
            i += 1
            while i < len(txt) and txt[i].startswith('  '):
                b += parse_event(txt[i].strip())
                i += 1
            chains[head] = bytes(b)
            continue
        raise ValueError(f'{sec}: unknown line {l!r}')
    # the chains follow the links just written, exactly as export() found them
    placed = set()
    for s, e in hk_sections(bytes(out)):
        cs = [c for c in cells if s <= c < e]
        for seq in chains_of(out, cs, s // 256 + HDR_BLOCKS):
            body = chains[seq[0]]
            assert len(body) == len(seq) * PAYLOAD, \
                f'{sec} chain {seq[0] >> 8:03X}: {len(body)} B for {len(seq)} cells'
            for n, o in enumerate(seq):
                out[o + 6:o + 6 + PAYLOAD] = body[n * PAYLOAD:(n + 1) * PAYLOAD]
                placed.add(o)
    assert placed == set(cells), f'{sec}: {len(set(cells) - placed)} cells in no chain'
    return bytes(out)


def build():
    tot = 0
    INC.mkdir(parents=True, exist_ok=True)
    for sec in SECTIONS:
        d = rebuild(sec)
        (INC / f'{sec}.bin').write_bytes(d)
        tot += len(d)
    for name, (_, _, _, outdir) in EXTRA.items():
        outdir.mkdir(parents=True, exist_ok=True)
        d = rebuild(name)
        (outdir / f'{name}.bin').write_bytes(d)
        tot += len(d)
    print(f"style_events: rebuilt {len(SECTIONS) + len(EXTRA)} banks, {tot:,} B from event listings")


def verify():
    """Compare against the ORIGINAL ROM, not the .bin -- the .bin is a build product now."""
    bad = 0
    for sec, want in sources():
        got = rebuild(sec)
        if got == want:
            print(f"  ok  {sec:<14} {len(want):>8,} B")
        else:
            bad += 1
            n = sum(1 for a, b in zip(got, want) if a != b) if len(got) == len(want) else -1
            print(f"  *** {sec}: MISMATCH ({n} bytes)" if n >= 0 else f"  *** {sec}: LENGTH")
    if bad:
        sys.exit(f"{bad} bank(s) do not round-trip")
    print("ROUND TRIP EXACT: the event listings rebuild all four style banks")


if __name__ == '__main__':
    {'export': export, 'build': build, 'verify': verify}[sys.argv[1] if len(sys.argv) > 1 else 'verify']()
