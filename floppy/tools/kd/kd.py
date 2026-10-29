#!/usr/bin/env python3
"""kd.py -- the file containers of the SX-KN6000 / SX-KN7000 floppies: parse, unpack, re-encode.

QUESTION IT ANSWERS
  "How is each KN6000 / KN7000 disk file wrapped, and can every wrapper be rebuilt from its payload?"
  `verify` answers the second half for every file of every disk given: it splits each file into its header
  and payload parts, re-encodes the parts with the encoders below, and compares with the disk.

THE CONTAINERS (the first byte is the model: 'I' = KN6000, 'J' = KN7000; evidence in notes/
floppy-others-2026-10-29/README.md, "Containers")
  KD      'I KD' 'J KD' 'IK D'   .CMP .TM .PMT .MSP .EFC (one part)   .SQT .LSW (two parts)
            +0  magic[4]   +4 u16be version = 1   +6 u16be flags (0x0000; .SQT 0x000f or 0x00f0)
            one part:  +8 u32le 0   +0xc u32le size              +0x10 stream
            two parts: +8 u32le size1  +0xc size2  +0x10 csize1  +0x14 csize2   +0x18 stream1 stream2
  K1      'I K\\x01' 'J K\\x01'   .AST (custom-data flash image), .CST (custom style)
            +0  magic[4]   +4 u32le size   .AST: +8, +0xc two u32le words, stream at +0x10
                                           .CST: +8 .. +0x30 a style header, stream at +0x30
  RAW     'IK \\0' 'JK \\0' and every other file: stored as is (.HMP .FAV .MD .JPG .CNV .TXT ...)

  A stream is coded by the model: 'I' parts (and every K1 part) are zlib 1.0.4 deflate, level 6, written
  WITHOUT the 2-byte zlib header but WITH the 4-byte big-endian adler32; their csize counts the absent
  header too (stream + 2).  'J KD' parts are LZSS (lzss_j.py), csize = stream length.  An empty 'I' part
  is the 6 bytes 03 00 00 00 00 01 (csize 8); an empty 'J' part is nothing (csize 0).

USAGE
  python3 -I kd.py unpack FILE OUTPREFIX     # OUTPREFIX.hdr (the header bytes), OUTPREFIX.p1 [.p2] payloads
  python3 -I kd.py encode CODEC IN OUT       # CODEC = deflate104 | lzss_j: one stream as it sits on disk
  python3 -I kd.py verify FILE...            # every container of these extracted files re-encodes exactly
The deflate coder is the C program zdeflate104 (build it with `make -C floppy/tools/kd`); set ZDEFLATE104 to
its path if it is not next to this script.
"""
import os
import struct
import subprocess
import sys
import zlib

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import lzss_j  # noqa: E402

ZDEFLATE104 = os.environ.get("ZDEFLATE104", os.path.join(HERE, "zdeflate104"))
TWO_PART = {"SQT", "LSW"}


def deflate104(data):
    return subprocess.run([ZDEFLATE104], input=data, capture_output=True, check=True).stdout


def encode(codec, data):
    if codec == "deflate104":
        return deflate104(data)
    if codec == "lzss_j":
        return lzss_j.encode(data)
    raise ValueError(codec)


def inflate_part(d, off):
    """A deflate part at `off`: returns (payload, offset just past its adler32)."""
    o = zlib.decompressobj(-15)
    p = o.decompress(d[off:])
    if not o.eof:
        raise ValueError("deflate stream at 0x%x does not end" % off)
    end = len(d) - len(o.unused_data)
    if struct.unpack(">I", d[end:end + 4])[0] != zlib.adler32(p):
        raise ValueError("adler32 after the stream at 0x%x does not match" % off)
    return p, end + 4


def parse(d, ext):
    """-> (kind, header bytes, [(codec, payload, on-disk stream)])."""
    ext = ext.upper()
    m = d[:4]
    if len(d) >= 0x10 and m in (b"I KD", b"J KD", b"IK D"):
        codec = "lzss_j" if m[0:1] == b"J" else "deflate104"
        if ext in TWO_PART:
            s1, s2, c1, c2 = struct.unpack_from("<4I", d, 8)
            hlen, sizes = 0x18, [(s1, c1), (s2, c2)]
        else:
            z, s1 = struct.unpack_from("<2I", d, 8)
            if z:
                raise ValueError("one-part KD with +8 = 0x%x" % z)
            hlen, sizes = 0x10, [(s1, None)]
        parts, off = [], hlen
        for size, csize in sizes:
            if codec == "deflate104":
                p, end = inflate_part(d, off)
                if csize is not None and csize != end - off + 2:
                    raise ValueError("csize 0x%x != stream 0x%x + 2" % (csize, end - off))
            else:
                p, used = lzss_j.decode(d[off:], size)
                end = off + used
                if csize is not None and csize != used:
                    raise ValueError("csize 0x%x != stream 0x%x" % (csize, used))
            if len(p) != size:
                raise ValueError("payload 0x%x != header size 0x%x" % (len(p), size))
            parts.append((codec, p, d[off:end]))
            off = end
        if off != len(d):
            raise ValueError("0x%x bytes after the last part" % (len(d) - off))
        return "KD", d[:hlen], parts
    if len(d) >= 0x10 and m in (b"I K\x01", b"J K\x01"):
        hlen = 0x30 if ext == "CST" else 0x10
        size = struct.unpack_from("<I", d, 4)[0]
        p, end = inflate_part(d, hlen)
        if len(p) != size or end != len(d):
            raise ValueError("K1 sizes")
        return "K1", d[:hlen], [("deflate104", p, d[hlen:end])]
    return "RAW", b"", []


def rebuild(kind, hdr, parts):
    if kind == "RAW":
        raise ValueError("RAW has no parts")
    return hdr + b"".join(encode(c, p) for c, p, _ in parts)


def main(a):
    if len(a) == 3 and a[0] == "unpack":
        d = open(a[1], "rb").read()
        kind, hdr, parts = parse(d, a[1].rsplit(".", 1)[-1])
        if kind == "RAW":
            sys.exit("kd.py: %s is not a compressed container" % a[1])
        open(a[2] + ".hdr", "wb").write(hdr)
        for i, (_, p, _) in enumerate(parts, 1):
            open(a[2] + ".p%d" % i, "wb").write(p)
        return 0
    if len(a) == 4 and a[0] == "encode":
        open(a[3], "wb").write(encode(a[1], open(a[2], "rb").read()))
        return 0
    if len(a) >= 2 and a[0] == "verify":
        bad = 0
        for f in a[1:]:
            d = open(f, "rb").read()
            kind, hdr, parts = parse(d, f.rsplit(".", 1)[-1])
            ok = kind == "RAW" or rebuild(kind, hdr, parts) == d
            bad += not ok
            print("%-4s %-4s %s" % ("OK" if ok else "FAIL", kind, f))
        return 1 if bad else 0
    sys.exit(__doc__)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
