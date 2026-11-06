# The SX-KN7000 board's memory-mapped devices outside the CPU, by name: the floppy controller, the
# tone generator's host ports, the SD card's SPI port and power controller, the board strap and the LCD
# controller.  Hand-written source (lane mn10300-names, 2026-11-02), copied from the IC18 boot ROM's
# own .equ rows (kn7000/tools/gen_ic18_s.py; evidence in kn7000/notes/ic18-boot-rom.md), which name
# them from the boot ROM's use and the 941 program's; kn7000/tools/check_sfr_names.py keeps the two
# in agreement.  Read by gen_program_s.py for the KN7000 program builds only: the siblings' boards are
# not shown to have the same devices at these addresses (the HD-SX3 uses 0x98060010.. for another).

.equ FDC_DACK, 0x98010000                # the controller's DMA data port: reading or writing a byte here answers one DMA request (FdcDreqIsr moves the last byte of a transfer through it)
.equ FDC_DOR, 0x98020004                 # digital output register: 0x1C motor on, 0x0C off
.equ FDC_MSR_DSR, 0x98020008             # main status register when read, data-rate select when written
.equ FDC_FIFO, 0x9802000A                # the command / result / data FIFO
.equ FDC_DIR_CCR, 0x9802000E             # digital input register when read (bit 7 disk changed), configuration control when written
.equ TGA_KEY_FIFO, 0x98050004            # tone generator A's key-event FIFO: program 941 reads it as {key, velocity} words, 0xFFFF when empty (0x484480A2), and its TgChipResetSideA writes 3 three times; SdSpiPortSetup writes 0xFFFF ([INFERENCE] a flush; the second write, on subtype 4, never runs here)
.equ SD_SPI_DATA, 0x9805000C             # the SPI shift register: a byte written goes out, the byte that came in is read back
.equ SD_SPI_CLOCK, 0x9805000E            # the SPI clock-rate latch: rate | 0x80
.equ TGA_INIT, 0x98050010                # [INFERENCE] tone generator A's start-up strobe: program 941's TgChipResetSideA writes 1 three times before it sets the key FIFO; SdSpiPortSetup writes 1 once, this ROM having no tone generator bring-up of its own
.equ SD_POWER_CTRL, 0x98060000           # the sound-control latch IC25 (74AHC174; service manual MAIN 1/5 sheet 2), SdPowerShadow keeps the last byte: bit 0 USB.WAITM, bit 1 SPSW (the headphone / speaker switch), bit 2 SDMODE (to the SD board; read before as the SD card's supply), bits 3 / 4 / 5 the D/A converter IC311's ML / MC / MDI (kn7000/notes/audio-mute-probes/README.md); the name is the earlier reading's
.equ BOARD_STRAP, 0x98070000             # board-revision strap, read only
.equ LCDC, 0x9CC00000                    # the LCD controller's registers
.equ LCDC_MISC, 0x9CC00001
.equ LCDC_GPIO_CONFIG0, 0x9CC00004       # pin directions, 1 = output: bits 6 and 7 the SD lamps
.equ LCDC_GPIO_CONFIG1, 0x9CC00005       # pin directions: bits 1 and 2 the SD slot-enable and supply lines
.equ LCDC_GPIO_CTRL0, 0x9CC00008         # pin data: bit 6 the SD card lamp, bit 7 the SD in-use lamp
.equ LCDC_GPIO_CTRL1, 0x9CC00009         # pin data, the SD slot: bit 0 card sensed, bit 1 slot enable, bit 2 supply line, bit 4 write-protected
.equ LCDC_MEM_CLOCK_CONFIG, 0x9CC00010
.equ LCDC_LCD_PCLK_CONFIG, 0x9CC00014
.equ LCDC_CRT_PCLK_CONFIG, 0x9CC00018
.equ LCDC_MEDIAPLUG_CLOCK_CONFIG, 0x9CC0001C
.equ LCDC_CPU_MEM_WAIT, 0x9CC0001E
.equ LCDC_MEM_CONFIG, 0x9CC00020
.equ LCDC_DRAM_REFRESH, 0x9CC00021
.equ LCDC_DRAM_TIMING0, 0x9CC0002A
.equ LCDC_DRAM_TIMING1, 0x9CC0002B
.equ LCDC_PANEL_TYPE, 0x9CC00030
.equ LCDC_MOD_RATE, 0x9CC00031
.equ LCDC_LCD_HDISP, 0x9CC00032          # (value + 1) x 8 pixels
.equ LCDC_LCD_HNDP, 0x9CC00034
.equ LCDC_TFT_FPLINE_START, 0x9CC00035
.equ LCDC_TFT_FPLINE_WIDTH, 0x9CC00036
.equ LCDC_LCD_VDISP0, 0x9CC00038         # value + 1 lines, low byte
.equ LCDC_LCD_VDISP1, 0x9CC00039
.equ LCDC_LCD_VNDP, 0x9CC0003A
.equ LCDC_TFT_FPFRAME_START, 0x9CC0003B
.equ LCDC_TFT_FPFRAME_WIDTH, 0x9CC0003C
.equ LCDC_LCD_DISPLAY_MODE, 0x9CC00040   # bits 2-0 the pixel depth, 5 = 16 bits
.equ LCDC_LCD_MISC, 0x9CC00041
.equ LCDC_LCD_START0, 0x9CC00042
.equ LCDC_LCD_START1, 0x9CC00043
.equ LCDC_LCD_START2, 0x9CC00044
.equ LCDC_LCD_OFFSET0, 0x9CC00046        # the line pitch in 16-bit words, low byte
.equ LCDC_LCD_OFFSET1, 0x9CC00047
.equ LCDC_LCD_PANNING, 0x9CC00048
.equ LCDC_LCD_FIFO_HIGH, 0x9CC0004A
.equ LCDC_LCD_FIFO_LOW, 0x9CC0004B
.equ LCDC_CRT_HDISP, 0x9CC00050
.equ LCDC_CRT_HNDP, 0x9CC00052
.equ LCDC_CRT_HRTC_START, 0x9CC00053
.equ LCDC_CRT_HRTC_WIDTH, 0x9CC00054
.equ LCDC_CRT_VDISP0, 0x9CC00056
.equ LCDC_CRT_VDISP1, 0x9CC00057
.equ LCDC_CRT_VNDP, 0x9CC00058
.equ LCDC_CRT_VRTC_START, 0x9CC00059
.equ LCDC_CRT_VRTC_WIDTH, 0x9CC0005A
.equ LCDC_TV_OUTPUT_CTRL, 0x9CC0005B
.equ LCDC_CRT_DISPLAY_MODE, 0x9CC00060
.equ LCDC_CRT_START0, 0x9CC00062
.equ LCDC_CRT_START1, 0x9CC00063
.equ LCDC_CRT_START2, 0x9CC00064
.equ LCDC_CRT_OFFSET0, 0x9CC00066
.equ LCDC_CRT_OFFSET1, 0x9CC00067
.equ LCDC_CRT_PANNING, 0x9CC00068
.equ LCDC_CRT_FIFO_HIGH, 0x9CC0006A
.equ LCDC_CRT_FIFO_LOW, 0x9CC0006B
.equ LCDC_LCD_CURSOR_CTRL, 0x9CC00070
.equ LCDC_LCD_CURSOR_START, 0x9CC00071
.equ LCDC_LCD_CURSOR_X0, 0x9CC00072
.equ LCDC_LCD_CURSOR_X1, 0x9CC00073
.equ LCDC_LCD_CURSOR_Y0, 0x9CC00074
.equ LCDC_LCD_CURSOR_Y1, 0x9CC00075
.equ LCDC_LCD_CURSOR_BLUE0, 0x9CC00076
.equ LCDC_LCD_CURSOR_GREEN0, 0x9CC00077
.equ LCDC_LCD_CURSOR_RED0, 0x9CC00078
.equ LCDC_LCD_CURSOR_BLUE1, 0x9CC0007A
.equ LCDC_LCD_CURSOR_GREEN1, 0x9CC0007B
.equ LCDC_LCD_CURSOR_RED1, 0x9CC0007C
.equ LCDC_LCD_CURSOR_FIFO, 0x9CC0007E
.equ LCDC_CRT_CURSOR_CTRL, 0x9CC00080
.equ LCDC_CRT_CURSOR_START, 0x9CC00081
.equ LCDC_CRT_CURSOR_X0, 0x9CC00082
.equ LCDC_CRT_CURSOR_X1, 0x9CC00083
.equ LCDC_CRT_CURSOR_Y0, 0x9CC00084
.equ LCDC_CRT_CURSOR_Y1, 0x9CC00085
.equ LCDC_CRT_CURSOR_BLUE0, 0x9CC00086
.equ LCDC_CRT_CURSOR_GREEN0, 0x9CC00087
.equ LCDC_CRT_CURSOR_RED0, 0x9CC00088
.equ LCDC_CRT_CURSOR_BLUE1, 0x9CC0008A
.equ LCDC_CRT_CURSOR_GREEN1, 0x9CC0008B
.equ LCDC_CRT_CURSOR_RED1, 0x9CC0008C
.equ LCDC_CRT_CURSOR_FIFO, 0x9CC0008E
.equ LCDC_BLT_CTRL0, 0x9CC00100
.equ LCDC_BLT_CTRL1, 0x9CC00101
.equ LCDC_BLT_ROP, 0x9CC00102
.equ LCDC_BLT_OPERATION, 0x9CC00103
.equ LCDC_BLT_SRC0, 0x9CC00104
.equ LCDC_BLT_SRC1, 0x9CC00105
.equ LCDC_BLT_SRC2, 0x9CC00106
.equ LCDC_BLT_DST0, 0x9CC00108
.equ LCDC_BLT_DST1, 0x9CC00109
.equ LCDC_BLT_DST2, 0x9CC0010A
.equ LCDC_BLT_OFFSET0, 0x9CC0010C
.equ LCDC_BLT_OFFSET1, 0x9CC0010D
.equ LCDC_BLT_WIDTH0, 0x9CC00110
.equ LCDC_BLT_WIDTH1, 0x9CC00111
.equ LCDC_BLT_HEIGHT0, 0x9CC00112
.equ LCDC_BLT_HEIGHT1, 0x9CC00113
.equ LCDC_BLT_BG0, 0x9CC00114
.equ LCDC_BLT_BG1, 0x9CC00115
.equ LCDC_BLT_FG0, 0x9CC00118
.equ LCDC_BLT_FG1, 0x9CC00119
.equ LCDC_LUT_MODE, 0x9CC001E0
.equ LCDC_LUT_ADDR, 0x9CC001E2
.equ LCDC_LUT_DATA, 0x9CC001E4
.equ LCDC_POWER_SAVE_CONFIG, 0x9CC001F0
.equ LCDC_WATCHDOG, 0x9CC001F4
.equ LCDC_DISPLAY_MODE, 0x9CC001FC       # LcdControllerInit writes 0 before the set-up, 7 after it
.equ LCDC_VRAM, 0x9CE00000               # the LCD controller's display memory (its registers + 0x200000)
