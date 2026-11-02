# Sub-lane `dsp` of lane open6/kn5000-d (2026-11-02): the uPD6383 R1 cascade and the reverb topology

Tracker items: **`kn5000-ax7`** (uPD6383 decode, the R1 cascade) and **`kn5000-i2m`** (the reverb
micro-topology, which depends on it). Parent `kn5000-1oy` stays BLOCKED on `kn5000-a9y` (which chip
decodes sub-CPU 0x130000); nothing here touches that.

No hardware and no emulator run. Static work on the two committed corpora (`dsp/disasm/`,
`wsa1/dsp/disasm/`). The emulator arms (`pair_gate.sh`, `run_dsp_arm.sh`) need a
`KN5000_ENABLE_DSP1=1` rebuild of the shared `kn7000_mame_build` tree, which this sub-lane does not
own. They were not needed: section 3 says why no arm has a criterion for the open step.

## 1. What changed

| file                                               | change                                                                                                                                      |
|----------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| `dsp/tools/bit11_xprod.py`                         | new: the bit-11 words across the 32 KN5000 / SX-WSA1R homolog pairs, with a control, the relocation test, and the `--dram` migration census |
| `dsp/tools/README.md`                              | one section for it                                                                                                                          |
| `dsp/analysis/bit11-xprod-2026-11-02.md`           | new: the findings (items A-I) and the per-step state of the R1 cascade                                                                      |
| `dsp/analysis/data/bit11_xprod-2026-11-02.txt`     | the tool's output as measured                                                                                                               |
| `dsp/analysis/DECODE-QUEUE-HANDOVER-2026-09-14.md` | item 0*: the 8BC relocation target it pointed at is spent (dated addition, nothing deleted)                                                 |
| `dsp/README.md`                                    | one row listing the new note                                                                                                                |
| `notes/open6-kn5000-d/dsp/`                        | this README, `probes/`, the two issue-comment files                                                                                         |

No assembly source, no `decoded()` predicate, no `.dsm` listing and no device code was changed. No
renames, so no sed file.

## 2. Coverage, before and after (unchanged)

| measure                                  | before (start of session)              | after                  | command                                  |
|------------------------------------------|----------------------------------------|------------------------|------------------------------------------|
| pooled, de-duplicated (the honest one)   | 7273 words, 1397 undecoded, **80.8 %** | 7273, 1397, **80.8 %** | `python3 dsp/tools/decoded_selfcheck.py` |
| pooled, as published                     | 8003, 1469, 81.6 %                     | 8003, 1469, 81.6 %     | same                                     |
| KN5000, all 38 body images, tier 1 / +1b | 79.4 % / 80.5 %                        | 79.4 % / 80.5 %        | `python3 dsp/tools/dsp_coverage.py`      |
| reverb image (algo 16), tier 1           | 124 of 133, 93.2 %                     | 124 of 133, 93.2 %     | same                                     |
| bit-11 family                            | 187 words, 169 undecoded               | 187, 169               | `python3 dsp/tools/bit11_prize.py`       |

Gate: `flock .../build.lock python3 dsp/verify.py` -> `BYTE-MATCH OK -- every committed listing
reproduces the ROM bytes exactly` (kernel + epilogue + 91 valid algorithm streams, 38 distinct
images). Nothing byte-relevant changed, so no `make` was run.

## 3. Findings (details and evidence in `dsp/analysis/bit11-xprod-2026-11-02.md`)

1. **`8BC` is at `w0`/`w1` in 49 of 49 pooled occurrences** (KN 24, WSA 25). MEASURED.
2. **Across the 32 homolog pairs:** `8BC` kept in 16, carrier swapped in 4 (KN `040.0.00.8BC` <->
   WSA `880.1.30.8BC`: DISTORTION, FUZZ, OVERDRIVE, RING MODULATOR), carried by only the WSA copy
   in 2 (MIX UP, S.DELAY+CHORUS). The drop rate (2 of 42) is ordinary against the control (43 of 583
   decoded once-per-image words). MEASURED.
3. **Relocation test on the alternate encoding:** KN bodies load at I-RAM 84, WSA bodies at 110;
   62 of 62 aligned bit-11 words are byte-identical after the 26-word move, and `C63` also moved
   inside its body in 41 of 44. **No bit-11 field is an I-RAM address**, absolute or body-relative.
   MEASURED. Worth zero words.
4. **The handover's named first target is spent.** `8BC`'s `lo12` is constant in 49 of 49 and the
   fused form's `addr8` is `0x30` in 37 of 37; nothing in the word varies, so a relocation test can
   say nothing about it beyond item 3. MEASURED.
5. **Delay-read route migration:** KN `880.1.30.407` <-> WSA `880.1.30.00B` in 6 pairs, with `407`
   on an adjacent ALU word in the WSA copy 6 of 6. At those `SRC 0x00` sites `ACT 0x0B`'s
   `mem<-bus` reading writes the cell into itself and cannot be told from `none`, so these sites can
   only separate `{none, mem<-bus}` from `tA<-acc`. CONDITIONAL (assumes the bus on an escape read
   carries the `SRC` operand).
6. **The reverb has no bit-11 word.** ROOM REVERB 1's nine undecoded words are `ACT 0x0B` x4,
   `ACT 0x1A` x3, `SRC 0x11` x2, each a sole open axis. MEASURED (`acc_blind.open_axes`).
7. The SX-WSA1R records' fields +0/+4/+8 carry **no** tag-0x4C descriptor pokes (0 of 48), so a
   cross-product descriptor-slot check of the fused `880.1.30.8BC` could not be run.
   MEASURED (`probes/wsa1_descriptor_cells.py`).

