# Code emitted as data: the MILK kernel's flash tail, and the siblings' `.byte` escapes

Lane `code-island` of the open-items effort, 2026-10-30.  It answers two of the owner's open items
(`notes/data-semantics-2026-10-29/README.md` at the repository root, "Generic 0", "Left open"), which
turned out to be one problem:

1. KN7000 `func_487B8E34`: the library's func_4C03B514 does `call func_487B8E34, [d2,a2,a3], 0x1c`,
   yet its 301 bytes were a `census: opaque -- unknown-dump` piece of the typed data region, followed by
   more opaque pieces that were call targets (`func_487B8F9B`, `func_487B8F9E`, `func_487B8FA1`) and a
   jump target (`loc_487B8FA4`);
2. `func_4C03B799_Table`, "353 x s16", ran on into code.

Then it makes the fix systematic: a committed probe (`../code-island-probes/code_in_data.py`) lists every
branch target, code-named label, fall-through and code pointer that lands on bytes a tree emits as data,
in all MN10300 trees, and the generators were changed until it finds nothing but the cases listed under
"Left open".

## The island

All four KN7000 program builds keep the same 1,317-byte block between the data region and the library
image the boot copies to 0x4C000000: the MILK kernel's tables and routines that run from the flash, at
their flash address.  The KN6000 / KN6500 hold the same block at the top of their images
(`../../../kn6000/kn6000_manual.sym`: `Str_MILK_MN10300_Ver1_0R1`, `KernelServiceHash`, `KernelRamLayout`,
`KernelParams`, func_4C3F7383 .. func_4C3F779E), where it was already code because their Makefiles give
that range to `gen_image_s.py` as code.  Program 941 (the other builds: "Per build" below):

