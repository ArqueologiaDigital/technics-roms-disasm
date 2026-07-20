# The KN7000 SHARC kernel (rec04) — architecture of a 4.6 KB effects OS

Static reverse-engineering of the resident kernel record (2026-07-19):
**rec04, CPU `0x486BD9A8`, 4,597 bytes — the ADSP-21065L program that runs the
whole effects subsystem**. Everything below is read off the committed listing
`../disasm/dsp/rec04_kernel_0x486BD9A8.asm` (PM/DM addresses quoted
throughout), the ADSP-21065L Technical Reference (register/bit tables cited as
"TRM"; PDF in the project root), the KN7000 service manual schematic (IC306
sheet), and the MN10300 host-driver RE in
`../../kn7000_mame/notes/dsp-host-interface.md`. Live-emulation evidence is
cited from `kn7000_mame/notes/` where it corroborates. Claims not pinned by
one of those are marked **PROVISIONAL**.

**Headline**: the kernel is a tiny static-priority operating system. It is
host-booted through the 21065L's own IOP registers (the "host protocol" the
CPU speaks *is* the documented ADSP-21065L host interface — nothing custom),
then runs a single interrupt-paced loop that dispatches **10 effect-unit call
slots** per 44.1 kHz sample frame, feeds them audio through **eight
self-chaining SPORT DMA ring buffers** (four serial lines in, four out, to/from
the tone generator), grants each slot a fixed window of one scrolling SDRAM
delay arena and one scrolling internal ring, locks the external bus during the
delay-critical half of every frame so the CPU can hot-patch coefficients
race-free in the other half, and exposes six "scrub" stubs that let the host
silence and zero-fill a slot's delay memory before a new effect moves in.

Kernel record layout (8 blocks):

| block | size | content |
|---|---|---|
| PM `0x8000` | 258 w | vectors + ISR + main loop + dispatch stubs (`0x8000..0x8101`) |
| PM `0x8300` | 64 w | four shared filter/interpolation helpers |
| PM `0x8400` | 7 w | default passthrough effect (slot-0 template) |
| PM `0x8D00` | 147 w | one-time boot init — later **overwritten by effect slot 9** |
| DM `0x9800` | 0x50 w | per-unit state slab (template; ×10 at runtime) |
| DM `0x9C40` | 20 w | per-unit scrub-countdown words (read over the PM bus) |
| DM `0xC000` | 0x4D w | per-unit parameter slab (template; ×10) |
| DM `0xC302` | 152 w | **eight SPORT DMA TCBs** + I/O rings + a memory-map table |

## 1. Boot: the host protocol is the 21065L host interface

IC306 has no boot ROM (service manual SPC sheet: only IC307/IC308 16M SDRAM,
IC302/IC304 bus transceivers, IC303 D-flip-flop latch, IC301 OR gate around
it; `BSEL` pin 152 strapped for host boot). The MN10300 reaches it through two
mapped ports — **`0x98000000` = address latch, `0x9C000000` = data** — and the
"registers" the firmware pokes are simply **21065L IOP registers**, selected
by the latch (IC303) and accessed 16 bits at a time (the TRM's host-interface
mode; SYSCON reset value sets HBW=16-bit). Every magic constant in the
host driver decodes against the TRM:

