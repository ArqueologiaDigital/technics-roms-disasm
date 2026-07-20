# "TCMP" container synthesis — the experiment, and its honest verdict

2026-07-20. Offline experiment set up by the previous CONVERT tick: now that
both the READERS and the WRITERS of the Technics "TCMP" style container are
re-assemblable source, build one from scratch in Python, run it past the
firmware's own verifiers, and answer whether a synthetic container could stand
in for the built-in style source that `StyleResourceWindowProbe` never finds.

Tool: `tools/tcmp_build.py`. `python3 tools/tcmp_build.py --self-test`.

## Result 1 — the synthetic container passes every firmware verifier

Three verifiers were ported to Python instruction-by-instruction from the
converted MN10300 assembly in `src/program.s`:

| firmware routine | address | port |
| --- | --- | --- |
| `MemStyleAreaSignatureVerify` | 0x48435749 | `verify_signature` |
| `MemStyleAreaChecksumVerify` (+ `SumU16BE` 0x484403A5) | 0x484356BD | `verify_checksum` |
| `MemStyleAreaStreamsVerify` (+ `MemStyleVarBarCount` 0x4843C445, `RhySysexLen` 0x484403CD, `RhyEventLenByStatus` 0x484403D5) | 0x4843579E | `verify_streams` |
| `MemStyleAreaValidate` (sig + checksum + streams) | 0x4843B1B5 | `mem_style_area_validate` |
| `MemStyleAreaValidateOrInit` (sig + streams) | 0x4843B1F6 | `mem_style_area_validate_or_init` |

**The oracle passes.** Run against the real `FactoryMemStyleContainer`
0x48035D08 (table ROM segment 2, 0xA96C bytes, N=3), all five return +1 —
including the checksum, which reproduces the stored 0xCC00 exactly over
0x70..0x3670. That is the evidence that the port is faithful and not merely
permissive.

**The synthetic passes the same five.** `build_container(n_styles=3)` emits a
0x391C-byte container (checksum 0x0B95, allocator top 0x00391C) that returns
+1 from all five.

Negative controls (the verifiers are not vacuous):

| mutation | sig | cksum | streams |
| --- | --- | --- | --- |
| control | +1 | +1 | +1 |
| signature byte corrupted | **-3** | +1 | +1 |
| one record byte flipped | +1 | **-1** | **-3** |
| a stream's leading variation index wrong | +1 | +1 | **-3** |
| a 0xF4 bar marker removed | +1 | +1 | **-3** |
| one byte of tail slack after the last stream | **-3** | +1 | +1 |
| `rec[0x11]` meter field changed | +1 | **-1** | **-3** |

### Structural diff, synthetic vs factory

Byte-identical: the whole 0x70 header except the two fields that *must* differ
(checksum +0x06, allocator top +0x13) — signature, sub-signature, checksum
descriptor 0x70/0x1B00, +0x0E, container length 0x025800, style count 3, the
fixed 0x18-byte tail and the 0x40 bytes of 0x20 padding all match exactly.
All three style records' 20-entry variation-index tables at +0x50 match
(0..0x13, 0x14..0x27, 0x28..0x3B). Across the 60 variation records the pair
bit `rec[3]&0x10` agrees 60/60 and the per-part bytes `rec[4..0x0B]` agree
60/60 — i.e. the `MemStyleVarRecInit` slot rules were reproduced correctly.

