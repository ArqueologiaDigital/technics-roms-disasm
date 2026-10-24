# v10 header comments in v9 and v7

The KN5000 documentation passes mostly worked in `v10/maincpu`. CLAUDE.md's multi-version sync
policy wants the same comment on the same code in every version. This folder holds the evidence
of carrying v10's header blocks to `v9/maincpu` and `v7/maincpu`.

The tool is `scripts/tools/propagate_v10_headers.py`. Its docstring gives the rules a comment
must pass before it is copied: equal body text, equal ROM bytes except for relocated addresses,
and header text that holds for the target build.

## Commands

| question                                                              | command                                                                                                 |
|-----------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| How many v10 labels with a header have one in v9 / v7?                | `python3 scripts/tools/propagate_v10_headers.py --count`                                                |
| What would be copied, and what goes to review? (dry run)              | `python3 scripts/tools/propagate_v10_headers.py`                                                        |
| Copy, then write the review list                                      | `python3 scripts/tools/propagate_v10_headers.py --apply`                                                |
| Did the edit only add comments? (code lines and old comments)         | `python3 scripts/tools/propagate_v10_headers.py --verify HEAD`                                          |
| Did any byte move?                                                    | `make -j3 gate`                                                                                         |
| Calibrate address translation (dry run)                               | `python3 scripts/tools/propagate_v10_headers.py --no-translate`                                         |
| Where does v7 keep a v10 RAM address?                                 | `python3 scripts/analysis/v7_ram_shift_map.py --min-obs 2`                                              |
| Does a v7 header written since BASE quote a v10 RAM address v7 moved? | `python3 scripts/tools/propagate_v10_headers.py --check-ram 908218944`                                  |
| Re-examine (and with `--apply`, fix) every comment written since BASE | `python3 scripts/tools/propagate_v10_headers.py --audit 908218944 [--apply]`                            |
| Which headers were proved only on a routine's entry fragment?         | `python3 scripts/tools/propagate_v10_headers.py --extent-report 908218944`                              |
| Draft a hand port (first guess, for a person to finish)               | `python3 scripts/tools/draft_handport_headers.py LABEL ...`                                             |
| Is v10 routine X the same code as v7 routine Y?                       | `python3 scripts/analysis/v7_routine_equivalence.py X=Y=NBYTES`                                         |
| Apply the hand ports (idempotent)                                     | `python3 scripts/tools/apply_handported_headers.py analysis/header-propagation/handport-2026-10-24.txt` |

The dry run, `--apply`, `--audit`, `--check-ram` and `--extent-report` read the linked ELFs in
`rebuilt_ROMs/`, so run `make all` first. `908218944` is the commit this lane branched from (the
state before any header was propagated).

## Measured 2026-10-24

`--count`. A label is counted when the line directly above it is a `;` comment line.

| tree | v10 labels with a header | label present | with header, before | after pass 1 | after pass 2 | after pass 3 | after hand ports | after review audit | after re-ports | without, now |
|------|--------------------------|---------------|---------------------|--------------|--------------|--------------|------------------|--------------------|----------------|--------------|
| v9   | 9,610                    | 9,607         | 8,381               | 9,585        | 9,599        | 9,599        | 9,599            | 9,599              | 9,599          | 8            |
| v7   | 9,610                    | 9,254         | 8,101               | 8,765        | 8,929        | 8,970        | 9,062            | 9,010              | 9,024          | 230          |

Three automatic passes were made with `--apply`. Pass 1 compared bodies with whitespace and hex case
normalized. Pass 2 also normalized number bases and register case, split `Label: insn` lines, and
added the byte proof for spans the trees spell differently. Pass 3 worked on the review list. It
added the RAM-remap tier (below), dropped an explicit `t,` condition (`jr t, X` = `jr X`), and
matched pointers by a shared label name as well as by translate_addr. The last two columns are the
review round described under "Review round" below.

| pass | tree | headers inserted | of them byte-proven | headers extended | addresses translated | trailing comments | in-body comment runs |
|------|------|------------------|---------------------|------------------|----------------------|-------------------|----------------------|
| 1    | v9   | 1,204            | 0                   | 85               | 0                    | 10                | 4                    |
| 1    | v7   | 664              | 0                   | 62               | 17                   | 25                | 20                   |
| 2    | v9   | 14               | 8                   | 0                | 0                    | 12                | 0                    |
| 2    | v7   | 164              | 108                 | 1                | 7                    | 161               | 9                    |
| 3    | v7   | 41               | 4                   | 0                | 0                    | 0                 | 4                    |