| host reg | 21065L register | use in the KN7000 driver |
|---|---|---|
| `0x00` | SYSCON | boot probe reads it expecting **`0x20` = SYSCON's documented reset value** (HBW=16-bit): a "DSP present and freshly reset" liveness check (10 retries, else dead-flag `0x500066CC=0xFF`) |
| `0x0B` | MSGR3 (message register 3) | probe-record result/ID readback — rec00–03 each write DM `0x0B` at every test stage (e.g. rec00 PM `0x8404/0x840F/0x8418/0x8421/0x842A`); kernel init zeroes MSGR3–7 (`0x8D2F..0x8D33`) |
| `0x1C` | DMAC0 (EPB0 DMA control) | commit strobe: **`0xA1` = DEN+DTYPE+PMODE:16↔48 → PM download** (48-bit instructions packed from 3×16-bit host words), **`0x41` = DEN+PMODE:16↔32 → DM download** (2×16), **`0xA0` = DEN off** (park channel) |
| `0x1D` | DMAC1 (EPB1 DMA control) | written during full re-init |
| `0x37` | DMASTAT | busy poll during downloads (bit6 = EPB0/ch8 active, bit7 = EPB1/ch9 active; the driver polls bit7 — which of the two FIFO directions that maps to is unverified) |
| `0x40/0x41/0x42` | IIEP0 / IMEP0 / CEP0 | download header: target address / address modify / word count for external-port DMA channel 8 |
| `0x43 / 0x4B` | CPEP0 / CPEP1 | chain pointers, cleared during re-init |
| `0x04` | EPB0 (external-port FIFO) | **the "data port"**: the driver latches the index once and hammers 16-bit halves — correct because EPB0 is a FIFO drained by DMA ch8 into ascending internal addresses; no address auto-increment exists or is needed |

So a record download is textbook ADI host boot: write IIEP0=target,
IMEP0=1, CEP0=count, DMAC0=0xA1/0x41, stream the payload into the EPB0 FIFO,
poll DMASTAT. The record format (`README.md`: `{0x2004, mode 0x80=PM/0x00=DM,
flag, target, len, payload}`) carries **no checksums** — integrity relies on
the SYSCON probe, the rec00–03 SDRAM self-tests' MSGR3 verdicts, and (for
audio) the send/return path itself. One unresolved index: re-init also writes
host reg `0xA0`, which is not a documented 21065L IOP register
(**PROVISIONAL** — possibly glue-decoded).

Boot order (driver `0x48404D10`/`0x48405470`): reset the DSP, auto-boot
streams the first 256 words of the PM `0x8000` block (the 258-word block spans
`0x8000..0x8101`; the interpreter re-sends it whole), then rec00–03 SDRAM
probes are tried until MSGR3 answers correctly, then the full kernel record,
then effect records on demand. The reset vector slot holds `IDLE` (`0x8004`)
falling into `JUMP 0x8071` (`0x8005`).

## 2. Vector table (PM `0x8000`, 4 words/vector, TRM Table E-5)

Only two vectors carry code; all else is `RTI` stubs. The full map (now in
`sym/rec04.sym`): `0x8000` reserved-0, `0x8004` **RSTI**, `0x800C` SOVFI,
`0x8010` TMZHI, `0x8014` VIRPTI, `0x8018` IRQ2, `0x801C` IRQ1, **`0x8020`
IRQ0 — the one wired interrupt**, `0x8028/0x802C/0x8030/0x8034`
SPR0I/SPR1I/SPT0I/SPT1I (SPORT DMA — stubs because the rings self-chain
forever and never interrupt), `0x8040/0x8044` EP0I/EP1I (external-port DMA),
`0x8054/0x8058` CB7I/CB15I, `0x805C` TMZLI, `0x8060..0x806C`
FIXI/FLTOI/FLTUI/FLTII, `0x8070` SFT0I.

The IRQ0 ISR is three words, no stack traffic beyond the auto status stack:

```
8020: RTI (DB)
8021: R13 = 1                    ; frame-tick flag for the main loop
8022: BIT SET MODE2 0x40         ; BUSLK — lock the external bus (see §6)
```

`MODE2 0x40` is **BUSLK** (TRM E-7 bit 6, external bus lock) — this corrects
the earlier "ISR↔mainloop handshake flag" reading. Asserting it holds off
host-bus grants; the main loop drops it mid-frame (`0x809C`), which is the
keystone of the coefficient-update path (§7).

## 3. Reset and mode setup (PM `0x8071`)

