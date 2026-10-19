import struct
ROM_PATH = '/home/fsanches/compartilhado/kn7000_disassembly/baserom/kn7000_program.rom'
BASE = 0x48400000
LIB_SRC = 0x487B8FD1
LIB_BASE = 0x4C000000
LIB_LEN = 0x3F6EE8 - 0x3B8FD1
data = open(ROM_PATH, 'rb').read()
def rd(addr, n):
    if LIB_BASE <= addr < LIB_BASE + LIB_LEN:
        o = addr - LIB_BASE + (LIB_SRC - BASE)
    else:
        o = addr - BASE
    return data[o:o+n]
def u32(a): return struct.unpack('<I', rd(a, 4))[0]
def u16(a): return struct.unpack('<H', rd(a, 2))[0]
def u8(a): return rd(a, 1)[0]
def cstr(a, maxn=200):
    b = rd(a, maxn)
    return b.split(b'\0')[0].decode('latin1')
def find_all(pat):
    res = []
    i = data.find(pat)
    while i >= 0:
        res.append(i + BASE)
        i = data.find(pat, i + 1)
    return res
