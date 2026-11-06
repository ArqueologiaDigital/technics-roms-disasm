# The KN7000's audio mute and switch lines: service manual trace, firmware writers, MAME watch

Lane kn7000-research2 (wave 12, 2026-11-06), item N-44e56012 (the silence on SD PICTURE LOAD).  Wave 11
showed in MAME that a key played on SD PICTURE LOAD reaches the tone generators and is audible
(`../picload-silence-probes/README.md`), so the silence the owner's manual describes must come from
outside the tone-generator path.  This folder follows the service manual's mute lines to the CPU, lists
every firmware write to them, and watches them in MAME on that screen.

Every MAME result here is **observed in emulation, not on hardware**: the kn7000_mame overlay build
`/home/fsanches/compartilhado/kn7000_mame_build/kn7000` (md5 `8b9865bd2e3849bea134c97315c9781e`), used
read-only, ROMs from `~/compartilhado/technics_romsets`, the SD slot holding a fresh copy of
`~/compartilhado/technics_roms/media/sdcard_from_real_kn7000.img` (md5 `c3bcea2346cb3bb7d803e8c48aebce78`).

| file               | question it answers                                                                                                                                    | run (from `kn7000/`)                                                      |
|--------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------|
| `sm_crops.sh`      | what the service manual's schematics show for the mute / switch lines: renders the thirteen crops the trace below was read from                        | `sh notes/audio-mute-probes/sm_crops.sh [PDF] [OUTDIR]`                   |
| `audio_writers.py` | which code of a program build writes PMUT (P04 bit 2), the IC25 latch (0x98060000), M3 id 0x600009 and the D/A converter's mode words, with what value | `python3 -I notes/audio-mute-probes/audio_writers.py program` (or `b893`) |
| `audio_lines.lua`  | in MAME, from power-on through SD PICTURE LOAD and a key held on it, does PMUT, SPSW, SDMODE or a D/A converter mode word ever change                  | see below                                                                 |

`audio_lines.lua` command (from a scratch run directory with `cfg/ nvram/ snap/ diff/` and the SD copy as
`sd_real.img`; time-boxed; about 5 minutes):

    OUT=audio_lines.txt timeout 1800 ~/compartilhado/kn7000_mame_build/kn7000 kn7000 \
      -rompath ~/compartilhado/technics_romsets -skip_gameinfo -video none -sound none -nothrottle \
      -debug -debugger none -cfg_directory cfg -nvram_directory nvram -snapshot_directory snap \
      -diff_directory diff -harddisk sd_real.img -autoboot_script audio_lines.lua

For program 893 add `-bios v13` and `BP_CHANGETITLE=0x4842B3B2 BP_INTERRUPTTITLE=0x4842B45E`.  The
screen route is wave 11's (`picload_keys.lua` with `TITLE=0xD6 AFTER="LCDR 2"`): PROGRAM MENUS,
SEQUENCER, RECORD & EDIT redirected to the PICTURE LIST, its PICTURE LOAD item, which makes the firmware
call `InterruptTitle(0x12B)`, the SD PICTURE LOAD screen; key C4 held 1 s on the home screen (window A),
on SD PICTURE LOAD (B) and after EXIT (C).

| run file                     | build                      | what it shows                                                                                                                           |
|------------------------------|----------------------------|-----------------------------------------------------------------------------------------------------------------------------------------|
| `runs/audio_lines_941.txt`   | BIOS v16, program 941      | PMUT 0 from reset, 1 from 6.63 s for the rest of the run; SPSW 1 throughout; the two boot mode words only; SDMODE 0 from 1.85 to 6.99 s |
| `runs/audio_lines_893.txt`   | BIOS v13, program 893      | the same, at 893's addresses (PMUT 1 from 6.23 s, SDMODE 0 from 1.66 to 7.36 s)                                                         |
| `runs/audio_writers_941.txt` | `audio_writers.py program` | the static census for 941                                                                                                               |
| `runs/audio_writers_893.txt` | `audio_writers.py b893`    | the same for 893                                                                                                                        |

