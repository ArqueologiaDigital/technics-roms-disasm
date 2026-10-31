#!/usr/bin/env python3
"""apply_c_divergence.py TREE -- patch a ported main-program tree's C data bins.

QUESTION ANSWERED: which bytes of TREE's compiled C data (TREE/maincpu/includes/generated/*.bin)
does the ROM need different from what the C, shared with the newer tree it was ported from,
compiles to -- and are they applied exactly once?

The ported trees (v7 from v9/v10's C, v6 from v7, v5 from v6; scripts/converters/port_maincpu_version.py)
keep the C data sources of the tree they were ported from, so a C file compiles to the NEWER
firmware's bytes.  TREE/maincpu/includes/TREE_c_divergence.json records, per bin, where the older ROM
differs:

    "reloc": [[offset, delta], ...]   a 32-bit little-endian pointer moved by delta
    "raw":   {offset: byte, ...}      any other byte
    "size":  bytes of the bin the build uses

It is written by `port_maincpu_version.py --cdiv` (v6, v5) and regenerate_v7_c_divergence.py (v7),
which compare the compiled bins with the bytes the ported source places there.  A missing json means
nothing to patch.

APPLIED EXACTLY ONCE.  A relocation is relative (v += delta) and the bin is patched in place, so
patching a bin that make did not recompile would apply delta twice (measured 2026-08-23:
style_ui_screendata_ctlonly.bin drifted -42 per build).  It cannot be made absolute without reading
the ROM, which the poison rule forbids.  So beside each patched bin the script writes a stamp,
X.bin.patched, holding two SHA-256 values: of the bin it wrote, and of the json entry it applied.
On the next run:

    stamp valid, bin hash = stamp      the bin is the one this script wrote: skip it
    stamp valid, bin hash differs      make recompiled the bin since: patch it
    no stamp / old stamp / entry changed
                                       whether the bin is fresh is unknown: delete it, let make
                                       compile it again, then patch it

So a missing stamp only costs a recompile, never a double patch.  The stamps are build state, not
source: git-ignored since 2026-10-31 (lane media-cleanup; until then 80 of them were tracked, and
untracking them is safe precisely because of the third row).

    python3 scripts/build/apply_c_divergence.py v6
"""
import hashlib
import json
import os
import pathlib
import subprocess
import sys

REPO = pathlib.Path(__file__).resolve().parent.parent.parent


def sha(b):
    return hashlib.sha256(b).hexdigest()


def entry_hash(ent):
    return sha(json.dumps(ent, sort_keys=True, separators=(",", ":")).encode())


def patched(cur, ent):
    data = bytearray(cur)
    size = ent["size"]
    if len(data) < size:
        data.extend(b"\x00" * (size - len(data)))
    del data[size:]
    for off, delta in ent.get("reloc", []):
        v = int.from_bytes(data[off:off + 4], "little")
        data[off:off + 4] = ((v + delta) & 0xFFFFFFFF).to_bytes(4, "little")
    for off, val in ent.get("raw", {}).items():
        data[int(off)] = val
    return bytes(data)


def stamp_of(target):
    return target.with_suffix(target.suffix + ".patched")


def remake(targets):
    """Compile `targets` again from their C (they were deleted first), through the same make."""
    rel = [str(t.relative_to(REPO)) for t in targets]
    cmd = [os.environ.get("MAKE", "make"), "-s"] + rel
    r = subprocess.run(cmd, cwd=REPO)
    if r.returncode != 0:
        sys.exit("apply_c_divergence: `%s` failed" % " ".join(cmd))
    missing = [t for t in rel if not (REPO / t).exists()]
    if missing:
        sys.exit("apply_c_divergence: make did not rebuild %s" % missing)


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
    todo, doubt, nskip = [], [], 0
    for name, ent in sorted(patch.items()):
        target = gen / name
        if not target.exists():
            sys.exit("apply_c_divergence: %s missing -- build the C bins first" % target)
        st = stamp_of(target).read_text().split() if stamp_of(target).exists() else []
        if len(st) == 2 and st[1] == entry_hash(ent):
            if sha(target.read_bytes()) == st[0]:
                nskip += 1
            else:
                todo.append(name)
        else:
            doubt.append(name)
    if doubt:
        for name in doubt:
            stamp_of(gen / name).unlink(missing_ok=True)
            (gen / name).unlink()
        remake([gen / n for n in doubt])
        todo += doubt
    nrel = nraw = 0
    for name in sorted(todo):
        ent = patch[name]
        target = gen / name
        data = patched(target.read_bytes(), ent)
        target.write_bytes(data)
        stamp_of(target).write_text("%s %s\n" % (sha(data), entry_hash(ent)))
        nrel += len(ent.get("reloc", []))
        nraw += len(ent.get("raw", {}))
    print("apply_c_divergence %s: %d bins, %d already patched (skipped), %d recompiled first (no valid stamp), "
          "%d patched: %d pointer relocations, %d raw bytes"
          % (tree, len(patch), nskip, len(doubt), len(todo), nrel, nraw))


if __name__ == "__main__":
    main()
