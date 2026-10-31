# prom_b 0xF44018-0xF477FF — the module that opens after the thunk table

Status: **converted**, 14,312 bytes (8,445 substantive + 5,867 bytes of `0x0E`
padding). The byte gate passes.

Reproduce:

    python3 notes/gen_prom_b_f44018_module.py --checks    # 30 rows, all byte re-reads
    python3 notes/gen_prom_b_f44018_module.py --copies    # every `ld XIX,0x00F460xx` site
    python3 notes/prom_b_module_trace.py 0xF44018 0xF47800
    python3 notes/prom_b_round2_frontier_delta.py         # the frontier arithmetic

---

## Why this range

`notes/prom_b_module_frontier.py` ranks three **adjacent** runs into it —
`T_F409C0-T_F40A30`, `T_F40A3C-T_F40A64`, `T_F40A6C-T_F40AC8` — with a summed
reference upper bound of 81 + 41 + 7 = **129**, the highest of any group in
prom_b. `T_Seq_RequestRewind -> 0xF4542D` (x24) and `T_F40A1C -> 0xF44367` (x15) are both in
`notes/prom_b_call_graph.py`'s top ten.

**64 slots point into the range, resolving to 62 distinct targets** — two slots
share a target. Both numbers are derived by `--checks`; see the unit note below.

## Both edges are pinned by something other than the decode

* **start** `0xF44018` is the first byte *after* the `0xF40000` thunk table,
  whose extent is fixed by `scripts/analysis/prom_b_thunk_table.py` and which the
  `.s` already converts;
* **end** `0xF47800` is itself a thunk target (`T_BStore_StepCursorToNextLeadByte`) — an address the
  linker chose — and the 5,867 bytes in front of it are pure `0x0E`.

Between them the two code segments decode with **zero** undecodable bytes and
each ends exactly on its segment boundary. Unlike most pad boundaries in this
image there is no `ret`-versus-padding ambiguity: the byte before the pad run is
`0x48`, not `0x0E`.

## `Dispatch_3629` — 5 pointers, two of them dead

