"""floppy/wsa1/formats.py -- the SX-WSA1R file-format describers (floppy/README.md).

The WSA1R's disk code (prom_a DiskLoad_ByContentType / DiskSave_ByContentType, wsa1/notes/
FINDINGS-prom_b-disk-and-file-menus.md) writes RAM images under fixed extensions; .MID files are
Standard MIDI Files written by prom_b's SMF writer (wsa1/notes/FINDINGS-prom_b-smf-writer.md).
"""
import os
import struct
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'tools', 'kd'))
import kd_describe  # noqa: E402

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'kn5000'))
import events  # noqa: E402  (the KN5000 floppy tree's song tokenizer)

MODEL = 'wsa1'


def smf_length(d):
    """The length of the Standard MIDI File at the start of d: MThd, then its tracks' chunks."""
    if d[:4] != b'MThd':
        return None
    i = 8 + struct.unpack('>I', d[4:8])[0]
    ntrk = struct.unpack('>H', d[10:12])[0]
    for _ in range(ntrk):
        if d[i:i + 4] != b'MTrk':
            return None
        i += 8 + struct.unpack('>I', d[i + 4:i + 8])[0]
    return i if i <= len(d) else None


def describe_mid(ctx):
    n = smf_length(ctx.data)
    if n is None:
        return None
    kd_describe._reg(MODEL, ctx.disk)[1].append(
        '$(eval $(call KD_CUT,%s,%s,%s,smf.mid,0,%d))' % (MODEL, ctx.disk, ctx.extracted, n))
    L = ['; A Standard MIDI File (format %d, %d tracks, division %d), cut out as a .mid of its own.'
         % struct.unpack('>HHH', ctx.data[8:14]), '',
         '%s:\t.incbin\t"%s.smf.mid"' % (ctx.label, ctx.extracted)]
    if n < len(ctx.data):
        L += ['; The rest of the last 1024-byte output window.  The SMF writer flushes whole windows',
              '; (SmfOut_WindowsFlushed 0x126C counts them; the track length at 0xF7789A is computed from',
              '; it), so the file is a multiple of 1024 bytes and these bytes are what the window buffer',
              '; still held from earlier output.',
              '; census: opaque -- unknown-dump: stale SMF output-window bytes past the end of the file\'s last track',
              '\t.incbin\t"%s", 0x%x, %d' % (ctx.ref, ctx.offset + n, len(ctx.data) - n)]
    return L


def describe_seq(ctx):
    """SEQUENCER .SEQ: the song store's 256-byte blocks (DiskSave_Sequencer / SeqFile_WriteSeqCompacted,
    wsa1/notes/FINDINGS-prom_b-disk-and-file-menus.md), chains followed from blocks whose PREV is 0."""
    d = ctx.data
    if len(d) % 256 or not d:
        return None
    n = len(d) // 256
    cell = lambda c: (c - 1) * 256  # noqa: E731
    owner, plan = {}, {}
    for h in range(1, n + 1):
        if struct.unpack_from('<H', d, cell(h) + 1)[0] != 0 or not d[cell(h)] & 0x80:
            continue
        seq, c = [], h
        while 1 <= c <= n and c not in owner and c not in seq:
            seq.append(c)
            c = struct.unpack_from('<H', d, cell(c) + 3)[0]
        for k, cc in enumerate(seq):
            owner[cc] = (h, k, len(seq))
        stream = b''.join(d[cell(cc) + 5:cell(cc) + 256] for cc in seq)
        toks = events.tokenize_seq(stream)
        for cc, part in zip(seq, events.cut(stream, toks, [(251 * k, 251 * (k + 1)) for k in range(len(seq))])):
            plan[cc] = [line for line, _ in part]
    L = ['; SEQUENCER song blocks: the song store\'s heap of 256-byte blocks, written by DiskSave_Sequencer',
         '; (prom_b SeqFile_WriteSeqCompacted relinks each copied block: previous 0 at a chain\'s start, next',
         '; 0xFFFF at its end).  Each chain is one stream of events (macros: wsa1/include/wsa1_files.inc).', '',
         '\t.include\t"wsa1_files.inc"', ctx.label + ':']
    for c in range(1, n + 1):
        b = cell(c)
        prev, nxt = struct.unpack_from('<HH', d, b + 1)
        h = owner.get(c)
        L.append('\tseq_block\t0x%02x, %d, %s\t; block %d%s' % (d[b], prev, '0xffff' if nxt == 0xFFFF else nxt, c,
                 ': chain from block %d, %d of %d' % (h[0], h[1] + 1, h[2]) if h else ': in no chain'))
        body = d[b + 5:b + 256]
        if c in plan:
            L += plan[c]
        elif len(set(body)) == 1:
            L.append('\t.fill\t251, 1, 0x%02x' % body[0])
        else:
            L.append('\t; census: opaque -- unknown-dump: a block in no chain (left over in the heap)')
            L.append('\t.incbin\t"%s", 0x%x, 251' % (ctx.ref, ctx.offset + b + 5))
    return L


