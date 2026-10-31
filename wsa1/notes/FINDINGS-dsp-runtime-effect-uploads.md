# Runtime WSA1R DSP uploads are COEFFICIENT-driven, not I-RAM re-programmed

**Date 2026-09-07.** Measured in-emulator on a `WSA1R_ENABLE_DSP=1` build with the
three `upd6383` devices instantiated. Instrument: `kn7000_mame/tools/rigs/
wsa1_dsp_effect_sweep.lua` (committed). This answers "does selecting each effect at
runtime fill more of the DSPs' I-RAM and C-RAM, exercising more of the 918-word
corpus?" — and the answer is **C-RAM yes, I-RAM no**.

## How effects were driven (deterministic, real firmware)

Each unit's effect is byte +0 of a 26-byte CPU-2 unit block; CPU 1 delivers it over
link channel 1 into the "twin" inbox and `P7Units_ServiceTask` resolves+reloads on a
change flag (RE'd by workflow wf_6046d59e-9fc; addresses in `p7/p7_module.s`
:19016/:19429, `PoolDir_RecordForUnitProgram` 0xFDC551). The rig writes the twin
program byte (`0x7E7E`/`0x7E98`/`0x7EB2`, +0x1A·unit) and sets the change flag
(`0x7ECC`, bit `1<<(unit+1)`) — **the exact bytes CPU 1's link handler writes**
(Link_Ch1_WriteParamBlock subcmd 0x81/0x82/0x83), so the ensuing `P7Stream_Run`
upload is 100% real firmware. `live` (`0x856E`/`0x8588`/`0x85A2`) and the resolved
record (`0x8586`/`0x85A0`/`0x85BA`) confirm each change landed.

## What was measured

| DSP | unit | boot I-RAM | boot C-RAM | after sweeping the 55 real effects |
|---|---|---|---|---|
| IC30 | 2 | 63 words / 45 distinct | 0 cells | I-RAM **unchanged** (45 distinct); C-RAM **still 0** |
| IC6 | 0 | 0 | 79 cells / 37 distinct values | C-RAM **37→47 distinct / 79→91 cells**; I-RAM still 0 |
| IC5 | 1 | 0 | 54 cells / 19 distinct values | same shape as IC6 (coefficients grow; no I-RAM) |

- **Exhaustive**: sweeping unit2 across **all 128 programs** exercised **55 distinct
  resolved records** (0..55 minus the NO-OP record 53) and IC30's I-RAM stayed
  byte-identical every single time (distinct words 45→45).
- **I-RAM is invariant** across every trigger tried: per-unit effect change, group
  reload (`P7Units_ReloadForGroup`, toggling `0xF361`), a 3-unit combi, and clearing
  the per-unit preamble latch (`0xF354`+2·unit) before a reload. C-RAM *did* change
  under these (capture-live control), so the invariance is real, not a capture miss.

## The architecture this reveals (MEASURED)

- **IC30 is the PROGRAM DSP**: a resident I-RAM kernel (63 words / 45 distinct),
  loaded once at boot, with an empty C-RAM. It is not re-programmed by effect changes.
- **IC6 / IC5 are COEFFICIENT DSPs**: C-RAM-driven, no I-RAM program. Effect changes
  re-upload their C-RAM coefficients.
- So **runtime effect selection is coefficient-driven**: it swaps C-RAM values on
  IC6/IC5; it never re-programs any DSP's microcode.

## Consequence for the 918-word "corpus" (the important part)

