# Names carried into the KN7000 from the other MN10300 images

`../../tools/port_sibling_names.py` names KN7000 program-941 routines that are still
`func_<ADDR>` when another image in this tree names the same routine. The other images are
the MN10300 siblings (KN2400/KN2600, KN6000, KN6500, HD-SX3), whose names come from the
firmware's own MILK reflection tables, plus the KN7000's IC18 boot ROM and the KORG Style
Convert converter, whose names were read from their code (`kn7000_ic18.sym`,
`cnv_manual.sym`). The siblings' `*_ported.sym` files are not read, because those names
came from the KN7000 in the first place.

The comparison is `../../tools/fn_similarity.py`. It takes a whole routine body, meaning every
instruction that control flow reaches from the entry, with relocations masked. Its header
gives the three match classes and the conditions a name must meet before it is carried:

- the two routines must each be the other's best match;
- that match must beat the next one by a clear margin;
- no aligned callee or string may disagree.

## Files

| file           | written by              | what it holds                                                                                                  |
|----------------|-------------------------|----------------------------------------------------------------------------------------------------------------|
| `accepted.tsv` | `port_sibling_names.py` | every name carried: KN7000 address, name, class, source image and address, scores, the other images that agree |
| `differs.tsv`  | `port_sibling_names.py` | routines another image names that the KN7000 already names otherwise, by the same rules (nothing is renamed)   |
| `report.md`    | `port_sibling_names.py` | counts: carried per image and class, not carried per reason, and the audit                                     |
| this README    | by hand                 | how to read the three                                                                                          |

The names themselves go into the GENERATED section at the end of `kn7000_manual.sym`, one
row per name, with the image and address it came from and the class. A second run of the
tool rewrites that section, and so does a run after `make program-src`. Each run gives the
same result, because names the tool wrote earlier count as unnamed again.

    cd kn7000
    python3 tools/port_sibling_names.py --unidasm ../../tools/unidasm \
        --cache $TMPDIR/kn7000-fn-similarity
    make program-src symbols-sp7001 program-src-sp7001 xap-src-sp7001 cnv-src ic18-src

## How to read `report.md`

**The audit** is the error measurement. Some names are given by both images already. For
each such name, the rules are run on the other image's routine as if the name were new. A
`right` pick is the routine the KN7000 gives that name; a `wrong` pick is a different routine.

The run of 2026-11-02 (lane mn10300-names) leaves one `wrong` pick: KN2400's
`FilePriorityFunc` picks the KN7000's `SdcPanelSwAsFunc`, the two bodies equal and each the
only one of its kind on its side.  It is a template twin, not a naming error (settled 2026-11-06,
lane kn7000-names, `../kn7000-names-probes/names_choice_func_lists.py`): both are MILK
choice-parameter handlers, whose MT_GetRamString copies choice (obj+0x10) out of a string-pointer
table and whose MT_GetMax returns the last choice number.  The masked comparison hides the table.
KN2400 `FilePriorityFunc` lists {TECHNICS, SMF} (max 1; the KN2400 has no CUSTOM STYLE), the
KN7000's `FilePriorityFunc` {TECHNICS, SMF, CUSTOM STYLE} (max 2) and its `SdcPanelSwAsFunc`
{SD-AUDIO, SD-SOUND} (max 1).  Two two-entry lists give equal bodies; each image's name is
right for its own routine.  (KN2400 `SdcPanelSwAsFunc` is a `clr d0; retf` stub.)

The 2026-10-24 run had 19 `wrong` picks, all from KN2400 and all but `FilePriorityFunc` in its
SD-card screen table (`Sdc*`); for example KN2400's "`SdcSoundTtlJgFunc` (0x48718C9E)" was the
KN7000's `SdcNewPlaylistInfoFunc`.  The KN2400's table was the one paired wrongly: its
identifier run (90) is shorter than the 111 entries InitializeBlock33 registers, and the
end-aligned pairing of the time named the last 90 code pointers.  `gen_symbols.py`'s start
alignment (2026-10-29, 8037f3750) fixed it; 0x48718C9E is `SdcNewPlaylistInfoFunc` in
`kn2400.sym` since.  That same change shifted three KN6000 / KN6500 tables the other way (3 of the KN6000's 21
tables and 3 of the KN6500's 22, among them the Se table: 89 / 90 `wrong` picks per image in a
run before the fix).  Their code runs are longer than their names because other tables' pointers
lead them, and the firmware registers the code array at the run's start + 16 (KN6000
0x4C37EEF0 for the Se table).  So `gen_symbols.py` now takes the code-array start the image's
registering call loads a few bytes before the name array's address, and the start of the run
only when nothing names one (`_registered_code_start`).  KN7000 941, 942's plug-in, KN2400 and
HD-SX3 write the same symbol files with it; `kn6000.sym` / `kn6500.sym` change in those three
tables.  `../mn10300-names-probes/names_reflection_table_dump.py` prints a table's pairing.

**Not carried** counts each name of the other image that found no home, by the first rule it
failed:

- `name already in B`: the KN7000 has the name, which is most of them;
- `no candidate in B`: no KN7000 routine shares enough instruction 3-grams;
- `too little unmasked content`: fewer than 8 instructions are left once relocations are
  masked;
- `not the best match back in A`: the KN7000 routine matches some other routine of the
  image better;
- `best match in B is named or already carried`: the routine is listed in `differs.tsv`
  when its KN7000 name differs.

## What `differs.tsv` says

The 2026-10-24 rows that are settled: KN6000 / KN6500's `TgcBufWrite` is now the KN7000's
name too (it was `SndCmdStreamWrite`, a hand name; renamed 2026-11-02), and KN2400's
`SdcTechFolderCopyFunc` row went with its table's pairing.  IC18's `BootKeyComboProbeShadow` /
the KN7000's `PanelTypeProbeShadow` and KN2400's `crt0_start` / the KN7000's `ResetEntry` are
hand names on both sides; `TEST2FUNC` and the rest are the KN7000's `Test2Func` and the rest,
the same reflection names in another case.  `differs.tsv` lists the current rows.

## Follow-ups

- (settled 2026-11-02) Which SD-card reflection table was mispaired: the KN2400's (above).
- (done 2026-11-02) `SndCmdStreamWrite` renamed to the firmware's `TgcBufWrite`.
- (settled 2026-11-06) KN2400 `FilePriorityFunc` = KN7000 `SdcPanelSwAsFunc` by body: both names are right, the
  bodies differ only in their choice lists (above).
