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

The `wrong` picks all come from KN2400, and all but one are in its SD-card screen table
(`Sdc*`). The exception is `FilePriorityFunc`, which picks the KN7000's
`SdcPanelSwAsFunc`. In every such case the two bodies are equal or near-equal, and each is
the only routine with that body on its side. So the disagreement is between the two images'
symbol files, not a weakness of the matcher.

One example: KN2400's `SdcSoundTtlJgFunc` (0x48718C9E) and KN7000's
`SdcNewPlaylistInfoFunc` (0x4855BAC5) are the same 19 instructions, with every number of
0x10000 or more masked. KN7000's own `SdcSoundTtlJgFunc` is a different, 8-instruction
routine. One of the two images' SD-card reflection tables is therefore paired wrongly by
`gen_symbols.py`. Which one is open (see Follow-ups).

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

## What `differs.tsv` says (2026-10-24)

- KN6000 and KN6500 call the KN7000's `SndCmdStreamWrite` (0x4C003A60, a hand name)
  `TgcBufWrite`, which is the firmware's own name, from their reflection tables. The match
  class is skeleton. The KN7000 name was not changed, because other notes and the generator
  use it; it is a candidate for renaming.
- KN2400's `SdcTechFolderCopyFunc` falls on the KN7000's `SdcFmmPrivateSmfFileNameFunc`, the
  same SD-card table question as in the audit.
- IC18's `BootKeyComboProbeShadow` is the KN7000's `PanelTypeProbeShadow`, and KN2400's
  `crt0_start` is the KN7000's `ResetEntry`. Each is a hand name on both sides.
- `TEST2FUNC` and the rest are the KN7000's `Test2Func` and the rest: the same reflection
  names in another case.

## Follow-ups

- Decide which image's SD-card reflection table is mispaired (KN2400 or KN7000). Compare
  each table's code-array order with its name-array order, and check the bodies against what
  the names say: a `*TtlJg*` routine should answer the title-draw message.
- Rename `SndCmdStreamWrite` to the firmware's `TgcBufWrite` once its users are updated.
