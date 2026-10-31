# The MN10300 typer: pointers that land where a pointer can, arrays that end where their loop does

Lane `mn10300-typer` of the open-items effort, 2026-10-31.  It takes the items the 2026-10-30 lanes left
open in `../callee-walk/README.md` and `../code-island/README.md` ("Left open"): text typed as pointers,
the array-end rule, four extensions of the reader walk, and what enters `func_487B8FB2`.  The machinery is
in `kn7000/tools/` (`gen_data_s.py`, `data_structs.py`, `data_readers.py`, `gen_program_s.py` and the new
`mn10300_insn_len.py`) and applies to every MN10300 tree: the KN7000 program builds 941, 942 (sp7001), 935
and 893, the KN6000, KN6500, KN2400 and the HD-SX3 plug-in.  Probes: `../mn10300-typer-probes/` (README
there).

Each rule is a key of `gen_data_s.FEATURES`, on by default; the environment variable `GEN_DATA_S_OFF`
(a comma list) turns rules off, which is how `typer_stats.py` measures each one against the generator
as it was.

| rule           | item | what it does                                                                                                                                                                                  |
|----------------|------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ptr_starts`   | 1    | a 32-bit word is a pointer into code only when it is the first byte of an instruction; otherwise it is text or a number, as the readers say                                                  |
| `array_end`    | 2    | a pointer loop proven to stop at an address (`cmp End, aN` and a branch back) ends the array it walks                                                                                         |
| `mem_ptrs`     | 3a   | data addresses stored to a memory slot (a RAM global, a zero-initialised data word, a field of a record) and loaded back elsewhere                                                            |
| `loop_index`   | 3b   | a constant in a data register a loop writes is the loop's induction variable at its head; a pointer plus a scaled index keeps the scale                                                      |
| `step_arrays`  | 3c   | a block a routine steps through (or indexes) by s >= 2 is an array of s-byte records, counted by the loop when it is proven, else by the block's extent                                      |
| `deep_records` | 3d   | a loop that walks records through their own field types every record of the chain; blocks a record's pointer field leads to that the code copies whole are typed copies (all trees now) |

## 1. Pointer fields that hold text (`ptr_starts`)

`data_structs.layout()` kept a 32-bit field as a pointer when every record held an address or 0 there, and
`gen_data_s.is_addr()` called any value in code region 1 an address.  Uppercase text often reads as one:
`"><SH"` = 0x48533C3E (p28 of `REC_StartFeatureDemo_Table_p0`, the feature demo's XML script, 90 records),
`"RIGH"` = 0x48474952 (MidiPmemOutLGrid's "RIGHT 1" / "RIGHT 2"), `"PUSH"` = 0x48535550 ("PUSH EXIT BUTTON"),
and the KN2400's `ptrs_48501B38` second word.  gen_program_s.py / gen_image_s.py then declared an `.equ
loc_<ADDR>` inside an instruction for each.

Where a pointer into code can land is the first byte of an instruction.  `tools/mn10300_insn_len.py`
ports the KN7000 MAME driver's length decoder (`mn10300_insn_length.h`, checked there against unidasm over
550,328 instructions) and decodes forward from anchors the converted code gives: its function headers
(`# Name  (CPU 0x...)`), `func_<ADDR>` / `*_entry` names and a sibling's `<entry>_L<hex>` branch labels
(never `loc_<ADDR>`, which an `.equ` may have put inside an instruction).  `gen_data_s.code_ptr_ok()` asks
it of every code value before `is_addr()`, the pointer-table pass (`typed_refs()`), the message tables and
`pointerish()` (the guard that keeps a string from being taken when its words look like addresses) accept
it.  RAM, the host program and data addresses are never judged by it.

`insn_starts_check.py` compares the oracle with what kn7asm assembles, byte by byte (the lane's base,
f4045a81c):

| tree          | instruction bytes | agree     | disagree | undecided (before the first anchor) |
|---------------|-------------------|-----------|----------|-------------------------------------|
| kn7000-941    | 1,850,485         | 1,850,470 | 0        | 15                                  |
| kn7000-sp7001 | 1,853,070         | 1,853,055 | 0        | 15                                  |
| kn7000-b935   | 1,850,421         | 1,850,408 | 0        | 13                                  |
| kn7000-b893   | 1,845,605         | 1,845,592 | 0        | 13                                  |
| kn6000        | 1,544,492         | 1,544,474 | 0        | 18                                  |
| kn6500        | 1,546,542         | 1,546,524 | 0        | 18                                  |
| kn2400        | 1,778,472         | 1,778,452 | 0        | 20                                  |
| hdsx3         | 253,526           | 253,524   | 0        | 2                                   |