- **Headers extended** means the target's header was a subsequence of v10's (v10 had added to it)
  and was replaced by v10's. Nothing was removed.
- **Addresses translated** counts headers that quote a v10 ROM address and were copied with the
  target build's address. A translation is accepted only when the bytes from the nearest label
  the two builds share up to that address are the same code.
- **Byte-proven** headers sit on spans that the two trees spell differently, for example
  `.incbin` against record macros, `.long Sym` against `.byte`, or `pushw 0xff` against
  `pushw 255`. Each such span has the same length and the same bytes, and every differing pointer
  is the target's translation of v10's. Headers that talk about the source text (`.byte`,
  "spelled", "below") are refused there.
- **RAM-remap tier (pass 3, 37 of the 41 v7 headers).** A body passes when its lines pair up and
  differ only in RAM operands. Those are literal numbers below 0x40000 that are less than 0x400
  apart (v7 keeps one region 156 bytes lower), moved `.equ` values, or call targets that are the
  same routine under another name. The bytes must differ only there and in relocated pointers.
  The header is then copied with each such RAM number rewritten to v7's. Any other 3-5-digit
  hex number in it must be spelled in the body, or the header is refused. Each port is a
  `ported-ram-remap` row in the review list, with its mapping. Calibration: three v7 headers
  that an earlier session had ported by hand (`Rhythm_DispatchNoteFromFC5A`,
  `Rhythm_StoreDispatchHelperResult`, `AccChannel_ResetCurrentState`) are exactly what the tier
  produces.
- **Calibration of the translation rule.** 336 v7 headers match v10's only after address
  translation. This lane wrote 24 of them (17 + 7). The other 312 were adapted by earlier hand
  ports, and the rule reproduces each of them exactly. To reproduce the count, run the v7 dry run
  with and without `--no-translate` and subtract the `header-already` figures. After pass 2 that
  was 8,134 - 7,798 = 336. After pass 3 it is 8,153 - 7,816 = 337.

## Hand ports: handport-2026-10-24.txt

After pass 3, 131 v7 review-list labels had a v10 header and none in v7, and their bodies differ
(`body-differs` or `bytes-differ`). All 131 were read one by one. 92 were ported and 39 were
recorded as not ported. Each decision has its reason in `handport-2026-10-24.txt` and in the
review list's `handport` column. (The review round below withdrew 2 of the 92 as label restatements,
and added 16 entries, 14 of them ports.) A port adapts the header only in these ways:

- **RAM numbers.** A RAM number is rewritten to v7's value when the pair is read from the two
  bodies, or else from the measured map `v7-ram-shift-2026-10-24.txt`. The map was made by
  `scripts/analysis/v7_ram_shift_map.py --min-obs 2` from paired memory operands. The committed
  output is authoritative: v10 0x00109-0x029F6 unmoved (816 addresses, 10,743 observations),
  0x0321C-0x0E38E at -156 (1,342 / 13,922), 0x0E3DC-0x0EC11 at -198 (33 / 311) and
  0x0F180-0x3F2F8 unmoved (603 / 5,513). The gaps between those runs are unmeasured, and no port
  relies on them. (Earlier text here, and commit afd0add34's message, quoted wider ranges and
  larger counts -- 0x0100-0x29F6, 0x3214-0xE38E, 0xE3BA-0xEC11, 1,008 / 1,627 / 44 / 724
  addresses -- that no committed version of the script produces; those figures are withdrawn.)
- **Numbers that are not RAM addresses are kept.** These are parameter ids (0x4000-0x428E,
  0x5000), lengths, error codes, the 0x55AA boot signature, offsets into the 0x1E0000 sound-RAM
  image and sub-CPU addresses. A first draft remapped some of them by the map, and those were
  reverted by hand.
- **Callee names.** v7 sometimes calls the same routine under a placeholder name. The header
  then names v7's label, but only after the two routines were shown to be the same: equal ROM
  bytes modulo the RAM map and relocated pointers. The pairs used, and the two whole-span checks
  (FDC_CMD_EXEC over 672 bytes and CmpRealTtl_EnterTitle_Impl), are in
  `callee-equivalence-2026-10-24.txt`. That file is the output of
  `scripts/analysis/v7_routine_equivalence.py` run on those pairs.
- **Drafts.** The entries were first drafted by `scripts/tools/draft_handport_headers.py`, which
  maps every RAM-range number and renames differing callees, and were then corrected by hand.
- **Decimal RAM addresses** (FDC_CMD_EXEC, AccPart_GetParamAddr_Wrap) are rewritten the same way.

