# The tone generators' wave ROM read port (PROGRAM 941), 2026-10-18

How the service-mode WAVE ROM test (service manual 8.9) reads the four wave ROMs, which chip each
of its steps reaches, and how the two MAME drivers answer the same accesses. Written for a ROM
dumper that runs on the stock firmware. Probe: `wave-rom-port-probes/` (README there).

## The routine

| address      | name                      | what it does                                                          |
|--------------|---------------------------|-----------------------------------------------------------------------|
| `0x484A2E3A` | `MainWaveRomTestFunc`     | runs index 0..3, ORs error bit n per index, paints five OK/NG fields  |
| `0x48483B63` | (per-index check)         | index 0..3: core(TG, 0, 0x00FFFFFF, bit0), compare with golden sum    |
| `0x484839A1` | (checksum core)           | the read loop below; returns the 32-bit sum                           |
| `0x48483B12` | (expansion-board variant) | index 4..19: start 0x02000000..0x03800000, length from a board header |

The core, for port `P` (`0x98050000` when its TG argument is 0, `0x98040000` otherwise),
first unit `S`, last unit `E` and select bit `c`:

    movhu 0x8000 -> P+6 ; LibTickSleep(1)                 ; 0x484839BC / 0x48483A68
    for bank = S>>15 .. E>>15:
        movhu 0x8000|bank -> P+6
        for a = c, c+2, .. 0x7FFF:
            movhu 0x8000|a -> P+8
            w = movhu P+A                                 ; 16-bit, no wait, no status poll
            sum += (w >> 8) + (w & 0xFF)                  ; 32-bit, wraps
    movhu 0 -> P+6 ; LibTickSleep(1)

These six addresses (`P+6/8/A` for both ports) appear nowhere else in the program image, so no
other firmware code competes for the latches.

For index 0..3, `S = 0`, `E = 0x00FFFFFF`: 512 banks of 0x4000 reads, 8 Mi words, 16 MiB per
chip. Both latches always carry bit 15 set while reading.

## Which chip each index reads

From `wave_rom_test_map.py`. The OK/NG object an index is painted into sits right of a label on
the WAVE ROM TEST page, so the firmware itself names the chip:

| index | port         | `+8` bit 0 | golden sum   | firmware label    |
|-------|--------------|------------|--------------|-------------------|
| 0     | `0x98050000` | 0          | `0x8164C77C` | MAIN TG ... IC203 |
| 1     | `0x98050000` | 1          | `0x815CFC83` | IC204             |
| 2     | `0x98040000` | 0          | `0x8331EF0B` | SUB TG ... IC207  |
| 3     | `0x98040000` | 1          | `0x83254F9D` | IC208             |

So the firmware calls `0x9805xxxx` the MAIN TG (IC203/IC204), and bit 0 = 0 the Y-bus ROM
(IC203, IC207). That is consistent with the voice router at `0x487EFF69` (voices 0..63 go to
`0x98050000`) and with the single-TG models, whose one TG is at `0x98050000`. It contradicts the
symbol `ToneGenWriteMain` (`0x487EFF92`, writes `0x98040000`) in `kn7000_manual.sym` and the
"master = 0x98040000" wording in kn5000-docs `kn7000-sound-subsystem.md`. The labels are the
firmware author's; no hardware capture has confirmed them yet.

## Dumper formula

For chip byte offset `f` (0 .. 0xFFFFFF, even), port `P` and bit `c` from the table:

    bank = f >> 15                       write 0x8000 | bank       -> P+6 (once per bank)
    addr = 0x8000 | (f & 0x7FFE) | c     write addr                -> P+8
    w    = read16(P+A)                   file[f] = w & 0xFF, file[f+1] = w >> 8

Bracket the sweep as the firmware does (`0x8000` then a 1-tick sleep before, `0` then a 1-tick
sleep after), and use the uncached `0x98xxxxxx` addresses. A whole-file check is
`sum(file) mod 2^32 == golden`; it cannot see a byte swap inside words.

## How MAME answers

| driver                                          | port to chip                                                     | bank              | out of range                    |
|-------------------------------------------------|------------------------------------------------------------------|-------------------|---------------------------------|
| upstream (`mame-pr-kn-flop-rebuild` `ef311a49`) | `0x98040000` main_y/x, `0x98050000` sub_y/x; bit 0 = 1 selects x | `& 0x7FFF`        | `0xFFFF` past 16 MiB, no mirror |
| overlay (`kn7000_mame` `1cee9fe`)               | all four read one 16 MiB `wavepack`, `(rom*16Mi + 2W) mod 16Mi`  | `& 0x1FF` (wraps) | none: banks mirror every 512    |

Both compute the region byte as `2 * (bank * 0x4000 + ((addr >> 1) & 0x3FFF))` and return
`get_u16le`, low byte = region byte `2W`, which matches the formula above. Both ignore bit 15 of
either latch, so neither catches a dumper that forgets it. Upstream's port-to-chip assignment is
the opposite of the firmware's labels (its KN6000/KN2600 single TG at `0x98050000` is "main",
consistent with the firmware), so with real dumps loaded the 8.9 test would compare IC207's sum
against IC203's golden value. In the overlay the four chips are indistinguishable.

## Read on a real instrument (2026-10-19)

The ROM dumper's WAVE build ran this protocol on a KN7000 with PROGRAM 893, whose checksum routine is
the same instruction stream as 941's. Two runs were byte-identical. Each (port, select) pair gave
exactly the sum the firmware expects for its index: `0x98050000`/0 `0x8164C77C`, `0x98050000`/1
`0x815CFC83`, `0x98040000`/0 `0x8331EF0B`, `0x98040000`/1 `0x83254F9D`. So the table above holds on
real hardware, and upstream MAME's port assignment was the swapped one. The chip names are the
firmware's labels; the board has not been traced.

The data (checks in the private ROM repository, `real_dump_v1.3_b893/wave-analysis/`):
- 16-bit samples, low byte first, in sample order.
- Each tone generator's Y and X ROMs are the even and odd samples of one stream, word *i* of Y
  followed by word *i* of X. The tone generator fetches two neighbouring samples at once.