What the fields became: `REC_StartFeatureDemo_Table_p0` is `f0, f1` (LibStrlen's two reads) and one
1,256-byte text field; "RIGHT 1", "RIGHT 2", "PUSH EXIT BUTTON", "_TT_SEPITCH", "BRIGHTNESS", "SLIDESHOW",
"RHYTHM" (and the KN2400's "MD_HSS", "TT_HELP" ...) are strings again; the pointer tables before them end
one word earlier.

## 2. The array-end rule (`array_end`)

`data_readers.Reader.loop_bound()`: at `cmp End, aN` (End a data address, as a label or a number) followed
by a branch back to a label above, or the Lcc of a setlb loop, taken while aN < End (bcs / blt / bne and
lcs / llt / lne), with aN holding data address B at the loop head and B + s at the compare (the walk is
linear, so it knows aN only when nothing but constants stepped it), and End - B a whole number >= 2 of s:
a `("bound", B)` access.  `gen_data_s.loop_end()` applies it in `struct_arrays()`, the pass that runs a
stepped or indexed array on while its records are free: the array whose record boundary B is ends at End,
and the table header cites the compare (`...; ends at +20, where func_4850DF34 0x4850DF34's loop stops
(`cmp func_4850DF34_Table+20, a2`)`).  Only bottom-tested loops count: a loop that compares before its
step (`cmp End, aN` / exit / `bra` back) does not show the step at the compare.  Bounds found: 40 in
build 941 (`MainMmmControl_Table` 260 -> 256 entries; its +1024 / +1028 are `MainMmmControl`'s two
variables), 15 tables shortened.

The churn: `--only array_end` on 941 changes 311 lines of the generated data sources (data_NN.s,
data_structs.inc, labels.sym), and gen_program_s.py then respells the code that names the bytes after a
shortened table: `movhu (func_4850DF34_Table+20), d0` becomes `movhu (FE_CmpMDelFstMeas_Table), d0`.  Those
are not unrelated lines: what followed each table was the `FE_*` routines' own one-field tables (`2 x u16,
1..65535`, a menu field's min / max, read by `FE_CmpMDelFstMeas` ...), which the table had swallowed.  The
trial of 2026-10-30 changed more because it bounded every array whose base a compare named, not only the
array a proven loop walks.

## 3. The callee walk

**(a) Memory slots (`mem_ptrs`).**  In the collecting walks, a `mov aN, (slot)` records what is stored:
data addresses (a T set), NULL, or the storing function's own parameter, which `memory_slots()` resolves to
the data addresses its callers pass in it [INFERENCE: calls that pass something else are not counted
against it]; a byte / half-word store or an unknown value spoils the slot.  Slots: a fixed address
(`(0x500A1CF0)`, `(Label)`, a constant register), field N of a record whose address was loaded from a slot
(an "M" value only this rule follows), field N of the block a parameter points at (a store to each block
the callers pass), and field N of the records a pointer field leads to.  A load from a RAM slot gives a T
value; a field the walk already keys (a data word, a pointer field's field) gets the stored addresses as
more targets (`gen_data_s.stored_targets()`, which also matches one field reached by two spellings of its
path: `func_484288AC_Table[i].p52` and `func_484288AC_Table+52`).  Found in 941: 5 slots (two of inflate's
state globals, `StyleBuiltinNameTableInit`'s and `TechnicsPadsResourceParse`'s, and `SetApTimer`'s timer
message field, 12 messages).  It types no new byte in the KN7000 builds: the message field is read only by
`ApTimer`, which hands it to `ProcCall` (a dispatch through a function pointer the walk does not follow).

**(b) Loop counters (`loop_index`).**  `loop_scan()` finds each loop (a branch back to a label of the same
stretch of code, or an Lcc to its setlb) and the registers its body writes; at the head, `loop_head()`
replaces a constant c in such a data register by an unknown index -- `S(1)` with start c, so the first
element the loop reaches stays at its offset (DrawBitmapSPFast16_Impl's palette index runs 0x20..0x2F and
is read at index * 4 - 0x80) -- and drops a bound an earlier loop's `cmp` gave the register.  A pointer plus
a scaled index keeps the scale (the access's `bound`).  `loop_count()`: `cmp N, dR` before the branch back,
dR = c at the head and one `inc dR` in the body: the loop runs N - c times.  Before, the walk took the
counter's first value as a constant, so such a loop read "one field at +0" (or at +c * s).

**(c) Stepped and indexed arrays (`step_arrays`).**  `gen_data_s.arg_array()`: a block a routine is handed
and steps through by one s >= 2 (`param_steps`), or reads at an index of scale s >= 2, is an array of s-byte
records; its fields are the reads at their offsets modulo s.  The count: the loop's (`param_count`: a
counter compared with a constant, or `cmp aM, aN` within the block), else the records free up to the next
address anything names [INFERENCE: the block's extent].  E.g. `DiskDriveCtrlHandler_ArgA0_0..7`,
`DrawBitmapSPFast4_ArgSp24_*` (a palette, 4-byte records).

**(d) Recursive structures (`deep_records`).**  `loop_close()`: an address register holding P(K) at a loop
head and the pointer loaded from field f of it at the branch back walks a chain through f; gen_data_s's
`chain_closure()` makes every record the chain reaches (visited once, at most 4,096) a target of kind K.
In the KN7000 that is the voice directory's five hash tables (`VoiceDirRemapFind`, `VoiceDirClassFind`,
`VoiceDirIndexFind`, `VoiceDirRefFind`, `VoiceDirPartRefFind`: `a2 = Table[hash]; while (a2) { ...; a2 =
*a2 }`), 1,222 records, and Malloc / Free's free list (in RAM: nothing to type).  `copied_blocks()` (a block
the code memcpy's / memcmp's with a constant length) follows pointer fields of typed records and now runs
for the siblings too: the KN2400's 12-byte blocks the switch descriptors' `p8` leads to
(`func_5016594F_entry_L63_Block*`, `memcpy(.., 12)`), which lane callee-walk left as opaque pieces.

## 4. What enters func_487B8FB2: nothing -- `KernelTickIsrDefault`

The routine after `KernelInitHook` clears bits 4..7 of G6ICR 0x34000118 (acknowledges interrupt group 6),
calls func_4C03DC87 (which wakes the task (0x50380000) points at, E_OBJ when it is dormant, E_QOVR at 0x7FFF
queued wake-ups) and returns with `rets`.  That is the interrupt-handler shape: `LibIrqScheduler`
(lib 0x4C03DE26) reads the accepted group from 0x34000200, finds the request in GxICR, maps it through the
RAM table 0x50380A6C to an index and calls the handler from the RAM table 0x50380B64 with `calls (a2)`.
The table is filled by KernelInit (every entry the default `loc_4C03DEE9`) and by the def_int service
func_4C03DB21, from a packet {attribute, handler, level, ICR address}.  The only def_int of G6ICR is
func_48447F33's (the application start-up KernelInit calls): interrupt 1, handler `KernelTickHandler`
(lib 0x4C02BB05, the 1 kHz tick), level 6, ICR 0x34000118.  No word of the program, table or IC18 image
holds 0x487B8FB2, no instruction names it, and no branch reaches it.  So it is the kernel
configuration's default tick handler, which the application replaced [INFERENCE].  All four models have
it right after KernelInitHook and install their own tick handler for interrupt 1 / G6ICR the same way
(KN6000 0x4C171C06, KN6500 0x4C172408, KN2400 0x5018B5FD).  Named `KernelTickIsrDefault` in
`kn7000_manual.sym` (ported to 942 / 935 / 893), `kn6000_manual.sym`, `kn6500_manual.sym` and
`kn2400_manual.sym`, with a `FUNC_DOC` note in gen_program_s.py.

## Figures

PLACEHOLDER

## Regenerating

After the tool commits, in this order (in a worktree, with the absolute Makefile overrides and `UNIDASM=`):

1. `make -C kn2400 data-and-code-src`, `make -C kn6000 data-and-code-src`, the same for `kn6500`, then
   `hdsx3` (fixpoints after 3, 3, 3 and 2 rounds; each runs `program-src`, which takes the new symbol);
2. `make -C kn7000 symbols-sp7001 symbols-935 symbols-893 SYMOUT=<scratch>` and copy the three
   `kn7000_*_manual.sym` (only `KernelTickIsrDefault` changes);
3. `python3 tools/gen_program_s.py --profile <b>` for 941, sp7001, b935 and b893, then `make -C kn7000
   data-and-code-src` (`tools/regen_data_and_code.sh`) to the fixpoint.

## Left open

- `mem_ptrs` finds few slots in these images: most stored pointers are values the linear walk does not
  know at the store (computed, or loaded through an index), and the stores into a parameter's record that
  matter (`SetApTimer`'s message) are read by routines reached through a function pointer.
- Top-tested pointer loops (`L: cmp End, aN; bcc out; ...; add s, aN; bra L`) do not bound their arrays.
- A few bytes per tree that an over-long table or record held before are now untyped: the tables' last
  `0xFFFFFFFF` words (`func_484161BE_Table` and its twins: the loop now starts at the counter's first value
  and stops before the terminator, written `.space 4, 0xFF`), `func_48440E4D_Records` (3 "User Bank"
  records, not 6), `data_50001850_p0_1` (a pseudo-record over three RAM pointer variables), build 935's
  64-character map at 0x48613508 (was a string running into the next record, now a 64-byte piece of
  printable bytes).  `typer_stats.py` lists them.
- Field names stay offset-named (`f0`, `p8`, `x2`).

## Website page draft

(For the program-data pages of the KN7000 and the MN10300 siblings in technics-docs.)

> **Pointers, arrays and loops.**  The data sources type a 32-bit field as a pointer into code only where
> it lands on the first byte of an instruction (a length decoder walks the code from its known entry
> points); text that happens to read as a code address -- the feature demo's script, "RIGHT 1", "PUSH EXIT
> BUTTON" -- is text again.  A table the code walks with a pointer ends where the loop compares the pointer
> with its end, so the small tables after it (the sequencer menus' minimum / maximum pairs) are their own.
> The walk of the code now treats a loop's counter as an index rather than its first value, follows a block
> a routine steps through as an array of records, follows a pointer stored to memory and loaded back, and
> types every record of a linked chain (the voice directory's hash buckets) once it sees a loop walk it.
> One routine of the kernel that nothing calls is identified: the default system-tick interrupt handler
> right after `KernelInitHook`, which the firmware replaces with its own tick handler at start-up.
