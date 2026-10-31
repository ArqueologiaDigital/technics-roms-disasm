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

| rule           | item | what it does                                                                                                                                                                            |
|----------------|------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ptr_starts`   | 1    | a 32-bit word is a pointer into code only when it is the first byte of an instruction; otherwise it is text or a number, as the readers say                                             |
| `array_end`    | 2    | a pointer loop proven to stop at an address (`cmp End, aN` and a branch back) ends the array it walks                                                                                   |
| `mem_ptrs`     | 3a   | data addresses stored to a memory slot (a RAM global, a zero-initialised data word, a field of a record) and loaded back elsewhere                                                      |
| `loop_index`   | 3b   | a constant in a data register a loop writes is the loop's induction variable at its head; a pointer plus a scaled index keeps the scale                                                 |
| `step_arrays`  | 3c   | a block a routine steps through (or indexes) by s >= 2 is an array of s-byte records, counted by the loop when it is proven, else by the block's extent                                 |
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

`insn_starts_check.py` compares the oracle with what kn7asm assembles, byte by byte (the lane's base
f4045a81c, and again on this branch's final sources, with the same figures):

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
variables), 16 tables shortened (headers `...; ends at +N, where ... loop stops`).

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
*a2 }`): their records go from 2,118 (the bucket heads the tables point at) to 3,351 in build 941
(VoiceDirRemapFind 357 -> 984, VoiceDirClassFind and VoiceDirIndexFind 453 -> 570, VoiceDirRefFind
466 -> 645, VoiceDirPartRefFind 389 -> 582; 645 and 582 are also the record counts the comment above
VoiceDirRemapFind gives for two of the directories), and Malloc / Free's free list (in RAM: nothing to type).  `copied_blocks()` (a block
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

Measured against main 868b201f0 (lanes mn10300-formats, ic21-own and hdae-ledgers merged), with
`typer_stats.py` (the generator with every rule off, which reproduces main's committed sources byte for
byte -- checked for 941 -- against every rule on, the same inputs) and `code_in_data.py` (main's committed
sources, then this branch's final ones).  Main's later merge, lane media-build (b256f3b36), touches none of
these sources.  The "typed after" column is also what gen_data_s.py reports on this branch's final, fixpoint
sources, for every profile.

**Per tree, all rules** (n / bytes; reader rows = the read / address-only / string row pieces):

| tree       | typed before | typed after | change  | reader rows before | reader rows after | opaque before   | opaque after    | P before | P after | line churn |
|------------|--------------|-------------|---------|--------------------|-------------------|-----------------|-----------------|----------|---------|------------|
| kn7000-941 | 2,125,911    | 2,143,981   | +18,070 | 85 / 995           | 78 / 905          | 3,448 / 63,227  | 2,174 / 45,394  | 3        | 0       | 24,731     |
| kn7000-942 | 2,132,336    | 2,150,400   | +18,064 | 87 / 1,091         | 81 / 1,013        | 3,471 / 61,497  | 2,196 / 43,654  | 3        | 0       | 24,847     |
| kn7000-935 | 2,126,637    | 2,144,574   | +17,937 | 87 / 1,091         | 84 / 1,049        | 3,459 / 64,020  | 2,193 / 46,280  | 1        | 0       | 24,396     |
| kn7000-893 | 2,126,357    | 2,144,470   | +18,113 | 85 / 995           | 79 / 917          | 3,453 / 62,910  | 2,177 / 45,007  | 2        | 0       | 24,769     |
| kn6000     | 2,424,027    | 2,436,905   | +12,878 | 185 / 11,215       | 142 / 9,370       | 2,833 / 65,733  | 2,347 / 54,782  | 0        | 0       | 12,952     |
| kn6500     | 1,935,342    | 1,948,203   | +12,861 | 190 / 11,331       | 147 / 9,486       | 2,849 / 69,967  | 2,364 / 59,027  | 0        | 0       | 12,882     |
| kn2400     | 1,670,358    | 1,688,962   | +18,604 | 218 / 9,889        | 184 / 8,255       | 4,448 / 172,071 | 3,419 / 155,297 | 1        | 0       | 26,804     |
| hdsx3      | 481,868      | 482,118     | +250    | 34 / 211           | 34 / 211          | 98 / 3,103      | 98 / 2,981      | 0        | 0       | 64         |

"P" is `code_in_data.py`'s mid-instruction `.long` count (distinct addresses); every other column of that
probe (T, T-mid, F, L) is 0 before and after.  "line churn" is the lines of data_NN.s, data_structs.inc and
labels.sym that differ between the two generator runs.

**Per rule, build 941** (`--only R`: that rule alone against all off):

| rule           | typed change | reader rows | opaque                           | line churn |
|----------------|--------------|-------------|----------------------------------|------------|
| `ptr_starts`   | +119         | 85 -> 80    | 3,448 / 63,227 -> 3,441 / 63,161 | 230        |
| `array_end`    | +12          | 85 -> 85    | 3,448 / 63,227 -> 3,447 / 63,215 | 311        |
| `mem_ptrs`     | +0           | 85 -> 85    | unchanged                        | 0          |
| `loop_index`   | +5,959       | 85 -> 85    | 3,448 / 63,227 -> 3,157 / 57,371 | 4,533      |
| `step_arrays`  | +32          | 85 -> 84    | unchanged                        | 403        |
| `deep_records` | +11,924      | 85 -> 84    | 3,448 / 63,227 -> 2,475 / 51,352 | 20,564     |

The rules overlap (the sum is more than the +18,070 of all of them).  The churn is mostly names: a new
record gets a label, the generator's numbered names after it (`Str_d_5` -> `Str_d_19`, `func_X_Table_3`
...) renumber, and gen_program_s.py then respells the code that names them; `deep_records`' 1,233 new hash-chain
records of the voice directory each get a label of their own.