A header is not ported when it names a symbol v7 does not define, or when v7 frames the code
differently (FDC_INTERRUPT_HANDLER, SeMenu_ToggleSolo). It is also not ported when its sentence
needs rewording rather than translation (MidiPkt_SendCtlValueSysEx). Those rows remain as
follow-ups. Most of them first need v7 labels harmonized with v10's names.

## Review round (2026-10-24): RAM numbers, address notes, restated labels

A review of the branch found v10 RAM addresses copied verbatim into v7 headers although v7 keeps
those variables 156 or 198 bytes lower. One example is `PanelLed_PendingGroup1Handlers` saying
0x8F3A where v7's code reads `(0x8e9e:16)`. There were two causes. `adapt()` translated or refused
only ROM addresses, and checked RAM numbers only in the RAM-remap tier. And the remap tier rewrote
only `0x` hex, so decimal RAM addresses and `8A40h` stayed as v10's.

**The rule now (`RamMap.decide`, v7 only; v9's RAM layout equals v10's).** It covers every 4-5-digit
hex number (`0x8F3A`, `8A40h`) and every 4-5-digit decimal number in a comment that travels to v7.
Numbers below 0x100, at or above 0x40000, or in an unmoved run of
`v7-ram-shift-2026-10-24.txt` are left alone. So is a number that the compared body spells. A number
in a moved run is rewritten to the moved value only when v10's code spells the number and v7's code
spells the moved value but not the number itself. The other case that rewrites is paired code: the
measured observations must show that very address moving by that delta. A number is kept as a
constant when v7 spells it, never as a memory operand, and never spells the moved value. This keeps
parameter ids such as 0x4002, which v7 also spells. Everything else is refused as
`quotes-ram-address`. A number that both trees spell does not prove a constant, because addresses
are loaded as immediates (`ld xix, 0x3692`).

**What `--audit 908218944 --apply` changed** (output: `audit-2026-10-24.txt`). The audit re-examined
the 1,024 v7 headers and 1,303 v9 headers this lane wrote. In each header, the candidates were the
numbers that also appear verbatim in v10's header. Hand ports were exempt from the RAM rule, because
their notes judge every number.

| change                                                           | v7 | v9 |
|------------------------------------------------------------------|----|----|
| headers whose RAM numbers were rewritten to v7's                 | 95 | 0  |
| headers withdrawn, `quotes-ram-address`                          | 16 | 0  |
| headers withdrawn, `restates-label` (2 of them hand ports)       | 36 | 0  |
| header lines that lost an inline address note (`Foo (0xEF97B6)`) | 6  | 0  |

`--check-ram 908218944` is the review's flagging criterion as a script. A token is flagged when it
appears verbatim in v10's header and v10's code spells it, while v7's code never spells it but does
spell the value minus 156 or 198. Before the audit it flagged 116 tokens in 67 headers: the review's
104 hex tokens in 63 headers, plus 11 decimal tokens and one `8A40h` in 4 FDC and title headers that
the remap tier had ported. After the audit it flags 0 (`check-ram-before-2026-10-24.txt`,
`check-ram-after-2026-10-24.txt`).

The 16 withdrawn headers were then read by hand, and 14 were re-ported. Their entries are the last
section of `handport-2026-10-24.txt`:

- The LED-row headers take ENCODER_STATE_BASE + row, using v7's base 0x8e7c.
- The scale-tune and DSP headers quote parameter ids, which were kept.
- The grid-row headers take the bit-map rows at 0x3692/0x3696/0x369A, read from v7's
  SqStep_BuildCurrentRowBitmap and Display_RedrawSidePanel.
- The transfer-descriptor headers take 0xBC40/0xBC50, and drop a stale v10 line number.

Two were not ported: `AccompSeq_MidiFilterCodeBlock_Step2`, whose comment is v10's own edit history,
and `Str_20469e32473220`, whose comment gives offsets into v10's NAKA blob. A plain `--apply` under
the new rules wrote one more header, `Rhythm_InstrMapTable_D4`, with its RAM numbers mapped to v7's
0x323C / 0x3258. It also regenerated the review list. Before the audit, v7 had 9,062 headers. The
audit withdrew 52 (9,010), and the re-ports added 14 (9,024).

