#!/usr/bin/env python3
# probe.py [build/kn7000_picture.rom] -- the numbers notes/ic19-picture-rom.md quotes, from the rebuilt image
# (make verify-picture first): picture sizes (smallest, largest, total), every picture's frame size, entry 0
# parsed the way the SOFT VERSION screen does (decimal digits from 0x57800400), and the hypotheses tried for
# entry 0 before that routine was read (none fits), each printed with its value.
import os, struct, sys
p = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), '..', '..', 'build', 'kn7000_picture.rom')
b = open(p, 'rb').read()
offs = struct.unpack_from('<102I', b, 0)
jp = []
for n in range(100):
    s = b[offs[n + 1]:offs[n + 2]]
    jp.append(s[:s.rfind(b'\xff\xd9') + 2])
dims = set()
for j in jp:
    i = 2
    while i < len(j):
        if j[i + 1] in (0xC0, 0xC1, 0xC2):
            dims.add(struct.unpack_from('>HH', j, i + 5)[::-1]); break
        i += 2 + struct.unpack_from('>H', j, i + 2)[0]
sizes = [len(j) for j in jp]
print(f'pictures: 100; JPEG bytes smallest {min(sizes)} (PRESET {sizes.index(min(sizes))}), '
      f'largest {max(sizes)} (PRESET {sizes.index(max(sizes))}), total {sum(sizes)}; frame sizes {sorted(dims)}')
e0 = struct.unpack_from('<I', b, 0x400)[0]
data = b[0x404:offs[-1]]
x = 0
for c in data: x ^= c
tries = {
    'byte sum of the pictures area, 16 bits': sum(data) & 0xFFFF,
    'byte sum of everything before the end, 16 bits': sum(b[:offs[-1]]) & 0xFFFF,
    'byte sum of the 2 MB, 16 bits': sum(b) & 0xFFFF,
    'u16 sum of the pictures area': sum(struct.unpack_from(f'<{len(data) // 2}H', data)) & 0xFFFF,
    'xor of the pictures area': x,
    'size of the pictures area': len(data),
    'size of the pictures area in KB': len(data) // 1024,
}
v = 0
for c in b[0x400:0x404]:
    if not 0x30 <= c <= 0x39: break
    v = v * 10 + c - 0x30
print(f'entry 0 = {e0:#x}; as the SOFT VERSION screen reads it (AcAromVerBoxProc 0x48488A0B): PICTURE : {v}')
for k, v in tries.items():
    print(f'   {k:48s} {v:#x}{"   <== equal" if v == e0 else ""}')
