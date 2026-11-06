# Lane open11/sibling-names (2026-11-06, wave 11): routine and RAM names in the MN10300 siblings

Wave 11 of the open-items work (`../../../notes/open-items/REGISTER.md`).  The lane took the six
L-sized naming items of the KN6000, KN6500 and KN2400 (routine names N-02383279, N-a6b3dca1,
N-391deec6; RAM operands N-8fce01b1, N-cccf0416, N-dc17693c).  The goal was measured progress with
evidence, not closure: the porting by whole-routine code was already done (lane mn10300-names,
`../mn10300-names/README.md`), and what was left is the routines and variables no body comparison
can place.  The probes are in `../sibling-names-probes/` (README there).

## What the earlier porting could not reach (measured)

`../sibling-names-probes/kn7000_names_missed.py` puts each of KN7000 941's 3,889 routine names in a
class, for the commit before this lane (`missed-2bde950fa.txt`):

| class                                        | KN6000 before | after | KN6500 before | after | KN2400 before | after |
|----------------------------------------------|---------------|-------|---------------|-------|---------------|-------|
| B has the name                               | 2,487         | 2,595 | 2,490         | 2,598 | 2,814         | 3,042 |
| no strict-equal body in B                    | 887           | 865   | 881           | 859   | 467           | 429   |
| short, twins on both sides (kept<8, 3+ / 3+) | 226           | 206   | 226           | 204   | 277           | 201   |
| short, unique (kept<8, 1 / 1)                | 33            | 7     | 32            | 7     | 50            | 3     |
| other short with twins (kept<8)              | 28            | 19    | 28            | 18    | 17            | 8     |
| kept>=8 with a twin on either side           | 97            | 65    | 108           | 78    | 120           | 54    |
| kept>=8, unique                              | 1             | 1     | 1             | 1     | 5             | 1     |
| same-body routines in B all named otherwise  | 111           | 112   | 104           | 105   | 120           | 132   |
| A name not at a routine start                | 19            | 19    | 19            | 19    | 19            | 19    |
| total                                        | 3,889         | 3,889 | 3,889         | 3,889 | 3,889         | 3,889 |

(the probe's own classes are in `../sibling-names-probes/missed-2bde950fa.txt` and `missed-after.txt`;
this table groups them; "after" is the tree this lane regenerated).

So most of 941's names that the siblings lack belong to code the sibling changed or does not have
(no routine with the same body).  Of the rest, the large class is short bodies with twins on both
sides (getters, setters, flag tests; `kept<8, A twins 3+, B open 3+`: 226 / 226 / 277): their code
is the same in many routines and only their variables tell them apart, which is why
`port_names_by_code.py` (unique, at least 8 unmasked instructions) leaves them.

## Tools added

| tool                                     | what it does                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
|------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `../../tools/port_names_by_alignment.py` | carries 941 names along the CALL SITES and RAM OPERANDS of routines both images already name (anchors): the k-th call of B's `Foo` is the k-th call of 941's `Foo` when the two bodies align; same-body routines (short, twins) are told apart by their RAM operands through the RAM pairs the anchors give; unnamed pairs the rule accepts anchor the next round; writes `<model>_aligned.sym`, `notes/ram-map-kn7000.tsv`, `notes/routine-map-kn7000.tsv`, `notes/aligned-names-report.md` |
| `../../tools/name_ram_by_use.py`         | names RAM addresses after named routines: `accessor` (a named GetX / SetX / IsX / XGet / XSet routine whose whole body is one load or store of the address, the variable takes the stem: GetSeqPlySrtR / SetSeqPlySrtR -> `SeqPlySrtR`) and `owner` (every direct reference lies in one named routine R: `R_Ram`, `R_Ram_2`, ...); writes `<model>_ram.sym`, `notes/ram-names-report.md`                                                                                                     |

Each sibling Makefile has the targets `aligned-names` and `ram-names`; `program-src` reads the two new
symbol files, and `ported-names` passes them as B names so it never reuses one.  The order of a full
regeneration is

    make -C <model> aligned-names UNIDASM=... PORT_CACHE=<scratch>/cache
    make -C <model> data-and-code-src UNIDASM=...
    make -C <model> ram-names
    make -C <model> data-and-code-src UNIDASM=...
    make -C <model> gui-map

(HD-SX3: the first two; it has no RAM operand in the RAM ranges).  Each tool is a fixed point on
its own output (names it wrote earlier count as unnamed again).

## The evidence classes, and how often they are wrong

Every row of `<model>_aligned.sym` and `<model>_ram.sym` says its class and its evidence:

