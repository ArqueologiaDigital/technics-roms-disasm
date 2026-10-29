#!/usr/bin/env python3
"""lzss_j.py -- the LZSS of the SX-KN7000's 'J KD' files: decoder, and an encoder that reproduces them bit for bit.

QUESTION IT ANSWERS
  "What compression is inside a 'J KD' file (.CMP .SQT .PMT .LSW .MSP), and which encoder wrote it?"

THE FORMAT (measured: floppy/notes probes, `kd.py verify` reproduces all 61 'J KD' parts on ca7001, organs,
custom1, custom2 and idd7000 with this encoder):
  * a flag byte, then 8 items, low bit first; bit = 1: one literal byte; bit = 0: a two-byte reference
        lo, hi:   position = lo | (hi >> 3) << 8   (13 bits: an 8 KB ring buffer)
                  length   = (hi & 7) + 3          (3..10 bytes)
    The position is ABSOLUTE in the ring, not a distance.
  * the ring is 8192 bytes, pre-filled with 0x00, and the first byte decoded is written at 0x1FF6 = N - F
    (N = 8192, F = 10 = the longest match); a reference to a position not yet written reads 0x00.
  * no end marker: the decoder stops at the size held in the file header; the stream has no padding.
  This is H. Okumura's LZSS (LZSS.C, 1989) with N = 8192, F = 10, THRESHOLD = 2, fill byte 0, and the
  position's high bits packed above a 3-bit length -- the KN5000's SLIDE4K is the same coder with N = 4096,
  F = 18, a 4-bit length.

THE ENCODER
  `encode()` is LZSS.C's binary-tree encoder (InsertNode / DeleteNode), unchanged except for N, F and the
  field packing.  Its match choice (first longest match met in the tree walk, ties to the most recently
  inserted string) is what the instrument's own encoder does: every 'J KD' part on the softlist disks is
  re-encoded identically, so no reference stream is needed.

USAGE
  python3 -I lzss_j.py encode IN OUT        # raw -> LZSS
  python3 -I lzss_j.py decode IN OUT SIZE   # LZSS -> raw (SIZE bytes)
"""
import sys

N, F, THRESHOLD, FILL = 0x2000, 10, 2, 0x00
LENBITS = 3


def decode(c, n):
    """Decode `n` bytes from stream `c`.  Returns (data, bytes of `c` consumed)."""
    w = bytearray([FILL]) * N
    wp = N - F
    out = bytearray()
    i = 0
    while len(out) < n and i < len(c):
        f = c[i]
        i += 1
        for b in range(8):
            if len(out) >= n or i >= len(c):
                break
            if f >> b & 1:
                x = c[i]
                i += 1
                out.append(x)
                w[wp] = x
                wp = (wp + 1) & (N - 1)
            else:
                lo, hi = c[i], c[i + 1]
                i += 2
                pos = lo | (hi >> LENBITS) << 8
                for k in range((hi & ((1 << LENBITS) - 1)) + THRESHOLD + 1):
                    x = w[(pos + k) & (N - 1)]
                    out.append(x)
                    w[wp] = x
                    wp = (wp + 1) & (N - 1)
    if len(out) != n:
        raise ValueError("lzss_j: stream ends after %d of %d bytes" % (len(out), n))
    return bytes(out), i


def encode(data):
    """LZSS.C's encoder with this format's parameters."""
    NIL = N
    lson = [NIL] * (N + 1)
    rson = [NIL] * (N + 257)
    dad = [NIL] * (N + 1)
    tb = bytearray(N + F - 1)
    match = [0, 0]                      # position, length

    def insert(r):
        cmp = 1
        p = N + 1 + tb[r]
        rson[r] = lson[r] = NIL
        match[1] = 0
        while True:
            if cmp >= 0:
                if rson[p] != NIL:
                    p = rson[p]
                else:
                    rson[p] = r
                    dad[r] = p
                    return
            else:
                if lson[p] != NIL:
                    p = lson[p]
                else:
                    lson[p] = r
                    dad[r] = p
                    return
            i = 1
            while i < F:
                cmp = tb[r + i] - tb[p + i]
                if cmp:
                    break
                i += 1
            if i > match[1]:
                match[0], match[1] = p, i
                if i >= F:
                    break
        dad[r], lson[r], rson[r] = dad[p], lson[p], rson[p]
        dad[lson[p]] = r
        dad[rson[p]] = r
        if rson[dad[p]] == p:
            rson[dad[p]] = r
        else:
            lson[dad[p]] = r
        dad[p] = NIL

    def delete(p):
        if dad[p] == NIL:
            return
        if rson[p] == NIL:
            q = lson[p]
        elif lson[p] == NIL:
            q = rson[p]
        else:
            q = lson[p]
            if rson[q] != NIL:
                while rson[q] != NIL:
                    q = rson[q]
                rson[dad[q]] = lson[q]
                dad[lson[q]] = dad[q]
                lson[q] = lson[p]
                dad[lson[p]] = q
            rson[q] = rson[p]
            dad[rson[p]] = q
        dad[q] = dad[p]
        if rson[dad[p]] == p:
            rson[dad[p]] = q
        else:
            lson[dad[p]] = q
        dad[p] = NIL

    out = bytearray()
    code = bytearray([0])
    mask = 1
    s, r = 0, N - F
    for i in range(s, r):
        tb[i] = FILL
    pos, n, ln = 0, len(data), 0
    while ln < F and pos < n:
        tb[r + ln] = data[pos]
        pos += 1
        ln += 1
    if ln == 0:
        return bytes(out)
    for i in range(1, F + 1):
        insert(r - i)
    insert(r)
    while True:
        if match[1] > ln:
            match[1] = ln
        if match[1] <= THRESHOLD:
            match[1] = 1
            code[0] |= mask
            code.append(tb[r])
        else:
            mp = match[0]
            code.append(mp & 0xff)
            code.append(((mp >> 8) << LENBITS) & 0xff | (match[1] - (THRESHOLD + 1)))
        mask = (mask << 1) & 0xff
        if mask == 0:
            out += code
            code = bytearray([0])
            mask = 1
        last = match[1]
        i = 0
        while i < last and pos < n:
            c = data[pos]
            pos += 1
            delete(s)
            tb[s] = c
            if s < F - 1:
                tb[s + N] = c
            s = (s + 1) & (N - 1)
            r = (r + 1) & (N - 1)
            insert(r)
            i += 1
        while i < last:
            i += 1
            delete(s)
            s = (s + 1) & (N - 1)
            r = (r + 1) & (N - 1)
            ln -= 1
            if ln:
                insert(r)
        if ln <= 0:
            break
    if len(code) > 1:
        out += code
    return bytes(out)


if __name__ == "__main__":
    a = sys.argv[1:]
    if len(a) == 3 and a[0] == "encode":
        open(a[2], "wb").write(encode(open(a[1], "rb").read()))
    elif len(a) == 4 and a[0] == "decode":
        open(a[2], "wb").write(decode(open(a[1], "rb").read(), int(a[3], 0))[0])
    else:
        sys.exit(__doc__)