```
8071: BIT SET MODE2 0x18011      ; IRQ0E (edge) | CADIS (cache off) | FLG0O | FLG1O
8072: BIT SET IMASK 0x100        ; bit 8 = IRQ0I
8073: BIT CLEAR IRPTL 0x100
8074: BIT SET MODE1 0x3000       ; IRPTEN (bit 12) | ALUSAT (bit 13)
8076: IDLE                       ; wait for the first frame tick
8077: CALL 0x8D00                ; one-time boot init
```

- **FLAG0/FLAG1 become outputs** (MODE2 bits 15/16); FLAG2/FLAG3 stay inputs.
  FLAG3 is the input the main loop polls (§5); FLAG0/1 are DSP→board signal
  lines (schematic pins 197/198; their sink is not traced — PROVISIONAL:
  status/IRQ lines back to the glue).
- **ALUSAT** (not NESTM — bit 11 is clear) saturates fixed-point ALU results:
  effects rely on it, e.g. rec07's ±1.15 modulator sums clipping at ±1.0
  (`chorus-family-algorithms.md` §3).
- Cache is *disabled* here, re-enabled inside init (`0x8D4E` clears CADIS)
  right before the four PM-bus-heavy helpers are called once each
  (`0x8D51..0x8D5A`), then **frozen** (`0x8D5D` sets MODE2 `0x80000` = CAFRZ,
  TRM bit 19). Reading: warm the conflict cache on the shared helper loops,
  then lock those entries in (PROVISIONAL interpretation; the bit decode
  itself is TRM fact).

## 4. Audio I/O fabric: eight self-chaining SPORT DMA rings

### 4.1 SPORT configuration (init `0x8D62`)

`STCTL0/STCTL1 = 0x013CB173` (DM `0xE0/0xF0`), `SRCTL0/SRCTL1 = 0x013C3173`
(DM `0xE1/0xF1`). Against TRM E-23/E-24: **standard mode** (MCE=0, OPMODE=0 —
not I²S, not multichannel; init zeroes the multichannel/keyword registers
`0xE8..0xEC`, `0xF8..0xFC`), **24-bit words** (SLEN=23), sign-extended
right-justified (DTYPE=01), MSB first, **external clock and external frame
sync** (ICLK=0, IRFS/ITFS=0 — the tone generator is the timing master),
rising-edge sampling (CKRE), frame-sync required (TFSR/RFSR; TX
data-independent, DITFS), and **DMA enabled with chaining on both A and B
channels of both SPORTs** (SDEN_A/SCHEN_A/SDEN_B/SCHEN_B, SPEN_A, SPEN_B).

### 4.2 The TCBs (DM `0xC306..0xC341`) and the TRM-pinned channel map

Init (`0x8D68..0x8D77`) writes eight **chain-pointer registers** — and the
TRM's IOP addresses identify every channel exactly:

| CP write | register (TRM) | DMA ch | serial pin | TCB @ | ring buffer |
|---|---|---|---|---|---|
| `DM(0x73)=0x4309` | CPT0A | 4 | **DT0A out** | `0xC309` | `0xC342..0xC349` |
| `DM(0x53)=0x4311` | CPT0B | 5 | **DT0B out** | `0xC311` | `0xC34A..0xC351` |
| `DM(0x7B)=0x4319` | CPT1A | 6 | **DT1A out** | `0xC319` | `0xC352..0xC359` |
| `DM(0x5B)=0x4321` | CPT1B | 7 | DT1B out (unused) | `0xC321` | `0xC35A..0xC361` |
| `DM(0x63)=0x4329` | CPR0A | 0 | **DR0A in** | `0xC329` | `0xC362..0xC369` |
| `DM(0x33)=0x4331` | CPR0B | 1 | **DR0B in** | `0xC331` | `0xC36A..0xC371` |
| `DM(0x6B)=0x4339` | CPR1A | 2 | **DR1A in** | `0xC339` | `0xC372..0xC379` |
| `DM(0x3B)=0x4341` | CPR1B | 3 | DR1B in (unused) | `0xC341` | `0xC37A..0xC381` |