# ---- SOUND (.TM): CPU 2's sound flash, 0xE80000-0xEBFFFF ------------------------------------------
TM_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'include', 'tm')


def rows(b, w=16):
    return ['\t.byte\t' + ', '.join(str(x) for x in b[k:k + w]) for k in range(0, len(b), w)]


def s_esc(b):
    return '"' + ''.join(chr(c) if 0x20 <= c < 0x7F and c not in (0x22, 0x5C) else '\\%03o' % c for c in b) + '"'


def item(kind, body, head):
    """A record as a content-addressed include file, shared by every disk holding it."""
    import hashlib
    h = hashlib.sha1(body).hexdigest()[:12]
    name = '%s_%s.s' % (kind, h)
    os.makedirs(TM_DIR, exist_ok=True)
    path = os.path.join(TM_DIR, name)
    text = '\n'.join(head) + '\n'
    if not os.path.exists(path) or open(path, 'rb').read() != text.encode('latin-1'):
        open(path, 'wb').write(text.encode('latin-1'))
    return 'tm/' + name


def vals(b):
    return ', '.join(str(x) for x in b)


def tone_item(r):
    head = ['; Generated by floppy/wsa1/formats.py (describe_tm); regenerate rather than edit (floppy/README.md).',
            '; A NORMAL SOUND record, 713 bytes: GENERAL DATA, 4 TONE DATA, 4 MODELING DATA (wsa1_sound.inc, the',
            '; Reference Guide\'s field names; SoundRam_ClearFourBanks writes 64 of them per bank, stride 0x2C9).', '',
            '\t.ascii\t%s\t; NAME' % s_esc(r[:16]), '\tsnd_general\t' + vals(r[16:217])]
    for j in range(4):
        head.append('\tsnd_tone\t%s\t; tone %d' % (vals(r[217 + 81 * j:217 + 81 * (j + 1)]), j + 1))
    for j in range(4):
        head.append('\tsnd_modeling\t%s\t; modeling %d' % (vals(r[541 + 43 * j:541 + 43 * (j + 1)]), j + 1))
    return item('tone', r, head)


def perc_item(r):
    head = ['; Generated by floppy/wsa1/formats.py (describe_tm); regenerate rather than edit (floppy/README.md).',
            '; A DRUM SOUND NOTE DATA block, 150 bytes: NOTE GENERAL DATA, 2 NOTE TONE DATA, 2 NOTE MODELING DATA',
            '; (wsa1_sound.inc; prom_c addresses the class with `ld C,0x96` at 0xFBA5DD).', '',
            '\t.ascii\t%s\t; NAME' % s_esc(r[:13]), '\tnote_general_data\t' + vals(r[13:18])]
    for j in range(2):
        head.append('\tnote_tone_data\t%s\t; tone %d' % (vals(r[18 + 23 * j:18 + 23 * (j + 1)]), j + 1))
    for j in range(2):
        head.append('\tnote_modeling_data\t%s\t; modeling %d' % (vals(r[64 + 43 * j:64 + 43 * (j + 1)]), j + 1))
    return item('perc', r, head)


