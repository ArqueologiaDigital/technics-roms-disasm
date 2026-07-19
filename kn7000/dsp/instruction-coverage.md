# Effects-DSP pool vs the SHARC core: instruction coverage audit

**Question (Felipe, 2026-07-19):** now that the entire effects-DSP download-record
pool is disassembled, is every instruction it uses supported by the SHARC core the
kn7000 build runs — in BOTH the interpreter and the DRC?

## ★ 2026-07-20 — GAP CLOSED, POOL 100% COVERED (and 100% DRC-NATIVE)

All three findings below are FIXED in the overlay core (kn7000_mame
`src/devices/cpu/sharc/`):

1. **`Rn = SAT MRF/MRB` (multiplier op 0x00–0x0F)** — implemented in the
   interpreter (sharcops.hxx general-multiplier `oper==0` corner, full TRM B-57
   family: SI/UI/SF/UF × Rn/MR × MRF/MRB, flags MN/MV/MU/MI per TRM; the MR
   model is 64-bit so only the integer forms can actually clamp) **and natively
   in the DRC** (sharcdrc.cpp multiplier case, mirrors the interpreter exactly,
   flags gated on liveness). RND (0x18–0x1F) remains unimplemented — the pool
   contains zero uses.
2. **`Rn = ABS Rx` (ALU 0x30)** — now DRC-NATIVE (was fallback): mirrors
   `compute_abs` exactly incl. AV+STKY-AOS on `Rx==0x80000000`, translation-
   time-baked ALUSAT clamp, AS = input sign, AZ/AN from the saturated result.
3. **`FDEP Rx BY bit:len (SE)` immediate (shiftop 0x13)** — now DRC-NATIVE
   (was fallback): `sext(Rx, min(len,32)) << bit`, SZ from result,
   SV = (bit+len > 32), with shift-by-zero routed through flag-generating ops.

**Verification (2026-07-20):**
* `tools/check_sharc_coverage.py` exits 0 — all **69 used classes**: interpreter
  OK, **DRC NATIVE for every one** (no interpreter-fallback classes remain in
  the used set).
* Reverb A/B oracle: money.lua harness on the rebuilt binary is **bit-identical**
  to the current-era baseline (md5 `44b09b9d0eaae59d9a65e5b4f4e72ec0`).
* **LIVE Gate Reverb**: SOUND DSP screen → group "Reverb" → **Short Gate**
  selected (uploads rec12 into effect slot 2 — PM `0x8638` verified holding the
  SAT word `0000305003909300`); machine ran 10+ s with the gate active (its
  "quiet" branch executes `R3 = SAT MRF` every silent frame) plus a keybed note
  through it, **no fatalerror, both DRC and `-nodrc` interpreter runs**.
  Gotcha for future GUI drives: the Gate presets are NOT on the (hold-)REVERB
  screen (2 pages, Room…Stadium); they are the SOUND DSP screen's "Reverb"
  group (first group in the center list; scroll-up soft rocker = CPC_SEG9 0x01),
  and pressing the already-stored preset with the insert OFF uploads nothing —
  toggle SOUND DSP on (short press CPR_SEG3 0x08) or pick a different preset.

The remainder of this file is the original 2026-07-19 audit, kept for the
method, the support matrix and the ALUSAT/TRM-deviation cross-checks; read
"THROW/CRASH/FALLBACK" rows below through the fixes above.

---

**Answer (2026-07-19, superseded above): almost, with ONE genuine gap.** Of the pool's **6,499 PM words** (80
records) falling into **69 distinct instruction/compute classes**, **66 classes are
native in both paths**, **2 classes are DRC-fallback-to-interpreter** (functionally
correct, perf-only), and **1 class is unimplemented in BOTH paths**:

> **`Rn = SAT MRF (SF)`** (single-function multiplier op `0x09`) — **1 occurrence**,
> **rec12 (GATE REVERB)** at PM `0x8438`:
> `8438: 0000305003909300  R3 = SAT MRF,  DM(I0, M1) = R8, R7 = PM(I8, M8)`
> The interpreter throws (`compute: multiplier operation 09 not implemented`), and
> the DRC routes it to `generate_unimplemented_compute` → `compute_fallback` → the
> same interpreter throw. The DRC frontend describes it fine, so the failure is a
> clean `emu_fatalerror` at execute time in both engines.

