# Probes for notes/open4-kn5000-b/cpanel

| file                      | question it answers                                                                                                       |
|---------------------------|---------------------------------------------------------------------------------------------------------------------------|
| `led_boot_tap.lua`        | Which control-panel LED rows does the main CPU send after power-on, and when?                                             |
| `led_boot_tap.cold.log`   | Its output, cold start (empty nvram directory)                                                                            |
| `led_boot_tap.second.log` | Its output, second start with the nvram the first run left (identical: the MAME build does not keep the power-down state) |
| `ref_scan.py`             | Does any 3-byte copy of an address occur in a program ROM (is a routine reachable through a pointer)?                     |
| `flag_access_scan.py`     | Which instructions touch `CPANEL_TX_RX_FLAGS` (0x8D8C) / `CPANEL_PROTOCOL_FLAGS` (0x8D92)?                                |

## led_boot_tap.lua

Signal: writes to `CPANEL_LED_IMAGE_SENT` (v10 RAM 0x8F28-0x8F37, one byte per LED row 0..15 in
`Protocol_values_for_LED_rows` order).  `CPanel_LED_FlushImage` writes a row there right after it queues that
row's 2-byte LED frame, so every logged change (pc = 0xFC71A3) is one frame sent to a panel.  The writes at
pc 0xEF0B9B are `Boot_InitWorkRAM` zeroing RAM, not frames.  A row value is the LED bit pattern
(control-panel-protocol.md, LED mapping tables).

Run (kn7000_mame build tree; the romset directory holds `kn5000/`; scratch outside the repo):

    mkdir -p ~/compartilhado/tmp/ledtap/cfg ~/compartilhado/tmp/ledtap/nvram
    cd ~/compartilhado/kn7000_mame_build
    LEDTAP_SECONDS=30 ./kn7000 kn5000 -rompath ~/compartilhado/technics_romsets -skip_gameinfo \
        -autoboot_delay 0 -video none -sound none -nothrottle \
        -cfg_directory ~/compartilhado/tmp/ledtap/cfg -nvram_directory ~/compartilhado/tmp/ledtap/nvram \
        -autoboot_script <repo>/notes/open4-kn5000-b/cpanel/probes/led_boot_tap.lua | grep '^LED'

Measured 2026-10-31 with the kn7000_mame build of 2026-10-31 (binary `kn7000_mame_build/kn7000`, 18:20).
Times are emulated seconds in MAME, whose sub-CPU boot ROM is a BAD_DUMP: they are not hardware timings.

## ref_scan.py

    python3 notes/open4-kn5000-b/cpanel/probes/ref_scan.py original_ROMs/kn5000_v10_program.rom 0xFC4021 0xFC47F1
    python3 notes/open4-kn5000-b/cpanel/probes/ref_scan.py original_ROMs/kn5000_v7_program.rom 0xFC3856

Result 2026-10-31: 0 hits for all three (v10 `CPanel_SendFramePolled`, the unlabelled code after
`CPanel_SM_Idle`, v7 `CPanel_SendFramePolled`).  Pass = no hit means no pointer to it; together with no
symbolic reference in the sources, the code is unreachable.

## flag_access_scan.py

    python3 notes/open4-kn5000-b/cpanel/probes/flag_access_scan.py original_ROMs/kn5000_v10_program.rom.unidasm

Result 2026-10-31: 40 accesses, all in 0xFC3E94-0xFC4B24 (cpanel_routines).  No `or` with 0x10 on 0x8D8C (bit 4
is never set); 0x8D92 is read only by `bit 0` at 0xFC4775.

## Schematic pages (not committed; rendered from the service manual in technics-docs)

    pdftoppm -r 400 -f 45 -l 45 -png technics-docs/service_manual/technics_sx-kn5000.pdf cpl   # sheet II-35/36, CPL board
    pdftoppm -r 400 -f 32 -l 32 -png technics-docs/service_manual/technics_sx-kn5000.pdf cpu   # sheet II-11/12, CPU SECTION (A)

CPL: SW101, R11-R14, C7/C8 and IC1 pins 30/31 at the left edge, rows C-B; AD0-AD3 and CN3 just below.  CPU:
the `EXP`/`AFT` inputs at the top-left edge run to IC5 pins 150 (AN0) and 151 (AN1).
