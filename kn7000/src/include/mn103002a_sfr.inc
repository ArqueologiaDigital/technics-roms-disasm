# MN103002A on-chip registers (SFRs) and the KN7000-family boards' I/O latches, shared by every
# MN10300 tree (KN7000 builds 941/942/935/893, KN2400/KN2600, KN6000, KN6500, HD-SX3).
# Hand-written source (lane mn10300-names, 2026-11-02).  kn7000/tools/gen_image_s.py --sfr-inc and
# gen_program_s.py read it and spell an absolute operand that equals an address here (or lies up to
# 3 bytes above one, as NAME+N) by its name; the sources .include it.  The KN7000 board's own devices
# (FDC, tone generator ports, SD SPI, LCD controller) are in kn7000_board_io.inc.  Names agree with the
# IC18 boot ROM's (kn7000/tools/check_sfr_names.py, run by `make -C kn7000 symbols-check`).
#
# Evidence, per block:
#  [M]  MN1030/MN103S Series Instruction Manual (Pub.No.13250-040E), 3.4.2 'Interrupt Handlers'
#       example: IAGR 0x34000200, IVAR0..6 0x20000000.., G0ICR 0x34000100, G3ICR 0x3400010C
#       (~/compartilhado/kn7000_scratchpad_snapshot/manual.txt, line ~8325).
#  [L]  the Linux MN10300 port's register headers (arch/mn10300/include/asm/timer-regs.h,
#       serial-regs.h, v4.16): the MN103E010 has the same timer and serial blocks at 0xD4003000 /
#       0xD4002000; every offset the firmware uses (TMnMD +0..3, TMnBR +0x10..13, TMPSCNT +0x71,
#       TM4/5MD +0x80/82, TM6MD +0x84, TMnBR +0x90/92, TM5BC +0xA2, TM6MDA/B +0xB4/B5, TM6CA +0xC4,
#       TM6CB +0xD4; SCn +0x00/04/08/09/0C, n*0x10) is a register there.  [INFERENCE] that the
#       MN103002A has the same layout at 0x34001000 / 0x34000800: no MN103002A LSI manual is at hand.
#  [B]  the IC18 boot ROM's own use (kn7000/src/ic18/boot.s, kn7000/notes/ic18-boot-rom.md).
#  [E]  kn7000_mame's MN10300 core and KN7000 driver (src/devices/cpu/mn10300/mn10300.cpp,
#       src/mame/matsushita/kn7000.cpp), which model these registers for the firmware to boot.

# ---- CPU core (0x20000000) ----------------------------------------------------------- [M][B]
.equ IVAR0, 0x20000000                   # level-0 interrupt entry, low 16 bits
.equ IVAR1, 0x20000004                   # level-1 interrupt entry, low 16 bits
.equ IVAR2, 0x20000008                   # level-2 interrupt entry, low 16 bits
.equ IVAR3, 0x2000000C                   # level-3 interrupt entry, low 16 bits
.equ IVAR4, 0x20000010                   # level-4 interrupt entry, low 16 bits
.equ IVAR5, 0x20000014                   # level-5 interrupt entry, low 16 bits
.equ IVAR6, 0x20000018                   # level-6 interrupt entry, low 16 bits
.equ CPUM, 0x20000040                    # [INFERENCE] CPU mode: bit 3 HALT, bit 4 STOP [B]
.equ CHCTR, 0x20000070                   # cache control: bits 0/1 enable I/D, 4/5 invalidate [B][E]
.equ DCACHE_WAY0, 0x28400000             # reading 0x80 lines of 16 bytes here flushes data-cache way 0 [B][E]
.equ DCACHE_WAY1, 0x28401000             # the other way [B][E]

