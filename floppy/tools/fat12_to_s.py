#!/usr/bin/env python3
"""fat12_to_s.py -- turn a FAT12 diskette image into an llvm-mc source tree that rebuilds it.

QUESTION IT ANSWERS
  "Can a diskette be held as source -- its boot sector, FAT, directories and files each typed by
   what they are -- and still rebuild byte for byte?"  Set up 2026-10-29 for the data-semantics
   effort (notes/data-semantics-2026-10-29/README.md); the interface is floppy/README.md.

USAGE
  python3 floppy/tools/fat12_to_s.py IMAGE OUTDIR --ref NAME.img [--title TEXT]
                                     [--formats floppy/<model>/formats.py]

  IMAGE    the reference image (git-ignored copy under floppy/<model>/baserom/)
  OUTDIR   floppy/<model>/<disk>/; everything in it is (re)written, and files/*.s units this run
           did not write are removed
  --ref    the file name the sources `.incbin` (found through the Makefile's -I list)
  --formats  a Python module with  describe(ctx) -> str | None  (see floppy/README.md); a None
           (or no module) leaves the file as one generic `.incbin` of the reference

OUTPUT (all llvm-mc, assembled by floppy/Makefile)
  disk.s          the image in disk order: boot.s, the FAT copies, root.s, then the data area,
                  cluster by cluster, each unit asserted at its cluster (fat12_at_cluster)
  boot.s          the boot sector: BPB fields one per labelled line, boot code, signature
  fat.s           one FAT copy spelled as cluster chains (fat12_run per contiguous run, named
                  after the file it belongs to); included once per copy when the copies agree,
                  else fat1.s, fat2.s, ...
  root.s          the root directory, one fat_dirent per used slot, zero slots as fill
  dir_<path>.s    each subdirectory's entry table, placed at its clusters
  files/<unit>.s  one unit per file (fat12lib.unit_name): the describer's typed source, or the
                  generic incbin.  Fragmented files are placed per fragment in disk.s and are not
                  offered to describers (none of the 2026-10-18 softlist images has one).

  Slack past a file's end, free clusters and reserved sectors are `.fill` when uniform, else an
  `.incbin` declared `census: opaque -- unknown-dump: ...` naming what the bytes are.
"""
import argparse
import importlib.util
import os
import pathlib
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import fat12lib  # noqa: E402


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


def label_of(unit):
    return 'F_' + ''.join(c if c.isalnum() or c == '_' else '_' for c in unit)


def hexb(bs):
    return ', '.join('0x%02x' % b for b in bs)


def fill_or_opaque(ref, off, buf, what, why):
    """Spell a run of bytes: `.fill` if uniform, else an opaque incbin of the reference."""
    if not buf:
        return []
    if len(set(buf)) == 1:
        return ['\t.fill\t%d, 1, 0x%02x\t\t; %s' % (len(buf), buf[0], what)]
    return ['\t; census: opaque -- unknown-dump: %s' % why,
            '\t.incbin\t"%s", 0x%x, %d\t\t; %s' % (ref, off, len(buf), what)]


class Ctx:
    """What a format describer is given about one file."""

    def __init__(self, **kw):
        self.__dict__.update(kw)


def dirent_lines(e):
    raw = e.raw
    if raw == bytes(32):
        return None
    if e.is_lfn:
        u = [int.from_bytes(raw[o:o + 2], 'little') for o in
             (1, 3, 5, 7, 9, 14, 16, 18, 20, 22, 24, 28, 30)]
        tail = raw[26:28]
        if tail != b'\0\0' or raw[12] != 0:
            return ['\t.byte\t%s\t; LFN entry with non-zero type/cluster' % hexb(raw)]
        return ['\tfat_lfn\t0x%02x, 0x%02x, %s' % (raw[0], raw[13], ', '.join('0x%04x' % x for x in u))]
    t, d = e.time, e.date
    attr = []
    for bit, nm in ((0x01, 'READONLY'), (0x02, 'HIDDEN'), (0x04, 'SYSTEM'), (0x08, 'VOLUME'),
                    (0x10, 'DIRECTORY'), (0x20, 'ARCHIVE')):
        if e.attr & bit:
            attr.append('FAT_ATTR_' + nm)
    rest = e.attr & 0xC0
    if rest:
        attr.append('0x%02x' % rest)
    extra = []
    for k in ('ntres', 'ctenth', 'ctime', 'cdate', 'adate', 'clhi'):
        v = getattr(e, k)
        if v:
            extra.append('%s=0x%x' % (k, v))
    args = [s_escape(e.name), s_escape(e.ext), ' | '.join(attr) or '0',
            str(t >> 11), str((t >> 5) & 63), str((t & 31) * 2),
            str(1980 + (d >> 9)), str((d >> 5) & 15), str(d & 31),
            str(e.cluster), str(e.size)] + extra
    what = e.display() if not e.deleted else 'deleted entry'
    return ['\tfat_dirent\t%s\t; %s' % (', '.join(args), what)]


