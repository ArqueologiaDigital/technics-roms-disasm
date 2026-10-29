# The rest of the KN7000 program data region: readers, records, pictures

Lane kn7000-data-rest of the data-semantics effort (`notes/data-semantics-2026-10-29/README.md` at
the repository root), 2026-10-29.  It continues lane gui-kn7000 (`../gui-data-region/README.md`):
that lane typed program 941's GUI, demo songs, built-in style, reader tables, sparse maps and panel
memories, and left about 793 KB per build generic.  This lane types what is left from the code that
reads it.

(Status, numbers and the open list: see "Census" and "What remains" below; they are filled in as
the work lands.)

## The instrument: who reads each byte (`tools/data_readers.py`)

The converted code (`src/<build>/*.s`, tools/gen_program_s.py's output) is walked function by
function with a symbolic value per register:

| value      | meaning                                                                            |
|------------|------------------------------------------------------------------------------------|
| `C(c)`     | a constant                                                                         |
| `A(x)`     | the address x (a data label, `Label+N`, or a number)                               |
| `S(s)`     | an unknown index times s (`mul` / `mulu` by a constant, `asl`, `asl2`, `add r, r`) |
| `I(b,s,o)` | b + index * s + o: field o of an array of s-byte records at b                      |
| `P(key,o)` | a pointer loaded from the 32-bit field `key`, plus o                               |
| `D(key,o)` | a function's own d0 / d1 argument: a pointer if it is dereferenced, else an index  |

Every load, store and call argument through such a register is an access: its key (a fixed address,
field o of the records at b with stride s, or field o of what a pointer field points at), width,
signedness (an `extb` / `exth` of the loaded register right after the load) and the instruction.  A
function's accesses through its own arguments (a0, a1, d0, d1) are carried into every caller that
passes a data address in them (`resolve_params`), so a record handed to a helper is typed by what the
helper reads.  [INFERENCE] the walk is linear: a label after an unconditional jump starts with no
knowledge, any other label keeps what falls into it, so a value that differs on another path is not
seen; every structure below is also checked against the bytes.

## Struct arrays (`tools/data_structs.py`, gen_data_s `struct_arrays`)

An access through `base + index * stride + offset` makes an array of `stride`-byte records at base:

- the field is the offset modulo the stride (a reader of element i - 1 or a 1-based index adds or
  subtracts the stride); bases less than one stride apart (the code added a field offset first) or a
  whole number of strides apart are one array;
- a field's width is the one most of its loads use; a second, smaller index (`base + i * s + j * t`)
  is an array of t-byte elements inside the record; a field whose address goes to strncpy / memcpy /
  strcpy / strcmp is text;
- bytes no instruction was seen to read stay in the record, as a pointer where every record holds an
  address or 0, else as bytes (`x<off>`), so the record is whole;
- the array runs from its base while its records are free, its dereferenced pointer fields hold
  addresses, and no other array base, symbol-file name or typed item is reached.

Each record kind is one macro in `<data dir>/data_structs.inc`; its header lists every field, its type
and the first readers (function, address, instruction).  A one-field array is a `tab_uN` table, as
the reader tables of lane gui-kn7000.

## Records a pointer leads to (gen_data_s `ptr_records`)

When the code loads a pointer from a typed field or table entry and reads through it, the targets of
that field (every record's value) are records too: their fields are the offsets those reads use.
Targets reached through the same fields are one kind.  When a kind's targets lie a constant distance
apart (and nothing else lies between), that distance is the record size; otherwise a record ends at
its last read field.  Pointers in those records are followed the same way.  Example: StyleRecordTable
(1,085 records of 24 bytes) points with its field +0 at 1,037 records of 160 bytes, each a built-in
style's panel settings.

## The other passes this lane added (gen_data_s, profiles with `structs=True`)

| pass             | what it types                                                                                      | evidence                                                             |
|------------------|----------------------------------------------------------------------------------------------------|----------------------------------------------------------------------|
| `dsp_pool`       | the 80 effects-DSP download records, block by block, PM words with their SHARC instruction         | tools/gen_dsp_records.py's format; names from dsp/records.tsv        |
| `bitmaps`        | the bitmap resources (procs answering MT_GetBitmapData / Width / Height / Palette / GetBitCount)   | the shared pass of lane sib-kn6000, now also for unlabelled procs    |
| `drawn_bitmaps`  | pixels handed to DrawBitmapSP / SPFast / SPFast16 / SPFast4 / SP2 with a constant size             | the call's a1 / d0 / d1 (annotations/gfx_draw.ann gives each format) |
| `string_arrays`  | fixed-width NUL-terminated value names ("  0.1   ", "   10 ms")                                    | the shared pass; at least 4 characters for the KN7000                |
| `message_tables` | `{u32 key, code address}` runs: dispatch tables                                                    | [INFERENCE] from their shape; a MILK id key is spelled by its name   |
| `variables`      | what an instruction reads or writes at a fixed address: a variable, or a table up to the next name | the access, cited                                                    |

Bitmaps are indexed PNGs in `<data dir>/media/`, built by `tools/table_png.py` into
`build/bitmaps/<build>/` (`pk D W H`, rows padded to an even byte count; `p2 W H`).  A bitmap
resource with no MT_GetBitCount answer is taken as 4 bits a pixel only when its pixels end
exactly at the next label [INFERENCE: VwUserBitmapProc draws any depth but 1 and 8 with
DrawBitmapSPFast16].

## What is declared opaque, and why

Bytes no pass could type are an `.incbin_range` of the reference.  When no load, store, base
(`mov Addr, rN` / `add Addr, rN`) or call argument of the converted code lands in them, the
line above says so: `census: opaque -- unknown-dump: <n> bytes of <what> in <where>; no
instruction reads them ...`, and whether a typed pointer or a code immediate still holds their
address.  That is the reader search the brief asks for (tools/data_readers.py over all the
converted code), and its limits are the walk's: a pointer computed in a way the walk does not
follow is not seen.  Bytes that some instruction does read but no pass could type stay generic,
and are listed under "What remains".

## The symbol files (coordinator items, same session)

- `symbols-sp7001` was a phony inside a grouped target, so every `verify-sp7001` re-ran it.
- More generally no rule has a committed symbol file as its target any more (kn7000 and the four
  siblings): `make symbols` and its per-build variants regenerate them on purpose, and `make
  symbols-check` compares the generator's output with them (in the siblings' gates).
- `gen_symbols.py` pairs a reflection table's names with its code array start-aligned by default
  and stops its walk at name lists; with that it reproduces every committed symbol file.  The
  committed SP7001 plug-in pairing (ApTestProc = 0x483E850F) is the right one: the name array at
  0x483F9130 holds 25 names and the code run before its NUL 25 entries (0x483F90C8..0x483F9128).
- 935 and 893 still called 941's get_tid routine ter_tsk (941's names were corrected by 612f5881c
  and never re-ported); `make symbols-935 symbols-893` re-ported them with those programs.

## Website page draft

(For `kn7000-data-region.md` in technics-docs, to be added by the website sync.)

> **What the KN7000 program's data is, from the code that reads it.**  Every table the firmware
> indexes is now a list of records in the disassembly, one macro per kind of record, whose header
> says which routine reads which field and how (`movhu (0xa, a0), d1`: a 16-bit field at +10).
> The kinds are found by following the code: a base address, an index times a record size, a field
> offset.  Pointers in those records lead to further records, typed the same way.