**Bytes typed before and not after** (`typer_stats.py`'s "typed in the off run only"; they become reader
rows, `.space` fill or opaque pieces):

| tree       | bytes | what                                                                                                                                                                                                          |
|------------|-------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| kn7000-941 | 23    | the `0xFFFFFFFF` after `func_484161BE_Table` and its three twins (the loop starts at the counter's first value and stops before it), `func_48440E4D_Records` 6 -> 3 "User Bank" records, `data_50001850_p0_1` |
| kn7000-942 | 23    | the same                                                                                                                                                                                                      |
| kn7000-935 | 87    | the same, and the 64-character map at 0x48613508 (a string before, running into the next record; now a piece of printable bytes, no NUL)                                                                      |
| kn7000-893 | 23    | the same as 941                                                                                                                                                                                               |
| kn6000     | 32    | the same tables' terminators (`func_4C007A5B_entry_L27_Table` ...), `func_4C062A3D_entry_Lcd_Records`                                                                                                         |
| kn6500     | 35    | the same, and `TtSqmixer_L64_Table`                                                                                                                                                                           |
| kn2400     | 17    | `func_5017E2AD_entry_Lcd_Records`, `func_4863A91F_Table_4`, `TtSqmixer_L74_Table`, two `SdWorkerCmdHandler` variables (now inside records)                                                                    |
| hdsx3      | 6     | two `KssCopy*_Table_p0_0` records, now part of a larger one                                                                                                                                                   |

No tree loses typed coverage: every tree types more bytes (the table above), and the bytes it no longer
types are those an over-long item held.

**Census figures** (read-only; `scripts/analysis/data_incbin_census.py --compare
docs/coverage/data-incbin-2026-10-31-01.json` exits 0, nothing rose, generic 0 everywhere).  Opaque n /
bytes on this branch: kn7000-program 2,174 / 45,394, kn7000-sp7001 2,196 / 43,654, kn7000-b935 2,192 /
46,280, kn7000-b893 2,177 / 45,007, kn6000 2,347 / 54,782, kn6500 2,364 / 59,027, kn2400 3,419 / 155,297,
hdsx3 98 / 2,981 (main b256f3b36: the "opaque before" column above, which `typer_stats.py` counts the same
way; the census counts b935's one fewer).

`scripts/analysis/doc_quality_census.py --compare` (against doc-quality-2026-10-31-01; on main b256f3b36 it
shows no rise in these images) exits 1 for three siblings:

| image  | debt                          | before -> after  | why                                                                                                                                                                                                                   |
|--------|-------------------------------|------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| kn2400 | (a) routines without a header | 21,233 -> 21,242 | new records' pointer fields name code addresses no label had (`loc_486D0C7E` ..., a table of handlers now typed), and a pointed-to label counts as a routine; `func_5018DD6C_entry`, the call of KernelTickIsrDefault |
| kn2400 | (c) loc_ locals               | 4,967 -> 4,975   | the same `loc_486D0C7E` ... labels                                                                                                                                                                                    |
| kn6000 | (a) routines without a header | 19,020 -> 19,021 | `func_4C3F7272_entry`: KernelTickIsrDefault is a function now, so its call names an entry                                                                                                                             |
| kn6500 | (a) routines without a header | 19,065 -> 19,070 | the same entry, and four `loc_4C04F405` ... code addresses new records name                                                                                                                                           |
| kn6500 | (c) loc_ locals               | 5,061 -> 5,065   | those four labels                                                                                                                                                                                                     |

What fell: placeholder routine names in the KN7000 program builds (`func_487B8FB2` -> `KernelTickIsrDefault`)
and the siblings (the three twins).  `make dispatch-census` measures no MN10300 image.

## Regenerating

After the tool commits, in this order (in a worktree, with the absolute Makefile overrides, `UNIDASM=` and
`SP7001_UPDATES=`):

1. `make -C kn2400 data-and-code-src`, the same for `kn6000` and `kn6500`, then `hdsx3` (fixpoints after 3,
   3, 3 and 2 rounds; each runs `program-src`, which takes the new symbol);
2. `make -C kn7000 symbols-sp7001 symbols-935 symbols-893 SYMOUT=<scratch>` and copy the three
   `kn7000_*_manual.sym` (only `KernelTickIsrDefault` changes);
3. `python3 tools/gen_program_s.py --profile <b>` for 941, sp7001, b935 and b893;
4. `make -C kn7000 data-and-code-src` (`tools/regen_data_and_code.sh`; fixpoint after 3 rounds), then
   `make -C kn7000 plugin-src`;
5. build the four programs (`make -C kn7000 verify verify-sp7001 verify-935 verify-893`), then
   `data-and-code-src` once more: it reached its fixpoint in round 1.

Two loop hazards the regeneration showed, fixed in the tools: a generated `func_<ADDR>` the data names
must stay in `code_refs.txt` (gen_program_s.py names a prologue a table points at `func_` only while the
data lists it; lane mn10300-formats made the same `ref()` change, kept at the merge), and gen_program_s.py
writes no `loc_<ADDR>` `.equ` for such a prologue unless the data spells that `loc_` name
(`read_data_loc_names()`; 941, 935 and 893 lose 245-265 unused equates from program.s, 942 five).  copied_blocks()
cites a block's copies in a fixed order (a memcpy and a memcmp from one routine tied, and a set's order
varies from run to run).

## Left open

- ~~`mem_ptrs` finds few slots~~ (lane mn10300-rest, `../mn10300-rest/README.md` section 3: `fld_slots`
  follows a pointer loaded from a typed field through a memory slot, 131 slots in 941; SetApTimer's message
  is read through ProcCall's run-time window table 0x5011FAAC, a dispatch no static walk resolves).
- ~~Top-tested pointer loops~~ (lane mn10300-rest, section 3: `top_tested` bounds them; the images' compiled
  loops are bottom-tested, so it finds none there).
- A few bytes per tree that an over-long table or record held before are now untyped: the tables' last
  `0xFFFFFFFF` words (`func_484161BE_Table` and its twins: the loop now starts at the counter's first value
  and stops before the terminator, written `.space 4, 0xFF`), `func_48440E4D_Records` (3 "User Bank"
  records, not 6), `data_50001850_p0_1` (a pseudo-record over three RAM pointer variables), build 935's
  64-character map at 0x48613508 (was a string running into the next record, now a 64-byte piece of
  printable bytes).  `typer_stats.py` lists them.
- ~~Field names stay offset-named~~ (lane mn10300-rest, section 4: 941 630 -> 257 fields with a reader).

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