Each TCB (kernel DM block `0xC302`, read descending from the CP address per
the 2106x chaining convention, CP value + internal base `0x8000`) is four
words `{CP'=itself, C=8, IM=1, II=buffer}` — **a chain that points at its own
TCB**: an infinite autobuffer. Each serial line therefore carries **8 words
per 44.1 kHz sample frame** (4 stereo pairs), continuously re-armed with zero
software attention — which is why all four SPORT interrupt vectors are RTI
stubs. The service manual names the board nets: **SDIE0–3** (TG→DSP, into
DR0A/DR0B/DR1A/DR1B through resistor network Z301) and **SDOE0–3** (DSP→TG
from DT0A/DT0B/DT1A/DT1B via Z304); the index↔pin pairing within each group
is not OCR-recoverable (PROVISIONAL: identity order).

### 4.3 Which unit reads/writes which ring words (the I4 walk)

The main loop resets `I4 = 0xC342` each frame (`0x807F`). Every unit program
follows the kernel convention: input = `DM(I4+0x20)/DM(I4+0x21)`, output = two
`DM(I4,M2)` writes leaving I4 +2 (the +0x20 offset is exactly the TX→RX buffer
distance). The walk includes a deliberate `+0x0A` hop before call 7 (`0x8092`)
and `-0x0A` after it (`0x8096`), plus a final `+2` skip (`0x80A2`):

| call | unit | out (TX slot) | in (RX slot) | serial line |
|---|---|---|---|---|
| 1 `0x8080` | u0 | `0xC342/3` | `0xC362/3` | SPORT0-A |
| 2 `0x8083` | u1 | `0xC344/5` | `0xC364/5` | SPORT0-A |
| 3 `0x8086` | u2 | `0xC346/7` | `0xC366/7` | SPORT0-A |
| 4 `0x8089` | u3 | `0xC348/9` | `0xC368/9` | SPORT0-A |
| 5 `0x808C` | u4 | `0xC34A/B` | `0xC36A/B` | SPORT0-B |
| 6 `0x808F` | u5 | `0xC34C/D` | `0xC36C/D` | SPORT0-B |
| 7 `0x8093` | u6 | `0xC358/9` | `0xC378/9` | **SPORT1-A** |
| 8 `0x8097` | u7 | `0xC350/1` | `0xC370/1` | SPORT0-B |
| 9 `0x809D` | u8 | `0xC352/3` | `0xC372/3` | SPORT1-A |
| 10 `0x80A0` | u9 | `0xC356/7` | `0xC376/7` | SPORT1-A |

(Pairs `0xC34E`, `0xC354` and the whole SPORT1-B pair are never used. This
table matches the live-verified walk in
`kn7000_mame/notes/effect-multi-unit-routing.md` 2026-07-11★★★.) The hop
exists to give the 7th-called unit a third-line slot — a routing crossbar
baked into instruction order (see §8).

## 5. The per-sample execution chain (PM `0x8078..0x80A5`)

```
8078: R13 = 0                          ; re-arm
807A: IF EQ JUMP 807A (DB)             ; spin until the ISR sets R13
807B: I1 = 0xC004                      ; parameter cursor (+0x4D/unit)
807C: I8 = 0x9800                      ; state cursor (+0x50/unit, PM bus)
807D: I12 = 0x9C40                     ; scrub-countdown cursor (+1/unit)
807E: DM(0x2F) = R13                   ; IOSTAT: drive FLAG4 pin HIGH
807F: I4 = 0xC342                      ; I/O slot cursor
8080..80A0: ten CALLs                  ; the unit chain (delay slots carry
                                       ;   the I6/I2 arena advances, §6)
8082: BIT CLEAR IMASK 0x100            ; (call-1 delay slot) mask IRQ0
8098: IF FLAG3_IN, MODIFY(I3, M3)      ; poll the FLAG3 input pin
8099: BIT TOGGLE ASTAT 0x100000        ; software ping-pong flag (bit 20)
809B: DM(0x2F) = 0                     ; FLAG4 pin LOW
809C: BIT CLEAR MODE2 0x40             ; release BUSLK
80A3: JUMP 8078 (DB)
80A4: BIT SET IMASK 0x100              ; re-enable IRQ0
```