## 4. Item outcomes

### `kn5000-ax7`: BLOCKED

Every step of the R1 cascade is now shut on a named missing input; none is merely unfinished.

| step                                   | sole-axis words now        | state   | what is missing                                                                                                                                                                                                                                                                                    |
|----------------------------------------|----------------------------|---------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1  bit-11 alternate `lo12` (169 words) | 132                        | BLOCKED | an observable: no audio sees control words, the device model gives the alternate `lo12` no meaning, the relocation test is spent (findings 3-4), the KN1500 adds nothing (handover §208). Needs a **Pioneer CDJ-500 firmware dump** (same chip, IC302) or a PC trace from the chip's emulator mode |
| 2  `ACT 0x0B` off class A              | 159                        | BLOCKED | an anchored reference for a program whose `ACT 0x0B` words are delay escapes (handover §135/§137): a recording of the real KN5000's EFFECT OUT on an effect that carries the code. KN5000 hardware is inaccessible (`kn5000-hardware-inaccessible`). Finding 5 narrows six sites, conditionally    |
| 3  `f31` 3..7                          | 56 (`f31 3`), 48 (`f31 5`) | BLOCKED | handover §149: the anchored programs carry no `f31 = 3` word; the carriers are dynamics/distortion programs with graded HLE. Same hardware block as step 2                                                                                                                                         |
| 4  addressing classes 0/1/4            | 99 (class-4 bit-4 store)   | BLOCKED | mode 4 has one witness (EXCITER) and no replication exists in either corpus (§165); class 0's corner is inert (§132). Needs a new corpus (the CDJ-500 again)                                                                                                                                       |

Coverage reached: 80.8 % pooled, unchanged (section 2).

### `kn5000-i2m`: BLOCKED

The micro-topology (pipe-comb against series comb cascade, `reverb-topology-round7.md` §12) is not
blocked by the bit-11 encoding at all (finding 6): the reverb's open words are `ACT 0x0B`, `ACT
0x1A` and `SRC 0x11`, and the topology search's real obstruction is the read latency `land`, which
the decode-status page's R6 lists as unobtainable from either board's software. The SX-WSA1R reverb
is not a homolog (21 of 133 words align; 40 delay consumers against the KN5000's 32 cells) and the
WSA1R never executes its bodies. **What is missing: an impulse response of the real KN5000 on ROOM
REVERB 1, recorded at EFFECT OUT**, which waits on the KN5000 hardware. The tracker's dependency
"depends on kn5000-ax7" should read "depends on `ACT 0x0B` (ax7 step 2), `ACT 0x1A` and `SRC 0x11`".

## 5. Website page draft

(For the integrator; `../technics-docs` was not touched.)

**`upd6383-decode-status.md`, §5 R1, replace the paragraph starting "The best-posed single target is
the bit-11 alternate encoding" with:**

> The bit-11 alternate encoding looked like the best-posed single target: nine shapes, two carrying
> most of the family, and a named first word (`8801308BC`) for a relocation-style test. **That test
> was run on 2026-11-02, and it is spent.** The KN5000 loads its effect bodies at I-RAM 84 and the
> SX-WSA1R at 110, and all 62 bit-11 words that align between the two products' copies of a program
> are byte-identical after that move (`C63` also moved inside its body in 41 of 44). So no field of
> these words is an instruction-RAM address. Beyond that the test has nothing to measure: `8BC`'s
> fields do not vary anywhere in the pooled corpus (49 of 49 at the start of a program, `lo12`
> constant, `addr8 = 0x30` in all 37 fused copies). The family is control words that no audio
> measurement sees and that the emulator model gives no meaning, so **the corpus cannot decide it**.
> The named routes are a second product's firmware (the CDJ-500, R2) or the chip's emulator mode (R5).

**Same page, §8 row 1 ("The bit-11 alternate encoding"):** change *cost* to "done 2026-11-02: no
corpus route left", *risk* to "n/a", *why now* to "the relocation test ran and is spent; the family
now waits on R2 (CDJ-500 firmware) or R5".

**Same page, §4, add after the cascade block:**

> ⚠ **As of 2026-11-02 every step of the internal cascade is blocked on a named input, not
> unfinished.** Steps 2 (`ACT 0x0B`) and 3 (`f31 3..7`) need a recorded output of an effect that
> carries the code on a real KN5000; step 4 (addressing classes) has one witness program and no
> replication in either corpus; step 5 (bit-11) is above. The 80.8 % figure is where corpus work
> stops.

**`effects-dsp.md` §19, append:**

> **What the topology waits on (2026-11-02).** None of the reverb's nine still-undecoded words
> belongs to the bit-11 family: four are delay escapes carrying `ACT 0x0B`, three carry `ACT 0x1A`
> and two read `SRC 0x11`. Choosing between the pipe-comb and the series comb cascade depends on the
> delay-read latency, which neither board's software can observe, and the SX-WSA1R's reverb is a
> different program (21 of 133 words align). An impulse response of the real KN5000 on ROOM REVERB 1,
> taken at EFFECT OUT, is what would settle it.

## 6. Scratch

Exploration scripts (`ctx.py`, `align.py`, `wsadsc.py`) lived in
`~/compartilhado/tmp/open6-kn5000-d/dsp/`. `align.py` became `dsp/tools/bit11_xprod.py`, and
`wsadsc.py` became `probes/wsa1_descriptor_cells.py`. `ctx.py` only printed word contexts, no
quoted figure. All three were harvested into `~/compartilhado/research-scratch`.