- **call site**: the callee at N aligned call sites of the named anchors (listed), with the two
  callees' body similarity.  A name is carried only when every aligned call site of that B routine
  has one 941 callee and that callee pairs with no other B routine; one exact or skeleton anchor, or
  two aligned ones; no named callee or string of the two bodies disagrees; body skeleton similarity
  at least 0.6.
- **same body**: the whole bodies are equal (strict tokens); every RAM operand the RAM map pairs
  agrees, at least one, and no other routine of either group passes with them (or, for a pair
  unique on both sides, a named callee or string agrees).
- **RAM =**: the B address pairs with the 941 address at every aligned operand, and no other B
  address takes it; the name is 941's (`kn7000_manual.sym`).
- **accessor**, **owner**: above.

The audit (`notes/aligned-names-report.md`) runs the rule where the answer is known (the callee or
same-body routine both images name already):

| model  | call sites right | wrong | same body right | wrong | RAM pairs right | wrong |
|--------|------------------|-------|-----------------|-------|-----------------|-------|
| KN6000 | 488              | 2     | 122             | 0     | 14              | 0     |
| KN6500 | 491              | 2     | 125             | 0     | 14              | 0     |
| KN2400 | 650              | 3     | 190             | 0     | 14              | 0     |
| HD-SX3 | 36               | 0     | 0               | 0     | 0               | 0     |

The call-site `wrong` rows are listed in each report; they are two names for one routine rather
than wrong picks, as far as read: KN6000 / KN6500 `Draw2BpFile_Impl` against 941's
`DrawBitmapFile_Impl` (the siblings draw 2-bit pictures there), `M3HookDispatch` against
`M3SetSpecialDispatch`; KN2400 `TgGlobalRegWriteB` against 941's `TgGlobalRegWriteBoth`,
`FxCategoryGet` / `DspPresetKeyKind`, `AcRcVolumeProc` / `AcMonitorOnProc` (1 call site; the
KN2400's reflection name).  Not settled further here.

One case checked by hand while the rule was being built: KN6000 0x4C08896C has the same body as
941's `TgEffectEnableBit14` and `TgMasterVolumeSubEnable` (both `TgEffectEnable*`-style bit
setters); its RAM operand maps to 941's 0x500C0758 and it sets bit 0x4000, so `TgEffectEnableBit14`
is right; a single aligned call site had suggested the other, which is why one aligned site is not
enough.

## Results

`../sibling-names-probes/sibling_name_census.py`, before (`census-2bde950fa.txt`) and after
(`census-after.txt`):

| model  | func_ (stats) before | after  | func_ starts before | after | named before | after | work RAM ops / addrs before | after          | uncached 0x90 before | after   |
|--------|----------------------|--------|---------------------|-------|--------------|-------|-----------------------------|----------------|----------------------|---------|
| KN6000 | 10,061               | 9,917  | 5,784               | 5,678 | 2,677        | 2,785 | 20,128 / 2,996              | 17,752 / 2,524 | 117 / 34             | 73 / 18 |
| KN6500 | 10,116               | 9,972  | 5,810               | 5,704 | 2,684        | 2,792 | 20,164 / 3,006              | 17,788 / 2,533 | 117 / 34             | 73 / 18 |
| KN2400 | 11,645               | 11,340 | 6,765               | 6,538 | 3,192        | 3,420 | 23,931 / 3,565              | 20,931 / 2,940 | 113 / 35             | 71 / 21 |
| HD-SX3 | 768                  | 765    | 461                 | 459   | 177          | 179   | 0 / 0                       | 0 / 0          | 0 / 0                | 0 / 0   |

Where the names came from (`<model>_aligned.sym`, `<model>_ram.sym`; the reports in each
`<model>/notes/`):

| model  | aligned: call site | aligned: same body | RAM = (941) | accessor     | owner R_Ram     | routine pairs | RAM pairs |
|--------|--------------------|--------------------|-------------|--------------|-----------------|---------------|-----------|
| KN6000 | 82                 | 26                 | 8           | 25 (290 ops) | 458 (2,042 ops) | 4,398         | 1,613     |
| KN6500 | 81                 | 27                 | 9           | 25 (289 ops) | 458 (2,042 ops) | 4,492         | 1,636     |
| KN2400 | 182                | 46                 | 8           | 21 (125 ops) | 613 (2,805 ops) | 6,159         | 2,258     |
| HD-SX3 | 1                  | 1                  | 0           | -            | -               | -             | 0         |

