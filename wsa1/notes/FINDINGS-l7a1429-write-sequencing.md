# 0x00104000: the write sequencing, not the register map

Lane `w19/lsi-timing`, 2026-09-03.  Companion to
`notes/FINDINGS-prom_c-dev104-register-map.md`, which says **what** each of the nineteen
per-channel registers is built from.  This says **when** each one is written, how often, and
in what order — the half of a device model a register map does not give you.

Everything below is re-derived from `original_ROMs/wsa1_prom_c.ic28` by

```
python3 notes/wsa1_l7a1429_write_timing_probe.py             # 11 sections, printed
python3 notes/wsa1_l7a1429_write_timing_probe.py --selftest  # FAILURES: 0
```

⚠ Scope discipline, kept throughout: this describes **what crosses the bus at 0x00104000**.
Where a value comes out of RAM the RAM address is named as a *source of the number*, never as
a description of the device.  ⚠ "No read-back" remains a fact about the bus.  A device the CPU
never reads can hold as much internal state as it likes, and the firmware's habit of
re-writing whole channels is equally consistent with a chip that remembers everything.

⚠ The reading that 0x00104000 is the acoustic-modelling LSI is a DECLARED INFERENCE held over
from the driver work (no WSA1R ROM names any part).  Nothing below depends on it.

---

## 1. THE CHANNEL COUNT: **64** — PROVEN

Not by analogy with the sibling at `0x0010C000`, and not from the 0x40 block stride.  From the
loops that drive *this* device.

`Dev10C_ResetAllChannels` (0xFB80E1) contains two loops over `HL`, each closed by
`cp HL,0x0040 / jr C` — `db cf 40 00` at **0xFB81B9** and at **0xFB8281** — and each loop body
calls a 0x00104000 writer with `HL` as the channel argument:

| loop | closing compare | what it calls with the channel |
|---|---|---|
| 1 | 0xFB81B9 | `calr 0xFB77EF` at 0xFB81A4 — `Dev104_WriteAllChanRegs`, all nineteen registers |
| 2 | 0xFB8281 | `calr 0xFB7A58` at 0xFB826B — `Dev104_WriteChanReg0`, block 0 only |

So the firmware programs channels **0x00..0x3F** of this device at power-on.  Probe section 1
asserts both compares *and* re-computes both `calr` displacements to their targets, so the
bound and the callee are checked together rather than assumed adjacent.

Corroboration, five further sites (probe section 1): every runtime path bounds its channel
argument with `cp H,0x40` and skips the device on `NC` — `MidiNote_OnTail` 0xFB36A8,
`MidiNote_OffTail` 0xFB37B5, `sub_FAC34D` 0xFAC37B, `sub_FACAB7` 0xFACACD, and
`Pack104_SetInputs_SubRecordPair` 0xFC4CE7.  5 of 5.

⚠ **THE NULL, and it matters.**  On the companion device a channel argument of 0x40..0x7F is
*not* a 65th channel: six of its routines branch on `cp HL,0x0040` and the high arm re-aims the
same staging field at slot 3 (`prom_c/devices/dev10c_dev104_drivers.s`, the 0xFB7B63 banner).
If 0x00104000 had that trick, "64" would be a re-encoding rather than a count.  It does not:

```
`cp HL,0x0040` inside the eight 0x00104000 routines : 0
`cp HL,0x0040` inside the 0x0010C000 driver blocks  : 6      (the control)
```

**64 channels, each with the nineteen registers of the map, plus one register outside the
per-channel space (§3).**

---

## 2. THE COMPLETE BUS SURFACE: eight routines, 27 call sites

The image holds **nine** `0x00104000` literals — eight, one each, in the eight driver routines,
and one direct write inside `Dev10C_ResetAllChannels` (probe section 0; the same census
`notes/prom_c_dev104_regmap_checks.py` section 3 makes).  **Nothing else in prom_c can reach
the device**, so the table below is the whole of it.

Call sites are the image-wide `1D <addr24>` (call) and `1E <disp16>` (calr) scan, probe
section 2.  Enclosing-routine names are the tree's labels.