Everything else the pool uses — every fixed/float ALU op, the whole SSF fixed
multiplier/MAC family, all multifunction combinations, all shifter forms, all
memory/ureg moves, immediates, branches (with delay slots), DO/UNTIL loops, sysreg
bit ops, IDLE/RTS/RTI — is implemented in the interpreter and either native or
safe-fallback in the DRC.

## The one gap in detail — rec12 Gate Reverb would crash MAME

* **Which GUI effects trigger it:** rec12 is the GUI **Sound-DSP "Reverb" group =
  Medium Gate / Short Gate / Long Gate** (effect type 0x08, Multi/Sound-DSP insert
  units 1–6). Loading any of those three presets uploads rec12.
* **When it executes:** `eff12_quiet` — the gate-decision "quiet" branch, taken on
  **every sample frame whose envelope is at/below the gate threshold**. Silence is
  quiet, so the very first idle frame after the record starts fires it. Loading a
  Gate Reverb ⇒ immediate fatalerror, both interpreter and DRC.
* **Why it has not been seen yet:** the routed-and-audible Sound-DSP tests to date
  used other members of the insert bank; rec12 has never actually been uploaded in
  the emulator.
* **Required semantics (trivial):** saturate the 80-bit MRF to 32-bit signed
  fractional — if MRF is representable in 1.31, return MR1-aligned value, else clamp
  to 0x7FFFFFFF/0x80000000. In rec12's actual use the result is **always 0**: MRF is
  zeroed six words earlier (`8432: MRF = 0`, a delay-slot instruction executed on
  both branch paths), so `R3 = SAT MRF` is the firmware's way of getting a parallel
  "R3 = 0" alongside two memory moves. A correct implementation is a few lines in
  `sharcops.hxx` (the SAT/RND `oper==0` corner of the general multiplier decode) —
  the DRC then inherits it for free through the existing fallback. *(Not fixed here:
  this audit was explicitly no-core-changes.)*

## Support matrix (all 69 used classes)

Full machine-generated table: run `tools/check_sharc_coverage.py` (exits 1 while the
gap exists; `--tsv` emits the table with per-record attribution). Summary:

| group | used classes | interp | DRC | notes |
|---|---|---|---|---|
| Top-level opcode classes (moves, branches, loops, push/pop, NOP/IDLE/RTS/RTI, imm loads) | 30 | all OK | all NATIVE | every class the pool uses is in `s_sharc_opcode_table` and emitted natively by `generate_opcode` |
| Sysreg bit ops (`BIT SET/CLR/TGL` on MODE1/MODE2/ASTAT/IMASK/IRPTL) | 8 | OK | NATIVE | kernel-only (rec04); `BIT SET MODE1 0x3000` = IRPTEN+ALUSAT (no BR8/BR0/SRCU, so the guarded MODE1-write throws can't fire) |
| Float ALU (`Fx±Fy`, FAVG, COMP, ABS, SCALB, RECIPS, FIX, FLOAT, FLOAT-BY, CLIP) | 14 | OK | NATIVE | RECIPS ×21 (compressor/AGC families), FIX ×178, FLOAT ×147 |
| Fixed ALU (`Rx±Ry`, AVG, COMP, NEG, INC, CLIP) | 8 | OK | NATIVE (ABS = fallback) | all respect MODE1.ALUSAT identically in both paths (interpreter clamps in compute.hxx; DRC `generate_fixed_alusat_tail`) |
| Fixed multiplier/MAC (SSF/SSI forms: `Rx*Ry`, `MRF±Rx*Ry`, `MRF=…`, `MRF=0`) | 7 | OK | NATIVE | the hot path; native since the D.1/D.2 patches (bit-identical vs interpreter) |
| **`Rn = SAT MRF (SF)` (op 0x09)** | **1** | **THROW** | **CRASH (fallback→throw)** | **the gap — rec12 only** |
| Float multiplier (`Fn = Fx*Fy`) | 1 | OK | NATIVE | 981 uses, 62 records |
| Multifunction (float mul∥add/sub, dual add/sub, fixed MAC∥ALU, MR moves) | 5 | OK | NATIVE | MF 0x18/0x19/0x38/0x10 + `MR1F = Rn`; the MR2F/MR2B move forms (DRC-fallback) are unused |
| Immediate shifts (LSHIFT/ASHIFT/FDEP/FEXT ± SE) | 5 | OK | NATIVE (FDEP-SE = fallback) | ASHIFT-imm ×216 is the pool's big shifter op |

**DRC-fallback-only classes (perf note, functionally correct — the fallback runs the
interpreter's implementation per instruction):**

* `FDEP Rx BY bit:len (SE)` immediate (shiftop 0x13) — ×34, 19 records (the LFO
  phase-accumulator wrap in every chorus/flanger/phaser/ensemble family member;
  one per LFO update, a few per frame — negligible).
* `Rn = ABS Rx` (ALU 0x30) — ×28, 21 records (envelope detectors in the
  AGC/compressor/gate families).

Both are per-frame-scalar ops, not per-tap loops; measured fallback counts in the
reverb profiling eras were dominated by the (now native) SS multiplier family, so
neither is worth new DRC emission on KN7000's account.

## ALUSAT interaction — no used op diverges

The kernel sets ALUSAT once at reset (`8074: BIT SET MODE1 0x3000`) and never
clears it. Every **used** fixed-point op with saturating hardware behavior is
ALUSAT-correct and identical in both engines:

* fixed ALU `+`, `−`, NEG, INC (patched family, `generate_fixed_alusat_tail`);
* AVG (op 0x09) cannot overflow → unaffected by definition;
* the multifunction fixed-MAC parallel-ALU adds (MF 0x10) — patched;
* CLIP/MIN/MAX/COMP don't saturate;
* the SSF multiplier/MAC family: MR arithmetic is 80-bit and non-saturating on HW —
  matching both engines.

No used instruction relies on the *unpatched* saturation corners (MR SAT forms are
exactly the gap above; unsigned/mixed multiplier forms are entirely unused).

## Known TRM deviations (catalogue section C) cross-referenced with actual usage

From `kn7000_mame/notes/sharc-upstream-patch-series.md` section C:

| deviation | used-set exposure |
|---|---|
| C.1 circular-buffer wrap off-by-one (`I == B+L` doesn't wrap) | **Exposed** — every delay ring in the pool; already A/B-verified at 2 samples / 2.11M on the reverb WAV; fix staged pending Felipe's approval |
| C.2 pre-modify never circular-wraps | Latent — the pool's 86 pre-modify accesses are linear-only (SPORT/I4), per the kernel doc |
| C.3 fixed AVG truncates instead of round-to-nearest | **Exposed, tiny** — ALU 0x09 ×19 in 17 records (output mixes); −0.25 LSB mean bias |
| C.4 SSFR multiplier forms never round | **Not exposed** — the pool contains **zero** SSFR fixed forms (all fixed MACs are SSF/SSI, and MF 0x04/0x05 are unused); the deviation lives only in helpers the pool never calls |
| C.5 FIX overflow w/o ALUSAT returns wrong pattern; `fmul_fix_scaled` TRUNC direction | Masked — FIX (0xC9, ×178) always runs with ALUSAT on here; `fmul_fix_scaled` (MF 0x1B) is unused |

## Method / reproducibility

* Inventory: `tools/check_sharc_coverage.py` parses every PM word in
  `disasm/dsp/rec*.asm` (6,499 words incl. the four probe records and the kernel;
  DM blocks are data and excluded; rec77–79 are DM-only tables) and decodes it with
  an exact mirror of MAME's decode: `sharcops_table.cpp` mask/value pairs on bits
  47..32, then the 23-bit compute field / shiftop / sysreg-bitop subfields.
* Support tables in the script are a hand audit (2026-07-19) of the core the build
  actually links: the **kn7000_mame overlay** `sharc.cpp` / `sharc.h` /
  `sharcops.hxx` / `sharcdrc.cpp` / `sharcfe.cpp` (verified symlinked into
  `kn7000_mame_build/src/devices/cpu/sharc/`) plus stock upstream `compute.hxx`,
  `sharcops_table.cpp`, `sharcinternal.ipp` (verified byte-identical to
  `~/compartilhado/mame`).
* Decoder sanity: 18 random instructions cross-checked classifier-vs-listing-text,
  all consistent.
* The script exits non-zero while any used class lacks full support, so it can gate
  future pool re-disassembly or core edits.

**Bottom line (2026-07-19, now DONE — see the 2026-07-20 section at the top):**
implement `Rn = SAT MRF/MRB` (the `oper==0` SAT corner — one small
interpreter case; DRC inherits via fallback) and the entire effects pool is 100%
covered in both engines. Implemented 2026-07-20 (interpreter + DRC-native, plus
native ABS and FDEP(SE)-imm); the Gate Reverb presets are safe to select.
