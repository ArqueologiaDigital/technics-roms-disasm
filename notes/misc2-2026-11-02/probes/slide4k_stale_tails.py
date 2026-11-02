#!/usr/bin/env python3
"""slide4k_stale_tails.py -- what are the bytes after demo songs 17 and 18's SLIDE4K streams?

QUESTION IT ANSWERS
  The factory slices of demo songs 17 (0x9F4959..0x9F94CA) and 18 (0x8E000B..0x8E6D3E) run on past the
  stream their header's size makes the decoder read: 15,957 B after song 17's 3,357-byte stream, 75 B after
  song 18's 27,881-byte stream.  Are they something a source could regenerate?  It prints:
    0. how many bytes at the start of song 17's tail repeat the stream's own last bytes (a copy the build can
       derive); the rest of the tail ("the old part") is what 1.-4. look at;
    1. whether song 18's 75-byte tail equals the last 75 bytes of song 17's tail;
    2. the runs (>= 16 B) where the old part equals the current song-18 stream, with both offsets;
    3. whether the old part parses as SLIDE4K items (flag byte, 8 items, low bit first) from its first
       byte to its last, and that the parse converges on the song-18 stream's own item boundaries inside the
       longest equal run (the same items, not just the same bytes);
    4. whether any 16-byte piece of song 17's tail occurs anywhere else in the table data image or in the
       other KN5000 images (a copy would make it derivable, as the stale help block is).
  Measured 2026-11-02: 0 the first 398 bytes of the tail equal the stream's last 398 (ROM 0x9F54E8..0x9F5675
  repeated at 0x9F5676..0x9F5803), so the old part is the last 15,559 bytes; 1 yes; 2 nine runs, the longest 199 B (old part +13,100 = stream +25,576),
  the stream offset 12,425 to 12,476 bytes ahead of the old part's (12,385 for one 49-byte run), the last five
  in the stream's last 2.7 KB; 3 the parse ends on the old part's last byte and hits all 144 item boundaries of
  the 199-byte run; 4 every piece found is inside song 18's slice (the runs of 2.), none elsewhere in 58 images.
  (Offsets in 2. and 3. are from the old part's start, tail + 398.)
  Reading: both tails are the end of one older SLIDE4K stream, close to the current Feature Demo stream;
  [INFERENCE] an earlier Feature Demo, 27,956 B long if it started where song 18's stream starts.  A stream's references point into the
  window of everything decoded before, and that older stream's start is overwritten, so its plain bytes, and
  with them any source, are gone: the tails are declared `census: opaque -- compressed`.

RUN (repository root)
  python3 notes/misc2-2026-11-02/probes/slide4k_stale_tails.py
"""
import difflib
import glob
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
R = os.path.join(ROOT, "original_ROMs")
S17, S18 = 3357, 27881          # stream lengths the decoder reads (slide4k_encode_exact.py)


def boundaries(c, start=0):
    """Item start offsets parsing c from a flag byte at `start`; and the offset after the last item."""
    out, i = [], start
    while i < len(c):
        f = c[i]
        i += 1
        for b in range(8):
            if i >= len(c):
                break
            out.append(i)
            i += 1 if f >> b & 1 else 2
    return out, i


def main():
    a = open(os.path.join(R, "demo_preset_17_compressed.original.bin"), "rb").read()
    b = open(os.path.join(R, "demo_preset_18_compressed.original.bin"), "rb").read()
    t17, t18 = a[S17:], b[S18:]
    # the longest k such that the tail starts with the stream's last k bytes
    rep = max(k for k in range(0, S17 + 1) if t17[:k] == a[S17 - k:S17])
    print("0. the tail's first %d bytes == the stream's last %d bytes (ROM 0x%06X.. repeated at 0x%06X..)"
          % (rep, rep, 0x9F4959 + S17 - rep, 0x9F4959 + S17))
    t17 = t17[rep:]
    print("1. song 18's %d-byte tail == the last %d bytes of song 17's old part: %s" % (len(t18), len(t18), t17.endswith(t18)))
    sm = difflib.SequenceMatcher(None, t17, b[:S18], autojunk=False)
    runs = [m for m in sm.get_matching_blocks() if m.size >= 16]
    print("2. %d runs of >= 16 B where song 17's old part equals the song-18 stream:" % len(runs))
    for m in runs:
        print("     old part +%5d = stream +%5d, %3d B (offset %d)" % (m.a, m.b, m.size, m.b - m.a))
    big = max(runs, key=lambda m: m.size)
    ib, _ = boundaries(b[:S18])
    bset = set(ib)
    it, end = boundaries(t17)
    aset = set(it)
    zone = [p for p in range(big.a, big.a + big.size) if p + (big.b - big.a) in bset]
    print("3. song 17's old part parses as SLIDE4K items to offset %d of %d (%s); in the %d-byte run it hits %d of the"
          " stream's %d item boundaries" % (end, len(t17), "its last byte" if end == len(t17) else "NOT the end",
                                            big.size, sum(p in aset for p in zone), len(zone)))
    others = [p for p in glob.glob(os.path.join(R, "*")) + glob.glob(os.path.expanduser(
        "~/compartilhado/technics_roms/roms/kn5000/*")) if os.path.isfile(p) and "demo_preset" not in p]
    rom = open(os.path.join(R, "kn5000_table_data.rom"), "rb").read()
    own = (rom.find(a), rom.find(a) + len(a))           # song 17's whole slice
    s18 = (rom.find(b[:64]), rom.find(b[:64]) + len(b))      # song 18's slice: the stream the runs above match
    inside18, elsewhere = 0, []
    for p in others:
        d = open(p, "rb").read()
        is_rom = d == rom
        for k in range(0, len(t17) - 16, 16):
            i = d.find(t17[k:k + 16])
            while i >= 0:
                if is_rom and own[0] <= i < own[1]:
                    pass
                elif is_rom and s18[0] <= i < s18[1]:
                    inside18 += 1
                    break
                else:
                    elsewhere.append((os.path.basename(p), i, k))
                    break
                i = d.find(t17[k:k + 16], i + 1)
    print("4. 16-byte pieces of song 17's old part (stride 16) found outside their own place, in %d images: %d inside"
          " song 18's slice (the runs of 2.), %d elsewhere %s" % (len(others), inside18, len(elsewhere),
                                                                  elsewhere[:8]))

if __name__ == "__main__":
    main()