Legitimately different: the style names (synthetic = the ROM template's
`"    clear    "`, factory = `" Easy 8 Beat "` / `"Easy 16 Beat "` /
`" Easy Swing  "`), the bar field `rec[0x10]` (38/60 agree; the factory holds
real bar counts, the synthetic holds the 0/1 the empty-pattern rule produces),
and the heap (synthetic 0x2AC bytes of empty bar-marker streams vs the
factory's 0x72F9 bytes of real patterns).

One correction to `kn7000_manual.sym` fell out of this: the style record's two
u16 fields (0x0044 0x0044 in the factory container, 0x0010 0x0023 in the ROM
template) are at **+0x70**, not +0x68. Fixed in the sym file.

## Result 2 — ★ NEGATIVE: this cannot fix the built-in style names

**A synthetic "TCMP" container cannot stand in for the built-in style source.
The two are different file formats and no code path converts between them.**

The built-in style-name source is opened by `StyleBuiltinNameTableInit`
0x484332F9, whose window comes from `StyleResourceWindowProbe` 0x4843D6D7. Read
straight off the converted assembly, it requires:

```
  +0x00  "Technics Rhythms"   16-byte ASCII signature (strncmp, string 0x4872980C)
  +0x18  u24BE offset -> block whose u16BE at +2 is the style COUNT   -> 0x50034B74
  +0x1B  u24BE offset -> the u16 name index table                     -> 0x50034B7C
  +0x1E  u24BE offset -> the 3-byte offset sub-table                  -> 0x50034B80
  +0x21  u24BE offset -> the secondary sub-table                      -> 0x50034B84
  +0x24  u24BE offset -> the fallback name string                     -> 0x50034B88
```

A "TCMP" container has none of that. Its first 16 bytes are `"TCMP"`, a 00 00
sub-signature, a u16BE checksum and a checksum descriptor; +0x18 is the start
of a fixed constant tail, not a u24BE directory. Feeding one to
`StyleBuiltinNameTableInit` fails at the very first `strncmp` and returns -3,
at which point `StyleNameModuleBoot` 0x4843385E installs the program-ROM stub
0x48729988 — which is exactly the "8 Beat 1" fallback. Conversely
`MemStyleAreaSignatureVerify` rejects a "Technics Rhythms" resource at its
first `strncmp` too. Neither format is reachable from the other's reader.

The formats are not merely different, they describe different *things*: TCMP is
a 3-style x 20-variation **pattern** container with an event-stream heap and a
bump allocator; the "Technics Rhythms" resource is a **name/offset directory**
for 0xDD = 221 built-in styles. Confirmation from the dumps: the truncated
in-flash copy at 0x483E828C (`TableRomStyleResourcePtr` 0x4843D7A8, table ROM
directory entry `*(0x4800014C)`) carries the signature, declares count 0xDD,
and its surviving sub-table offsets run up to +0x3E5D75 (~4.08 MB) — a whole
flash device, not a 0x25800 RAM area. The program-ROM stub declares count 1 and
its fallback string at +0x11BA is literally `"  8 Beat 1    "`.

This matches the fix that actually shipped: the "8 Beat 1" bug was resolved by
installing a synthetic **"Technics Rhythms" name resource** at 0x54E00000 (52
real names recovered, 168 awaiting a Phase C dump), not by any container work.
See `kn7000_mame/notes/sequenced-playback-and-style-data-rootcause.md` §2a-bis.

## What the tool is good for anyway

Generating valid MEMORY-style containers for testing (`-o file.bin -n 3`,
optionally `--pad` to the full 0x25800 area), generating the N=1 CUSTOM-export
shape (`-n 1`, per `MemStyleExportToCustom` 0x4843DEC7), and documenting the
container format executably — the builder *is* the recipe, and `--self-test`
proves the recipe against real bytes on every run. `--verify-templates` checks
the six embedded ROM templates (header 0x487312E8, style record 0x48731358,
variation record 0x487313D8, stream prototypes 0x487314B8 / 0x487314C5, pair
table 0x485B6D74) against `baserom/kn7000_program.rom`.

Note that the firmware's stream verifier hard-codes the N=3 MEMORY geometry
(0x3C variations at 0x1F0 + var*0xE0, via `MemStyleVarRecPtr` 0x484355F8), so
only an N=3 container is checkable by the real routines; the N=1 CUSTOM shape
is validated against `MemStyleExportToCustom`'s written contract instead
(checksum descriptor zeroed, +0x10 = the used size, allocator top 0x1354).
