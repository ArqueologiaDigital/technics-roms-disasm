#!/usr/bin/env python3
"""help_db_layout_probe.py -- what layout do the five live decompressed HELP databases have?

Decompresses each factory SLIDE8K stream (original_ROMs/help_db_<lang>_compressed.original.bin) and
measures, without assuming them, the facts scripts/build/help_db_text.py relies on:
  - 200 u32 pointers at +0, all into the pool at RAM 0x69B20 (= 0x69800 + 0x320);
  - which slots point at the shared empty string (0x69B20) and whether any other string is shared;
  - pool order == topic-major order (slot = 50 * (page - 1) + topic, topic-major = topic 0 p1..p4, ...);
  - alignment pad bytes (value, and whether strings start on even addresses);
  - fill after the pool; control bytes; escapes "~xx"; bytes >= 0x80;
  - slot -> topic title, from the v10 program ROM's HelpTtlFunc_LookupSlide_PtrTable (0xE343EE),
    read as title[(topic - 1) mod 50] (HelpTtlFunc_DecrementPage, 0xF2E94D).
Prints one summary line per language and, with --titles, the topic table.

    python3 notes/kn5000-existing-includes-2026-10-29/probes/help_db_layout_probe.py [--titles]
"""
import collections, re, struct, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'scripts' / 'build'))
import decompress_slide8k as d8

BASE, POOL, SIZE = 0x69800, 0x69B20, 0x9000
for lang in ['english', 'german', 'french', 'spanish', 'indonesian']:
    ref = (ROOT / 'original_ROMs' / f'help_db_{lang}_compressed.original.bin').read_bytes()
    d, _ = d8.decompress_slide8k(d8.MAGIC + SIZE.to_bytes(3, 'big') + ref)
    ptr = struct.unpack('<200I', d[:800])
    pool = sorted(set(ptr))
    tm = []
    for t in range(50):
        for pg in range(4):
            p = ptr[pg * 50 + t]
            if p != POOL and p not in tm:
                tm.append(p)
    shared = [hex(p) for p, n in collections.Counter(ptr).items() if n > 1 and p != POOL]
    pads, odd, ctl, esc, hi = collections.Counter(), 0, 0, collections.Counter(), collections.Counter()
    end = 0
    for p in pool:
        o = p - BASE
        odd += o % 2
        e = d.index(b'\0', o)
        s = d[o:e]
        ctl += sum(1 for c in s if c < 0x20 or c == 0x7f)
        esc.update(m.decode() for m in re.findall(rb'~..', s))
        hi.update(chr(c) for c in s if c >= 0x80)
        end = e + 1
        if end % 2:
            pads[d[end]] += 1
            end += 1
    print(f'{lang:<11} {len(d):,} B  len(pool)={len(pool)}  empty slots={ptr.count(POOL)}  shared={shared or "none"}  '
          f'topic-major={tm == pool[1:]}  odd starts={odd}  pad values={dict(pads)}  '
          f'fill after pool={set(d[end:]) or "none"} ({SIZE - end} B)  control bytes={ctl}  escapes={dict(esc)}  '
          f'Latin-1 letters={"".join(sorted(hi))}')
if '--titles' in sys.argv:
    r = (ROOT / 'original_ROMs' / 'kn5000_v10_program.rom').read_bytes()
    pt = struct.unpack('<50I', r[0xE343EE - 0xE00000:0xE343EE - 0xE00000 + 200])
    t = [r[p - 0xE00000:r.index(b'\0', p - 0xE00000)].decode('latin-1') for p in pt]
    for topic in range(50):
        print(f'  topic {topic:2}  {t[(topic - 1) % 50]}')