`0xF45E9A`, read by one site: `ld XIX,0x00F45E9A` at `0xF45E87` (a byte scan
reports `0xF45E88`, that instruction's **operand** field), then `ld A,(0x3629)` /
`sll 0x02,XWA` / `add XIX,XWA` / `ld XIX,(XIX)` / `call XIX`.

The entry count is fixed **twice**, neither time by dividing an extent by a
guess:

1. entries **[3] and [4] both hold `0xF45EAE`**, which is the byte immediately
   after the table — so the table cannot reach past it;
2. a sixth entry would read `0xCA96F00E`, not an address in this image.

⚠ **[3] and [4] are dead.** A whole-image linear decode finds `(0x3629)` written
only with 0, 1 and 2 (at `0xF569CB`, `0xF569F4`, `0xF56A59` and nine more sites)
and compared only with 2. That is an upper-bound scan over a linear decode, not a
proof that no other writer exists — but nothing found selects [3] or [4], and
both of them point at the instruction the reader would fall into anyway.

## `WorkspaceDefaults` — and a partition deliberately left open

`0xF46074`, 161 bytes, the source of copy loops that seed the banked 3 KiB
workspace at `0x00603400` that `FINDINGS-prom_b-block-store.md` derives.

**Established, by reading the loops verbatim:**

| source     | destination  | length | loop                                                                           |
|------------|--------------|--------|--------------------------------------------------------------------------------|
| `0xF46074` | `0x00603400` | 8      | `ld A,(XIX+IY)` / `inc 1,IY` / `cp IY,7` / `jr ULE` — IY takes 0..7            |
| `0xF4607C` | `0x00603414` | 8      | `ld WA,(XIX+IY)` / `add IY,0x0002` / `cp IY,0x0008` / `jr C` — a **word** loop |

~~⚠ **Not established: how the other ~145 bytes are partitioned.**~~ (Resolved
2026-10-31, lane open4/wsa1-d: the whole object is partitioned, see the table
below; `prom_b/modules/f44018_f477ff_sequencer_core.s` `WorkspaceDefaults_*`.)
The loops in this module differ in stride (byte and word) and in bound form
(`cp IY,n / jr ULE` and `cp IY,n / jr C`), and the two do **not** mean the same
count. An automated read of them gave nine bytes for the `0xF4607C` block where
the instructions say eight, which is why the object was first emitted as one
labelled run.

### The partition (2026-10-31)

Every run starts at the `ld XIX/XIY,imm32` operand of its copy site and its
length is that site's loop bound, both re-read from the ROM by
`python3 notes/open4-d-probes/workspace_defaults_partition.py --selftest`
(FAILURES: 0). The runs abut with no gap and no overlap.

| run (label)                           | offset | bytes | element        | copied to                              | by                                                                        |
|---------------------------------------|--------|-------|----------------|----------------------------------------|---------------------------------------------------------------------------|
| `WorkspaceDefaults_Header8`           | +0x00  | 8     | byte           | `0x603400` (then 0 at +8)              | `BStore_TrackOutChannel_LoadDefaults` tail, `BStore_ResetWorkspaceFields` |
| `WorkspaceDefaults_Words4`            | +0x08  | 8     | 4 words        | `0x603414`                             | the same two routines                                                     |
| `WorkspaceDefaults_HeapDescriptor`    | +0x10  | 6     | long + word    | `BStore_HeapBase`, `BStore_BlockCount` | `BStore_BootPhase0` (0x00617800, 1292)                                    |
| `WorkspaceDefaults_HeapDescriptorAlt` | +0x16  | 6     | long + word    | the same                               | `BStore_BootPhase0`'s branch that `xor HL,HL / jr Z` never falls into     |
| `WorkspaceDefaults_TrackToPart`       | +0x1C  | 17    | byte per track | `BStore_TrackToPart`                   | `BStore_TrackToPart_LoadDefaults` (non-GM)                                |
| `WorkspaceDefaults_TrackToPartGm`     | +0x2D  | 17    | byte per track | `BStore_TrackToPart`                   | `BStore_LoadGmTrackDefaults`                                              |
| `WorkspaceDefaults_TrackOutNone`      | +0x3E  | 17    | byte per track | `0x603433`                             | both loaders when `(0x6034C7)` bit 1 is clear: all `0x20`, no OUT channel |
| `WorkspaceDefaults_TrackOutChannel`   | +0x4F  | 17    | byte per track | `0x603433`                             | `BStore_TrackOutChannel_LoadDefaults`, bit 1 set                          |
| `WorkspaceDefaults_TrackOutChannelGm` | +0x60  | 17    | byte per track | `0x603433`                             | `BStore_LoadGmTrackDefaults` and `sub_F45E14`, bit 1 set                  |
| `WorkspaceDefaults_SongName`          | +0x71  | 6     | 3 words        | `BStore_SongName`                      | `BStore_SongName_LoadDefault` (`ld BC,3 / ldirw`): `"______"`             |
| `WorkspaceDefaults_SixteenthTicks`    | +0x77  | 4     | byte           | `Seq_BeatTick`                         | `Seq_LocateToSongPosition`, indexed by position & 3: 0, 24, 48, 72        |
| `WorkspaceDefaults_UnreadTail`        | +0x7B  | 38    | byte           | nothing                                | no operand in prom_a or prom_b points into it                             |

The 38-byte tail repeats the last 11 bytes of a 17-byte track table, a whole
one, the song name and the four ticks: the shape of a longer default block of
which only the runs above are read. The probe's byte scan of both CPU-1 images
finds one 24-bit value inside it, prom_a `0xF8E21C`, which is the last byte of
`cp BC,0x0014` and the `jr LT` after it, not an operand.

⚠ `notes/gen_prom_b_f44018_module.py` emitted this module once; the source has
been edited by hand since (naming waves, this partition), so its plain emit now
refuses and `--stale-emit` prints the original text. `--checks` and `--copies`
still run, given a working `unidasm`.

## The routines

130 labels: 128 `sub_XXXXXX` plus the two data objects. Every header's
`Called from`, `Touches` and `Calls` list is read out of the proven
transcription's own decoded comments. What any of them **do** is not established.

## ⚠ State the unit — this module is why

`notes/prom_b_call_graph.py`'s header said *"UNCONVERTED prom_b thunk targets"*
until 2026-08-25 while it printed one row per **slot**. This range holds **64
slots and 62 distinct targets**, so the two units differ here by two, and a
"the frontier fell by exactly what the module owns" reconciliation done in the
wrong unit silently does not close.

The generator's own first draft made the matching mistake in miniature: it
asserted `len(thunks()) == 64`, comparing a slot count against a *target* count;
the repair then guessed 66 slots and failed again. Both numbers are now derived,
and the comment in `checks()` records the episode. The frontier arithmetic for
the whole round, in both units, is re-derived from the ROM by
`notes/prom_b_round2_frontier_delta.py`.

## Frontier, before and after

| | before | after |
|---|---:|---:|
| unconverted prom_b thunk **slots** | 347 | **283** |
| unconverted **distinct targets** | 339 | **277** |
| runs with unconverted targets | 33 | **29** |
| substantive bytes | 108,130 | **116,575** |

347 − 283 = **64 slots** and 339 − 277 = **62 distinct targets**, exactly what
this range owns in each unit, with nothing else moving —
`notes/prom_b_round2_frontier_delta.py` checks both and reconstructs the
before-state from the `.s` rather than quoting an earlier printout.