The static pool has **70 opcode-3 (program) records → 5,777 words / 918 distinct**
(`dsp/analysis/wsa1_dsp_isa_crossval.py`). At runtime **only 45 distinct I-RAM words
are ever resident** (IC30's kernel), and **none of the tested triggers uploaded any of
the rest**.

**Measured-resident executable surface (a decode advance).**
`dsp/analysis/dsp_runtime_resident_vs_corpus.py` cross-checks the 45 runtime-resident
words against the static corpus: **45/45 are container-valid AND 45/45 are in the
918-word corpus** — the runtime kernel is a genuine subset, and exactly **45 of 918
(4.9%)** static words are proven-executed (baseline: `runtime-resident-iram-words.txt`).

⚠ **The other ~873 are NOT data** — an earlier revision of this note guessed they were
coefficient/data framed as opcode-3; `dsp/analysis/dsp_program_record_classify.py`
**refutes that**: all 70 records are **100% container-valid** and most decode well above
the ~22% field-shuffle null (many 40–70%). They are **genuine effect-body programs** —
the runtime kernel is record #69 (addr 0x0030, 45/45 words); ~60 distinct effect bodies
sit at I-RAM address 0x6E. So the 918-word corpus is real code; the runtime just did not
upload the per-effect bodies through the triggers tested here.

⚠ **This REFUTES the earlier note** (`FINDINGS-dsp-upload-deframed.md`, "Insights"):
"Only 63/384 of IC30's I-RAM is filled at boot — the rest loads when effects are
selected." Measured: the rest does **not** load on the twin-poke effect change, nor on
group/combi/preamble-clear reloads. Corrected there in the same commit.

### The mechanism, traced (2026-09-07) — the reload RUNS but writes no I-RAM

Follow-up RE + execution/write taps resolved most of the crux:

- **The I-RAM program body is PoolDir_Records field +12**, not +0/+4 (verified:
  `dsp/analysis/dsp_record_field_opcodes.py` — field +12 is opcode-3 for 48/56 effects;
  +0/+4/+8 are all opcode-0 coefficient streams). `P7Unit_ReloadOnProgramChange` emits it via
  `P7Stream_Run(field+12)` at `p7_module.s` 0xFA3B9C. So each effect *does* have a
  distinct body in ROM (48 of them).
- **The reload routines RUN on an effect change** (exec-taps,
  `notes/wsa1-probes/wsa1_effect_exec_taps.lua`): `P7Units_ServiceTask` wakes,
  `ResolveProgramsAndReload` runs, and `P7Unit_ReloadOnProgramChange` fires (+2 on a program change), with
  `P7Byte_SendCmd` emitting bytes. So it is NOT skipped.
- **Yet host_w writes ZERO DSP I-RAM** on the change (write-tap,
  `wsa1_effect_iram_writetap.lua`: 0 I-RAM writes on all three DSPs; C-RAM writes DO
  happen — IC6 +12). So the negative is now confirmed at the WRITE level, not just the
  non-zero count: runtime effect selection produces no I-RAM write at all.

### ✅ RESOLVED (raw-bus capture, 2026-09-07): the body is never on the bus — firmware-gated

The remaining question is now directly settled. A clean `LOG_DSPUP` capture (device iram
map temporarily widened to silence the per-sample unmapped-read flood; recipe in
`dsp/analysis/dsp_bus_program_scan.py`) around two effect changes shows:

- **The only cmd-0x01 PROGRAM upload on the entire bus is to 0x0030 on dest2 (IC30) — at
  boot** (bytes #1, #436). There is **no cmd-0x01 to 0x006E, ever**, and **no program
  upload of any kind after boot**.
- The effect changes produced **1923 (IC6) / 26 (IC5) post-boot bytes, all coefficient/
  descriptor framing** (0A value, 08 01 address, 00 00 D-RAM groups) — zero cmd-0x01
  program records.

⇒ **The firmware does NOT emit the per-effect I-RAM body to the DSP bus at runtime.**
`P7Unit_ReloadOnProgramChange`'s field+12 op3 `P7Stream_Run` is gated (the boot-loaded program is treated
as resident); effect changes stream only coefficients. This DIRECTLY confirms the
write-tap (0 I-RAM writes) at the bus level and **refutes the host_w-framing hypothesis**
(the body isn't on the bus in any framing — so no driver fix could load it). **The goal
of exercising more of the 918-word I-RAM corpus via effect selection is not achievable:
it is a firmware-architecture fact, not a driver limitation.** (Side note: the boot
program uploads to IC30 only; the ~48 field+12 effect bodies at I-RAM 0x6E in the pool
are never uploaded during SOUND-mode play.)

## What was and wasn't achieved vs the stated goal

- ✅ **Per-effect DSP uploads captured at runtime**, not just boot: all 55 real
  effects, driven through the real firmware path, with the devices loaded live.
- ✅ **More C-RAM filled at runtime**: IC6 coefficient vocabulary 37→47 distinct
  values (IC5 likewise).
- ⏳ **More of the 918-word I-RAM corpus was NOT exercised by the tested triggers** —
  effect change, group/combi reload, preamble-clear all moved only C-RAM. Measured, but
  NOT proof the corpus can never be exercised: ~60 real effect-body programs demonstrably
  exist in ROM (classifier), so the missing piece is the trigger that commits a per-effect
  body to I-RAM. The goal is **open**, not refuted.

## Still open

- ✅ **Why the reload writes no I-RAM — RESOLVED** (see the raw-bus section above): the
  firmware never puts the field+12 body on the bus at runtime; effect changes stream
  coefficients only. Not a driver bug — a firmware gate. So the goal is not reachable via
  effect selection, proven at the bus level.
- (Capture gotcha, for the record: a naive `VERBOSE|LOG_DSPUP` build floods error.log to
  >1 GB / 16 M lines from the `upd6383` device's per-sample read past its 384-word iram
  (`unmapped iram memory read from 7B7`) and never reaches the change frame; widen the
  device `iram_map` to the full 11-bit space (`map(0x000,0x7ff)`) for the capture build.
  That the device reads iram word 395 (>383) every sample is itself a device oddity worth
  a look, tangential to this finding.)
- **The only remaining runtime avenue** (unlikely to change the answer): whether some mode
  outside SOUND/COMBI play (a specific bank, a service/test mode) ever uploads the 0x6E
  bodies. Not observed in normal operation; low priority. (Resolved, from the ROM side: the ORDINARY program-change path uploads them --
  P7Unit_ReloadOnProgramChange, the only reader of record field +12, has no gate; see
  "Correction from the ROM, 2026-10-31" below; open-items wave 4.)
- Static executable-vs-data classification is DONE
  (`dsp/analysis/dsp_program_record_classify.py`): all 70 records are real programs, and
  the body is field +12 (`dsp_record_field_opcodes.py`); the task is "find why the field+12
  send produces no I-RAM write", not "drop the data".
- IC30 unit2 effect changes resolve a record but touch neither its I-RAM nor C-RAM —
  what unit2's effect program actually controls (routing? a main/reverb path?) is
  uncharacterised. (Resolved: unit 2 is not IC30.  P7Stream_Data_FD4B85 sends unit 2 to destination 1,
  IC5, and no unit program reaches destination 2 = IC30 at all, so a unit-2 change cannot
  write IC30; see the correction below; open-items wave 4.)

---

## Correction from the ROM, 2026-10-31 (lane open4/wsa1)

Nothing above is edited except the two "(Resolved: ...)" tails.  This section is static
reading of prom_c, every claim an instruction operand or a ROM byte, re-checked by
`notes/open4-f-probes/p7_unit_program_paths.py` (18 checks, exits 1 on drift).

**1. The units are not the three DSPs one-to-one.**  `P7Stream_Run(stream, index, table)`
takes its destination from byte 5 of the six-byte record `table + 6*index - 6`, and every
per-unit stream is run with `index = unit + 1` against `P7Stream_Data_FD4B85`:

| unit | relocation record (b0..b5) | destination | DSP (kn7000_mame wsa1.cpp nets) | op-3 body address (0x006E + b3) |
|------|----------------------------|-------------|---------------------------------|---------------------------------|
| 0    | `00 00 00 00 00 00`        | 0           | IC6 (DSP0CS = P5.4)             | 0x006E                          |
| 1    | `60 80 e0 79 80 00`        | 0           | IC6                             | 0x00E7                          |
| 2    | `00 00 e0 3a 00 01`        | 1           | IC5 (DSP1CS = P5.5)             | 0x00A8                          |

So units 0 and 1 share IC6 in disjoint regions (op-0 base 0x00 / 0x80, op-1 base 0x00 /
0x60, op-2 base 0x0000 / 0x8000, op-3 base 0x00 / 0x79), unit 2 is IC5, and **destination 2,
IC30, is no unit's destination**: only `P7Stream_Data_FD4B97` index 4 reaches it, from the
boot loader and the group reload's fixed streams.  The table at the top of this note pairs
IC30 with unit 2; per the ROM that pairing is wrong, and it is why "a unit-2 effect change
touches neither IC30's I-RAM nor its C-RAM" -- the firmware sends unit 2's bytes to IC5.

**2. The +12 bodies have exactly one reader, and it is not gated.**  `PoolDir_Records`
(`0xFDBFD9`) is an operand 15 times in the image; one of them adds +12, at `0xFA3AEA` in
`P7Unit_ReloadOnProgramChange` (was `sub_FA3A3C`).  That routine runs the +12 stream at
`0xFA3B9C` with no branch between its entry and the call; the stream is one op-3 record for
all 56 records, payload `01 00 6e ...`; the op-3 arm (`0xF9AAFB`) sends `0x01` through
`P7Byte_SendCmd`, which has no early return, then the relocated address through
`P7Byte_SendArg` and the words through `P7Byte_SendData`.
`P7Units_ResolveProgramsAndReload` calls it at `0xFA5773` (unit 1), `0xFA581C` (unit 0) and
`0xFA58CE` (unit 2) whenever the unit block's resolved record byte (+0x18 of
`0x856E + 26*unit`) differs from its shadow (+0x18 of `0x85BC + 26*unit`) -- i.e. on every
effect change.  **No firmware gate exists between an effect change and a command-0x01 body
upload to IC6 or IC5.**  The "firmware-gated" reading of the raw-bus section above is
contradicted by the ROM.

**3. The boot loader programs all three DSPs, not only IC30.**  `P7Units_BootLoadAndStartTask`
drops DSPRST and the three DSPnRST2 lines (`res 2/3/4/1,(PB)` at `0xFA3127`-`0xFA3130`),
raises DSPRST, runs three op-3 command-0x01 streams at address 0x0030 --
`P7Stream_FCD2C6` to destination 0, `P7Stream_FCD5E2` to destination 1, `P7Stream_FCDA77` to
destination 2 -- and raises DSP0RST2, DSP1RST2 and DSP2RST2 afterwards (`0xFA3196`,
`0xFA31B0`, `0xFA31CA`).  The emulator capture above saw only the third.

**What follows.**  The measurement in this note (no I-RAM on IC6/IC5 at boot, none after an
effect change) disagrees with what the ROM sends, so the place to look is the emulation:
how kn7000_mame's `wsa1.cpp` routes destinations 0 and 1 (`m_dsp[dest].found()` /
`dsp_deframe`) and how its `upd6383` device treats a command-0x01 body that arrives while
the part's /RST2 is HIGH (the per-unit reloads never lower it; the boot uploads run with it
low).  The second question is device semantics with no datasheet in this tree; the first is
work in the kn7000_mame repository, not here.