| routine | registers it writes | sites | who calls it, and WHEN |
|---|---|---|---|
| `Dev104_WriteAllChanRegs` 0xFB77EF | all 19, block 0 **last** | 9 | 4 × `VoiceRegs_Stage_A/B/C/D` (note-on/off staging) · `MidiNote_OnTail` · `MidiNote_OffTail` · `NotePool8_NoteOnOff` (the private 8-slot pool's note-on) · `sub_FAC34D` (the auto-note countdown) · `Dev10C_ResetAllChannels` (**power-on, ×64**) |
| `Dev104_WriteChanReg0` 0xFB7A58 | block 0 only | 8 | `MidiNote_OnTail` · `MidiNote_OffTail` · `MidiNote_OnByPartMode` ×3 (one per part-mode arm) · `NotePool8_NoteOnOff` · `sub_FAC34D` · `Dev10C_ResetAllChannels` (**power-on, ×64**) |
| `Dev104_SetChanRegs_00C0_0100_0240` 0xFB7A73 | 0x00C0, 0x0100, 0x0240 | 3 | `sub_FACAB7` (**periodic**, §5) · `CtrlDest29_Position_Apply`, `CtrlDest30_PosDepth_Apply` (**parameter edit / MIDI CC**, §6) |
| `Dev104_SetChanRegs_00C0_0100` 0xFB7AC9 | 0x00C0, 0x0100 | 1 | `sub_FACAB7` (**periodic**) |
| `Dev104_SetChanRegs_0140_0180` 0xFB7B05 | 0x0140, 0x0180 | 5 | `MidiNote_OnTail` · `MidiNote_OffTail` · `MidiNote_OnByPartMode` ×3 — always conditional on `sub_FC56C4` returning non-zero |
| `Dev104_SetChanReg_0280` 0xFB7B41 | 0x0280 | 1 | `CtrlDest37_SubGain_Apply` (**parameter edit / MIDI CC**) |
| `Dev104_SetChanRegs_01C0_0200_0240` 0xFB796E | block 0 **first**, then 0x01C0, 0x0200, 0x0240 | **0** | no located caller |
| `Dev104_SetChanRegs_0140_to_0240` 0xFB79D0 | block 0 **first**, then 0x0140…0x0240 | **0** | no located caller |

**27 located call sites over 6 of the 8 routines.**  ⚠ "No located caller" is a searched
negative of an absolute-`call` and `calr` scan; a call through a register operand is invisible
to it.  Not "dead" — "not found".

⚠ Two dozen of the 27 sites are reached from `MAIN` (0xF98B7D) directly or through
`MidiIn_ParseRingAndDispatch`; the three inside `CtrlDest29_Position_Apply`/`CtrlDest30_PosDepth_Apply`/`CtrlDest37_SubGain_Apply` inherit
`Voice_ApplyParamChange_Dispatch`'s 68 call sites, which this lane did not trace.  **No site
was found inside an interrupt handler**, which is consistent with the fact that no writer
disables interrupts around its select/data pair (§7) — but the fan-in above is unfinished, so
grade that WEAK.

### Timing hygiene of the bus itself

**PROVEN, and it is a difference from the companion.**  Every 0x0010C000 data write in this
firmware is followed by **five `nop`s** of bus padding.  Inside the eight 0x00104000 routines
that five-`nop` run occurs **zero** times (probe section 7; the control — the 0x0010C000 loops
of the very same reset routine — has 3).  Consecutive register writes to 0x00104000 are
separated only by the 3–5 instructions that build the next select value.  **An HLE needs no
write-recovery delay on this device.**

---

## 3. INITIALISATION — the state the firmware expects at t=0

There is no `Dev104_ResetAllChannels`.  The equivalent is the **second half of
`Dev10C_ResetAllChannels`** (0xFB80E1), which serves both devices and is called from exactly
one site: 0xFB05CD, at the end of `ExtBoard_ProbeAndInstallBases`, which is the **first** call
`MAIN` makes.  So this runs once, before anything else in the sound path.

In order (probe sections 3 and 4; every address is an instruction operand):

**Step 0 — one register outside the per-channel space.**

```
0xFB80F1  ld XIX,0x00104000
0xFB80F6  ld (XIX),0x0800          ; SELECT register number 0x0800 -- no channel added
0xFB80FA  ld BC,(0xFE1313)         ; = 0x1100
0xFB80FF  ld (XIX+2),BC            ; DATA
```

⚠ **This is a 20th register number and the map does not cover it.**  0x0800 is block 0x20 with
channel 0, or a global register; nothing decides which, and nothing else in the image ever
writes it.  Value **0x1100**, once, at power-on.  MEANING UNIDENTIFIED.

**Step 1 — the staging struct is loaded from a ROM image.**
`MemCopyWords(src=0xFE133B, dst=0x00D91F, 38)` at 0xFB8168 — 38 bytes = the nineteen 16-bit
words, one per register.  `Dev104_StagingStruct_ResetImage` in
`prom_c/data_tables/tail_data_zone.s`.

```
 word  register        value        word  register        value
   0   chan+0x0000     0x0004        10   chan+0x0280     0x8000
   1   chan+0x0040     0x0000        11   chan+0x02C0     0xFF00
   2   chan+0x0080     0x0000        12   chan+0x0300     0x0000
   3   chan+0x00C0     0x6C00        13   chan+0x0340     0xE0B8
   4   chan+0x0100     0x0100        14   chan+0x0380     0xE0B8
   5   chan+0x0140     0x0230        15   chan+0x03C0     0xE05E
   6   chan+0x0180     0x0230        16   chan+0x0400     0xBDF0
   7   chan+0x01C0     0x1C54        17   chan+0x0440     0xBDF0
   8   chan+0x0200     0x1C54        18   chan+0x0480     0x987B
   9   chan+0x0240     0x26D7
```

★ **THE IMAGE CHECKS THE REGISTER MAP, INDEPENDENTLY.**  Two words of it are values the map
derives from completely different evidence, and they agree:

* word 4 = **0x0100** — and the map's register 0x0100 is `Const_0100_251[i]`, a 251-entry table
  that holds 0x0100 in every entry;
* word 11 = **0xFF00** — and the map's register 0x02C0 is the literal 0xFF00, the only value
  any instruction ever puts in that word.

An off-by-one in the word↔register mapping would break both.  ★ The image also shows the map's
A/B pairing directly: w5 = w6, w7 = w8, w13 = w14, w16 = w17.

**Step 2 — 64 full writes.**  For `chan` = 0x00 … 0x3F:

```
(0x00D91F) &= 0xC0FF ; (0x00D91F) |= (chan << 8) & 0x3F00     ; 0xFB8181-0xFB8198
Dev104_WriteAllChanRegs(chan, &0x00D91F)                       ; 0xFB81A4
```

★ **So word 0's bits 13..8 carry the CHANNEL NUMBER** on this path.  The register-map header
reads register 0 as `(R[+0x07] << 8) | P[+0x07]`; here the same byte position is filled with
the channel index instead.  Both are the high byte of block 0.  PROVEN as arithmetic; what the
field *is* stays UNIDENTIFIED.

**Step 3 — 64 block-0-only writes, with bit 2 cleared.**  For `chan` = 0x00 … 0x3F, after that
channel's 0x0010C000 slot writes:

```
(0x00D91F) &= 0xC0FF ; BC = (0x00D91F) ; res 2,BC ; store   ; 0xFB8239-0xFB824B
(0x00D91F) |= (chan << 8) & 0x3F00
Dev104_WriteChanReg0(chan, &0x00D91F)                        ; 0xFB826B
```

**Total power-on traffic: 1 + 64×19 + 64×1 = 1281 register writes = 2562 word writes to the
port pair.**

### The quiescent state an emulated device must come up in

| register | value after init |
|---|---|
| 0x0800 (no channel) | 0x1100 |
| chan+0x0000 | `(chan << 8)` — the ROM image's 0x0004 with **bit 2 cleared** by step 3 |
| chan+0x0040 … chan+0x0480 | the eighteen image words above, identical on all 64 channels |

---

## 4. BIT 2 OF BLOCK 0 — and a reading that the null kills

The image's word 0 is **0x0004**: bit 2 set.  The power-on sweep's last act is to clear it
(`res 0x02,BC`, 0xFB8245).  And the routine every note event runs,
`Pack104_SetInputs_SubRecordPair`, ends by *setting* it (probe section 5):

```
0xFC4D43  ld A,(XBC+0x07)          ; R[+0x07]
0xFC4D4A  sll 8,HL                 ; << 8
0xFC4D50  ld (XBC),HL              ; staging word 0 = R[+0x07] << 8
0xFC4D54  set 0x02,BC
0xFC4D5A  ld (XWA),BC              ; staging word 0 |= 0x0004
```

That is `0x0004` cleared at power-on and set at every note event — exactly the shape of a
per-channel key gate.

⚠ **NULL, AND IT REFUTES THE READING.**  `Pack104_SetInputs_SubRecordPair` has five call sites
and they are 0xFB36F5, 0xFB3802, 0xFB391C, 0xFB3A67, 0xFB3B85 — 5 of 5 are `MidiNote_*`, and
**0xFB3802 is inside `MidiNote_OffTail`**.  The note-OFF tail sets bit 2 just as the note-ON
tail does.  Bit 2 is therefore **not** a key gate; on the evidence it is set whenever a channel
is programmed at all and cleared only once, at the end of the power-on sweep.  Recorded so the
next lane does not re-derive the same wrong conclusion.

---

## 5. PERIODIC VS ONE-SHOT — the classification, per register

### The tick

CPU 2's timer 1 is the pacemaker.  `ldio T01MOD,0x0D` at **0xFFF06C** in `RESET` selects φT256
for timer 1, and `Timer1_SetPeriodAndStart` loads `TREG1` with the fc-in-MHz byte at 0xFFFFEF =
0x1C = 28, so

> **INTT1 = 28 000 000 / 2048 / 28 = 488.28 Hz.**

⚠ **Which number this note used, and why.**  It is NOT derived here from scratch.
`notes/FINDINGS-system-clock.md` derives fc = 28 MHz; `notes/WSA1-EMULATION-DISASM-GAPS.md`
item 2 supplies the **prescaler correction** (upstream `tmp95c061` had the taps 16× slow;
Table 3.8(1) p.81 gives φT1/φT4/φT16/φT256 = 8/32/128/2048 over fc) and reports the rate
**measured live at 488.27 Hz** after the fix, together with the `T01MOD` write that the
scheduler note and `Timer1_SetPeriodAndStart`'s own header still record as "not located".
⚠ Those two texts are in files this lane does not own and are **not edited**; reported.

The INTT1 handler steps a six-phase counter and sets bits in `0x007ED1`; **bit 4 is set on
exactly one of the six phases** — 8 `set n,(0x007ED1)` sites in the whole image, one of them
bit 4 (probe section 9).  `MAIN`'s bit-4 arm calls `Toggle14FE_AndDispatch` (0xFB05EC), which
**alternates** between two paths on every call (`xor (XIX),0xff`, 0xFB0605), and the odd path
calls `sub_FACAB7`.

> **the periodic 0x00104000 refresh runs at 488.28 / 6 / 2 = 40.69 Hz** (24.6 ms).

⚠ That is an upper bound as well as a rate: the flag is a level, so a `MAIN` iteration longer
than 12.3 ms coalesces two settings.  It can be slower, never faster.

### What the refresh does

`sub_FACAB7` walks the active-voice list (terminator `cp H,0x40`), and for each voice calls
`sub_FC7C0D(voice, &0x00D7A2)`, which recomputes staging words through `Pack104_StageRegs_00C0_0100_0240` and returns
1, 2 or neither:

* **1** → `Dev104_SetChanRegs_00C0_0100_0240(voice, &0x00D7A2)` — registers 0x00C0, 0x0100, 0x0240
* **2** → `Dev104_SetChanRegs_00C0_0100(voice, &0x00D7A2)` — registers 0x00C0, 0x0100
* otherwise → no write

★ **PRODUCER AND SHIPPER MATCH, REGISTER FOR REGISTER** (probe section 8).  The register map's
producer index says `Pack104_StageRegs_00C0_0100_0240` writes staging words `{+0x06, +0x08, +0x12}` and `Pack104_StageReg_0280`
writes `{+0x14}`.  `Dev104_SetChanRegs_00C0_0100_0240` ships exactly `+0x06, +0x08, +0x12`
(→ 0x00C0, 0x0100, 0x0240) and `Dev104_SetChanReg_0280` ships exactly `+0x14` (→ 0x0280).  Each
of the two sub-packers has exactly the callers that pairing predicts:

| sub-packer                         | callers                                                                                                                                                                     |
|------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Pack104_StageRegs_00C0_0100_0240` | 0xFC56AA (inside the full packer) · 0xFC5EE9 (`Pack104_RestageRegs_00C0_0100_0240_ForVoice`, parameter edit) · 0xFC7CE9 (`Pack104_TickPositionMovement_ForVoice`, the tick) |
| `Pack104_StageReg_0280`            | 0xFC51A7 (inside the full packer) · 0xFC67E9 (`Pack104_RestageReg_0280_ForVoice`, parameter edit)                                                                           |

Three producers, three consumers, no leftovers.  This is the strongest structural signal in the
timing picture and it is what separates the modulation destinations from the voice parameters.

### The classification

| register                                                                                            | class                                                                            | rate / trigger                                                                                                  |
|-----------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| chan+0x00C0                                                                                         | **PERIODIC — model as a stream**                                                 | 40.69 Hz per sounding voice (both arms), + parameter edit, + every full write                                   |
| chan+0x0100                                                                                         | **PERIODIC — but a constant on this firmware**                                   | as above; the value is always 0x0100 (`Dev104_Reg0100_Const_251`)                                               |
| chan+0x0240                                                                                         | **PERIODIC**                                                                     | 40.69 Hz per sounding voice, arm 1 only; + parameter edit; + every full write                                   |
| chan+0x0280                                                                                         | ONE-SHOT + parameter edit                                                        | full writes; plus `CtrlDest37_SubGain_Apply` on a param change                                                                |
| chan+0x0140, chan+0x0180                                                                            | ONE-SHOT, with a conditional extra write at note time                            | full writes; plus `Dev104_SetChanRegs_0140_0180` at all 5 `MidiNote_*` sites when `sub_FC56C4` returns non-zero |
| chan+0x0000                                                                                         | ONE-SHOT, but written **twice** per note event and twice per channel at power-on | see §7                                                                                                          |
| chan+0x0040, 0x0080, 0x01C0, 0x0200, 0x02C0, 0x0300, 0x0340, 0x0380, 0x03C0, 0x0400, 0x0440, 0x0480 | ONE-SHOT — voice parameters                                                      | only ever inside a full 19-register write                                                                       |

**Population: 19 registers.  3 periodic, 1 param-edit-only, 2 note-time extras, 1 block 0,
12 full-write-only.**  ⚠ Register 0x0100 is periodic *in traffic* and constant *in value* on
this firmware — an emulator that ignores its value must still expect the writes.

---

## 6. PARAMETER EDITS AND MIDI CONTROLLERS

`Voice_ApplyParamChange_Dispatch` (0xFAF031) is the one routine that pushes a changed parameter
back to hardware: a 6-bit target code selects one of 49 arms through the table at 0xFAF08F
(index = code − 1).  Seven of its 68 call sites are inside named MIDI controller handlers
(`MidiCtrl_CC01`, `CC02`, `CC04`, `CC16`, `CC17`, `CC18`, `CC19`).

★ **Three arms of 49 reach 0x00104000** (probe section 10):

| table index | target code | arm                     | what it recomputes and ships                                           |
|-------------|-------------|-------------------------|------------------------------------------------------------------------|
| 28          | 29          | 0xFAF246 → `CtrlDest29_Position_Apply` | `sub_FC5D5B` → `sub_FC49AD` → registers **0x00C0, 0x0100, 0x0240**     |
| 29          | 30          | 0xFAF254 → `CtrlDest30_PosDepth_Apply` | `PartRec_SetPositionOffset_0005` / `sub_FC5D5B` → same three registers |
| 36          | 37          | 0xFAF29A → `CtrlDest37_SubGain_Apply` | `sub_FC6712` → `sub_FC4AED` → register **0x0280**                      |

All three go through `VoiceQuery_Tag00_Part` first, i.e. they act on the voices of one part.
⚠ What the target codes 29, 30 and 37 *mean* is UNIDENTIFIED — the dispatcher's own header
refuses to name the 49 entries. (Resolved 2026-10-31: they are controller DESTINATIONS — 29 `POSITION`, 30 `POS.DEPTH`, 37 `SUB GAIN` — by prom_b's `ControllerDestinationNames` (0xF33022), indexed by the same 6-bit field; the arms are now `CtrlDest29_Position_Apply`, `CtrlDest30_PosDepth_Apply`, `CtrlDest37_SubGain_Apply`; §10.4.)

**The other 46 arms never touch this device.**  So a parameter edit reaches 0x00104000 through
exactly four of its nineteen registers, and they are the same four the periodic refresh uses.

---

## 7. ORDERING AND ATOMICITY

### Block-0-last is NOT a commit strobe — STRONG

Census over all 8 routines (probe section 6; register count = half the port-store count, and
every non-zero select value is formed by an `add rr,imm16`, so block-0 writes = registers −
adds):

| routine | registers | block-0 writes | position | located callers |
|---|---|---|---|---|
| `Dev104_WriteAllChanRegs` | 19 | 1 | **LAST** | 9 |
| `Dev104_SetChanRegs_01C0_0200_0240` | 4 | 1 | **FIRST** | 0 |
| `Dev104_SetChanRegs_0140_to_0240` | 6 | 1 | **FIRST** | 0 |
| `Dev104_WriteChanReg0` | 1 | 1 | ALONE | 8 |
| `Dev104_SetChanRegs_00C0_0100_0240` | 3 | 0 | ABSENT | 3 |
| `Dev104_SetChanRegs_00C0_0100` | 2 | 0 | ABSENT | 1 |
| `Dev104_SetChanRegs_0140_0180` | 2 | 0 | ABSENT | 5 |
| `Dev104_SetChanReg_0280` | 1 | 0 | ABSENT | 1 |

Two independent reasons the "commit register" reading fails:

1. **The four routines that never write block 0 are exactly the four with real callers.**
   Every parameter change that actually happens on this firmware — the 40.69 Hz refresh, every
   MIDI-CC edit, the note-time 0x0140/0x0180 pair — lands on the device with **no block-0 write
   after it**.  A latch those registers had to wait on would have to appear in them.  It does
   not, in 4 of 4.
2. **The order is not even consistent.**  Block 0 is written LAST in one routine and FIRST in
   two others.  A commit strobe cannot be both.

⚠ Note which way this cuts: 2 of the 2 routines that write block 0 *first* have **no located
caller**, so they contribute no live traffic either way.  The falsification rests on point 1.

**For an HLE: a write to any single register takes effect on its own.**  Nothing has to be
buffered until a later write arrives.

### What *is* atomic

**The (SELECT, DATA) pair, and only that.**  Every register write is
`ld (0x00104000),<register number>` then `ld (0x00104002),<value>`, in that order, always, in
all 8 routines, with 1–4 unrelated instructions in between and **no interrupts disabled**.  A
model must latch the number written to +0x00 and apply it to the next write to +0x02.
⚠ Nothing in the firmware guards that pair, which is only safe if nothing else touches the
device — and nothing does (§2, nine literals).

**No group larger than one register is atomic.**  The strongest counter-evidence is the
firmware's own behaviour: the periodic refresh rewrites 3 registers of 19 and leaves the other
16 standing, 40 times a second.

---

## 8. ★ THE NOTE LIFECYCLE — one note, key-down to silence

The centrepiece.  Order is execution order; addresses are the call sites.  `chan` is the
allocated voice number (0..0x3F).  The staging struct is the single global `0x00D7A2`, shared
by every voice and every path — an emulator must treat each burst as "the struct as of that
moment", not as per-voice state.

Path shown: a part whose mode byte (part record +0x10, bits 7-6) is **0x40**, which is the one
mode that runs both `MidiNote_OnByPartMode`'s arm and `MidiNote_OnTail`.  Modes 0x00 and 0x80
differ only as noted at the end.

### Key-down

MIDI note-on arrives over link channel 0 from CPU 1, is parsed by
`MidiIn_ParseRingAndDispatch`, and reaches `MidiNote_Dispatch`'s velocity-non-zero arm, which
calls `MidiNote_OnByPartMode` (0xFB3F66) and then `MidiNote_OnTail` (0xFB3F75).

| # | moment | register(s) written | value source |
|---|---|---|---|
| 1 | `MidiNote_OnByPartMode` arm 0x40, 0xFB3A0A | — | `Pack104_SetInputs_PartRecord(part)`: (0x00E082) = 0x005D23 + 187·part |
| 2 | 0xFB3A67 | — | `Pack104_SetInputs_SubRecordPair(0, chan)`: (0x00E084), (0x00E086) = 0x00753E + 37·chan; **and staging word 0 := (R[+0x07] << 8) \| 0x0004** |
| 3 | 0xFB3A72 | **chan+0x0000** | `Dev104_WriteChanReg0` — staging word 0 from step 2 |
| 4 | 0xFB3A7A → `VoiceRegs_Stage_B` | — | `Dev104_LoadStageBImage` (0xFB1F42): 19 words copied from ROM 0xFE1315, then five patched — w0 = R[+0x07]<<8, w5 = 0x05A8, w6 = 0x05A8, w10 = 0x8000, w11 = 0xFF00. ★ **On this arm the nineteen registers are a ROM IMAGE, not a computation** |
| 5 | 0xFB1F51 | **all 19**, block 0 last | the struct as patched in step 4 |
| 6 | 0xFB3AC6 | — | `sub_FC56C4(chan, &struct)` → A |
| 7 | 0xFB3AD9, only if A ≠ 0 | **chan+0x0140, chan+0x0180** | staging words +0x0A, +0x0C |
| 8 | `MidiNote_OnTail` 0xFB369D | — | `Pack104_SetInputs_PartRecord(part)` again |
| 9 | 0xFB36A8 | — | voice number re-read from `VoiceParams_Compute_D`'s buffer at +10; **bail if ≥ 0x40** |
| 10 | 0xFB36C3-0xFB36E8 | *(companion device)* | 0x0010C000 `chan+0x0840` := 0xFF00, five `nop`s, `chan+0x0800` := 0xFF80 — the documented quiescent pair |
| 11 | 0xFB36F5 | — | `Pack104_SetInputs_SubRecordPair(0, chan)`; staging word 0 rewritten, bit 2 set |
| 12 | 0xFB36FB | **chan+0x0000** | `Dev104_WriteChanReg0` |
| 13 | 0xFB3703 → `VoiceRegs_Stage_D` | — | ~20 helpers, then `Dev104_PackStagingStruct(&0x00D7A2)` at 0xFB2F3B — the real nineteen-word packing of the register map |
| 14 | 0xFB2F4B | **all 19**, block 0 last | the packed struct |
| 15 | 0xFB3708 | **all 19 again**, block 0 last | ★ a **second** full burst from the same struct — see below |
| 16 | 0xFB3726 | — | `sub_FC56C4(chan, &struct)` → A |
| 17 | 0xFB373A, only if A ≠ 0 | **chan+0x0140, chan+0x0180** | staging words +0x0A, +0x0C |

★ **Steps 14 and 15 are two full 19-register bursts back to back.**  Between them
`VoiceRegs_Stage_D` calls only 0xFAB6D5, 0xFC35B8, 0xFAB7E0 and the *companion* device's
writer; none of the 35 sites in the image that name the literal `0x00D7A2` is inside those
three, and nothing between them calls the 0x00104000 packer — so the second burst repeats the
first's values.  Grade **STRONG**, not PROVEN: a write through a pointer already in a register
would be invisible to a literal scan. (Resolved 2026-10-31: **PROVEN** — every store in the forward closure of what runs between the bursts is classified by its base register, and none can reach 0x00D7A2..0x00D7C7; both tails load `XIX = 0x00D7A2` once in their prologue and `VoiceRegs_Stage_D` never names XIX; §10.5.)  ⚠ Either way, **an emulator matching a bus trace must
expect the burst twice.**

**Worst case per note-on on this path: 1 + 19 + 2 + 1 + 19 + 19 + 2 = 63 register writes = 126
word writes to the port pair.**

### While the note sounds

Every **24.6 ms** (40.69 Hz), for this voice, `sub_FACAB7` → `Pack104_TickPositionMovement_ForVoice` recomputes and ships
either `{chan+0x00C0, chan+0x0100, chan+0x0240}` or `{chan+0x00C0, chan+0x0100}` — §5.  Nothing
else in the image writes the device while a note is held.

A MIDI CC or panel edit whose target code is 29, 30 or 37 adds one aperiodic write of the same
registers, plus 0x0280 for code 37 — §6.

### Key-up

Velocity-zero note-on / note-off reaches `MidiNote_Dispatch`'s velocity-zero arm, which runs a
query and a retire walk and then calls `MidiNote_OffTail` (0xFB3F95).

★ **There is no "key off" register and no dedicated stop write.  A note-off is a full
re-program of the channel with release parameters.**  `MidiNote_OffTail` is byte-for-byte a
different routine from `MidiNote_OnTail` (205 of 278 bytes differ) but its **device traffic is
the same shape**, in the same order:

| # | moment | register(s) | value source |
|---|---|---|---|
| 1 | 0xFB376E | — | same part-mode 0x40 gate; the voice number comes from buffer **+11**, not +10 |
| 2 | 0xFB37AA | — | `Pack104_SetInputs_PartRecord(part)` |
| 3 | 0xFB37D0-0xFB37F5 | *(companion)* | 0x0010C000 `chan+0x0840` := 0xFF00, five `nop`s, `chan+0x0800` := 0xFF80 |
| 4 | 0xFB3802 | — | `Pack104_SetInputs_SubRecordPair(0, chan)`; staging word 0, **bit 2 set here too** (§4) |
| 5 | 0xFB3808 | **chan+0x0000** | `Dev104_WriteChanReg0` |
| 6 | 0xFB3810 → `VoiceRegs_Stage_D` → 0xFB2F4B | **all 19**, block 0 last | the repacked struct — release values |
| 7 | 0xFB3815 | **all 19 again** | the second burst, as at note-on |
| 8 | 0xFB3833 | — | `sub_FC56C4` → A |
| 9 | 0xFB3847, only if A ≠ 0 | **chan+0x0140, chan+0x0180** | staging words +0x0A, +0x0C |

### To silence

⚠ **Nothing else.**  The periodic refresh only visits voices still on `sub_FACAB7`'s active
list, so once the voice is retired the device sees no further traffic for that channel: the
last thing written is the note-off's own nineteen words, and the decay to silence is entirely
inside the chip.  `Voice_Retire_Mode20` and `ChanRec_ClearHoldAndRelease` write the companion
device only — the nine-literal census (§2) leaves no other route.

★ **That is the most load-bearing consequence of "no read-back" for an HLE**: the release
envelope is not driven from the CPU.  Whatever silences the note is internal state the firmware
programs once and then stops talking to.

### The other part modes, briefly

* **mode 0x00** (arm at 0xFB38B7): a loop over **at most four** voices, each iteration doing
  `Pack104_SetInputs_SubRecordPair` (0xFB391C) → `Dev104_WriteChanReg0` (0xFB3927) →
  `VoiceRegs_Stage_C` or `VoiceRegs_Stage_A` on a Z test (0xFB3946), i.e. up to **four** full
  19-register bursts per note-on; then once, after the loop, `sub_FC56C4` (0xFB39BC) and
  `Dev104_SetChanRegs_0140_0180` (0xFB39D1).  `MidiNote_OnTail` does **not** run.
* **mode 0x80** (arm at 0xFB3B01): one `VoiceRegs_Stage_C`.  ★ `VoiceRegs_Stage_A`, `_C` and
  `_D` all call the real packer; only `_B` (mode 0x40) uses the ROM image.
* **mode 0xC0 and the default** fall into 0xFB3C0E, which was never traced.  UNIDENTIFIED. (Resolved 2026-10-31: the bare common exit — no voice, no device write — and no factory tone has kind 0xC0; §10.3.)

### The two paths that are not the keyboard

* **`NotePool8_NoteOnOff`** (0xFC3E02) — a private eight-slot pool driven by link packets whose
  byte [1] is ≥ 0xF0.  Its note-on programs 0x00104000 in the order
  `Pack104_StageReg_0000_ForVoice` (0xFC3E91) → `Dev104_WriteChanReg0` (0xFC3EA1) →
  `Dev104_LoadStageBImage` (0xFC3EA9) → `Dev104_WriteAllChanRegs` (0xFC3ECD).  ★ Its **note-off
  does not touch this device at all** — it writes 0xA200/0xA280 to the companion's 0x0840/0x0800
  and nothing else.
* **`sub_FAC34D`** (0xFAC34D) — an auto-note countdown, reached from the periodic path.  It runs
  its body only when the counter at (0x151B) is non-zero and the countdown at (0x151C) — reloaded
  with the literal **4** at 0xFAC422 — reaches zero, so at most **40.69 / 4 = 10.17 Hz** (98 ms
  per note).  Both counters are set by arm 0x87 of `GlobalSetup_Dispatch`
  (`VoiceDefaults_StoreFromPackedByte`), i.e. by a global-setup message from CPU 1.  Its device
  order is identical to `NotePool8_NoteOnOff`'s: `Pack104_StageReg_0000_ForVoice` (0xFAC3CC) →
  `Dev104_WriteChanReg0` (0xFAC3D7) → `Dev104_LoadStageBImage` (0xFAC3E1) →
  `Dev104_WriteAllChanRegs` (0xFAC3EC).

---

## 9. WHAT REMAINS UNKNOWN

* **Register 0x0800** — written once at power-on with 0x1100, from ROM 0xFE1313.  Outside the
  19-register per-channel map.  Whether it is block 0x20 channel 0 or a global register, and
  what it does, is UNIDENTIFIED.
* **What selects the `VoiceRegs_Stage_B` / ROM-image path**, beyond "part mode 0x40" — and what
  part-record byte +0x10 *is*. (Resolved 2026-10-31, lane open4/wsa1-a, §10.1: the byte is the tone record's prom_d `kind` (+0x10) through part +0x00's pointer; 0x40 marks the two Drawbar tones.)
* **What the Z test at 0xFB3946 tests**, i.e. what makes a mode-0x00 voice take `Stage_A`
  rather than `Stage_C`. (Resolved 2026-10-31, lane open4/wsa1-a, §10.2: voice byte +0x01 bit 1, set only by `VoiceParams_Compute_D`'s builder tag; always clear on this arm, so `Stage_C` is unreachable from mode 0x00.)
* **Part mode 0xC0** and the default arm at 0xFB3C0E — never traced. (Resolved 2026-10-31, lane open4/wsa1-a, §10.3.)
* **Target codes 29, 30, 37** of `Voice_ApplyParamChange_Dispatch` — the three parameters a UI
  edit can push at this device.  Naming them would name three of the four registers that are
  written continuously, which is the highest-value open item here. (Resolved 2026-10-31, lane open4/wsa1-a, §10.4: controller destinations POSITION / POS.DEPTH / SUB GAIN.)
* **Whether the second full burst at note-on/off carries the same values** — STRONG, not PROVEN
  (§8). (Resolved 2026-10-31, lane open4/wsa1-a, §10.5: PROVEN.)
* **Whether any of the 68 `Voice_ApplyParamChange_Dispatch` call sites is inside an interrupt
  handler**, which is the last hole in "the select/data pair never needs guarding". (Resolved 2026-10-31, lane open4/wsa1-a, §10.6: none is; every caller chain ends at the MAIN task.)
* **Seventeen of the nineteen registers' meanings**, unchanged from
  `notes/FINDINGS-prom_c-dev104-register-map.md` §3.  ⚠ Felipe has no access to the hardware,
  so a live trace is not an available next step; the open routes stay the tone-editor UI and
  the localisation strings. (Resolved: HLE-GUIDE-l7a1429.md section 5.3 (1ccfc5fb2) and FINDINGS-l7a1429-editor-pages.md section 4 (478b87dca): fourteen of the nineteen blocks carry an editor name; 0x0100/0x02C0 are constants, 0x03C0/0x0480 have no editor name by proof, 0x0000 is named by its fields; open-items register 2026-10-31.)

---

## 10. CLOSURES, 2026-10-31 (lane `open4/wsa1-a`)

Nothing above is rewritten; the bullets of §6, §8 and §9 that these answer carry a pointer here.
Every claim is asserted by a probe in `notes/open4-a-probes/` (README there; each exits 0 on PASS).

### 10.1 What selects the part mode: the tone record's `kind` — PROVEN

`MidiNote_OnByPartMode` loads `XWA = (0x1523 + 300·part)` — the part record's **+0x00 is a
POINTER** — and tests `(XWA+0x10) & 0xC0` (0xFB3872 / 0xFB3877 / 0xFB387A).  The only 32-bit
store into that slot is `Part_LoadToneRecordAndPointers`'s `ld (XBC+0x1523),XIY` at 0xFB47EE,
which stores `Part_ResolveToneRecord`'s answer — the prom_d tone record, or the part's RAM-staged
copy when part word +0x04 bit 0 is set — and switches on the same byte at 0xFB47F3.  The other
five 32-bit stores into the array are element sub-record pointers (+0x88, +0x8C, +0x90+4k).
So "part-record byte +0x10" is **tone-head byte +0x10**, prom_d's `kind`:

| kind (+0x10) | tone heads | bits 7:6 | arm                                                             |
|--------------|------------|----------|-----------------------------------------------------------------|
| 0x10         | 248        | 00       | melodic: `VoiceParams_Compute_A`, Stage_A                       |
| 0x00         | 6          | 00       | melodic (Square Guitar, the vocal pads)                         |
| 0x71         | 2          | 01       | DRAWBAR: `VoiceParams_Compute_B`, `VoiceRegs_Stage_B` ROM image |
| 0x80         | 18         | 10       | drum kit: `VoiceParams_Compute_C`, Stage_C                      |
| —            | 0          | 11       | arm 0xC0, §10.3                                                 |

Probe: `part_mode_kind.py`.  So the Stage_B / ROM-image path is selected by the tone being one of
the two `<<< Drawbar >>>` records, exactly the complement of prom_d's "0x80 is the drum path".

### 10.2 The Z test at 0xFB3946: the voice record's BUILDER TAG — PROVEN, and the branch is dead

`ld WA,(XBC+0x3BCF)` with `XBC = 68·v + 1`, then `and DE,0x0002`: bit 1 of the voice record's
byte **+0x01**.  That byte is written when the record is built, in the staging copy at
`0x5A53 + 68·element` that each `VoiceParams_Compute_*` fills and then lays over the voice record
with `MemCopyWords(…, 68)` (0xFB1DE7 for A).  Its low bits are a tag of the builder:

| builder (and its orphan twin)          | byte +0x01             | sites                                                                 |
|----------------------------------------|------------------------|-----------------------------------------------------------------------|
| `VoiceParams_Compute_A` / `sub_FB0B95` | `(layer << 6) \| 0x04` | 0xFB0F53, 0xFB1162, 0xFB139E, 0xFB1638, 0xFB18E6, 0xFB1BB8 / 0xFB0CAF |
| `VoiceParams_Compute_B` / `sub_FB1FB1` | `0x08`                 | 0xFB224F, 0xFB23C6, 0xFB253D, 0xFB26CF / 0xFB2093                     |
| `VoiceParams_Compute_C` / `sub_FB289A` | `(layer << 6) \| 0x10` | 0xFB2B3E, 0xFB2CFE / 0xFB293C                                         |
| `VoiceParams_Compute_D` / `sub_FB2F74` | `(layer << 6) \| 0x12` | 0xFB32B4, 0xFB34BF / 0xFB307A                                         |

`layer` is `VelSplit_LayerFromVelocity`'s result.  **Bit 1 is D's alone** — D is C's tag plus
bit 1 — and 0xFB393A is the only test of that bit anywhere in prom_c.  In the mode-0x00 arm every
voice tested was rebuilt by `VoiceParams_Compute_A` a few instructions earlier: its copy loop runs k = 10..13
over the request buffer's voice list (0xFB1DA9 / 0xFB1DB4) and the arm walks the same list[10..13]
(0xFB38D1 / 0xFB395A), and nothing called in between (`Pack104_SetInputs_PartRecord`,
`Pack104_SetInputs_SubRecordPair`, `Dev104_WriteChanReg0` and their callees) names a voice record
or its staging copy.  So the bit is **always clear here, `VoiceRegs_Stage_A` is always taken, and
the `VoiceRegs_Stage_C` call at 0xFB3948 is unreachable from mode 0x00** — a compiled test of a
tag this path never sets.  Probe: `voice_builder_tag.py`.

### 10.3 Arm 0xC0 and the default (0xFB3C0E) — PROVEN

The arm is the common exit and nothing else: `and (part+0x04),0xFFF3` (0xFB3C1B), the frame pop
and `ret` — no `VoiceParams_Compute_*`, no voice allocated, no write to either device.  The other
three arms reach the same instructions after `PartRec_Word0006_ClearBit13` (0xFB3C09), so **every
note-on clears bits 2-3 of part word +0x04**.  Bit 3 is set by the twelve `Voice_Restage_Reg0440/
0180/04C0_*_ForPart` sites (0xFAE3A6 … 0xFAEA84) and bit 2 by `sub_FB8CEC` (0xFB8D7A) and
`sub_FB9AC2` (0xFB9AEC); ⚠ what the two bits *mean* is not established here.  No factory tone has
kind 0xC0 (§10.1); a RAM-staged tone carrying it would load its pointers as a melodic one
(`Part_LoadToneRecordAndPointers` treats 0xC0 like 0x00, 0xFB4813) and be **silent on note-on**.
Probe: `part_mode_kind.py`.

### 10.4 Target codes 29, 30, 37: controller DESTINATIONS — PROVEN

The dispatcher's code is the 6-bit field of a **tone record's controller-assignment slot**:
`MidiCtrl_CC01` hands it tone[+0x17]/[+0x1A], `CC02` tone[+0x1D]/[+0x20], `CC04` tone[+0x25]/[+0x28],
and `ld L,(XIX+0x01) / and L,0x3F` takes the code (0xFAF041).  CPU 1 names the same field:
prom_b's `ControllerDestinationNames` (0xF33022, 64 × 13 bytes, read with mask 0x3F) is the list
the SOUND EDIT controller page draws, and its entries agree with every arm this note decoded:

| code | prom_b name | arm (renamed)               | stores                                         | ships                  |
|------|-------------|-----------------------------|------------------------------------------------|------------------------|
| 29   | `POSITION`  | `CtrlDest29_Position_Apply` | `PartRec_SetPositionOffset_0003` → PART[+0x03] | 0x00C0, 0x0100, 0x0240 |
| 30   | `POS.DEPTH` | `CtrlDest30_PosDepth_Apply` | `PartRec_SetPositionOffset_0005` → PART[+0x05] | 0x00C0, 0x0100, 0x0240 |
| 37   | `SUB GAIN`  | `CtrlDest37_SubGain_Apply`  | `PartRec_SetSubGainOffset_000F` → PART[+0x0F]  | 0x0280                 |

So there is no CPU 1 or MIDI "sender" of a code: a code is a per-tone routing choice (edited on
CPU 1's controller page), and the MIDI controller the tone assigns to that destination is what
triggers the arm.  Factory use (`ctrl_dest_names.py`): code 29 is controller 2's first destination
in 119 of the 256 non-drum tones and its second in 33; no factory tone assigns 30 or 37.
⚠ PART[+0x05] is now the `POS.DEPTH` offset, which sharpens the asymmetry
`PartRec_SetPositionOffset_0005`'s header reports: the routine stores it but re-derives the
element fields from PART[+0x03], so no located code folds a `POS.DEPTH` controller into a register.
Renames: `scripts/renaming/rename_wsa1_open4_a.sed`.

### 10.5 The second 19-register burst repeats the first — PROVEN

`second_burst_stores.py` lists every memory store in the forward call closure of what runs between
the two bursts (`Dev104_WriteAllChanRegs` itself, `Voice_ComputeLevelBase_CD`,
`SlotRec_AddToArgField_000E`, `Voice_StageLevel_Reg0080_CD`, `Dev10C_WriteAllChanRegs` and their
callees — 12 routines) and classifies each by its base: frame locals; absolutes, all outside
0x00D7A2..0x00D7C7 (the one is 0x00D762, the *companion's* staging word); the voice record
pointer argument (`0x3BCF + 68·v`); and the two port pairs 0x00104000/2 and 0x0010C000/2.  Both
tails load `XIX = 0x00D7A2` in their prologue (0xFB363B, 0xFB3751) and `VoiceRegs_Stage_D` never
names XIX.  So the second burst sends the struct the first one sent.  §8's grade is **PROVEN**.

### 10.6 No `Voice_ApplyParamChange_Dispatch` call site runs in an interrupt — PROVEN

`isr_reach_param_dispatch.py`: the forward closure (calls, tail jumps and computed-goto tables) of
every vector of prom_c's table except RESET, plus the one soft-timer callback the INTT3 tick can
run (`SoftTimer_RotateLevel2`, the only `SoftTimer_Register` request), is 33 routines and contains
neither the dispatcher nor any of its 18 transitive callers.  Every caller chain ends at `MAIN`,
task 1 of `EntryPoint_Records` (initial SR 0x8800, IFF 0: thread level).  The computed branches
inside the closure are the INT0 and INTTC3 handlers' own local tables, INTT1's phase table and the
soft-timer callback slot — all accounted for.  So the select/data pair is only ever driven at task
level by this path, and "never needs guarding" holds for it.