# ---- bus / memory controller (0x32000000) -------------------------------------------- [B][E]
.equ UNKNOWN_32000010, 0x32000010        # bus controller: 0x400 written first in the bus set-up (IC18 Reset, 941 0x484D710E); not identified without the LSI manual
.equ MEMCTR0, 0x32000020                 # memory controller, chip select 0 timing
.equ MEMCTR1, 0x32000022                 # memory controller, chip select 1 timing
.equ MEMCTR2, 0x32000024                 # memory controller, chip select 2 timing
.equ MEMCTR3, 0x32000026                 # memory controller, chip select 3 timing
.equ MEMCTR4, 0x32000028                 # memory controller, chip select 4 timing
.equ MEMCTR5, 0x3200002A                 # memory controller, chip select 5 timing
.equ MEMCTR6, 0x3200002C                 # memory controller, chip select 6 timing
.equ MEMCTR7, 0x3200002E                 # memory controller, chip select 7 timing
.equ SDRAM_CTRL, 0x32000040              # [INFERENCE] SDRAM control: bit 2 pulsed for the auto-refresh cycles
.equ SDRAM_REFRESH, 0x32000042           # [INFERENCE] SDRAM refresh interval
.equ DMAC0_CTR, 0x32000800               # DMA channel 0: control / start [B][E]
.equ DMAC0_SRC, 0x32000804               # DMA channel 0: source address
.equ DMAC0_DST, 0x32000808               # DMA channel 0: destination address
.equ DMAC0_CNT, 0x3200080C               # DMA channel 0: byte count

# ---- interrupt controller (0x34000100) ----------------------------------------------- [M][B][E]
# GnICR, n = 0..31: group n's interrupt control (enable, level, request/detect bits; writing 1 to a
# detect bit clears it [M]).  G0ICR is the non-maskable group [M].
.equ G0ICR, 0x34000100
.equ G1ICR, 0x34000104
.equ G2ICR, 0x34000108
.equ G3ICR, 0x3400010C
.equ G4ICR, 0x34000110
.equ G5ICR, 0x34000114
.equ G6ICR, 0x34000118
.equ G7ICR, 0x3400011C
.equ G8ICR, 0x34000120
.equ G9ICR, 0x34000124
.equ G10ICR, 0x34000128
.equ G11ICR, 0x3400012C
.equ G12ICR, 0x34000130
.equ G13ICR, 0x34000134
.equ G14ICR, 0x34000138
.equ G15ICR, 0x3400013C
.equ G16ICR, 0x34000140
.equ G17ICR, 0x34000144
.equ G18ICR, 0x34000148
.equ G19ICR, 0x3400014C
.equ G20ICR, 0x34000150
.equ G21ICR, 0x34000154
.equ G22ICR, 0x34000158
.equ G23ICR, 0x3400015C
.equ G24ICR, 0x34000160
.equ G25ICR, 0x34000164
.equ G26ICR, 0x34000168
.equ G27ICR, 0x3400016C
.equ G28ICR, 0x34000170
.equ G29ICR, 0x34000174
.equ G30ICR, 0x34000178
.equ G31ICR, 0x3400017C
.equ IAGR, 0x34000200                    # interrupt accept group: the accepted level's group number [M]; IC18's IrqDispatch reads it as a byte offset into its handler table
.equ EXTMD, 0x34000280                   # external interrupt pin modes, 2 bits per pin [B][E]
.equ UNKNOWN_34004002, 0x34004002        # 0 written right after MEMCTR0 by 941's ResetEntry and IC18's OldReset; not identified without the LSI manual

# ---- serial interfaces (0x34000800) --------------------------------------------------- [L][B][E]
.equ SC0CTR, 0x34000800                  # serial 0: control (16-bit)
.equ SC0ICR, 0x34000804                  # serial 0: interrupt control
.equ SC0TXB, 0x34000808                  # serial 0: transmit buffer
.equ SC0RXB, 0x34000809                  # serial 0: receive buffer
.equ SC0STR, 0x3400080C                  # serial 0: status (16-bit): bit 4 RBF receive buffer full, 5 TBF, 6 RXF, 7 TXF; 0..2 OEF/PEF/FEF [L]
.equ SC1CTR, 0x34000810                  # serial 1: control (16-bit)
.equ SC1ICR, 0x34000814                  # serial 1: interrupt control
.equ SC1TXB, 0x34000818                  # serial 1: transmit buffer
.equ SC1RXB, 0x34000819                  # serial 1: receive buffer
.equ SC1STR, 0x3400081C                  # serial 1: status (16-bit): bit 4 RBF receive buffer full, 5 TBF, 6 RXF, 7 TXF; 0..2 OEF/PEF/FEF [L]
.equ SC2CTR, 0x34000820                  # serial 2: control (16-bit)
.equ SC2ICR, 0x34000824                  # serial 2: interrupt control
.equ SC2TXB, 0x34000828                  # serial 2: transmit buffer
.equ SC2RXB, 0x34000829                  # serial 2: receive buffer
.equ SC2STR, 0x3400082C                  # serial 2: status (16-bit): bit 4 RBF receive buffer full, 5 TBF, 6 RXF, 7 TXF; 0..2 OEF/PEF/FEF [L]