def dir_table(entries):
    out, zeros = [], 0
    for e in entries:
        ln = dirent_lines(e)
        if ln is None:
            zeros += 1
            continue
        if zeros:
            out.append('\t.fill\t%d * 32, 1, 0\t\t; %d unused slots' % (zeros, zeros))
            zeros = 0
        out += ln
    if zeros:
        out.append('\t.fill\t%d * 32, 1, 0\t\t; %d unused slots' % (zeros, zeros))
    return out


def boot_lines(img, ref):
    b = img.bpb
    bs = img.data[:b.bytes_per_sector]
    L = ['; Boot sector (sector 0).  Field names: fatgen103 section 3.', '',
         'Boot_Jump:\t\t.byte\t%s' % hexb(bs[0:3]),
         'Boot_OemName:\t\t.ascii\t%s' % s_escape(bs[3:11]),
         'BPB_BytesPerSector:\t.short\tFAT12_BYTES_PER_SECTOR',
         'BPB_SectorsPerCluster:\t.byte\tFAT12_SECTORS_PER_CLUSTER',
         'BPB_ReservedSectors:\t.short\tFAT12_RESERVED_SECTORS',
         'BPB_NumberOfFats:\t.byte\tFAT12_FATS',
         'BPB_RootEntries:\t.short\tFAT12_ROOT_ENTRIES',
         'BPB_TotalSectors16:\t.short\t%d' % b.total_sectors16,
         'BPB_MediaDescriptor:\t.byte\t0x%02x' % b.media,
         'BPB_SectorsPerFat:\t.short\tFAT12_SECTORS_PER_FAT',
         'BPB_SectorsPerTrack:\t.short\t%d' % b.sectors_per_track,
         'BPB_Heads:\t\t.short\t%d' % b.heads]
    if b.extended:
        L += ['BPB_HiddenSectors:\t.long\t%d' % b.hidden,
              'BPB_TotalSectors32:\t.long\t%d' % b.total_sectors32,
              'BS_DriveNumber:\t\t.byte\t0x%02x' % bs[0x24],
              'BS_Reserved1:\t\t.byte\t0x%02x' % bs[0x25],
              'BS_BootSignature:\t.byte\t0x%02x' % bs[0x26],
              'BS_VolumeSerial:\t.long\t0x%08x' % int.from_bytes(bs[0x27:0x2B], 'little'),
              'BS_VolumeLabel:\t\t.ascii\t%s' % s_escape(bs[0x2B:0x36]),
              'BS_FileSystemType:\t.ascii\t%s' % s_escape(bs[0x36:0x3E])]
        code0 = 0x3E
    else:
        L += ['BPB_HiddenSectors:\t.short\t%d\t\t; DOS 3.x BPB: 16-bit count, no extended fields'
              % b.hidden]
        code0 = 0x1E
    code = bs[code0:0x1FE]
    nz = [i for i, c in enumerate(code) if c]
    L.append('Boot_Code:')
    if not nz:
        L.append('\t.fill\t%d, 1, 0' % len(code))
    elif nz[-1] < 32:
        n = nz[-1] + 1
        note = ''
        if code[:2] == b'\xeb\xfe' and n == 2:
            note = '\t\t; x86 `jmp $`: spins forever, the diskette does not boot a PC'
        L.append('\t.byte\t%s%s' % (hexb(code[:n]), note))
        L.append('\t.fill\t%d, 1, 0' % (len(code) - n))
    else:
        L += ['\t; census: opaque -- code: x86 boot code written by the formatting PC, not part of'
              ' any instrument firmware',
              '\t.incbin\t"%s", 0x%x, %d' % (ref, code0, len(code))]
    sig = int.from_bytes(bs[0x1FE:0x200], 'little')
    note = '' if sig == 0xAA55 else '\t\t; not 0xaa55: no PC boot signature'
    L.append('Boot_Signature:\t\t.short\t0x%04x%s' % (sig, note))
    if b.bytes_per_sector > 512:
        L += fill_or_opaque(ref, 512, bs[512:], 'rest of the boot sector', 'boot sector tail')
    return L