(The 941 run was made with the probe before its `BP_CHANGETITLE` / `BP_INTERRUPTTITLE` variables were
added; their defaults are the addresses it had.  Both runs' snapshot 2 shows SD PICTURE LOAD.)

## 1. The service manual (technics_sx-kn7000_keyboard.pdf, ORDER NO. EMID0207013C0)

Page numbers are the PDF's; each schematic sheet is printed on two consecutive pages.  Crops: `sm_crops.sh`.

1. **MUTE to the amplifier board.**  FAJ 2/2 (diagram 12, p. 122): connector CN506 (to ASUB CN821) pin 1
   MUTE is the **+15PM** rail.  +15PM is +15A switched by Q514 (PNP, B1ACCF000016): its base is pulled to
   +15A by R633 and pulled down through D512, R637, Q516 (NPN) and Q515.  Q516's base takes the **PMUT** net
   through R636 47K; Q515's base sits on the R680 / R679 divider of +15A, and D511 ties the chain to +VCCF.
   So +15PM is on only while PMUT is high and +15A is up.  On the ASUB board (diagram 14, p. 126) MUTE feeds,
   through R835 / R859 / R846 15K, the input stages of the discrete power amplifiers (L, R and the third
   channel, whose outputs GATE-L1 / L2 etc. drive the output devices).  [INFERENCE] Those resistors supply
   the stages' bias, so with +15PM off the power amplifiers pass no signal: PMUT high = sound, low = muted.
2. **PMUT to the CPU.**  FAJ 1/2 (diagram 11, p. 120): PMUT is CN502 pin 11, to MAIN CN301 pin 11 (MAIN
   3/5, diagram 6, p. 110), where it is a named net.  On MAIN 1/5 (diagram 1, p. 100) the net is bus line
   `c`; at the CPU IC4 (MN103002A) line `c` goes through R1 100 ohm (C3 0.1 uF to ground) to **pin 148,
   TW210/P22**.  The neighbours fix the register: SD.CS (line `l`) is pin 149 P21, FDC.TC (`b`) pin 145
   P24 through R16, SELE.LED (`a`) pin 144 P25, DSP.RST (`m`) pin 142 P27.  The firmware and the MAME driver
   already know those as GPIO byte `P04` = 0x36008004 bits 1, 4, 5 and 7, so **PMUT is P04 bit 2**, and
   [INFERENCE] P04 is the CPU's own port-2 output register rather than a board latch (the comment in
   `src/include/mn103002a_sfr.inc` said "external to the CPU").
3. **SPSW, the second switch.**  MAIN CN302 pin 13 SPSW goes to FAJ CN501 pin 13 (p. 120): through Q511
   (DTC114YSA) and R677 1M / C539 (a slow ramp) it drives the gates of Q502 / Q503 (2SJ498), which sit in
   series between the summed sound (SUMR / SUML, through R540 / R535 39K) and IC506, whose outputs feed the
   headphone amplifier IC509 and the speakers' equaliser IC502 / IC503.  With SPSW low R522 holds the
   gates at +15A.  [INFERENCE] P-channel FETs: SPSW high = the path conducts.
4. **The latch that drives SPSW.**  MAIN 1/5 sheet 2 (diagram 2, p. 102): IC25, a 74AHC174, latches data
   bits D16..D21 into Q6..Q1 = **USB.WAITM, SPSW, SDMODE, DAC.ML, DAC.MC, DAC.MDI**, clocked through IC26
   (an OR gate).  The firmware's only stores with that bit layout go to **0x98060000** (`SD_POWER_CTRL`,
   shadow 0x50005214): bit 0 is toggled by `Midi2RxIsr` around each byte (USB.WAITM), bits 3 / 4 / 5 carry
   the 16-bit serial words of `DacModeWordWrite` (ML low, data on MDI clocked by MC, ML high), and bit 1 is
   set / cleared by the M3 id 0x600009 handler.  So 0x98060000 is IC25: bit 0 USB.WAITM, 1 SPSW, 2 SDMODE,
   3 DAC.ML, 4 DAC.MC, 5 DAC.MDI.  (The program's names `SdPowerCtrl*` and the include's "power
   controller" came from bit 2's SD use; MAIN 5/5, p. 116, routes SDMODE to the SD I/F board's analog
   switches IC404 / IC412.)
5. **The D/A converter's own mute.**  MAIN 3/5 (p. 110): IC311 (C0FBBK000025, "D/A CONVERTER") has its
   MUTE pin 15 tied to ground; its mode port (pins 12 / 13 / 14) is DAC.MDI / DAC.MC / DAC.ML (bus `k` / `l`
   / `m`, legend on p. 108).  The other MUTE on p. 118 is IC406's, the USB-audio converter, off the main path.

## 2. What the firmware writes (static; `runs/audio_writers_941.txt`, `_893.txt`)

Programs 941 and 893 have the same writers at their own addresses:

| line            | writers                                                                                                                                                                                                                                                                                                                                                                                      |
|-----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| PMUT (P04 b2)   | `ResetEntry` writes P04 := 2 (muted) and the boot's `func_484D710E` again; `BootPanelResetCheck` ends with `bset 0x04` (sound on); the NMI handler `func_484D77CF` (893 `func_484D75C2`) clears it before it sets the power latch (bit 3) and spins. `TickJobsTask`'s read-modify-write changes bit 5 only. Nothing else                                                                     |
| SPSW (latch b1) | the boot writes the latch := 0xFF; `AudioOutSwitchM3Handler` (941 0x48491B18, 893 0x4849190B; M3 id 0x600009) clears or sets it by the message's value. The only senders of 0x600009 in the code are three library routines that send 1 (`func_4C01EE3B`, `func_4C02139F`, `func_4C0213F9`); a 0 can only come through a generic parameter path (the id is in `ResourceIdTrie`, `data_00.s`) |
| D/A mode words  | `DacModeInit` at boot: 0x1220, 0x1380, and never again                                                                                                                                                                                                                                                                                                                                       |
| SDMODE (b2)     | `SdPowerRailSet` / `SdPowerRailClear`, from the SD card code                                                                                                                                                                                                                                                                                                                                 |

## 3. MAME (`runs/audio_lines_941.txt`, `runs/audio_lines_893.txt`)

Observed in emulation, both builds alike: PMUT goes 0 -> 1 once, when `BootPanelResetCheck` sets it (6.63 s
on 941), and stays 1 through the home screen, the opening of SD PICTURE LOAD, the key on it and EXIT.  The
latch is 0xFF at reset and 0xEF / 0xEE from 7 s on: SPSW 1 the whole run.  The D/A converter gets its two
boot words and nothing else.  SDMODE is 0 only during the boot's SD mount (1.85 .. 6.99 s).  The only bit
that moves on the screen is USB.WAITM, about 4,400 toggles a second in every window alike (the driver's
USB-MIDI input).  So on SD PICTURE LOAD the emulated firmware drives every software-controlled mute line of
the audio path to "sound on", and the sound is there (wave 11's capture).

## 4. Reading, and what is left

None of the three software-driven mutes the service manual shows (PMUT, SPSW, the D/A converter's mode
register) is used by SD PICTURE LOAD in either program build, statically or in emulation.  The firmware
mutes the power amplifier only from reset until `BootPanelResetCheck` and in the NMI handler, which is why
the instrument is silent while it boots and when the power fails.  So the silence the owner's manual
describes is not made by a mute line.  [INFERENCE] What remains is behaviour the emulation does not
reproduce: the real card's timing (each SD screen reads the card; on the instrument the SPI transfers take
real time, in MAME they are instant), the SD I/F board's own signals (SD BUSY / SD ACC / SD PLY, which
the driver does not model), or the manual describing a precaution rather than a measurement.  This needs
the instrument: play a key on SD PICTURE LOAD with a card holding pictures, and note whether the sound
stops for the whole screen or only while the card is read.

## 5. MAME driver gap (for the kn7000_mame owner; nothing was changed there)

`src/mame/matsushita/kn7000.cpp` keeps 0x36008004 in `m_gpio8004` and uses bits 1 (SD chip select), 3 (power
latch) and 4 (FDC TC); bit 2, **PMUT** (the power amplifier's mute, active low), is stored and not used.
0x98060000, the **IC25 sound-control latch**, falls in the generic `io_r` / `io_w` window: SPSW (bit 1, the
FET switches before the headphone and speaker stages) and the D/A converter's mode words (bits 3..5, a
16-bit word on ML / MC / MDI; the firmware sends 0x1220 and 0x1380 at boot) are not modelled.  Modelling
them would silence the emulated output while the firmware boots (PMUT 0 until `BootPanelResetCheck`) and
in the NMI handler, and whenever the parameter 0x600009 is 0.  None of them changes on SD PICTURE LOAD
(section 3), so modelling them would not reproduce that silence.

**Closed 2026-11-06** in kn7000_mame b0fd265 (`notes/audio-mute-2026-11-06/README.md` there holds the
probes and the measurements).  IC311's 28 pin names are the TI PCM1738's, pin for pin, so the driver
models it from that data sheet: 0x1220 is register 18 = 0x20 (24-bit standard format, no de-emphasis,
no soft mute) and 0x1380 is register 19 = 0x80 (REV, output phase inverted, cancelled by IC316, the
inverting mixer after it).  PMUT and SPSW gate the driver's speaker output; MAIN OUT taps SUML / SUMR
ahead of Q502 / Q503 and has neither switch.  Observed in emulation: a key held with PMUT forced low,
with SPSW forced low and after the NMI handler clears PMUT is silent (it sounds in the build before),
and in normal play the output is sample-identical to before (program 941).  Program 893 keeps the
latch's shadow at 0x5000520C, not 0x50005214.