# ---- timers (0x34001000) ------------------------------------------------------------ [L][E]
.equ TM0MD, 0x34001000                   # 8-bit timer 0: mode (bit 7 count enable, bit 6 load counter from TM0BR, bits 0..2 clock source)
.equ TM1MD, 0x34001001                   # 8-bit timer 1: mode (bit 7 count enable, bit 6 load counter from TM1BR, bits 0..2 clock source)
.equ TM2MD, 0x34001002                   # 8-bit timer 2: mode (bit 7 count enable, bit 6 load counter from TM2BR, bits 0..2 clock source)
.equ TM3MD, 0x34001003                   # 8-bit timer 3: mode (bit 7 count enable, bit 6 load counter from TM3BR, bits 0..2 clock source)
.equ TM0BR, 0x34001010                   # 8-bit timer 0: base (reload) value
.equ TM1BR, 0x34001011                   # 8-bit timer 1: base (reload) value
.equ TM2BR, 0x34001012                   # 8-bit timer 2: base (reload) value
.equ TM3BR, 0x34001013                   # 8-bit timer 3: base (reload) value
.equ TM0BC, 0x34001020                   # 8-bit timer 0: binary counter
.equ TM1BC, 0x34001021                   # 8-bit timer 1: binary counter
.equ TM2BC, 0x34001022                   # 8-bit timer 2: binary counter
.equ TM3BC, 0x34001023                   # 8-bit timer 3: binary counter
.equ TMPSCNT, 0x34001071                 # timer prescaler control (bit 7 enable)
.equ TM4MD, 0x34001080                   # 16-bit timer 4: mode
.equ TM5MD, 0x34001082                   # 16-bit timer 5: mode (the KN7000's tempo timer [E])
.equ TM6MD, 0x34001084                   # 16-bit timer 6: mode (16-bit register)
.equ TM4BR, 0x34001090                   # timer 4: base (reload) value
.equ TM5BR, 0x34001092                   # timer 5: base (reload) value
.equ TM4BC, 0x340010A0                   # timer 4: binary counter
.equ TM5BC, 0x340010A2                   # timer 5: binary counter
.equ TM6BC, 0x340010A4                   # timer 6: binary counter
.equ TM6MDA, 0x340010B4                  # timer 6: compare/capture A mode
.equ TM6MDB, 0x340010B5                  # timer 6: compare/capture B mode
.equ TM6CA, 0x340010C4                   # timer 6: compare/capture register A
.equ TM6CB, 0x340010D4                   # timer 6: compare/capture register B

# ---- board I/O latches (chip select at 0x36000000; external to the CPU) ---------------- [B][E]
# The KN7000, KN6000 / KN6500 and KN2400 boards all drive them (kn7000_mame kn7000.cpp models
# 0x36008004 on both boards; notes/io-map.md); every access is bset / bclr / btst or a byte / half
# store.  Named as the IC18 boot ROM names them (P<offset>).
.equ P04, 0x36008004                     # bit 1 the SD card's SPI chip select (low = selected), bit 3 the power latch, bit 4 the FDC's TC (active low), bit 5 toggled every 96 ms by 941's TickJobsTask; bits 0 / 6 panel-link strobes
.equ P05, 0x36008005                     # P04's high byte: bit 0 set by PanelLinkInit
.equ P24, 0x36008024                     # bit 0 a panel-link strobe (with P64 it switches what serial 0 is wired to: kn7000_mame notes/FINDINGS-usb-subsystem.md); bit 4 set by FdcHwInit; bit 6 set by PanelLinkInit
.equ P25, 0x36008025                     # bit 0 a panel-link strobe
.equ P44, 0x36008044                     # bit 0 cleared by PanelLinkInit
.equ P64, 0x36008064                     # bit 0 a panel-link strobe; bit 4 set by FdcHwInit; bit 6 set by PanelLinkInit
.equ P65, 0x36008065                     # bit 0 cleared by PanelLinkInit
.equ P84, 0x36008084                     # input: bit 0 tested by the panel link before it transmits (PanelTxPump, PanelWaitLinkIdle)