| CPU (941)  | bytes | name                        | what it is, and the evidence                                                                                                                                                                                             |
|------------|-------|-----------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0x487B8AAC | 24    | `Str_MILK_MN10300_Ver1_0R1` | the kernel's version string and two 0xFF pad bytes                                                                                                                                                                       |
| 0x487B8AC4 | 128   | `KernelServiceHash`         | 16 x {u32 key, case address}: KernelWaitRelease does `mov KernelServiceHash, a1`, probes `(key & 0xF) * 8`, steps `add 8, a0` up to `cmp KernelRamLayout, a0` and jumps through `(4, a0)`; typed `REC_KernelServiceHash` |
| 0x487B8B44 | 24    | `KernelRamLayout`           | 6 RAM addresses; read at +4, +8 (func_4C03CC4B), +0xC (func_4C03CC87) and +0x14 (func_4C03CC4B, KernelStart's stack pointer); +0 and +0x10 have no reader the walk sees                                                  |
| 0x487B8B5C | 28    | `KernelParams`              | 14 u16 = 10, 20, 20, 20, 10, 10, 10, 10, 10, 10, 20, 10, 30, 0; read at +0 (get_tid), +0x10, +0x12 (func_4C03B514), +0x16 (func_4C03B799)                                                                                |
| 0x487B8B78 | 695   | `KernelInit`                | KernelStart's `jmp` target: fills the kernel's RAM tables, creates the task func_4C03B514, calls func_48447F33 (region 1), KernelInitHook and func_4C03DCBF                                                              |
| 0x487B8E2F | 364   | `KernelWaitRelease`         | movm + `add -0x10, sp` prologue, then `KernelWaitRelease_entry` (the old `func_487B8E34`); the 11 cases KernelServiceHash points at are its `loc_` labels                                                                |
| 0x487B8F9B | 3     | `KernelErrorHook`           | `retf 0, 0`; 26 calls, each before a service returns an error (d0 = function code, d1 = a uITRON error code: -0x45 E_CTX, -0x3F E_OBJ, -0x23 E_ID ...)                                                                   |
| 0x487B8F9E | 3     | `KernelErrorHook2`          | `retf 0, 0`; 3 calls, the same arguments                                                                                                                                                                                 |
| 0x487B8FA1 | 3     | `KernelWaitAbortHook`       | `retf 0, 0`; func_4C03B514 calls it with a0 = the TCB, d0 = -0x55 (E_TMOUT); the KN6000's also gets -0x51 (E_DLT)                                                                                                        |
| 0x487B8FA4 | 11    | `KernelStart`               | `mov (KernelRamLayout+20), a3 / mov a3, sp / jmp KernelInit`; jumped to from the reset code (0x48410151) and from func_4C03DD98                                                                                          |
| 0x487B8FAF | 3     | `KernelInitHook`            | `ret 0, 0`, called by KernelInit                                                                                                                                                                                         |
| 0x487B8FB2 | 31    | `func_487B8FB2`             | no traced path enters it: after `ret 0, 0`, it decodes to the library image's first byte and ends in `rets` (clears bits 4..7 of 0x34000118, calls func_4C03DC87_entry); the KN6000's copy is unreached too              |

The 1,113 bytes from KernelInit on are code; the 204 bytes before it stay typed data.  The names are new
in `kn7000_manual.sym` (section "The MILK kernel's flash tail"), each with its evidence; the routine
names are `[INFERENCE]` from what the code does, the table names are the KN6000's.  The siblings' copies
of the routines take the same names (`kn6000_manual.sym`, `kn6500_manual.sym`, `kn2400_manual.sym`,
section "the MILK kernel's tail routines"; the KN2400 also its three tables, which its data region
holds as the KN7000's does).  Found by the same bytes: `KernelStart` is `mov (abs32), a3 / mov a3, sp /
jmp` right after the three `retf 0, 0` hooks, and its `jmp` target is KernelInit; KernelWaitRelease is
the routine that reads KernelServiceHash.

| model  | KernelInit | KernelWaitRelease | hooks (Error, Error2, WaitAbort)   | KernelStart | KernelInitHook | calls of the hooks |
|--------|------------|-------------------|------------------------------------|-------------|----------------|--------------------|
| KN7000 | 0x487B8B78 | 0x487B8E2F        | 0x487B8F9B, 0x487B8F9E, 0x487B8FA1 | 0x487B8FA4  | 0x487B8FAF     | 26, 3, 1           |
| KN6000 | 0x4C3F7383 | 0x4C3F7632        | 0x4C3F778A, 0x4C3F778D, 0x4C3F7790 | 0x4C3F7793  | 0x4C3F779E     | 27, 2, 2           |
| KN6500 | 0x4C380FE3 | 0x4C381292        | 0x4C3813EA, 0x4C3813ED, 0x4C3813F0 | 0x4C3813F3  | 0x4C3813FE     | 27, 2, 2           |
| KN2400 | 0x48728165 | 0x4872841C        | 0x48728588, 0x4872858B, 0x4872858E | 0x48728591  | 0x4872859C     | 25, 3, 1           |

### Per build

The block sits at the same distance from the library image in every build (the code is the same, the
addresses differ): the tail code starts at `LIB_FILE_BASE - 0x459`.

| build | library image (file) | tail code (file)   | KernelInit | KernelWaitRelease | KernelStart |
|-------|----------------------|--------------------|------------|-------------------|-------------|
| 941   | 0x3B8FD1             | 0x3B8B78..0x3B8FD1 | 0x487B8B78 | 0x487B8E2F        | 0x487B8FA4  |
| 942   | 0x3BA785             | 0x3BA32C..0x3BA785 | 0x487BA32C | 0x487BA5E3        | 0x487BA758  |
| 935   | 0x3B8F6D             | 0x3B8B14..0x3B8F6D | 0x487B8B14 | 0x487B8DCB        | 0x487B8F40  |
| 893   | 0x3B76B1             | 0x3B7258..0x3B76B1 | 0x487B7258 | 0x487B750F        | 0x487B7684  |

### `func_4C03B799_Table`'s true extent

func_4C03B799 (library_01.s) reads it four times, always as `movhu (func_4C03B799_Table), dN`: no index
register, no offset.  It can reach exactly one halfword, `KernelParams + 0x16` (value 10).  Its next two
halfwords (30, 0) are `KernelParams + 0x18` / `+ 0x1A`, which no instruction the walk sees reads (the
KN6000's KernelParams has the same 14 words, read at the same four offsets).  Everything from [3] on was
code: entries [3]..[352] are the 695 bytes of KernelInit and the 5-byte prologue of KernelWaitRelease
(700 bytes, up to the old `func_487B8E34`).  The 20536 = 0x5038 halves the owner spotted are the high
halves of the `mov 0x5038xxxx, aN` immediates of KernelInit's table fills.  `func_4C03B514_Table` next
door (2 x s16, read once at +0) is the same kind of piece: two halfwords of KernelParams.  The table now
reads `3 x s16, 0..30` (reader_tables() still runs a fixed-address read up to the next label; the line
says which index is read).

## Why the split missed it

`gen_program_s.py` knew two code ranges: code region 1 (file 0x80..R1_END) and the library image
(LIB_FILE_BASE..IMAGE_END), whose start is where the boot's copy descriptor begins (the copied image).
Everything between was the data region, handed to `gen_data_s.py`.  The kernel's flash tail is not part
of the copy, so it fell in the data region, right before the library image.  There:

- `gen_data_s.py` labelled the call and jump targets (`func_487B8E34`, `loc_487B8FA4`) and split the bytes
  there, but no instruction LOADS from them, so `data_readers.py` found no reader and the pieces were
  declared `opaque -- unknown-dump` ("a typed pointer or a code immediate holds their address, but
  nothing is read through it");
- `reader_tables()` types a fixed-address `movhu` read as a table that runs to the next label or typed
  item.  func_4C03B799's read was the last item before the code, and the next label was the call target
  `func_487B8E34`, 706 bytes on: hence 353 x s16.

The siblings had the opposite gap: their code ranges were right (Makefile `--code`), but
`gen_image_s.py` wrote 278 instructions it could not re-encode as `.byte` escapes (code emitted as
data), and branch targets landed on them (KN6000: `KernelIntDispatch`, the interrupt handler the reset
code jumps to).

## The fix (generators)

| tool                    | change                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
|-------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `gen_program_s.py`      | `TAIL_CODE` / `find_tail_code()`: every call / jump target of the converted code that lands in the data region is walked by control flow (branches followed, calls become functions, a `call` target behind a register-save prologue starts at the prologue); the unreached runs up to the library image must decode into code that ends in a return or jump; the result is emitted as functions (`src/<build>/program/tail_code.s`) between the data include and the library, and its range is written to `<data dir>/tail_code.txt`.  Code the walk finds anywhere but the end of the data region stops the generator with a message.  `disasm_function(partial=True)` decodes up to the first bad byte. |
| `gen_data_s.py`         | reads `tail_code.txt`: the data region ends where the tail code starts, addresses in it are code (`in_code`: a table pointing there names `loc_` labels, which `code_refs.txt` hands back to gen_program_s), and the data names a previous build gave those bytes (`data_*`) are dropped                                                                                                                                                                                                                                                                                                                                                                                                                   |
| `gen_image_s.py`        | spells the encodings the linker left long as instructions (`call T:32`, `mov 0x30:32, d0`, gen_program_s.reencode()), accepts movm's `other*` registers, and rebuilds the registers of FC 00-7F loads from (d32, aN) that unidasm swaps                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| `kn7000_manual.sym`     | the names above; `make symbols-sp7001 symbols-935 symbols-893` ports them into `kn7000_sp7001_manual.sym`, `kn7000_b935_manual.sym`, `kn7000_b893_manual.sym`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `<sibling>_manual.sym`  | the same routine names for the KN6000, KN6500 and KN2400 copies (and the KN2400's three tables)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `gen_program_s.py` docs | FUNC_DOC notes for KernelStart, KernelInit, KernelWaitRelease and the four hooks                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |

Regenerating, in this order (in a worktree, pass the absolute Makefile overrides and UNIDASM=):

1. `make -C kn6000 program-src`, the same for `kn6500` and `hdsx3`, and `make -C kn2400 data-and-code-src`
   (the KN2400's table names change its data labels);
2. `make -C kn7000 symbols-sp7001 symbols-935 symbols-893` into a scratch `SYMOUT=`: only the three
   `kn7000_*_manual.sym` change; copy those;
3. `python3 tools/gen_program_s.py --profile <b>` for 941, sp7001, b935 and b893 (each writes its
   `tail_code.txt`), then `make -C kn7000 data-and-code-src` (`tools/regen_data_and_code.sh`) to the
   fixpoint, then the builds (`make -C kn7000 verify verify-sp7001 verify-935 verify-893`).

## Probe figures

`python3 kn7000/notes/code-island-probes/code_in_data.py` (README there), distinct addresses per kind.
"Before" is the lane's base e611d4eaf.

PROBE-TABLE

## Census figures

CENSUS-TABLE

## Left open

- **Text typed as pointers** (`P`, mid-instruction): three struct fields hold printable text that
  happens to read as a code address, e.g. `REC_StartFeatureDemo_Table_p0`'s `p28=loc_48533C3E`, which is
  the four characters `"><SH"` of the feature demo's XML script (90 records); `loc_48474952` ("RIGH"),
  `loc_48535550`; the KN2400's `loc_48717F40`.  Not code in data: data_structs.py takes a field for a
  pointer when every record's word there is an address, and the generators then invent an `.equ
  loc_<ADDR>` for a target inside an instruction.  A fix belongs in the struct typer (a field inside a run
  of text is text).
- **func_487B8FB2** (and the KN6000's twin after func_4C3F779E): what enters it.  It is code by its
  bytes, not by any traced path [INFERENCE: an interrupt entry written to a vector at run time].
- **Pointer-walk bounds in the data typer**: with a rule "an address the code compares a stepped pointer
  with (`cmp Addr, aN`) ends the array", KN7000 tables end at their walker's bound instead of running into
  the small tables after them (a trial run on 941, not kept: MainMmmControl_Table 260 -> 256 entries,
  func_485371AC_Table 12 -> 6, func_4850DF34_Table 7 -> 5, with the FE_* tables after them typed on their
  own).  Left out of this lane because it changes many regenerated lines that have nothing to do with code
  islands; KernelServiceHash's end comes from the `KernelRamLayout` name instead.  Worth a lane of its own.

## Website page draft

(For `kn7000-data-region.md` / `rom-reconstruction.md` in technics-docs, to be added by the website sync.)

> **The kernel's flash tail.**  The KN7000's program flash holds the MILK real-time kernel as an image
> the boot copies to 0x4C000000 and runs there.  A small part of the kernel is not copied: 1,317 bytes
> right before that image, run from the flash itself.  They hold the kernel's version string ("MILK
> MN10300 Ver1.0R1"), the table that sends a waiting task to the routine that takes it off its wait
> queue, the RAM layout and parameter words the kernel reads, and 1,113 bytes of code: the kernel's
> start (`KernelStart`, which the reset code jumps to), its start-up routine (`KernelInit`), the
> wait-release routine and four empty hooks the kernel calls on errors and timeouts.  Until 2026-10-30
> the disassembly took that code for data, because it sits between the data and the copied image; the
> generator now finds it by following the calls and jumps that land there, in all four program builds.
> The KN6000 and KN6500 keep the same block at the top of their images.