def describe_tm(ctx):
    d = ctx.data
    if len(d) != 0x40000 or any(d[b * 0x10000:b * 0x10000 + 16] != b'WSA SOUND RAM S%d' % b for b in range(4)):
        return None
    L = ['; SOUND: CPU 2\'s sound flash 0xE80000-0xEBFFFF, four 64 KiB banks.  DiskLoad_Sound (prom_a 0xFE202F)',
         '; checks the tag (DiskLoad_CheckSoundRamTag) and streams 0x40000 bytes to 0xE80000; prom_c\'s',
         '; SoundRam_ClearFourBanks (0xFC386C) writes the layout typed here: per bank the tag, 64 tone records',
         '; from +0x90 (stride 0x2C9), the kit record at +0xB2D0 (0x198 bytes; its key map at +0x98, 128 x 2),',
         '; then 128 DRUM SOUND NOTE DATA blocks of 150 and a zero tail: the Reference Guide\'s DRUM SOUND',
         '; (wsa1_sound.inc).  Records: include/tm/.', '', '\t.include\t"wsa1_sound.inc"', ctx.label + ':']
    for b in range(4):
        o = b * 0x10000
        L += ['', '%s_Bank%d:' % (ctx.label, b),
              '\t.ascii\t"WSA SOUND RAM S%d"\t; SoundRam_BankName_S%d, copied here by SoundRam_ClearFourBanks' % (b, b),
              '; eight 16-character lines, which SoundRam_ClearFourBanks does not write (no reader found)']
        for k in range(8):
            L.append('\t.ascii\t%s' % s_esc(d[o + 16 + 16 * k:o + 32 + 16 * k]))
        for k in range(64):
            r = d[o + 0x90 + 0x2C9 * k:o + 0x90 + 0x2C9 * (k + 1)]
            L.append('\t.include\t"%s"\t; tone %d: %s' % (tone_item(r), k + 1, r[:16].decode('latin-1').strip()))
        kit = d[o + 0xB2D0:o + 0xB468]
        L += ['%s_Bank%d_Kit:' % (ctx.label, b), '\t.ascii\t%s\t; NAME' % s_esc(kit[:16]),
              '\tkit_general\t' + vals(kit[16:0x98])]
        L.append('; SOUND SELECT, NOTE:00 to NOTE:7F: two bytes per key (the clear writes 0, 64 to each)')
        for k in range(0, 128, 8):
            L.append('\t.byte\t' + ', '.join('%d, %d' % (kit[0x98 + 2 * j], kit[0x99 + 2 * j]) for j in range(k, k + 8))
                     + '\t; keys %d-%d' % (k, k + 7))
        for k in range(128):
            r = d[o + 0xB468 + 150 * k:o + 0xB468 + 150 * (k + 1)]
            L.append('\t.include\t"%s"\t; drum instrument %d: %s' % (perc_item(r), k, r[:13].decode('latin-1').strip()))
        t = d[o + 0xFF68:o + 0x10000]
        if len(set(t)) != 1:
            return None
        L.append('\t.fill\t%d, 1, 0x%02x\t; bank tail +0xFF68..+0xFFFF' % (len(t), t[0]))
    return L