def fat_lines(img, copy, names):
    b = img.bpb
    fat = fat12lib.fat12_entries(copy)
    N = len(fat)
    last_cluster = 1 + b.clusters
    L = ['; One FAT copy (%d bytes, %d twelve-bit slots).  Slots 0 and 1 hold the media byte and'
         % (len(copy), N), '; the end-of-chain filler; slot c >= 2 describes data cluster c.', '',
         '\tfat12_begin',
         '\tfat12_entry\t0x%03x\t\t; slot 0: 0xf00 | media descriptor 0x%02x' % (fat[0], b.media),
         '\tfat12_entry\t0x%03x\t\t; slot 1' % fat[1]]
    i = 2
    while i < N:
        v = fat[i]
        if v == 0:
            j = i
            while j < N and fat[j] == 0:
                j += 1
            if i > last_cluster:
                what = 'slots past the last cluster (%d)' % last_cluster
            elif j - 1 > last_cluster:
                what = 'free clusters %d..%d, then slots past the last cluster' % (i, last_cluster)
            else:
                what = 'free clusters %d..%d' % (i, j - 1)
            L.append('\tfat12_free\t%d\t\t; %s' % (j - i, what))
            i = j
            continue
        j = i
        while j + 1 < N and fat[j] == j + 1:
            j += 1
        last = fat[j]
        owner = names.get(i, 'not in any chain')
        if last >= 0xFF8:
            tail = 'end of chain' if last == 0xFFF else 'end of chain (0x%03x)' % last
            lastx = '0x%03x' % last
        elif last == 0xFF7:
            tail, lastx = 'bad cluster', '0xff7'
        else:
            tail, lastx = 'continues at %d' % last, str(last)
        L.append('\tfat12_run\t%d, %d, %s\t; %s: clusters %d..%d, %s'
                 % (i, j - i + 1, lastx, owner, i, j, tail))
        i = j + 1
    covered = N // 2 * 3
    L.append('\tfat12_end\t%d' % covered)
    if covered < len(copy):
        L.append('\t.byte\t%s\t\t; FAT bytes past the last whole slot pair' % hexb(copy[covered:]))
    return L


