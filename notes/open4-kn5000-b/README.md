# Lane open4/kn5000-b (wave 4, 2026-10-31): the unowned ACTIONABLE tracker issues

Base: main at 130735749.  The lane's items were every `kn5000-*` tracker issue that
`notes/open-items/REGISTER.md` marks ACTIONABLE and unowned: 33 task issues and the epics 3go, dnl,
nca, 9m6 (plus the epic-like 8z5, ake and z9k).  The work was split into nine sub-lanes, each in its
own worktree and branch off the base (accvar off the merged branch at 25e39bb77), merged here with
`--no-ff`.  Each sub-lane has its own README (findings, evidence, probes, one "Website page draft" per
issue) and an `issue-comments.json` holding the tracker comment and any proposed new issues; the lane
lead applied those to `.beads/issues.jsonl` with `scripts/tools/issues_jsonl_update.py` (comments)
and `scripts/tools/issues_jsonl_create.py` (new issues).

No tracker issue is closed here.  "CLOSED" below means the repo-side work the issue and its triage
plan ask for is committed and the website text is drafted; the integrator's docs lane publishes the
drafts into technics-docs and then closes the issues (repo-root CLAUDE.md "Issue Closure
Requirements").

| sub-lane | notes                                                  | issues                              |
|----------|--------------------------------------------------------|-------------------------------------|
| cpanel   | [cpanel/README.md](cpanel/README.md)                   | bq4, 9ye, 3c7, xhi, z9k             |
| midi     | [midi/README.md](midi/README.md)                       | 81p, 5ck, ake, 8dy, cox             |
| display  | [display/README.md](display/README.md)                 | ezo, rq0, 5dc, nmg, 8z5             |
| hdae     | [hdae/README.md](hdae/README.md)                       | 44c, t8n, e7f, mzz, qnf             |
| tools    | [tools/README.md](tools/README.md)                     | 0bq, waa, 87m, dkx, 3ei             |
| engine   | [engine/README.md](engine/README.md)                   | rlb, wgc, 98j (chord recognition)   |
| accvar   | [accvar/README.md](accvar/README.md)                   | 98j (section switching, transposition) |
| hwaudio  | [hwaudio/README.md](hwaudio/README.md)                 | xel, jy9, mhj, 1oy                  |
| naming   | [naming/README.md](naming/README.md)                   | nl6                                 |

nl6's leads were shared out: ENCODER_STATE_BASE (cpanel), SysEx_BytecodeDispatcher (midi),
ChordDetect_* / RhythmVariation_InlineCode_Code / VoiceSlot_FinalRetZ / ToneGen_CompareVoiceBlocks
(engine), the HD-AE5000 leads (hdae), the rest (naming).

## Merging

Every sub-lane regenerated `symbols/` from its own build, so the reference files conflicted at the
naming merge.  They were resolved by rebuilding the merged tree and running
`python3 scripts/analysis/l2_symbol_reference.py --regen` (`--check` PASS).  hdae first renamed the
maincpu `HdaeRom_*` family as well and reverted that (11a3b6d5b) in favour of naming's `SoundRam_*`
names (3832a6dfc).  Sub-lane rename scripts: `scripts/renaming/rename_open4_{cpanel,midi,display,
hdae,engine,naming}.sed` (+ accvar's, if any); to replay them on a tree, apply them in merge order
cpanel, display (both before engine), engine, naming, midi, hdae, accvar.

## The epics

The rule for this wave: an epic, or a milestone issue whose children are separate issues, is
CLOSED when every child is CLOSED (repo side) or BLOCKED; otherwise it is BLOCKED on the named open
children.  Child states below are as of this lane's merge.

| epic       | children                                                                                   | outcome |
|------------|--------------------------------------------------------------------------------------------|---------|
| kn5000-8z5 | ezo CLOSED here; 3c5, hy8 closed; gln resolved                                             | CLOSED  |
| kn5000-z9k | xhi CLOSED here; bcn, jwk closed (analog pages: jy9, xel CLOSED here)                      | CLOSED  |
| kn5000-ake | 81p, 5ck CLOSED here; 0vs resolved                                                         | CLOSED  |
| kn5000-9m6 | 81p, 5ck, rlb, 44c, mhj CLOSED here; izk, 8ro, bqe resolved                                | CLOSED  |
| kn5000-dnl | 5dc, 3c7 CLOSED here; kev resolved; ima, kuu closed; 1vz, a0k, qhm BLOCKED (MAME upstream) | CLOSED  |
| kn5000-nca | waa, 87m CLOSED here; pkx, sf8, 5jy, 9zb resolved; 9jq, 4bt, aar, 9a0 closed; a8s BLOCKED (hardware baselines) | CLOSED |
| kn5000-3go | dnl, 9m6, nca CLOSED here; dbi BLOCKED (undumped wave ROMs, MAME audio)                    | CLOSED  |

What the epics still list that no child carries, and where it belongs:

- dnl's "UI navigation via keyboard/mouse", "floppy loading" and "custom styles load/save" **in
  MAME** are mamedev/mame work (its children 1vz, a0k and qhm hold the exact gaps).
- nca's and 3go's "MAME driver merged upstream" is met for the driver itself: kn5000 is in mainline
  MAME, and so is the panel HLE since mamedev/mame#15919.  Getting it to "working" is the open MAME
  work of 1vz, a0k, qhm and y18.
- nca's "all LABEL_* renamed" holds: `llvm-nm` over the 18 KN5000 ELFs of this lane's build finds
  0 `LABEL_` symbols.
- 3go's "all ROMs 100% byte-matching" holds (below).  "All subsystems documented" is the sum of
  this lane's drafts once the docs lane publishes them.

### kn5000-3go: "Current Status" refresh (text for the issue's notes / roadmap.md)

The 2026-08-08 status block of kn5000-3go is out of date.  As measured in this lane's worktree
(base 130735749 plus this lane's merges; `make gate` exit 0):

- **Byte-match.**  `scripts/build/compare_roms.py`: `romset bytematch: 100.00%`, 21 sections
  at 100.00%.  The sections are maincpu v10, v9, v8, v7, v6 and v5, sub-CPU payloads v1.42, v1.41
  and v1.40 with their update images, sub-CPU boot, table data, custom data, the four HD-AE5000
  versions, the rhythm data ROM IC14 and the wave ROM IC307.
- **Source coverage.**  `scripts/analysis/kn5000_source_coverage.py` reports 0 B verbatim debt
  for v10, v9, v7, v142, the sub-CPU boot, table data, custom data and all four HD-AE5000 versions.
  v6 has 13,756 B and v5 15,910 B, all of it `TODO(port)` rows.  Over the 13 KN5000 images that is
  99.8 % source.
- **Labels.**  `llvm-nm` finds 0 `LABEL_*` symbols in every KN5000 ELF.
- **Coverage ledgers.**  The dispatch-census and doc-quality ledgers are in `docs/coverage/`
  (repo-root CLAUDE.md); the integrator writes the snapshots after merging.
- **Still undumped or bad.**  The undumped wave ROMs IC304/305/306 block KN5000 audio (y18, dbi).
  The sub-CPU boot ROM IC30 is a bad dump, 97 % unread; one consequence is that it blocks
  identifying the 0x130000 chip (split from 1oy).
- **MAME.**  The kn5000 driver is in mainline MAME, with the panel HLE since mamedev/mame#15919.
  - The boot timeline measured in MAME (mhj, `hwaudio/probes/boot_timeline.txt`): the sub CPU
    enters its payload at 3.961 s and `AcWelcomScreenProc` runs at 7.749 s.
  - The open MAME gaps are tracked in 1vz, a0k, qhm, y18 and 0eo, and in technics-docs
    mame-emulation-gaps.md.

### Website page draft (kn5000-3go)

roadmap.md has no KN5000 phase table, so there is nothing to change there.  The status bullets
above replace the issue's "Current Status" block.  The only website figure involved is
rom-reconstruction.md's summary row, which is drafted in [tools/README.md](tools/README.md),
section 5 (kn5000-3ei).

## New issues created from the splits

Created with `python3 scripts/tools/issues_jsonl_create.py notes/open4-kn5000-b/{hwaudio,naming,engine,accvar}/issue-comments.json`
(no blocking dependency: each description says "Split from <parent>", and the parent's comment names
the new id).  engine's proposed "play-time section switching and pattern transposition" issue was not
created: accvar did the section switching and proposed the two narrower 98j issues instead.  The
comments on all 37 lane issues were applied from `tracker-spec.json` (this directory) with
`scripts/tools/issues_jsonl_update.py`.

| new issue  | split from | title                                                                                                                   |
|------------|------------|-------------------------------------------------------------------------------------------------------------------------|
| kn5000-ax7 | kn5000-1oy | uPD6383 decode: R1 cascade (bit-11 alternate lo12 encoding first, then f31 3..7, ACT 0x0B, addressing classes 0/1/4)    |
| kn5000-i2m | kn5000-1oy | Effects DSP: settle the reverb micro-topology (effects-dsp.md section 19)                                               |
| kn5000-a9y | kn5000-1oy | Identify the chip that decodes the sub CPU's 0x130000 register block                                                    |
| kn5000-wxn | kn5000-nl6 | WSA1 naming leads of 2026-10-06/07 not yet checked                                                                      |
| kn5000-rld | kn5000-nl6 | KN5000 generic-label batches g1/g3/g5: 100 records not reviewed                                                         |
| kn5000-j8z | kn5000-nl6 | KN5000: RhythmProc_ChannelMapTable is data spelled as code; MainSysCtrl case callees and the rest of HdaeRom_* misnamed |
| kn5000-a1f | kn5000-wgc | Song controller events 0xD0/0xD1/0xD3: which sub-CPU records they become                                                |
| kn5000-zc1 | kn5000-nl6 | Rename the VoiceSlot_* song-memory family in display/scoop_display.s                                                    |
| kn5000-1gu | kn5000-rlb | Main-CPU sender of sub-CPU system sub-command 0x09 (voice allocation mode A/B)                                          |
| kn5000-3qp | kn5000-98j | Accompaniment: transposition of rhythm-ROM pattern notes to the recognized chord (root shift, chord-type note rule)     |
| kn5000-rzg | kn5000-98j | Accompaniment: SYNCHRO & BREAK while running (break) and synchro stop                                                   |