Facts worth naming:

- **`DM(0x2F)` is IOSTAT** — the FLAG4-11 programmable-I/O status register
  (TRM E-20), and IOCTL (`DM(0x2E) = 0x8852A05B`, init `0x8D7C`) sets
  **FLG4O=1: FLAG4 is an output pin** (IC306 pin 138). The "frame flag" is a
  real hardware **frame-busy strobe**, high from frame start until after call
  8. (This corrects the old "frame-in-progress scratch word" reading.)
- IRQ0 is masked for the whole unit chain and re-enabled in the loop-back
  delay slot. Edge-latched IRQ0 means an overrun tick is delayed, not lost.
- In ROM all ten CALLs target the null stub `0x80F7` (calls 8/9 target the
  copy stub `0x80FB`). **The host patches each CALL's target word to
  `0x8400 + unit*0x100`** when it loads an effect into that slot (single-word
  PM poke, driver `0x48407B1E`); live PM reads confirm the patched chain
  u0=`0x8400` … u9=`0x8D00` (`effect-multi-unit-routing.md` 2026-07-11).
  Slot 9's program area **is the boot-init block** — `0x8D00` runs once and
  is then overwritten. PM budget per slot = 0x100 words; the largest effect
  record is 115 words.
- Default behavior of an empty slot: `0x80F7` advances all four per-unit
  cursors (`I4+=2` via M1, `I1+=0x4D`, `I12+=1`, `I8+=0x50` — `0x80F7..0x80FA`)
  and **writes nothing** (a send bus with no effect returns silence — the TX
  ring words simply stay zero); the two `0x80FB` slots (calls 8/9 = u7/u8)
  instead **copy input→output** (`R0=DM(0x20,I4); DM(I4,M2)=R0` ×2,
  `0x80FB..0x80FF`). u8 is the EQ *insert* — an in-line unit must default to
  unity passthrough. This is the bare-kernel state MAME observed as "four
  output words per frame at `0xC350/1+0xC352/3`" (`f3-effect-loading.md`).
  Effect type 0x00 (rec05) is different again: it writes two **zeros** — a
  mute stub for send slots.
- `0x809E` (call-9 delay slot) sets `I0 = I1`: I0 is the coefficient-stream
  pointer of the shared helpers (§7), primed here for u8's EQ program (rec34
  CALLs helper `0x831B`).
- The `FLAG3` poll shifts I3 (the third delay ring, §6) by −1 only when the
  external pin is high, and `ASTAT` bit 20 toggles every frame — a
  frame-parity flag effects can branch on. Only rec58–61 gate on FLAG3 —
  and their design **pins its function** (2026-07-19,
  `final-batch-algorithms.md` §1): FLAG3 must be a **fs/2 frame-parity
  strobe**. The mic reverbs split a series-allpass tank across the two
  FLAG3 phases and rely on the I3 ring scrolling exactly once per two
  frames (the poll sits in u7's call delay slot, so the scroll lands
  immediately before the mic program runs); any other FLAG3 behavior
  breaks their delay bookkeeping. I3 is therefore a **half-rate delay
  arena** — 18,000 words = 816 ms of reach. (The pin's physical driver on
  the board remains untraced — function is design fact, source
  PROVISIONAL.)

## 6. The delay-memory manager

All delay storage is **statically partitioned, scrolling rings**. The DAG
base/length registers (init `0x8D0E..0x8D2D`) define three:

| ring | B/L | where | size |
|---|---|---|---|
| I6 | `B6=0x20000, L6=0x456F0` | external SDRAM | 284,400 w = 6.45 s |
| I2 | `B2=0xC3A0, L2=0x1C60` | internal block | 7,264 w = 165 ms |
| I3 | `B3=0x656F0, L3=0x4650` | external SDRAM | 18,000 w = 408 ms |

(IC307/IC308 = 1M×32 total; the kernel uses 433 K words. Init zero-fills all
three: 6×60,000-word loops at `0x8D7E`, `0x4650` via I3, `0x1C00` via I2.
`WAIT=0x200D0001`, IOCTL SDRAM fields, and **SDRDIV: `DM(0x20)=0x3A2`** — the
SDRAM refresh divisor, 930 cycles; this corrects the old "input default"
label. 930 cycles ≈ 15.6 µs at ~60 MHz core or 31.25 µs at 33.87 MHz —
whichever, it pins the refresh spec, not the audio path. PROVISIONAL as a
clock deduction.)

**The scroll**: the ten CALLs' delay slots advance I6 and I2 by per-slot
constants that sum to exactly `L−1 ≡ −1 (mod L)` per frame — each ring
scrolls one word per sample, so "read at write+D" = "D samples ago", and
every delay length in every effect is pure address arithmetic. The same
delay-slot constants ARE the per-slot arena grant table:

I6 (SDRAM) advances: `0x8081`+0x7917, `0x8084`+0x10748, `0x8087/808A/808D/
8090/8094/809F` +0x7918 each. Windows (entry cursor → next advance):

