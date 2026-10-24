#!/usr/bin/env python3
"""apply_c_divergence.py TREE -- patch a ported main-program tree's C data bins.

QUESTION ANSWERED: which bytes of TREE's compiled C data (TREE/maincpu/includes/generated/*.bin)
does the ROM need different from what the C, shared with the newer tree it was ported from,
compiles to -- and are they applied exactly once?

The ported trees (v6, and v5 after it; scripts/converters/port_maincpu_version.py) keep the C
data sources of the tree they were ported from, so a C file compiles to the NEWER firmware's
bytes.  TREE/maincpu/includes/TREE_c_divergence.json records, per bin, where the older ROM differs:

    "reloc": [[offset, delta], ...]   a 32-bit little-endian pointer moved by delta
    "raw":   {offset: byte, ...}      any other byte
    "size":  bytes of the bin the build uses

It is written by `port_maincpu_version.py --cdiv`, which compares the compiled bins with the
bytes the ported source places there.  This is scripts/build/apply_v7_c_divergence.py's
scheme, for any tree; the same idempotency stamp keeps a relative relocation from being
applied twice to a bin that make did not recompile.  A missing json means nothing to patch.

    python3 scripts/build/apply_c_divergence.py v6
"""
import hashlib
import json
import pathlib
import sys

REPO = pathlib.Path(__file__).resolve().parent.parent.parent


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    tree = sys.argv[1]
    gen = REPO / tree / "maincpu" / "includes" / "generated"
    path = REPO / tree / "maincpu" / "includes" / ("%s_c_divergence.json" % tree)
    if not path.exists():
        print("apply_c_divergence: %s has no %s -- nothing to patch" % (tree, path.name))
        return
    patch = json.loads(path.read_text())
    nrel = nraw = nskip = 0
    for name, ent in sorted(patch.items()):
        target = gen / name
        if not target.exists():
            sys.exit("apply_c_divergence: %s missing -- build the C bins first" % target)
        stamp = target.with_suffix(target.suffix + ".patched")
        cur = target.read_bytes()
        if stamp.exists() and stamp.read_text().strip() == hashlib.sha256(cur).hexdigest():
            nskip += 1
            continue
        data = bytearray(cur)
        size = ent["size"]
        if len(data) < size:
            data.extend(b"\x00" * (size - len(data)))
        del data[size:]
        for off, delta in ent.get("reloc", []):
            v = int.from_bytes(data[off:off + 4], "little")
            data[off:off + 4] = ((v + delta) & 0xFFFFFFFF).to_bytes(4, "little")
            nrel += 1
        for off, val in ent.get("raw", {}).items():
            data[int(off)] = val
            nraw += 1
        target.write_bytes(bytes(data))
        stamp.write_text(hashlib.sha256(bytes(data)).hexdigest() + "\n")
    print("apply_c_divergence %s: %d bins, %d already patched (skipped), %d pointer relocations, %d raw bytes"
          % (tree, len(patch), nskip, nrel, nraw))


if __name__ == "__main__":
    main()