**Inline address notes and restated labels (plan() and adapt() now apply both).** A parenthesised
ROM address that follows a defined symbol is dropped, not translated. A header whose words are all
words of its label is not copied (reason `restates-label`); camel case, underscores, prefixes and a
short abbreviation list (`ctrl` = control, `app` = application, ...) count as the same word. One
example is `; Rhythm parameter type check` above `RhythmParam_TypeCheck`. A header that names an
original firmware function, such as `MainCmpSetFunc init`, says more than its label and is kept. The
note rule also adds review rows: v7 and v9 headers that predate this lane and carry translated
inline address notes no longer equal v10's text, so they now show as `existing-header-differs`. They
are left as they are, for a later clean-up of the notes in all three trees.

## Caveat: a header is proved over its label's span, which can be a fragment

`Tree.span` ends a body at the first column-0 label that does not extend the label's name. A routine
whose loop or join labels are spelled otherwise is therefore compared only up to that label. For
example, `MidiSysMsg_Handler_OnF3ShortDeltaTime` was compared over 4 lines, up to
`MidiSysMsg_Handler_Loop2`. Its header describes code further on. The RAM rule above checks numbers
against the whole tree's code, not the span, so RAM numbers are covered. Other statements about the
code past the span are not proved.

`--extent-report 908218944` measures this. It defines a routine's real extent as the span extended
through every following label that only the extent itself references. The output is
`fragment-span-2026-10-24.tsv`:

| tree | headers written by this lane | real extent longer than the span | text over it differs, RAM operands only | differs otherwise |
|------|------------------------------|----------------------------------|-----------------------------------------|-------------------|
| v9   | 1,303                        | 878                              | 1                                       | 4                 |
| v7   | 987                          | 680                              | 67                                      | 101               |

"Differs otherwise" does not mean that the header is wrong. Spot checks show four kinds of
difference: v7's own framing (`.Lc_` local labels, a routine split or folded differently), label
names (`SndParamF9A541_ResBit7_Code_Join` against `ExtData_VoiceParam_DispatchBytecode_Join`),
spelling (`.long X` against `ld xbc, X`), and real code differences. The 105 rows are a follow-up
list for reading by hand. The BODY proof was not widened, because widening it would withdraw these
headers wholesale, not just the wrong ones.

## review-2026-10-24.tsv

These are the labels the tool would not copy. There is one row per (target, label). The columns:

| column     | meaning                                                                                                                                                                                                                                                              |
|------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `target`   | `v9` or `v7`                                                                                                                                                                                                                                                         |
| `label`    | the label, defined in both trees unless `reason` is `label-absent`                                                                                                                                                                                                   |
| `reason`   | why it was not copied (see below)                                                                                                                                                                                                                                    |
| `detail`   | the first difference, or the offending token                                                                                                                                                                                                                         |
| `src_line` | v10 file:line of the label, at the time of the run                                                                                                                                                                                                                   |
| `dst_line` | target file:line of the label, at the time of the run                                                                                                                                                                                                                |
| `ndiff`    | `body-differs` only: normalized code lines that differ                                                                                                                                                                                                               |
| `nlines`   | `body-differs` only: normalized code lines in the longer body                                                                                                                                                                                                        |
| `handport` | `hand-ported: ...` / `not ported: ...` (written by apply_handported_headers.py from the handport file), or `scripted (RAM remap tier)` for that tier's ports. Records a port, or a decision not to port, and why. Rows with it are kept when the list is regenerated |

| reason                    | meaning                                                                                  |
|---------------------------|------------------------------------------------------------------------------------------|
| `body-differs`            | the code from the label to the next unrelated label differs                              |
| `bytes-differ`            | same text but different ROM bytes, e.g. an `.incbin` of a different file                 |
| `existing-header-differs` | the target already has a different header. It is kept and not duplicated                 |
| `quotes-rom-address`      | quotes a v10 ROM address whose target address could not be proved, or a literal constant |
| `quotes-source-line`      | quotes `file.s:NNNN`. Line numbers move with every edit and are never translated         |
| `mentions-version`        | names v7, v9, v10 or a version                                                           |
| `names-absent-symbol`     | names a symbol that v10 defines and the target does not                                  |
| `header-text-elsewhere`   | a long header line already occurs elsewhere in the target file                           |
| `dump-of-differing-bytes` | contains a `; \|....\|` byte dump, and the bytes differ                                  |
| `spelling-differs`        | a byte-proven span whose header talks about the source text, which is what differs       |
| `ported-ram-remap`        | not a refusal: ported by the RAM-remap tier; `detail` is the v10 -> v7 RAM mapping       |
| `label-absent`            | the target has no label of that name; a job for `harmonize_version_labels.py`            |
| `quotes-ram-address`      | quotes a RAM number in a range v7 moved, not shown to be v7's (see Review round)         |
| `restates-label`          | the header's words are all words of the label; it adds nothing                           |
