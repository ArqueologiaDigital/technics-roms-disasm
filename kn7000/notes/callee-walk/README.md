# The callee walk: a block passed to a routine is a record of what the routine reads

Lane callee-walk of the open-items effort, 2026-10-30.  The owner's open item: *"Read widths, not
layouts: where code only passes a block's address on to another routine, the block is written at the
width it is read, not its real record layout.  That's because the analysis doesn't follow the address
into that routine."*  Background: `../../../notes/data-semantics-2026-10-29/README.md`, section "Generic 0"
(the `reader_rows` fallback of `tools/gen_data_s.py`).  Probe: `../callee-walk-probes/` (README there).

## What was missing

`tools/data_readers.py` already carried a callee's accesses through its register parameters a0 / a1 /
d0 / d1 into its callers (`resolve_params`, four rounds).  Three things kept the pieces as rows:

1. **Stack arguments were not followed.**  Words past the fourth argument go on the stack, and most
   "address only" pieces of the KN2400 are handed over that way, or parked in the caller's frame and
   reloaded just before the call.  The siblings' walk had no frame slots at all.
2. **What came back was flattened.**  A callee's read at +6 of its argument became a read of the fixed
   address Block+6, so `variables()` / `reader_tables()` typed each field as a separate `_Var` /
   `_Table` (`func_4C03D154_Table`, `func_4C03D154_Var`, `func_4C03D154_Table_2` ... for one cre_tsk
   block) and the bytes no field covered stayed rows.
3. **The siblings lost the address on the way to the call.**  A switch that selects a block per case
   (`mov data_X, a1` / `bra Join`) and returns it, or stores it to (0, sp) and jumps to a common call,
   reached the call as "unknown": the siblings' walk kept a register at a join only when every path
   agreed, had no return-value rule, and entered a jump table's cases with nothing known.

## The calling convention, from the code

| what                   | where                                                                                            | evidence                                                                                                                                                                                                              |
|------------------------|--------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| pointer arguments 1, 2 | a0, a1                                                                                           | DrawString_entry 0x48425398: `mov a1, (0x3c, sp)` "&pen", `mov a0, (0x38, sp)` "&clip rect" (frame 0x30: their homes at +8, +12)                                                                                      |
| number arguments 1, 2  | d0, d1                                                                                           | DrawString: `mov d0, d3` font index, `mov d1, d2` fg colour                                                                                                                                                           |
| the rest               | the caller's (N, sp), N = 16, 20, 24 ...                                                         | DrawString reads its string at (0x40, sp) = caller's (0x10, sp); SetApTimer 0x48429C95 its 5th argument at (0x4c, sp), frame 0x34 = caller's (0x18, sp), stored there by TestDiskFunc 0x484A0A32 `mov d0, (0x18, sp)` |
| the callee's frame     | `movm [regs], (sp)` (4 bytes a register) + `add -K, sp`, or the call's `call F_entry, [regs], K` | SetApTimer: `movm [d2,d3,a2,a3]` + `add -0x24, sp` = 0x34 = `call SetApTimer_entry, [d2,d3,a2,a3], 0x34`; DrawString_Impl's `add -0x188, sp` after its _entry label                                                   |

So a word the caller stores at (N, sp), N >= 16, and a read of (N + frame, sp) in the callee before it
writes there are the same parameter, `spN` in the walk.  The words below 16 are the return address and
the homes the callee spills its own a0 / a1 to: taking (8, sp) for an argument carried a caller's local
into the HD-SX3's func_97834719 and its stores into a doubles table (measured, then excluded).

## What the walk does now (`Reader(callee=True)`, profile key `readers_callee`)

Set for the KN7000 program builds (941, 942 = sp7001, 935, 893) and the four siblings (KN6000, KN6500,
KN2400, HD-SX3); the docstring of `data_readers.py` ("CALLEE") has the rules:

| rule                         | what it follows                                                                                                                                                                                                                                                                                                                                          |
|------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| stack arguments              | a call records each word of its frame holding a data address or a parameter as argument `spN`; the callee's read of (N + frame, sp) is parameter `spN`                                                                                                                                                                                                   |
| frame slots (siblings)       | ext's stack-slot rule, but a slot gives back only a data address, a parameter, or NULL into an address register (the full rule changed what the siblings' other passes see: StyleGenreTable's 180-byte records split, 840 bytes lost; NULL into a data register is an index: it made the HD-SX3's names_978A31BC_p0 a fixed-field record; both measured) |
| address joins (siblings)     | a label paths reach with different data addresses (or NULL) holds one of them (ext's T value), in a register or a slot                                                                                                                                                                                                                                   |
| return sets (siblings)       | a function returning one of a set of addresses gives its callers that set (ext's return rule; not its pointer-from-a-field one)                                                                                                                                                                                                                          |
| jump-table cases             | a label nothing branches to after the function's `jmp (aN)` takes the addresses and parameters the dispatch held [INFERENCE]                                                                                                                                                                                                                             |
| named branch labels (KN7000) | `bne DrawString_DrawNow`: a branch to a named label that no `call` and no `# Name (CPU ...)` header names stays inside the function                                                                                                                                                                                                                      |
| loop steps                   | a parameter pointer stepped (`inc a0`, `add 2, a0`) between a label and a branch back to it (or setlb .. Lcc) is stepped by a loop                                                                                                                                                                                                                       |
| layouts                      | per (function, parameter): every access relative to it, its own and its callees' (resolve_params, 4 rounds = the depth limit; memoised per (callee, slot)), and the calls that pass a fixed data address in it                                                                                                                                           |

`tools/gen_data_s.py` then:

- `arg_kinds()`: one record kind per (routine, slot) that receives a fixed data address and reads at least
  two fields of it (or one past +0); left out, with the reason kept for the rows' header: a library
  routine by name (`str*`, `mem*`, `*printf`, `Lib*`), no read at a fixed offset (the routine stores the
  pointer, in a timer, a registry or a queue), a byte loop (a string or a block), only the first byte, or
  only one field at +0 (a scalar, or the first entry of an array indexed by a loop counter the linear walk
  takes as a constant: DrawBitmapSPFast16_Impl's palette);
- `arg_reserve()`, before `reader_tables()` / `variables()`: those passes leave a table or variable wholly
  inside such a block to the record (or one that starts in it and runs on past it by no more than the
  block's length);
- `ptr_records(only_arg=True)`, after them: the records, with ptr_records' machinery (fields from the
  reads, pointer fields followed into the records they lead to, a stride from the targets' spacing, short
  variants); two records of a kind a whole number of records apart with free bytes between have the records
  between typed too `[INFERENCE]`; a table that ran on past the record's last field keeps its bytes as the
  record's tail rows; anything a record could not take is typed as before (`reader_tables()` / `variables()`
  run again);
- the header names the evidence: `Label:	# REC_F_ArgA0 (N bytes): the layout F 0xADDR reads through its
  argument a0 (passed by Caller 0xADDR `call F_entry, ...`, +k more calls)`, and the macro's comment lists
  each field's reader;
- a piece that stays rows says why (`arg_why()`), in place of "what the callee reads ... is not traced".

Fields are offset-named (`f12`, `p8`, `x4`) except where `tools/data_struct_names.py` knows their use:
`cre_tsk_ArgA0` is micro-ITRON's `T_CTSK` {exinf, tskatr, task, itskpri, stksz} (kn7000.sym's note on
cre_tsk 0x4C03D0C8; the reads are its body cre_tsk_Impl's, which cre_tsk hands the block to).

## Results

Measured against main 2a7b45be5 (lanes media-files and code-island merged), after `make -C kn2400|kn6000|kn6500|hdsx3
data-and-code-src` and `make -C kn7000 data-and-code-src` to the fixpoint.

**Reader rows and records** (`python3 kn7000/notes/callee-walk-probes/callee_walk_stats.py --reasons`; n / bytes;
"callee records" = blocks typed `REC_<F>_Arg<slot>`, "pointed" = every ptr_records() record, the siblings' new
switch selections included):

| tree       | read before | read after | address before | address after | string before | string after | rows before  | rows after   | callee records | inferred records | pointed before | pointed after |
|------------|-------------|------------|----------------|---------------|---------------|--------------|--------------|--------------|----------------|------------------|----------------|---------------|
| kn7000-941 | 4 / 121     | 4 / 121    | 50 / 1,037     | 39 / 682      | 32 / 200      | 45 / 252     | 86 / 1,358   | 88 / 1,055   | 39 / 535       | 1 / 28           | 4700 / 81,861  | 4747 / 82,451 |
| kn7000-942 | 4 / 121     | 4 / 121    | 52 / 1,133     | 41 / 778      | 32 / 200      | 45 / 252     | 88 / 1,454   | 90 / 1,151   | 44 / 635       | 1 / 28           | 4721 / 81,945  | 4773 / 82,635 |
| kn7000-935 | 4 / 121     | 4 / 121    | 52 / 1,133     | 41 / 778      | 32 / 200      | 45 / 252     | 88 / 1,454   | 90 / 1,151   | 40 / 547       | 1 / 28           | 4721 / 81,945  | 4769 / 82,547 |
| kn7000-893 | 4 / 121     | 4 / 121    | 49 / 1,033     | 39 / 682      | 32 / 200      | 45 / 252     | 85 / 1,354   | 88 / 1,055   | 40 / 547       | 1 / 28           | 4721 / 81,945  | 4769 / 82,547 |
| kn6000     | 5 / 129     | 4 / 113    | 339 / 17,838   | 151 / 11,022  | 34 / 142      | 33 / 140     | 378 / 18,109 | 188 / 11,275 | 31 / 696       | 0 / 0            | 2571 / 42,931  | 2861 / 50,844 |
| kn6500     | 5 / 129     | 4 / 113    | 345 / 17,958   | 156 / 11,138  | 34 / 142      | 33 / 140     | 384 / 18,229 | 193 / 11,391 | 31 / 696       | 0 / 0            | 2549 / 42,801  | 2839 / 50,714 |
| kn2400     | 3 / 109     | 51 / 1,833 | 380 / 18,475   | 123 / 7,849   | 48 / 269      | 47 / 267     | 431 / 18,853 | 221 / 9,949  | 30 / 420       | 0 / 0            | 2406 / 37,688  | 2700 / 42,535 |
| hdsx3      | 0 / 0       | 0 / 0      | 30 / 228       | 25 / 177      | 10 / 38       | 9 / 34       | 40 / 266     | 34 / 211     | 131 / 1,048    | 7 / 56           | 17 / 19,340    | 155 / 20,444  |

The KN7000's address-only pieces fall 50 -> 39 (1,037 -> 682 bytes); its string rows rise 32 -> 45 because
13 empty strings handed to func_48502E9F (one of a switch's set, now a T value) are written `.asciz ""` in place
of an s8 variable plus a 3 x s8 table.  The siblings' fall most (KN6000 339 -> 151 address pieces, 17,838 ->
11,022 bytes; KN2400 380 -> 123): the address joins, return sets and jump-table states let their switches'
descriptors be records (`func_4C026B6B_Selected`, `func_5016B726_Result` ...), and the KN2400's 51 "read"
pieces are such descriptors the code now reads (at +4, s16) but whose records did not fit.

**Why what is left stays rows:**

| tree       | reason                                                                                   | pieces | bytes |
|------------|------------------------------------------------------------------------------------------|--------|-------|
| kn7000-941 | the address reaches no call the walk sees (kept in memory, or a path it does not follow) | 18     | 400   |
| kn7000-941 | the routine stores it (a timer, a registry, a queue) and reads no field                  | 14     | 140   |
| kn7000-941 | handed to a library routine (string / block copy)                                        | 5      | 48    |
| kn7000-941 | the routine's reads are not seen (an argument the walk loses inside it)                  | 2      | 94    |
| kn7000-942 | the address reaches no call the walk sees (kept in memory, or a path it does not follow) | 20     | 496   |
| kn7000-942 | the routine stores it (a timer, a registry, a queue) and reads no field                  | 14     | 140   |
| kn7000-942 | handed to a library routine (string / block copy)                                        | 5      | 48    |
| kn7000-942 | the routine's reads are not seen (an argument the walk loses inside it)                  | 2      | 94    |
| kn7000-935 | the address reaches no call the walk sees (kept in memory, or a path it does not follow) | 20     | 496   |
| kn7000-935 | the routine stores it (a timer, a registry, a queue) and reads no field                  | 14     | 140   |
| kn7000-935 | handed to a library routine (string / block copy)                                        | 5      | 48    |
| kn7000-935 | the routine's reads are not seen (an argument the walk loses inside it)                  | 2      | 94    |
| kn7000-893 | the address reaches no call the walk sees (kept in memory, or a path it does not follow) | 18     | 400   |
| kn7000-893 | the routine stores it (a timer, a registry, a queue) and reads no field                  | 14     | 140   |
| kn7000-893 | handed to a library routine (string / block copy)                                        | 5      | 48    |
| kn7000-893 | the routine's reads are not seen (an argument the walk loses inside it)                  | 2      | 94    |
| kn6000     | the routine stores it (a timer, a registry, a queue) and reads no field                  | 69     | 1,028 |
| kn6000     | handed to a library routine (string / block copy)                                        | 52     | 2,015 |
| kn6000     | the address reaches no call the walk sees (kept in memory, or a path it does not follow) | 24     | 7,839 |
| kn6000     | the routine's reads are not seen (an argument the walk loses inside it)                  | 4      | 112   |
| kn6000     | the routine hands it on (or stores it) and reads no field                                | 1      | 20    |
| kn6000     | the record would overlap an item another pass typed                                      | 1      | 8     |
| kn6500     | the routine stores it (a timer, a registry, a queue) and reads no field                  | 72     | 1,048 |
| kn6500     | handed to a library routine (string / block copy)                                        | 52     | 2,015 |
| kn6500     | the address reaches no call the walk sees (kept in memory, or a path it does not follow) | 26     | 7,935 |
| kn6500     | the routine's reads are not seen (an argument the walk loses inside it)                  | 4      | 112   |
| kn6500     | the routine hands it on (or stores it) and reads no field                                | 1      | 20    |
| kn6500     | the record would overlap an item another pass typed                                      | 1      | 8     |
| kn2400     | the routine hands it on (or stores it) and reads no field                                | 42     | 5,789 |
| kn2400     | handed to a library routine (string / block copy)                                        | 31     | 496   |
| kn2400     | the routine stores it (a timer, a registry, a queue) and reads no field                  | 27     | 892   |
| kn2400     | the address reaches no call the walk sees (kept in memory, or a path it does not follow) | 18     | 504   |
| kn2400     | the routine's reads are not seen (an argument the walk loses inside it)                  | 5      | 168   |
| hdsx3      | the routine stores it (a timer, a registry, a queue) and reads no field                  | 18     | 120   |
| hdsx3      | handed to a library routine (string / block copy)                                        | 4      | 40    |
| hdsx3      | the address reaches no call the walk sees (kept in memory, or a path it does not follow) | 2      | 8     |
| hdsx3      | the routine hands it on (or stores it) and reads no field                                | 1      | 9     |

**Typed coverage** (`callee_off_on.py --profile P`: the generator's items with the walk off and on, the same
inputs; bytes of the data region in typed items):

| profile | walk off  | walk on   | change  | typed with the walk off only                                                                                                    |
|---------|-----------|-----------|---------|---------------------------------------------------------------------------------------------------------------------------------|
| 941     | 2,125,352 | 2,125,687 | +335    | 128 B: func_48502E9F_Var / _Table pieces, the empty strings above (now string rows)                                             |
| sp7001  | 2,131,777 | 2,132,112 | +335    | 128 B, the same (func_48502E8E)                                                                                                 |
| b935    | 2,126,078 | 2,126,413 | +335    | 128 B, the same                                                                                                                 |
| b893    | 2,125,800 | 2,126,133 | +333    | 128 B, the same                                                                                                                 |
| kn6000  | 2,408,017 | 2,423,968 | +15,951 | 29 B: func_4C0285C8_Table x 2, func_4C11B347_Table, a record head (func_4C09A63A_entry_L65_Records_p0_1): a new record's extent |
| kn6500  | 1,919,330 | 1,935,283 | +15,953 | 29 B, the same                                                                                                                  |
| kn2400  | 1,637,068 | 1,645,446 | +8,378  | 8 B: func_5017DCBF_entry_L71_Table, func_4861CCC5_Table, TtSdkeyscl_Table tails                                                 |
| hdsx3   | 481,779   | 481,868   | +89     | none                                                                                                                            |

No tree loses typed coverage; the few bytes typed only without the walk are listed (reader rows now, not opaque,
except where the next paragraph says).

**Census** (`scripts/analysis/data_incbin_census.py`, read-only; generic stays 0 everywhere; opaque n / bytes,
main 2a7b45be5 -> this branch): kn7000-program 3,451 / 63,410 -> 3,449 / 63,392; kn7000-sp7001 3,474 / 61,680 ->
3,472 / 61,662; kn7000-b893 3,456 / 63,093 -> 3,454 / 63,075; kn7000-b935 3,462 / 64,203 -> 3,460 / 64,185; kn6000
3,197 / 70,137 -> 2,833 / 65,733; kn6500 3,213 / 74,371 -> 2,849 / 69,967; hdsx3 101 / 3,133 -> 98 / 3,103.
**kn2400 ROSE**, 5,051 / 196,479 -> 5,131 / 196,924 (+80 pieces, +445 bytes): its switch descriptors
(`func_5016B726_Result`, 18 bytes) were the heads of 32-byte address-only pieces; now that they are records, the
12-byte blocks their `p8` field points at are pieces of their own, which no instruction reads (gap_note: "a typed
pointer ... holds their address, but nothing is read through it").  They were rows before only by being after
an address the code loads.

Evidence of the conventions above: DrawString_entry 0x48425398 (homes at +8 / +12, string at (0x40, sp) with a
0x30 frame), SetApTimer 0x48429C95 (fifth argument at (0x4c, sp), frame 0x34, stored by TestDiskFunc 0x484A0A32 at
(0x18, sp)).  Examples of callee records: `T_CTSK` (cre_tsk 0x4C03D0C8 / cre_tsk_Impl), `REC_cre_flg_ArgA0`
(12 bytes, 10 blocks and one 8-byte variant), `REC_func_48401F32_ArgA0` (28 bytes, with one record between two passed ones inferred),
`REC_func_4844416A_ArgA0` (its reads at +3..+5 after an `add 2, a0`, the block's first three bytes unread).

## Regenerating

After the tool commits, in this order (in a worktree, with the absolute Makefile overrides and `UNIDASM=`;
lane code-island's order, `../code-island/README.md`, whose steps 1-3 this lane's tools do not change):
`make -C kn2400 data-and-code-src`, `make -C kn6000 data-and-code-src`, the same for `kn6500` and then `hdsx3`
(its host is the KN6000), and `make -C kn7000 data-and-code-src` (`tools/regen_data_and_code.sh`).  Each
reached its fixpoint in 1-3 rounds.  The other census and doc-quality figures that moved:
`scripts/analysis/doc_quality_census.py` (read-only) counts 6 more routines in each sibling (kn2400 21,234 ->
21,240, kn6000 19,016 -> 19,022, kn6500 19,061 -> 19,067), all without a header and with a `loc_` local each:
the new records' pointer fields name 6 more code addresses (`code_refs.txt`: +6, -0, per sibling).

## Left open

- **A pointer the routine stores.**  SetApTimer / KillApTimer (a timer record's message argument),
  RegisterObjectTable, PutM3Em (a queue), zlib's `_tr_init` (`s->l_desc.stat_desc = &static_l_desc`) keep the
  address in memory, and whoever loads it from there later reads the block.  Lane mn10300-typer's `mem_ptrs`
  follows a store to memory and a load back (`../mn10300-typer/README.md`, 3a); it finds SetApTimer's message
  field, but the only load of it, in ApTimer, hands it to ProcCall, a dispatch through a function pointer, so
  these blocks still stay rows, with the reason in their header.  (BLOCKED, lane mn10300-data 2026-11-02: a
run-time dispatch, see `../mn10300-data/README.md` section 3.)  (Lane mn10300-rest,
  `../mn10300-rest/README.md` section 3: ProcCall takes the procedure from the RAM table 0x5011FAAC that a
  window fills when it registers: a run-time dispatch, so this stays.)
- **Library routines.**  memcpy / strcpy / LibStrlen and the like: the bytes are copied or measured, the
  layout is the copy's reader's.  Kept as rows (or `copied_blocks()`'s typed copies).  (Lane mn10300-data,
  2026-11-02: the strcpy / LibStrlen arguments are strings already; what is left handed only to memcpy is
  listed in `../mn10300-data/README.md` section 3.)
- ~~**Arrays indexed by a loop counter.**~~ (resolved by lane mn10300-typer, `loop_index`: the counter is an
  induction variable at the loop head, its start kept.)  The linear walk takes a counter's first value as a constant
  (DrawBitmapSPFast16_Impl's palette loop starts at index 0x20), so such a callee shows one field at +0;
  `arg_kinds()` leaves that to the rows.  A loop-head rule that widens the constants a loop changes would
  turn these into indexed arrays.
- ~~**Loop-stepped records.**~~ (resolved by lane mn10300-typer, `step_arrays`: arrays of N-byte records,
  counted by the loop or by the block's extent.)  `param_steps` records a parameter pointer a loop steps by N >= 2 (an array of
  N-byte records), but `arg_kinds()` does not yet write the block as an array of them: the count is not known
  from the walk.
- **Field names.**  Fields are offset-named except `T_CTSK`'s; naming the others needs reading each routine.
  Partly done 2026-10-31 (lane mn10300-formats, `../mn10300-formats/README.md`): a field is named from what
  the code does with it after the load (`tools/data_field_uses.py`, `data_struct_names.auto_name`); the
  counts before and after are `../mn10300-formats-probes/field_names_census.py`'s.
- **The siblings' walk** now has ext's slots (narrowed), joins and return sets, not its other rules
  (pointer-from-a-field returns, loop bodies keeping slots, bounds); `readers_ext` itself made the KN2400
  worse (`../../../kn6000/notes/siblings-data-final/README.md`).  (Resolved 2026-11-02, lane mn10300-data:
  four of ext's rules ported one at a time, `sib_rules`, each measured; `../mn10300-data/README.md` section 2.)
- A handful of bytes per sibling that a reader table or a record's head held are now in reader rows,
  because a record the new joins find claims a different extent (KN6000 / KN6500: 29 bytes, KN2400: 8;
  `callee_off_on.py` lists them).  (Resolved 2026-11-06, lane mn10300-data3, N-61c32961: the last of them were
  the menu parameter-id lists of KN6000 func_4C11B347 / KN6500 func_4C11B237 / KN2400 func_4861CCC5
  (and 941 func_4845BC68), walked by index (`asl2 d0` / `mov (d0, a0), d0` / `cmp d2, d0` / `lne`); the
  `sentinel_indexed` rule types them as -1-ended u32 lists, `../mn10300-data3/README.md` section 1.)

## Website page draft

(For the program-data pages of the KN7000 and the MN10300 siblings in technics-docs, to be added by the
website sync.)

> **Blocks a routine is handed.**  Much of the program data is never read where it is named: the code loads
> the block's address and passes it to a routine (in a0 / a1 for a pointer, d0 / d1 for a number, the rest in
> the caller's stack frame at +0x10, +0x14, ...), and that routine reads the fields.  The data sources now
> follow the address into the routine, and into the routines it hands it on to, and write the block as a
> record of what they read: one macro per (routine, argument), `REC_<routine>_Arg<slot>`, whose comment names
> each field's reader, and a header on each block naming the routine, its address, the argument and the call
> that passes it.  The kernel's task-creation blocks, for example, are micro-ITRON `T_CTSK` records
> {exinf, tskatr, task, itskpri, stksz} that `cre_tsk` hands to its worker; before, each field was a separate
> one-word table.  The same walk now follows a switch that selects a record per case and returns it (the
> KN6000 / KN6500 / KN2400 counterparts of the KN7000's 260-way descriptor switch), so those descriptors are
> records too.  A block stays rows, at the widths the code reads, when the routine only stores the pointer
> (a timer's message argument, a registry entry, a queue), copies or measures it (memcpy, strcpy, strlen), or
> reads one field of it; its header says which.
