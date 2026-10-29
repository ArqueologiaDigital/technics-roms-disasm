"""fat12lib.py -- read a FAT12 diskette image: BPB, both FATs, directory tree, cluster chains.

Shared by fat12_to_s.py (image -> source) and fat12_extract.py (image -> files).  Reads only; it
never repairs or normalises anything, so the generator can spell every non-standard byte.

Reference: Microsoft, "FAT: General Overview of On-Disk Format" (fatgen103, 2000).
"""
import re
import struct

SAFE = re.compile(r'[A-Za-z0-9_-]')


class Bpb:
    """The BIOS parameter block at offset 0x0B of the boot sector."""

    def __init__(self, bs):
        (self.bytes_per_sector, self.sectors_per_cluster, self.reserved_sectors, self.fats,
         self.root_entries, self.total_sectors16, self.media, self.sectors_per_fat,
         self.sectors_per_track, self.heads) = struct.unpack_from('<HBHBHHBHHH', bs, 0x0B)
        # DOS 3.x stops at a 16-bit hidden-sector count at 0x1C; DOS 4.0 extends the BPB with a
        # 32-bit hidden count, a 32-bit total, and (signature 0x29 at 0x26) serial, label, type.
        self.extended = bs[0x26] in (0x28, 0x29)
        if self.extended:
            self.hidden, self.total_sectors32 = struct.unpack_from('<II', bs, 0x1C)
        else:
            self.hidden = struct.unpack_from('<H', bs, 0x1C)[0]
            self.total_sectors32 = None
        self.total_sectors = self.total_sectors16 or (self.total_sectors32 or 0)
        b = self.bytes_per_sector
        self.fat_offset = self.reserved_sectors * b
        self.fat_bytes = self.sectors_per_fat * b
        self.root_offset = self.fat_offset + self.fats * self.fat_bytes
        root_bytes = self.root_entries * 32
        self.root_bytes = (root_bytes + b - 1) // b * b
        self.data_offset = self.root_offset + self.root_bytes
        self.cluster_bytes = self.sectors_per_cluster * b
        self.clusters = (self.total_sectors * b - self.data_offset) // self.cluster_bytes
        self.image_bytes = self.total_sectors * b


def fat12_entries(fat):
    """Every 12-bit slot the FAT copy holds (an even count; a trailing odd byte is not a slot)."""
    n = (len(fat) * 2 // 3) // 2 * 2
    out = []
    for k in range(n // 2):
        b0, b1, b2 = fat[3 * k], fat[3 * k + 1], fat[3 * k + 2]
        out.append(b0 | (b1 & 0x0F) << 8)
        out.append(b1 >> 4 | b2 << 4)
    return out


class Entry:
    def __init__(self, raw, slot, parent_path, parent_unit=''):
        self.raw = raw
        self.parent_unit = parent_unit
        self.slot = slot
        self.name = raw[0:8]
        self.ext = raw[8:11]
        self.attr = raw[11]
        self.ntres, self.ctenth = raw[12], raw[13]
        self.ctime, self.cdate, self.adate, self.clhi, self.time, self.date, self.cluster = \
            struct.unpack_from('<7H', raw, 14)
        self.size = struct.unpack_from('<I', raw, 28)[0]
        self.parent_path = parent_path
        self.chain = []
        self.children = None            # for directories: list of Entry

    @property
    def is_lfn(self):
        return self.attr & 0x3F == 0x0F

    @property
    def is_label(self):
        return not self.is_lfn and self.attr & 0x08

    @property
    def is_dir(self):
        return not self.is_lfn and self.attr & 0x10

    @property
    def is_dot(self):
        return self.name[:1] == b'.'

    @property
    def deleted(self):
        return self.raw[0] == 0xE5

    def display(self):
        n = self.name.decode('latin-1').rstrip()
        e = self.ext.decode('latin-1').rstrip()
        return n + ('.' + e if e else '')

    def path(self):
        return self.parent_path + self.display()

    def unit_path(self):
        return self.parent_unit + unit_name(self)


def unit_name(entry):
    """A file-system- and make-safe unit name: 8.3 name with every other character as xHH."""
    base = ''.join(c if SAFE.match(c) else 'x%02x' % ord(c)
                   for c in entry.name.decode('latin-1').rstrip())
    ext = ''.join(c if SAFE.match(c) else 'x%02x' % ord(c)
                  for c in entry.ext.decode('latin-1').rstrip())
    return base + ('.' + ext if ext else '')


class Image:
    def __init__(self, data):
        self.data = data
        self.bpb = bpb = Bpb(data[:512])
        self.fat_copies = [data[bpb.fat_offset + i * bpb.fat_bytes:
                                bpb.fat_offset + (i + 1) * bpb.fat_bytes] for i in range(bpb.fats)]
        self.fat = fat12_entries(self.fat_copies[0])
        self.root = self._dir_entries(data[bpb.root_offset:bpb.root_offset + bpb.root_entries * 32], '')
        self.owner = {}                 # cluster -> (Entry, index in chain)
        self._walk(self.root)

    def chain(self, first):
        out, c, seen = [], first, set()
        while 2 <= c < 2 + self.bpb.clusters and c not in seen:
            seen.add(c)
            out.append(c)
            c = self.fat[c] if c < len(self.fat) else 0xFFF
            if c >= 0xFF8 or c == 0:
                break
        return out

    def cluster_bytes(self, c):
        o = self.bpb.data_offset + (c - 2) * self.bpb.cluster_bytes
        return self.data[o:o + self.bpb.cluster_bytes]

    def cluster_offset(self, c):
        return self.bpb.data_offset + (c - 2) * self.bpb.cluster_bytes

    def _dir_entries(self, buf, parent_path, parent_unit=''):
        out = []
        for i in range(len(buf) // 32):
            raw = buf[32 * i:32 * i + 32]
            out.append(Entry(raw, i, parent_path, parent_unit))
        return out

    def live(self, entries):
        """Entries up to the 0x00 end marker that are neither deleted nor LFN pieces."""
        for e in entries:
            if e.raw[0] == 0:
                break
            if e.deleted or e.is_lfn:
                continue
            yield e

    def _walk(self, entries):
        for e in self.live(entries):
            if e.is_label or e.is_dot:
                continue
            if e.cluster:
                e.chain = self.chain(e.cluster)
                for k, c in enumerate(e.chain):
                    self.owner.setdefault(c, (e, k))
            if e.is_dir:
                buf = b''.join(self.cluster_bytes(c) for c in e.chain)
                e.children = self._dir_entries(buf, e.path() + '/', e.unit_path() + '/')
                self._walk(e.children)

    def files(self, entries=None):
        """Every live file and directory, depth first."""
        for e in self.live(self.root if entries is None else entries):
            if e.is_label or e.is_dot:
                continue
            yield e
            if e.is_dir and e.children is not None:
                yield from self.files(e.children)

    def file_bytes(self, e):
        return b''.join(self.cluster_bytes(c) for c in e.chain)[:e.size]
