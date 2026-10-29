#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""ast_file.py -- the .AST file of the KN7000 / KN6000 floppies: the whole CUSTOM STYLE flash bank.

FORMAT (KN7000 program 941; kn7000/notes/custom-data-ic21.md, section ".AST file")
  +0x00  3 bytes  file-type tag: "J K" on the KN7000 (0x48664308), "I K" on the KN6000
  +0x03  u8       1
  +0x04  u32 LE   payload size, 0x1E0000 (func_4852D0E5 stores both on its stack frame)
  +0x08  8 bytes  never written by func_4852D0E5: whatever its stack frame held (two words,
                  0x48582CD3 0x5006F220 in custom1/custom2's eight files, 0x485A9C1D 0x5006ED88
                  in idd7000's, 0 and 0x50052930 in idd6000's)
  +0x10  ...      the bank image, deflated by the program's zlib 1.0.4 (deflateInit_ level -1
                  = 6, windowBits 15, memLevel 8) WITHOUT the 2-byte zlib header: raw deflate,
                  then the zlib trailer, the Adler-32 of the image, big-endian.

  inflate AST OUT        check the header and the trailer, write the 0x1E0000-byte image
  deflate IMAGE OUT --like AST
                         rebuild an .AST from an image, taking the tag and the 8 stack bytes
                         from an existing file; the deflate is zlib10_deflate.py's port of
                         zlib 1.0.4 (exits 1 when the result differs from --like)
"""
import argparse
import struct
import sys
import zlib

SIZE = 0x1E0000
TAGS = {b"J K": "KN7000", b"I K": "KN6000"}


def parse(ast):
    tag, ver, size = ast[0:3], ast[3], struct.unpack_from("<I", ast, 4)[0]
    if tag not in TAGS or ver != 1 or size != SIZE:
        raise SystemExit(f"not a custom-style .AST: tag {tag!r} version {ver} size {size:#x}")
    d = zlib.decompressobj(-15)
    img = d.decompress(ast[16:]) + d.flush()
    if not d.eof or len(img) != size:
        raise SystemExit(f"deflate stream: eof {d.eof}, {len(img):#x} bytes")
    trailer = d.unused_data
    if len(trailer) != 4 or struct.unpack(">I", trailer)[0] != zlib.adler32(img):
        raise SystemExit(f"trailer {trailer.hex()} is not the Adler-32 {zlib.adler32(img):08x}")
    return tag, ast[8:16], img, len(ast) - 16 - 4


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    a = sub.add_parser("inflate")
    a.add_argument("ast")
    a.add_argument("out")
    b = sub.add_parser("deflate")
    b.add_argument("image")
    b.add_argument("out")
    b.add_argument("--like", required=True)
    args = ap.parse_args()
    if args.cmd == "inflate":
        tag, stack, img, n = parse(open(args.ast, "rb").read())
        open(args.out, "wb").write(img)
        print(f"{args.out}: {TAGS[tag]} custom-style bank, {len(img):#x} bytes from {n} deflated")
        return 0
    like = open(args.like, "rb").read()
    tag, stack, _, _ = parse(like)
    img = open(args.image, "rb").read()
    if len(img) != SIZE:
        raise SystemExit(f"{args.image}: {len(img):#x} bytes, expected {SIZE:#x}")
    sys.path.insert(0, __file__.rsplit("/", 1)[0])
    import zlib10_deflate
    body = zlib10_deflate.deflate_raw(img, level=6, mem_level=8)
    out = tag + b"\x01" + struct.pack("<I", SIZE) + stack + body + struct.pack(">I", zlib.adler32(img))
    open(args.out, "wb").write(out)
    same = out == like
    print(f"{args.out}: {len(out)} bytes, {'identical to' if same else 'DIFFERENT from'} {args.like}")
    return 0 if same else 1


if __name__ == "__main__":
    sys.exit(main())
