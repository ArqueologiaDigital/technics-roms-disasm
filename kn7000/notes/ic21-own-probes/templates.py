# templates.py -- does each block of Felipe's KN7000 IC21 below the CUSTOM bank equal the default the
# firmware itself writes there?  Each default is searched for in program 893 (this unit's build) and 941:
#   USER MIDI SETTING .MD part, 0x280 bytes at chip 0x4000 (factory copy: func_484C41B6, 941 0x484C41B6,
#     from Str_JK_6 and func_484C41B6_Block..Block_4)
#   the 0x7F0-byte panel image at chip 0x4280 (defaults: func_4C01ED5D copies Str_empty_1431, 0x7F0 bytes)
#   the 0x34-byte settings tail at chip 0x4A70 (func_4C023EC9 copies 26 halfwords func_4C023EC9_Table)
#   FAVORITES, 0x198 bytes at chip 0x10000 (func_4849EDEB copies func_4849EDEB_Table)
#   the HOME PAGE record, 0x18C bytes at chip 0x11000 (HpFlashWriteDefaults copies the ROM template)
#   the HOME PAGE BMP, 0x42B6 bytes at chip 0x1118C (HpBmpResetDefault copies the ROM default BMP)
# A block is printed with the program offset(s) where it occurs whole, or with how many of its bytes equal
# the best candidate otherwise (the candidate is found by its first 8 bytes).
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _paths
d = _paths.chip()
blocks = (('USER MIDI SETTING (.MD part)', 0x4000, 0x280), ('panel image', 0x4280, 0x7F0),
          ('settings tail', 0x4A70, 0x34), ('FAVORITES', 0x10000, 0x198),
          ('HOME PAGE record', 0x11000, 0x18C), ('HOME PAGE BMP', 0x1118C, 0x42B6))
for build in ('893', '941'):
    p = _paths.program(build)
    for what, off, n in blocks:
        b = d[off:off + n]
        hits, i = [], p.find(b)
        while i >= 0:
            hits.append(hex(0x48400000 + i)); i = p.find(b, i + 1)
        if hits:
            print(f'{build} {what:30s} {n:#7x} B: equal to program {", ".join(hits)}')
            continue
        best = None
        i = p.find(b[:8])
        while i >= 0:
            eq = sum(x == y for x, y in zip(b, p[i:i + n]))
            if best is None or eq > best[1]:
                best = (i, eq)
            i = p.find(b[:8], i + 1)
        print(f'{build} {what:30s} {n:#7x} B: not whole in the program; ' +
              (f'best candidate {0x48400000 + best[0]:#x} with {best[1]} of {n} bytes equal' if best else 'no candidate'))
