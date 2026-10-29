"""kn_formats.py -- the SX-KN6000 / SX-KN7000 file-format describers, shared by floppy/kn6000/formats.py and
floppy/kn7000/formats.py (the two firmwares write the same kinds; the magic's first byte says which).

describe(ctx, model) dispatches on the extension:
  compressed containers (kd.py)     describe_kd: typed header, generated streams, payload sources
  .AST (custom-data flash image)    the image comes from the custom-data source tree: describe_image
  .CNV (Style Convert converters)   the build output of kn7000/src/cnv/ (generated)
  .JPG                              the extracted file itself (media)
  .TXT .ACT .PRE                    text, one .ascii per line
  .VER                              a Cakewalk .WRK file, chunk by chunk
Payload describers (the inflated contents, per kind) are in kn_payloads.py.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import kd_describe  # noqa: E402
import kn_payloads  # noqa: E402

# .AST -> the make variable naming the custom-data image it holds (floppy/tools/kd/kd.mk sets the defaults).
AST_IMAGE = {
    ('kn6000', 'idd6000', '01CTMINI.AST'): 'KN6000_CUSTOMDATA_01ctmini',
    ('kn7000', 'idd7000', '01CTMINI.AST'): 'KN7000_CUSTOMDATA_01ctmini',
}
for _d, _n in (('custom1', (1, 2, 3, 4)), ('custom2', (5, 6, 7, 8))):
    for _k in _n:
        AST_IMAGE[('kn7000', _d, '%02dCUSTM%d.AST' % ((_k - 1) % 4 + 1, _k))] = 'KN7000_CUSTOMDATA_%02dcustm%d' % ((_k - 1) % 4 + 1, _k)

# .CNV -> kn7000/src/cnv/<name>.s (make -C kn7000 build-cnv).  The KN6000 disk's TECHNICS.CNV is its own build.
CNV_SOURCE = {'GEM_WS2': 'gem_ws2', 'GEM_WX2': 'gem_wx2', 'KORG': 'korg', 'ROLAND': 'roland',
              'SOLTON': 'solton', 'TECHNICS': 'technics'}


def s_escape(b):
    out = []
    for c in b:
        if c in (0x22, 0x5C):
            out.append('\\' + chr(c))
        elif 0x20 <= c < 0x7F:
            out.append(chr(c))
        elif c == 0x0d:
            out.append('\\r')
        elif c == 0x0a:
            out.append('\\n')
        elif c == 0x09:
            out.append('\\t')
        else:
            out.append('\\%03o' % c)
    return '"' + ''.join(out) + '"'


def text_unit(ctx, what):
    L = ['; %s' % what, '', ctx.label + ':']
    d = ctx.data
    i = 0
    while i < len(d):
        j = d.find(b'\n', i)
        j = len(d) if j < 0 else j + 1
        L.append('\t.ascii\t' + s_escape(d[i:j]))
        i = j
    return L


# Cakewalk .WRK chunk ids (the format as Cakewalk Pro documents it and drumstick's QWrk reads it).
WRK_CHUNK = {1: 'TRACK', 2: 'STREAM', 3: 'VARS', 4: 'TEMPO', 5: 'METER', 6: 'SYSEX', 7: 'MEMRGN',
             8: 'COMMENTS', 9: 'TRKOFFS', 10: 'TIMEBASE', 11: 'TIMEFMT', 12: 'TRKREPS', 14: 'TRKPATCH',
             15: 'NTEMPO', 16: 'THRU', 18: 'LYRICS', 19: 'TRKVOL', 20: 'SYSEX2', 21: 'MARKERS',
             22: 'STRTAB', 23: 'METERKEY', 24: 'TRKNAME', 26: 'VARIABLE', 27: 'NTRKOFS', 74: 'SOFTVER',
             255: 'END'}


def wrk_unit(ctx):
    d = ctx.data
    L = ['; A Cakewalk work file (.WRK) under another name: the Style Convert disk\'s version marker.',
         '; Header "CAKEWALK", 0x1a, then the version (minor, major), then chunks: an id byte and, except',
         '; for END (0xff), a u32 length and that many bytes.  Chunk names: Cakewalk\'s own (WRK_CHUNK).',
         '; Nothing in the KN7000 program reads this file (no "CAKEWALK" or ".VER" string in it); inferred:',
         '; the converter disk\'s authoring tool left it as a marker.', '',
         ctx.label + ':', '\t.ascii\t"CAKEWALK"', '\t.byte\t0x1a, %d, %d\t\t; version %d.%d' % (d[9], d[10], d[10], d[9])]
    i = 11
    while i < len(d):
        cid = d[i]
        name = WRK_CHUNK.get(cid, 'unknown_%d' % cid)
        if cid == 0xff:
            L.append('\t.byte\t0xff\t\t; END')
            i += 1
            L += ['\t.byte\t' + ', '.join('0x%02x' % x for x in d[k:k + 16]) for k in range(i, len(d), 16)]
            break
        n = int.from_bytes(d[i + 1:i + 5], 'little')
        L.append('\t.byte\t%d\t\t; chunk %s' % (cid, name))
        L.append('\t.long\t%d' % n)
        body = d[i + 5:i + 5 + n]
        for k in range(0, len(body), 16):
            L.append('\t.byte\t' + ', '.join('0x%02x' % x for x in body[k:k + 16]))
        i += 5 + n
    return L


def hmp_unit(ctx, model):
    """A home-page file: HmpFileLoad (KN7000 program 941 0x4852CC3A) checks the 'JK ' signature, reads
    0x4442 bytes, and HmpInstall (0x484970C1) copies the first 0x18C (the record) to 0x5006B5F8 and
    programs the rest, a BMP of 0x42B6 bytes, to custom flash 0x9681118C."""
    d = ctx.data
    bmp = '%s.bmp' % ctx.extracted
    kd_describe._reg(model, ctx.disk)[1].append(
        '$(eval $(call KD_CUT,%s,%s,%s,bmp,0x18c,%d))' % (model, ctx.disk, ctx.extracted, len(d) - 0x18c))
    L = ['; A home-page file (.HMP): HmpFileLoad (KN7000 program 941 0x4852CC3A) checks the signature and',
         '; reads 0x4442 bytes; HmpInstall (0x484970C1) copies the first 0x18C bytes, the home-page record,',
         '; to 0x5006B5F8 (HpRecordProgram writes it to custom flash 0x96811000) and programs the BMP after',
         '; it to custom flash 0x9681118C.  The record\'s fields past the signature are not decoded: they are',
         '; spelled as the little-endian halfwords they look like.', '',
         ctx.label + ':',
         '\t.ascii\t%s\t\t; signature, checked by func_4852B746 (file type 9)' % s_escape(d[:4])]
    for k in range(4, 0x18c, 16):
        L.append('\t.short\t' + ', '.join('0x%04x' % int.from_bytes(d[j:j + 2], 'little') for j in range(k, min(k + 16, 0x18c), 2)))
    L += ['%s_Bmp:\t.incbin\t"%s"\t; the home-page picture, %dx%d' % (ctx.label, bmp,
          int.from_bytes(d[0x18c + 18:0x18c + 22], 'little'), int.from_bytes(d[0x18c + 22:0x18c + 26], 'little'))]
    return L


def describe(ctx, model):
    ext = ctx.path.rsplit('.', 1)[-1].upper()
    base = ctx.path.rsplit('/', 1)[-1].rsplit('.', 1)[0]
    key = (model, ctx.disk, ctx.path)
    if key in AST_IMAGE:
        var = AST_IMAGE[key]
        src = ('kn7000/src/customdata/%s.s' % var.split('_')[-1]) if model == 'kn7000' else 'kn6000/src/customdata/01ctmini.s'
        return kd_describe.describe_image(ctx, model, var, [
            'A custom-data flash image, saved by CUSTOM DATA SAVE (func_4852D0E5, kn7000/notes/custom-data-ic21.md',
            '".AST file"): the deflate of the whole %d-byte CUSTOM STYLE bank, built from %s'
            % (int.from_bytes(ctx.data[4:8], 'little'), src),
            '(make variable %s).' % var])
    if ext == 'CNV' and base in CNV_SOURCE:
        name = CNV_SOURCE[base] + ('_kn6000' if model == 'kn6000' and base == 'TECHNICS' else '')
        kd_describe._reg(model, ctx.disk)[1].append(
            '$(eval $(call KD_CNV,%s,%s,%s,%s))' % (model, ctx.disk, ctx.extracted, name))
        return ['; A Style Convert converter (MN10300 code), the build output of kn7000/src/cnv/%s.s' % name,
                '; (make -C kn7000 build-cnv; verify-cnv checks it against this disk).', '',
                '%s:\t.incbin\t"%s.gen"\t; census: generated -- kn7000/src/cnv/%s.s (kn7000/tools/kn7asm.py)'
                % (ctx.label, ctx.extracted, name)]
    if ext in ('JPG', 'JPEG'):
        return ['; A baseline JFIF picture (the slide-show / presentation image this disk\'s .ACT names).', '',
                '%s:\t.incbin\t"%s"' % (ctx.label, ctx.extracted)]
    if ext in ('TXT', 'ACT', 'PRE'):
        what = {'TXT': 'Text: the disk\'s table of contents, CR LF lines.',
                'ACT': 'The presentation script (<ACTION> section): which picture each ACT NO shows.',
                'PRE': 'The presentation file (<PRESENTATION>): the song to play and its title.'}[ext]
        return text_unit(ctx, what)
    if ext == 'HMP' and ctx.data[1:4] == b'K \0' and ctx.data[0x18c:0x18e] == b'BM':
        return hmp_unit(ctx, model)
    if ext == 'VER' and ctx.data.startswith(b'CAKEWALK'):
        return wrk_unit(ctx)
    return kd_describe.describe_kd(ctx, model, kn_payloads.TYPERS, kn_payloads.note(ctx, ext))