def describe_cmb(ctx):
    d = ctx.data
    if len(d) != 0x16400 or d[:4] != b'ZZZZ' or d[6:10] != b'WSA1' or any(d[0x20:0x200]):
        return None
    hdr = d[:0x20]
    L = ['; COMBINATION: the user combination bank (wsa1/include/wsa1_files.inc, cmb_*).  The header\'s 32 bytes are',
         '; the factory bank\'s PresetBank_Header (prom_c/data_tables/preset_bank.s), DiskLoad_CheckCombiTag (prom_a',
         '; 0xFE2E3D) checks "WSA1" at +6.', '', '\t.include\t"wsa1_files.inc"', ctx.label + ':',
         '\t.ascii\t"ZZZZ"', '\t.short\t0', '\t.ascii\t"WSA1  "',
         '\t.short\t' + ', '.join('0x%04x' % (hdr[k] | hdr[k + 1] << 8) for k in range(12, 32, 2)) + '\t; the directory (PresetBank_Header)',
         '\t.fill\t0x1e0, 1, 0', '%s_BankNames:' % ctx.label]
    L += ['\t.ascii\t%s\t; bank %d' % (s_esc(d[0x200 + 16 * k:0x210 + 16 * k]), k) for k in range(16)]
    for k in range(128):
        o = 0x300 + 0x2C0 * k
        r = d[o:o + 0x2C0]
        L.append('%s_C%03d:\t\t; bank %d memory %d' % (ctx.label, k, k // 8, k % 8))
        q = 0
        n = 0
        while True:
            t, ln = r[q], r[q + 1]
            if t == 0xFF:
                if r[q:q + 2] != b'\xff\xff' or q + 2 != 0x2C0:
                    return None
                L.append('\t.byte\t0xff, 0xff')
                break
            pay = r[q + 2:q + 2 + ln]
            v = ', '.join(str(x) for x in pay)
            if t == 0x78 and ln == 16:
                L += ['\tcmb_name', '\t.ascii\t%s' % s_esc(pay)]
            elif t == 0x60 and ln == 12:
                L.append('\tcmb_effect_common\t' + v)
            elif t in (0x61, 0x62, 0x63) and ln == 30:
                L.append('\tcmb_effect\t0x%02x, %s' % (t, v))
            elif t <= 0x07 and ln == 30:
                L.append('\tcmb_part_a\t%d, %s' % (t, v))
            elif 0x20 <= t <= 0x27 and ln == 30:
                L.append('\tcmb_part_b\t0x%02x, %s' % (t, v))
            elif t == 0x92 and ln == 14:
                L.append('\tcmb_key_scaling\t' + v)
            elif t == 0x79 and ln == 44:
                L.append('\tcmb_common\t' + v)
            else:
                return None
            q += 2 + ln
            n += 1
        if n != 23:
            return None
    L += ['; The rest of the file\'s last kilobyte.  [INFERENCE] the disk code moves the file in whole kilobytes',
          '; (Disk_SetWindowLengthToKilobyte), and DiskLoad_Combination takes 0x16300 bytes of the 89 KB.  These 0x100',
          '; bytes are what the staging buffer still held.',
          '; census: opaque -- unknown-dump: stale staging-buffer bytes past the 0x16300-byte bank',
          '\t.incbin\t"%s", 0x%x, %d' % (ctx.ref, ctx.offset + 0x16300, 0x100)]
    return L


def describe_sqf(ctx):
    d = ctx.data
    if len(d) != 0x7800 or any(d[k * 0xC00:k * 0xC00 + 4] != b'ZZZZ' for k in range(10)):
        return None
    w = lambda r, o: r[o] | r[o + 1] << 8  # noqa: E731
    L = ['; SEQUENCER workspace, all ten banks (wsa1/include/wsa1_files.inc, sqf_*).  Named fields are the disk',
         '; notes\' (FINDINGS-prom_b-disk-and-file-menus.md); the other bytes are spelled with their offsets.', '',
         '\t.include\t"wsa1_files.inc"', ctx.label + ':']
    for k in range(10):
        r = d[k * 0xC00:(k + 1) * 0xC00]
        L += ['%s_Bank%d:' % (ctx.label, k), '\tsqf_head\t%d, %d' % (r[4], w(r, 5)), '; +0x07..+0x1B'] + rows(r[7:0x1C])
        L += ['\t.short\t0x%04x\t; +0x1C BStore_Password (two characters; 0 = none)' % w(r, 0x1C), '; +0x1E..+0x7D'] + rows(r[0x1E:0x7E])
        L.append('\t.short\t' + ', '.join(str(w(r, 0x7E + 2 * j)) for j in range(17)) + '\t; +0x7E the running block totals (SeqFile_Save)')
        L += ['; +0xA0..+0xB7'] + rows(r[0xA0:0xB8])
        L.append('\t.short\t%d, %d\t; +0xB8 the free chain head and count (0x6034B8 / 0x6034BA)' % (w(r, 0xB8), w(r, 0xBA)))
        L += ['; +0xBC..+0xC9'] + rows(r[0xBC:0xCA]) + ['\t.ascii\t%s\t; +0xCA the song name' % s_esc(r[0xCA:0xD0]), '; +0xD0..+0xFF'] + rows(r[0xD0:0x100])
        for j in range(17):
            L.append('\tsqf_dir\t0x%02x, 0x%04x' % (r[0x100 + 3 * j], w(r, 0x101 + 3 * j)))
        L += ['; +0x133..+0xBFF, not traced'] + rows(r[0x133:])
    return L


def tlv_blocks(d, o):
    """Consecutive {tag, len} record lists, each ended by FF FF: [(start, records)], offset after the last."""
    out = []
    while o + 2 <= len(d):
        q, recs = o, []
        while q + 2 <= len(d) and not (d[q] == 0xFF and d[q + 1] == 0xFF):
            t, n = d[q], d[q + 1]
            if q + 2 + n > len(d):
                return out, o
            recs.append((q, t, n))
            q += 2 + n
        if q + 2 > len(d) or not recs:
            return out, o
        out.append((o, recs))
        o = q + 2
    return out, o


CMB_TAGS = None


def cmb_line(t, n, pay):
    v = ', '.join(str(x) for x in pay)
    if t == 0x78 and n == 16:
        return ['\tcmb_name', '\t.ascii\t%s' % s_esc(pay)]
    if t == 0x60 and n == 12:
        return ['\tcmb_effect_common\t' + v]
    if t in (0x61, 0x62, 0x63) and n == 30:
        return ['\tcmb_effect\t0x%02x, %s' % (t, v)]
    if t <= 0x07 and n == 30:
        return ['\tcmb_part_a\t%d, %s' % (t, v)]
    if 0x20 <= t <= 0x27 and n == 30:
        return ['\tcmb_part_b\t0x%02x, %s' % (t, v)]
    if t == 0x92 and n == 14:
        return ['\tcmb_key_scaling\t' + v]
    if t == 0x79 and n == 44:
        return ['\tcmb_common\t' + v]
    return None


def describe_panel(ctx):
    """PANEL: .LSW (a 0x20-byte header "ZZ" 01 00 "WA0", then record blocks) and .SLS (0x600 bytes of RAM 0x7000,
    DiskLoad_PanelSlsFile; record blocks from +0).  The first block is a combination record (cmb_*), the
    others are {tag, length} lists typed by record; the bytes after the last block are spelled with offsets."""
    d = ctx.data
    ext = ctx.path.rsplit('.', 1)[-1].upper()
    if not d:
        return None
    st = 0x20 if ext == 'LSW' else 0
    if ext == 'LSW' and d[:4] != b'ZZ\x01\x00':
        return None
    blocks, end = tlv_blocks(d, st)
    if not blocks:
        return None
    L = ['; %s: the panel, as record blocks (wsa1/include/wsa1_files.inc).  The first block is the current' % ext,
         '; combination (the 23 records of a .CMB combination); the other blocks\' tags are not traced.', '',
         '\t.include\t"wsa1_files.inc"', ctx.label + ':']
    if st:
        L += ['\t.ascii\t"ZZ"', '\t.byte\t1, 0', '\t.ascii\t"WA0"'] + rows(d[7:0x20])
    for k, (o, recs) in enumerate(blocks):
        L.append('; block %d: %d records' % (k + 1, len(recs)))
        for q, t, n in recs:
            pay = d[q + 2:q + 2 + n]
            c = cmb_line(t, n, pay) if k == 0 else None
            if c:
                L += c
            else:
                L.append('\twsa_tlv\t0x%02x, %d' % (t, n))
                L += rows(pay)
        L.append('\twsa_tlv_end')
    if end < len(d):
        L += ['; +0x%X..+0x%X: after the last record block, not traced' % (end, len(d) - 1)] + rows(d[end:])
    return L


def describe_remap(ctx):
    """RE-MAP files: a header and three maps of 0x210 (.SRM .CRM: name, 16 group names, 128 {number, source})
    or 0x90 (.DRM: name, 128 one-byte entries); the map size is the header's own offset step.  One .DRM on
    mcompos holds a COMBI RE-MAP image cut at 1024 bytes: its second map is typed as far as it goes."""
    d = ctx.data
    ext = ctx.path.rsplit('.', 1)[-1].upper()
    if d[:5] != b'WSA1 ' or any(d[5:0x0F]):
        return None
    m = [int.from_bytes(d[0x10 + 4 * k:0x14 + 4 * k], 'little') for k in range(4)]
    size = m[1] - m[0]
    if m[3] or m[0] != 0x20 or m[2] - m[1] != size or size not in (0x90, 0x210):
        return None
    L = ['; %s: three re-maps (wsa1/notes/sysex-probes/sysex_remap_files.py)%s.' % (
         ext, '' if (size == 0x90) == (ext == 'DRM') else '; this file holds the other kind\'s layout'), '',
         '\t.include\t"wsa1_files.inc"', ctx.label + ':', '\tremap_head\t0x%02x, 0x%x, 0x%x, 0x%x' % ((d[0x0F],) + tuple(m[:3]))]
    pos = 0x20
    for k in range(3):
        o = 0x20 + size * k
        if o + 16 > len(d):
            break
        L += ['%s_Map%d:' % (ctx.label, k + 1), '\t.ascii\t%s\t; map name' % s_esc(d[o:o + 16])]
        pos = o + 16
        if size == 0x90:
            n = min(128, len(d) - pos)
            L += ['; %d entries of one byte' % n] + rows(d[pos:pos + n])
            pos += n
        else:
            for g in range(16):
                if pos + 16 > len(d):
                    break
                L.append('\t.ascii\t%s\t; group %d' % (s_esc(d[pos:pos + 16]), g + 1))
                pos += 16
            n = min(128, (len(d) - pos) // 2) if pos == o + 0x110 else 0
            for j in range(0, n, 8):
                L.append('\t.byte\t' + ', '.join('%d, %d' % (d[pos + 2 * x], d[pos + 2 * x + 1]) for x in range(j, min(j + 8, n)))
                         + '\t; entries %d-%d {number, source}' % (j, min(j + 8, n) - 1))
            pos += 2 * n
    rest = d[pos:]
    if rest:
        if len(set(rest)) == 1:
            L.append('\t.fill\t%d, 1, 0x%02x\t; to the end of the file' % (len(rest), rest[0]))
        else:
            L += ['; +0x%X..: after the maps, not traced' % pos] + rows(rest)
    return L


def describe(ctx):
    ext = ctx.path.rsplit('.', 1)[-1].upper()
    if ext == 'MID':
        return describe_mid(ctx)
    if ext == 'SEQ':
        return describe_seq(ctx)
    if ext == 'TM':
        return describe_tm(ctx)
    if ext == 'CMB':
        return describe_cmb(ctx)
    if ext == 'SQF':
        return describe_sqf(ctx)
    if ext in ('LSW', 'SLS'):
        return describe_panel(ctx)
    if ext in ('SRM', 'CRM', 'DRM'):
        return describe_remap(ctx)
    return None
