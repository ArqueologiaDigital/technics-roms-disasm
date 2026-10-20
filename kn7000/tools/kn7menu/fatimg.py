#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# fatimg.py -- copy a folder tree from the computer into a FAT16 SD card image, as a computer would: folders
# made, files written (an existing one replaced), and a VFAT long name wherever a name is not an upper-case
# 8.3 name already (the short name is then made as Windows makes it, NAME~1.EXT). For the MAME tests: the
# real KN7000's card image with the menu's card layout in it (test/run_menu_tests.sh).
#   python3 -I fatimg.py IMAGE put SRCDIR        everything in SRCDIR into the image's root
#   python3 -I fatimg.py IMAGE ls [PATH]          list a folder (8.3 name, long name, size, first cluster)
# Only FAT16 (the instrument's own format), 512-byte sectors; an MBR is followed to its first partition.
import os
import struct
import sys

VALID83 = set("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#$%&'()-@^_`{}~")


class Fat16:
    def __init__(self, path):
        self.path = path
        self.d = bytearray(open(path, 'rb').read())
        d = self.d
        base = 0
        if d[0] not in (0xEB, 0xE9):
            base = struct.unpack_from('<I', d, 0x1C6)[0] * 512
        self.base = base
        bps, spc, rsv, nfat, nroot, tot16, _m, spf = struct.unpack_from('<HBHBHHBH', d, base + 11)
        tot = tot16 or struct.unpack_from('<I', d, base + 32)[0]
        assert bps == 512, 'only 512-byte sectors'
        self.spc, self.nfat, self.spf = spc, nfat, spf
        self.cb = spc * 512
        self.fat0 = base + rsv * 512
        self.root = self.fat0 + nfat * spf * 512
        self.rootlen = nroot * 32
        self.data = self.root + ((self.rootlen + 511) // 512) * 512
        self.maxcl = (tot - (self.data - base) // 512) // spc + 1
        assert 4085 <= self.maxcl - 1 < 65525, 'not FAT16'

    def save(self):
        open(self.path, 'wb').write(self.d)

    def fat(self, c, v=None):
        if v is None:
            return struct.unpack_from('<H', self.d, self.fat0 + 2 * c)[0]
        for n in range(self.nfat):
            struct.pack_into('<H', self.d, self.fat0 + n * self.spf * 512 + 2 * c, v)

    def alloc(self, n):
        out, c = [], 2
        while len(out) < n:
            assert c <= self.maxcl, 'card full'
            if self.fat(c) == 0:
                out.append(c)
            c += 1
        for a, b in zip(out, out[1:] + [0xFFFF]):
            self.fat(a, b)
        return out

    def free(self, c):
        while 2 <= c <= self.maxcl:
            n = self.fat(c)
            self.fat(c, 0)
            c = n

    def coff(self, c):
        return self.data + (c - 2) * self.cb

    def chain(self, c):
        out = []
        while 2 <= c <= self.maxcl and len(out) < 65536:
            out.append(c)
            c = self.fat(c)
        return out

    def dir_slots(self, cl):
        """Byte offsets of a folder's 32-byte entries (cl 0 = the root)."""
        if cl == 0:
            return [self.root + i for i in range(0, self.rootlen, 32)]
        return [self.coff(c) + i for c in self.chain(cl) for i in range(0, self.cb, 32)]

    def entries(self, cl):
        """(offset, short 11 bytes, long name or None) of each entry in a folder."""
        out, lfn = [], {}
        for o in self.dir_slots(cl):
            e = self.d[o:o + 32]
            if e[0] == 0:
                break
            if e[0] == 0xE5:
                lfn = {}
                continue
            if e[11] & 0x3F == 0x0F:
                s = (e[1:11] + e[14:26] + e[28:32]).decode('utf-16le', 'replace')
                lfn[e[0] & 0x1F] = s
                continue
            name = None
            if lfn:
                name = ''.join(lfn[k] for k in sorted(lfn)).split('\0')[0]
            out.append((o, bytes(e[:11]), name))
            lfn = {}
        return out

    def find(self, cl, name):
        up = name.upper()
        for o, short, lng in self.entries(cl):
            if lng and lng.upper() == up:
                return o
            if show83(short).upper() == up:
                return o
        return None

    def place(self, cl, n):
        """n consecutive free slots in a folder (extended by a cluster when it is full)."""
        slots = self.dir_slots(cl)
        run = []
        for o in slots:
            if self.d[o] in (0, 0xE5):
                run.append(o)
                if len(run) == n:
                    return run
            else:
                run = []
        assert cl != 0, 'root directory full'
        last = self.chain(cl)[-1]
        new = self.alloc(1)[0]
        self.fat(last, new)
        self.d[self.coff(new):self.coff(new) + self.cb] = bytes(self.cb)
        return self.place(cl, n)

    def short_for(self, cl, name):
        """(11-byte short name, long name or None)."""
        base, _, ext = name.rpartition('.') if '.' in name.lstrip('.') else (name, '', '')
        if (name == name.upper() and 1 <= len(base) <= 8 and len(ext) <= 3
                and set(base) <= VALID83 and set(ext) <= VALID83):
            return (base.ljust(8) + ext.ljust(3)).encode('ascii'), None
        b = ''.join(ch for ch in base.upper() if ch in VALID83) or 'X'
        e = ''.join(ch for ch in ext.upper() if ch in VALID83)[:3]
        taken = {s for _, s, _ in self.entries(cl)}
        for k in range(1, 100):
            tail = f'~{k}'
            s = (b[:8 - len(tail)] + tail).ljust(8) + e.ljust(3)
            if s.encode('ascii') not in taken:
                return s.encode('ascii'), name
        raise AssertionError('no short name left')

    def add_entry(self, cl, name, attr, first, size):
        old = self.find(cl, name)
        if old is not None:                      # replace: free the old entry, its long name and data
            c = struct.unpack_from('<H', self.d, old + 26)[0]
            if not self.d[old + 11] & 0x10:
                self.free(c)
            k = old
            self.d[k] = 0xE5
            k -= 32
            while k >= 0 and self.d[k + 11] & 0x3F == 0x0F and self.d[k] != 0xE5:
                self.d[k] = 0xE5
                k -= 32
        short, lng = self.short_for(cl, name)
        parts = []
        if lng:
            ck = 0
            for b in short:
                ck = (((ck & 1) << 7) + (ck >> 1) + b) & 0xFF
            u = lng.encode('utf-16le') + b'\0\0'
            u += b'\xff' * ((-len(u)) % 26)
            n = len(u) // 26
            for i in range(n, 0, -1):
                c = u[(i - 1) * 26:i * 26]
                e = bytearray(32)
                e[0] = i | (0x40 if i == n else 0)
                e[1:11], e[11], e[13], e[14:26], e[28:32] = c[0:10], 0x0F, ck, c[10:22], c[22:26]
                parts.append(bytes(e))
        e = bytearray(32)
        e[0:11] = short
        e[11] = attr
        struct.pack_into('<HH', e, 22, 0x6000, 0x5994)   # 12:00, 2024-12-20
        struct.pack_into('<HI', e, 26, first, size)
        parts.append(bytes(e))
        for o, p in zip(self.place(cl, len(parts)), parts):
            self.d[o:o + 32] = p
        return short

    def put_file(self, cl, name, data):
        n = (len(data) + self.cb - 1) // self.cb
        chain = self.alloc(n) if n else []
        for i, c in enumerate(chain):
            piece = data[i * self.cb:(i + 1) * self.cb]
            self.d[self.coff(c):self.coff(c) + len(piece)] = piece
        self.add_entry(cl, name, 0x20, chain[0] if chain else 0, len(data))

    def mkdir(self, cl, name):
        o = self.find(cl, name)
        if o is not None:
            assert self.d[o + 11] & 0x10, f'{name} exists and is not a folder'
            return struct.unpack_from('<H', self.d, o + 26)[0]
        c = self.alloc(1)[0]
        self.d[self.coff(c):self.coff(c) + self.cb] = bytes(self.cb)
        dot = bytearray(32)
        dot[0:11], dot[11] = b'.          ', 0x10
        struct.pack_into('<H', dot, 26, c)
        dotdot = bytearray(32)
        dotdot[0:11], dotdot[11] = b'..         ', 0x10
        struct.pack_into('<H', dotdot, 26, cl)
        self.d[self.coff(c):self.coff(c) + 64] = dot + dotdot
        self.add_entry(cl, name, 0x10, c, 0)
        return c

    def put_tree(self, src, cl=0):
        for name in sorted(os.listdir(src)):
            p = os.path.join(src, name)
            if os.path.isdir(p):
                self.put_tree(p, self.mkdir(cl, name))
            else:
                self.put_file(cl, name, open(p, 'rb').read())


def show83(short):
    b, e = short[:8].decode('latin1').rstrip(), short[8:].decode('latin1').rstrip()
    return b + ('.' + e if e else '')


def main():
    img, cmd = sys.argv[1:3]
    f = Fat16(img)
    if cmd == 'put':
        f.put_tree(sys.argv[3])
        f.save()
    elif cmd == 'ls':
        cl = 0
        for part in (sys.argv[3].split('\\') if len(sys.argv) > 3 else []):
            cl = struct.unpack_from('<H', f.d, f.find(cl, part) + 26)[0]
        for o, short, lng in f.entries(cl):
            attr = f.d[o + 11]
            c, size = struct.unpack_from('<HI', f.d, o + 26)
            print(f'{show83(short):12} {"<DIR>" if attr & 0x10 else size:>9} cl {c:5}  {lng or ""}')
    else:
        sys.exit('usage: fatimg.py IMAGE put SRCDIR | ls [PATH]')


if __name__ == '__main__':
    main()