| slot(s) | SDRAM window | seconds |
|---|---|---|
| u0 | 0x10748 = 67,400 w | **1.53 s** (the reverb slot — rec5x's deepest write 0xB7A9 fits) |
| u1..u5 | 0x7918 = 31,000 w each | 0.70 s |
| **u6+u7 (shared)** | 0x7918 | 0.70 s |
| **u8+u9 (shared)** | 0x7917 | 0.70 s |

I2 (internal) advances: `0x8085`+0x45F, `0x8088/808B/808E/8091/8095/80A1`
+0x400 each. Windows: u0 **1,119 w** (u9 enters at the same cursor —
effectively u0+u9 shared), u1..u5 1,024 w each, u6+u7+u8 shared 1,024 w.

The sharings are consistent with the unit roles: u8 (EQ) needs no delay, u9's
programs (rec06/07/09 family) are I2-only with ≤866-word footprints — fitting
the 1,119-word first window they share with the I6-only reverb on u0. The
{u6,u7} SDRAM share looked like the one corner where two concurrently-active
delay effects could collide — **resolved** (2026-07-19): u7's whitelist
admits only the mic reverbs rec58–61, and those use **no I6 and no I2 at
all** — their tank lives entirely in the u7-exclusive half-rate I3 ring
(`final-batch-algorithms.md` §1). The shared windows have exactly one real
user (u6).

**The scrub stubs** (`0x80A6..0x80F6`): six variants of a
silence-and-zero-fill routine, elegantly overlapped (each stub's `RTS(DB)`
delay slots are the next stub's first two words). Per frame a scrub stub
writes zero to the slot's two TX words, reads the slot's countdown from the
`0x9C40` table (over the PM bus via I12), subtracts 0x28, clamps at 0, skips
that far into the slot's arena and zeroes 0x29 (0x51 for the `0x80E7`
variant) words there, writes the countdown back, and advances all cursors.
Entry points: `0x80A6/0x80CF/0x80DE` (I6 variants), `0x80B2` (I2), `0x80C0`
(I3, plus an ASTAT toggle at `0x80CD`), `0x80E0` (zeroes 20 PM-side state
words instead), `0x80E7` (0x50-stride state+arena variant). Net effect: park
a slot on a scrub stub with `0x9C40[unit] = arena size` and its delay memory
is wiped end-to-start, 41 words per frame, while the slot outputs silence —
**no stale reverb tail can bleed into the next effect**. (Mechanism is fact;
the host-side usage is now **captured live** (2026-07-20,
`kn7000_mame/notes/dsp-unit-roles-live-capture.md`): every GUI effect-select
burst arms `0x9C40+unit` and writes the unit's CALL-slot word twice —
once around the swap, once to re-patch the effect — exactly the
park-on-scrub choreography this section predicted.)

## 7. Effect ABI + the coefficient hot-patch path

Per-unit context at CALL time: `I1` = params (`0xC004+unit*0x4D`; words
`c000..c003` below I1 are per-unit scratch — rec09 keeps float feedback state
in `c002/c003`, rec51 saves I6 in `c003`), `I8` = state (`0x9800+unit*0x50`,
PM bus), `I12` = the `0x9C40` word, `I4` = I/O cursor, `I0` = coefficient
stream for helper-based programs. Modify-register contract (init `0x8D00`):
`M1=2, M2=+1, M3=−1, M4=−2, M5=0x4D, M6=0` (DM); `M8=+1, M9=+2, M10=+3,
M11=−1, M12=−2, M13=0x50, M14=0` (PM). Every program ends
`RTS(DB); R4=DM(I1,M5), R7=PM(I12,M8); MODIFY(I8,0x50)` — the delay slots
advance the next unit's cursors.

Shared helpers (PM `0x8300`): `0x8300` float biquad/MAC chain, `0x830B`
fixed-point IIR (MRF), `0x831B` **the 5-section EQ cascade** — FLOAT →
first-order + `LCNTR=3` biquad loop + first-order → FIX, loading the clip
bound into R15 (this corrects the earlier "3-tap-interpolation coefficient
generator" reading: the "3" is the biquad loop count; rec34, the unit-8
5-band EQ, is a 13-word wrapper around it and rec23 is its inlined twin —
`dynamics-eq-exciter.md` §5) — and `0x8338` second float MAC — all stream
coefficients from `DM(I0,M2)` and state from `PM(I8,…)`; boot init calls
each once (cache warming, §3).

**How CPU parameter writes land in a running effect**: the host simply
DMA-writes the unit's DM param block (`0xC000+unit*0x4D`, and/or state at
`0x9800+unit*0x50`) through EPB0 — there is no mailbox, no dirty flag, no
kernel cooperation on the DSP side (all of that machinery lives host-side in
the 0x120-byte structs of `DspEffectSelect`). It is race-free anyway, because
effects re-read their entire coefficient bank from DM **every frame** (live
full-frame traces: the reverb streams `c004..c02x` per sample), and **BUSLK
(§2) holds host accesses off the bus from the IRQ0 tick until `0x809C`** —
after the eight delay-critical unit calls. Host bursts therefore land in the
frame tail and take effect atomically at the next frame's re-read: ≤1 sample
frame of latency, no torn banks — the mechanism behind audible mid-note
reverb-depth changes. (BUSLK's decode is TRM fact; "designed as the
coefficient-window" is interpretation — PROVISIONAL. Note the two units that
run *after* the unlock, u8/u9, are exactly the two that touch no SDRAM.)

## 8. The MULTI question: ~~which slot serves the `0x8298` TG send~~ — ANSWERED LIVE 2026-07-20 (the §8 verdict below was WRONG)

**Resolved by the DspEffectSelect + upload live capture**
(`kn7000_mame/notes/dsp-unit-roles-live-capture.md`): driving the four
effect GUIs while tapping the param block AND the host download ports gives
the full fixed-function unit map as live fact:

| unit | live role | GUI evidence |
|---|---|---|
| u0 | **REVERB** | reverb presets → {unit0, types 0x10/0x12/0x14/0x16}, records to PM `0x8400` |
| u1 | **MULTI** (captured state) | Multi Cross-Delay presets → {unit1, 0x0C=rec15}, PM `0x850C/0x8529` delay-immediate patches |
| u2..u6 | per-part Sound-DSP / Digital-Effect insert pool | SOUND DSP (RIGHT1) → {unit2, 0x03=rec08}; boot defaults u2=0x03 u3=0x06 u4=0x01 u5=0x29 u6=0x05; PANEL MEMORY recalls resync all five |
| u7 | **MIC REVERB** | resyncs write {unit7, 0x58=rec58} + rec58's PM immediates |
| u8 | EQUALIZER | boot {unit8, 0x4F} |
| u9 | **CHORUS** | Chorus1–4 → {unit9, 0x52=rec49}; GM Chorus1–4 → {unit9, 0x02=rec07} |

So the prior verdict "MULTI = u6" is **REFUTED**, and with it this section's
load-bearing hypothesis (bank↔line 1:1): the three TG send banks land on
specific TDM **pairs**, two of them on the same line —

| TG send bus | unit | input pair (§4.3) | line |
|---|---|---|---|
| REVERB `0x80xx` | u0 | `0xC362/3` | SPORT0-A pair 0 |
| MULTI `0x82xx` | u1 | `0xC364/5` | SPORT0-A pair 1 |
| CHORUS `0x81xx` | u9 | `0xC376/7` | SPORT1-A pair 2 |

The step-3 "cross-check" above rested on the whitelist role labels
(u7=Chorus, u9=Reverb, u0=Enhancer) — all three of which the capture
falsifies. The whitelist *contents* always agreed with the corrected roles:
u0 admits the six rec5x comb+allpass reverbs (0x10–0x1F), u9 admits only
modulated-delay choruses (rec06/07/09/70/49 — this doc's own §6-family
finding that "the unit-9 records are NOT reverbs" is finally explained), u7
admits the rec58–61 mic reverbs. Correct corollaries that survive: u6's
`+0x0A` I4 hop serves an ordinary insert slot (nothing special about u6);
u7's input `0xC370/1` is the TG's MIC feed; u8's `0xC372/3` is the
master-mix insert feed. Caveat recorded: "MULTI = u1" is the captured
machine state (boot default + two PMEM registrations); a registration that
allocates the multi elsewhere in the u1–u6 pool is not excluded.

## 9. Open questions

- ~~Bank↔line identity order (§8)~~ — **resolved 2026-07-20** by the live
  unit-role capture (§8): banks map to TDM pairs (u0/u1/u9), not lines.
  Still open from that capture: whether the ALLOCATION screen can move the
  MULTI/Sound-DSP assignments within the u1–u6 pool.
- ~~What drives the FLAG3 input pin, and the {u6,u7} shared-SDRAM-window
  concurrency corner (§6)~~ — **both resolved 2026-07-19** by the rec58–61
  annotation (`final-batch-algorithms.md` §1): FLAG3 = fs/2 parity strobe
  by design necessity (physical source still untraced), and u7's mic
  reverbs never touch the shared windows. Related detail explained there:
  boot init zeroes MSGR3–7 but *not* MSGR2 (`DM 0x0A`) — MSGR2 is the mic
  reverbs' I3-cursor save cell.
- FLAG0/FLAG1 output sinks; host reg `0xA0`; the exact SDIE/SDOE index↔pin
  order; the DSP core-clock (SDRDIV reading, §6).
- The `0xC382..0xC399` memory-map table: `{0x022000,0,0x020000}` /
  `{0xC000,0x66}` / `{0x9800,0x33}` region descriptors with stride words
  (`0x4D`, `0x100`+`0x8400`) — nothing in the kernel PM references it; it
  looks like a host-read rebase/region directory (**PROVISIONAL**; labels in
  the sym).

## 10. Cross-model

KN6000/KN6500 (`cross-model/README.md`): all four kernel DM blocks —
including the TCB/ring tables, so the entire §4 I/O fabric — are
byte-identical; the PM is an older build. The §4.3 walk and §6 window tables
should be re-derived from the KN6xxx PM before porting unit-role conclusions.