The backup-SRAM operands (0x84) are unchanged: none of their users is a named accessor or sole
owner yet.  The KN2400's RAM-linked tone-generator library (the twin of the library 941 links at
0x4C000000) gained the most: of 941's 544 routine names in that library, the KN2400 had 332 at
2bde950fa and has 418 now (`missed-*.txt`, the `--a-range` tables); 36 of the rest are short
twins whose RAM operands the map does not pair yet, 76 have no same-body routine there.

## Why the RAM figures are still large

`notes/ram-names-report.md` gives, per model, why an address stays a number: most RAM addresses
are spelled by several routines, or by one routine that is still `func_<ADDR>`.  An owner name says
only who spells the address, not what it holds; an accessor name says what the firmware calls it.
941 itself names few RAM variables (`kn7000_manual.sym`: 34), so the RAM pairs
(`notes/ram-map-kn7000.tsv`: KN6000 1,613, KN6500 1,636, KN2400 2,258 pairs) carry 6 to 9 names
each today; every RAM name the KN7000 gets later reaches the siblings by a re-run of
`aligned-names`.  The same holds for routines: `notes/routine-map-kn7000.tsv` lists every routine
pair, among them the 1,797 / 1,888 / 3,110 pairs where 941 names neither routine.

## Items

| item       | outcome | in one line                                                                                                                      |
|------------|---------|----------------------------------------------------------------------------------------------------------------------------------|
| N-02383279 | OPEN    | KN6000 func_ 10,061 -> 9,917 (108 names by call site / same body); next: 941 names via the routine map, per-subsystem naming     |
| N-a6b3dca1 | OPEN    | KN6500 func_ 10,116 -> 9,972 (108 names); next as N-02383279                                                                     |
| N-391deec6 | OPEN    | KN2400 func_ 11,645 -> 11,340 (228 names; RAM-linked TG library 332 -> 418 of 941's 544); next as N-02383279                     |
| N-8fce01b1 | OPEN    | KN6000 numeric work-RAM operands 20,128 / 2,996 -> 17,752 / 2,524 (491 names); next: KN7000 RAM names via the RAM map, accessors |
| N-cccf0416 | OPEN    | KN6500 20,164 / 3,006 -> 17,788 / 2,533 (492 names); next as N-8fce01b1                                                          |
| N-dc17693c | OPEN    | KN2400 23,931 / 3,565 -> 20,931 / 2,940 (642 names); next as N-8fce01b1                                                          |

The register quotes the 2026-11-02 figures (10,098 / 10,153 / 11,678 func_ and 19,019 / 19,055 /
22,483 RAM operands); the "before" figures here are the same quantities measured on 2bde950fa by
the committed probe (the func_ ones moved since 2026-11-02 with other lanes' names; the RAM ones
were counted by an uncommitted script).

## Next steps

- KN7000 names first: a 941 name given to a routine of `routine-map-kn7000.tsv` (or a RAM name of
  `ram-map-kn7000.tsv`) reaches the sibling by `make aligned-names` and the regeneration above.
  The maps also run the other way: the rows where B is named and 941 is not (`-` in the A column)
  are candidates for the KN7000 (lane kn7000-research; `port_sibling_names.py` judges by body, these
  by call site).
- `gen_data_s.py` (lane mn10300-data3): add `<model>_aligned.sym` and `<model>_ram.sym` to the
  sibling profiles' `syms`, so `functions.sym` sees their names (today the tools keep the files
  disjoint by construction: both read `functions.sym` as names).
- The `kept<8, A twins 1, B open 1` class (unique short bodies with no RAM operand or named callee
  to confirm them) is not carried: a two-instruction body unique among 15,000 starts is weak
  evidence alone.
- Per-subsystem naming of what has no KN7000 counterpart (KN2400 SD-card and help screens, the
  KN6000 / KN6500 XAPR and HD code), from MILK messages and strings, as before.

## Website page draft

*For the technics-docs pages `kn6000-disassembly.md`, `kn2400-disassembly.md` (or the MN10300
siblings' overview), section "Names" (text only; the integrator publishes it).*

**Where the names come from.** The KN6000, KN6500 and KN2400/KN2600 programs carry part of their
own names: the MILK framework's reflection tables name about 1,250 to 1,500 procedures per image,
and its function tables some 550 more.  Most other names are carried over from the KN7000, whose
program shares much of their code.  A routine whose code is the same as a named KN7000 routine
takes its name; since November 2026 a routine too short to be told apart by its code alone (a
getter, a flag setter) takes it too when the routines that call it are the same on both sides and
call it at the same place, or when it uses the same variables.  Variables are named the same way:
from the KN7000 when the same instruction of the same routine uses them, from the firmware's own
accessor routines (`GetSeqSongNo` reads `SeqSongNo`), or after the one named routine that uses
them.