def default_unit(ctx):
    return ['; No describer for this kind yet: the bytes are the reference image\'s.',
            '%s:\t.incbin\t"%s", 0x%x, %d' % (ctx.label, ctx.ref, ctx.offset, ctx.entry.size)]


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[1])
    ap.add_argument('image')
    ap.add_argument('outdir')
    ap.add_argument('--ref', required=True)
    ap.add_argument('--title', default='')
    ap.add_argument('--formats')
    a = ap.parse_args()

    data = pathlib.Path(a.image).read_bytes()
    img = fat12lib.Image(data)
    b = img.bpb
    out = pathlib.Path(a.outdir)
    (out / 'files').mkdir(parents=True, exist_ok=True)
    describe = None
    boot_note = []
    if a.formats:
        spec = importlib.util.spec_from_file_location('formats', a.formats)
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        describe = mod.describe
        boot_note = list(getattr(mod, 'BOOT_NOTE', []))
    disk = out.name
    gen = 'floppy/tools/fat12_to_s.py'
    head = ['; Generated by %s from %s; regenerate rather than edit (floppy/README.md).'
            % (gen, a.ref)]

    if len(data) != b.image_bytes:
        sys.exit('image is %d bytes, the BPB says %d' % (len(data), b.image_bytes))

    names = {}
    for e in img.files():
        for c in e.chain:
            names.setdefault(c, e.path() + ('/' if e.is_dir else ''))

    w = {}
    w['boot.s'] = head + [''] + [('; ' + x).rstrip() for x in boot_note] + \
        ([''] if boot_note else []) + boot_lines(img, a.ref)
    copies = img.fat_copies
    same = all(c == copies[0] for c in copies)
    if same:
        w['fat.s'] = head + [''] + fat_lines(img, copies[0], names)
    else:
        for k, c in enumerate(copies):
            w['fat%d.s' % (k + 1)] = head + [''] + fat_lines(img, c, names)
    w['root.s'] = head + ['', '; Root directory: %d slots of 32 bytes.' % b.root_entries, ''] + \
        dir_table(img.root)

    # The data area, in cluster order.
    L = []
    c = 2
    end = 2 + b.clusters
    written_units = set()
    while c < end:
        own = img.owner.get(c)
        if own is None:
            j = c
            while j < end and img.owner.get(j) is None and (img.fat[j] == 0) == (img.fat[c] == 0):
                j += 1
            o = img.cluster_offset(c)
            buf = data[o:img.cluster_offset(j)]
            free = img.fat[c] == 0
            what = ('free clusters %d..%d' % (c, j - 1)) if free else \
                ('clusters %d..%d: allocated, in no chain' % (c, j - 1))
            L.append('\tfat12_at_cluster\t%d' % c)
            if len(set(buf)) == 1:
                L.append('\t.fill\t%d * FAT12_CLUSTER_BYTES, 1, 0x%02x\t; %s' % (j - c, buf[0], what))
            else:
                for k in range(c, j):
                    cb = img.cluster_bytes(k)
                    L += fill_or_opaque(a.ref, img.cluster_offset(k), cb, 'cluster %d (%s)' % (
                        k, 'free' if free else 'lost'),
                        'a %s cluster holding bytes no directory entry reaches (leftover data)'
                        % ('free' if free else 'lost'))
            c = j
            continue
        e, k = own
        # the run of this chain that starts here
        j = c
        while j + 1 < end and img.owner.get(j + 1) == (e, k + (j + 1 - c)):
            j += 1
        run = j - c + 1
        L.append('\tfat12_at_cluster\t%d' % c)
        fragmented = run != len(e.chain)
        if e.is_dir:
            u = 'dir_' + e.unit_path().replace('/', '__') + '.s'
            buf = b''.join(img.cluster_bytes(x) for x in e.chain[k:k + run])
            ents = e.children[k * b.cluster_bytes // 32:(k + run) * b.cluster_bytes // 32]
            w[u] = head + ['', '; Directory %s/, clusters %d..%d.' % (e.path(), c, j), ''] + dir_table(ents)
            L.append('\t.include\t"%s"\t\t; directory %s/' % (u, e.path()))
        elif fragmented:
            start = k * b.cluster_bytes
            n = max(0, min(e.size - start, run * b.cluster_bytes))
            L.append('\t; %s, fragment at chain index %d (fragmented: not offered to describers)'
                     % (e.path(), k))
            L.append('\t.incbin\t"%s", 0x%x, %d' % (a.ref, img.cluster_offset(c), n))
            if n < run * b.cluster_bytes:
                o = img.cluster_offset(c) + n
                L += fill_or_opaque(a.ref, o, data[o:img.cluster_offset(j + 1)],
                                    'slack: rest of the last cluster',
                                    'slack past the end of %s (leftover bytes)' % e.path())
        else:
            unit = e.unit_path().replace('/', '__')
            fname = 'files/%s.s' % unit
            fdata = img.file_bytes(e)
            ctx = Ctx(disk=disk, ref=a.ref, entry=e, data=fdata, offset=img.cluster_offset(c),
                      label=label_of(unit), unit=unit, path=e.path(),
                      extracted=pathlib.Path(e.unit_path()).with_suffix(
                          pathlib.Path(e.unit_path()).suffix.lower()).as_posix())
            body = describe(ctx) if describe else None
            if body is None:
                body = default_unit(ctx)
            elif isinstance(body, str):
                body = body.rstrip('\n').split('\n')
            w[fname] = head + ['', '; %s -- %d bytes, clusters %d..%d.' % (e.path(), e.size, c, j), ''] + body
            written_units.add(fname)
            L.append('\t.include\t"%s"\t\t; %s, %d B' % (fname, e.path(), e.size))
            L.append('\tat\t0x%x + %d\t\t; the unit is exactly the file' % (img.cluster_offset(c), e.size))
            o = img.cluster_offset(c) + e.size
            L += fill_or_opaque(a.ref, o, data[o:img.cluster_offset(j + 1)],
                                'slack: rest of the last cluster',
                                'slack past the end of %s (leftover bytes)' % e.path())
        c = j + 1

    top = head + [
        '; %s' % (a.title or disk), ';',
        '; Assembled by floppy/Makefile:  llvm-mc -filetype=obj, llvm-objcopy -O binary.',
        '', '\t.include\t"fat12.inc"', '',
        '\t.set\tFAT12_BYTES_PER_SECTOR, %d' % b.bytes_per_sector,
        '\t.set\tFAT12_SECTORS_PER_CLUSTER, %d' % b.sectors_per_cluster,
        '\t.set\tFAT12_RESERVED_SECTORS, %d' % b.reserved_sectors,
        '\t.set\tFAT12_FATS, %d' % b.fats,
        '\t.set\tFAT12_ROOT_ENTRIES, %d' % b.root_entries,
        '\t.set\tFAT12_SECTORS_PER_FAT, %d' % b.sectors_per_fat,
        '\t.set\tFAT12_CLUSTER_BYTES, FAT12_SECTORS_PER_CLUSTER * FAT12_BYTES_PER_SECTOR',
        '\t.set\tFAT12_FAT_OFFSET, FAT12_RESERVED_SECTORS * FAT12_BYTES_PER_SECTOR',
        '\t.set\tFAT12_ROOT_OFFSET, FAT12_FAT_OFFSET + FAT12_FATS * FAT12_SECTORS_PER_FAT * FAT12_BYTES_PER_SECTOR',
        '\t.set\tFAT12_DATA_OFFSET, FAT12_ROOT_OFFSET + 0x%x\t; root directory, rounded up to whole sectors'
        % b.root_bytes,
        '', 'disk_base:', '\t.include\t"boot.s"']
    rs = data[512:b.fat_offset]
    if rs:
        top += fill_or_opaque(a.ref, 512, rs, 'reserved sectors after the boot sector',
                              'reserved sectors after the boot sector')
    for k in range(b.fats):
        top += ['\tat\tFAT12_FAT_OFFSET + %d * FAT12_SECTORS_PER_FAT * FAT12_BYTES_PER_SECTOR' % k,
                '\t.include\t"%s"\t\t; FAT copy %d' % ('fat.s' if same else 'fat%d.s' % (k + 1), k + 1)]
    top += ['\tat\tFAT12_ROOT_OFFSET', '\t.include\t"root.s"']
    rt = data[b.root_offset + b.root_entries * 32:b.data_offset]
    if rt:
        top += fill_or_opaque(a.ref, b.root_offset + b.root_entries * 32, rt,
                              'root directory sector tail', 'root directory sector tail')
    top += ['', '; ---- data area: cluster 2 at FAT12_DATA_OFFSET ----', ''] + L
    top += ['\tat\t%d\t\t; %d sectors of %d bytes' % (b.image_bytes, b.total_sectors, b.bytes_per_sector)]
    w['disk.s'] = top

    for f in (out / 'files').glob('*.s'):
        rel = 'files/' + f.name
        if rel not in written_units:
            assert f.resolve().parent == (out / 'files').resolve()
            f.unlink()
    for name, lines in w.items():
        p = out / name
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_bytes(('\n'.join(lines) + '\n').encode('latin-1'))


if __name__ == '__main__':
    main()
