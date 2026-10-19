#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# fatls.py -- list (or extract) the files on a FAT12/16 SD card image as the KN7000 writes it (MBR with
# one partition, or a bare volume). Long-name entries are shown as such; files are read by following the
# FAT chain.
#   python3 -I fatls.py SD.img                 # tree with sizes and CRC32
#   python3 -I fatls.py SD.img PATH OUT        # extract one file (PATH like C:\ROMDUMP\FILE.BIN)
import struct
import sys
import zlib


class Fat:
    def __init__(self, path):
        self.f = open(path, 'rb')
        mbr = self.rd(0, 512)
        self.lba = 0
        if mbr[0x1fe:0x200] == b'\x55\xaa' and mbr[0x1c2] in (1, 4, 6, 0xb, 0xc, 0xe):
            self.lba = struct.unpack_from('<I', mbr, 0x1c6)[0]
        bs = self.rd(self.lba * 512, 512)
        (self.bps, self.spc, res, nf, self.rde, tot16, _, self.spf) = struct.unpack_from('<HBHBHHBH', bs, 11)
        tot = tot16 or struct.unpack_from('<I', bs, 32)[0]
        self.fat = (self.lba + res) * self.bps
        self.root = self.fat + nf * self.spf * self.bps
        self.data = self.root + self.rde * 32
        clusters = (tot - (res + nf * self.spf + self.rde * 32 // self.bps)) // self.spc
        self.fat16 = clusters >= 4085

    def rd(self, off, n):
        self.f.seek(off)
        return self.f.read(n)

    def next(self, c):
        if self.fat16:
            return struct.unpack_from('<H', self.rd(self.fat + 2 * c, 2))[0]
        v = struct.unpack_from('<H', self.rd(self.fat + c * 3 // 2, 2))[0]
        return (v >> 4) if c & 1 else (v & 0xfff)

    def chain(self, c):
        end = 0xfff8 if self.fat16 else 0xff8
        while 2 <= c < end:
            yield c
            c = self.next(c)

    def read_file(self, c, size):
        cb = self.spc * self.bps
        out = b''.join(self.rd(self.data + (x - 2) * cb, cb) for x in self.chain(c))
        return out[:size] if size is not None else out

    def entries(self, c):
        raw = self.rd(self.root, self.rde * 32) if c == 0 else self.read_file(c, None)
        lfn = []
        for i in range(0, len(raw), 32):
            e = raw[i:i + 32]
            if e[0] == 0:
                break
            if e[0] == 0xe5:
                lfn = []
                continue
            if e[11] == 0x0f:
                part = (e[1:11] + e[14:26] + e[28:32]).decode('utf-16-le', 'replace')
                lfn.insert(0, part.split('\x00')[0])
                continue
            short = e[0:8].decode('latin1').rstrip()
            ext = e[8:11].decode('latin1').rstrip()
            name = short + ('.' + ext if ext else '')
            yield name, ''.join(lfn) or None, e[11], struct.unpack_from('<H', e, 26)[0], struct.unpack_from('<I', e, 28)[0]
            lfn = []


def walk(fat, c, path):
    for name, lng, attr, cl, size in fat.entries(c):
        if attr & 0x08 or name in ('.', '..'):
            continue
        shown = path + name + (f'  [long name: {lng}]' if lng else '')
        if attr & 0x10:
            print(f'{shown}\\')
            walk(fat, cl, path + name + '\\')
        else:
            crc = zlib.crc32(fat.read_file(cl, size)) & 0xffffffff
            print(f'{shown}  {size} bytes  crc32 {crc:08x}')


def find(fat, path):
    c, size = 0, None
    for part in path.replace('C:\\', '').split('\\'):
        for name, lng, attr, cl, sz in fat.entries(c):
            if part.upper() in (name.upper(), (lng or '').upper()):
                c, size = cl, (None if attr & 0x10 else sz)
                break
        else:
            sys.exit(f'{part}: not found')
    return fat.read_file(c, size)


if __name__ == '__main__':
    fat = Fat(sys.argv[1])
    if len(sys.argv) > 3:
        open(sys.argv[3], 'wb').write(find(fat, sys.argv[2]))
    else:
        walk(fat, 0, 'C:\\')
