
; ==============================================================================
; 0xF8E800-0xF8E9A4 -- the LCD controller: entry thunks and the power-on setup
; ==============================================================================
;
; ★ THE CONTROLLER IS AN SED1330-FAMILY LCD CONTROLLER, and this is citable
;   rather than guessed.  Two independent checks:
;
;   1. COMMAND SET.  Every command byte this firmware ever writes to 0x790001 is
;      in MAME's SED1330 instruction table (src/devices/video/sed1330.cpp:23-39),
;      and no byte outside that table is ever written:
;        0x40 SYSTEM SET   0x42 MWRITE   0x43 MREAD   0x44 SCROLL
;        0x46 CSRW         0x47 CSRR     0x4C CSRDIR RIGHT
;        0x58 DISP OFF     0x59 DISP ON  0x5A HDOT SCR
;        0x5B OVLAY        0x5D CSRFORM
;      (a byte census of prom_a and prom_b finds exactly these and nothing else).
;
;   2. PORT SHAPE.  MAME's own drivers wire this part up as
;        even address: read = status_r, write = data_w
;        odd  address: read = data_r,   write = command_w
;      (mame/skeleton/textelcomp.cpp:147-148, and the commented-out map in
;      mame/epson/px8.cpp:534-535).  That is exactly how this firmware uses
;      0x790000/0x790001, including the busy poll: `bit 6,(0x790000)`, and
;      sed1330_device::status_r returns `m_bf << 6` (sed1330.cpp:245-251).
;
;   The parameter bytes below then decode into a consistent panel, which is the
;   third check: 320 x 240 pixels, 40 bytes per line, three graphics layers
;   OR-composited, at display-RAM 0x0000 / 0x2600 / 0x4C00.
;
;   ⚠ What is NOT established: the exact part number.  SED1330, SED1335,
;   S1D13305 and the second-source clones share this command set, and nothing
;   in the firmware distinguishes them.  Say "SED1330-family", not "SED1330".
;
; RAM the driver keeps alongside the controller (all CS1 static RAM):
;   (0x2541) (0x2543) (0x2545)  the three layer base addresses, as sent to SCROLL
;   (0x2554)  the OVLAY byte             (0x2557)/(0x2558)  AP = bytes per line
;   (0x2559)  the last DISP ON/OFF byte  (0x255A)  the last cursor address
;   (0xC6) bit 0  "do not wait for BUSY" -- set when the display is turned off
;
.equ LCDC_DATA, 0x790000	; write = data.  read = status, bit 6 = busy
.equ LCDC_CMD,  0x790001	; write = command.  read = data

; ---------------------------------------------------------------------
; LCD_EntryThunks -- six `jp` slots, the module's public entry points
;
; Called from: not yet traced (the callers are in prom_b)
; Inputs:  none
; Outputs: none
; Evidence: all six slots are `jp nnn` and are emitted as symbols, so the byte
;          gate checks each target; notes/prom_a_byte_checks.py additionally
;          re-reads the six targets and the fact that the four "unused" ones
;          point at 0xF8E818, whose body is the single byte 0x0E = RET.
;          ⚠ "the module's public entry points" is the SHAPE (a jump table at a
;          fixed address at the start of the module), not a citation -- the
;          callers are in prom_b and have not been traced.
; Notes:   four of the six are `jp 0xF8E818`, i.e. a bare RET, so only two of
;          the six services exist: slot 0 is the power-on setup and slot 2 is
;          the (0x97) bit-4 test at 0xF8E99F.  A table of `jp`s rather than of
;          pointers is the usual way a fixed entry-point ABI is kept stable
;          across firmware revisions.
; ---------------------------------------------------------------------
LCD_EntryThunks:
	jp LCD_Init_SED1330                           ; F8E800  1b 19 e8 f8
	jp LCD_Thunk_Unused                           ; F8E804  1b 18 e8 f8
	jp LCD_Thunk2_Test97b4                        ; F8E808  1b 9f e9 f8
	jp LCD_Thunk_Unused                           ; F8E80C  1b 18 e8 f8
	jp LCD_Thunk_Unused                           ; F8E810  1b 18 e8 f8
	jp LCD_Thunk_Unused                           ; F8E814  1b 18 e8 f8
LCD_Thunk_Unused:
	ret                                           ; F8E818  0e

; ---------------------------------------------------------------------
; LCD_Init_SED1330 -- power-on setup of the LCD controller, then clear the screen
;
; Called from: LCD_EntryThunks slot 0 (0xF8E800)
; Inputs:  none
; Outputs: the controller fully programmed and every one of its 32768 display
;          bytes zeroed, display then enabled.  (0x2541)-(0x2559) hold copies of
;          the values sent.  XIY, WA and BC are clobbered.
; Evidence: the controller FAMILY is established for the whole block by the
;          banner above -- every command byte written to 0x790001 is in MAME's
;          SED1330 table and no byte outside it is ever written
;          (notes/lcd_command_census.py). "Power-on setup" is this routine's
;          own content: it is slot 0 of the entry table, opens `ld
;          XIY,0x00790000` + SYSTEM SET (0xF8E819, 0xF8E81E), and ends by
;          clearing all 32768 display bytes -- notes/prom_a_byte_checks.py
;          checks that arithmetic ("setup: 0x0800 * 16 = 32768 = the whole
;          display RAM") and this routine's length ("svc 0x10 is 308 bytes and
;          LCD_Init_SED1330 is 390").
; Notes:   this routine never reads the BUSY flag.  It separates accesses with
;          runs of four NOPs instead -- a fixed delay, which is the usual way to
;          drive this part before the display is on and the busy flag means
;          anything.  Every one of those NOPs is a real instruction in the ROM,
;          which is why they are written out rather than folded into a .fill.
; ---------------------------------------------------------------------
LCD_Init_SED1330:
	ld XIY,0x00790000                             ; F8E819  45 00 00 79 00   XIY = the controller's two ports
	ld (XIY+0x01),0x40                            ; F8E81E  bd 01 00 40   SYSTEM SET
	nop                                           ; F8E822  00
	nop                                           ; F8E823  00
	nop                                           ; F8E824  00
	nop                                           ; F8E825  00
	ld (XIY),0x30                                 ; F8E826  b5 00 30   SYSTEM SET arg 1 = 0x30: internal CG ROM, 8-line chars, single-panel drive
	nop                                           ; F8E829  00
	nop                                           ; F8E82A  00
	nop                                           ; F8E82B  00
	nop                                           ; F8E82C  00
	ld (XIY),0x07                                 ; F8E82D  b5 00 07   SYSTEM SET arg 2, FX  = 7  -> 8 pixels per character cell
	nop                                           ; F8E830  00
	nop                                           ; F8E831  00
	nop                                           ; F8E832  00
	nop                                           ; F8E833  00
	ld (XIY),0x00                                 ; F8E834  b5 00 00   SYSTEM SET arg 3, FY  = 0  -> 1 line per cell (this is a graphics-only panel)
	nop                                           ; F8E837  00
	nop                                           ; F8E838  00
	nop                                           ; F8E839  00
	nop                                           ; F8E83A  00
	ld (XIY),0x27                                 ; F8E83B  b5 00 27   SYSTEM SET arg 4, C/R = 39 -> 40 bytes displayed per line = 320 pixels
	nop                                           ; F8E83E  00
	nop                                           ; F8E83F  00
	nop                                           ; F8E840  00
	nop                                           ; F8E841  00
	ld (XIY),0x35                                 ; F8E842  b5 00 35   SYSTEM SET arg 5, TC/R= 53 -> 54 byte-times per line total
	nop                                           ; F8E845  00
	nop                                           ; F8E846  00
	nop                                           ; F8E847  00
	nop                                           ; F8E848  00
	ld (XIY),0xef                                 ; F8E849  b5 00 ef   SYSTEM SET arg 6, L/F = 239 -> 240 lines
	nop                                           ; F8E84C  00
	nop                                           ; F8E84D  00
	nop                                           ; F8E84E  00
	nop                                           ; F8E84F  00
	ld a, 0x28:opc                                   ; F8E850  21 28   SYSTEM SET arg 7, APL = 0x28 -- virtual screen width, low byte
	ld (XIY),A                                    ; F8E852  b5 41
	ld (LCD_BytesPerLine:16), a                            ; F8E854  f1 57 25 41
	nop                                           ; F8E858  00
	nop                                           ; F8E859  00
	nop                                           ; F8E85A  00
	ld a, 0x00:opc                                   ; F8E85B  21 00   SYSTEM SET arg 8, APH = 0x00 -> AP = 40 bytes per line
	ld (XIY),A                                    ; F8E85D  b5 41
	ld (LCD_BytesPerLine_Hi:16), a                            ; F8E85F  f1 58 25 41
	nop                                           ; F8E863  00
	nop                                           ; F8E864  00
	nop                                           ; F8E865  00
	ld (XIY+0x01),0x44                            ; F8E866  bd 01 00 44   SCROLL
	nop                                           ; F8E86A  00
	nop                                           ; F8E86B  00
	nop                                           ; F8E86C  00
	nop                                           ; F8E86D  00
	ld (XIY),0x00                                 ; F8E86E  b5 00 00   SAD1 low
	nop                                           ; F8E871  00
	nop                                           ; F8E872  00
	nop                                           ; F8E873  00
	nop                                           ; F8E874  00
	ld (XIY),0x00                                 ; F8E875  b5 00 00   SAD1 high: display block 1 base = 0x0000 = firmware LAYER 0
	nop                                           ; F8E878  00
	nop                                           ; F8E879  00
	nop                                           ; F8E87A  00
	nop                                           ; F8E87B  00
	ld (XIY),0xf0                                 ; F8E87C  b5 00 f0   SL1  = 240 lines
	nop                                           ; F8E87F  00
	nop                                           ; F8E880  00
	nop                                           ; F8E881  00
	nop                                           ; F8E882  00
	ld (XIY),0x00                                 ; F8E883  b5 00 00   SAD2 low
	nop                                           ; F8E886  00
	nop                                           ; F8E887  00
	nop                                           ; F8E888  00
	nop                                           ; F8E889  00
	ld (XIY),0x26                                 ; F8E88A  b5 00 26   SAD2 high: display block 2 base = 0x2600 = firmware LAYER 1
	nop                                           ; F8E88D  00
	nop                                           ; F8E88E  00
	nop                                           ; F8E88F  00
	nop                                           ; F8E890  00
	ld (XIY),0xf0                                 ; F8E891  b5 00 f0   SL2  = 240 lines
	nop                                           ; F8E894  00
	nop                                           ; F8E895  00
	nop                                           ; F8E896  00
	nop                                           ; F8E897  00
	ld (XIY),0x00                                 ; F8E898  b5 00 00   SAD3 low
	nop                                           ; F8E89B  00
	nop                                           ; F8E89C  00
	nop                                           ; F8E89D  00
	nop                                           ; F8E89E  00
	ld (XIY),0x4c                                 ; F8E89F  b5 00 4c   SAD3 high: display block 3 base = 0x4C00 = firmware LAYER 2.  SAD4 is not sent
	ld a, 0x00:opc                                   ; F8E8A2  21 00
	ld w, 0x00:opc                                   ; F8E8A4  20 00
	ld (LCD_Layer0_SAD:16), wa                           ; F8E8A6  f1 41 25 50
	ld a, 0x00:opc                                   ; F8E8AA  21 00
	ld w, 0x26:opc                                   ; F8E8AC  20 26
	ld (LCD_Layer1_SAD:16), wa                           ; F8E8AE  f1 43 25 50
	ld a, 0x00:opc                                   ; F8E8B2  21 00
	ld w, 0x4c:opc                                   ; F8E8B4  20 4c
	ld (LCD_Layer2_SAD:16), wa                           ; F8E8B6  f1 45 25 50
	ld (XIY+0x01),0x5a                            ; F8E8BA  bd 01 00 5a   HDOT SCR
	nop                                           ; F8E8BE  00
	nop                                           ; F8E8BF  00
	nop                                           ; F8E8C0  00
	nop                                           ; F8E8C1  00
	ld (XIY),0x00                                 ; F8E8C2  b5 00 00   0 -- no horizontal dot scroll
	nop                                           ; F8E8C5  00
	nop                                           ; F8E8C6  00
	nop                                           ; F8E8C7  00
	nop                                           ; F8E8C8  00
	ld (XIY+0x01),0x5b                            ; F8E8C9  bd 01 00 5b   OVLAY
	nop                                           ; F8E8CD  00
	nop                                           ; F8E8CE  00
	nop                                           ; F8E8CF  00
	nop                                           ; F8E8D0  00
	ld (XIY),0x1c                                 ; F8E8D1  b5 00 1c   0x1C: MX=0 (OR), layers 1 and 3 in GRAPHICS mode, 3 layers
	ld (LCD_OvlayShadow:16), 0x1c                          ; F8E8D4  f1 54 25 00 1c
	nop                                           ; F8E8D9  00
	nop                                           ; F8E8DA  00
	nop                                           ; F8E8DB  00
	nop                                           ; F8E8DC  00
	nop                                           ; F8E8DD  00
	ld (XIY+0x01),0x5d                            ; F8E8DE  bd 01 00 5d   CSRFORM
	nop                                           ; F8E8E2  00
	nop                                           ; F8E8E3  00
	nop                                           ; F8E8E4  00
	nop                                           ; F8E8E5  00
	nop                                           ; F8E8E6  00
	ld (XIY),0x07                                 ; F8E8E7  b5 00 07   cursor width
	nop                                           ; F8E8EA  00
	nop                                           ; F8E8EB  00
	nop                                           ; F8E8EC  00
	nop                                           ; F8E8ED  00
	nop                                           ; F8E8EE  00
	ld (XIY),0x87                                 ; F8E8EF  b5 00 87   cursor height / block cursor
	nop                                           ; F8E8F2  00
	nop                                           ; F8E8F3  00
	nop                                           ; F8E8F4  00
	nop                                           ; F8E8F5  00
	ld (XIY+0x01),0x58                            ; F8E8F6  bd 01 00 58   DISP OFF -- draw the screen blank before it is shown
	nop                                           ; F8E8FA  00
	nop                                           ; F8E8FB  00
	nop                                           ; F8E8FC  00
	nop                                           ; F8E8FD  00
	ld (XIY),0x54                                 ; F8E8FE  b5 00 54   0x54: cursor off, all three layers on, none flashing
	ld a, 0x54:opc                                   ; F8E901  21 54
	ld (LCD_DispOnOffShadow:16), a                            ; F8E903  f1 59 25 41
	nop                                           ; F8E907  00
	nop                                           ; F8E908  00
	nop                                           ; F8E909  00
	nop                                           ; F8E90A  00
	ld (XIY+0x01),0x4c                            ; F8E90B  bd 01 00 4c   CSRDIR RIGHT -- the cursor auto-increments after every MWRITE
	nop                                           ; F8E90F  00
	nop                                           ; F8E910  00
	nop                                           ; F8E911  00
	nop                                           ; F8E912  00
	nop                                           ; F8E913  00
	nop                                           ; F8E914  00
	ld (XIY+0x01),0x46                            ; F8E915  bd 01 00 46   CSRW -- set the cursor (= the memory pointer)
	nop                                           ; F8E919  00
	nop                                           ; F8E91A  00
	nop                                           ; F8E91B  00
	nop                                           ; F8E91C  00
	xor WA,WA                                     ; F8E91D  d8 d0
	ld (XIY),A                                    ; F8E91F  b5 41
	nop                                           ; F8E921  00
	nop                                           ; F8E922  00
	nop                                           ; F8E923  00
	nop                                           ; F8E924  00
	ld (XIY),A                                    ; F8E925  b5 41
	nop                                           ; F8E927  00
	nop                                           ; F8E928  00
	nop                                           ; F8E929  00
	nop                                           ; F8E92A  00
	ld (XIY+0x01),0x42                            ; F8E92B  bd 01 00 42   MWRITE -- and now 0x800 x 16 = 32768 zero bytes follow
	ldw bc, 0x0800                                ; F8E92F  31 00 08   0x800 iterations of a 16-store unrolled loop
	ld a, 0x00:opc                                   ; F8E932  21 00
LCD_Init__clear_loop:
	nop                                           ; F8E934  00
	nop                                           ; F8E935  00
	nop                                           ; F8E936  00
	ld (XIY),A                                    ; F8E937  b5 41
	nop                                           ; F8E939  00
	nop                                           ; F8E93A  00
	nop                                           ; F8E93B  00
	nop                                           ; F8E93C  00
	ld (XIY),A                                    ; F8E93D  b5 41
	nop                                           ; F8E93F  00
	nop                                           ; F8E940  00
	nop                                           ; F8E941  00
	nop                                           ; F8E942  00
	ld (XIY),A                                    ; F8E943  b5 41
	nop                                           ; F8E945  00
	nop                                           ; F8E946  00
	nop                                           ; F8E947  00
	nop                                           ; F8E948  00
	ld (XIY),A                                    ; F8E949  b5 41
	nop                                           ; F8E94B  00
	nop                                           ; F8E94C  00
	nop                                           ; F8E94D  00
	nop                                           ; F8E94E  00
	ld (XIY),A                                    ; F8E94F  b5 41
	nop                                           ; F8E951  00
	nop                                           ; F8E952  00
	nop                                           ; F8E953  00
	nop                                           ; F8E954  00
	ld (XIY),A                                    ; F8E955  b5 41
	nop                                           ; F8E957  00
	nop                                           ; F8E958  00
	nop                                           ; F8E959  00
	nop                                           ; F8E95A  00
	ld (XIY),A                                    ; F8E95B  b5 41
	nop                                           ; F8E95D  00
	nop                                           ; F8E95E  00
	nop                                           ; F8E95F  00
	nop                                           ; F8E960  00
	ld (XIY),A                                    ; F8E961  b5 41
	nop                                           ; F8E963  00
	nop                                           ; F8E964  00
	nop                                           ; F8E965  00
	nop                                           ; F8E966  00
	ld (XIY),A                                    ; F8E967  b5 41
	nop                                           ; F8E969  00
	nop                                           ; F8E96A  00
	nop                                           ; F8E96B  00
	nop                                           ; F8E96C  00
	ld (XIY),A                                    ; F8E96D  b5 41
	nop                                           ; F8E96F  00
	nop                                           ; F8E970  00
	nop                                           ; F8E971  00
	nop                                           ; F8E972  00
	ld (XIY),A                                    ; F8E973  b5 41
	nop                                           ; F8E975  00
	nop                                           ; F8E976  00
	nop                                           ; F8E977  00
	nop                                           ; F8E978  00
	ld (XIY),A                                    ; F8E979  b5 41
	nop                                           ; F8E97B  00
	nop                                           ; F8E97C  00
	nop                                           ; F8E97D  00
	nop                                           ; F8E97E  00
	ld (XIY),A                                    ; F8E97F  b5 41
	nop                                           ; F8E981  00
	nop                                           ; F8E982  00
	nop                                           ; F8E983  00
	nop                                           ; F8E984  00
	ld (XIY),A                                    ; F8E985  b5 41
	nop                                           ; F8E987  00
	nop                                           ; F8E988  00
	nop                                           ; F8E989  00
	nop                                           ; F8E98A  00
	ld (XIY),A                                    ; F8E98B  b5 41
	nop                                           ; F8E98D  00
	nop                                           ; F8E98E  00
	nop                                           ; F8E98F  00
	nop                                           ; F8E990  00
	ld (XIY),A                                    ; F8E991  b5 41
	djnz16 bc, LCD_Init__clear_loop                           ; F8E993  d9 1c 9e
	nop                                           ; F8E996  00
	nop                                           ; F8E997  00
	nop                                           ; F8E998  00
	nop                                           ; F8E999  00
	ld (XIY+0x01),0x59                            ; F8E99A  bd 01 00 59   DISP ON, with no parameter byte: keeps the 0x54 above
	ret                                           ; F8E99E  0e

; ---------------------------------------------------------------------
; LCD_Thunk2_Test97b4 -- what LCD_EntryThunks slot 2 reaches
;
; Called from: LCD_EntryThunks slot 2 (0xF8E808)
; Inputs:  bit 4 of (0x97)
; Outputs: NONE.  Both arms of the branch land on the same RET, so this routine
;          has no effect at all; it only leaves the Z flag set from the bit test.
; Evidence: the whole routine is three instructions -- `bit 4,(0x97)` at
;          0xF8E99F, `jr nz,0xF8E9A4`, and `ret` at 0xF8E9A4 -- and the branch
;          target IS the fall-through, so the name states exactly what the
;          code does and nothing more. Its only caller is slot 2 of
;          LCD_EntryThunks, which is emitted as a symbol and re-read from the
;          ROM by notes/prom_a_byte_checks.py.
; Notes:   named for what it tests, because what the caller does with the flag
;          has not been traced.  A conditional jump whose two arms coincide is
;          usually a compiler artefact of an `if` whose body was optimised away.
; ---------------------------------------------------------------------
LCD_Thunk2_Test97b4:
	bit	4, (0x97:8)                            ; F8E99F  f0 97 cc
	jr nz, .LF8E9A4                               ; F8E9A2  6e 00
.LF8E9A4:
	ret                                           ; F8E9A4  0e

; ==============================================================================
; 0xF8E9A5-0xF8EAC6 -- SWI7: the service-call gateway and its 64-slot table
; ==============================================================================

; ---------------------------------------------------------------------
; SWI7_ServiceCall_Dispatch -- `swi 7` is this firmware's system call
;
; Called from: vector slot 0x1C (0xFFFF1C holds 0x00F400A4, a prom_b thunk whose
;          body is `jp 0xF8E9A5`).  Every `swi 7` in either ROM lands here.
; Inputs:  A = service number.  Only A & 0x3F is used, so the number space is
;          exactly 64 wide -- which is also exactly the size of the table below,
;          and that agreement is what proves the table's length.
;          Every other register is passed straight through to the service; C is
;          the usual argument (LCD_Svc_0C_SetLayersOn reads C bits 0-2).
; Outputs: whatever the service returns.  HL is preserved across the dispatch
;          itself (pushed, restored before the call).
; Evidence: `and A,0x3f` at 0xF8E9AF is the whole argument for "64 services" --
;          six bits of A -- and `sla hl,0x02` at 0xF8E9B4 scales by 4 before
;          0xF8E9B7 loads the table base 0xF8E9C6. 64 x 4 = 256 bytes is
;          exactly the table's extent. What makes it a SERVICE CALL rather
;          than a jump table is `call (XWA)` at 0xF8E9C2 with the caller's own
;          registers still live, and the `pop SR / ret` pair at 0xF8E9C4
;          discarding the SR the SWI pushed.
; Notes:   it writes 0 to control register 0x3C before re-enabling interrupts.
;          That register is the kernel's CRITICAL-SECTION DEPTH (see the kernel
;          block at 0xF856EC): IRQ_Epilogue reschedules only when it reads 1, and
;          Kernel_ServiceSoftTimers brackets its callbacks with depth++/depth--.
;          Zeroing it here means a service call can never itself cause a task
;          switch on the way out.
;          ⚠ unidasm prints control-register numbers as "unknown"; MAME does not
;          name the TLCS-900 control registers and no databook is in these
;          trees, so 0x3C stays a number here.
;
;          The final `pop SR` / `ret` pair is how a TLCS-900 SWI returns without
;          RETI: the SWI pushed SR, the service returned normally, and this
;          discards the saved SR before returning to the instruction after the
;          `swi`.
; ---------------------------------------------------------------------
SWI7_ServiceCall_Dispatch:
	pushw hl                                      ; F8E9A5  2b
	xor HL,HL                                     ; F8E9A6  db d3
	ldc_cr16	hl, 0x3c                      ; F8E9A8  db 2e 3c   control register 0x3C := 0 -- see the kernel at 0xF856EC
	ei 0x00                                       ; F8E9AB  06 00
	xor H,H                                       ; F8E9AD  ce d6
	and A,0x3f                                    ; F8E9AF  c9 cc 3f   only 6 bits of A select the service
	ld L,A                                        ; F8E9B2  c9 8f
	sla hl, 0x02                                  ; F8E9B4  db ec 02   index * 4
	ld XWA,SWI7_ServiceTable                      ; F8E9B7  40 c6 e9 f8 00   the table below
	ld	xwa, (xwa+hl)                         ; F8E9BC  e3 07 e0 ec 20   fetch the entry
	popw hl                                       ; F8E9C1  4b
	call (xwa)                                    ; F8E9C2  b0 e8   call it with the caller's own registers still live
	pop SR                                        ; F8E9C4  03   pop the SR the SWI pushed, then RET past it
	ret                                           ; F8E9C5  0e

; ---------------------------------------------------------------------
; SWI7_ServiceTable -- 64 x LE32, the service numbers
;
; Read by:  SWI7_ServiceCall_Dispatch (0xF8E9B7), indexed by (A & 0x3F) * 4.
; Evidence: the counts are a script's output, not a reader's -- `python3
;          notes/swi7_service_table.py` reads all 64 slots out of the ROM and
;          prints 34 live / 30 dead / 34 distinct, checks every live target
;          lands inside prom_a, and checks that the byte after slot 0x3F is
;          the 0x0E RET the dead slots point at. The 64 itself comes from the
;          dispatcher's `and A,0x3f` (0xF8E9AF), so the table's length and the
;          service-number space are one fact, not two. Every converted slot is
;          emitted as a SYMBOL, so the byte gate checks its address.
; Layout:   64 entries, 256 bytes, 0xF8E9C6-0xF8EAC5.  34 of them are LIVE and
;           they name 34 DISTINCT routines; the other 30 -- slot 0x18 and every
;           slot from 0x23 up -- point at the bare RET that follows the table,
;           which is what makes the used range 0x00-0x22.
;           ⚠ CORRECTED 2026-08-24: this header said 35 live and 29 dead, and
;           notes/FINDINGS-display-controller.md said 35 too.  Both were counted
;           by hand and both were wrong.  Regenerate the numbers with
;           `python3 notes/swi7_service_table.py` (`--slots` for every slot);
;           it also checks that all 34 targets land inside prom_a and that the
;           byte after slot 0x3F is the 0x0E RET the dead slots point at.
; Notes:    every implemented service is in prom_a between 0xF8EAC7 and 0xF908FF
;           (the script prints that range) and every
;           one of them talks to the LCD controller at 0x790000/0x790001 --
;           directly, or through the shared setup at 0xF8EE93 that most of them
;           open with.  So SWI7 is, in this firmware, the GRAPHICS API.
;           ★ ALL 34 live services are converted and named as of 2026-08-25, and
;           every one of their entries below is a real SYMBOL, so the byte gate
;           checks the address of each.
;           ⚠ CORRECTED 2026-08-25 (round-2 audit F10): the sentence above was
;           written while ELEVEN slots -- 0x0E 0x0F 0x10 0x11 0x12 0x14 0x15
;           0x17 0x1B 0x1C 0x1E -- were still spelled `.long <address>` with a
;           stale one-line note beside them ("svc 0x17 -- BC = count, WA = 8",
;           written before 0xF90118 was converted into
;           LCD_Svc_17_DrawText8x8Packed).  A reader auditing the table from
;           here could not reach the routines.  All eleven now carry their
;           symbol, and the byte gate checks all thirty-four addresses.  Do not retype the list: `python3
;           notes/swi7_service_table.py` prints it, and prints anything still
;           `.incbin` -- as of 2026-08-25 that list is EMPTY.
;           ⚠ CORRECTED 2026-08-25: this paragraph said "23 of the 34 ... as of
;           2026-08-24" and named eleven slots as still `.incbin`.  The eleven
;           (0x0E 0x0F 0x10 0x11 0x12 0x14 0x15 0x17 0x1B 0x1C 0x1E) were
;           converted in the round that landed 0xF8F850-0xF90988, and this text
;           was not updated with them.  The script was right; the header rotted.
;           ★ TEN of the live slots -- 0x06 0x07 0x08 0x16 0x19 0x1A 0x1D 0x1F
;           0x20 0x21 -- are the TEXT services, one per font.  See the block
;           header at 0xF8F039 and notes/FINDINGS-fonts.md.
; ---------------------------------------------------------------------
SWI7_ServiceTable:
	.long LCD_Svc_00_DrawLine		; F8E9C6  c7 ea f8 00   svc 0x00
	.long LCD_Svc_01_DrawHLine		; F8E9CA  28 f5 f8 00   svc 0x01
	.long LCD_Svc_02_DrawVLine		; F8E9CE  39 f7 f8 00   svc 0x02
	.long LCD_Svc_03_BlitColumns	; F8E9D2  b4 ed f8 00   svc 0x03
	.long LCD_Svc_04_ReadColumns	; F8E9D6  23 ee f8 00   svc 0x04
	.long LCD_Svc_05_FillRect		; F8E9DA  bd ee f8 00   svc 0x05
	.long LCD_Svc_06_DrawText8x14	; F8E9DE  39 f0 f8 00   svc 0x06
	.long LCD_Svc_07_DrawText8x16	; F8E9E2  30 f1 f8 00   svc 0x07
	.long LCD_Svc_08_DrawText16x16	; F8E9E6  c3 f1 f8 00   svc 0x08
	.long LCD_Svc_09_DrawBox		; F8E9EA  a4 f3 f8 00   svc 0x09
	.long LCD_Svc_0A_DrawBoxShadow2	; F8E9EE  e1 f3 f8 00   svc 0x0A
	.long LCD_Svc_0B_PlotPoint	; F8E9F2  b5 ec f8 00   svc 0x0B
	.long LCD_Svc_0C_SetLayersOn	; F8E9F6  b8 f7 f8 00   svc 0x0C
	.long LCD_Svc_0D_SetLayersFlashing	; F8E9FA  01 f8 f8 00   svc 0x0D
	.long LCD_Svc_0E_ClearColumns	; F8E9FE  50 f8 f8 00   svc 0x0E
	.long LCD_Svc_0F_SetPanel2Layer	; F8EA02  60 fa f8 00   svc 0x0F
	.long LCD_Svc_10_SetPanel3Layer	; F8EA06  7e fb f8 00   svc 0x10
	.long LCD_Svc_11_DrawHLineDither	; F8EA0A  b2 fc f8 00   svc 0x11
	.long LCD_Svc_12_DrawVLineDashed	; F8EA0E  80 fe f8 00   svc 0x12
	.long LCD_Svc_13_DrawBoxPatterned	; F8EA12  75 f4 f8 00   svc 0x13
	.long LCD_Svc_14_FillRectPattern	; F8EA16  bc fe f8 00   svc 0x14
	.long LCD_Svc_15_DrawLineDashed	; F8EA1A  b0 00 f9 00   svc 0x15
	.long LCD_Svc_16_DrawKatakanaHalfWidth	; F8EA1E  a3 f0 f8 00   svc 0x16
	.long LCD_Svc_17_DrawText8x8Packed	; F8EA22  18 01 f9 00   svc 0x17
	.long LCD_Svc_Unimplemented		; F8EA26  c6 ea f8 00   svc 0x18
	.long LCD_Svc_19_DrawKatakana16x16	; F8EA2A  8d f2 f8 00   svc 0x19
	.long LCD_Svc_1A_DrawKanjiSetA16x16	; F8EA2E  29 f2 f8 00   svc 0x1A
	.long LCD_Svc_1B_EraseRect	; F8EA32  bd f8 f8 00   svc 0x1B
	.long LCD_Svc_1C_DrawText16x16Packed	; F8EA36  5e 02 f9 00   svc 0x1C
	.long LCD_Svc_1D_DrawHiragana16x16	; F8EA3A  bf f2 f8 00   svc 0x1D
	.long LCD_Svc_1E_ScrollCurrentLayer	; F8EA3E  ff 08 f9 00   svc 0x1E
	.long LCD_Svc_1F_DrawKanjiSetB16x16	; F8EA42  5b f2 f8 00   svc 0x1F
	.long LCD_Svc_20_DrawText8x10	; F8EA46  6e f0 f8 00   svc 0x20
	.long LCD_Svc_21_DrawText16x24	; F8EA4A  f7 f1 f8 00   svc 0x21
	.long LCD_Svc_22_DrawBoxShadow1	; F8EA4E  b2 f4 f8 00   svc 0x22
	.long LCD_Svc_Unimplemented		; F8EA52  c6 ea f8 00   svc 0x23
	.long LCD_Svc_Unimplemented		; F8EA56  c6 ea f8 00   svc 0x24
	.long LCD_Svc_Unimplemented		; F8EA5A  c6 ea f8 00   svc 0x25
	.long LCD_Svc_Unimplemented		; F8EA5E  c6 ea f8 00   svc 0x26
	.long LCD_Svc_Unimplemented		; F8EA62  c6 ea f8 00   svc 0x27
	.long LCD_Svc_Unimplemented		; F8EA66  c6 ea f8 00   svc 0x28
	.long LCD_Svc_Unimplemented		; F8EA6A  c6 ea f8 00   svc 0x29
	.long LCD_Svc_Unimplemented		; F8EA6E  c6 ea f8 00   svc 0x2A
	.long LCD_Svc_Unimplemented		; F8EA72  c6 ea f8 00   svc 0x2B
	.long LCD_Svc_Unimplemented		; F8EA76  c6 ea f8 00   svc 0x2C
	.long LCD_Svc_Unimplemented		; F8EA7A  c6 ea f8 00   svc 0x2D
	.long LCD_Svc_Unimplemented		; F8EA7E  c6 ea f8 00   svc 0x2E
	.long LCD_Svc_Unimplemented		; F8EA82  c6 ea f8 00   svc 0x2F
	.long LCD_Svc_Unimplemented		; F8EA86  c6 ea f8 00   svc 0x30
	.long LCD_Svc_Unimplemented		; F8EA8A  c6 ea f8 00   svc 0x31
	.long LCD_Svc_Unimplemented		; F8EA8E  c6 ea f8 00   svc 0x32
	.long LCD_Svc_Unimplemented		; F8EA92  c6 ea f8 00   svc 0x33
	.long LCD_Svc_Unimplemented		; F8EA96  c6 ea f8 00   svc 0x34
	.long LCD_Svc_Unimplemented		; F8EA9A  c6 ea f8 00   svc 0x35
	.long LCD_Svc_Unimplemented		; F8EA9E  c6 ea f8 00   svc 0x36
	.long LCD_Svc_Unimplemented		; F8EAA2  c6 ea f8 00   svc 0x37
	.long LCD_Svc_Unimplemented		; F8EAA6  c6 ea f8 00   svc 0x38
	.long LCD_Svc_Unimplemented		; F8EAAA  c6 ea f8 00   svc 0x39
	.long LCD_Svc_Unimplemented		; F8EAAE  c6 ea f8 00   svc 0x3A
	.long LCD_Svc_Unimplemented		; F8EAB2  c6 ea f8 00   svc 0x3B
	.long LCD_Svc_Unimplemented		; F8EAB6  c6 ea f8 00   svc 0x3C
	.long LCD_Svc_Unimplemented		; F8EABA  c6 ea f8 00   svc 0x3D
	.long LCD_Svc_Unimplemented		; F8EABE  c6 ea f8 00   svc 0x3E
	.long LCD_Svc_Unimplemented		; F8EAC2  c6 ea f8 00   svc 0x3F

; ---------------------------------------------------------------------
; LCD_Svc_Unimplemented -- the do-nothing service
;
; Called from: SWI7_ServiceTable slots 0x18 and 0x23-0x3F -- 30 slots, counted by
;          notes/swi7_service_table.py, not by hand
; Inputs:  none
; Outputs: none
; Evidence: the body is one byte -- 0x0E = RET at 0xF8EAC6, immediately after
;          the table's last slot -- so "do-nothing" is the instruction itself.
;          The 30 slots that point here are counted by
;          notes/swi7_service_table.py, not by hand.
; Notes:   a single RET.  Its address is what identifies the unused slots, and
;          the fact that the table's tail is entirely filled with it is what
;          shows the table really is 64 entries long rather than 35.
; ---------------------------------------------------------------------
LCD_Svc_Unimplemented:
	ret					; F8EAC6  0e

; ==============================================================================
; 0xF8EAC7-0xF8ECB4 -- SWI7 service 0x00: DRAW A LINE, and its six helpers
; ==============================================================================
;
; ★ SERVICE 0x00 IS A LINE DRAW, and the identification does not rest on any one
;   instruction:
;
;   1. THE CLAMP.  LCD_ClampCoordsToPanel (0xF8EB6B) limits two of its four
;      variables to 0x13F = 319 and the other two to 0xEF = 239 -- the exact
;      dimensions the SYSTEM SET parameters give (320 x 240, see
;      notes/FINDINGS-display-controller.md section 3, derived from completely
;      different bytes).  So (0x2530)/(0x2534) are X coordinates and
;      (0x2532)/(0x2536) are Y coordinates.
;   2. THE PAIRING.  Every helper reads them as two POINTS: 0xF8EB19 forms
;      (0x2534)-(0x2530) and (0x2536)-(0x2532), i.e. dx and dy; 0xF8EBF1 swaps
;      X with Y in both pairs at once; 0xF8EC4B and 0xF8EC83 each pick one whole
;      point by comparing the two X values.
;   3. THE PLOT.  The body's loop ends in `calr 0xF8ECCF`, which is
;      LCD_PlotPointAt -- already converted, already known to set one pixel from
;      (0x2550)/(0x2552) -- and the loop's only job is to fill in those two
;      words for each step.
;
;   So the two endpoints are (X0,Y0) = ((0x2530),(0x2532)) and (X1,Y1) =
;   ((0x2534),(0x2536)), and the service plots every pixel between them.
;
;   ⚠ NAMING.  An earlier version of these headers called the endpoints "P0" and
;   "P1" (audit round 1).  P1 and P7 are also TMP95C061 port SFRs named all over
;   this same file, and P1..P8 is also how the SED1330 datasheet numbers the
;   SYSTEM SET parameter bytes.  Endpoints are therefore always written
;   (X0,Y0)/(X1,Y1) here, port SFRs keep the bare Pn spelling, and the SED1330
;   command bytes are written "arg n".
;
; THE ARITHMETIC IS FIXED-POINT IN HUNDREDTHS.  The slope is kept as
; dy*100/dx in (0x2548) and the intercept as y*100 - m*x in (0x254A); a step
; recovers y as (m*x + b + 50)/100.  100 is the scale, 50 is the round-to-nearest
; half, and 0x64/0x32 appear nowhere else in the block.
;
; RAM this block establishes (all CS1 static RAM, 16-bit):
;   (0x2530) X0   (0x2532) Y0   (0x2534) X1   (0x2536) Y1  -- the caller's line
;   (0x2547) bit 0 = "X and Y have been swapped", the major-axis flag
;   (0x2548) slope * 100          (0x254A) intercept * 100
;   (0x2550)/(0x2552) the point being plotted -- LCD_PlotPointAt's input
;
; ⚠ NOT ESTABLISHED: who calls service 0x00 and how it sets (0x2530)-(0x2536);
;   no writer of those four words is converted yet.

; ---------------------------------------------------------------------
; LCD_Svc_00_DrawLine -- SWI7 service 0x00: draw a line between two points
;
; Called from: SWI7_ServiceTable slot 0x00 (0xF8E9C6)
; Inputs:  (0x2530),(0x2532) = (X0,Y0) and (0x2534),(0x2536) = (X1,Y1), in panel pixels;
;          (0x2540) selects the layer.
; Outputs: the pixels set (OR, never cleared -- LCD_PlotPointAt only ORs).
;          The four coordinate words are CLOBBERED: clamped, and swapped in place
;          when the line is steep.  IX, IY, WA, HL, DE clobbered.
; Evidence: see the block header above.
; Unknown:  whether the duplicate plot of the low-X endpoint (once by
;          LCD_Line_PlotLowXEnd before the loop, once by the loop's first
;          iteration) is deliberate.
; ---------------------------------------------------------------------
LCD_Svc_00_DrawLine:
	calr LCD_SelectCurrentLayer                    ; F8EAC7  1e c9 03   LCD_SelectCurrentLayer
	calr LCD_ClampCoordsToPanel                    ; F8EACA  1e 9e 00   LCD_ClampCoordsToPanel
	calr LCD_Line_ChooseMajorAxis                    ; F8EACD  1e 49 00   LCD_Line_ChooseMajorAxis
	calr LCD_Line_ComputeIntercept                    ; F8EAD0  1e 37 01   LCD_Line_ComputeIntercept
	calr LCD_Line_PlotLowXEnd                    ; F8EAD3  1e 75 01   LCD_Line_PlotLowXEnd -- also sets IX/IY
LCD_Svc_00__step:
	ld WA,IX                                      ; F8EAD6  dc 88   IX = the current major coordinate
	cp WA,IY                                      ; F8EAD8  dd f0   IY = the last one
	jr nc, LCD_Svc_00__done                       ; F8EADA  6f 39
	muls	xwa, (LCD_LineSlopeX100:16)                      ; F8EADC  d1 48 25 48   unidasm: muls XWA,(0x2548) -- x * slope
	add	wa, (LCD_LineInterceptX100:16)                       ; F8EAE0  d1 4a 25 80   + the intercept
	bit 0x0f,WA                                   ; F8EAE4  d8 33 0f
	jr z, .LF8EAEB                                ; F8EAE7  66 02
	neg WA                                        ; F8EAE9  d8 07   ⚠ the sign is NOT restored below
.LF8EAEB:
	add WA,0x0032                                 ; F8EAEB  d8 c8 32 00   + 50, to round to nearest
	ldw bc, 0x64                                  ; F8EAEF  31 64 00
	exts XWA                                      ; F8EAF2  e8 13
	divs xwa, bc                                 ; F8EAF4  d9 58   / 100 -- back to whole pixels
	bit	0, (LCD_LineFlags:16)                        ; F8EAF6  f1 47 25 c8   were X and Y swapped?
	jr nz, .LF8EB06                               ; F8EAFA  6e 0a
	ld (LCD_PlotY:16), wa                           ; F8EAFC  f1 52 25 50   no: the interpolant is Y
	ld (LCD_PlotX:16), ix                           ; F8EB00  f1 50 25 54       and the loop variable is X
	jr .LF8EB0E                                   ; F8EB04  68 08
.LF8EB06:
	ld (LCD_PlotX:16), wa                           ; F8EB06  f1 50 25 50   yes: the other way round
	ld (LCD_PlotY:16), ix                           ; F8EB0A  f1 52 25 54
.LF8EB0E:
	calr LCD_PlotPointAt                    ; F8EB0E  1e be 01   LCD_PlotPointAt
	inc 1,IX                                      ; F8EB11  dc 61
	jr LCD_Svc_00__step                           ; F8EB13  68 c1
LCD_Svc_00__done:
	calr LCD_Line_PlotHighXEnd                    ; F8EB15  1e 6b 01   LCD_Line_PlotHighXEnd
	ret                                           ; F8EB18  0e

; ---------------------------------------------------------------------
; LCD_Line_ChooseMajorAxis -- pick the axis to step along, and set the slope
;
; Called from: LCD_Svc_00_DrawLine (0xF8EACD)
; Inputs:  the four coordinate words
; Outputs: (0x2548) = the slope; (0x2547) bit 0 = 1 when the coordinates have
;          been swapped; the four words themselves swapped in that case.
; Evidence: three arms, and each is the textbook case.  dx = 0 (a vertical line)
;          cannot have a slope, so it takes slope 0 and swaps the axes.  dy = 0
;          (horizontal) takes slope 0 and does not.  Otherwise the slope is
;          computed and, if |slope| > 100 -- steeper than 45 degrees, since the
;          scale is 100 -- the axes are swapped and the slope recomputed, which
;          is exactly the "step along the longer axis" rule.
; Unknown:  nothing outstanding.
; ---------------------------------------------------------------------
LCD_Line_ChooseMajorAxis:
	ld wa, (LCD_X1:16)                          ; F8EB19  d1 34 25 20
	ld hl, (LCD_X0:16)                          ; F8EB1D  d1 30 25 23
	sub WA,HL                                     ; F8EB21  db a0   dx = X1 - X0
	jr nz, .LF8EB33                               ; F8EB23  6e 0e
	ld (LCD_LineSlopeX100:16), wa                           ; F8EB25  f1 48 25 50   vertical: slope 0 ...
	or	(LCD_LineFlags:16), 0x01                     ; F8EB29  c1 47 25 3e 01   ... and step along Y instead
	calr LCD_Line_SwapXY                    ; F8EB2E  1e c0 00   LCD_Line_SwapXY
	jr .LF8EB6A                                   ; F8EB31  68 37
.LF8EB33:
	ld wa, (LCD_Y1:16)                          ; F8EB33  d1 36 25 20
	ld hl, (LCD_Y0:16)                          ; F8EB37  d1 32 25 23
	sub WA,HL                                     ; F8EB3B  db a0   dy = Y1 - Y0
	jr nz, .LF8EB4A                               ; F8EB3D  6e 0b
	ld (LCD_LineSlopeX100:16), wa                           ; F8EB3F  f1 48 25 50   horizontal: slope 0
	and	(LCD_LineFlags:16), 0xfe                     ; F8EB43  c1 47 25 3c fe
	jr .LF8EB6A                                   ; F8EB48  68 20
.LF8EB4A:
	and	(LCD_LineFlags:16), 0xfe                     ; F8EB4A  c1 47 25 3c fe
	calr LCD_Line_ComputeSlope                    ; F8EB4F  1e 48 00   LCD_Line_ComputeSlope
	bit 0x0f,WA                                   ; F8EB52  d8 33 0f
	jr z, .LF8EB59                                ; F8EB55  66 02
	neg WA                                        ; F8EB57  d8 07
.LF8EB59:
	cp WA,0x0064                                  ; F8EB59  d8 cf 64 00   |slope| > 1.00?
	jr ule, .LF8EB6A                              ; F8EB5D  63 0b
	or	(LCD_LineFlags:16), 0x01                     ; F8EB5F  c1 47 25 3e 01   steep: step along Y
	calr LCD_Line_SwapXY                    ; F8EB64  1e 8a 00   LCD_Line_SwapXY
	calr LCD_Line_ComputeSlope                    ; F8EB67  1e 30 00   and redo the slope
.LF8EB6A:
	ret                                           ; F8EB6A  0e

; ---------------------------------------------------------------------
; LCD_ClampCoordsToPanel -- clip both endpoints to 320 x 240
;
; Called from: LCD_Svc_00_DrawLine (0xF8EACA) and LCD_Svc_0B_PlotPoint
;          (0xF8ECB8, converted below)
; Inputs:  (0x2530),(0x2534) X; (0x2532),(0x2536) Y
; Outputs: each clamped in place; WA clobbered.
; Evidence: ★ 0x13F = 319 and 0xEF = 239 are the panel's last column and last
;          row.  That is an INDEPENDENT confirmation of the geometry
;          notes/FINDINGS-display-controller.md derives from the SYSTEM SET
;          parameter bytes, and it is what identifies which two of the four
;          words are X and which are Y.
; Unknown:  ⚠ the comparison is UNSIGNED (`jr ule`), so a coordinate that is
;          negative as a 16-bit signed number is larger than the limit and comes
;          out clamped to 319 or 239 rather than to 0.  Whether callers can
;          produce a negative coordinate is not established.
; ---------------------------------------------------------------------
LCD_ClampCoordsToPanel:
	ldw wa, 0x013f                                ; F8EB6B  30 3f 01   319 = the last column
	cp	(LCD_X0:16), wa                       ; F8EB6E  d1 30 25 f8
	jr ule, .LF8EB78                              ; F8EB72  63 04
	ld (LCD_X0:16), wa                           ; F8EB74  f1 30 25 50
.LF8EB78:
	cp	(LCD_X1:16), wa                       ; F8EB78  d1 34 25 f8
	jr ule, .LF8EB82                              ; F8EB7C  63 04
	ld (LCD_X1:16), wa                           ; F8EB7E  f1 34 25 50
.LF8EB82:
	ldw wa, 0xef                                  ; F8EB82  30 ef 00   239 = the last row
	cp	(LCD_Y0:16), wa                       ; F8EB85  d1 32 25 f8
	jr ule, .LF8EB8F                              ; F8EB89  63 04
	ld (LCD_Y0:16), wa                           ; F8EB8B  f1 32 25 50
.LF8EB8F:
	cp	(LCD_Y1:16), wa                       ; F8EB8F  d1 36 25 f8
	jr ule, .LF8EB99                              ; F8EB93  63 04
	ld (LCD_Y1:16), wa                           ; F8EB95  f1 36 25 50
.LF8EB99:
	ret                                           ; F8EB99  0e

; ---------------------------------------------------------------------
; LCD_Line_ComputeSlope -- (0x2548) := round(dy * 100 / dx)
;
; Called from: LCD_Line_ChooseMajorAxis (0xF8EB4F and 0xF8EB67)
; Inputs:  the four coordinate words
; Outputs: (0x2548) = the slope in hundredths; WA = the same; IZ, HL, DE, XWA
;          clobbered.
; Evidence: the rounding is what makes it a slope rather than a difference: it
;          adds |dx|/2 to the numerator with the sign of dy before dividing,
;          which is round-half-away-from-zero, and then -- if the quotient came
;          out 0 with a non-zero remainder -- forces it to +1 or -1 so that a
;          shallow line still moves.  A firmware that only wanted dy/dx would do
;          none of that.
; Unknown:  nothing outstanding.
; ---------------------------------------------------------------------
LCD_Line_ComputeSlope:
	ld wa, (LCD_X1:16)                          ; F8EB9A  d1 34 25 20
	ld hl, (LCD_X0:16)                          ; F8EB9E  d1 30 25 23
	sub WA,HL                                     ; F8EBA2  db a0   dx
	pushw wa                                      ; F8EBA4  28
	bit 0x0f,WA                                   ; F8EBA5  d8 33 0f
	jr z, .LF8EBAC                                ; F8EBA8  66 02
	neg WA                                        ; F8EBAA  d8 07
.LF8EBAC:
	exts XWA                                      ; F8EBAC  e8 13
	ldw bc, 0x02                                  ; F8EBAE  31 02 00
	divs xwa, bc                                 ; F8EBB1  d9 58   |dx| / 2 -- the rounding term
	ld IZ,WA                                      ; F8EBB3  d8 8e
	ld wa, (LCD_Y1:16)                          ; F8EBB5  d1 36 25 20
	ld bc, (LCD_Y0:16)                          ; F8EBB9  d1 32 25 21
	sub WA,BC                                     ; F8EBBD  d9 a0   dy
	exts XWA                                      ; F8EBBF  e8 13
	ldw bc, 0x64                                  ; F8EBC1  31 64 00
	muls xwa, bc                                 ; F8EBC4  d9 48   dy * 100
	bit 0x0f,WA                                   ; F8EBC6  d8 33 0f
	jr nz, .LF8EBCF                               ; F8EBC9  6e 04
	add WA,IZ                                     ; F8EBCB  de 80   round away from zero ...
	jr .LF8EBD1                                   ; F8EBCD  68 02
.LF8EBCF:
	sub WA,IZ                                     ; F8EBCF  de a0   ... in whichever direction dy points
.LF8EBD1:
	popw hl                                       ; F8EBD1  4b   dx again
	exts XWA                                      ; F8EBD2  e8 13
	divs xwa, hl                                 ; F8EBD4  db 58
	ld DE,QWA                                     ; F8EBD6  d7 e2 8a   DE = the remainder
	and WA,WA                                     ; F8EBD9  d8 c0
	jr nz, .LF8EBEC                               ; F8EBDB  6e 0f
	and DE,DE                                     ; F8EBDD  da c2
	jr z, .LF8EBEC                                ; F8EBDF  66 0b
	ldw wa, 0x01                                  ; F8EBE1  30 01 00   a slope that rounds to zero but is not
	bit 0x0f,DE                                   ; F8EBE4  da 33 0f   zero becomes +/- 1, so the line still moves
	jr z, .LF8EBEC                                ; F8EBE7  66 03
	ldw wa, 0xffff                                ; F8EBE9  30 ff ff
.LF8EBEC:
	ld (LCD_LineSlopeX100:16), wa                           ; F8EBEC  f1 48 25 50
	ret                                           ; F8EBF0  0e

; ---------------------------------------------------------------------
; LCD_Line_SwapXY -- exchange X with Y in BOTH endpoints
;
; Called from: LCD_Line_ChooseMajorAxis (0xF8EB2E and 0xF8EB64)
; Inputs/Outputs: (0x2530)<->(0x2532) and (0x2534)<->(0x2536); WA clobbered.
; Evidence: two `ex (addr),WA` pairs and nothing else.  It is always called
;          together with setting bit 0 of (0x2547), and every consumer of that
;          bit -- the step loop and both endpoint plotters -- reverses the
;          meaning of the two words it writes, which is what makes the flag and
;          this routine one mechanism.
; ---------------------------------------------------------------------
LCD_Line_SwapXY:
	ld wa, (LCD_X0:16)                          ; F8EBF1  d1 30 25 20
	ex	(LCD_Y0:16), wa                       ; F8EBF5  d1 32 25 30
	ld (LCD_X0:16), wa                           ; F8EBF9  f1 30 25 50
	ld wa, (LCD_X1:16)                          ; F8EBFD  d1 34 25 20
	ex	(LCD_Y1:16), wa                       ; F8EC01  d1 36 25 30
	ld (LCD_X1:16), wa                           ; F8EC05  f1 34 25 50
	ret                                           ; F8EC09  0e

; ---------------------------------------------------------------------
; LCD_Line_ComputeIntercept -- (0x254A) := the mean of the two endpoints' b
;
; Called from: LCD_Svc_00_DrawLine (0xF8EAD0)
; Inputs:  the four coordinate words and (0x2548), the slope
; Outputs: (0x254A) = intercept * 100; WA, HL, BC, XWA clobbered.
; Evidence: it computes (y*100 - m*x)/2 for (X0,Y0), stores it, the same for
;          (X1,Y1) and ADDS it -- i.e. the average of the value of b at the two ends.
;          b = y*100 - m*x is the line equation the step loop inverts
;          (`x*m + b + 50, /100`), so this is its intercept, and averaging both
;          ends is a way of halving the rounding error of the integer slope.
; Unknown:  nothing outstanding.
; ---------------------------------------------------------------------
LCD_Line_ComputeIntercept:
	ld wa, (LCD_X0:16)                          ; F8EC0A  d1 30 25 20
	muls	xwa, (LCD_LineSlopeX100:16)                      ; F8EC0E  d1 48 25 48   unidasm: muls XWA,(0x2548)
	ld HL,WA                                      ; F8EC12  d8 8b   m * X0
	ld wa, (LCD_Y0:16)                          ; F8EC14  d1 32 25 20
	ldw bc, 0x64                                  ; F8EC18  31 64 00
	muls xwa, bc                                 ; F8EC1B  d9 48   Y0 * 100
	sub WA,HL                                     ; F8EC1D  db a0
	ldw bc, 0x02                                  ; F8EC1F  31 02 00
	exts XWA                                      ; F8EC22  e8 13
	divs xwa, bc                                 ; F8EC24  d9 58   half of it
	ld (LCD_LineInterceptX100:16), wa                           ; F8EC26  f1 4a 25 50
	ld wa, (LCD_X1:16)                          ; F8EC2A  d1 34 25 20
	muls	xwa, (LCD_LineSlopeX100:16)                      ; F8EC2E  d1 48 25 48
	ld HL,WA                                      ; F8EC32  d8 8b   m * X1
	ld wa, (LCD_Y1:16)                          ; F8EC34  d1 36 25 20
	ldw bc, 0x64                                  ; F8EC38  31 64 00
	muls xwa, bc                                 ; F8EC3B  d9 48   Y1 * 100
	sub WA,HL                                     ; F8EC3D  db a0
	ldw bc, 0x02                                  ; F8EC3F  31 02 00
	exts XWA                                      ; F8EC42  e8 13
	divs xwa, bc                                 ; F8EC44  d9 58
	add	(LCD_LineInterceptX100:16), wa                       ; F8EC46  d1 4a 25 88   + the other half
	ret                                           ; F8EC4A  0e

; ---------------------------------------------------------------------
; LCD_Line_PlotLowXEnd -- plot the endpoint with the smaller X, and set IX/IY
;
; Called from: LCD_Svc_00_DrawLine (0xF8EAD3)
; Inputs:  the four coordinate words and (0x2547) bit 0
; Outputs: IX = the smaller X, IY = the larger -- which is what the step loop
;          then runs between; (0x2550)/(0x2552) = the plotted point; the pixel
;          set.  WA clobbered.
; Evidence: it compares (0x2530) with (0x2534) and keeps the smaller in IX
;          together with ITS OWN Y in WA, then writes the pair honouring the
;          swap flag and calls LCD_PlotPointAt.  The endpoints are plotted from
;          their exact coordinates rather than from the interpolation, so they
;          land where the caller asked even when the rounded slope would not put
;          them there.
; Unknown:  nothing outstanding.
; ---------------------------------------------------------------------
LCD_Line_PlotLowXEnd:
	ld iy, (LCD_X0:16)                          ; F8EC4B  d1 30 25 25
	ld ix, (LCD_X1:16)                          ; F8EC4F  d1 34 25 24
	ld wa, (LCD_Y1:16)                          ; F8EC53  d1 36 25 20
	cp IY,IX                                      ; F8EC57  dc f5
	jr ugt, .LF8EC67                              ; F8EC59  6b 0c
	ld iy, (LCD_X1:16)                          ; F8EC5B  d1 34 25 25
	ld ix, (LCD_X0:16)                          ; F8EC5F  d1 30 25 24
	ld wa, (LCD_Y0:16)                          ; F8EC63  d1 32 25 20
.LF8EC67:
	bit	0, (LCD_LineFlags:16)                        ; F8EC67  f1 47 25 c8
	jr nz, .LF8EC77                               ; F8EC6B  6e 0a
	ld (LCD_PlotY:16), wa                           ; F8EC6D  f1 52 25 50
	ld (LCD_PlotX:16), ix                           ; F8EC71  f1 50 25 54
	jr .LF8EC7F                                   ; F8EC75  68 08
.LF8EC77:
	ld (LCD_PlotX:16), wa                           ; F8EC77  f1 50 25 50
	ld (LCD_PlotY:16), ix                           ; F8EC7B  f1 52 25 54
.LF8EC7F:
	calr LCD_PlotPointAt                    ; F8EC7F  1e 4d 00   LCD_PlotPointAt
	ret                                           ; F8EC82  0e

; ---------------------------------------------------------------------
; LCD_Line_PlotHighXEnd -- plot the endpoint with the larger X
;
; Called from: LCD_Svc_00_DrawLine (0xF8EB15), after the step loop
; Inputs:  the four coordinate words and (0x2547) bit 0
; Outputs: (0x2550)/(0x2552) = that endpoint; the pixel set.  WA, HL clobbered.
; Evidence: the mirror of LCD_Line_PlotLowXEnd -- same comparison, opposite
;          arm kept -- and it is the last thing the service does, so the far end
;          of the line is drawn exactly rather than by interpolation.
; Unknown:  nothing outstanding.
; ---------------------------------------------------------------------
LCD_Line_PlotHighXEnd:
	ld wa, (LCD_X0:16)                          ; F8EC83  d1 30 25 20
	ld hl, (LCD_Y0:16)                          ; F8EC87  d1 32 25 23
	cp	wa, (LCD_X1:16)                       ; F8EC8B  d1 34 25 f0
	jr ugt, .LF8EC99                              ; F8EC8F  6b 08
	ld wa, (LCD_X1:16)                          ; F8EC91  d1 34 25 20
	ld hl, (LCD_Y1:16)                          ; F8EC95  d1 36 25 23
.LF8EC99:
	bit	0, (LCD_LineFlags:16)                        ; F8EC99  f1 47 25 c8
	jr nz, .LF8ECA9                               ; F8EC9D  6e 0a
	ld (LCD_PlotY:16), hl                           ; F8EC9F  f1 52 25 53
	ld (LCD_PlotX:16), wa                           ; F8ECA3  f1 50 25 50
	jr .LF8ECB1                                   ; F8ECA7  68 08
.LF8ECA9:
	ld (LCD_PlotX:16), hl                           ; F8ECA9  f1 50 25 53
	ld (LCD_PlotY:16), wa                           ; F8ECAD  f1 52 25 50
.LF8ECB1:
	calr LCD_PlotPointAt                    ; F8ECB1  1e 1b 00   LCD_PlotPointAt
	ret                                           ; F8ECB4  0e

; ==============================================================================
; 0xF8ECB5-0xF8EDB3 -- SWI7 service 0x0B: set one pixel
; ==============================================================================

; ---------------------------------------------------------------------
; LCD_Svc_0B_PlotPoint -- SWI7 service 0x0B: set the pixel at (0x2530),(0x2532)
;
; Called from: SWI7_ServiceTable slot 0x0B
; Inputs:  (0x2530) = X, (0x2532) = Y, both 16-bit; (0x2555) = the base address
;          of the layer being drawn into; (0x2557) = AP, bytes per line.
; Outputs: the pixel is set (OR, never cleared).  (0x2550)/(0x2552) are left
;          holding the X and Y that were used.  WA, BC, DE, HL, XHL clobbered.
; Evidence: the ADDRESS ARITHMETIC is the identification and it is arithmetic,
;          not a guess: display address = Y*AP + X/8 + base, and the bit
;          within the byte is X mod 8 used to index LCD_BitMaskTable, which
;          really holds 80 40 20 10 08 04 02 01 (notes/prom_a_byte_checks.py
;          re-reads all eight). That is a 1-bit-per- pixel, MSB-leftmost
;          framebuffer, which is what the SYSTEM SET in LCD_Init_SED1330
;          programmes. The slot binding is emitted as a symbol in
;          SWI7_ServiceTable, so the byte gate proves slot 0x0B points here.
; Notes:   the address arithmetic is the identification, and it is arithmetic
;          rather than a guess: display address = Y*AP + X/8 + base, and the bit
;          within that byte is X mod 8 used as an index into an eight-entry mask
;          table that holds exactly 80 40 20 10 08 04 02 01.  A 1-bit-per-pixel,
;          MSB-leftmost framebuffer -- which is what the SED1330 SYSTEM SET at
;          LCD_Init_SED1330 programmes (FX = 8 pixels per cell, AP = 40 bytes per
;          line, 240 lines: 320 x 240).
; ---------------------------------------------------------------------
LCD_Svc_0B_PlotPoint:
	calr LCD_SelectCurrentLayer                                   ; F8ECB5  1e db 01   -> 0xF8EE93, the setup every graphics service starts with
	calr LCD_ClampCoordsToPanel                                   ; F8ECB8  1e b0 fe   -> LCD_ClampCoordsToPanel (0xF8EB6B)
	ld wa, (LCD_X0:16)                          ; F8ECBB  d1 30 25 20   (0x2530) = the caller's X
	ld (LCD_PlotX:16), wa                           ; F8ECBF  f1 50 25 50
	ld wa, (LCD_Y0:16)                          ; F8ECC3  d1 32 25 20   (0x2532) = the caller's Y
	ld (LCD_PlotY:16), wa                           ; F8ECC7  f1 52 25 50
	calr LCD_PlotPointAt                                 ; F8ECCB  1e 01 00
	ret                                           ; F8ECCE  0e
LCD_PlotPointAt:

; ---------------------------------------------------------------------
; LCD_PlotPointAt -- the read-modify-write that actually sets the bit
;
; Called from: LCD_Svc_0B_PlotPoint (0xF8ECCB), and from all three plot sites of
;          the line draw -- LCD_Svc_00_DrawLine's step loop (0xF8EB0E),
;          LCD_Line_PlotLowXEnd (0xF8EC7F) and LCD_Line_PlotHighXEnd
;          (0xF8ECB1), all converted above.
; Inputs:  (0x2550) = X, (0x2552) = Y, (0x2555) = layer base, (0x2557) = AP
; Outputs: one display byte updated
; Notes:   the controller has no read-modify-write, so this is CSRW / MREAD /
;          CSRW / MWRITE -- the second CSRW exists only because MREAD advances
;          the cursor.  Every access is preceded by the BUSY poll unless bit 0 of
;          (0xC6) says the display is off; see LCD_Svc_0C_DisplayOnOff, which is
;          what sets that bit.
; ---------------------------------------------------------------------
	ld wa, (LCD_PlotY:16)                          ; F8ECCF  d1 52 25 20   WA = Y
	ld bc, (LCD_BytesPerLine:16)                          ; F8ECD3  d1 57 25 21   BC = AP, the bytes per line the SYSTEM SET programmed (40)
	mul xwa, bc                                  ; F8ECD7  d9 40   XWA = Y * AP
	ld HL,WA                                      ; F8ECD9  d8 8b
	ld wa, (LCD_PlotX:16)                          ; F8ECDB  d1 50 25 20   WA = X
	extz XWA                                      ; F8ECDF  e8 12
	ldw bc, 0x08                                  ; F8ECE1  31 08 00
	div xwa, bc                                  ; F8ECE4  d9 50   XWA = X/8, QWA = X mod 8
	ld DE,QWA                                     ; F8ECE6  d7 e2 8a   DE = X mod 8 -- which bit inside the byte
	add WA,HL                                     ; F8ECE9  db 80   WA = Y*AP + X/8
	add	wa, (LCD_CurrentLayerBase:16)                       ; F8ECEB  d1 55 25 80   + (0x2555), the layer's base address -> the display-RAM address
	bit	0, (0xc6:8)                            ; F8ECEF  f0 c6 c8   (0xC6) bit 0 set = the display is off, do not wait for BUSY
	jr nz, .LF8ECFB                               ; F8ECF2  6e 07
.LF8ECF4:
	bit	6, (0x790000:24)                      ; F8ECF4  f2 00 00 79 ce
	jr nz, .LF8ECF4                               ; F8ECF9  6e f9
.LF8ECFB:
	ld (0x790001:24), 0x46                      ; F8ECFB  f2 01 00 79 00 46   CSRW
	bit	0, (0xc6:8)                            ; F8ED01  f0 c6 c8
	jr nz, .LF8ED0D                               ; F8ED04  6e 07
.LF8ED06:
	bit	6, (0x790000:24)                      ; F8ED06  f2 00 00 79 ce
	jr nz, .LF8ED06                               ; F8ED0B  6e f9
.LF8ED0D:
	ld (0x790000:24), a                          ; F8ED0D  f2 00 00 79 41   address low
	bit	0, (0xc6:8)                            ; F8ED12  f0 c6 c8
	jr nz, .LF8ED1E                               ; F8ED15  6e 07
.LF8ED17:
	bit	6, (0x790000:24)                      ; F8ED17  f2 00 00 79 ce
	jr nz, .LF8ED17                               ; F8ED1C  6e f9
.LF8ED1E:
	ld (0x790000:24), w                          ; F8ED1E  f2 00 00 79 40   address high
	bit	0, (0xc6:8)                            ; F8ED23  f0 c6 c8
	jr nz, .LF8ED2F                               ; F8ED26  6e 07
.LF8ED28:
	bit	6, (0x790000:24)                      ; F8ED28  f2 00 00 79 ce
	jr nz, .LF8ED28                               ; F8ED2D  6e f9
.LF8ED2F:
	ld (0x790001:24), 0x43                      ; F8ED2F  f2 01 00 79 00 43   MREAD -- and it auto-increments the cursor, which is why
	bit	0, (0xc6:8)                            ; F8ED35  f0 c6 c8
	jr nz, .LF8ED41                               ; F8ED38  6e 07
.LF8ED3A:
	bit	6, (0x790000:24)                      ; F8ED3A  f2 00 00 79 ce
	jr nz, .LF8ED3A                               ; F8ED3F  6e f9
.LF8ED41:
	ld c, (0x790001:24)                          ; F8ED41  c2 01 00 79 23   C = the byte that is already there
	bit	0, (0xc6:8)                            ; F8ED46  f0 c6 c8
	jr nz, .LF8ED52                               ; F8ED49  6e 07
.LF8ED4B:
	bit	6, (0x790000:24)                      ; F8ED4B  f2 00 00 79 ce
	jr nz, .LF8ED4B                               ; F8ED50  6e f9
.LF8ED52:
	ld (0x790001:24), 0x46                      ; F8ED52  f2 01 00 79 00 46   CSRW again, to undo the MREAD auto-increment
	bit	0, (0xc6:8)                            ; F8ED58  f0 c6 c8
	jr nz, .LF8ED64                               ; F8ED5B  6e 07
.LF8ED5D:
	bit	6, (0x790000:24)                      ; F8ED5D  f2 00 00 79 ce
	jr nz, .LF8ED5D                               ; F8ED62  6e f9
.LF8ED64:
	ld (0x790000:24), a                          ; F8ED64  f2 00 00 79 41
	bit	0, (0xc6:8)                            ; F8ED69  f0 c6 c8
	jr nz, .LF8ED75                               ; F8ED6C  6e 07
.LF8ED6E:
	bit	6, (0x790000:24)                      ; F8ED6E  f2 00 00 79 ce
	jr nz, .LF8ED6E                               ; F8ED73  6e f9
.LF8ED75:
	ld (0x790000:24), w                          ; F8ED75  f2 00 00 79 40
	ld XHL,LCD_BitMaskTable                       ; F8ED7A  43 ac ed f8 00   the single-bit mask table below
	or	c, (xhl+de)                           ; F8ED7F  c3 07 ec e8 e3   set the one bit
	nop                                           ; F8ED84  00
	nop                                           ; F8ED85  00
	nop                                           ; F8ED86  00
	nop                                           ; F8ED87  00
	bit	0, (0xc6:8)                            ; F8ED88  f0 c6 c8
	jr nz, .LF8ED94                               ; F8ED8B  6e 07
.LF8ED8D:
	bit	6, (0x790000:24)                      ; F8ED8D  f2 00 00 79 ce
	jr nz, .LF8ED8D                               ; F8ED92  6e f9
.LF8ED94:
	ld (0x790001:24), 0x42                      ; F8ED94  f2 01 00 79 00 42   MWRITE
	bit	0, (0xc6:8)                            ; F8ED9A  f0 c6 c8
	jr nz, .LF8EDA6                               ; F8ED9D  6e 07
.LF8ED9F:
	bit	6, (0x790000:24)                      ; F8ED9F  f2 00 00 79 ce
	jr nz, .LF8ED9F                               ; F8EDA4  6e f9
.LF8EDA6:
	ld (0x790000:24), c                          ; F8EDA6  f2 00 00 79 43   the modified byte goes back
	ret                                           ; F8EDAB  0e

; ---------------------------------------------------------------------
; LCD_BitMaskTable -- 8 x byte, the single-bit masks
;
; Read by:  0xF8ED7A/0xF8ED7F, indexed by DE = X mod 8.
; Evidence: the eight bytes are re-read out of the ROM by
;          notes/prom_a_byte_checks.py ("LCD_BitMaskTable is 80 40 20 10 08 04
;          02 01"). "Leftmost pixel = most significant bit" is a fact about
;          the table TOGETHER with its reader at 0xF8ED7A/0xF8ED7F, which
;          indexes it by X mod 8 -- neither half states it alone.
; Layout:   index 0 -> 0x80 ... index 7 -> 0x01, i.e. the leftmost pixel of a
;           byte is its most significant bit.
; ---------------------------------------------------------------------
LCD_BitMaskTable:
	.byte 0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01	; F8EDAC

; ==============================================================================
; 0xF8EDB4-0xF8EEBC -- SWI7 services 0x03 and 0x04, and the layer selector
; ==============================================================================
;
; ★ THE DRIVER'S BLOCK OPERATIONS ARE COLUMN-MAJOR.  Both services set CSRDIR
;   **DOWN** (0x4F) before the transfer and then, per iteration, run one CSRW +
;   MWRITE/MREAD burst of HL bytes and advance the starting address by ONE.
;   With the cursor auto-advancing downward, HL bytes with one burst is a
;   vertical COLUMN of HL bytes and "+1" is the next column to the right.
;   0x4F = CSRDIR DOWN is cited: ../mame/src/devices/video/sed1330.cpp:33, and
;   `sed1330_device::increment_csr` adds AP for that direction (sed1330.cpp:135).
;   This is also the correction described in notes/FINDINGS-display-controller.md
;   section 2 -- 0x4F was missing from the first command census.
;
; THE BUSY WAIT, which appears twenty-odd times below:
;       bit_dd8 0x00, 0xc6      ; (0xC6) bit 0 = "the panel is dark, do not poll"
;       jr nz, <past>
;   .w: bit 6,(XIZ)             ; 0x790000 bit 6 = BF, the controller's busy flag
;       jr nz, .w
;   MAME's `sed1330_device::status_r` returns `m_bf << 6` (sed1330.cpp:245-251).

; ---------------------------------------------------------------------
; LCD_Svc_03_BlitColumns -- SWI7 service 0x03: write a rectangle, column-major
;
; Called from: SWI7_ServiceTable slot 0x03 (0xF8E9D2)
; Inputs:  IX = byte offset of the top-left corner WITHIN the current layer;
;          BC = number of columns; HL = bytes down each column;
;          XIY = source data, read forwards.  (0x2540) selects the layer.
; Outputs: BC*HL bytes copied into display RAM; XIY advanced past the source;
;          WA, BC, E clobbered.  Returns immediately if BC or HL is zero.
; Evidence: the arithmetic and the command bytes.  `ld WA,IX` + `add WA,(0x2555)`
;          turns the caller's offset into an absolute display-RAM address by
;          adding the CURRENT LAYER'S BASE, which is exactly what
;          LCD_SelectCurrentLayer (called as the first instruction) has just put
;          in (0x2555).  The rest is CSRW (0x46) with that 16-bit address low
;          byte first, then MWRITE (0x42) and HL data bytes.
; Unknown:  nothing is checked against the panel's bounds, so the caller owns
;           clipping; which callers those are has not been traced.
; ---------------------------------------------------------------------
LCD_Svc_03_BlitColumns:
	calr (0xF8EE93 - 0xF8EDB7)                    ; F8EDB4  1e dc 00   LCD_SelectCurrentLayer
	ld XIZ,0x00790000                             ; F8EDB7  46 00 00 79 00
	bit	0, (0xc6:8)                            ; F8EDBC  f0 c6 c8
	jr nz, .LF8EDC5                               ; F8EDBF  6e 04
.LF8EDC1:
	bit 6,(XIZ)                                   ; F8EDC1  b6 ce
	jr nz, .LF8EDC1                               ; F8EDC3  6e fc
.LF8EDC5:
	ld (XIZ+0x01),0x4f                            ; F8EDC5  be 01 00 4f   CSRDIR DOWN
	and BC,BC                                     ; F8EDC9  d9 c1
	jr z, LCD_Svc_03__ret                         ; F8EDCB  66 55   no columns
	and HL,HL                                     ; F8EDCD  db c3
	jr z, LCD_Svc_03__ret                         ; F8EDCF  66 51   no rows
	ld WA,IX                                      ; F8EDD1  dc 88
	add	wa, (LCD_CurrentLayerBase:16)                       ; F8EDD3  d1 55 25 80   + the layer base
LCD_Svc_03__column:
	bit	0, (0xc6:8)                            ; F8EDD7  f0 c6 c8
	jr nz, .LF8EDE0                               ; F8EDDA  6e 04
.LF8EDDC:
	bit 6,(XIZ)                                   ; F8EDDC  b6 ce
	jr nz, .LF8EDDC                               ; F8EDDE  6e fc
.LF8EDE0:
	ld (XIZ+0x01),0x46                            ; F8EDE0  be 01 00 46   CSRW
	bit	0, (0xc6:8)                            ; F8EDE4  f0 c6 c8
	jr nz, .LF8EDED                               ; F8EDE7  6e 04
.LF8EDE9:
	bit 6,(XIZ)                                   ; F8EDE9  b6 ce
	jr nz, .LF8EDE9                               ; F8EDEB  6e fc
.LF8EDED:
	ld (XIZ),A                                    ; F8EDED  b6 41   cursor address, low byte
	bit	0, (0xc6:8)                            ; F8EDEF  f0 c6 c8
	jr nz, .LF8EDF8                               ; F8EDF2  6e 04
.LF8EDF4:
	bit 6,(XIZ)                                   ; F8EDF4  b6 ce
	jr nz, .LF8EDF4                               ; F8EDF6  6e fc
.LF8EDF8:
	ld (XIZ),W                                    ; F8EDF8  b6 40   cursor address, high byte
	bit	0, (0xc6:8)                            ; F8EDFA  f0 c6 c8
	jr nz, .LF8EE03                               ; F8EDFD  6e 04
.LF8EDFF:
	bit 6,(XIZ)                                   ; F8EDFF  b6 ce
	jr nz, .LF8EDFF                               ; F8EE01  6e fc
.LF8EE03:
	ld (XIZ+0x01),0x42                            ; F8EE03  be 01 00 42   MWRITE
	pushw bc                                      ; F8EE07  29
	ld BC,HL                                      ; F8EE08  db 89   the inner count is HL
LCD_Svc_03__byte:
	ld E,(XIY)                                    ; F8EE0A  85 25
	inc 1,XIY                                     ; F8EE0C  ed 61
	bit	0, (0xc6:8)                            ; F8EE0E  f0 c6 c8
	jr nz, .LF8EE17                               ; F8EE11  6e 04
.LF8EE13:
	bit 6,(XIZ)                                   ; F8EE13  b6 ce
	jr nz, .LF8EE13                               ; F8EE15  6e fc
.LF8EE17:
	ld (XIZ),E                                    ; F8EE17  b6 45   one byte of display RAM
	djnz16 bc, LCD_Svc_03__byte                   ; F8EE19  d9 1c ee
	popw bc                                       ; F8EE1C  49
	inc 1,WA                                      ; F8EE1D  d8 61   the next column starts one byte along
	djnz16 bc, LCD_Svc_03__column                 ; F8EE1F  d9 1c b5
LCD_Svc_03__ret:
	ret                                           ; F8EE22  0e

; ---------------------------------------------------------------------
; LCD_Svc_04_ReadColumns -- SWI7 service 0x04: read a rectangle back, column-major
;
; Called from: SWI7_ServiceTable slot 0x04 (0xF8E9D6)
; Inputs:  IX, BC, HL as for service 0x03; XIY = the DESTINATION buffer.
; Outputs: BC*HL bytes copied out of display RAM into (XIY); XIY advanced.
; Evidence: instruction for instruction the same routine as service 0x03 with
;          MWRITE (0x42) replaced by MREAD (0x43) and the inner body reversed --
;          `ld E,(XIZ+0x01)` (read the DATA port at 0x790001) then
;          `ld (XIY),E`, where 0x03 has `ld E,(XIY)` then `ld (XIZ),E`.
;          The read/write asymmetry of the port pair is the reason the register
;          offsets differ: reading data is 0x790001, writing data is 0x790000
;          (notes/FINDINGS-display-controller.md section 1).
; Unknown:  as service 0x03.
; ---------------------------------------------------------------------
LCD_Svc_04_ReadColumns:
	calr LCD_SelectCurrentLayer                    ; F8EE23  1e 6d 00   LCD_SelectCurrentLayer
	ld XIZ,0x00790000                             ; F8EE26  46 00 00 79 00
	bit	0, (0xc6:8)                            ; F8EE2B  f0 c6 c8
	jr nz, .LF8EE34                               ; F8EE2E  6e 04
.LF8EE30:
	bit 6,(XIZ)                                   ; F8EE30  b6 ce
	jr nz, .LF8EE30                               ; F8EE32  6e fc
.LF8EE34:
	ld (XIZ+0x01),0x4f                            ; F8EE34  be 01 00 4f   CSRDIR DOWN
	and BC,BC                                     ; F8EE38  d9 c1
	jr z, LCD_Svc_04__ret                         ; F8EE3A  66 56
	and HL,HL                                     ; F8EE3C  db c3
	jr z, LCD_Svc_04__ret                         ; F8EE3E  66 52
	ld WA,IX                                      ; F8EE40  dc 88
	add	wa, (LCD_CurrentLayerBase:16)                       ; F8EE42  d1 55 25 80   + the layer base
LCD_Svc_04__column:
	bit	0, (0xc6:8)                            ; F8EE46  f0 c6 c8
	jr nz, .LF8EE4F                               ; F8EE49  6e 04
.LF8EE4B:
	bit 6,(XIZ)                                   ; F8EE4B  b6 ce
	jr nz, .LF8EE4B                               ; F8EE4D  6e fc
.LF8EE4F:
	ld (XIZ+0x01),0x46                            ; F8EE4F  be 01 00 46   CSRW
	bit	0, (0xc6:8)                            ; F8EE53  f0 c6 c8
	jr nz, .LF8EE5C                               ; F8EE56  6e 04
.LF8EE58:
	bit 6,(XIZ)                                   ; F8EE58  b6 ce
	jr nz, .LF8EE58                               ; F8EE5A  6e fc
.LF8EE5C:
	ld (XIZ),A                                    ; F8EE5C  b6 41
	bit	0, (0xc6:8)                            ; F8EE5E  f0 c6 c8
	jr nz, .LF8EE67                               ; F8EE61  6e 04
.LF8EE63:
	bit 6,(XIZ)                                   ; F8EE63  b6 ce
	jr nz, .LF8EE63                               ; F8EE65  6e fc
.LF8EE67:
	ld (XIZ),W                                    ; F8EE67  b6 40
	bit	0, (0xc6:8)                            ; F8EE69  f0 c6 c8
	jr nz, .LF8EE72                               ; F8EE6C  6e 04
.LF8EE6E:
	bit 6,(XIZ)                                   ; F8EE6E  b6 ce
	jr nz, .LF8EE6E                               ; F8EE70  6e fc
.LF8EE72:
	ld (XIZ+0x01),0x43                            ; F8EE72  be 01 00 43   MREAD
	pushw bc                                      ; F8EE76  29
	ld BC,HL                                      ; F8EE77  db 89
LCD_Svc_04__byte:
	bit	0, (0xc6:8)                            ; F8EE79  f0 c6 c8
	jr nz, .LF8EE82                               ; F8EE7C  6e 04
.LF8EE7E:
	bit 6,(XIZ)                                   ; F8EE7E  b6 ce
	jr nz, .LF8EE7E                               ; F8EE80  6e fc
.LF8EE82:
	ld E,(XIZ+0x01)                               ; F8EE82  8e 01 25   the DATA port when READING
	ld (XIY),E                                    ; F8EE85  b5 45
	inc 1,XIY                                     ; F8EE87  ed 61
	djnz16 bc, LCD_Svc_04__byte                   ; F8EE89  d9 1c ed
	popw bc                                       ; F8EE8C  49
	inc 1,WA                                      ; F8EE8D  d8 61
	djnz16 bc, LCD_Svc_04__column                 ; F8EE8F  d9 1c b4
LCD_Svc_04__ret:
	ret                                           ; F8EE92  0e

; ---------------------------------------------------------------------
; LCD_SelectCurrentLayer -- (0x2555) := the display-RAM base of layer (0x2540)
;
; Called from: nearly every SWI7 service opens with it -- 0xF8EDB4 and 0xF8EE23
;          here, and the display-controller note lists the rest.
; Inputs:  (0x2540), a layer number.
; Outputs: (0x2555) = the 16-bit display-RAM base address of that layer.
;          XHL and XIX are saved and restored, so it clobbers only WA.
; Evidence: ★ THIS IS WHAT (0x2555) IS, and the three-entry table below is what
;          proves it.  The table holds pointers to (0x2541), (0x2543) and
;          (0x2545) -- and those are exactly the three RAM words that
;          LCD_Init_SED1330 (0xF8E819, converted) writes the SCROLL command's
;          SAD1, SAD2 and SAD3 into, i.e. the base addresses of the three
;          OR-composited graphics layers.  So (0x2540) is the layer number and
;          this routine dereferences it into the base every drawing service then
;          adds to its caller's offset.
;
;          ★ AND THE LAYER COUNT IS NOW INDEPENDENT OF THE TABLE.  The three
;          entries used to rest on one argument -- that a fourth would overlap
;          service 0x05's first instruction.  `python3 notes/lcd_layer_census.py`
;          censuses every access to (0x2540) in BOTH images and finds 764 sites
;          writing it with an immediate, whose value is 0 at 499 of them, 1 at
;          180 and 2 at 85.  **Never 3, never anything else.**  That is a
;          byte-pattern census and cannot tell code from data, but it does not
;          need to: coincidental matches would spread the immediate over
;          0..255, and this one never exceeds 2.
; Notes:   exactly one of those 764 sites lies inside source this tree has
;          converted -- 0xF8EEBD, the first instruction of LCD_Svc_05_FillRect,
;          written out below as `stdi8 (0x2540), 0x01`.  So at least one hit is
;          confirmed a real instruction at a real boundary, by the byte gate.
;          ★ That site is also a finding in itself: service 0x05 FORCES layer 1
;          before doing anything, so a filled rectangle always lands in SAD2 =
;          0x2600 whatever the caller had selected.
; Unknown:  ⚠ the layers are still not NAMED.  Knowing that 0, 1 and 2 are the
;          only values, and that layer 0 is selected three times as often as
;          layer 2, does not say which is menu, which is keyboard graphics and
;          which is an overlay.  Naming them needs a converted caller, and the
;          callers are in prom_b.
; ---------------------------------------------------------------------
LCD_SelectCurrentLayer:
	push XHL                                      ; F8EE93  3b
	push XIX                                      ; F8EE94  3c
	xor H,H                                       ; F8EE95  ce d6
	ld l, (LCD_CurrentLayer:16)                            ; F8EE97  c1 40 25 27   the layer number
	sla hl, 0x02                                  ; F8EE9B  db ec 02   * 4
	ld XIX,LCD_LayerBasePtr_Table                 ; F8EE9E  44 b1 ee f8 00   the table below
	ld	xhl, (xix+hl)                         ; F8EEA3  e3 07 f0 ec 23
	ld WA,(XHL)                                   ; F8EEA8  93 20   the SAD word it points at
	ld (LCD_CurrentLayerBase:16), wa                           ; F8EEAA  f1 55 25 50
	pop XIX                                       ; F8EEAE  5c
	pop XHL                                       ; F8EEAF  5b
	ret                                           ; F8EEB0  0e

; ---------------------------------------------------------------------
; LCD_LayerBasePtr_Table -- 3 x LE32: where each layer's base address is kept
;
; Read by:  LCD_SelectCurrentLayer (0xF8EE9E), indexed by (0x2540)*4.
; Layout:   3 entries, 12 bytes, 0xF8EEB1-0xF8EEBC.  Each entry is a 32-bit
;           POINTER to a 16-bit RAM word, not a base address itself.
; Count:    exactly three, and the proof is arithmetic rather than a guess --
;           0xF8EEB1 + 3*4 = 0xF8EEBD, which is the address SWI7_ServiceTable
;           slot 0x05 holds (0xF8E9DA = 0x00F8EEBD).  A fourth entry would
;           overlap the next service's first instruction.
; Evidence: the three targets are (0x2541), (0x2543) and (0x2545), the three
;           words LCD_Init_SED1330 fills with SAD1/SAD2/SAD3 from the SCROLL
;           command -- see notes/FINDINGS-display-controller.md section 3.
;
; ★ TWO NUMBERINGS, AND THIS FILE USED TO MIX THEM (audit round 1, F7).  The
;   SED1330's own registers are 1-based -- SAD1..SAD4, which MAME logs as
;   "Display Page 1/2 Start Address" (../mame/src/devices/video/sed1330.cpp:459
;   and :473).  The FIRMWARE's layer selector (0x2540) is 0-based, because
;   LCD_SelectCurrentLayer indexes this table with (0x2540)*4 and the table has
;   three entries.  The rule adopted from here on, and applied to the
;   LCD_Init_SED1330 comments above and to LCD_Svc_05_FillRect below:
;
;       firmware layer 0  =  SAD1  =  display-RAM 0x0000
;       firmware layer 1  =  SAD2  =  display-RAM 0x2600
;       firmware layer 2  =  SAD3  =  display-RAM 0x4C00
;
;   Anything written as a bare "layer N" in this file means the FIRMWARE index.
;   SAD/display-block numbers are always spelled SADn.
; ---------------------------------------------------------------------
LCD_LayerBasePtr_Table:
	.long 0x00002541			; F8EEB1  41 25 00 00   layer 0 -> SAD1 = 0x0000
	.long 0x00002543			; F8EEB5  43 25 00 00   layer 1 -> SAD2 = 0x2600
	.long 0x00002545			; F8EEB9  45 25 00 00   layer 2 -> SAD3 = 0x4C00

; ==============================================================================
; 0xF8EEBD-0xF8F038 -- SWI7 service 0x05: fill a rectangle
; ==============================================================================

; ---------------------------------------------------------------------
; LCD_Svc_05_FillRect -- SWI7 service 0x05: fill the box between (X0,Y0) and (X1,Y1)
;
; Called from: SWI7_ServiceTable slot 0x05 (0xF8E9DA)
; Inputs:  (0x2530),(0x2532) = (X0,Y0) and (0x2534),(0x2536) = (X1,Y1), the same four
;          coordinate words the line draw uses -- it calls the same
;          LCD_ClampCoordsToPanel to clip them.  (0x2554) = the OVLAY shadow.
; Outputs: every pixel of the box set in firmware LAYER 1, i.e. the SED1330
;          display block 2 whose base SAD2 = 0x2600 (see the numbering note in
;          the LCD_LayerBasePtr_Table header); (0x2540) forced to 1;
;          (0x255A) left holding the last column's cursor address; the OVLAY
;          register reprogrammed.  WA, BC, DE, HL, XIX clobbered.
; Evidence: three things together, none of them a guess:
;          1. it walks the SAME four coordinate words as LCD_Svc_00_DrawLine and
;             clips them with the same routine, so the two are opposite corners;
;          2. the height it counts out for every column is (0x2536)-(0x2532)+1
;             and the width it divides by 8 is (0x2534)-(0x2530)+1 -- inclusive
;             spans in Y and X;
;          3. the middle of the box is written as whole 0xFF bytes and the two
;             ends through the masks at 0xF8F79B and 0xF8F7AF, which is what
;             filling a byte-addressed bitmap looks like when the edges do not
;             fall on byte boundaries.
;          ⚠ The first thing it does after selecting the layer is issue OVLAY
;          with the MX field forced to 1.  MAME names MX=1 "Exclusive-OR"
;          (../mame/src/devices/video/sed1330.cpp:49) and leaves it
;          unimplemented, so the NAME is cited but the BEHAVIOUR is not.  Filling
;          layer 1 with 0xFF while the composition is XOR would invert whatever
;          the other layers show there -- that is a READING of those two facts,
;          offered as such, not a measurement.
; Unknown:  why this service, alone among those converted, forces the layer
;          instead of using the caller's (0x2540); what (0x2554) is otherwise
;          for; who calls it.
; ---------------------------------------------------------------------
LCD_Svc_05_FillRect:
	ld (LCD_CurrentLayer:16), 0x01                          ; F8EEBD  f1 40 25 00 01   force firmware layer 1 = SAD2 = 0x2600
	calr (0xF8EE93 - 0xF8EEC5)                    ; F8EEC2  1e ce ff   LCD_SelectCurrentLayer
	calr LCD_ClampCoordsToPanel                    ; F8EEC5  1e a3 fc   LCD_ClampCoordsToPanel
	ld XIX,0x00790000                             ; F8EEC8  44 00 00 79 00
	ld (XIX+0x01),0x5b                            ; F8EECD  bc 01 00 5b   OVLAY
	ld a, (LCD_OvlayShadow:16)                            ; F8EED1  c1 54 25 21
	and A,0xfc                                    ; F8EED5  c9 cc fc
	or A,0x01                                     ; F8EED8  c9 ce 01   MX = 1 = Exclusive-OR (sed1330.cpp:49)
	bit	0, (0xc6:8)                            ; F8EEDB  f0 c6 c8
	jr nz, .LF8EEE4                               ; F8EEDE  6e 04
.LF8EEE0:
	bit 6,(XIX)                                   ; F8EEE0  b4 ce
	jr nz, .LF8EEE0                               ; F8EEE2  6e fc
.LF8EEE4:
	ld (XIX),A                                    ; F8EEE4  b4 41
	ld wa, (LCD_Y0:16)                          ; F8EEE6  d1 32 25 20
	ld bc, (LCD_BytesPerLine:16)                          ; F8EEEA  d1 57 25 21
	mul xwa, bc                                  ; F8EEEE  d9 40   Y0 * AP
	ld HL,WA                                      ; F8EEF0  d8 8b
	ld wa, (LCD_X0:16)                          ; F8EEF2  d1 30 25 20
	extz XWA                                      ; F8EEF6  e8 12
	ldw bc, 0x08                                  ; F8EEF8  31 08 00
	div xwa, bc                                  ; F8EEFB  d9 50   XWA = X0/8, QWA = X0 mod 8
	ld DE,QWA                                     ; F8EEFD  d7 e2 8a   DE = the bit offset into the first byte
	add HL,WA                                     ; F8EF00  d8 83
	ld wa, (LCD_CurrentLayerBase:16)                          ; F8EF02  d1 55 25 20
	add WA,HL                                     ; F8EF06  db 80   + the layer base -> the display-RAM address
	ld (LCD_RunAddress:16), wa                           ; F8EF08  f1 5a 25 50   (0x255A) = this column's cursor address
	bit	0, (0xc6:8)                            ; F8EF0C  f0 c6 c8
	jr nz, .LF8EF15                               ; F8EF0F  6e 04
.LF8EF11:
	bit 6,(XIX)                                   ; F8EF11  b4 ce
	jr nz, .LF8EF11                               ; F8EF13  6e fc
.LF8EF15:
	ld (XIX+0x01),0x4f                            ; F8EF15  bc 01 00 4f   CSRDIR DOWN -- columns, not rows
	and DE,DE                                     ; F8EF19  da c2
	jr z, LCD_Svc_05__fullcols                                ; F8EF1B  66 58
	bit	0, (0xc6:8)                            ; F8EF1D  f0 c6 c8
	jr nz, .LF8EF26                               ; F8EF20  6e 04
.LF8EF22:
	bit 6,(XIX)                                   ; F8EF22  b4 ce
	jr nz, .LF8EF22                               ; F8EF24  6e fc
.LF8EF26:
	ld (XIX+0x01),0x46                            ; F8EF26  bc 01 00 46
	bit	0, (0xc6:8)                            ; F8EF2A  f0 c6 c8
	jr nz, .LF8EF33                               ; F8EF2D  6e 04
.LF8EF2F:
	bit 6,(XIX)                                   ; F8EF2F  b4 ce
	jr nz, .LF8EF2F                               ; F8EF31  6e fc
.LF8EF33:
	ld (XIX),A                                    ; F8EF33  b4 41
	bit	0, (0xc6:8)                            ; F8EF35  f0 c6 c8
	jr nz, .LF8EF3E                               ; F8EF38  6e 04
.LF8EF3A:
	bit 6,(XIX)                                   ; F8EF3A  b4 ce
	jr nz, .LF8EF3A                               ; F8EF3C  6e fc
.LF8EF3E:
	ld (XIX),W                                    ; F8EF3E  b4 40
	inc 1,WA                                      ; F8EF40  d8 61
	ld (LCD_RunAddress:16), wa                           ; F8EF42  f1 5a 25 50
	calr LCD_Rect_LeftEdgeMask                    ; F8EF46  1e 1e 08   LCD_Rect_LeftEdgeMask -> A
	bit	0, (0xc6:8)                            ; F8EF49  f0 c6 c8
	jr nz, .LF8EF52                               ; F8EF4C  6e 04
.LF8EF4E:
	bit 6,(XIX)                                   ; F8EF4E  b4 ce
	jr nz, .LF8EF4E                               ; F8EF50  6e fc
.LF8EF52:
	ld (XIX+0x01),0x42                            ; F8EF52  bc 01 00 42
	ld bc, (LCD_Y1:16)                          ; F8EF56  d1 36 25 21
	sub	bc, (LCD_Y0:16)                       ; F8EF5A  d1 32 25 a1
	inc 1,BC                                      ; F8EF5E  d9 61   BC = Y1 - Y0 + 1, the height in rows
LCD_Svc_05__leftrow:
	bit	0, (0xc6:8)                            ; F8EF60  f0 c6 c8
	jr nz, .LF8EF69                               ; F8EF63  6e 04
.LF8EF65:
	bit 6,(XIX)                                   ; F8EF65  b4 ce
	jr nz, .LF8EF65                               ; F8EF67  6e fc
.LF8EF69:
	ld (XIX),A                                    ; F8EF69  b4 41
	djnz16 bc, LCD_Svc_05__leftrow                           ; F8EF6B  d9 1c f2
	ldw hl, 0x08                                  ; F8EF6E  33 08 00
	sub HL,DE                                     ; F8EF71  da a3
	ex16 hl, de                                   ; F8EF73  da bb
; --- the whole-byte middle, and how much of it there is ----------------------
; DE arrives holding 8 - (X0 mod 8): the number of pixels the partial first
; column already covered.  If the box is no wider than that it is finished.
LCD_Svc_05__fullcols:
	ld wa, (LCD_X1:16)                          ; F8EF75  d1 34 25 20
	sub	wa, (LCD_X0:16)                       ; F8EF79  d1 30 25 a0
	inc 1,WA                                      ; F8EF7D  d8 61
	cp WA,DE                                      ; F8EF7F  da f0
	jrl ule, LCD_Svc_05__ret                             ; F8EF81  73 b4 00
	sub WA,DE                                     ; F8EF84  da a0
	ldw bc, 0x08                                  ; F8EF86  31 08 00
	extz XWA                                      ; F8EF89  e8 12
	divs xwa, bc                                 ; F8EF8B  d9 58
	ld DE,QWA                                     ; F8EF8D  d7 e2 8a
	and WA,WA                                     ; F8EF90  d8 c0
	jr z, LCD_Svc_05__rightedge                                ; F8EF92  66 5a
	ld BC,WA                                      ; F8EF94  d8 89

; --- one whole byte-column of the middle, repeated (0x2534)-(0x2530)+1 / 8 ---
LCD_Svc_05__fullcol:
	bit	0, (0xc6:8)                            ; F8EF96  f0 c6 c8
	jr nz, .LF8EF9F                               ; F8EF99  6e 04
.LF8EF9B:
	bit 6,(XIX)                                   ; F8EF9B  b4 ce
	jr nz, .LF8EF9B                               ; F8EF9D  6e fc
.LF8EF9F:
	ld (XIX+0x01),0x46                            ; F8EF9F  bc 01 00 46
	ld wa, (LCD_RunAddress:16)                          ; F8EFA3  d1 5a 25 20
	bit	0, (0xc6:8)                            ; F8EFA7  f0 c6 c8
	jr nz, .LF8EFB0                               ; F8EFAA  6e 04
.LF8EFAC:
	bit 6,(XIX)                                   ; F8EFAC  b4 ce
	jr nz, .LF8EFAC                               ; F8EFAE  6e fc
.LF8EFB0:
	ld (XIX),A                                    ; F8EFB0  b4 41
	bit	0, (0xc6:8)                            ; F8EFB2  f0 c6 c8
	jr nz, .LF8EFBB                               ; F8EFB5  6e 04
.LF8EFB7:
	bit 6,(XIX)                                   ; F8EFB7  b4 ce
	jr nz, .LF8EFB7                               ; F8EFB9  6e fc
.LF8EFBB:
	ld (XIX),W                                    ; F8EFBB  b4 40
	inc 1,WA                                      ; F8EFBD  d8 61
	ld (LCD_RunAddress:16), wa                           ; F8EFBF  f1 5a 25 50
	bit	0, (0xc6:8)                            ; F8EFC3  f0 c6 c8
	jr nz, .LF8EFCC                               ; F8EFC6  6e 04
.LF8EFC8:
	bit 6,(XIX)                                   ; F8EFC8  b4 ce
	jr nz, .LF8EFC8                               ; F8EFCA  6e fc
.LF8EFCC:
	ld (XIX+0x01),0x42                            ; F8EFCC  bc 01 00 42
	pushw bc                                      ; F8EFD0  29
	ld bc, (LCD_Y1:16)                          ; F8EFD1  d1 36 25 21
	sub	bc, (LCD_Y0:16)                       ; F8EFD5  d1 32 25 a1
	inc 1,BC                                      ; F8EFD9  d9 61
LCD_Svc_05__fullrow:
	bit	0, (0xc6:8)                            ; F8EFDB  f0 c6 c8
	jr nz, .LF8EFE4                               ; F8EFDE  6e 04
.LF8EFE0:
	bit 6,(XIX)                                   ; F8EFE0  b4 ce
	jr nz, .LF8EFE0                               ; F8EFE2  6e fc
.LF8EFE4:
	ld (XIX),0xff                                 ; F8EFE4  b4 00 ff   a whole byte of pixels
	djnz16 bc, LCD_Svc_05__fullrow                           ; F8EFE7  d9 1c f1
	popw bc                                       ; F8EFEA  49
	djnz16 bc, LCD_Svc_05__fullcol                           ; F8EFEB  d9 1c a8
; --- the partial LAST column, if the box does not end on a byte boundary -----
LCD_Svc_05__rightedge:
	and DE,DE                                     ; F8EFEE  da c2
	jr z, LCD_Svc_05__ret                                ; F8EFF0  66 46
	bit	0, (0xc6:8)                            ; F8EFF2  f0 c6 c8
	jr nz, .LF8EFFB                               ; F8EFF5  6e 04
.LF8EFF7:
	bit 6,(XIX)                                   ; F8EFF7  b4 ce
	jr nz, .LF8EFF7                               ; F8EFF9  6e fc

.LF8EFFB:
	ld (XIX+0x01),0x46                            ; F8EFFB  bc 01 00 46
	ld wa, (LCD_RunAddress:16)                          ; F8EFFF  d1 5a 25 20
	bit	0, (0xc6:8)                            ; F8F003  f0 c6 c8
	jr nz, .LF8F00C                               ; F8F006  6e 04
.LF8F008:
	bit 6,(XIX)                                   ; F8F008  b4 ce
	jr nz, .LF8F008                               ; F8F00A  6e fc
.LF8F00C:
	ld (XIX),A                                    ; F8F00C  b4 41
	bit	0, (0xc6:8)                            ; F8F00E  f0 c6 c8
	jr nz, .LF8F017                               ; F8F011  6e 04
.LF8F013:
	bit 6,(XIX)                                   ; F8F013  b4 ce
	jr nz, .LF8F013                               ; F8F015  6e fc
.LF8F017:
	ld (XIX),W                                    ; F8F017  b4 40
	calr LCD_Rect_RightEdgeMask                    ; F8F019  1e 88 07   LCD_Rect_RightEdgeMask -> A
	ld (XIX+0x01),0x42                            ; F8F01C  bc 01 00 42
	ld bc, (LCD_Y1:16)                          ; F8F020  d1 36 25 21
	sub	bc, (LCD_Y0:16)                       ; F8F024  d1 32 25 a1
	inc 1,BC                                      ; F8F028  d9 61
LCD_Svc_05__rightrow:
	bit	0, (0xc6:8)                            ; F8F02A  f0 c6 c8
	jr nz, .LF8F033                               ; F8F02D  6e 04
.LF8F02F:
	bit 6,(XIX)                                   ; F8F02F  b4 ce
	jr nz, .LF8F02F                               ; F8F031  6e fc
.LF8F033:
	ld (XIX),A                                    ; F8F033  b4 41
	djnz16 bc, LCD_Svc_05__rightrow                           ; F8F035  d9 1c f2
LCD_Svc_05__ret:
	ret                                           ; F8F038  0e

; ==============================================================================
; 0xF8F039-0xF8F3A3 -- SWI7's TEXT SERVICES: ten fonts and three glyph blitters
; ==============================================================================
;
; ★ TEN OF THE THIRTY-FOUR SWI7 SERVICES ARE THE SAME ROUTINE WITH A DIFFERENT
;   FONT.  Each one is 0x32-0x35 bytes long and does exactly this:
;
;       if BC == 0: return
;       LCD_SelectCurrentLayer                   ; (0x2555) := the layer base
;       IX += (0x2555)                           ; the caller's offset -> absolute
;       IZ = HL * BC                             ; the offset of the first code
;       repeat BC times:
;           A = (XIY + IZ)                       ; the character code
;           XIY' = <font base> + A * <bytes per glyph>
;           blit <bytes per glyph> bytes at IX
;           XIY++;  IX++                         ; next code, next byte-column
;
;   Only three things vary between the ten: the FONT BASE, the BYTES PER GLYPH,
;   and which of the two blitters is called.  That is what makes them one family
;   and what lets a single argument convention be stated once:
;
;       IX   byte offset of the top-left corner WITHIN the current layer
;       BC   number of characters
;       HL   a stride added to the source pointer as HL*BC before the first read
;       XIY  the string
;
; ★★ AND THEY REALLY ARE FONTS -- this is not inferred from the code shape, it
;   is visible.  `python3 notes/render_font.py <base> <bytes> [--width 16]
;   --art 0x41` draws the glyph, and five of the ten tables render legible
;   capital A at code 0x41.  The sharper test is `--ascii-check`, which asks
;   whether code 0x20 is blank and every code 0x21-0x7E is not:
;
;   | svc | font base | bytes | w x h | blitter | ASCII test |
;   |-----|-----------|------:|-------|---------|------------|
;   | 0x06 | 0xF1B400 | 14 |  8 x 14 | LCD_BlitGlyph8           | PASSES |
;   | 0x20 | 0xF24DC0 | 10 |  8 x 10 | LCD_BlitGlyph8           | PASSES |
;   | 0x16 | 0xF212B0 | 14 |  8 x 14 | LCD_BlitGlyph8           | fails  |
;   | 0x07 | 0xF1BEF0 | 16 |  8 x 16 | LCD_BlitGlyph8_ExtraWait | PASSES |
;   | 0x08 | 0xF1CB70 | 32 | 16 x 16 | LCD_BlitGlyph16          | PASSES |
;   | 0x21 | 0xF25590 | 48 | 16 x 24 | LCD_BlitGlyph16          | PASSES |
;   | 0x1A | 0xF22840 | 32 | 16 x 16 | LCD_BlitGlyph16          | fails  |
;   | 0x1F | 0xF24640 | 32 | 16 x 16 | LCD_BlitGlyph16          | fails  |
;   | 0x19 | 0xF21940 | 32 | 16 x 16 | LCD_BlitGlyph16          | fails  |
;   | 0x1D | 0xF203B0 | 32 | 16 x 16 | LCD_BlitGlyph16          | fails  |
;
;   The five that PASS are 8x10, 8x14, 8x16, 16x16 and 16x24 ASCII fonts: one
;   blank glyph (0x20, the space) and 94 drawn ones, at every printable code.
;   ⚠ The five that FAIL are NOT ASCII and are NOT named here.  Their glyphs are
;   stroke shapes -- 0xF22840's code 0x41 is a single horizontal bar, 0xF21940's
;   is a two-stroke figure -- which look Japanese, but nothing in this firmware
;   says what encoding indexes them.  "Symbols" below means "not ASCII", nothing
;   more.
;
;   Every font lives in PROM_B; the bases run from 0xF1B400 to 0xF25590 and six
;   of the ten are in bank 0xF2, which notes/FINDINGS-prom_b-thunk-table.md
;   records as having no thunk targets.  Both are true: nothing CALLS into that
;   bank, and these tables are read as DATA by an immediate load here.
;
; THE WIDTH IS READ OFF THE BLITTER, not guessed.  LCD_BlitGlyph8 writes the
; glyph's bytes consecutively down one byte-column with CSRDIR DOWN, so a glyph
; is 8 pixels wide and <bytes> rows tall.  LCD_BlitGlyph16 writes the EVEN bytes
; down one column (`inc 2,IZ`), steps the cursor one byte right, and writes the
; ODD bytes down the next -- 16 pixels wide, two bytes per row, <bytes>/2 rows.
; Rendering the 16-wide tables with that layout is what produces the legible A.

; ---------------------------------------------------------------------
; LCD_Svc_06_DrawText8x14 -- SWI7 service 0x06: draw a string in the 8x14 font
;
; Called from: SWI7_ServiceTable slot 0x06 (0xF8E9DE)
; Inputs:  IX, BC, HL, XIY as in the block header
; Outputs: BC glyphs drawn; XIY and IX advanced past them; WA, HL, IZ, A
;          clobbered.
; Evidence: font 0xF1B400, 14 bytes per glyph, 8 wide -- and that table passes
;          notes/render_font.py's ASCII test (blank only at 0x20).
; HL:      a ROW NUMBER in a table of BC-character strings at XIY.  IZ := HL * BC
;          once, before the loop, and every character is read as `ld A,(XIY+IZ)`
;          (0xF8F04A), so the string drawn is the one at XIY + HL*BC.  Call sites
;          that pass HL /= 0 use exactly that: StepRecord_DrawNibbleAsStars
;          (BC = 4, HL = a nibble, XIY = sixteen 4-character rows),
;          SysexProgressBar_FillCells (svc 0x07, BC = 1, HL = 1: the second byte of
;          Chars_F0D99A), LCD_DrawVar272ENumberTag_SaveRegs (BC = 4, HL = its
;          argument).  The other text services share this prologue.  Census:
;          notes/open4-f-probes/swi7_text_hl.py.
; ---------------------------------------------------------------------
LCD_Svc_06_DrawText8x14:
	and BC,BC                                     ; F8F039  d9 c1
	jr z, .LF8F06D                                ; F8F03B  66 30
	calr LCD_SelectCurrentLayer                   ; F8F03D  1e 53 fe   LCD_SelectCurrentLayer
	add	ix, (LCD_CurrentLayerBase:16)                       ; F8F040  d1 55 25 84
	ld WA,HL                                      ; F8F044  db 88
	mul xwa, bc                                  ; F8F046  d9 40
	ld IZ,WA                                      ; F8F048  d8 8e
.LF8F04A:
	ld	a, (xiy+iz)                           ; F8F04A  c3 07 f4 f8 21
	ld w, 0x0e:opc                                   ; F8F04F  20 0e
	mul wa, w                                   ; F8F051  c8 41
	xor XHL,XHL                                   ; F8F053  eb d3
	ld HL,WA                                      ; F8F055  d8 8b
	push XIY                                      ; F8F057  3d
	ld XIY,Font_Svc06_8x14                        ; F8F058  45 00 b4 f1 00
	add XIY,XHL                                   ; F8F05D  eb 85
	ldw de, 0x0e                                  ; F8F05F  32 0e 00
	calr LCD_BlitGlyph8                                 ; F8F062  1e 73 00
	pop XIY                                       ; F8F065  5d
	inc 1,XIY                                     ; F8F066  ed 61
	inc 1,IX                                      ; F8F068  dc 61
	djnz16 bc, .LF8F04A                           ; F8F06A  d9 1c dd
.LF8F06D:
	ret                                           ; F8F06D  0e

; ---------------------------------------------------------------------
; LCD_Svc_20_DrawText8x10 -- SWI7 service 0x20: the 8x10 font
;
; Called from: SWI7_ServiceTable slot 0x20 (0xF8EA46)
; Inputs/Outputs: as LCD_Svc_06_DrawText8x14
; Evidence: font 0xF24DC0, 10 bytes per glyph, 8 wide; passes the ASCII test.
;          Apart from those two constants it is the same routine as service 0x06.
; Unknown:  as service 0x06.
; ---------------------------------------------------------------------
LCD_Svc_20_DrawText8x10:
	and BC,BC                                     ; F8F06E  d9 c1
	jr z, .LF8F0A2                                ; F8F070  66 30
	calr LCD_SelectCurrentLayer                   ; F8F072  1e 1e fe   LCD_SelectCurrentLayer
	add	ix, (LCD_CurrentLayerBase:16)                       ; F8F075  d1 55 25 84
	ld WA,HL                                      ; F8F079  db 88
	mul xwa, bc                                  ; F8F07B  d9 40
	ld IZ,WA                                      ; F8F07D  d8 8e
.LF8F07F:
	ld	a, (xiy+iz)                           ; F8F07F  c3 07 f4 f8 21
	ld w, 0x0a:opc                                   ; F8F084  20 0a
	mul wa, w                                   ; F8F086  c8 41
	xor XHL,XHL                                   ; F8F088  eb d3
	ld HL,WA                                      ; F8F08A  d8 8b
	push XIY                                      ; F8F08C  3d
	ld XIY,Font_Svc20_8x10                        ; F8F08D  45 c0 4d f2 00
	add XIY,XHL                                   ; F8F092  eb 85
	ldw de, 0x0a                                  ; F8F094  32 0a 00
	calr LCD_BlitGlyph8                                 ; F8F097  1e 3e 00
	pop XIY                                       ; F8F09A  5d
	inc 1,XIY                                     ; F8F09B  ed 61
	inc 1,IX                                      ; F8F09D  dc 61
	djnz16 bc, .LF8F07F                           ; F8F09F  d9 1c dd
.LF8F0A2:
	ret                                           ; F8F0A2  0e

; ---------------------------------------------------------------------
; LCD_Svc_16_DrawKatakanaHalfWidth -- SWI7 service 0x16: a string in the
; half-width KATAKANA face, 8 x 14
;
; Called from: SWI7_ServiceTable slot 0x16 (0xF8EA1E)
; Inputs/Outputs: as LCD_Svc_06_DrawText8x14
; Evidence: font base 0xF212B0 (the immediate at 0xF8F0C2), 14 bytes per glyph
;          (`ldw de,0x0e` at 0xF8F0C9), 8 wide (it calls LCD_BlitGlyph8).
;          The table holds exactly 120 cells, and that is arithmetic rather
;          than inspection: the next face begins at 0xF21940 and
;          0xF21940 - 0xF212B0 = 1680 = 120 x 14 exactly, so the tables abut
;          with no padding.  Two blocks of those 120 are defined:
;            0x0F-0x16  eight marks and punctuation.  0x0F is two ticks and
;                       0x10 a small ring at the TOP of the cell -- the voiced
;                       and semi-voiced sound marks, which a half-width face
;                       must carry as separate characters because it has no
;                       room to compose them.  0x11 is the same ring at the
;                       BOTTOM (the full stop) and 0x12 a tick there (the
;                       comma); 0x13 and 0x14 are the two corner brackets;
;                       0x16 is the middle dot.  0x15 is not identified.
;            0x21-0x58  fifty-six kana: the 46 gojuon in dictionary order from
;                       0x21, then the 9 small kana, then the prolonged sound
;                       mark.  46 + 9 + 1 = 56.
;          ★ The LAST cell of that block is the check worth quoting.  Code
;          0x58 is `00 00 00 00 00 7f 00 00 00 00 00 00 00 00` -- one
;          horizontal bar and nothing else, which is the prolonged sound mark,
;          exactly what the reading predicts at the END of the range.
;          Re-derive every number here with
;          `python3 notes/font_layout_check.py`, and look at the glyphs with
;          `python3 notes/font_sheet.py 0xF212B0 14 --range 0x21-0x30`.
;          Written up in notes/FINDINGS-fonts.md.
; Unknown:  ⚠ the ENCODING is private.  The repertoire is JIS X 0201's
;          half-width katakana, but the code points are NOT: JIS puts the wo
;          and the nine small kana BEFORE the gojuon, at 0xA6-0xAF, whereas
;          this face puts the wo inside the gojuon at 0x4D and the small kana
;          after it.  Nothing found so far says what maps a text byte onto
;          these codes.  ⚠ And no caller is traced.
; ---------------------------------------------------------------------
LCD_Svc_16_DrawKatakanaHalfWidth:
	and BC,BC                                     ; F8F0A3  d9 c1
	jr z, .LF8F0D7                                ; F8F0A5  66 30
	calr LCD_SelectCurrentLayer                   ; F8F0A7  1e e9 fd   LCD_SelectCurrentLayer
	add	ix, (LCD_CurrentLayerBase:16)                       ; F8F0AA  d1 55 25 84
	ld WA,HL                                      ; F8F0AE  db 88
	mul xwa, bc                                  ; F8F0B0  d9 40
	ld IZ,WA                                      ; F8F0B2  d8 8e
.LF8F0B4:
	ld	a, (xiy+iz)                           ; F8F0B4  c3 07 f4 f8 21
	ld w, 0x0e:opc                                   ; F8F0B9  20 0e
	mul wa, w                                   ; F8F0BB  c8 41
	xor XHL,XHL                                   ; F8F0BD  eb d3
	ld HL,WA                                      ; F8F0BF  d8 8b
	push XIY                                      ; F8F0C1  3d
	ld XIY,Font_Svc16_8x14                        ; F8F0C2  45 b0 12 f2 00
	add XIY,XHL                                   ; F8F0C7  eb 85
	ldw de, 0x0e                                  ; F8F0C9  32 0e 00
	calr LCD_BlitGlyph8                                 ; F8F0CC  1e 09 00
	pop XIY                                       ; F8F0CF  5d
	inc 1,XIY                                     ; F8F0D0  ed 61
	inc 1,IX                                      ; F8F0D2  dc 61
	djnz16 bc, .LF8F0B4                           ; F8F0D4  d9 1c dd
.LF8F0D7:
	ret                                           ; F8F0D7  0e
; ---------------------------------------------------------------------
; LCD_BlitGlyph8 -- write one 8-pixel-wide glyph down a byte-column
;
; Called from: services 0x06 (0xF8F062), 0x20 (0xF8F097) and 0x16 (0xF8F0CC)
; Inputs:  IX = the display-RAM address, DE = bytes in the glyph, XIY = the glyph
; Outputs: the glyph drawn; IZ saved and restored; WA, A clobbered.
; Evidence: CSRDIR DOWN (0x4F), CSRW with IX, MWRITE, then DE bytes read from
;          (XIY+IZ) with IZ stepping by ONE.  With the cursor advancing downward,
;          consecutive bytes are consecutive rows of the same 8-pixel column --
;          which is what "8 wide, one byte per row" means.
; Unknown:  nothing outstanding.
; ---------------------------------------------------------------------
LCD_BlitGlyph8:
	pushw iz                                      ; F8F0D8  2e
	ld XHL,0x00790000                             ; F8F0D9  43 00 00 79 00
	ld (XHL+0x01),0x4f                            ; F8F0DE  bb 01 00 4f
	bit	0, (0xc6:8)                            ; F8F0E2  f0 c6 c8
	jr nz, .LF8F0EB                               ; F8F0E5  6e 04
.LF8F0E7:
	bit 6,(XHL)                                   ; F8F0E7  b3 ce
	jr nz, .LF8F0E7                               ; F8F0E9  6e fc
.LF8F0EB:
	ld (XHL+0x01),0x46                            ; F8F0EB  bb 01 00 46
	ld WA,IX                                      ; F8F0EF  dc 88
	bit	0, (0xc6:8)                            ; F8F0F1  f0 c6 c8
	jr nz, .LF8F0FA                               ; F8F0F4  6e 04
.LF8F0F6:
	bit 6,(XHL)                                   ; F8F0F6  b3 ce
	jr nz, .LF8F0F6                               ; F8F0F8  6e fc
.LF8F0FA:
	ld (XHL),A                                    ; F8F0FA  b3 41
	bit	0, (0xc6:8)                            ; F8F0FC  f0 c6 c8
	jr nz, .LF8F105                               ; F8F0FF  6e 04
.LF8F101:
	bit 6,(XHL)                                   ; F8F101  b3 ce
	jr nz, .LF8F101                               ; F8F103  6e fc
.LF8F105:
	ld (XHL),W                                    ; F8F105  b3 40
	bit	0, (0xc6:8)                            ; F8F107  f0 c6 c8
	jr nz, .LF8F110                               ; F8F10A  6e 04
.LF8F10C:
	bit 6,(XHL)                                   ; F8F10C  b3 ce
	jr nz, .LF8F10C                               ; F8F10E  6e fc
.LF8F110:
	ld (XHL+0x01),0x42                            ; F8F110  bb 01 00 42
	xor IZ,IZ                                     ; F8F114  de d6
.LF8F116:
	cp IZ,DE                                      ; F8F116  da f6
	jr nc, .LF8F12E                               ; F8F118  6f 14
	ld	a, (xiy+iz)                           ; F8F11A  c3 07 f4 f8 21
	inc 1,IZ                                      ; F8F11F  de 61
	bit	0, (0xc6:8)                            ; F8F121  f0 c6 c8
	jr nz, .LF8F12A                               ; F8F124  6e 04
.LF8F126:
	bit 6,(XHL)                                   ; F8F126  b3 ce
	jr nz, .LF8F126                               ; F8F128  6e fc
.LF8F12A:
	ld (XHL),A                                    ; F8F12A  b3 41
	jr .LF8F116                                   ; F8F12C  68 e8
.LF8F12E:
	popw iz                                       ; F8F12E  4e
	ret                                           ; F8F12F  0e

; ---------------------------------------------------------------------
; LCD_Svc_07_DrawText8x16 -- SWI7 service 0x07: the 8x16 font
;
; Called from: SWI7_ServiceTable slot 0x07 (0xF8E9E2)
; Inputs/Outputs: as LCD_Svc_06_DrawText8x14
; Evidence: font 0xF1BEF0, 16 bytes per glyph, 8 wide; passes the ASCII test.
;          It scales the code with `sla 0x04,HL` rather than `mul WA,W`, because
;          16 is a power of two -- the only structural difference.
; Unknown:  as service 0x06.
; ---------------------------------------------------------------------
LCD_Svc_07_DrawText8x16:
	and BC,BC                                     ; F8F130  d9 c1
	jr z, .LF8F161                                ; F8F132  66 2d
	calr LCD_SelectCurrentLayer                   ; F8F134  1e 5c fd   LCD_SelectCurrentLayer
	add	ix, (LCD_CurrentLayerBase:16)                       ; F8F137  d1 55 25 84
	ld WA,HL                                      ; F8F13B  db 88
	mul xwa, bc                                  ; F8F13D  d9 40
	ld IZ,WA                                      ; F8F13F  d8 8e
.LF8F141:
	xor XHL,XHL                                   ; F8F141  eb d3
	ld	l, (xiy+iz)                           ; F8F143  c3 07 f4 f8 27
	sla hl, 0x04                                  ; F8F148  db ec 04
	push XIY                                      ; F8F14B  3d
	ld XIY,Font_Svc07_8x16                        ; F8F14C  45 f0 be f1 00
	add XIY,XHL                                   ; F8F151  eb 85
	ldw de, 0x10                                  ; F8F153  32 10 00
	calr LCD_BlitGlyph8_ExtraWait                                 ; F8F156  1e 09 00
	pop XIY                                       ; F8F159  5d
	inc 1,XIY                                     ; F8F15A  ed 61
	inc 1,IX                                      ; F8F15C  dc 61
	djnz16 bc, .LF8F141                           ; F8F15E  d9 1c e0
.LF8F161:
	ret                                           ; F8F161  0e
; ---------------------------------------------------------------------
; LCD_BlitGlyph8_ExtraWait -- LCD_BlitGlyph8 with one more BUSY poll
;
; Called from: service 0x07 only (0xF8F156)
; Inputs/Outputs: identical to LCD_BlitGlyph8
; Evidence: ★ the two routines are BYTE-IDENTICAL apart from a single inserted
;          nine-byte busy poll.  Checked, not eyeballed: the first six bytes of
;          each are equal; bytes 6..14 of this one are exactly the poll sequence
;          `f0 c6 c8 6e 04 b3 ce 6e fc`; and bytes 6.. of LCD_BlitGlyph8 equal
;          bytes 15.. of this one, all 82 of them.  88 bytes versus 97.
; Unknown:  why service 0x07 needs the extra wait before CSRDIR and the other
;          three do not.  Nothing here says whether that is a fix or an accident.
; ---------------------------------------------------------------------
LCD_BlitGlyph8_ExtraWait:
	pushw iz                                      ; F8F162  2e
	ld XHL,0x00790000                             ; F8F163  43 00 00 79 00
	bit	0, (0xc6:8)                            ; F8F168  f0 c6 c8
	jr nz, .LF8F171                               ; F8F16B  6e 04
.LF8F16D:
	bit 6,(XHL)                                   ; F8F16D  b3 ce
	jr nz, .LF8F16D                               ; F8F16F  6e fc
.LF8F171:
	ld (XHL+0x01),0x4f                            ; F8F171  bb 01 00 4f
	bit	0, (0xc6:8)                            ; F8F175  f0 c6 c8
	jr nz, .LF8F17E                               ; F8F178  6e 04
.LF8F17A:
	bit 6,(XHL)                                   ; F8F17A  b3 ce
	jr nz, .LF8F17A                               ; F8F17C  6e fc
.LF8F17E:
	ld (XHL+0x01),0x46                            ; F8F17E  bb 01 00 46
	ld WA,IX                                      ; F8F182  dc 88
	bit	0, (0xc6:8)                            ; F8F184  f0 c6 c8
	jr nz, .LF8F18D                               ; F8F187  6e 04
.LF8F189:
	bit 6,(XHL)                                   ; F8F189  b3 ce
	jr nz, .LF8F189                               ; F8F18B  6e fc
.LF8F18D:
	ld (XHL),A                                    ; F8F18D  b3 41
	bit	0, (0xc6:8)                            ; F8F18F  f0 c6 c8
	jr nz, .LF8F198                               ; F8F192  6e 04
.LF8F194:
	bit 6,(XHL)                                   ; F8F194  b3 ce
	jr nz, .LF8F194                               ; F8F196  6e fc
.LF8F198:
	ld (XHL),W                                    ; F8F198  b3 40
	bit	0, (0xc6:8)                            ; F8F19A  f0 c6 c8
	jr nz, .LF8F1A3                               ; F8F19D  6e 04
.LF8F19F:
	bit 6,(XHL)                                   ; F8F19F  b3 ce
	jr nz, .LF8F19F                               ; F8F1A1  6e fc
.LF8F1A3:
	ld (XHL+0x01),0x42                            ; F8F1A3  bb 01 00 42
	xor IZ,IZ                                     ; F8F1A7  de d6
.LF8F1A9:
	cp IZ,DE                                      ; F8F1A9  da f6
	jr nc, .LF8F1C1                               ; F8F1AB  6f 14
	ld	a, (xiy+iz)                           ; F8F1AD  c3 07 f4 f8 21
	inc 1,IZ                                      ; F8F1B2  de 61
	bit	0, (0xc6:8)                            ; F8F1B4  f0 c6 c8
	jr nz, .LF8F1BD                               ; F8F1B7  6e 04
.LF8F1B9:
	bit 6,(XHL)                                   ; F8F1B9  b3 ce
	jr nz, .LF8F1B9                               ; F8F1BB  6e fc
.LF8F1BD:
	ld (XHL),A                                    ; F8F1BD  b3 41
	jr .LF8F1A9                                   ; F8F1BF  68 e8
.LF8F1C1:
	popw iz                                       ; F8F1C1  4e
	ret                                           ; F8F1C2  0e

; ---------------------------------------------------------------------
; LCD_Svc_08_DrawText16x16 -- SWI7 service 0x08: the 16x16 font
;
; Called from: SWI7_ServiceTable slot 0x08 (0xF8E9E6)
; Inputs/Outputs: as LCD_Svc_06_DrawText8x14, but each glyph occupies TWO
;          byte-columns, so IX advances by two per character -- once here and
;          once inside LCD_BlitGlyph16.
; Evidence: font 0xF1CB70, 32 bytes per glyph, 16 wide; passes the ASCII test
;          when rendered two bytes per row.
; Unknown:  as service 0x06.
; ---------------------------------------------------------------------
LCD_Svc_08_DrawText16x16:
	and BC,BC                                     ; F8F1C3  d9 c1
	jr z, .LF8F1F6                                ; F8F1C5  66 2f
	calr LCD_SelectCurrentLayer                   ; F8F1C7  1e c9 fc   LCD_SelectCurrentLayer
	add	ix, (LCD_CurrentLayerBase:16)                       ; F8F1CA  d1 55 25 84
	ld WA,HL                                      ; F8F1CE  db 88
	mul xwa, bc                                  ; F8F1D0  d9 40
	ld IZ,WA                                      ; F8F1D2  d8 8e
.LF8F1D4:
	xor XHL,XHL                                   ; F8F1D4  eb d3
	ld	l, (xiy+iz)                           ; F8F1D6  c3 07 f4 f8 27
	sla hl, 0x05                                  ; F8F1DB  db ec 05
	push XIY                                      ; F8F1DE  3d
	ld XIY,Font_Svc08_16x16                       ; F8F1DF  45 70 cb f1 00
	extz XHL                                      ; F8F1E4  eb 12
	add XIY,XHL                                   ; F8F1E6  eb 85
	ldw de, 0x20                                  ; F8F1E8  32 20 00
	calr LCD_BlitGlyph16                                 ; F8F1EB  1e 03 01
	pop XIY                                       ; F8F1EE  5d
	inc 1,XIY                                     ; F8F1EF  ed 61
	inc 1,IX                                      ; F8F1F1  dc 61
	djnz16 bc, .LF8F1D4                           ; F8F1F3  d9 1c de
.LF8F1F6:
	ret                                           ; F8F1F6  0e

; ---------------------------------------------------------------------
; LCD_Svc_21_DrawText16x24 -- SWI7 service 0x21: the 16x24 font, the largest
;
; Called from: SWI7_ServiceTable slot 0x21 (0xF8EA4A)
; Inputs/Outputs: as LCD_Svc_08_DrawText16x16
; Evidence: font 0xF25590, 48 bytes per glyph (`mul L,0x30`), 16 wide; passes
;          the ASCII test.  24 rows is the tallest glyph in the machine.
; Unknown:  as service 0x06.
; ---------------------------------------------------------------------
LCD_Svc_21_DrawText16x24:
	and BC,BC                                     ; F8F1F7  d9 c1
	jr z, .LF8F228                                ; F8F1F9  66 2d
	calr LCD_SelectCurrentLayer                   ; F8F1FB  1e 95 fc   LCD_SelectCurrentLayer
	add	ix, (LCD_CurrentLayerBase:16)                       ; F8F1FE  d1 55 25 84
	ld WA,HL                                      ; F8F202  db 88
	mul xwa, bc                                  ; F8F204  d9 40
	ld IZ,WA                                      ; F8F206  d8 8e
.LF8F208:
	xor XHL,XHL                                   ; F8F208  eb d3
	ld	l, (xiy+iz)                           ; F8F20A  c3 07 f4 f8 27
	mul L,0x30                                    ; F8F20F  cf 08 30
	push XIY                                      ; F8F212  3d
	ld XIY,Font_Svc21_16x24                       ; F8F213  45 90 55 f2 00
	add XIY,XHL                                   ; F8F218  eb 85
	ldw de, 0x30                                  ; F8F21A  32 30 00
	calr LCD_BlitGlyph16                                 ; F8F21D  1e d1 00
	pop XIY                                       ; F8F220  5d
	inc 1,XIY                                     ; F8F221  ed 61
	inc 1,IX                                      ; F8F223  dc 61
	djnz16 bc, .LF8F208                           ; F8F225  d9 1c e0
.LF8F228:
	ret                                           ; F8F228  0e

; ---------------------------------------------------------------------
; LCD_Svc_1A_DrawKanjiSetA16x16 -- SWI7 service 0x1A: a string in the LARGE
; KANJI face, 16 x 16
;
; Called from: SWI7_ServiceTable slot 0x1A (0xF8EA2E)
; Inputs/Outputs: as LCD_Svc_08_DrawText16x16
; Evidence: font base 0xF22840 (immediate at 0xF8F245), 32 bytes per glyph,
;          16 wide.  ★ This table's length is PROVED, not padded-into:
;          0xF22840 + 0xF0 * 32 = 0xF24640, which is the base of the next face
;          exactly, so the table is 240 cells and there is no room for a 241st.
;          Of those, codes 0x10-0xEF -- all 224 -- are defined, with no blank
;          cell anywhere in the run.  The glyphs are multi-stroke CJK
;          ideographs: see them with
;          `python3 notes/font_sheet.py 0xF22840 32 --width 16 --range 0x10-0x17`
;          (code 0x12 is a triangular roof over a bar over a box, i.e. the
;          character read GOU/AU).  That reading is corroborated structurally:
;          the same firmware carries a hiragana face (service 0x1D) and a
;          katakana face (service 0x19) at these same 16x16 metrics, so the two
;          remaining 16x16 faces are the ideographs those two scripts need.
;          Counts re-derived by `python3 notes/font_layout_check.py`.
; Unknown:  ⚠ the ENCODING.  224 contiguous codes from 0x10 match no
;          standard Japanese encoding -- not JIS X 0208, which is two bytes,
;          and not Shift-JIS.  This is a PRIVATE SUBSET: the kanji the UI
;          happens to need, numbered in whatever order they were collected.
;          Nothing in prom_a says which ideograph a given code is, and prom_a
;          cannot say -- the mapping lives in whatever built the strings.
;          "Set A" is this disassembly's label for it, not a name the firmware
;          uses.  ⚠ No caller is traced.
; UPDATE 2026-09-02, lane rq-fonts: the encoding is no longer opaque.
;          All 224 ideographs are transcribed in
;          notes/fonts-kanji/kanji_transcription.txt (they cannot be written
;          in this source, which is latin-1), and the ORDER is measured: the
;          codes were assigned by walking Japanese running text and numbering
;          each new ideograph on first use.  72 adjacent code pairs are
;          dictionary words against a shuffle null of 24.8 +/- 4.8 over
;          10,000 permutations of the same characters, 9.9 sd, 0 of 10,000
;          reaching it; distance-2..8 controls sit on the null.
;            python3 scripts/analysis/kanji_order_hypothesis.py
;          The TEXT itself is still missing, and it is not in these four
;          images: scripts/analysis/japanese_text_census.py finds no Japanese
;          kana in any of them, under a test that recovers planted sentences
;          and refuses decoys.  FINDINGS-fonts.md sec.5 and 6.1.
; ---------------------------------------------------------------------
LCD_Svc_1A_DrawKanjiSetA16x16:
	and BC,BC                                     ; F8F229  d9 c1
	jr z, .LF8F25A                                ; F8F22B  66 2d
	calr LCD_SelectCurrentLayer                   ; F8F22D  1e 63 fc   LCD_SelectCurrentLayer
	add	ix, (LCD_CurrentLayerBase:16)                       ; F8F230  d1 55 25 84
	ld WA,HL                                      ; F8F234  db 88
	mul xwa, bc                                  ; F8F236  d9 40
	ld IZ,WA                                      ; F8F238  d8 8e
.LF8F23A:
	xor XHL,XHL                                   ; F8F23A  eb d3
	ld	l, (xiy+iz)                           ; F8F23C  c3 07 f4 f8 27
	sla hl, 0x05                                  ; F8F241  db ec 05
	push XIY                                      ; F8F244  3d
	ld XIY,Font_Svc1A_16x16                       ; F8F245  45 40 28 f2 00
	add XIY,XHL                                   ; F8F24A  eb 85
	ldw de, 0x20                                  ; F8F24C  32 20 00
	calr LCD_BlitGlyph16                                 ; F8F24F  1e 9f 00
	pop XIY                                       ; F8F252  5d
	inc 1,XIY                                     ; F8F253  ed 61
	inc 1,IX                                      ; F8F255  dc 61
	djnz16 bc, .LF8F23A                           ; F8F257  d9 1c e0
.LF8F25A:
	ret                                           ; F8F25A  0e

; ---------------------------------------------------------------------
; LCD_Svc_1F_DrawKanjiSetB16x16 -- SWI7 service 0x1F: a string in the SMALL
; KANJI face, 16 x 16
;
; Called from: SWI7_ServiceTable slot 0x1F (0xF8EA42)
; Inputs/Outputs: as LCD_Svc_08_DrawText16x16
; Evidence: font base 0xF24640 (immediate at 0xF8F277), 32 bytes per glyph,
;          16 wide.  ★ The length is proved by abutment, as for service 0x1A:
;          0xF24640 + 0x3C * 32 = 0xF24DC0, the next face's base exactly, so
;          the table is 60 cells.  43 of them are defined, contiguously,
;          0x10 to 0x3A -- and cell 0x3B, the one blank cell before the next
;          table starts, is the end test.  The glyphs are multi-stroke CJK
;          ideographs at both ends of the range:
;          `python3 notes/font_sheet.py 0xF24640 32 --width 16 --range 0x33-0x3a`
;          shows the last eight, and 0x33 is a box inside a box.
;          Counts re-derived by `python3 notes/font_layout_check.py`.
; Notes:   this face and service 0x1A's share no glyph bitmap at all -- 0 in
;          common out of 43 and 224 -- so they are two DISJOINT ideograph sets,
;          not one set drawn twice.  The same comparison finds 0 shared
;          bitmaps between either of them and any Latin or kana face.
; Unknown:  ⚠ the ENCODING, for the same reason as service 0x1A: 43 contiguous
;          codes from 0x10 are a private subset, and prom_a cannot say which
;          ideograph a code is.  ⚠ Why the firmware keeps TWO disjoint kanji
;          sets rather than one is not established.  "Set B" is this
;          disassembly's label.  ⚠ No caller is traced.
; UPDATE 2026-09-02, lane rq-fonts: all 43 ideographs are transcribed in
;          notes/fonts-kanji/kanji_transcription.txt.  Set B reads like a
;          SECOND BATCH collected after set A was closed -- it is disjoint,
;          and the same ordering test points the same way (6 adjacent pairs
;          are dictionary words against a null of 2.6 +/- 1.5) but at 43
;          cells that is p = 0.04 and not conclusive alone.
;          FINDINGS-fonts.md sec.5.2.
; ---------------------------------------------------------------------
LCD_Svc_1F_DrawKanjiSetB16x16:
	and BC,BC                                     ; F8F25B  d9 c1
	jr z, .LF8F28C                                ; F8F25D  66 2d
	calr LCD_SelectCurrentLayer                   ; F8F25F  1e 31 fc   LCD_SelectCurrentLayer
	add	ix, (LCD_CurrentLayerBase:16)                       ; F8F262  d1 55 25 84
	ld WA,HL                                      ; F8F266  db 88
	mul xwa, bc                                  ; F8F268  d9 40
	ld IZ,WA                                      ; F8F26A  d8 8e
.LF8F26C:
	xor XHL,XHL                                   ; F8F26C  eb d3
	ld	l, (xiy+iz)                           ; F8F26E  c3 07 f4 f8 27
	sla hl, 0x05                                  ; F8F273  db ec 05
	push XIY                                      ; F8F276  3d
	ld XIY,Font_Svc1F_16x16                       ; F8F277  45 40 46 f2 00
	add XIY,XHL                                   ; F8F27C  eb 85
	ldw de, 0x20                                  ; F8F27E  32 20 00
	calr LCD_BlitGlyph16                                 ; F8F281  1e 6d 00
	pop XIY                                       ; F8F284  5d
	inc 1,XIY                                     ; F8F285  ed 61
	inc 1,IX                                      ; F8F287  dc 61
	djnz16 bc, .LF8F26C                           ; F8F289  d9 1c e0
.LF8F28C:
	ret                                           ; F8F28C  0e

; ---------------------------------------------------------------------
; LCD_Svc_19_DrawKatakana16x16 -- SWI7 service 0x19: a string in the KATAKANA
; face, 16 x 16
;
; Called from: SWI7_ServiceTable slot 0x19 (0xF8EA2A)
; Inputs/Outputs: as LCD_Svc_08_DrawText16x16
; Evidence: font base 0xF21940 (immediate at 0xF8F2A9), 32 bytes per glyph,
;          16 wide.  The table is exactly 120 cells (0xF22840 - 0xF21940 =
;          3840 = 120 x 32, abutting the next face), of which 87 are defined,
;          contiguously, 0x10 to 0x66.  It is service 0x1D's HIRAGANA face in
;          the same code space and the same order -- 46 gojuon at 0x10-0x3D,
;          9 small kana, the prolonged sound mark at 0x47, 20 voiced and 5
;          semi-voiced forms, then punctuation -- with ONE extra cell at 0x66,
;          a small filled diamond, which the hiragana face leaves blank.
;          86 + 1 = 87.
;          See LCD_Svc_1D_DrawHiragana16x16's header for the six-code
;          cross-check that ties the two faces together, and look at the
;          glyphs with
;          `python3 notes/font_sheet.py 0xF21940 32 --width 16 --range 0x10-0x17`.
;          Counts re-derived by `python3 notes/font_layout_check.py`.
; Unknown:  ⚠ the ENCODING is private.  ⚠ Why the katakana face alone carries
;          the 0x66 diamond is not established.  ⚠ No caller is traced.
; ---------------------------------------------------------------------
LCD_Svc_19_DrawKatakana16x16:
	and BC,BC                                     ; F8F28D  d9 c1
	jr z, .LF8F2BE                                ; F8F28F  66 2d
	calr LCD_SelectCurrentLayer                   ; F8F291  1e ff fb   LCD_SelectCurrentLayer
	add	ix, (LCD_CurrentLayerBase:16)                       ; F8F294  d1 55 25 84

	ld WA,HL                                      ; F8F298  db 88
	mul xwa, bc                                  ; F8F29A  d9 40
	ld IZ,WA                                      ; F8F29C  d8 8e
.LF8F29E:
	xor XHL,XHL                                   ; F8F29E  eb d3
	ld	l, (xiy+iz)                           ; F8F2A0  c3 07 f4 f8 27
	sla hl, 0x05                                  ; F8F2A5  db ec 05
	push XIY                                      ; F8F2A8  3d
	ld XIY,Font_Svc19_16x16                       ; F8F2A9  45 40 19 f2 00
	add XIY,XHL                                   ; F8F2AE  eb 85
	ldw de, 0x20                                  ; F8F2B0  32 20 00
	calr LCD_BlitGlyph16                                 ; F8F2B3  1e 3b 00
	pop XIY                                       ; F8F2B6  5d
	inc 1,XIY                                     ; F8F2B7  ed 61
	inc 1,IX                                      ; F8F2B9  dc 61
	djnz16 bc, .LF8F29E                           ; F8F2BB  d9 1c e0
.LF8F2BE:
	ret                                           ; F8F2BE  0e

; ---------------------------------------------------------------------
; LCD_Svc_1D_DrawHiragana16x16 -- SWI7 service 0x1D: a string in the HIRAGANA
; face, 16 x 16
;
; Called from: SWI7_ServiceTable slot 0x1D (0xF8EA3A)
; Inputs/Outputs: as LCD_Svc_08_DrawText16x16
; Evidence: font base 0xF203B0 (immediate at 0xF8F2DB), 32 bytes per glyph,
;          16 wide.  The table is exactly 120 cells -- 0xF212B0 - 0xF203B0 =
;          3840 = 120 x 32, abutting the next face -- of which 86 are defined,
;          contiguously, 0x10 to 0x65.  ★ That 86 is not a bare count: it is
;          the hiragana repertoire added up, and every term lands where the
;          reading says it should.
;            0x10-0x3D   46  the gojuon, A I U E O KA KI ... WA WO N
;            0x3E-0x46    9  the small kana
;            0x47         1  the prolonged sound mark
;            0x48-0x5B   20  the voiced (dakuten) forms, GA GI GU ... BO
;            0x5C-0x60    5  the semi-voiced (handakuten) forms, PA ... PO
;            0x61-0x65    5  full stop, comma, the two corner brackets, wave
;                            dash
;          46 + 9 + 1 + 20 + 5 + 5 = 86.
;          ★ THE CROSS-CHECK.  Service 0x19's katakana face uses the SAME code
;          space, and six of its cells hold bitmaps byte-identical to this
;          one's: 0x47 and 0x61-0x65 -- precisely the six characters in the
;          table above that belong to neither script.  Every other code the two
;          faces both define differs.  notes/font_layout_check.py finds those
;          six by comparing bitmaps, knowing nothing about kana, and asserts it
;          got exactly that set; the layout above predicts them from the
;          repertoire alone.  Two independent routes, same six codes.
;          Look at the glyphs with
;          `python3 notes/font_sheet.py 0xF203B0 32 --width 16 --range 0x10-0x17`.
; Unknown:  ⚠ the ENCODING is private: the order is the Japanese dictionary
;          order but the code points are nobody's standard.  ⚠ No caller is
;          traced, so nothing here says which script the UI uses when.
; ---------------------------------------------------------------------
LCD_Svc_1D_DrawHiragana16x16:
	and BC,BC                                     ; F8F2BF  d9 c1
	jr z, .LF8F2F0                                ; F8F2C1  66 2d
	calr LCD_SelectCurrentLayer                   ; F8F2C3  1e cd fb   LCD_SelectCurrentLayer
	add	ix, (LCD_CurrentLayerBase:16)                       ; F8F2C6  d1 55 25 84
	ld WA,HL                                      ; F8F2CA  db 88
	mul xwa, bc                                  ; F8F2CC  d9 40
	ld IZ,WA                                      ; F8F2CE  d8 8e
.LF8F2D0:
	xor XHL,XHL                                   ; F8F2D0  eb d3
	ld	l, (xiy+iz)                           ; F8F2D2  c3 07 f4 f8 27
	sla hl, 0x05                                  ; F8F2D7  db ec 05
	push XIY                                      ; F8F2DA  3d
	ld XIY,Font_Svc1D_16x16                       ; F8F2DB  45 b0 03 f2 00
	add XIY,XHL                                   ; F8F2E0  eb 85
	ldw de, 0x20                                  ; F8F2E2  32 20 00
	calr LCD_BlitGlyph16                                 ; F8F2E5  1e 09 00
	pop XIY                                       ; F8F2E8  5d
	inc 1,XIY                                     ; F8F2E9  ed 61
	inc 1,IX                                      ; F8F2EB  dc 61
	djnz16 bc, .LF8F2D0                           ; F8F2ED  d9 1c e0
.LF8F2F0:
	ret                                           ; F8F2F0  0e
; ---------------------------------------------------------------------
; LCD_BlitGlyph16 -- write one 16-pixel-wide glyph as TWO byte-columns
;
; Called from: services 0x08 (0xF8F1EB), 0x21 (0xF8F21D), 0x1A (0xF8F24F),
;          0x1F (0xF8F281), 0x19 (0xF8F2B3) and 0x1D (0xF8F2E5)
; Inputs:  IX = the display-RAM address of the left column, DE = bytes in the
;          glyph, XIY = the glyph
; Outputs: the glyph drawn, IX left pointing at the RIGHT column (it is
;          incremented once, in the middle); IZ saved and restored.
; Evidence: ★ this is what fixes the 16-wide layout.  The first pass steps IZ by
;          TWO from 0, so it writes bytes 0, 2, 4 ... down one column; then
;          `inc 1,IX`, a fresh CSRW, and the second pass does the same from
;          XIY+1, writing bytes 1, 3, 5 ... down the next column.  Two bytes per
;          row, row-major, left byte first -- and rendering the six tables that
;          way is what makes their glyphs legible.
; Unknown:  nothing outstanding.
; ---------------------------------------------------------------------
LCD_BlitGlyph16:
	pushw iz                                      ; F8F2F1  2e
	ld XHL,0x00790000                             ; F8F2F2  43 00 00 79 00
	bit	0, (0xc6:8)                            ; F8F2F7  f0 c6 c8
	jr nz, .LF8F300                               ; F8F2FA  6e 04
.LF8F2FC:
	bit 6,(XHL)                                   ; F8F2FC  b3 ce
	jr NZ,.LF8F2FC                                ; F8F2FE  6e fc
.LF8F300:
	ld (XHL+0x01),0x4f                            ; F8F300  bb 01 00 4f
	bit	0, (0xc6:8)                            ; F8F304  f0 c6 c8
	jr nz, .LF8F30D                               ; F8F307  6e 04
.LF8F309:
	bit 6,(XHL)                                   ; F8F309  b3 ce
	jr nz, .LF8F309                               ; F8F30B  6e fc
.LF8F30D:
	ld (XHL+0x01),0x46                            ; F8F30D  bb 01 00 46
	ld WA,IX                                      ; F8F311  dc 88
	bit	0, (0xc6:8)                            ; F8F313  f0 c6 c8
	jr nz, .LF8F31C                               ; F8F316  6e 04
.LF8F318:
	bit 6,(XHL)                                   ; F8F318  b3 ce
	jr nz, .LF8F318                               ; F8F31A  6e fc
.LF8F31C:
	ld (XHL),A                                    ; F8F31C  b3 41
	bit	0, (0xc6:8)                            ; F8F31E  f0 c6 c8
	jr nz, .LF8F327                               ; F8F321  6e 04
.LF8F323:
	bit 6,(XHL)                                   ; F8F323  b3 ce
	jr nz, .LF8F323                               ; F8F325  6e fc
.LF8F327:
	ld (XHL),W                                    ; F8F327  b3 40
	bit	0, (0xc6:8)                            ; F8F329  f0 c6 c8
	jr nz, .LF8F332                               ; F8F32C  6e 04
.LF8F32E:
	bit 6,(XHL)                                   ; F8F32E  b3 ce
	jr nz, .LF8F32E                               ; F8F330  6e fc
.LF8F332:
	ld (XHL+0x01),0x42                            ; F8F332  bb 01 00 42
	xor IZ,IZ                                     ; F8F336  de d6
.LF8F338:
	cp IZ,DE                                      ; F8F338  da f6
	jr nc, .LF8F350                               ; F8F33A  6f 14
	ld	a, (xiy+iz)                           ; F8F33C  c3 07 f4 f8 21
	inc 2,IZ                                      ; F8F341  de 62
	bit	0, (0xc6:8)                            ; F8F343  f0 c6 c8
	jr nz, .LF8F34C                               ; F8F346  6e 04
.LF8F348:
	bit 6,(XHL)                                   ; F8F348  b3 ce
	jr nz, .LF8F348                               ; F8F34A  6e fc
.LF8F34C:
	ld (XHL),A                                    ; F8F34C  b3 41
	jr .LF8F338                                   ; F8F34E  68 e8
.LF8F350:
	inc 1,IX                                      ; F8F350  dc 61
	bit	0, (0xc6:8)                            ; F8F352  f0 c6 c8
	jr nz, .LF8F35B                               ; F8F355  6e 04
.LF8F357:
	bit 6,(XHL)                                   ; F8F357  b3 ce
	jr nz, .LF8F357                               ; F8F359  6e fc
.LF8F35B:
	ld (XHL+0x01),0x46                            ; F8F35B  bb 01 00 46
	ld WA,IX                                      ; F8F35F  dc 88
	bit	0, (0xc6:8)                            ; F8F361  f0 c6 c8
	jr nz, .LF8F36A                               ; F8F364  6e 04
.LF8F366:
	bit 6,(XHL)                                   ; F8F366  b3 ce
	jr nz, .LF8F366                               ; F8F368  6e fc
.LF8F36A:
	ld (XHL),A                                    ; F8F36A  b3 41
	bit	0, (0xc6:8)                            ; F8F36C  f0 c6 c8
	jr nz, .LF8F375                               ; F8F36F  6e 04
.LF8F371:
	bit 6,(XHL)                                   ; F8F371  b3 ce
	jr nz, .LF8F371                               ; F8F373  6e fc
.LF8F375:
	ld (XHL),W                                    ; F8F375  b3 40
	bit	0, (0xc6:8)                            ; F8F377  f0 c6 c8
	jr nz, .LF8F380                               ; F8F37A  6e 04
.LF8F37C:
	bit 6,(XHL)                                   ; F8F37C  b3 ce
	jr nz, .LF8F37C                               ; F8F37E  6e fc
.LF8F380:
	ld (XHL+0x01),0x42                            ; F8F380  bb 01 00 42
	xor IZ,IZ                                     ; F8F384  de d6
.LF8F386:
	cp IZ,DE                                      ; F8F386  da f6
	jr nc, .LF8F3A2                               ; F8F388  6f 18
	inc 1,XIY                                     ; F8F38A  ed 61
	ld	a, (xiy+iz)                           ; F8F38C  c3 07 f4 f8 21
	dec 1,XIY                                     ; F8F391  ed 69
	inc 2,IZ                                      ; F8F393  de 62
	bit	0, (0xc6:8)                            ; F8F395  f0 c6 c8
	jr nz, .LF8F39E                               ; F8F398  6e 04
.LF8F39A:
	bit 6,(XHL)                                   ; F8F39A  b3 ce
	jr nz, .LF8F39A                               ; F8F39C  6e fc
.LF8F39E:
	ld (XHL),A                                    ; F8F39E  b3 41
	jr .LF8F386                                   ; F8F3A0  68 e4
.LF8F3A2:
	popw iz                                       ; F8F3A2  4e
	ret                                           ; F8F3A3  0e
; ==============================================================================
; 0xF8F3A4-0xF8F766 -- SWI7's LINE AND BOX SERVICES
; ==============================================================================
;
; Six services that share the same four coordinate words as LCD_Svc_00_DrawLine
; -- (0x2530),(0x2532) = (X0,Y0) and (0x2534),(0x2536) = (X1,Y1) -- and build on each
; other:
;
;   0x01  a HORIZONTAL run of pixels, solid           (0xF8F528)
;   0x02  a VERTICAL run of pixels, solid             (0xF8F739)
;   0x09  a rectangle OUTLINE = 0x01 twice + 0x02 twice          (0xF8F3A4)
;   0x0A  0x09 plus a TWO-pixel drop shadow           (0xF8F3E1)
;   0x22  0x09 plus a ONE-pixel drop shadow           (0xF8F4B2)
;   0x13  a rectangle outline built the same way as 0x09 but from services 0x11
;         and 0x12, the PATTERNED line pair            (0xF8F475)
;
; ★ WHY "OUTLINE" AND NOT "FILL".  Service 0x09's whole body is four calls and
;   eight coordinate exchanges: it calls 0x01 with Y0 and Y1 swapped around it,
;   so the horizontal run is drawn once at each Y; then 0x02 with X0 and X1
;   swapped, so the vertical run is drawn once at each X.  Four sides, nothing
;   in between.  (The FILLED rectangle is service 0x05, converted above, and it
;   is a completely different routine.)
;
; ★ WHY "DROP SHADOW".  Services 0x0A and 0x22 both begin by calling 0x09, then
;   save all four coordinates into (0x255C),(0x255E),(0x2560),(0x2562), draw
;   extra horizontal runs BELOW the bottom edge and extra vertical runs to the
;   RIGHT of the right edge, and restore.  0x0A draws two of each and 0x22 one
;   of each -- that is the entire difference between them, and it is visible in
;   the call counts below.  Bottom-and-right only is what a drop shadow is.
;
; ⚠ WHAT IS NOT ESTABLISHED: nothing here traces a CALLER, so which of the two
;   shadow depths the UI uses where is unknown, and "shadow" is a description of
;   the geometry, not of an intent stated anywhere in the ROM.

; ---------------------------------------------------------------------
; LCD_Svc_09_DrawBox -- SWI7 service 0x09: the outline of a rectangle
;
; Called from: SWI7_ServiceTable slot 0x09 (0xF8E9EA); also called directly by
;          services 0x0A (0xF8F3E1) and 0x22 (0xF8F4B2)
; Inputs:  (0x2530),(0x2532),(0x2534),(0x2536) = the two corners
; Outputs: four sides drawn.  ⚠ The four coordinate words are left EXCHANGED
;          BACK to their entry values -- each swap is done twice -- but service
;          0x01 clamps them on the way, so they can come back CHANGED if the
;          caller passed anything outside 320 x 240.  Service 0x02 does not
;          clamp.
; Evidence: `calr 0x01` / swap Y0<->Y1 / `calr 0x01` / swap back, then the same
;          with 0x02 and X0<->X1.  Two horizontal runs at two different Y values
;          and two vertical runs at two different X values is a box outline.
; Unknown:  callers.
; ---------------------------------------------------------------------
LCD_Svc_09_DrawBox:
	calr LCD_Svc_01_DrawHLine                                 ; F8F3A4  1e 81 01
	ld wa, (LCD_Y1:16)                          ; F8F3A7  d1 36 25 20
	ex	(LCD_Y0:16), wa                       ; F8F3AB  d1 32 25 30
	ld (LCD_Y1:16), wa                           ; F8F3AF  f1 36 25 50
	calr LCD_Svc_01_DrawHLine                                 ; F8F3B3  1e 72 01
	ld wa, (LCD_Y1:16)                          ; F8F3B6  d1 36 25 20
	ex	(LCD_Y0:16), wa                       ; F8F3BA  d1 32 25 30
	ld (LCD_Y1:16), wa                           ; F8F3BE  f1 36 25 50
	calr LCD_Svc_02_DrawVLine                                 ; F8F3C2  1e 74 03
	ld wa, (LCD_X1:16)                          ; F8F3C5  d1 34 25 20
	ex	(LCD_X0:16), wa                       ; F8F3C9  d1 30 25 30
	ld (LCD_X1:16), wa                           ; F8F3CD  f1 34 25 50
	calr LCD_Svc_02_DrawVLine                                 ; F8F3D1  1e 65 03
	ld wa, (LCD_X1:16)                          ; F8F3D4  d1 34 25 20
	ex	(LCD_X0:16), wa                       ; F8F3D8  d1 30 25 30
	ld (LCD_X1:16), wa                           ; F8F3DC  f1 34 25 50
	ret                                           ; F8F3E0  0e

; ---------------------------------------------------------------------
; LCD_Svc_0A_DrawBoxShadow2 -- SWI7 service 0x0A: a box with a 2-pixel shadow
;
; Called from: SWI7_ServiceTable slot 0x0A (0xF8E9EE)
; Inputs:  the four coordinate words
; Outputs: the outline, plus two horizontal runs below it and two vertical runs
;          to its right.  (0x255C),(0x255E),(0x2560),(0x2562) hold the entry
;          coordinates on exit; the four live words are restored from them
;          halfway through and then stepped again, so they are NOT restored at
;          the end.
; Evidence: it calls LCD_Svc_09_DrawBox once, then LCD_Svc_01_DrawHLine TWICE
;          and LCD_Svc_02_DrawVLine TWICE, each preceded by `incw 1,` on the
;          coordinates that move the run one pixel further down or right.  Two
;          extra runs per side = a two-pixel shadow.  Service 0x22 is the same
;          routine with one of each.
; Unknown:  callers; whether the four saved words at 0x255C are read by anything
;          outside these two services.
; ---------------------------------------------------------------------
LCD_Svc_0A_DrawBoxShadow2:
	calr LCD_Svc_09_DrawBox                                 ; F8F3E1  1e c0 ff
	ld wa, (LCD_X0:16)                          ; F8F3E4  d1 30 25 20
	ld (LCD_SavedX0:16), wa                           ; F8F3E8  f1 5c 25 50
	ld wa, (LCD_Y0:16)                          ; F8F3EC  d1 32 25 20
	ld (LCD_SavedY0:16), wa                           ; F8F3F0  f1 5e 25 50
	ld wa, (LCD_X1:16)                          ; F8F3F4  d1 34 25 20
	ld (LCD_SavedX1:16), wa                           ; F8F3F8  f1 60 25 50
	ld wa, (LCD_Y1:16)                          ; F8F3FC  d1 36 25 20
	ld (LCD_SavedY1:16), wa                           ; F8F400  f1 62 25 50
	incw 0x01, (LCD_X0:16)                        ; F8F404  d1 30 25 61
	incw 0x01, (LCD_Y1:16)                        ; F8F408  d1 36 25 61
	ld wa, (LCD_Y1:16)                          ; F8F40C  d1 36 25 20
	ld (LCD_Y0:16), wa                           ; F8F410  f1 32 25 50
	addw	(LCD_X1:16), 0x0001                   ; F8F414  d1 34 25 38 01 00
	calr LCD_Svc_01_DrawHLine                                 ; F8F41A  1e 0b 01
	incw 0x01, (LCD_X0:16)                        ; F8F41D  d1 30 25 61
	incw 0x01, (LCD_Y0:16)                        ; F8F421  d1 32 25 61
	incw 0x01, (LCD_Y1:16)                        ; F8F425  d1 36 25 61
	calr LCD_Svc_01_DrawHLine                                 ; F8F429  1e fc 00
	ld wa, (LCD_SavedX0:16)                          ; F8F42C  d1 5c 25 20
	ld (LCD_X0:16), wa                           ; F8F430  f1 30 25 50
	ld wa, (LCD_SavedY0:16)                          ; F8F434  d1 5e 25 20
	ld (LCD_Y0:16), wa                           ; F8F438  f1 32 25 50
	ld wa, (LCD_SavedX1:16)                          ; F8F43C  d1 60 25 20
	ld (LCD_X1:16), wa                           ; F8F440  f1 34 25 50
	ld wa, (LCD_SavedY1:16)                          ; F8F444  d1 62 25 20
	ld (LCD_Y1:16), wa                           ; F8F448  f1 36 25 50
	incw 0x01, (LCD_Y0:16)                        ; F8F44C  d1 32 25 61
	incw 0x01, (LCD_X1:16)                        ; F8F450  d1 34 25 61
	ld wa, (LCD_X1:16)                          ; F8F454  d1 34 25 20
	ld (LCD_X0:16), wa                           ; F8F458  f1 30 25 50
	addw	(LCD_Y1:16), 0x0002                   ; F8F45C  d1 36 25 38 02 00
	calr LCD_Svc_02_DrawVLine                                 ; F8F462  1e d4 02
	incw 0x01, (LCD_Y0:16)                        ; F8F465  d1 32 25 61
	incw 0x01, (LCD_X0:16)                        ; F8F469  d1 30 25 61
	incw 0x01, (LCD_X1:16)                        ; F8F46D  d1 34 25 61
	calr LCD_Svc_02_DrawVLine                                 ; F8F471  1e c5 02
	ret                                           ; F8F474  0e

; ---------------------------------------------------------------------
; LCD_Svc_13_DrawBoxPatterned -- SWI7 service 0x13: a box drawn with the
; patterned line pair instead of the solid one
;
; Called from: SWI7_ServiceTable slot 0x13 (0xF8EA12)
; Inputs/Outputs: as LCD_Svc_09_DrawBox
; Evidence: instruction for instruction the same routine as service 0x09 with
;          `calr 0x01` replaced by `calr 0xF8FCB2` (service 0x11) and
;          `calr 0x02` by `calr 0xF8FE80` (service 0x12).
;          ⚠ "Patterned" rather than "solid": services 0x11/0x12 are not
;          converted, but 0x11 opens exactly like 0x01 and then, instead of
;          filling with 0xFF, calls 0xF8FE39, which indexes TWO tables by
;          X mod 8 -- 0xF8FE52 holding `cc 66 33 19 0c 06 03 01 00` and
;          0xF8FE5B holding `cc 66 33 99 cc 66 33 99 cc`.  Those are 0xCC
;          logically SHIFTED right by k and 0xCC ROTATED right by k: one dither
;          pattern, phase-aligned to the pixel column, for the ragged first byte
;          and for the whole bytes respectively.  0xCC is two pixels on, two
;          off.  What that looks like on the panel is NOT measured here, and
;          neither table is converted yet -- they are inside the 0xF8F850
;          .incbin.
; Unknown:  callers.
; ---------------------------------------------------------------------
LCD_Svc_13_DrawBoxPatterned:
	calr LCD_Svc_11_DrawHLineDither                   ; F8F475  1e 3a 08   svc 0x11, the patterned horizontal line
	ld wa, (LCD_Y1:16)                          ; F8F478  d1 36 25 20
	ex	(LCD_Y0:16), wa                       ; F8F47C  d1 32 25 30
	ld (LCD_Y1:16), wa                           ; F8F480  f1 36 25 50
	calr LCD_Svc_11_DrawHLineDither                   ; F8F484  1e 2b 08   svc 0x11
	ld wa, (LCD_Y1:16)                          ; F8F487  d1 36 25 20
	ex	(LCD_Y0:16), wa                       ; F8F48B  d1 32 25 30
	ld (LCD_Y1:16), wa                           ; F8F48F  f1 36 25 50
	calr LCD_Svc_12_DrawVLineDashed                   ; F8F493  1e ea 09   svc 0x12, the patterned vertical line
	ld wa, (LCD_X1:16)                          ; F8F496  d1 34 25 20
	ex	(LCD_X0:16), wa                       ; F8F49A  d1 30 25 30
	ld (LCD_X1:16), wa                           ; F8F49E  f1 34 25 50
	calr LCD_Svc_12_DrawVLineDashed                   ; F8F4A2  1e db 09   svc 0x12
	ld wa, (LCD_X1:16)                          ; F8F4A5  d1 34 25 20
	ex	(LCD_X0:16), wa                       ; F8F4A9  d1 30 25 30
	ld (LCD_X1:16), wa                           ; F8F4AD  f1 34 25 50
	ret                                           ; F8F4B1  0e

; ---------------------------------------------------------------------
; LCD_Svc_22_DrawBoxShadow1 -- SWI7 service 0x22: a box with a 1-pixel shadow
;
; Called from: SWI7_ServiceTable slot 0x22 (0xF8EA4E)
; Inputs/Outputs: as LCD_Svc_0A_DrawBoxShadow2
; Evidence: the same routine as service 0x0A with ONE call to
;          LCD_Svc_01_DrawHLine and ONE to LCD_Svc_02_DrawVLine instead of two
;          each, and `add (0x2536),0x0001` where 0x0A has `0x0002`.  A one-pixel
;          shadow rather than a two-pixel one.
; Unknown:  callers, and which of the two the UI prefers.
; ---------------------------------------------------------------------
LCD_Svc_22_DrawBoxShadow1:
	calr LCD_Svc_09_DrawBox                                 ; F8F4B2  1e ef fe
	ld wa, (LCD_X0:16)                          ; F8F4B5  d1 30 25 20
	ld (LCD_SavedX0:16), wa                           ; F8F4B9  f1 5c 25 50
	ld wa, (LCD_Y0:16)                          ; F8F4BD  d1 32 25 20
	ld (LCD_SavedY0:16), wa                           ; F8F4C1  f1 5e 25 50
	ld wa, (LCD_X1:16)                          ; F8F4C5  d1 34 25 20
	ld (LCD_SavedX1:16), wa                           ; F8F4C9  f1 60 25 50
	ld wa, (LCD_Y1:16)                          ; F8F4CD  d1 36 25 20
	ld (LCD_SavedY1:16), wa                           ; F8F4D1  f1 62 25 50
	incw 0x01, (LCD_X0:16)                        ; F8F4D5  d1 30 25 61
	incw 0x01, (LCD_Y1:16)                        ; F8F4D9  d1 36 25 61
	ld wa, (LCD_Y1:16)                          ; F8F4DD  d1 36 25 20
	ld (LCD_Y0:16), wa                           ; F8F4E1  f1 32 25 50
	addw	(LCD_X1:16), 0x0001                   ; F8F4E5  d1 34 25 38 01 00
	calr LCD_Svc_01_DrawHLine                                 ; F8F4EB  1e 3a 00
	ld wa, (LCD_SavedX0:16)                          ; F8F4EE  d1 5c 25 20
	ld (LCD_X0:16), wa                           ; F8F4F2  f1 30 25 50
	ld wa, (LCD_SavedY0:16)                          ; F8F4F6  d1 5e 25 20
	ld (LCD_Y0:16), wa                           ; F8F4FA  f1 32 25 50
	ld wa, (LCD_SavedX1:16)                          ; F8F4FE  d1 60 25 20
	ld (LCD_X1:16), wa                           ; F8F502  f1 34 25 50
	ld wa, (LCD_SavedY1:16)                          ; F8F506  d1 62 25 20
	ld (LCD_Y1:16), wa                           ; F8F50A  f1 36 25 50
	incw 0x01, (LCD_Y0:16)                        ; F8F50E  d1 32 25 61
	incw 0x01, (LCD_X1:16)                        ; F8F512  d1 34 25 61
	ld wa, (LCD_X1:16)                          ; F8F516  d1 34 25 20
	ld (LCD_X0:16), wa                           ; F8F51A  f1 30 25 50
	addw	(LCD_Y1:16), 0x0001                   ; F8F51E  d1 36 25 38 01 00
	calr LCD_Svc_02_DrawVLine                                 ; F8F524  1e 12 02
	ret                                           ; F8F527  0e

; ---------------------------------------------------------------------
; LCD_Svc_01_DrawHLine -- SWI7 service 0x01: a solid horizontal run of pixels
;
; Called from: SWI7_ServiceTable slot 0x01 (0xF8E9CA), and from services 0x09,
;          0x0A and 0x22 above
; Inputs:  (0x2530) = X0, (0x2534) = X1, (0x2532) = Y; (0x2540) the layer
; Outputs: the pixels from X0 to X1 at row Y set (OR, never cleared);
;          (0x255A) = the display address of the first byte; the four coordinate
;          words clamped in place.
; Evidence: the address arithmetic is LCD_PlotPointAt's, Y*(0x2557) + X/8 +
;          (0x2555); then CSRDIR **RIGHT** (0x4C) -- which is what makes it
;          horizontal, against the column services' CSRDIR DOWN -- and the
;          three-phase byte walk the rectangle fill also uses: MREAD the ragged
;          first byte, OR in LCD_Rect_LeftEdgeMask's mask, write it back, then
;          whole 0xFF bytes, then LCD_Rect_RightEdgeMask for the last one.  It
;          shares BOTH of those mask helpers with LCD_Svc_05_FillRect, which is
;          the cross-check.
;          0x4C = CSRDIR RIGHT is cited: ../mame/src/devices/video/sed1330.cpp:30.
; Unknown:  nothing outstanding beyond callers.
; ---------------------------------------------------------------------
LCD_Svc_01_DrawHLine:
	calr LCD_SelectCurrentLayer                   ; F8F528  1e 68 f9   LCD_SelectCurrentLayer
	calr LCD_ClampCoordsToPanel                   ; F8F52B  1e 3d f6   LCD_ClampCoordsToPanel
	ld wa, (LCD_Y0:16)                          ; F8F52E  d1 32 25 20
	ld bc, (LCD_BytesPerLine:16)                          ; F8F532  d1 57 25 21
	mul xwa, bc                                  ; F8F536  d9 40
	ld HL,WA                                      ; F8F538  d8 8b
	ld wa, (LCD_X0:16)                          ; F8F53A  d1 30 25 20
	extz XWA                                      ; F8F53E  e8 12
	ldw bc, 0x08                                  ; F8F540  31 08 00
	divs xwa, bc                                 ; F8F543  d9 58
	ld DE,QWA                                     ; F8F545  d7 e2 8a
	add HL,WA                                     ; F8F548  d8 83
	ld wa, (LCD_CurrentLayerBase:16)                          ; F8F54A  d1 55 25 20
	add WA,HL                                     ; F8F54E  db 80
	bit	0, (0xc6:8)                            ; F8F550  f0 c6 c8
	jr nz, .LF8F55C                               ; F8F553  6e 07
.LF8F555:
	bit	6, (0x790000:24)                      ; F8F555  f2 00 00 79 ce
	jr nz, .LF8F555                               ; F8F55A  6e f9
.LF8F55C:
	ld (0x790001:24), 0x4c                      ; F8F55C  f2 01 00 79 00 4c
	bit	0, (0xc6:8)                            ; F8F562  f0 c6 c8
	jr nz, .LF8F56E                               ; F8F565  6e 07
.LF8F567:
	bit	6, (0x790000:24)                      ; F8F567  f2 00 00 79 ce
	jr nz, .LF8F567                               ; F8F56C  6e f9
.LF8F56E:
	ld (0x790001:24), 0x46                      ; F8F56E  f2 01 00 79 00 46
	ld (LCD_RunAddress:16), wa                           ; F8F574  f1 5a 25 50
	bit	0, (0xc6:8)                            ; F8F578  f0 c6 c8
	jr nz, .LF8F584                               ; F8F57B  6e 07
.LF8F57D:
	bit	6, (0x790000:24)                      ; F8F57D  f2 00 00 79 ce
	jr nz, .LF8F57D                               ; F8F582  6e f9
.LF8F584:
	ld (0x790000:24), a                          ; F8F584  f2 00 00 79 41
	bit	0, (0xc6:8)                            ; F8F589  f0 c6 c8
	jr nz, .LF8F595                               ; F8F58C  6e 07
.LF8F58E:
	bit	6, (0x790000:24)                      ; F8F58E  f2 00 00 79 ce
	jr nz, .LF8F58E                               ; F8F593  6e f9
.LF8F595:
	ld (0x790000:24), w                          ; F8F595  f2 00 00 79 40
	and DE,DE                                     ; F8F59A  da c2
	jrl z, .LF8F62B                               ; F8F59C  76 8c 00
	bit	0, (0xc6:8)                            ; F8F59F  f0 c6 c8
	jr nz, .LF8F5AB                               ; F8F5A2  6e 07
.LF8F5A4:
	bit	6, (0x790000:24)                      ; F8F5A4  f2 00 00 79 ce
	jr nz, .LF8F5A4                               ; F8F5A9  6e f9
.LF8F5AB:
	ld (0x790001:24), 0x43                      ; F8F5AB  f2 01 00 79 00 43
	bit	0, (0xc6:8)                            ; F8F5B1  f0 c6 c8
	jr nz, .LF8F5BD                               ; F8F5B4  6e 07
.LF8F5B6:
	bit	6, (0x790000:24)                      ; F8F5B6  f2 00 00 79 ce
	jr nz, .LF8F5B6                               ; F8F5BB  6e f9
.LF8F5BD:
	ld w, (0x790001:24)                          ; F8F5BD  c2 01 00 79 20
	calr LCD_Rect_LeftEdgeMask                   ; F8F5C2  1e a2 01   LCD_Rect_LeftEdgeMask -> A
	or A,W                                        ; F8F5C5  c8 e1
	ld C,A                                        ; F8F5C7  c9 8b
	bit	0, (0xc6:8)                            ; F8F5C9  f0 c6 c8
	jr nz, .LF8F5D5                               ; F8F5CC  6e 07
.LF8F5CE:
	bit	6, (0x790000:24)                      ; F8F5CE  f2 00 00 79 ce
	jr nz, .LF8F5CE                               ; F8F5D3  6e f9
.LF8F5D5:
	ld (0x790001:24), 0x46                      ; F8F5D5  f2 01 00 79 00 46
	ld wa, (LCD_RunAddress:16)                          ; F8F5DB  d1 5a 25 20
	bit	0, (0xc6:8)                            ; F8F5DF  f0 c6 c8
	jr nz, .LF8F5EB                               ; F8F5E2  6e 07
.LF8F5E4:
	bit	6, (0x790000:24)                      ; F8F5E4  f2 00 00 79 ce
	jr nz, .LF8F5E4                               ; F8F5E9  6e f9
.LF8F5EB:
	ld (0x790000:24), a                          ; F8F5EB  f2 00 00 79 41
	bit	0, (0xc6:8)                            ; F8F5F0  f0 c6 c8
	jr nz, .LF8F5FC                               ; F8F5F3  6e 07
.LF8F5F5:
	bit	6, (0x790000:24)                      ; F8F5F5  f2 00 00 79 ce
	jr nz, .LF8F5F5                               ; F8F5FA  6e f9
.LF8F5FC:
	ld (0x790000:24), w                          ; F8F5FC  f2 00 00 79 40
	bit	0, (0xc6:8)                            ; F8F601  f0 c6 c8
	jr nz, .LF8F60D                               ; F8F604  6e 07
.LF8F606:
	bit	6, (0x790000:24)                      ; F8F606  f2 00 00 79 ce
	jr nz, .LF8F606                               ; F8F60B  6e f9
.LF8F60D:
	ld (0x790001:24), 0x42                      ; F8F60D  f2 01 00 79 00 42
	ldw hl, 0x08                                  ; F8F613  33 08 00
	sub HL,DE                                     ; F8F616  da a3
	ex16 hl, de                                   ; F8F618  da bb
	bit	0, (0xc6:8)                            ; F8F61A  f0 c6 c8
	jr nz, .LF8F626                               ; F8F61D  6e 07
.LF8F61F:
	bit	6, (0x790000:24)                      ; F8F61F  f2 00 00 79 ce
	jr nz, .LF8F61F                               ; F8F624  6e f9
.LF8F626:
	ld (0x790000:24), c                          ; F8F626  f2 00 00 79 43
.LF8F62B:
	ld wa, (LCD_X1:16)                          ; F8F62B  d1 34 25 20
	sub	wa, (LCD_X0:16)                       ; F8F62F  d1 30 25 a0
	inc 1,WA                                      ; F8F633  d8 61
	cp WA,DE                                      ; F8F635  da f0
	jrl ule, .LF8F738                             ; F8F637  73 fe 00
	sub WA,DE                                     ; F8F63A  da a0
	extz XWA                                      ; F8F63C  e8 12
	ldw bc, 0x08                                  ; F8F63E  31 08 00
	divs xwa, bc                                 ; F8F641  d9 58
	ld DE,QWA                                     ; F8F643  d7 e2 8a
	and WA,WA                                     ; F8F646  d8 c0
	jr z, .LF8F676                                ; F8F648  66 2c
	ld BC,WA                                      ; F8F64A  d8 89
	bit	0, (0xc6:8)                            ; F8F64C  f0 c6 c8
	jr nz, .LF8F658                               ; F8F64F  6e 07
.LF8F651:
	bit	6, (0x790000:24)                      ; F8F651  f2 00 00 79 ce
	jr nz, .LF8F651                               ; F8F656  6e f9
.LF8F658:
	ld (0x790001:24), 0x42                      ; F8F658  f2 01 00 79 00 42
	ld a, 0xff:opc                                   ; F8F65E  21 ff
.LF8F660:
	nop                                           ; F8F660  00
	nop                                           ; F8F661  00
	bit	0, (0xc6:8)                            ; F8F662  f0 c6 c8
	jr nz, .LF8F66E                               ; F8F665  6e 07
.LF8F667:
	bit	6, (0x790000:24)                      ; F8F667  f2 00 00 79 ce
	jr nz, .LF8F667                               ; F8F66C  6e f9
.LF8F66E:
	ld (0x790000:24), a                          ; F8F66E  f2 00 00 79 41
	djnz16 bc, .LF8F660                           ; F8F673  d9 1c ea
.LF8F676:
	and DE,DE                                     ; F8F676  da c2
	jrl z, .LF8F738                               ; F8F678  76 bd 00
	bit	0, (0xc6:8)                            ; F8F67B  f0 c6 c8
	jr nz, .LF8F687                               ; F8F67E  6e 07
.LF8F680:
	bit	6, (0x790000:24)                      ; F8F680  f2 00 00 79 ce
	jr nz, .LF8F680                               ; F8F685  6e f9
.LF8F687:
	ld (0x790001:24), 0x47                      ; F8F687  f2 01 00 79 00 47
	bit	0, (0xc6:8)                            ; F8F68D  f0 c6 c8
	jr nz, .LF8F699                               ; F8F690  6e 07
.LF8F692:
	bit	6, (0x790000:24)                      ; F8F692  f2 00 00 79 ce
	jr nz, .LF8F692                               ; F8F697  6e f9
.LF8F699:
	ld a, (0x790001:24)                          ; F8F699  c2 01 00 79 21
	bit	0, (0xc6:8)                            ; F8F69E  f0 c6 c8
	jr nz, .LF8F6AA                               ; F8F6A1  6e 07
.LF8F6A3:
	bit	6, (0x790000:24)                      ; F8F6A3  f2 00 00 79 ce
	jr nz, .LF8F6A3                               ; F8F6A8  6e f9
.LF8F6AA:
	ld w, (0x790001:24)                          ; F8F6AA  c2 01 00 79 20
	ld (LCD_RunAddress:16), wa                           ; F8F6AF  f1 5a 25 50
	bit	0, (0xc6:8)                            ; F8F6B3  f0 c6 c8
	jr nz, .LF8F6BF                               ; F8F6B6  6e 07
.LF8F6B8:
	bit	6, (0x790000:24)                      ; F8F6B8  f2 00 00 79 ce
	jr nz, .LF8F6B8                               ; F8F6BD  6e f9
.LF8F6BF:
	ld (0x790001:24), 0x43                      ; F8F6BF  f2 01 00 79 00 43
	bit	0, (0xc6:8)                            ; F8F6C5  f0 c6 c8
	jr nz, .LF8F6D1                               ; F8F6C8  6e 07
.LF8F6CA:
	bit	6, (0x790000:24)                      ; F8F6CA  f2 00 00 79 ce
	jr nz, .LF8F6CA                               ; F8F6CF  6e f9
.LF8F6D1:
	ld w, (0x790001:24)                          ; F8F6D1  c2 01 00 79 20
	calr LCD_Rect_RightEdgeMask                   ; F8F6D6  1e cb 00   LCD_Rect_RightEdgeMask -> A
	or A,W                                        ; F8F6D9  c8 e1

	ld C,A                                        ; F8F6DB  c9 8b
	bit	0, (0xc6:8)                            ; F8F6DD  f0 c6 c8
	jr nz, .LF8F6E9                               ; F8F6E0  6e 07
.LF8F6E2:
	bit	6, (0x790000:24)                      ; F8F6E2  f2 00 00 79 ce
	jr nz, .LF8F6E2                               ; F8F6E7  6e f9
.LF8F6E9:
	ld (0x790001:24), 0x46                      ; F8F6E9  f2 01 00 79 00 46
	ld wa, (LCD_RunAddress:16)                          ; F8F6EF  d1 5a 25 20
	bit	0, (0xc6:8)                            ; F8F6F3  f0 c6 c8
	jr nz, .LF8F6FF                               ; F8F6F6  6e 07
.LF8F6F8:
	bit	6, (0x790000:24)                      ; F8F6F8  f2 00 00 79 ce
	jr nz, .LF8F6F8                               ; F8F6FD  6e f9
.LF8F6FF:
	ld (0x790000:24), a                          ; F8F6FF  f2 00 00 79 41
	bit	0, (0xc6:8)                            ; F8F704  f0 c6 c8
	jr nz, .LF8F710                               ; F8F707  6e 07
.LF8F709:
	bit	6, (0x790000:24)                      ; F8F709  f2 00 00 79 ce
	jr nz, .LF8F709                               ; F8F70E  6e f9
.LF8F710:
	ld (0x790000:24), w                          ; F8F710  f2 00 00 79 40
	bit	0, (0xc6:8)                            ; F8F715  f0 c6 c8
	jr nz, .LF8F721                               ; F8F718  6e 07
.LF8F71A:
	bit	6, (0x790000:24)                      ; F8F71A  f2 00 00 79 ce
	jr nz, .LF8F71A                               ; F8F71F  6e f9
.LF8F721:
	ld (0x790001:24), 0x42                      ; F8F721  f2 01 00 79 00 42
	bit	0, (0xc6:8)                            ; F8F727  f0 c6 c8
	jr nz, .LF8F733                               ; F8F72A  6e 07
.LF8F72C:
	bit	6, (0x790000:24)                      ; F8F72C  f2 00 00 79 ce
	jr nz, .LF8F72C                               ; F8F731  6e f9
.LF8F733:
	ld (0x790000:24), c                          ; F8F733  f2 00 00 79 43
.LF8F738:
	ret                                           ; F8F738  0e

; ---------------------------------------------------------------------
; LCD_Svc_02_DrawVLine -- SWI7 service 0x02: a solid vertical run of pixels
;
; Called from: SWI7_ServiceTable slot 0x02 (0xF8E9CE), and from services 0x09,
;          0x0A and 0x22 above
; Inputs:  (0x2530) = X, (0x2532) = Y0, (0x2536) = Y1
; Outputs: the pixels from Y0 to Y1 in column X set.
; Evidence: it needs no masks at all -- a vertical run touches one BIT of each
;          of many bytes -- so the whole body is: count the rows as
;          (0x2536)-(0x2532)+1, return if that is zero, seed (0x2550)/(0x2552)
;          with X and Y0, then `calr LCD_PlotPointAt` / `incw 1,(0x2552)` in a
;          djnz loop.  That asymmetry with service 0x01 -- edge masks one way,
;          one plot per pixel the other -- is the shape of a 1-bit framebuffer
;          laid out in rows.
;          ⚠ It does NOT clamp: unlike service 0x01 it calls only
;          LCD_SelectCurrentLayer, so an out-of-range Y is the caller's problem.
; Unknown:  nothing outstanding beyond callers.
; ---------------------------------------------------------------------
LCD_Svc_02_DrawVLine:
	calr LCD_SelectCurrentLayer                   ; F8F739  1e 57 f7   LCD_SelectCurrentLayer
	ld bc, (LCD_Y1:16)                          ; F8F73C  d1 36 25 21
	sub	bc, (LCD_Y0:16)                       ; F8F740  d1 32 25 a1
	inc 1,BC                                      ; F8F744  d9 61
	and BC,BC                                     ; F8F746  d9 c1
	jr z, .LF8F766                                ; F8F748  66 1c
	ld wa, (LCD_X0:16)                          ; F8F74A  d1 30 25 20
	ld (LCD_PlotX:16), wa                           ; F8F74E  f1 50 25 50
	ld wa, (LCD_Y0:16)                          ; F8F752  d1 32 25 20
	ld (LCD_PlotY:16), wa                           ; F8F756  f1 52 25 50
.LF8F75A:
	pushw bc                                      ; F8F75A  29
	calr LCD_PlotPointAt                   ; F8F75B  1e 71 f5   LCD_PlotPointAt
	popw bc                                       ; F8F75E  49
	incw 0x01, (LCD_PlotY:16)                        ; F8F75F  d1 52 25 61
	djnz16 bc, .LF8F75A                           ; F8F763  d9 1c f4
.LF8F766:
	ret                                           ; F8F766  0e

; ==============================================================================
; 0xF8F767-0xF8F7B7 -- the two edge-mask helpers of the rectangle fill
; ==============================================================================
;
; ★ THE BIT ORDER IS MSB-LEFTMOST, and these tables re-prove it.  The pixel
;   plotter's table at 0xF8EDAC is `80 40 20 10 08 04 02 01` indexed by X mod 8,
;   so pixel k of a byte is bit 7-k.  A left edge that starts at pixel k must
;   therefore keep bits 7-k..0, i.e. 0xFF >> k -- and that is exactly what
;   LCD_LeftEdgeMask_Table holds for k = 1..7.  A right edge that ends before
;   pixel k must keep bits 7..8-k, i.e. 0xFF << (8-k) -- which is
;   LCD_RightEdgeMask_Table.  Two tables derived from one convention, and they
;   agree with a third table in another routine.

; ---------------------------------------------------------------------
; LCD_Rect_LeftEdgeMask -- A := the pixel mask of the box's first byte-column
;
; Called from: LCD_Svc_05_FillRect (0xF8EF46)
; Inputs:  DE = X0 mod 8, always 1..7 here (the caller skips this whole phase
;          when it is 0); (0x2530)/(0x2534) = the box's X range.
; Outputs: A = the mask; BC clobbered.
; Evidence: it indexes LCD_LeftEdgeMask_Table with DE and then, IF the box is
;          narrower than the 8-DE pixels that mask covers, shifts the mask right
;          and back left by the excess -- which clears exactly the low bits that
;          lie past the box's right edge.  Both shifts are the variable
;          shift-by-a-register form (`cb ff` / `cb fc`), which llvm-mc cannot
;          encode; they stay as .byte with unidasm's text beside them.
; Unknown:  nothing outstanding.
; ---------------------------------------------------------------------
LCD_Rect_LeftEdgeMask:
	ldw bc, 0x08                                  ; F8F767  31 08 00
	sub BC,DE                                     ; F8F76A  da a1   BC = pixels this mask covers
	ld XHL,LCD_LeftEdgeMask_Table                 ; F8F76C  43 9b f7 f8 00   LCD_LeftEdgeMask_Table
	ld	a, (xhl+de)                           ; F8F771  c3 07 ec e8 21
	ld hl, (LCD_X1:16)                          ; F8F776  d1 34 25 23
	sub	hl, (LCD_X0:16)                       ; F8F77A  d1 30 25 a3
	inc 1,HL                                      ; F8F77E  db 61   HL = the box width in pixels
	cp BC,HL                                      ; F8F780  db f1
	jr ule, .LF8F79A                              ; F8F782  63 16   the box is wider: keep the whole mask
	sub BC,HL                                     ; F8F784  db a1   C = how many low bits lie past the right edge
	cp c, 0x00:i3                                   ; F8F786  cb d8
	jr z, .LF8F79A                                ; F8F788  66 10
	ex8 a, c                                      ; F8F78A  cb b9
	.byte 0xcb, 0xff                              ; F8F78C  cb ff   srl A,C -- shift the mask right by that count
	ex8 a, c                                      ; F8F78E  cb b9
	cp c, 0x00:i3                                   ; F8F790  cb d8
	jr z, .LF8F79A                                ; F8F792  66 06
	ex8 a, c                                      ; F8F794  cb b9
	.byte 0xcb, 0xfc                              ; F8F796  cb fc   sla A,C -- and back, so those bits are now 0
	ex8 a, c                                      ; F8F798  cb b9
.LF8F79A:
	ret                                           ; F8F79A  0e

; ---------------------------------------------------------------------
; LCD_LeftEdgeMask_Table -- 9 bytes: keep pixels k..7 of a byte
;
; Read by:  LCD_Rect_LeftEdgeMask (0xF8F76C), indexed by X0 mod 8.
; Evidence: notes/prom_a_byte_checks.py re-reads these nine bytes from the ROM
;          twice over, once as the literal sequence ("left mask table: 00 7f
;          3f 1f 0f 07 03 01 00") and once as the RULE ("left mask table:
;          entries 1..7 are 0xFF >> k") -- two independent statements of the
;          same nine bytes, so a typo in either fails. The COUNT argument is
;          in the Count: field above and rests on two addresses the byte gate
;          holds.
; Layout:   9 bytes, 0xF8F79B-0xF8F7A3, one per index 0..8; entry k is
;           0xFF >> k for k = 1..7 and 0x00 at both ends.
; Count:    9 is fixed by the addresses, not by inspection: the table starts at
;           0xF8F79B because that is the immediate LCD_Rect_LeftEdgeMask loads,
;           and 0xF8F7A4 is the first instruction of LCD_Rect_RightEdgeMask, so
;           nine bytes is all the room there is.
;           ⚠ Only indices 1..7 are reachable -- the one call site skips the
;           whole phase when X0 mod 8 is 0, and `div` by 8 cannot produce 8.
;           Whether index 0 and index 8 are entries or padding is NOT decided
;           here; both are 0x00, which is harmless either way.
; ---------------------------------------------------------------------
LCD_LeftEdgeMask_Table:
	.byte 0x00			; F8F79B  index 0 -- unreachable
	.byte 0x7F			; F8F79C  index 1 -- pixels 1..7
	.byte 0x3F			; F8F79D  index 2
	.byte 0x1F			; F8F79E  index 3
	.byte 0x0F			; F8F79F  index 4
	.byte 0x07			; F8F7A0  index 5
	.byte 0x03			; F8F7A1  index 6
	.byte 0x01			; F8F7A2  index 7 -- pixel 7 only
	.byte 0x00			; F8F7A3  index 8 -- unreachable

; ---------------------------------------------------------------------
; LCD_Rect_RightEdgeMask -- A := the pixel mask of the box's last byte-column
;
; Called from: LCD_Svc_05_FillRect (0xF8F019)
; Inputs:  DE = the pixels left over after the whole bytes, 1..7
; Outputs: A = the mask; XHL clobbered.
; Evidence: a table lookup and nothing else -- no clipping is needed at this end
;          because the leftover count came from the division and is already
;          inside one byte.
; ---------------------------------------------------------------------
LCD_Rect_RightEdgeMask:
	ld XHL,LCD_RightEdgeMask_Table                ; F8F7A4  43 af f7 f8 00   LCD_RightEdgeMask_Table
	ld	a, (xhl+de)                           ; F8F7A9  c3 07 ec e8 21
	ret                                           ; F8F7AE  0e

; ---------------------------------------------------------------------
; LCD_RightEdgeMask_Table -- 9 bytes: keep pixels 0..k-1 of a byte
;
; Read by:  LCD_Rect_RightEdgeMask (0xF8F7A4), indexed by the leftover width.
; Evidence: same shape as the other table and checked the same way --
;          notes/prom_a_byte_checks.py asserts both the literal ("right mask
;          table: 00 80 c0 e0 f0 f8 fc fe 00") and the rule ("entries 1..7 are
;          0xFF << (8-k)"). The same script also finds where this table is
;          DUPLICATED elsewhere in the image ("0xF8F7AF, 0xF8FE77 are byte-
;          identical (9 of 9)").
; Layout:   9 bytes, 0xF8F7AF-0xF8F7B7, entry k = 0xFF << (8-k) for k = 1..7.
; Count:    same argument as the other table -- 0xF8F7B8 is
;           LCD_Svc_0C_SetLayersOn's first instruction (converted below), so the
;           table cannot be longer, and the load at 0xF8F7A4 fixes where it
;           starts.  Only indices 1..7 are reachable.
; ---------------------------------------------------------------------
LCD_RightEdgeMask_Table:
	.byte 0x00			; F8F7AF  index 0 -- unreachable
	.byte 0x80			; F8F7B0  index 1 -- pixel 0 only
	.byte 0xC0			; F8F7B1  index 2
	.byte 0xE0			; F8F7B2  index 3
	.byte 0xF0			; F8F7B3  index 4
	.byte 0xF8			; F8F7B4  index 5
	.byte 0xFC			; F8F7B5  index 6
	.byte 0xFE			; F8F7B6  index 7 -- pixels 0..6
	.byte 0x00			; F8F7B7  index 8 -- unreachable

; ==============================================================================
; 0xF8F7B8-0xF8F84F -- SWI7 services 0x0C and 0x0D: which layers are visible
; ==============================================================================
;
; Both write the SED1330 DISP ON parameter byte, whose four 2-bit fields are
; FC (cursor), FP1, FP2/4, FP3, with 00 = off, 01 = on, 10 = flash at fFR/32,
; 11 = flash at fFR/4 (MAME, src/devices/video/sed1330.cpp:410-448).  0x0C
; writes 01 into the selected layers, 0x0D writes 10 -- on, versus blinking.

; ---------------------------------------------------------------------
; LCD_Svc_0C_SetLayersOn -- SWI7 service 0x0C: exactly these layers, steady on
;
; Called from: SWI7_ServiceTable slot 0x0C, and directly by
;          NMI_PowerFail_SaveAndHalt with A = 0x0C, C = 0
; Inputs:  C bits 0/1/2 select display layers 1/2/3
; Outputs: the DISP ON byte is rebuilt from scratch -- a layer whose bit is
;          clear in C is turned OFF -- and remembered in (0x2559).  If the whole
;          byte comes out zero, bit 0 of (0xC6) is SET, which is what makes the
;          rest of the driver stop waiting for BUSY; any non-zero value clears it
;          again.
; Notes:   the NMI calls this with C = 0, so the power-fail path's first act is
;          to blank the panel and put the driver into its no-wait mode.  That is
;          also the evidence for what bit 0 of (0xC6) means.
; ---------------------------------------------------------------------
LCD_Svc_0C_SetLayersOn:
	ld a, (LCD_DispOnOffShadow:16)                            ; F8F7B8  c1 59 25 21   the last DISP byte sent
	and A,0x03                                    ; F8F7BC  c9 cc 03   keep bits[1:0], the cursor field; every layer field starts OFF
	bit 0x00,C                                    ; F8F7BF  cb 33 00
	jr z, .LF8F7C7                                ; F8F7C2  66 03
	or A,0x04                                     ; F8F7C4  c9 ce 04   layer 1 field = 01 SOLID
.LF8F7C7:
	bit 0x01,C                                    ; F8F7C7  cb 33 01
	jr z, .LF8F7CF                                ; F8F7CA  66 03
	or A,0x10                                     ; F8F7CC  c9 ce 10   layer 2 field = 01 SOLID
.LF8F7CF:
	bit 0x02,C                                    ; F8F7CF  cb 33 02
	jr z, .LF8F7D7                                ; F8F7D2  66 03
	or A,0x40                                     ; F8F7D4  c9 ce 40   layer 3 field = 01 SOLID
.LF8F7D7:
	ld (0x790001:24), 0x59                      ; F8F7D7  f2 01 00 79 00 59   DISP ON
	bit	0, (0xc6:8)                            ; F8F7DD  f0 c6 c8
	jr nz, .LF8F7E9                               ; F8F7E0  6e 07
.LF8F7E2:
	bit	6, (0x790000:24)                      ; F8F7E2  f2 00 00 79 ce
	jr nz, .LF8F7E2                               ; F8F7E7  6e f9
.LF8F7E9:
	ld (0x790000:24), a                          ; F8F7E9  f2 00 00 79 41
	ld (LCD_DispOnOffShadow:16), a                            ; F8F7EE  f1 59 25 41
	and A,A                                       ; F8F7F2  c9 c1   nothing on at all?
	jr nz, .LF8F7FC                               ; F8F7F4  6e 06
	or	(0xc6:8), 0x01                        ; F8F7F6  c0 c6 3e 01   then stop polling BUSY -- the panel is dark
	jr .LF8F800                                   ; F8F7FA  68 04
.LF8F7FC:
	and	(0xc6:8), 0xfe                        ; F8F7FC  c0 c6 3c fe   otherwise resume polling
.LF8F800:
	ret                                           ; F8F800  0e

; ---------------------------------------------------------------------
; LCD_Svc_0D_SetLayersFlashing -- SWI7 service 0x0D: make these layers blink
;
; Called from: SWI7_ServiceTable slot 0x0D
; Inputs:  C bits 0/1/2 select display layers 1/2/3
; Outputs: each selected layer's field becomes 10 (flash at fFR/32); layers not
;          selected keep whatever they had, so unlike service 0x0C this is a
;          modify, not a rebuild.  (0x2559) updated.
; Evidence: "flashing" is the FIELD VALUE, read off the code -- each selected
;          layer's two-bit field in (0x2559) is forced to 10 by `and A,0xF3 /
;          or A,0x08` at 0xF8F80A/0xF8F80D for layer 1, and by the same pair
;          of instructions with the other field's masks for layers 2 and 3 --
;          and 10 is "flash at fFR/32" in the SED1330 DISP ON parameter that
;          (0x2559) shadows (notes/FINDINGS-display-controller.md). "Modify,
;          not rebuild" is that each arm is guarded by its own `bit n,C` and
;          leaves the other fields untouched.
; Notes:   it does NOT touch (0xC6): a blinking layer is still a live panel.
; ---------------------------------------------------------------------
LCD_Svc_0D_SetLayersFlashing:
	ld a, (LCD_DispOnOffShadow:16)                            ; F8F801  c1 59 25 21
	bit 0x00,C                                    ; F8F805  cb 33 00
	jr z, .LF8F810                                ; F8F808  66 06
	and A,0xf3                                    ; F8F80A  c9 cc f3   layer 1 field = 10 FLASH fFR/32
	or A,0x08                                     ; F8F80D  c9 ce 08
.LF8F810:
	bit 0x01,C                                    ; F8F810  cb 33 01
	jr z, .LF8F81B                                ; F8F813  66 06
	and A,0xcf                                    ; F8F815  c9 cc cf   layer 2 field = 10 FLASH fFR/32
	or A,0x20                                     ; F8F818  c9 ce 20
.LF8F81B:
	bit 0x02,C                                    ; F8F81B  cb 33 02
	jr z, .LF8F826                                ; F8F81E  66 06
	and A,0x3f                                    ; F8F820  c9 cc 3f   layer 3 field = 10 FLASH fFR/32
	or A,0x80                                     ; F8F823  c9 ce 80
.LF8F826:
	bit	0, (0xc6:8)                            ; F8F826  f0 c6 c8
	jr nz, .LF8F832                               ; F8F829  6e 07
.LF8F82B:
	bit	6, (0x790000:24)                      ; F8F82B  f2 00 00 79 ce
	jr nz, .LF8F82B                               ; F8F830  6e f9
.LF8F832:
	ld (0x790001:24), 0x59                      ; F8F832  f2 01 00 79 00 59   DISP ON
	nop                                           ; F8F838  00
	nop                                           ; F8F839  00
	bit	0, (0xc6:8)                            ; F8F83A  f0 c6 c8
	jr nz, .LF8F846                               ; F8F83D  6e 07
.LF8F83F:
	bit	6, (0x790000:24)                      ; F8F83F  f2 00 00 79 ce
	jr nz, .LF8F83F                               ; F8F844  6e f9
.LF8F846:
	ld (0x790000:24), a                          ; F8F846  f2 00 00 79 41
	ld (LCD_DispOnOffShadow:16), a                            ; F8F84B  f1 59 25 41
	ret                                           ; F8F84F  0e

; ==============================================================================
; 0xF8F850-0xF90117 -- SWI7 services 0x0E 0x1B 0x0F 0x10 0x11 0x12 0x14 0x15:
; the ERASE family, the two PANEL MODES, and the three PATTERNED primitives
; ==============================================================================
;
; Everything here is a variant of a service that is already converted above, and
; each header below says which one and what the variation is.  Three groups:
;
;  * ERASE.  Services 0x0E and 0x1B write ZERO where 0x03 and 0x05 write the
;    caller's data and 0xFF.  0x1B does it as a read-modify-write with the
;    COMPLEMENT of the same two edge masks the fill uses, so the pixels outside
;    the box survive.
;
;  * PANEL MODE.  ★ Services 0x0F and 0x10 re-run the whole power-on sequence of
;    LCD_Init_SED1330 -- SYSTEM SET, SCROLL, OVLAY, clear, DISP ON -- with
;    DIFFERENT layer geometry.  0x10 restores the three-layer arrangement the
;    power-on setup programmes; 0x0F switches the panel to a TWO-layer one whose
;    second layer is at display-RAM 0x4000.  So the WSA1's display has two
;    modes, and the firmware can switch between them at runtime.
;
;  * PATTERN.  Services 0x11, 0x12 and 0x15 draw with a fixed 2-on-2-off dither
;    (0xCC horizontally, a modulo-4 counter vertically); service 0x14 fills a
;    box with an EIGHT-BYTE pattern the caller leaves in RAM at (0x2538).
;
; ⚠ NEW RAM ESTABLISHED BY THIS BLOCK, beyond the map in the display-controller
;   note:
;     (0x2538)-(0x253F)  the caller's 8 x 8 fill pattern, one byte per row,
;                        read by service 0x14 only
;     (0x2558)           APH, the high byte of AP -- services 0x0F and 0x10
;                        write 0x28 to (0x2557) and 0x00 to (0x2558), so the
;                        16-bit word at (0x2557) that the plotter multiplies Y
;                        by is AP = 40, spelled out one byte at a time
;     (0x255E)           the current pattern byte, in services 0x11 and 0x14.
;                        ⚠ THE SAME WORD IS SERVICES 0x0A/0x22's SAVED Y0.  Two
;                        unrelated uses of one address; they do not overlap in
;                        time because 0x0A/0x22 call only the SOLID line pair.

; ---------------------------------------------------------------------
; LCD_Svc_0E_ClearColumns -- SWI7 service 0x0E: zero a rectangle, column-major
;
; Called from: SWI7_ServiceTable slot 0x0E (0xF8E9FE)
; Inputs:  IY = byte offset of the top-left corner WITHIN the current layer;
;          BC = number of columns; HL = bytes down each column.  (0x2540)
;          selects the layer.  ⚠ The offset is in IY, not IX as in service
;          0x03 -- `dd 88 ld WA,IY` here against `dc 88 ld WA,IX` at 0xF8EDD1.
; Outputs: BC*HL display bytes set to 0x00.  WA, BC, E clobbered.  Returns
;          immediately if BC or HL is zero.
; Evidence: it is service 0x03 with the source pointer removed.  109 bytes here
;           against 0x03's 111; the two differences are that 0x03's inner body
;           is `ld E,(XIY)` + `inc 1,XIY` (4 bytes) reading the caller's buffer,
;           where this one hoists a single `ld E,0x00` (2 bytes) out of the loop
;           and writes that constant every time -- 111 - 4 + 2 = 109.  Same
;           CSRDIR DOWN (0x4F), same CSRW/MWRITE per column, same
;           `add WA,(0x2555)` to turn the offset into a display address.
;           The arithmetic and the two byte counts are checked by
;           notes/prom_a_byte_checks.py.
; Unknown:  callers.  Nothing in prom_a or prom_b is known to invoke it other
;           than through the SWI7 table.
; ---------------------------------------------------------------------
LCD_Svc_0E_ClearColumns:
	calr (0xF8EE93 - 0xF8F853)                                   ; F8F850  1e 40 f6
	ld XIX,0x00790000                             ; F8F853  44 00 00 79 00
	bit	0, (0xc6:8)                            ; F8F858  f0 c6 c8
	jr nz, .LF8F861                               ; F8F85B  6e 04
.LF8F85D:
	bit 6,(XIX)                                   ; F8F85D  b4 ce
	jr nz, .LF8F85D                               ; F8F85F  6e fc
.LF8F861:
	ld (XIX+0x01),0x4f                            ; F8F861  bc 01 00 4f
	and BC,BC                                     ; F8F865  d9 c1
	jr z, .LF8F8BC                                ; F8F867  66 53
	and HL,HL                                     ; F8F869  db c3
	jr z, .LF8F8BC                                ; F8F86B  66 4f
	ld WA,IY                                      ; F8F86D  dd 88
	add	wa, (LCD_CurrentLayerBase:16)                       ; F8F86F  d1 55 25 80
	ld e, 0x00:opc                                   ; F8F873  25 00
.LF8F875:
	bit	0, (0xc6:8)                            ; F8F875  f0 c6 c8
	jr nz, .LF8F87E                               ; F8F878  6e 04
.LF8F87A:
	bit 6,(XIX)                                   ; F8F87A  b4 ce
	jr nz, .LF8F87A                               ; F8F87C  6e fc
.LF8F87E:
	ld (XIX+0x01),0x46                            ; F8F87E  bc 01 00 46
	bit	0, (0xc6:8)                            ; F8F882  f0 c6 c8
	jr nz, .LF8F88B                               ; F8F885  6e 04
.LF8F887:
	bit 6,(XIX)                                   ; F8F887  b4 ce
	jr nz, .LF8F887                               ; F8F889  6e fc
.LF8F88B:
	ld (XIX),A                                    ; F8F88B  b4 41
	bit	0, (0xc6:8)                            ; F8F88D  f0 c6 c8
	jr nz, .LF8F896                               ; F8F890  6e 04
.LF8F892:
	bit 6,(XIX)                                   ; F8F892  b4 ce
	jr nz, .LF8F892                               ; F8F894  6e fc
.LF8F896:
	ld (XIX),W                                    ; F8F896  b4 40
	bit	0, (0xc6:8)                            ; F8F898  f0 c6 c8
	jr nz, .LF8F8A1                               ; F8F89B  6e 04
.LF8F89D:
	bit 6,(XIX)                                   ; F8F89D  b4 ce
	jr nz, .LF8F89D                               ; F8F89F  6e fc
.LF8F8A1:
	ld (XIX+0x01),0x42                            ; F8F8A1  bc 01 00 42
	pushw bc                                      ; F8F8A5  29
	ld BC,HL                                      ; F8F8A6  db 89
.LF8F8A8:
	bit	0, (0xc6:8)                            ; F8F8A8  f0 c6 c8
	jr nz, .LF8F8B1                               ; F8F8AB  6e 04
.LF8F8AD:
	bit 6,(XIX)                                   ; F8F8AD  b4 ce
	jr nz, .LF8F8AD                               ; F8F8AF  6e fc
.LF8F8B1:
	ld (XIX),E                                    ; F8F8B1  b4 45
	djnz16 bc, .LF8F8A8                           ; F8F8B3  d9 1c f2
	popw bc                                       ; F8F8B6  49
	inc 1,WA                                      ; F8F8B7  d8 61
	djnz16 bc, .LF8F875                           ; F8F8B9  d9 1c b9
.LF8F8BC:
	ret                                           ; F8F8BC  0e

; ---------------------------------------------------------------------
; LCD_Svc_1B_EraseRect -- SWI7 service 0x1B: clear the box between (X0,Y0) and (X1,Y1)
;
; Called from: SWI7_ServiceTable slot 0x1B (0xF8EA32)
; Inputs:  the same four coordinate words as the fill and the line draw --
;          (0x2530),(0x2532) = (X0,Y0), (0x2534),(0x2536) = (X1,Y1); (0x2540)
;          selects the layer.
; Outputs: every pixel of the box CLEARED in the current layer, and nothing
;          outside it touched.  (0x2532) is left one past Y1 -- the routine
;          walks Y by incrementing that word in place -- and (0x255A) holds the
;          last cursor address written.  WA, BC, DE, HL, XIX clobbered.
; Evidence: it is the erase counterpart of LCD_Svc_05_FillRect and of
;          LCD_Svc_01_DrawHLine, and three things say so rather than one:
;          1. it calls the SAME two edge-mask helpers, LCD_Rect_LeftEdgeMask
;             (0xF8F767, from 0xF8F926) and LCD_Rect_RightEdgeMask (0xF8F7A4,
;             from 0xF8FA0F), and follows each with `xor A,0xff` before ANDing
;             the mask into the byte it just MREAD -- fill ORs the mask in, this
;             ANDs the complement, which clears exactly those pixels;
;          2. the whole byte-columns between the two ragged ends are written as
;             0x00, where the fill writes 0xFF;
;          3. the address arithmetic is LCD_PlotPointAt's, Y*(0x2557) + X/8 +
;             (0x2555), recomputed for every row, and the cursor advances with
;             CSRDIR RIGHT (0x4C), so it erases one scan line per pass and loops
;             on `incw 1,(0x2532)` until (0x2532) > (0x2536).
; ⚠ Differences from service 0x05 that are NOT cosmetic: this one does NOT call
;          LCD_ClampCoordsToPanel, does NOT force (0x2540), and does NOT touch
;          the OVLAY register.  It erases in whatever layer the caller selected,
;          with whatever composition mode is already programmed, and an
;          out-of-range coordinate is the caller's problem.
; Unknown:  callers.
; ---------------------------------------------------------------------
LCD_Svc_1B_EraseRect:
	calr LCD_SelectCurrentLayer                                   ; F8F8BD  1e d3 f5
	ld XIX,0x00790000                             ; F8F8C0  44 00 00 79 00
.LF8F8C5:
	ld wa, (LCD_Y1:16)                          ; F8F8C5  d1 36 25 20
	cp	(LCD_Y0:16), wa                       ; F8F8C9  d1 32 25 f8
	jrl ugt, .LF8FA5F                             ; F8F8CD  7b 8f 01
	ld wa, (LCD_Y0:16)                          ; F8F8D0  d1 32 25 20
	ld bc, (LCD_BytesPerLine:16)                          ; F8F8D4  d1 57 25 21
	mul xwa, bc                                  ; F8F8D8  d9 40
	ld HL,WA                                      ; F8F8DA  d8 8b
	ld wa, (LCD_X0:16)                          ; F8F8DC  d1 30 25 20
	ldw bc, 0x08                                  ; F8F8E0  31 08 00
	extz XWA                                      ; F8F8E3  e8 12
	div xwa, bc                                  ; F8F8E5  d9 50
	ld DE,QWA                                     ; F8F8E7  d7 e2 8a
	add HL,WA                                     ; F8F8EA  d8 83
	ld wa, (LCD_CurrentLayerBase:16)                          ; F8F8EC  d1 55 25 20
	add WA,HL                                     ; F8F8F0  db 80
	bit	0, (0xc6:8)                            ; F8F8F2  f0 c6 c8
	jr nz, .LF8F8FB                               ; F8F8F5  6e 04
.LF8F8F7:
	bit 6,(XIX)                                   ; F8F8F7  b4 ce
	jr nz, .LF8F8F7                               ; F8F8F9  6e fc
.LF8F8FB:
	ld (XIX+0x01),0x4c                            ; F8F8FB  bc 01 00 4c
	bit	0, (0xc6:8)                            ; F8F8FF  f0 c6 c8
	jr nz, .LF8F908                               ; F8F902  6e 04
.LF8F904:
	bit 6,(XIX)                                   ; F8F904  b4 ce
	jr nz, .LF8F904                               ; F8F906  6e fc
.LF8F908:
	ld (XIX+0x01),0x46                            ; F8F908  bc 01 00 46
	ld (LCD_RunAddress:16), wa                           ; F8F90C  f1 5a 25 50
	bit	0, (0xc6:8)                            ; F8F910  f0 c6 c8
	jr nz, .LF8F919                               ; F8F913  6e 04
.LF8F915:
	bit 6,(XIX)                                   ; F8F915  b4 ce
	jr nz, .LF8F915                               ; F8F917  6e fc
.LF8F919:
	ld (XIX),A                                    ; F8F919  b4 41
	bit	0, (0xc6:8)                            ; F8F91B  f0 c6 c8
	jr nz, .LF8F924                               ; F8F91E  6e 04
.LF8F920:
	bit 6,(XIX)                                   ; F8F920  b4 ce
	jr nz, .LF8F920                               ; F8F922  6e fc
.LF8F924:
	ld (XIX),W                                    ; F8F924  b4 40
	calr LCD_Rect_LeftEdgeMask                                   ; F8F926  1e 3e fe
	xor A,0xff                                    ; F8F929  c9 cd ff
	and DE,DE                                     ; F8F92C  da c2
	jr z, .LF8F98A                                ; F8F92E  66 5a
	ld (XIX+0x01),0x43                            ; F8F930  bc 01 00 43
	bit	0, (0xc6:8)                            ; F8F934  f0 c6 c8
	jr nz, .LF8F93D                               ; F8F937  6e 04
.LF8F939:
	bit 6,(XIX)                                   ; F8F939  b4 ce
	jr nz, .LF8F939                               ; F8F93B  6e fc
.LF8F93D:
	ld W,(XIX+0x01)                               ; F8F93D  8c 01 20
	and W,A                                       ; F8F940  c9 c0
	ld C,W                                        ; F8F942  c8 8b
	bit	0, (0xc6:8)                            ; F8F944  f0 c6 c8
	jr nz, .LF8F94D                               ; F8F947  6e 04
.LF8F949:
	bit 6,(XIX)                                   ; F8F949  b4 ce
	jr nz, .LF8F949                               ; F8F94B  6e fc
.LF8F94D:
	ld (XIX+0x01),0x46                            ; F8F94D  bc 01 00 46
	ld wa, (LCD_RunAddress:16)                          ; F8F951  d1 5a 25 20
	bit	0, (0xc6:8)                            ; F8F955  f0 c6 c8
	jr nz, .LF8F95E                               ; F8F958  6e 04
.LF8F95A:
	bit 6,(XIX)                                   ; F8F95A  b4 ce
	jr nz, .LF8F95A                               ; F8F95C  6e fc
.LF8F95E:
	ld (XIX),A                                    ; F8F95E  b4 41
	bit	0, (0xc6:8)                            ; F8F960  f0 c6 c8
	jr nz, .LF8F969                               ; F8F963  6e 04
.LF8F965:
	bit 6,(XIX)                                   ; F8F965  b4 ce
	jr nz, .LF8F965                               ; F8F967  6e fc
.LF8F969:
	ld (XIX),W                                    ; F8F969  b4 40
	bit	0, (0xc6:8)                            ; F8F96B  f0 c6 c8
	jr nz, .LF8F974                               ; F8F96E  6e 04
.LF8F970:
	bit 6,(XIX)                                   ; F8F970  b4 ce
	jr nz, .LF8F970                               ; F8F972  6e fc
.LF8F974:
	ld (XIX+0x01),0x42                            ; F8F974  bc 01 00 42
	bit	0, (0xc6:8)                            ; F8F978  f0 c6 c8
	jr nz, .LF8F981                               ; F8F97B  6e 04
.LF8F97D:
	bit 6,(XIX)                                   ; F8F97D  b4 ce
	jr nz, .LF8F97D                               ; F8F97F  6e fc
.LF8F981:
	ld (XIX),C                                    ; F8F981  b4 43
	ldw hl, 0x08                                  ; F8F983  33 08 00
	sub HL,DE                                     ; F8F986  da a3
	ex16 hl, de                                   ; F8F988  da bb
.LF8F98A:
	ld wa, (LCD_X1:16)                          ; F8F98A  d1 34 25 20
	sub	wa, (LCD_X0:16)                       ; F8F98E  d1 30 25 a0
	inc 1,WA                                      ; F8F992  d8 61
	cp WA,DE                                      ; F8F994  da f0
	jrl ule, .LF8FA58                             ; F8F996  73 bf 00
	sub WA,DE                                     ; F8F999  da a0
	ldw bc, 0x08                                  ; F8F99B  31 08 00
	extz XWA                                      ; F8F99E  e8 12
	div xwa, bc                                  ; F8F9A0  d9 50
	ld DE,QWA                                     ; F8F9A2  d7 e2 8a
	and WA,WA                                     ; F8F9A5  d8 c0
	jr z, .LF8F9C8                                ; F8F9A7  66 1f
	ld BC,WA                                      ; F8F9A9  d8 89
	bit	0, (0xc6:8)                            ; F8F9AB  f0 c6 c8
	jr nz, .LF8F9B4                               ; F8F9AE  6e 04
.LF8F9B0:
	bit 6,(XIX)                                   ; F8F9B0  b4 ce
	jr nz, .LF8F9B0                               ; F8F9B2  6e fc
.LF8F9B4:
	ld (XIX+0x01),0x42                            ; F8F9B4  bc 01 00 42
	ld a, 0x00:opc                                   ; F8F9B8  21 00
.LF8F9BA:
	bit	0, (0xc6:8)                            ; F8F9BA  f0 c6 c8
	jr nz, .LF8F9C3                               ; F8F9BD  6e 04
.LF8F9BF:
	bit 6,(XIX)                                   ; F8F9BF  b4 ce
	jr nz, .LF8F9BF                               ; F8F9C1  6e fc
.LF8F9C3:
	ld (XIX),A                                    ; F8F9C3  b4 41
	djnz16 bc, .LF8F9BA                           ; F8F9C5  d9 1c f2
.LF8F9C8:
	and DE,DE                                     ; F8F9C8  da c2
	jrl z, .LF8FA58                               ; F8F9CA  76 8b 00
	bit	0, (0xc6:8)                            ; F8F9CD  f0 c6 c8
	jr nz, .LF8F9D6                               ; F8F9D0  6e 04
.LF8F9D2:
	bit 6,(XIX)                                   ; F8F9D2  b4 ce
	jr nz, .LF8F9D2                               ; F8F9D4  6e fc
.LF8F9D6:
	ld (XIX+0x01),0x47                            ; F8F9D6  bc 01 00 47
	bit	0, (0xc6:8)                            ; F8F9DA  f0 c6 c8
	jr nz, .LF8F9E3                               ; F8F9DD  6e 04
.LF8F9DF:
	bit 6,(XIX)                                   ; F8F9DF  b4 ce
	jr nz, .LF8F9DF                               ; F8F9E1  6e fc
.LF8F9E3:
	ld A,(XIX+0x01)                               ; F8F9E3  8c 01 21
	bit	0, (0xc6:8)                            ; F8F9E6  f0 c6 c8
	jr nz, .LF8F9EF                               ; F8F9E9  6e 04
.LF8F9EB:
	bit 6,(XIX)                                   ; F8F9EB  b4 ce
	jr nz, .LF8F9EB                               ; F8F9ED  6e fc
.LF8F9EF:
	ld W,(XIX+0x01)                               ; F8F9EF  8c 01 20
	ld (LCD_RunAddress:16), wa                           ; F8F9F2  f1 5a 25 50
	bit	0, (0xc6:8)                            ; F8F9F6  f0 c6 c8
	jr nz, .LF8F9FF                               ; F8F9F9  6e 04
.LF8F9FB:
	bit 6,(XIX)                                   ; F8F9FB  b4 ce
	jr nz, .LF8F9FB                               ; F8F9FD  6e fc
.LF8F9FF:
	ld (XIX+0x01),0x43                            ; F8F9FF  bc 01 00 43
	bit	0, (0xc6:8)                            ; F8FA03  f0 c6 c8
	jr nz, .LF8FA0C                               ; F8FA06  6e 04
.LF8FA08:
	bit 6,(XIX)                                   ; F8FA08  b4 ce
	jr nz, .LF8FA08                               ; F8FA0A  6e fc
.LF8FA0C:
	ld W,(XIX+0x01)                               ; F8FA0C  8c 01 20
	calr LCD_Rect_RightEdgeMask                                   ; F8FA0F  1e 92 fd
	xor A,0xff                                    ; F8FA12  c9 cd ff
	and W,A                                       ; F8FA15  c9 c0
	ld C,W                                        ; F8FA17  c8 8b
	bit	0, (0xc6:8)                            ; F8FA19  f0 c6 c8
	jr nz, .LF8FA22                               ; F8FA1C  6e 04
.LF8FA1E:
	bit 6,(XIX)                                   ; F8FA1E  b4 ce
	jr nz, .LF8FA1E                               ; F8FA20  6e fc
.LF8FA22:
	ld (XIX+0x01),0x46                            ; F8FA22  bc 01 00 46
	ld wa, (LCD_RunAddress:16)                          ; F8FA26  d1 5a 25 20
	bit	0, (0xc6:8)                            ; F8FA2A  f0 c6 c8
	jr nz, .LF8FA33                               ; F8FA2D  6e 04
.LF8FA2F:
	bit 6,(XIX)                                   ; F8FA2F  b4 ce
	jr nz, .LF8FA2F                               ; F8FA31  6e fc
.LF8FA33:
	ld (XIX),A                                    ; F8FA33  b4 41
	bit	0, (0xc6:8)                            ; F8FA35  f0 c6 c8
	jr nz, .LF8FA3E                               ; F8FA38  6e 04
.LF8FA3A:
	bit 6,(XIX)                                   ; F8FA3A  b4 ce
	jr nz, .LF8FA3A                               ; F8FA3C  6e fc
.LF8FA3E:
	ld (XIX),W                                    ; F8FA3E  b4 40
	bit	0, (0xc6:8)                            ; F8FA40  f0 c6 c8
	jr nz, .LF8FA49                               ; F8FA43  6e 04
.LF8FA45:
	bit 6,(XIX)                                   ; F8FA45  b4 ce
	jr nz, .LF8FA45                               ; F8FA47  6e fc
.LF8FA49:
	ld (XIX+0x01),0x42                            ; F8FA49  bc 01 00 42
	bit	0, (0xc6:8)                            ; F8FA4D  f0 c6 c8
	jr nz, .LF8FA56                               ; F8FA50  6e 04
.LF8FA52:
	bit 6,(XIX)                                   ; F8FA52  b4 ce
	jr nz, .LF8FA52                               ; F8FA54  6e fc
.LF8FA56:
	ld (XIX),C                                    ; F8FA56  b4 43
.LF8FA58:
	incw 0x01, (LCD_Y0:16)                        ; F8FA58  d1 32 25 61
	jrl .LF8F8C5                                  ; F8FA5C  78 66 fe
.LF8FA5F:
	ret                                           ; F8FA5F  0e

; ---------------------------------------------------------------------
; LCD_Svc_0F_SetPanel2Layer -- SWI7 service 0x0F: reprogramme the panel with
; TWO composed layers
;
; Called from: SWI7_ServiceTable slot 0x0F (0xF8EA02)
; Inputs:  none
; Outputs: the controller re-initialised: SYSTEM SET with the same geometry as
;          the power-on setup, SCROLL with only SIX parameter bytes (SAD1 =
;          0x0000, SL1 = 240, SAD2 = 0x4000, SL2 = 240 -- no SAD3), OVLAY 0x0C,
;          DISP OFF, CSRDIR RIGHT, CSRW 0x0000, MWRITE and 0x0658 * 16 = 25984
;          zero bytes, then DISP ON.  (0x2557)/(0x2558) = AP = 0x0028;
;          (0x2541) = 0x0000; (0x2543) = 0x4000; (0x2554) = 0x0C.
;          WA, BC and XIY clobbered.
; Evidence: OVLAY 0x0C is what makes this the TWO-layer mode, and it is decoded
;          rather than guessed: MAME's sed1330_device splits the OVLAY byte as
;          MX = bits[1:0], DM1 = bit 2, DM2 = bit 3, OV = bit 4
;          (../mame/src/devices/video/sed1330.cpp:546-561, which logs bit 4 as
;          "Display Composition Layers: 3 or 2").  0x0C = MX 0 (OR), DM1 and DM2
;          both GRAPHICS, **OV = 0 -> two layers**, against the 0x1C that
;          LCD_Init_SED1330 and service 0x10 send, whose OV = 1 -> three.
;          The SCROLL parameter count agrees independently: six bytes here,
;          eight there, and six is exactly SAD1/SL1/SAD2/SL2 with SAD3 omitted.
;          So does the clear count: 240 lines * 40 bytes = 0x2580 per layer, the
;          higher layer is based at 0x4000, and 0x4000 + 0x2580 = 0x6580 = the
;          25984 bytes this routine zeroes -- it clears display RAM up to the
;          end of the LAST layer and no further.  (Service 0x10's count is
;          0x7180 = 0x4C00 + 0x2580 by the same arithmetic; the power-on setup,
;          which cannot assume either layout, zeroes all 32768.)
; Notes:   like LCD_Init_SED1330 it never polls BUSY -- runs of NOPs separate the
;          accesses instead.  Unlike the power-on setup it sends no HDOT SCR and
;          no CSRFORM, and its DISP OFF and DISP ON carry NO parameter byte, so
;          the controller keeps whatever layer-visibility byte services 0x0C and
;          0x0D last programmed and (0x2559) stays valid.
; ⚠ Unknown, and it matters: (0x2545) -- firmware layer 2's base -- is NOT
;          updated here, because the two-layer arrangement has no third layer.
;          A drawing service called with (0x2540) = 2 after this one runs will
;          therefore aim at whatever base was left over from the three-layer
;          mode.  Whether the UI ever does that is not traced.
; ⚠ Also unknown: which of the two modes the instrument actually runs in, and
;          what switches it.  No caller of either service is traced.
; ---------------------------------------------------------------------
LCD_Svc_0F_SetPanel2Layer:
	ld XIY,0x00790000                             ; F8FA60  45 00 00 79 00
	ld (XIY+0x01),0x40                            ; F8FA65  bd 01 00 40
	nop                                           ; F8FA69  00
	nop                                           ; F8FA6A  00
	nop                                           ; F8FA6B  00
	nop                                           ; F8FA6C  00
	ld (XIY),0x30                                 ; F8FA6D  b5 00 30
	nop                                           ; F8FA70  00
	nop                                           ; F8FA71  00
	nop                                           ; F8FA72  00
	nop                                           ; F8FA73  00
	ld (XIY),0x07                                 ; F8FA74  b5 00 07
	nop                                           ; F8FA77  00
	nop                                           ; F8FA78  00
	nop                                           ; F8FA79  00
	nop                                           ; F8FA7A  00
	ld (XIY),0x00                                 ; F8FA7B  b5 00 00
	nop                                           ; F8FA7E  00
	nop                                           ; F8FA7F  00
	nop                                           ; F8FA80  00
	nop                                           ; F8FA81  00
	ld (XIY),0x27                                 ; F8FA82  b5 00 27
	nop                                           ; F8FA85  00
	nop                                           ; F8FA86  00
	nop                                           ; F8FA87  00
	nop                                           ; F8FA88  00
	ld (XIY),0x35                                 ; F8FA89  b5 00 35
	nop                                           ; F8FA8C  00
	nop                                           ; F8FA8D  00
	nop                                           ; F8FA8E  00
	nop                                           ; F8FA8F  00
	ld (XIY),0xef                                 ; F8FA90  b5 00 ef
	ld a, 0x28:opc                                   ; F8FA93  21 28
	ld (XIY),A                                    ; F8FA95  b5 41
	ld (LCD_BytesPerLine:16), a                            ; F8FA97  f1 57 25 41
	nop                                           ; F8FA9B  00
	nop                                           ; F8FA9C  00
	ld a, 0x00:opc                                   ; F8FA9D  21 00
	ld (XIY),A                                    ; F8FA9F  b5 41
	ld (LCD_BytesPerLine_Hi:16), a                            ; F8FAA1  f1 58 25 41
	nop                                           ; F8FAA5  00
	nop                                           ; F8FAA6  00
	ld (XIY+0x01),0x44                            ; F8FAA7  bd 01 00 44
	nop                                           ; F8FAAB  00
	nop                                           ; F8FAAC  00
	nop                                           ; F8FAAD  00
	nop                                           ; F8FAAE  00
	ld (XIY),0x00                                 ; F8FAAF  b5 00 00
	nop                                           ; F8FAB2  00
	nop                                           ; F8FAB3  00
	nop                                           ; F8FAB4  00
	nop                                           ; F8FAB5  00
	ld (XIY),0x00                                 ; F8FAB6  b5 00 00
	nop                                           ; F8FAB9  00
	nop                                           ; F8FABA  00
	nop                                           ; F8FABB  00
	nop                                           ; F8FABC  00
	ld (XIY),0xf0                                 ; F8FABD  b5 00 f0
	nop                                           ; F8FAC0  00
	nop                                           ; F8FAC1  00
	nop                                           ; F8FAC2  00
	nop                                           ; F8FAC3  00
	ld (XIY),0x00                                 ; F8FAC4  b5 00 00
	nop                                           ; F8FAC7  00
	nop                                           ; F8FAC8  00
	nop                                           ; F8FAC9  00
	nop                                           ; F8FACA  00
	ld (XIY),0x40                                 ; F8FACB  b5 00 40
	nop                                           ; F8FACE  00
	nop                                           ; F8FACF  00
	nop                                           ; F8FAD0  00
	nop                                           ; F8FAD1  00
	ld (XIY),0xf0                                 ; F8FAD2  b5 00 f0
	ld a, 0x00:opc                                   ; F8FAD5  21 00
	ld w, 0x00:opc                                   ; F8FAD7  20 00
	ld (LCD_Layer0_SAD:16), wa                           ; F8FAD9  f1 41 25 50
	ld a, 0x00:opc                                   ; F8FADD  21 00
	ld w, 0x40:opc                                   ; F8FADF  20 40
	ld (LCD_Layer1_SAD:16), wa                           ; F8FAE1  f1 43 25 50
	ld (XIY+0x01),0x5b                            ; F8FAE5  bd 01 00 5b
	nop                                           ; F8FAE9  00
	nop                                           ; F8FAEA  00
	nop                                           ; F8FAEB  00
	ld (XIY),0x0c                                 ; F8FAEC  b5 00 0c
	ld (LCD_OvlayShadow:16), 0x0c                          ; F8FAEF  f1 54 25 00 0c
	nop                                           ; F8FAF4  00
	nop                                           ; F8FAF5  00
	nop                                           ; F8FAF6  00
	ld (XIY+0x01),0x58                            ; F8FAF7  bd 01 00 58
	nop                                           ; F8FAFB  00
	nop                                           ; F8FAFC  00
	nop                                           ; F8FAFD  00
	nop                                           ; F8FAFE  00
	ld (XIY+0x01),0x4c                            ; F8FAFF  bd 01 00 4c
	nop                                           ; F8FB03  00
	nop                                           ; F8FB04  00
	nop                                           ; F8FB05  00
	nop                                           ; F8FB06  00
	ld (XIY+0x01),0x46                            ; F8FB07  bd 01 00 46
	xor WA,WA                                     ; F8FB0B  d8 d0
	nop                                           ; F8FB0D  00
	nop                                           ; F8FB0E  00
	nop                                           ; F8FB0F  00
	nop                                           ; F8FB10  00
	ld (XIY),W                                    ; F8FB11  b5 40
	nop                                           ; F8FB13  00
	nop                                           ; F8FB14  00
	nop                                           ; F8FB15  00
	nop                                           ; F8FB16  00
	ld (XIY),A                                    ; F8FB17  b5 41
	nop                                           ; F8FB19  00
	nop                                           ; F8FB1A  00
	nop                                           ; F8FB1B  00
	ld (XIY+0x01),0x42                            ; F8FB1C  bd 01 00 42
	ldw bc, 0x0658                                ; F8FB20  31 58 06
.LF8FB23:
	nop                                           ; F8FB23  00
	nop                                           ; F8FB24  00
	nop                                           ; F8FB25  00
	ld (XIY),A                                    ; F8FB26  b5 41
	nop                                           ; F8FB28  00
	nop                                           ; F8FB29  00
	nop                                           ; F8FB2A  00
	ld (XIY),A                                    ; F8FB2B  b5 41
	nop                                           ; F8FB2D  00
	nop                                           ; F8FB2E  00
	nop                                           ; F8FB2F  00
	ld (XIY),A                                    ; F8FB30  b5 41
	nop                                           ; F8FB32  00
	nop                                           ; F8FB33  00
	nop                                           ; F8FB34  00
	ld (XIY),A                                    ; F8FB35  b5 41
	nop                                           ; F8FB37  00
	nop                                           ; F8FB38  00
	nop                                           ; F8FB39  00
	ld (XIY),A                                    ; F8FB3A  b5 41
	nop                                           ; F8FB3C  00
	nop                                           ; F8FB3D  00
	nop                                           ; F8FB3E  00
	ld (XIY),A                                    ; F8FB3F  b5 41
	nop                                           ; F8FB41  00
	nop                                           ; F8FB42  00
	nop                                           ; F8FB43  00
	ld (XIY),A                                    ; F8FB44  b5 41
	nop                                           ; F8FB46  00
	nop                                           ; F8FB47  00
	nop                                           ; F8FB48  00
	ld (XIY),A                                    ; F8FB49  b5 41
	nop                                           ; F8FB4B  00
	nop                                           ; F8FB4C  00
	nop                                           ; F8FB4D  00
	ld (XIY),A                                    ; F8FB4E  b5 41
	nop                                           ; F8FB50  00
	nop                                           ; F8FB51  00
	nop                                           ; F8FB52  00
	ld (XIY),A                                    ; F8FB53  b5 41
	nop                                           ; F8FB55  00
	nop                                           ; F8FB56  00
	nop                                           ; F8FB57  00
	ld (XIY),A                                    ; F8FB58  b5 41
	nop                                           ; F8FB5A  00
	nop                                           ; F8FB5B  00
	nop                                           ; F8FB5C  00
	ld (XIY),A                                    ; F8FB5D  b5 41
	nop                                           ; F8FB5F  00
	nop                                           ; F8FB60  00
	nop                                           ; F8FB61  00
	ld (XIY),A                                    ; F8FB62  b5 41
	nop                                           ; F8FB64  00
	nop                                           ; F8FB65  00
	nop                                           ; F8FB66  00
	ld (XIY),A                                    ; F8FB67  b5 41
	nop                                           ; F8FB69  00
	nop                                           ; F8FB6A  00
	nop                                           ; F8FB6B  00
	ld (XIY),A                                    ; F8FB6C  b5 41
	nop                                           ; F8FB6E  00
	nop                                           ; F8FB6F  00
	nop                                           ; F8FB70  00
	ld (XIY),A                                    ; F8FB71  b5 41
	djnz16 bc, .LF8FB23                           ; F8FB73  d9 1c ad
	nop                                           ; F8FB76  00
	nop                                           ; F8FB77  00
	nop                                           ; F8FB78  00
	ld (XIY+0x01),0x59                            ; F8FB79  bd 01 00 59
	ret                                           ; F8FB7D  0e

; ---------------------------------------------------------------------
; LCD_Svc_10_SetPanel3Layer -- SWI7 service 0x10: reprogramme the panel with
; THREE composed layers -- the arrangement the power-on setup leaves
;
; Called from: SWI7_ServiceTable slot 0x10 (0xF8EA06)
; Inputs:  none
; Outputs: as service 0x0F but with the three-layer geometry: SCROLL with EIGHT
;          parameter bytes (SAD1 = 0x0000, SL1 = 240, SAD2 = 0x2600, SL2 = 240,
;          SAD3 = 0x4C00), OVLAY 0x1C, and 0x0718 * 16 = 29056 zero bytes.
;          (0x2541) = 0x0000, (0x2543) = 0x2600, (0x2545) = 0x4C00,
;          (0x2554) = 0x1C, (0x2557)/(0x2558) = AP = 0x0028.
; Evidence: the SYSTEM SET and SCROLL parameter bytes are the SAME eight and
;          eight that LCD_Init_SED1330 sends -- 30 07 00 27 35 EF 28 00 and
;          00 00 F0 00 26 F0 00 4C -- and the three RAM words it writes are the
;          three the layer table points at.  The clear count is 0x4C00 + 240*40
;          = 0x7180 = 29056, the end of the highest layer.  All of that is
;          re-read from the ROM by notes/prom_a_byte_checks.py.
; Notes:   this service is NOT a copy of LCD_Init_SED1330: 308 bytes against the
;          setup's 390, because it omits HDOT SCR, CSRFORM and the parametered
;          DISP OFF, and because its clear loop stops at the end of layer 2
;          instead of at the end of display RAM.  The pair 0x0F / 0x10 is a
;          MODE SWITCH; the power-on setup is a superset of 0x10.
; Unknown:  callers, as for 0x0F.
; ---------------------------------------------------------------------
LCD_Svc_10_SetPanel3Layer:
	ld XIY,0x00790000                             ; F8FB7E  45 00 00 79 00
	ld (XIY+0x01),0x40                            ; F8FB83  bd 01 00 40
	nop                                           ; F8FB87  00
	nop                                           ; F8FB88  00
	nop                                           ; F8FB89  00
	nop                                           ; F8FB8A  00
	ld (XIY),0x30                                 ; F8FB8B  b5 00 30
	nop                                           ; F8FB8E  00
	nop                                           ; F8FB8F  00
	nop                                           ; F8FB90  00
	nop                                           ; F8FB91  00
	ld (XIY),0x07                                 ; F8FB92  b5 00 07
	nop                                           ; F8FB95  00
	nop                                           ; F8FB96  00
	nop                                           ; F8FB97  00
	nop                                           ; F8FB98  00
	ld (XIY),0x00                                 ; F8FB99  b5 00 00
	nop                                           ; F8FB9C  00
	nop                                           ; F8FB9D  00
	nop                                           ; F8FB9E  00
	nop                                           ; F8FB9F  00
	ld (XIY),0x27                                 ; F8FBA0  b5 00 27
	nop                                           ; F8FBA3  00
	nop                                           ; F8FBA4  00
	nop                                           ; F8FBA5  00
	nop                                           ; F8FBA6  00
	ld (XIY),0x35                                 ; F8FBA7  b5 00 35
	nop                                           ; F8FBAA  00
	nop                                           ; F8FBAB  00
	nop                                           ; F8FBAC  00
	nop                                           ; F8FBAD  00
	ld (XIY),0xef                                 ; F8FBAE  b5 00 ef
	ld a, 0x28:opc                                   ; F8FBB1  21 28
	ld (XIY),A                                    ; F8FBB3  b5 41
	ld (LCD_BytesPerLine:16), a                            ; F8FBB5  f1 57 25 41
	nop                                           ; F8FBB9  00
	nop                                           ; F8FBBA  00
	ld a, 0x00:opc                                   ; F8FBBB  21 00
	ld (XIY),A                                    ; F8FBBD  b5 41
	ld (LCD_BytesPerLine_Hi:16), a                            ; F8FBBF  f1 58 25 41
	nop                                           ; F8FBC3  00
	nop                                           ; F8FBC4  00
	ld (XIY+0x01),0x44                            ; F8FBC5  bd 01 00 44
	nop                                           ; F8FBC9  00
	nop                                           ; F8FBCA  00
	nop                                           ; F8FBCB  00
	ld (XIY),0x00                                 ; F8FBCC  b5 00 00
	nop                                           ; F8FBCF  00
	nop                                           ; F8FBD0  00
	nop                                           ; F8FBD1  00
	ld (XIY),0x00                                 ; F8FBD2  b5 00 00
	nop                                           ; F8FBD5  00
	nop                                           ; F8FBD6  00
	nop                                           ; F8FBD7  00
	ld (XIY),0xf0                                 ; F8FBD8  b5 00 f0
	nop                                           ; F8FBDB  00
	nop                                           ; F8FBDC  00
	nop                                           ; F8FBDD  00
	ld (XIY),0x00                                 ; F8FBDE  b5 00 00
	nop                                           ; F8FBE1  00
	nop                                           ; F8FBE2  00
	nop                                           ; F8FBE3  00
	ld (XIY),0x26                                 ; F8FBE4  b5 00 26
	nop                                           ; F8FBE7  00
	nop                                           ; F8FBE8  00
	nop                                           ; F8FBE9  00
	ld (XIY),0xf0                                 ; F8FBEA  b5 00 f0
	nop                                           ; F8FBED  00
	nop                                           ; F8FBEE  00
	nop                                           ; F8FBEF  00
	ld (XIY),0x00                                 ; F8FBF0  b5 00 00
	nop                                           ; F8FBF3  00
	nop                                           ; F8FBF4  00
	nop                                           ; F8FBF5  00
	ld (XIY),0x4c                                 ; F8FBF6  b5 00 4c
	ld a, 0x00:opc                                   ; F8FBF9  21 00
	ld w, 0x00:opc                                   ; F8FBFB  20 00
	ld (LCD_Layer0_SAD:16), wa                           ; F8FBFD  f1 41 25 50
	ld a, 0x00:opc                                   ; F8FC01  21 00
	ld w, 0x26:opc                                   ; F8FC03  20 26
	ld (LCD_Layer1_SAD:16), wa                           ; F8FC05  f1 43 25 50
	ld a, 0x00:opc                                   ; F8FC09  21 00
	ld w, 0x4c:opc                                   ; F8FC0B  20 4c
	ld (LCD_Layer2_SAD:16), wa                           ; F8FC0D  f1 45 25 50
	ld (XIY+0x01),0x5b                            ; F8FC11  bd 01 00 5b
	nop                                           ; F8FC15  00
	nop                                           ; F8FC16  00
	nop                                           ; F8FC17  00
	ld (XIY),0x1c                                 ; F8FC18  b5 00 1c
	ld (LCD_OvlayShadow:16), 0x1c                          ; F8FC1B  f1 54 25 00 1c
	nop                                           ; F8FC20  00
	nop                                           ; F8FC21  00
	ld (XIY+0x01),0x58                            ; F8FC22  bd 01 00 58
	nop                                           ; F8FC26  00
	nop                                           ; F8FC27  00
	nop                                           ; F8FC28  00
	nop                                           ; F8FC29  00
	ld (XIY+0x01),0x4c                            ; F8FC2A  bd 01 00 4c
	nop                                           ; F8FC2E  00
	nop                                           ; F8FC2F  00
	nop                                           ; F8FC30  00
	nop                                           ; F8FC31  00
	nop                                           ; F8FC32  00
	ld (XIY+0x01),0x46                            ; F8FC33  bd 01 00 46
	xor WA,WA                                     ; F8FC37  d8 d0
	nop                                           ; F8FC39  00
	nop                                           ; F8FC3A  00
	nop                                           ; F8FC3B  00
	nop                                           ; F8FC3C  00
	nop                                           ; F8FC3D  00
	nop                                           ; F8FC3E  00
	nop                                           ; F8FC3F  00
	ld (XIY),W                                    ; F8FC40  b5 40
	nop                                           ; F8FC42  00
	nop                                           ; F8FC43  00
	nop                                           ; F8FC44  00
	nop                                           ; F8FC45  00
	nop                                           ; F8FC46  00
	nop                                           ; F8FC47  00
	nop                                           ; F8FC48  00
	nop                                           ; F8FC49  00
	ld (XIY),A                                    ; F8FC4A  b5 41
	nop                                           ; F8FC4C  00
	nop                                           ; F8FC4D  00
	nop                                           ; F8FC4E  00
	nop                                           ; F8FC4F  00
	ld (XIY+0x01),0x42                            ; F8FC50  bd 01 00 42
	ldw bc, 0x0718                                ; F8FC54  31 18 07
.LF8FC57:
	nop                                           ; F8FC57  00
	nop                                           ; F8FC58  00
	nop                                           ; F8FC59  00
	ld (XIY),A                                    ; F8FC5A  b5 41
	nop                                           ; F8FC5C  00
	nop                                           ; F8FC5D  00
	nop                                           ; F8FC5E  00
	ld (XIY),A                                    ; F8FC5F  b5 41
	nop                                           ; F8FC61  00
	nop                                           ; F8FC62  00
	nop                                           ; F8FC63  00
	ld (XIY),A                                    ; F8FC64  b5 41
	nop                                           ; F8FC66  00
	nop                                           ; F8FC67  00
	nop                                           ; F8FC68  00
	ld (XIY),A                                    ; F8FC69  b5 41
	nop                                           ; F8FC6B  00
	nop                                           ; F8FC6C  00
	nop                                           ; F8FC6D  00
	ld (XIY),A                                    ; F8FC6E  b5 41
	nop                                           ; F8FC70  00
	nop                                           ; F8FC71  00
	nop                                           ; F8FC72  00
	ld (XIY),A                                    ; F8FC73  b5 41
	nop                                           ; F8FC75  00
	nop                                           ; F8FC76  00
	nop                                           ; F8FC77  00
	ld (XIY),A                                    ; F8FC78  b5 41
	nop                                           ; F8FC7A  00
	nop                                           ; F8FC7B  00
	nop                                           ; F8FC7C  00
	ld (XIY),A                                    ; F8FC7D  b5 41
	nop                                           ; F8FC7F  00
	nop                                           ; F8FC80  00
	nop                                           ; F8FC81  00
	ld (XIY),A                                    ; F8FC82  b5 41
	nop                                           ; F8FC84  00
	nop                                           ; F8FC85  00
	nop                                           ; F8FC86  00
	ld (XIY),A                                    ; F8FC87  b5 41
	nop                                           ; F8FC89  00
	nop                                           ; F8FC8A  00
	nop                                           ; F8FC8B  00
	ld (XIY),A                                    ; F8FC8C  b5 41
	nop                                           ; F8FC8E  00
	nop                                           ; F8FC8F  00
	nop                                           ; F8FC90  00
	ld (XIY),A                                    ; F8FC91  b5 41
	nop                                           ; F8FC93  00
	nop                                           ; F8FC94  00
	nop                                           ; F8FC95  00
	ld (XIY),A                                    ; F8FC96  b5 41
	nop                                           ; F8FC98  00
	nop                                           ; F8FC99  00
	nop                                           ; F8FC9A  00
	ld (XIY),A                                    ; F8FC9B  b5 41
	nop                                           ; F8FC9D  00
	nop                                           ; F8FC9E  00
	nop                                           ; F8FC9F  00
	ld (XIY),A                                    ; F8FCA0  b5 41
	nop                                           ; F8FCA2  00
	nop                                           ; F8FCA3  00
	nop                                           ; F8FCA4  00
	ld (XIY),A                                    ; F8FCA5  b5 41
	djnz16 bc, .LF8FC57                           ; F8FCA7  d9 1c ad
	nop                                           ; F8FCAA  00
	nop                                           ; F8FCAB  00
	nop                                           ; F8FCAC  00
	ld (XIY+0x01),0x59                            ; F8FCAD  bd 01 00 59
	ret                                           ; F8FCB1  0e

; ---------------------------------------------------------------------
; LCD_Svc_11_DrawHLineDither -- SWI7 service 0x11: a horizontal run drawn with
; the 0xCC dither instead of solid pixels
;
; Called from: SWI7_ServiceTable slot 0x11 (0xF8EA0A), and from
;          LCD_Svc_13_DrawBoxPatterned (0xF8F475 and 0xF8F484, both converted)
; Inputs:  (0x2530) = X0, (0x2534) = X1, (0x2532) = Y; (0x2540) the layer
; Outputs: the pattern OR'd into the run; (0x255A) = the first byte's display
;          address; (0x255E) = the pattern byte used for the whole bytes; the
;          four coordinate words clamped in place.
; Evidence: it is LCD_Svc_01_DrawHLine with the two constants replaced.  The
;          solid version ORs LCD_Rect_LeftEdgeMask's mask into the ragged first
;          byte, then whole 0xFF bytes, then LCD_Rect_RightEdgeMask's mask; this
;          one calls LCD_Dither_FetchMasks instead of the left-edge helper,
;          writes (0x255E) instead of 0xFF for the whole bytes, and
;          LCD_Dither_RightEdgeMask instead of the right-edge helper.  Same
;          CSRDIR RIGHT, same address arithmetic, same three-phase byte walk.
;          ⚠ It also uses `divs` where service 0x01 uses `div` for X0/8 -- a
;          SIGNED divide of a coordinate that has just been clamped to 0..319,
;          so the two agree on every reachable input.
; Unknown:  callers other than service 0x13.
; ---------------------------------------------------------------------
LCD_Svc_11_DrawHLineDither:
	calr (0xF8EE93 - 0xF8FCB5)                                   ; F8FCB2  1e de f1
	calr (0xF8EB6B - 0xF8FCB8)                                   ; F8FCB5  1e b3 ee
	ld XIX,0x00790000                             ; F8FCB8  44 00 00 79 00
	ld wa, (LCD_Y0:16)                          ; F8FCBD  d1 32 25 20
	ld bc, (LCD_BytesPerLine:16)                          ; F8FCC1  d1 57 25 21
	mul xwa, bc                                  ; F8FCC5  d9 40
	ld HL,WA                                      ; F8FCC7  d8 8b
	ld wa, (LCD_X0:16)                          ; F8FCC9  d1 30 25 20
	extz XWA                                      ; F8FCCD  e8 12
	ldw bc, 0x08                                  ; F8FCCF  31 08 00
	divs xwa, bc                                 ; F8FCD2  d9 58
	ld DE,QWA                                     ; F8FCD4  d7 e2 8a
	add HL,WA                                     ; F8FCD7  d8 83
	ld wa, (LCD_CurrentLayerBase:16)                          ; F8FCD9  d1 55 25 20
	add WA,HL                                     ; F8FCDD  db 80
	bit	0, (0xc6:8)                            ; F8FCDF  f0 c6 c8
	jr nz, .LF8FCE8                               ; F8FCE2  6e 04
.LF8FCE4:
	bit 6,(XIX)                                   ; F8FCE4  b4 ce
	jr nz, .LF8FCE4                               ; F8FCE6  6e fc
.LF8FCE8:
	ld (XIX+0x01),0x4c                            ; F8FCE8  bc 01 00 4c
	bit	0, (0xc6:8)                            ; F8FCEC  f0 c6 c8
	jr nz, .LF8FCF5                               ; F8FCEF  6e 04
.LF8FCF1:
	bit 6,(XIX)                                   ; F8FCF1  b4 ce
	jr nz, .LF8FCF1                               ; F8FCF3  6e fc
.LF8FCF5:
	ld (XIX+0x01),0x46                            ; F8FCF5  bc 01 00 46
	ld (LCD_RunAddress:16), wa                           ; F8FCF9  f1 5a 25 50
	bit	0, (0xc6:8)                            ; F8FCFD  f0 c6 c8
	jr nz, .LF8FD06                               ; F8FD00  6e 04
.LF8FD02:
	bit 6,(XIX)                                   ; F8FD02  b4 ce
	jr nz, .LF8FD02                               ; F8FD04  6e fc
.LF8FD06:
	ld (XIX),A                                    ; F8FD06  b4 41
	bit	0, (0xc6:8)                            ; F8FD08  f0 c6 c8
	jr nz, .LF8FD11                               ; F8FD0B  6e 04
.LF8FD0D:
	bit 6,(XIX)                                   ; F8FD0D  b4 ce
	jr nz, .LF8FD0D                               ; F8FD0F  6e fc
.LF8FD11:
	ld (XIX),W                                    ; F8FD11  b4 40
	calr LCD_Dither_FetchMasks                                 ; F8FD13  1e 23 01
	and DE,DE                                     ; F8FD16  da c2
	jr z, .LF8FD74                                ; F8FD18  66 5a
	ld (XIX+0x01),0x43                            ; F8FD1A  bc 01 00 43
	bit	0, (0xc6:8)                            ; F8FD1E  f0 c6 c8
	jr nz, .LF8FD27                               ; F8FD21  6e 04
.LF8FD23:
	bit 6,(XIX)                                   ; F8FD23  b4 ce
	jr nz, .LF8FD23                               ; F8FD25  6e fc
.LF8FD27:
	ld W,(XIX+0x01)                               ; F8FD27  8c 01 20
	or A,W                                        ; F8FD2A  c8 e1
	ld C,A                                        ; F8FD2C  c9 8b
	bit	0, (0xc6:8)                            ; F8FD2E  f0 c6 c8
	jr nz, .LF8FD37                               ; F8FD31  6e 04
.LF8FD33:
	bit 6,(XIX)                                   ; F8FD33  b4 ce
	jr nz, .LF8FD33                               ; F8FD35  6e fc
.LF8FD37:
	ld (XIX+0x01),0x46                            ; F8FD37  bc 01 00 46
	ld wa, (LCD_RunAddress:16)                          ; F8FD3B  d1 5a 25 20
	bit	0, (0xc6:8)                            ; F8FD3F  f0 c6 c8
	jr nz, .LF8FD48                               ; F8FD42  6e 04
.LF8FD44:
	bit 6,(XIX)                                   ; F8FD44  b4 ce
	jr nz, .LF8FD44                               ; F8FD46  6e fc
.LF8FD48:
	ld (XIX),A                                    ; F8FD48  b4 41
	bit	0, (0xc6:8)                            ; F8FD4A  f0 c6 c8
	jr nz, .LF8FD53                               ; F8FD4D  6e 04
.LF8FD4F:
	bit 6,(XIX)                                   ; F8FD4F  b4 ce
	jr nz, .LF8FD4F                               ; F8FD51  6e fc
.LF8FD53:
	ld (XIX),W                                    ; F8FD53  b4 40
	bit	0, (0xc6:8)                            ; F8FD55  f0 c6 c8
	jr nz, .LF8FD5E                               ; F8FD58  6e 04
.LF8FD5A:
	bit 6,(XIX)                                   ; F8FD5A  b4 ce
	jr nz, .LF8FD5A                               ; F8FD5C  6e fc
.LF8FD5E:
	ld (XIX+0x01),0x42                            ; F8FD5E  bc 01 00 42
	ldw hl, 0x08                                  ; F8FD62  33 08 00
	sub HL,DE                                     ; F8FD65  da a3
	ex16 hl, de                                   ; F8FD67  da bb
	bit	0, (0xc6:8)                            ; F8FD69  f0 c6 c8
	jr nz, .LF8FD72                               ; F8FD6C  6e 04
.LF8FD6E:
	bit 6,(XIX)                                   ; F8FD6E  b4 ce
	jr nz, .LF8FD6E                               ; F8FD70  6e fc
.LF8FD72:
	ld (XIX),C                                    ; F8FD72  b4 43
.LF8FD74:
	ld wa, (LCD_X1:16)                          ; F8FD74  d1 34 25 20
	sub	wa, (LCD_X0:16)                       ; F8FD78  d1 30 25 a0
	inc 1,WA                                      ; F8FD7C  d8 61
	cp WA,DE                                      ; F8FD7E  da f0
	jrl ule, .LF8FE38                             ; F8FD80  73 b5 00
	sub WA,DE                                     ; F8FD83  da a0
	extz XWA                                      ; F8FD85  e8 12
	ldw bc, 0x08                                  ; F8FD87  31 08 00
	divs xwa, bc                                 ; F8FD8A  d9 58
	ld DE,QWA                                     ; F8FD8C  d7 e2 8a
	and WA,WA                                     ; F8FD8F  d8 c0
	jr z, .LF8FDAB                                ; F8FD91  66 18
	ld BC,WA                                      ; F8FD93  d8 89
	ld (XIX+0x01),0x42                            ; F8FD95  bc 01 00 42
	ld a, (LCD_SavedY0:16)                            ; F8FD99  c1 5e 25 21
.LF8FD9D:
	bit	0, (0xc6:8)                            ; F8FD9D  f0 c6 c8
	jr nz, .LF8FDA6                               ; F8FDA0  6e 04
.LF8FDA2:
	bit 6,(XIX)                                   ; F8FDA2  b4 ce
	jr nz, .LF8FDA2                               ; F8FDA4  6e fc
.LF8FDA6:
	ld (XIX),A                                    ; F8FDA6  b4 41
	djnz16 bc, .LF8FD9D                           ; F8FDA8  d9 1c f2
.LF8FDAB:
	and DE,DE                                     ; F8FDAB  da c2
	jrl z, .LF8FE38                               ; F8FDAD  76 88 00
	bit	0, (0xc6:8)                            ; F8FDB0  f0 c6 c8
	jr nz, .LF8FDB9                               ; F8FDB3  6e 04
.LF8FDB5:
	bit 6,(XIX)                                   ; F8FDB5  b4 ce
	jr nz, .LF8FDB5                               ; F8FDB7  6e fc
.LF8FDB9:
	ld (XIX+0x01),0x47                            ; F8FDB9  bc 01 00 47
	bit	0, (0xc6:8)                            ; F8FDBD  f0 c6 c8
	jr nz, .LF8FDC6                               ; F8FDC0  6e 04
.LF8FDC2:
	bit 6,(XIX)                                   ; F8FDC2  b4 ce
	jr nz, .LF8FDC2                               ; F8FDC4  6e fc
.LF8FDC6:
	ld A,(XIX+0x01)                               ; F8FDC6  8c 01 21
	bit	0, (0xc6:8)                            ; F8FDC9  f0 c6 c8
	jr nz, .LF8FDD2                               ; F8FDCC  6e 04
.LF8FDCE:
	bit 6,(XIX)                                   ; F8FDCE  b4 ce
	jr nz, .LF8FDCE                               ; F8FDD0  6e fc
.LF8FDD2:
	ld W,(XIX+0x01)                               ; F8FDD2  8c 01 20
	ld (LCD_RunAddress:16), wa                           ; F8FDD5  f1 5a 25 50
	bit	0, (0xc6:8)                            ; F8FDD9  f0 c6 c8
	jr nz, .LF8FDE2                               ; F8FDDC  6e 04
.LF8FDDE:
	bit 6,(XIX)                                   ; F8FDDE  b4 ce
	jr nz, .LF8FDDE                               ; F8FDE0  6e fc
.LF8FDE2:
	ld (XIX+0x01),0x43                            ; F8FDE2  bc 01 00 43
	bit	0, (0xc6:8)                            ; F8FDE6  f0 c6 c8
	jr nz, .LF8FDEF                               ; F8FDE9  6e 04
.LF8FDEB:
	bit 6,(XIX)                                   ; F8FDEB  b4 ce
	jr nz, .LF8FDEB                               ; F8FDED  6e fc
.LF8FDEF:
	ld W,(XIX+0x01)                               ; F8FDEF  8c 01 20
	calr LCD_Dither_RightEdgeMask                                   ; F8FDF2  1e 6f 00
	or A,W                                        ; F8FDF5  c8 e1
	ld C,A                                        ; F8FDF7  c9 8b
	bit	0, (0xc6:8)                            ; F8FDF9  f0 c6 c8
	jr nz, .LF8FE02                               ; F8FDFC  6e 04
.LF8FDFE:
	bit 6,(XIX)                                   ; F8FDFE  b4 ce
	jr nz, .LF8FDFE                               ; F8FE00  6e fc
.LF8FE02:
	ld (XIX+0x01),0x46                            ; F8FE02  bc 01 00 46
	ld wa, (LCD_RunAddress:16)                          ; F8FE06  d1 5a 25 20
	bit	0, (0xc6:8)                            ; F8FE0A  f0 c6 c8
	jr nz, .LF8FE13                               ; F8FE0D  6e 04
.LF8FE0F:
	bit 6,(XIX)                                   ; F8FE0F  b4 ce
	jr nz, .LF8FE0F                               ; F8FE11  6e fc
.LF8FE13:
	ld (XIX),A                                    ; F8FE13  b4 41
	bit	0, (0xc6:8)                            ; F8FE15  f0 c6 c8
	jr nz, .LF8FE1E                               ; F8FE18  6e 04
.LF8FE1A:
	bit 6,(XIX)                                   ; F8FE1A  b4 ce
	jr nz, .LF8FE1A                               ; F8FE1C  6e fc
.LF8FE1E:
	ld (XIX),W                                    ; F8FE1E  b4 40
	bit	0, (0xc6:8)                            ; F8FE20  f0 c6 c8
	jr nz, .LF8FE29                               ; F8FE23  6e 04
.LF8FE25:
	bit 6,(XIX)                                   ; F8FE25  b4 ce
	jr nz, .LF8FE25                               ; F8FE27  6e fc
.LF8FE29:
	ld (XIX+0x01),0x42                            ; F8FE29  bc 01 00 42
	bit	0, (0xc6:8)                            ; F8FE2D  f0 c6 c8
	jr nz, .LF8FE36                               ; F8FE30  6e 04
.LF8FE32:
	bit 6,(XIX)                                   ; F8FE32  b4 ce
	jr nz, .LF8FE32                               ; F8FE34  6e fc
.LF8FE36:
	ld (XIX),C                                    ; F8FE36  b4 43
.LF8FE38:
	ret                                           ; F8FE38  0e

; ---------------------------------------------------------------------
; LCD_Dither_FetchMasks -- pick this run's two dither bytes out of the tables
;
; Called from: LCD_Svc_11_DrawHLineDither (0xF8FD13)
; Inputs:  DE = X0 mod 8, 0..7
; Outputs: (0x255E) = the pattern byte for the WHOLE bytes of the run;
;          A = the pattern byte for the RAGGED FIRST byte.  XHL clobbered.
; Evidence: two five-byte table reads and nothing else, and the two tables are
;          what name it -- see their headers below.  The whole-byte value comes
;          from the ROTATE table, the first-byte value from the SHIFT table,
;          both indexed by the same X0 mod 8.
; ---------------------------------------------------------------------
LCD_Dither_FetchMasks:
	ld XHL,LCD_DitherRotate_Table                 ; F8FE39  43 5b fe f8 00
	ld	a, (xhl+de)                           ; F8FE3E  c3 07 ec e8 21
	ld (LCD_SavedY0:16), a                            ; F8FE43  f1 5e 25 41
	ld XHL,LCD_DitherShift_Table                  ; F8FE47  43 52 fe f8 00
	ld	a, (xhl+de)                           ; F8FE4C  c3 07 ec e8 21
	ret                                           ; F8FE51  0e

; ---------------------------------------------------------------------
; LCD_DitherShift_Table -- 9 bytes: 0xCC logically SHIFTED right by k
; LCD_DitherRotate_Table -- 9 bytes: 0xCC ROTATED right by k
;
; Read by:  LCD_Dither_FetchMasks (0xF8FE47 and 0xF8FE39), indexed by X0 mod 8.
; Layout:   two consecutive 9-byte tables, 0xF8FE52-0xF8FE5A and
;           0xF8FE5B-0xF8FE63.
; Count:    9 and 9, fixed by the two immediates and by what follows: the second
;           table starts at 0xF8FE5B because that is the address the first table
;           read loads, and 0xF8FE64 is LCD_Dither_RightEdgeMask's first
;           instruction, so there is room for nine bytes and no more.
;           ⚠ Index 8 is unreachable in both: `div`/`divs` by 8 cannot produce
;           it.  Index 0 IS reachable -- unlike LCD_LeftEdgeMask_Table's, this
;           helper is called before the caller tests DE for zero.
; Evidence: 0xCC = 11001100, and with the MSB-leftmost bit order the plotter's
;           mask table fixes, that is two pixels on, two off, repeating with
;           period 4.  Rotating it right by k moves the pattern to the pixel
;           column the byte starts at, which is what keeps the phase constant
;           across a run; because the period divides 8, ONE rotated byte serves
;           every whole byte of the run, and the code does exactly that -- it
;           loads (0x255E) once, outside the loop.  The SHIFT table is the same
;           rotated byte ANDed with 0xFF >> k, i.e. the rotate value with the
;           pixels left of X0 removed; that identity holds for all eight
;           reachable indices and is checked by notes/prom_a_byte_checks.py.
; ---------------------------------------------------------------------
LCD_DitherShift_Table:
	.byte 0xCC			; F8FE52  index 0 -- 0xCC >> 0
	.byte 0x66			; F8FE53  index 1
	.byte 0x33			; F8FE54  index 2
	.byte 0x19			; F8FE55  index 3
	.byte 0x0C			; F8FE56  index 4
	.byte 0x06			; F8FE57  index 5
	.byte 0x03			; F8FE58  index 6
	.byte 0x01			; F8FE59  index 7
	.byte 0x00			; F8FE5A  index 8 -- unreachable
LCD_DitherRotate_Table:
	.byte 0xCC			; F8FE5B  index 0 -- ror(0xCC,0)
	.byte 0x66			; F8FE5C  index 1
	.byte 0x33			; F8FE5D  index 2
	.byte 0x99			; F8FE5E  index 3
	.byte 0xCC			; F8FE5F  index 4 -- the pattern's period is 4
	.byte 0x66			; F8FE60  index 5
	.byte 0x33			; F8FE61  index 6
	.byte 0x99			; F8FE62  index 7
	.byte 0xCC			; F8FE63  index 8 -- unreachable

; ---------------------------------------------------------------------
; LCD_Dither_RightEdgeMask -- trim the run's LAST byte to the pixels inside it
;
; Called from: LCD_Svc_11_DrawHLineDither (0xF8FDF2)
; Inputs:  DE = how many pixels of the last byte are inside the run, 0..7;
;          (0x255E) = the whole-byte pattern LCD_Dither_FetchMasks stored.
; Outputs: (0x255E) masked down to those pixels, and A = the result.
;          XHL clobbered.
; Evidence: `and (0x255e),A` is a MEMORY-destination AND -- MAME's byte-operand
;          table has 0xC8-0xCF as `AND (mem),r8` against 0xC0-0xC7's
;          `AND r8,(mem)` (../mame/src/devices/cpu/tlcs900/dasm900.cpp:161-164, the mnemonic_80 table),
;          and the very next instruction reloads A from (0x255E), which would be
;          pointless the other way round.  So the pattern byte is narrowed in
;          place and handed back.
; ---------------------------------------------------------------------
LCD_Dither_RightEdgeMask:
	ld XHL,LCD_Dither_RightEdge_Table                             ; F8FE64  43 77 fe f8 00
	ld	a, (xhl+de)                           ; F8FE69  c3 07 ec e8 21
	and (LCD_SavedY0:16), a                            ; F8FE6E  c1 5e 25 c9
	ld a, (LCD_SavedY0:16)                            ; F8FE72  c1 5e 25 21
	ret                                           ; F8FE76  0e

; ---------------------------------------------------------------------
; LCD_Dither_RightEdge_Table -- 9 bytes: keep pixels 0..k-1 of a byte
;
; Read by:  LCD_Dither_RightEdgeMask (0xF8FE64).
; Layout:   9 bytes, 0xF8FE77-0xF8FE7F, entry k = 0xFF << (8-k).
; Count:    fixed by the load at 0xF8FE64 and by 0xF8FE80 being
;           LCD_Svc_12_DrawVLineDashed's first instruction.
; ⚠ Evidence about the DUPLICATE: this table is byte-for-byte the same as
;           LCD_RightEdgeMask_Table at 0xF8F7AF -- ALL NINE bytes equal,
;           00 80 C0 E0 F0 F8 FC FE 00 -- so the ROM carries the same nine bytes
;           twice.  The pattern services do not share the solid services'
;           helper because the helper they need also has to mask (0x255E); they
;           got their own copy of the table with it.  The nine-of-nine
;           comparison is one of the checks in notes/prom_a_byte_checks.py, not
;           an eyeball.
; ---------------------------------------------------------------------
LCD_Dither_RightEdge_Table:
	.byte 0x00			; F8FE77  index 0 -- unreachable
	.byte 0x80			; F8FE78  index 1 -- pixel 0 only
	.byte 0xC0			; F8FE79  index 2
	.byte 0xE0			; F8FE7A  index 3
	.byte 0xF0			; F8FE7B  index 4
	.byte 0xF8			; F8FE7C  index 5
	.byte 0xFC			; F8FE7D  index 6
	.byte 0xFE			; F8FE7E  index 7 -- pixels 0..6
	.byte 0x00			; F8FE7F  index 8 -- unreachable

; ---------------------------------------------------------------------
; LCD_Svc_12_DrawVLineDashed -- SWI7 service 0x12: a vertical run, two pixels
; on and two off
;
; Called from: SWI7_ServiceTable slot 0x12 (0xF8EA0E), and from
;          LCD_Svc_13_DrawBoxPatterned (0xF8F493 and 0xF8F4A2, both converted)
; Inputs:  (0x2530) = X, (0x2532) = Y0, (0x2536) = Y1; (0x2540) the layer
; Outputs: pixels set at (X, Y0), (X, Y0+1), skipped at Y0+2 and Y0+3, and so on
;          for (0x2536)-(0x2532)+1 rows.  (0x2532) is left one past Y1;
;          (0x2550)/(0x2552) hold the last point plotted.
; Evidence: the loop is a modulo-4 counter in WA -- plot when it is 0 or 1, skip
;          on 2, and on 3 reset it to 0 and skip -- wrapped around the same
;          LCD_PlotPointAt (0xF8ECCF) the solid vertical line uses.  Two on,
;          two off is the same duty cycle as the 0xCC byte the horizontal
;          patterned service uses, which is what makes 0x11 and 0x12 a pair and
;          service 0x13 a box drawn in one consistent dither.
; ⚠ Unlike service 0x11 the phase is NOT tied to the coordinate: the counter
;          starts at 0 on every call, so the dash always begins with two set
;          pixels at Y0 whatever Y0 is.  Service 0x11's phase, by contrast,
;          follows X0 mod 8.
; ⚠ Like the solid vertical line it does NOT clamp -- neither service calls
;          LCD_ClampCoordsToPanel -- but unlike it, it has NO zero-height guard.
;          Service 0x02 tests `and BC,BC` and returns; this one goes straight
;          into a `djnz`, so a call with (0x2536) one BELOW (0x2532) plots 65536
;          points instead of none.
; Unknown:  callers other than service 0x13.
; ---------------------------------------------------------------------
LCD_Svc_12_DrawVLineDashed:
	calr LCD_SelectCurrentLayer                                   ; F8FE80  1e 10 f0
	ld bc, (LCD_Y1:16)                          ; F8FE83  d1 36 25 21
	sub	bc, (LCD_Y0:16)                       ; F8FE87  d1 32 25 a1
	inc 1,BC                                      ; F8FE8B  d9 61
	ld wa, (LCD_X0:16)                          ; F8FE8D  d1 30 25 20
	ld (LCD_PlotX:16), wa                           ; F8FE91  f1 50 25 50
	ld wa, (LCD_Y0:16)                          ; F8FE95  d1 32 25 20
	ld (LCD_PlotY:16), wa                           ; F8FE99  f1 52 25 50
	xor WA,WA                                     ; F8FE9D  d8 d0
.LF8FE9F:
	cp wa, 0x02:i3                                  ; F8FE9F  d8 da
	jr z, .LF8FEB2                                ; F8FEA1  66 0f
	cp wa, 0x03:i3                                  ; F8FEA3  d8 db
	jr nz, .LF8FEAB                               ; F8FEA5  6e 04
	xor WA,WA                                     ; F8FEA7  d8 d0
	jr .LF8FEB4                                   ; F8FEA9  68 09
.LF8FEAB:
	pushw wa                                      ; F8FEAB  28
	pushw bc                                      ; F8FEAC  29
	calr LCD_PlotPointAt                                   ; F8FEAD  1e 1f ee
	popw bc                                       ; F8FEB0  49
	popw wa                                       ; F8FEB1  48
.LF8FEB2:
	inc 1,WA                                      ; F8FEB2  d8 61
.LF8FEB4:
	incw 0x01, (LCD_PlotY:16)                        ; F8FEB4  d1 52 25 61
	djnz16 bc, .LF8FE9F                           ; F8FEB8  d9 1c e4
	ret                                           ; F8FEBB  0e

; ---------------------------------------------------------------------
; LCD_Svc_14_FillRectPattern -- SWI7 service 0x14: fill the box with the
; caller's 8-byte pattern
;
; Called from: SWI7_ServiceTable slot 0x14 (0xF8EA16)
; Inputs:  (0x2530),(0x2532),(0x2534),(0x2536) = the box, as for the fill;
;          (0x2540) the layer; ★ (0x2538)-(0x253F) = EIGHT pattern bytes, one
;          per screen row, supplied by the caller.
; Outputs: the pattern OR'd over the box, row by row, repeating every 8 rows.
;          (0x2532) left one past Y1; (0x255E) = the last pattern byte used;
;          IY left holding the row index.
; Evidence: ★ THIS IS WHAT (0x2538) IS.  LCD_Pattern_NextRow loads
;          `ld XHL,0x00002538` and indexes it with IY, having just wrapped IY to
;          zero when it reached 8 -- an eight-entry byte table in RAM, stepped
;          once per row of the box, and its address is an immediate in the code,
;          not an inference.  The rest of the routine is LCD_Svc_1B_EraseRect's
;          skeleton with the sense flipped back to OR: same per-row address
;          arithmetic, same CSRDIR RIGHT, same three-phase byte walk, same
;          `incw 1,(0x2532)` loop.
; ⚠ The pattern is tiled on BYTE boundaries in X, not on the coordinate: the one
;          byte fetched for a row is written into every whole byte of that row
;          and is never rotated by X mod 8.  Service 0x11's dither IS rotated.
;          So this service's pattern has period 8 in X anchored at display-byte
;          boundaries, and period 8 in Y anchored at Y0.
; ⚠ IY is not initialised by the row loop but by the routine's second
;          instruction (`xor IY,IY`), so the vertical phase restarts at the top
;          of every call.
; Unknown:  who fills (0x2538)-(0x253F).  No writer of those bytes is converted.
; ---------------------------------------------------------------------
LCD_Svc_14_FillRectPattern:
	calr LCD_SelectCurrentLayer                                   ; F8FEBC  1e d4 ef
	ld XIX,0x00790000                             ; F8FEBF  44 00 00 79 00
	xor IY,IY                                     ; F8FEC4  dd d5
.LF8FEC6:
	ld wa, (LCD_Y1:16)                          ; F8FEC6  d1 36 25 20
	cp	(LCD_Y0:16), wa                       ; F8FECA  d1 32 25 f8
	jrl ugt, .LF90067                             ; F8FECE  7b 96 01
	ld wa, (LCD_Y0:16)                          ; F8FED1  d1 32 25 20
	ld bc, (LCD_BytesPerLine:16)                          ; F8FED5  d1 57 25 21
	mul xwa, bc                                  ; F8FED9  d9 40
	ld HL,WA                                      ; F8FEDB  d8 8b
	ld wa, (LCD_X0:16)                          ; F8FEDD  d1 30 25 20
	extz XWA                                      ; F8FEE1  e8 12
	ldw bc, 0x08                                  ; F8FEE3  31 08 00
	divs xwa, bc                                 ; F8FEE6  d9 58
	ld DE,QWA                                     ; F8FEE8  d7 e2 8a
	add HL,WA                                     ; F8FEEB  d8 83
	ld wa, (LCD_CurrentLayerBase:16)                          ; F8FEED  d1 55 25 20
	add WA,HL                                     ; F8FEF1  db 80
	bit	0, (0xc6:8)                            ; F8FEF3  f0 c6 c8
	jr nz, .LF8FEFC                               ; F8FEF6  6e 04
.LF8FEF8:
	bit 6,(XIX)                                   ; F8FEF8  b4 ce
	jr nz, .LF8FEF8                               ; F8FEFA  6e fc
.LF8FEFC:
	ld (XIX+0x01),0x4c                            ; F8FEFC  bc 01 00 4c
	bit	0, (0xc6:8)                            ; F8FF00  f0 c6 c8
	jr nz, .LF8FF09                               ; F8FF03  6e 04
.LF8FF05:
	bit 6,(XIX)                                   ; F8FF05  b4 ce
	jr nz, .LF8FF05                               ; F8FF07  6e fc
.LF8FF09:
	ld (XIX+0x01),0x46                            ; F8FF09  bc 01 00 46
	ld (LCD_RunAddress:16), wa                           ; F8FF0D  f1 5a 25 50
	bit	0, (0xc6:8)                            ; F8FF11  f0 c6 c8
	jr nz, .LF8FF1A                               ; F8FF14  6e 04
.LF8FF16:
	bit 6,(XIX)                                   ; F8FF16  b4 ce
	jr nz, .LF8FF16                               ; F8FF18  6e fc
.LF8FF1A:
	ld (XIX),A                                    ; F8FF1A  b4 41
	bit	0, (0xc6:8)                            ; F8FF1C  f0 c6 c8
	jr nz, .LF8FF25                               ; F8FF1F  6e 04
.LF8FF21:
	bit 6,(XIX)                                   ; F8FF21  b4 ce
	jr nz, .LF8FF21                               ; F8FF23  6e fc
.LF8FF25:
	ld (XIX),W                                    ; F8FF25  b4 40
	calr LCD_Pattern_NextRow                                 ; F8FF27  1e 3e 01
	and DE,DE                                     ; F8FF2A  da c2
	jr z, .LF8FF91                                ; F8FF2C  66 63
	bit	0, (0xc6:8)                            ; F8FF2E  f0 c6 c8
	jr nz, .LF8FF37                               ; F8FF31  6e 04
.LF8FF33:
	bit 6,(XIX)                                   ; F8FF33  b4 ce
	jr nz, .LF8FF33                               ; F8FF35  6e fc
.LF8FF37:
	ld (XIX+0x01),0x43                            ; F8FF37  bc 01 00 43
	bit	0, (0xc6:8)                            ; F8FF3B  f0 c6 c8
	jr nz, .LF8FF44                               ; F8FF3E  6e 04
.LF8FF40:
	bit 6,(XIX)                                   ; F8FF40  b4 ce
	jr nz, .LF8FF40                               ; F8FF42  6e fc
.LF8FF44:
	ld W,(XIX+0x01)                               ; F8FF44  8c 01 20
	or A,W                                        ; F8FF47  c8 e1
	ld C,A                                        ; F8FF49  c9 8b
	bit	0, (0xc6:8)                            ; F8FF4B  f0 c6 c8
	jr nz, .LF8FF54                               ; F8FF4E  6e 04
.LF8FF50:
	bit 6,(XIX)                                   ; F8FF50  b4 ce
	jr nz, .LF8FF50                               ; F8FF52  6e fc
.LF8FF54:
	ld (XIX+0x01),0x46                            ; F8FF54  bc 01 00 46
	ld wa, (LCD_RunAddress:16)                          ; F8FF58  d1 5a 25 20
	bit	0, (0xc6:8)                            ; F8FF5C  f0 c6 c8
	jr nz, .LF8FF65                               ; F8FF5F  6e 04
.LF8FF61:
	bit 6,(XIX)                                   ; F8FF61  b4 ce
	jr nz, .LF8FF61                               ; F8FF63  6e fc
.LF8FF65:
	ld (XIX),A                                    ; F8FF65  b4 41
	bit	0, (0xc6:8)                            ; F8FF67  f0 c6 c8
	jr nz, .LF8FF70                               ; F8FF6A  6e 04
.LF8FF6C:
	bit 6,(XIX)                                   ; F8FF6C  b4 ce
	jr nz, .LF8FF6C                               ; F8FF6E  6e fc
.LF8FF70:
	ld (XIX),W                                    ; F8FF70  b4 40
	bit	0, (0xc6:8)                            ; F8FF72  f0 c6 c8
	jr nz, .LF8FF7B                               ; F8FF75  6e 04
.LF8FF77:
	bit 6,(XIX)                                   ; F8FF77  b4 ce
	jr nz, .LF8FF77                               ; F8FF79  6e fc
.LF8FF7B:
	ld (XIX+0x01),0x42                            ; F8FF7B  bc 01 00 42
	bit	0, (0xc6:8)                            ; F8FF7F  f0 c6 c8
	jr nz, .LF8FF88                               ; F8FF82  6e 04
.LF8FF84:
	bit 6,(XIX)                                   ; F8FF84  b4 ce
	jr nz, .LF8FF84                               ; F8FF86  6e fc
.LF8FF88:
	ld (XIX),C                                    ; F8FF88  b4 43
	ldw hl, 0x08                                  ; F8FF8A  33 08 00
	sub HL,DE                                     ; F8FF8D  da a3
	ex16 hl, de                                   ; F8FF8F  da bb
.LF8FF91:
	ld wa, (LCD_X1:16)                          ; F8FF91  d1 34 25 20
	sub	wa, (LCD_X0:16)                       ; F8FF95  d1 30 25 a0
	inc 1,WA                                      ; F8FF99  d8 61
	cp WA,DE                                      ; F8FF9B  da f0
	jrl ule, .LF90060                             ; F8FF9D  73 c0 00
	sub WA,DE                                     ; F8FFA0  da a0
	extz XWA                                      ; F8FFA2  e8 12
	ldw bc, 0x08                                  ; F8FFA4  31 08 00
	divs xwa, bc                                 ; F8FFA7  d9 58
	ld DE,QWA                                     ; F8FFA9  d7 e2 8a
	and WA,WA                                     ; F8FFAC  d8 c0
	jr z, .LF8FFD3                                ; F8FFAE  66 23
	ld BC,WA                                      ; F8FFB0  d8 89
	bit	0, (0xc6:8)                            ; F8FFB2  f0 c6 c8
	jr nz, .LF8FFBB                               ; F8FFB5  6e 04
.LF8FFB7:
	bit 6,(XIX)                                   ; F8FFB7  b4 ce
	jr nz, .LF8FFB7                               ; F8FFB9  6e fc
.LF8FFBB:
	ld (XIX+0x01),0x42                            ; F8FFBB  bc 01 00 42
	ld a, (LCD_SavedY0:16)                            ; F8FFBF  c1 5e 25 21
.LF8FFC3:
	nop                                           ; F8FFC3  00
	nop                                           ; F8FFC4  00
	bit	0, (0xc6:8)                            ; F8FFC5  f0 c6 c8
	jr nz, .LF8FFCE                               ; F8FFC8  6e 04
.LF8FFCA:
	bit 6,(XIX)                                   ; F8FFCA  b4 ce
	jr nz, .LF8FFCA                               ; F8FFCC  6e fc
.LF8FFCE:
	ld (XIX),A                                    ; F8FFCE  b4 41
	djnz16 bc, .LF8FFC3                           ; F8FFD0  d9 1c f0
.LF8FFD3:
	and DE,DE                                     ; F8FFD3  da c2
	jrl z, .LF90060                               ; F8FFD5  76 88 00
	bit	0, (0xc6:8)                            ; F8FFD8  f0 c6 c8
	jr nz, .LF8FFE1                               ; F8FFDB  6e 04
.LF8FFDD:
	bit 6,(XIX)                                   ; F8FFDD  b4 ce
	jr nz, .LF8FFDD                               ; F8FFDF  6e fc
.LF8FFE1:
	ld (XIX+0x01),0x47                            ; F8FFE1  bc 01 00 47
	bit	0, (0xc6:8)                            ; F8FFE5  f0 c6 c8
	jr nz, .LF8FFEE                               ; F8FFE8  6e 04
.LF8FFEA:
	bit 6,(XIX)                                   ; F8FFEA  b4 ce
	jr nz, .LF8FFEA                               ; F8FFEC  6e fc
.LF8FFEE:
	ld A,(XIX+0x01)                               ; F8FFEE  8c 01 21
	bit	0, (0xc6:8)                            ; F8FFF1  f0 c6 c8
	jr nz, .LF8FFFA                               ; F8FFF4  6e 04
.LF8FFF6:
	bit 6,(XIX)                                   ; F8FFF6  b4 ce
	jr nz, .LF8FFF6                               ; F8FFF8  6e fc
.LF8FFFA:
	ld W,(XIX+0x01)                               ; F8FFFA  8c 01 20
	ld (LCD_RunAddress:16), wa                           ; F8FFFD  f1 5a 25 50
	bit	0, (0xc6:8)                            ; F90001  f0 c6 c8
	jr nz, .LF9000A                               ; F90004  6e 04
.LF90006:
	bit 6,(XIX)                                   ; F90006  b4 ce
	jr nz, .LF90006                               ; F90008  6e fc
.LF9000A:
	ld (XIX+0x01),0x43                            ; F9000A  bc 01 00 43
	bit	0, (0xc6:8)                            ; F9000E  f0 c6 c8
	jr nz, .LF90017                               ; F90011  6e 04
.LF90013:
	bit 6,(XIX)                                   ; F90013  b4 ce
	jr nz, .LF90013                               ; F90015  6e fc
.LF90017:
	ld W,(XIX+0x01)                               ; F90017  8c 01 20
	calr LCD_Pattern_RightEdgeMask                                   ; F9001A  1e 77 00
	or A,W                                        ; F9001D  c8 e1
	ld C,A                                        ; F9001F  c9 8b
	bit	0, (0xc6:8)                            ; F90021  f0 c6 c8
	jr nz, .LF9002A                               ; F90024  6e 04
.LF90026:
	bit 6,(XIX)                                   ; F90026  b4 ce
	jr nz, .LF90026                               ; F90028  6e fc
.LF9002A:
	ld (XIX+0x01),0x46                            ; F9002A  bc 01 00 46
	ld wa, (LCD_RunAddress:16)                          ; F9002E  d1 5a 25 20
	bit	0, (0xc6:8)                            ; F90032  f0 c6 c8
	jr nz, .LF9003B                               ; F90035  6e 04
.LF90037:
	bit 6,(XIX)                                   ; F90037  b4 ce
	jr nz, .LF90037                               ; F90039  6e fc
.LF9003B:
	ld (XIX),A                                    ; F9003B  b4 41
	bit	0, (0xc6:8)                            ; F9003D  f0 c6 c8
	jr nz, .LF90046                               ; F90040  6e 04
.LF90042:
	bit 6,(XIX)                                   ; F90042  b4 ce
	jr nz, .LF90042                               ; F90044  6e fc
.LF90046:
	ld (XIX),W                                    ; F90046  b4 40
	bit	0, (0xc6:8)                            ; F90048  f0 c6 c8
	jr nz, .LF90051                               ; F9004B  6e 04
.LF9004D:
	bit 6,(XIX)                                   ; F9004D  b4 ce
	jr nz, .LF9004D                               ; F9004F  6e fc
.LF90051:
	ld (XIX+0x01),0x42                            ; F90051  bc 01 00 42
	bit	0, (0xc6:8)                            ; F90055  f0 c6 c8
	jr nz, .LF9005E                               ; F90058  6e 04
.LF9005A:
	bit 6,(XIX)                                   ; F9005A  b4 ce
	jr nz, .LF9005A                               ; F9005C  6e fc
.LF9005E:
	ld (XIX),C                                    ; F9005E  b4 43
.LF90060:
	incw 0x01, (LCD_Y0:16)                        ; F90060  d1 32 25 61
	jrl .LF8FEC6                                  ; F90064  78 5f fe
.LF90067:
	ret                                           ; F90067  0e

; ---------------------------------------------------------------------
; LCD_Pattern_NextRow -- fetch the next row's pattern byte and trim its LEFT edge
;
; Called from: LCD_Svc_14_FillRectPattern (0xF8FF27)
; Inputs:  IY = the row index, 0..8; DE = X0 mod 8, 0..7
; Outputs: IY advanced (and wrapped to 0 first if it had reached 8);
;          (0x255E) = the row's pattern byte; A = that byte with the pixels left
;          of X0 removed.  XHL clobbered.
; Evidence: `cp IY,0x0008` then `xor IY,IY` is the wrap, and the AND against
;          LCD_PatternLeftMask_Table is the same left-edge trim
;          LCD_Rect_LeftEdgeMask performs for the solid fill -- here folded into
;          the fetch because the pattern byte, unlike 0xFF, has to be kept.
; ---------------------------------------------------------------------
LCD_Pattern_NextRow:
	cp IY,0x0008                                  ; F90068  dd cf 08 00
	jr nz, .LF90070                               ; F9006C  6e 02
	xor IY,IY                                     ; F9006E  dd d5
.LF90070:
	ld XHL,0x00002538                             ; F90070  43 38 25 00 00
	ld	a, (xhl+iy)                           ; F90075  c3 07 ec f4 21
	inc 1,IY                                      ; F9007A  dd 61
	ld (LCD_SavedY0:16), a                            ; F9007C  f1 5e 25 41
	ld XHL,LCD_PatternLeftMask_Table              ; F90080  43 8b 00 f9 00
	and	a, (xhl+de)                           ; F90085  c3 07 ec e8 c1
	ret                                           ; F9008A  0e

; ---------------------------------------------------------------------
; LCD_PatternLeftMask_Table -- 9 bytes: keep pixels k..7 of a byte
;
; Read by:  LCD_Pattern_NextRow (0xF90080), indexed by X0 mod 8.
; Layout:   9 bytes, 0xF9008B-0xF90093, entry k = 0xFF >> k for k = 0..8.
; Count:    fixed by the load at 0xF90080 and by 0xF90094 being
;           LCD_Pattern_RightEdgeMask's first instruction.
; ⚠ Evidence about the near-duplicate: this is LCD_LeftEdgeMask_Table
;           (0xF8F79B) with ONE of its nine bytes different -- index 0 is 0xFF
;           here and 0x00 there; the other eight are equal.  The difference is
;           required, not accidental: the solid fill calls its helper only after
;           testing X0 mod 8 for zero, so its index 0 is dead, while this helper
;           is called BEFORE that test and must return "keep all eight pixels".
;           The one-of-nine count is a check in notes/prom_a_byte_checks.py.
; ---------------------------------------------------------------------
LCD_PatternLeftMask_Table:
	.byte 0xFF			; F9008B  index 0 -- keep the whole byte
	.byte 0x7F			; F9008C  index 1
	.byte 0x3F			; F9008D  index 2
	.byte 0x1F			; F9008E  index 3
	.byte 0x0F			; F9008F  index 4
	.byte 0x07			; F90090  index 5
	.byte 0x03			; F90091  index 6
	.byte 0x01			; F90092  index 7 -- pixel 7 only
	.byte 0x00			; F90093  index 8 -- unreachable

; ---------------------------------------------------------------------
; LCD_Pattern_RightEdgeMask -- trim the box's LAST byte-column
;
; Called from: LCD_Svc_14_FillRectPattern (0xF9001A)
; Inputs:  DE = how many pixels of the last byte are inside the box, 0..7;
;          (0x255E) = the row's pattern byte.
; Outputs: (0x255E) masked down to those pixels, and A = the result.
; Evidence: instruction for instruction LCD_Dither_RightEdgeMask (0xF8FE64),
;           with a different table address -- 19 bytes each, and the ONLY
;           differing bytes are three of the four in the `ld XHL,imm` operand
;           (0xF8FE77 against 0xF900A7).  16 of 19 equal; the count is a check
;           in notes/prom_a_byte_checks.py.
; ---------------------------------------------------------------------
LCD_Pattern_RightEdgeMask:
	ld XHL,LCD_PatternRightMask_Table             ; F90094  43 a7 00 f9 00
	ld	a, (xhl+de)                           ; F90099  c3 07 ec e8 21
	and (LCD_SavedY0:16), a                            ; F9009E  c1 5e 25 c9
	ld a, (LCD_SavedY0:16)                            ; F900A2  c1 5e 25 21
	ret                                           ; F900A6  0e

; ---------------------------------------------------------------------
; LCD_PatternRightMask_Table -- 9 bytes: keep pixels 0..k-1 of a byte
;
; Read by:  LCD_Pattern_RightEdgeMask (0xF90094).
; Layout:   9 bytes, 0xF900A7-0xF900AF, entry k = 0xFF << (8-k) for k = 0..8.
; Count:    fixed by the load at 0xF90094 and by 0xF900B0 being
;           LCD_Svc_15_DrawLineDashed's first instruction.
; ⚠ Evidence about the near-duplicate: this is LCD_RightEdgeMask_Table
;           (0xF8F7AF) and LCD_Dither_RightEdge_Table (0xF8FE77) with ONE of the
;           nine bytes different -- index 8 is 0xFF here and 0x00 in both of
;           those; the other eight are equal.  So the ROM carries this nine-byte
;           shape THREE times, in two variants.  Index 8 is unreachable in all
;           three (`div` by 8 cannot produce it), so the difference has no
;           behavioural consequence; it is recorded because the byte gate cannot
;           see it and a reader who assumed "same table" would be wrong.
; ---------------------------------------------------------------------
LCD_PatternRightMask_Table:
	.byte 0x00			; F900A7  index 0 -- unreachable
	.byte 0x80			; F900A8  index 1 -- pixel 0 only
	.byte 0xC0			; F900A9  index 2
	.byte 0xE0			; F900AA  index 3
	.byte 0xF0			; F900AB  index 4
	.byte 0xF8			; F900AC  index 5
	.byte 0xFC			; F900AD  index 6
	.byte 0xFE			; F900AE  index 7 -- pixels 0..6
	.byte 0xFF			; F900AF  index 8 -- unreachable

; ---------------------------------------------------------------------
; LCD_Svc_15_DrawLineDashed -- SWI7 service 0x15: the line draw, two pixels on
; and two off
;
; Called from: SWI7_ServiceTable slot 0x15 (0xF8EA1A)
; Inputs/Outputs: exactly LCD_Svc_00_DrawLine's -- the same four coordinate
;          words, the same clamp, the same major-axis choice, the same
;          hundredths fixed-point interpolation, the same two endpoint plots.
; Evidence: it calls the SAME five helpers in the same order --
;          LCD_ClampCoordsToPanel, LCD_Line_ChooseMajorAxis,
;          LCD_Line_ComputeIntercept, LCD_Line_PlotLowXEnd and, at the end,
;          LCD_Line_PlotHighXEnd -- and its step loop is byte-for-byte the
;          arithmetic of LCD_Svc_00__step.  What is added is a counter in IZ
;          with the same modulo-4 shape service 0x12 keeps in WA: plot when it
;          is 0 or 1, skip on 2, reset and skip on 3.
; ⚠ TWO differences from service 0x00 that are NOT the dash, both read off the
;          opcodes rather than assumed:
;          1. the loop test is `jr UGT` (0x6B) here against `jr NC` (0x6F)
;             there, so this one runs one more iteration -- it includes the
;             major coordinate that equals IY, service 0x00 stops before it;
;          2. it keeps its counter in IZ, which service 0x00 never touches.
; Unknown:  callers.  Nothing yet calls it, and no box service is built from it
;          the way 0x13 is built from 0x11 and 0x12.
; ---------------------------------------------------------------------
LCD_Svc_15_DrawLineDashed:
	calr LCD_SelectCurrentLayer                                   ; F900B0  1e e0 ed
	calr LCD_ClampCoordsToPanel                                   ; F900B3  1e b5 ea
	calr LCD_Line_ChooseMajorAxis                                   ; F900B6  1e 60 ea
	calr LCD_Line_ComputeIntercept                                   ; F900B9  1e 4e eb
	calr LCD_Line_PlotLowXEnd                                   ; F900BC  1e 8c eb
	xor IZ,IZ                                     ; F900BF  de d6
.LF900C1:
	ld WA,IX                                      ; F900C1  dc 88
	cp WA,IY                                      ; F900C3  dd f0
	jr ugt, .LF90114                              ; F900C5  6b 4d
	cp iz, 0x02:i3                                  ; F900C7  de da
	jr z, .LF9010E                                ; F900C9  66 43
	cp iz, 0x03:i3                                  ; F900CB  de db
	jr nz, .LF900D3                               ; F900CD  6e 04
	xor IZ,IZ                                     ; F900CF  de d6
	jr .LF90110                                   ; F900D1  68 3d
.LF900D3:
	muls	xwa, (LCD_LineSlopeX100:16)                     ; F900D3  d1 48 25 48
	ld DE,QWA                                     ; F900D7  d7 e2 8a
	add	wa, (LCD_LineInterceptX100:16)                       ; F900DA  d1 4a 25 80
	bit 0x0f,WA                                   ; F900DE  d8 33 0f
	jr z, .LF900E5                                ; F900E1  66 02
	neg WA                                        ; F900E3  d8 07
.LF900E5:
	add WA,0x0032                                 ; F900E5  d8 c8 32 00
	ldw bc, 0x64                                  ; F900E9  31 64 00
	exts XWA                                      ; F900EC  e8 13
	divs xwa, bc                                 ; F900EE  d9 58
	ld DE,QWA                                     ; F900F0  d7 e2 8a
	bit	0, (LCD_LineFlags:16)                        ; F900F3  f1 47 25 c8
	jr nz, .LF90103                               ; F900F7  6e 0a
	ld (LCD_PlotY:16), wa                           ; F900F9  f1 52 25 50
	ld (LCD_PlotX:16), ix                           ; F900FD  f1 50 25 54
	jr .LF9010B                                   ; F90101  68 08
.LF90103:
	ld (LCD_PlotX:16), wa                           ; F90103  f1 50 25 50
	ld (LCD_PlotY:16), ix                           ; F90107  f1 52 25 54
.LF9010B:
	calr LCD_PlotPointAt                                   ; F9010B  1e c1 eb
.LF9010E:
	inc 1,IZ                                      ; F9010E  de 61
.LF90110:
	inc 1,IX                                      ; F90110  dc 61
	jr .LF900C1                                   ; F90112  68 ad
.LF90114:
	calr LCD_Line_PlotHighXEnd                                   ; F90114  1e 6c eb
	ret                                           ; F90117  0e

; ==============================================================================
; 0xF90118-0xF90988 -- SWI7 services 0x17, 0x1C and 0x1E: the two PACKED text
; services, their bit-shifting engine, and the panel SCROLL
; ==============================================================================
;
; ★ TWO MORE CHARACTER GENERATORS, AND THEY ARE ASCII.  Services 0x17 and 0x1C
;   load glyphs from bases that appear nowhere in the ten-font inventory of
;   notes/FINDINGS-fonts.md:
;
;     svc 0x17  0xF1E470   8 bytes/glyph    8 x 8   advance  6 pixels
;     svc 0x1C  0xF1EAB0  32 bytes/glyph   16 x 16  advance 11 pixels
;
;   Both pass `python3 notes/render_font.py <base> <n> --ascii-check`: one blank
;   glyph (0x20) and 94 drawn ones, with 0x41 rendering as an A and 0x39 as a 9.
;   So the machine carries SEVEN ASCII faces, not five.  The inventory in that
;   note is updated.
;
; ★ AND THESE TWO ARE THE ONLY TEXT SERVICES THAT CAN START AT ANY PIXEL.  The
;   ten services in the 0xF8F039 block blit whole bytes: a string can only begin
;   on an 8-pixel boundary and every glyph is 8 or 16 wide.  These two run every
;   glyph through TextShift_ShiftRight first, so the string starts at
;   (0x2530) exactly, and they advance by the face's real width -- 6 and 11 --
;   rather than by 8 or 16.  That is what "packed" means in the names below, and
;   it is read off two constants that agree: the advance the service adds to
;   (0x259E), and the `and W,0xe0` in TextShift_LoadGlyph16 that keeps three
;   bits of the second byte, making a row 8 + 3 = 11 wide.
;
; THE ENGINE.  Three 16-byte staging buffers in CS1 RAM, and their SIZE is fixed
; by their own addresses -- 0x257A - 0x256A = 16 and 0x258A - 0x257A = 16, and
; 0x259A is the character counter:
;
;   TextShift_BufA  (0x256A)  the byte column the glyph's left 8 pixels land in
;   TextShift_BufB  (0x257A)  the byte column its overflow lands in
;   TextShift_BufC  (0x258A)  where the previous character's overflow is parked
;
; and four 16-bit/8-bit variables:
;
;   (0x259A)  characters left to draw
;   (0x259C)  the display-RAM address of the byte column being written
;   (0x259E)  the bit offset within that byte, 0..8 -- the string's X position
;             modulo 8, advanced by the glyph width per character
;   (0x259F)  a 32-bit pointer to the current glyph's bitmap
;
; ⚠ (0x259E) IS ALLOWED TO BE 8.  The advance is `add 6` (or 11) then
;   `if > 8 subtract 8`, not `mod 8`, so a glyph that ends exactly on a byte
;   boundary leaves 8 rather than 0.  Every mask table below is 9 entries for
;   that reason, and both services special-case the index where the glyph ends
;   flush -- 2 for the 6-wide face, 5 for the 11-wide one.
;
; ⚠ WHAT IS NOT ESTABLISHED HERE: nothing calls either service in any code this
;   tree has converted, so the meaning of the HL argument (multiplied by BC once
;   into IZ, exactly as in the ten byte-aligned text services) is still open,
;   and so is which face the UI uses for what.

; ---------------------------------------------------------------------
; LCD_Svc_17_DrawText8x8Packed -- SWI7 service 0x17: a string in the 8x8 face,
; six pixels apart, starting at any pixel column
;
; Called from: SWI7_ServiceTable slot 0x17 (0xF8EA22)
; Inputs:  BC = number of characters; XIY = the string; HL = the same stride the
;          byte-aligned text services take (IZ := HL*BC, then the character code
;          is read as (XIY+IZ)); (0x2530),(0x2532) = the top-left corner in
;          PIXELS; (0x2540) selects the layer.
; Outputs: the string drawn, OR'd into the layer.  (0x259A)-(0x25A2) and all
;          three staging buffers clobbered; returns at once if BC is zero.
; Evidence: the font base 0xF1E470 and the 8-byte glyph pitch are immediates
;          (`ld W,0x08` then `mul WA,W`, then `add XIX,XHL`); the 6-pixel
;          advance is the `add (0x259e),0x06` at 0xF901F5; and
;          notes/render_font.py says the table at that base is an ASCII 8x8
;          face.  The address arithmetic is the driver's usual
;          Y*(0x2557) + X/8 + (0x2555), kept in (0x259C).
; Structure: load and shift the first glyph, then for the first character
;          either merge it into the panel directly (offset > 2, i.e. the glyph
;          spills into the next byte) or first READ the panel column into buffer
;          A and merge that (offset <= 2 -- and when this is also the LAST
;          character that whole head write is skipped); then per character, advance the
;          offset, shift, OR in the previous character's overflow, and write
;          one or two columns; finally flush whichever buffer still holds
;          pixels.  Every step is a call to one of the helpers below.
; Unknown:  callers; and the exact pixel meaning of the two tail mask tables --
;          see LCD_TextColMask_Tail8's header.
; ---------------------------------------------------------------------
LCD_Svc_17_DrawText8x8Packed:
	and BC,BC                                     ; F90118  d9 c1
	jrl z, .LF9025D                               ; F9011A  76 40 01
	ldw wa, 0x08                                  ; F9011D  30 08 00
	calr TextShift_ClearBufA                                   ; F90120  1e e7 02
	ld (LCD_TextCharsLeft:16), bc                           ; F90123  f1 9a 25 51
	calr LCD_SelectCurrentLayer                                   ; F90127  1e 69 ed
	ld WA,HL                                      ; F9012A  db 88
	mul xwa, bc                                  ; F9012C  d9 40
	ld IZ,WA                                      ; F9012E  d8 8e
	ld wa, (LCD_Y0:16)                          ; F90130  d1 32 25 20
	ld bc, (LCD_BytesPerLine:16)                          ; F90134  d1 57 25 21
	mul xwa, bc                                  ; F90138  d9 40
	ld (LCD_TextColumnAddr:16), wa                           ; F9013A  f1 9c 25 50
	ld wa, (LCD_X0:16)                          ; F9013E  d1 30 25 20
	extz XWA                                      ; F90142  e8 12
	ldw bc, 0x08                                  ; F90144  31 08 00
	divs xwa, bc                                 ; F90147  d9 58
	ld DE,QWA                                     ; F90149  d7 e2 8a
	ld (LCD_TextBitOffset:16), e                            ; F9014C  f1 9e 25 45
	add	(LCD_TextColumnAddr:16), wa                       ; F90150  d1 9c 25 88
	ld wa, (LCD_CurrentLayerBase:16)                          ; F90154  d1 55 25 20
	add	(LCD_TextColumnAddr:16), wa                       ; F90158  d1 9c 25 88
	ld	a, (xiy+iz)                           ; F9015C  c3 07 f4 f8 21
	ld w, 0x08:opc                                   ; F90161  20 08
	mul wa, w                                   ; F90163  c8 41
	xor XHL,XHL                                   ; F90165  eb d3
	ld HL,WA                                      ; F90167  d8 8b
	ld XIX,Font_Svc17_8x8                         ; F90169  44 70 e4 f1 00
	add XIX,XHL                                   ; F9016E  eb 84
	ld (LCD_TextGlyphPtr:16), xix                          ; F90170  f1 9f 25 64
	ldw bc, 0x08                                  ; F90174  31 08 00
	calr TextShift_LoadGlyph8                                   ; F90177  1e b4 02
	decw 0x01, (LCD_TextCharsLeft:16)                        ; F9017A  d1 9a 25 69
	ld d, 0x08:opc                                   ; F9017E  24 08
	calr TextShift_ShiftRight                                   ; F90180  1e f4 02
	cp	(LCD_TextBitOffset:16), 0x02                     ; F90183  c1 9e 25 3f 02
	jr ule, .LF901A4                              ; F90188  63 1a
	ldw bc, 0x04                                  ; F9018A  31 04 00
	calr TextShift_CopyBtoC                                   ; F9018D  1e 54 03
	calr LCD_TextCol_SetCursor                                   ; F90190  1e eb 06
	ld XIX,0x0000256a                             ; F90193  44 6a 25 00 00
	ldw bc, 0x08                                  ; F90198  31 08 00
	calr LCD_TextCol_MergeHead8                                   ; F9019B  1e 0c 05
	incw 0x01, (LCD_TextColumnAddr:16)                        ; F9019E  d1 9c 25 61
	jr .LF901C9                                   ; F901A2  68 25
.LF901A4:
	cpw	(LCD_TextCharsLeft:16), 0x0000                   ; F901A4  d1 9a 25 3f 00 00
	jr z, .LF901C9                                ; F901AA  66 1d
	calr LCD_TextCol_SetCursor                                   ; F901AC  1e cf 06
	ldw bc, 0x08                                  ; F901AF  31 08 00
	calr LCD_TextCol_ReadIntoBufA                                   ; F901B2  1e 03 07
	ldw bc, 0x04                                  ; F901B5  31 04 00
	calr TextShift_CopyAtoC                                   ; F901B8  1e 1a 03
	calr LCD_TextCol_SetCursor                                   ; F901BB  1e c0 06
	ld XIX,0x0000256a                             ; F901BE  44 6a 25 00 00
	ldw bc, 0x08                                  ; F901C3  31 08 00
	calr LCD_TextCol_MergeHead8                                   ; F901C6  1e e1 04
.LF901C9:
	cpw	(LCD_TextCharsLeft:16), 0x0000                   ; F901C9  d1 9a 25 3f 00 00
	jr z, .LF9023B                                ; F901CF  66 6a
	inc 1,XIY                                     ; F901D1  ed 61
	ld	a, (xiy+iz)                           ; F901D3  c3 07 f4 f8 21
	ld w, 0x08:opc                                   ; F901D8  20 08
	mul wa, w                                   ; F901DA  c8 41
	xor XHL,XHL                                   ; F901DC  eb d3
	ld HL,WA                                      ; F901DE  d8 8b
	ld XIX,Font_Svc17_8x8                         ; F901E0  44 70 e4 f1 00
	add XIX,XHL                                   ; F901E5  eb 84
	ld (LCD_TextGlyphPtr:16), xix                          ; F901E7  f1 9f 25 64
	ldw bc, 0x08                                  ; F901EB  31 08 00
	calr TextShift_LoadGlyph8                                   ; F901EE  1e 3d 02
	decw 0x01, (LCD_TextCharsLeft:16)                        ; F901F1  d1 9a 25 69
	add	(LCD_TextBitOffset:16), 0x06                     ; F901F5  c1 9e 25 38 06
	cp	(LCD_TextBitOffset:16), 0x08                     ; F901FA  c1 9e 25 3f 08
	jr ule, .LF90206                              ; F901FF  63 05
	sub	(LCD_TextBitOffset:16), 0x08                    ; F90201  c1 9e 25 3a 08
.LF90206:
	ld d, 0x08:opc                                   ; F90206  24 08
	calr TextShift_ShiftRight                                   ; F90208  1e 6c 02
	ld d, 0x08:opc                                   ; F9020B  24 08
	calr TextShift_OrCintoA                                   ; F9020D  1e e3 02
	cp	(LCD_TextBitOffset:16), 0x02                     ; F90210  c1 9e 25 3f 02
	jr ule, .LF90233                              ; F90215  63 1c
	ldw bc, 0x04                                  ; F90217  31 04 00
	calr TextShift_CopyBtoC                                   ; F9021A  1e c7 02
	ld d, 0x08:opc                                   ; F9021D  24 08
	calr LCD_TextCol_SetCursor                                   ; F9021F  1e 5c 06
	ld XIX,0x0000256a                             ; F90222  44 6a 25 00 00
	ldw bc, 0x08                                  ; F90227  31 08 00
	calr LCD_TextCol_WriteRaw                                   ; F9022A  1e 15 06
	incw 0x01, (LCD_TextColumnAddr:16)                        ; F9022D  d1 9c 25 61
	jr .LF901C9                                   ; F90231  68 96
.LF90233:
	ldw bc, 0x04                                  ; F90233  31 04 00
	calr TextShift_CopyAtoC                                   ; F90236  1e 9c 02
	jr .LF901C9                                   ; F90239  68 8e
.LF9023B:
	calr LCD_TextCol_SetCursor                                   ; F9023B  1e 40 06
	cp	(LCD_TextBitOffset:16), 0x02                     ; F9023E  c1 9e 25 3f 02
	jr ule, .LF90252                              ; F90243  63 0d
	ld XIX,0x0000257a                             ; F90245  44 7a 25 00 00
	ldw bc, 0x08                                  ; F9024A  31 08 00
	calr LCD_TextCol_MergeTail8                                   ; F9024D  1e 26 05
	jr .LF9025D                                   ; F90250  68 0b
.LF90252:
	ld XIX,0x0000256a                             ; F90252  44 6a 25 00 00
	ldw bc, 0x08                                  ; F90257  31 08 00
	calr LCD_TextCol_MergeTail8                                   ; F9025A  1e 19 05
.LF9025D:
	ret                                           ; F9025D  0e

; ---------------------------------------------------------------------
; LCD_Svc_1C_DrawText16x16Packed -- SWI7 service 0x1C: a string in the 16x16
; face, eleven pixels apart, starting at any pixel column
;
; Called from: SWI7_ServiceTable slot 0x1C (0xF8EA36)
; Inputs/Outputs: as service 0x17
; Evidence: font base 0xF1EAB0, glyph pitch `ld W,0x10` + `mul WA,W` then
;          `sla 0x01,HL` -- 16*2 = 32 bytes per glyph -- and the 11-pixel
;          advance at 0xF90367.  TextShift_LoadGlyph16's `and W,0xe0` keeps
;          exactly three bits of each row's second byte, so the face is 11
;          pixels wide, which is the same 11.  notes/render_font.py says the
;          table is ASCII 16x16.
; Notes:   it is service 0x17's shape with the 8-wide loader replaced by the
;          16-wide one, an extra left-shift pass (TextShift_ShiftLeft, with the
;          count computed as 8 - (0x259E) at the call site) and a third buffer
;          clear.  The special offset is 5 rather than 2 -- 8 - 11 modulo 8 --
;          and unlike service 0x17 the tail flush RETURNS at that offset instead
;          of writing a column.
; Unknown:  callers.
; ---------------------------------------------------------------------
LCD_Svc_1C_DrawText16x16Packed:
	and BC,BC                                     ; F9025E  d9 c1
	jrl z, .LF90409                               ; F90260  76 a6 01
	ldw wa, 0x10                                  ; F90263  30 10 00
	calr TextShift_ClearBufA                                   ; F90266  1e a1 01
	ld (LCD_TextCharsLeft:16), bc                           ; F90269  f1 9a 25 51
	calr LCD_SelectCurrentLayer                                   ; F9026D  1e 23 ec
	ld WA,HL                                      ; F90270  db 88
	mul xwa, bc                                  ; F90272  d9 40
	ld IZ,WA                                      ; F90274  d8 8e
	ld wa, (LCD_Y0:16)                          ; F90276  d1 32 25 20
	ld bc, (LCD_BytesPerLine:16)                          ; F9027A  d1 57 25 21
	mul xwa, bc                                  ; F9027E  d9 40
	ld (LCD_TextColumnAddr:16), wa                           ; F90280  f1 9c 25 50
	ld wa, (LCD_X0:16)                          ; F90284  d1 30 25 20
	extz XWA                                      ; F90288  e8 12
	ldw bc, 0x08                                  ; F9028A  31 08 00
	divs xwa, bc                                 ; F9028D  d9 58
	ld DE,QWA                                     ; F9028F  d7 e2 8a
	ld (LCD_TextBitOffset:16), e                            ; F90292  f1 9e 25 45
	add	(LCD_TextColumnAddr:16), wa                       ; F90296  d1 9c 25 88
	ld wa, (LCD_CurrentLayerBase:16)                          ; F9029A  d1 55 25 20
	add	(LCD_TextColumnAddr:16), wa                       ; F9029E  d1 9c 25 88
	ld	a, (xiy+iz)                           ; F902A2  c3 07 f4 f8 21
	ld w, 0x10:opc                                   ; F902A7  20 10
	mul wa, w                                   ; F902A9  c8 41
	xor XHL,XHL                                   ; F902AB  eb d3
	ld HL,WA                                      ; F902AD  d8 8b
	sla hl, 0x01                                  ; F902AF  db ec 01
	ld XIX,Font_Svc1C_16x16                       ; F902B2  44 b0 ea f1 00
	add XIX,XHL                                   ; F902B7  eb 84
	ld (LCD_TextGlyphPtr:16), xix                          ; F902B9  f1 9f 25 64
	ldw bc, 0x10                                  ; F902BD  31 10 00
	calr TextShift_LoadGlyph16                                   ; F902C0  1e 8f 01
	decw 0x01, (LCD_TextCharsLeft:16)                        ; F902C3  d1 9a 25 69
	ld d, 0x10:opc                                   ; F902C7  24 10
	calr TextShift_ShiftRight                                   ; F902C9  1e ab 01
	calr LCD_TextCol_SetCursor                                   ; F902CC  1e af 05
	ld XIX,0x0000256a                             ; F902CF  44 6a 25 00 00
	ldw bc, 0x10                                  ; F902D4  31 10 00
	calr LCD_TextCol_MergeHead16                                   ; F902D7  1e 38 02
	incw 0x01, (LCD_TextColumnAddr:16)                        ; F902DA  d1 9c 25 61
	cp	(LCD_TextBitOffset:16), 0x05                     ; F902DE  c1 9e 25 3f 05
	jr ule, .LF90310                              ; F902E3  63 2b
	calr LCD_TextCol_SetCursor                                   ; F902E5  1e 96 05
	ld XIX,0x0000257a                             ; F902E8  44 7a 25 00 00
	ldw bc, 0x10                                  ; F902ED  31 10 00
	calr LCD_TextCol_WriteRaw                                   ; F902F0  1e 4f 05
	incw 0x01, (LCD_TextColumnAddr:16)                        ; F902F3  d1 9c 25 61
	ldw bc, 0x10                                  ; F902F7  31 10 00
	calr TextShift_LoadGlyph16                                   ; F902FA  1e 55 01
	ld c, 0x08:opc                                   ; F902FD  23 08
	sub c, (LCD_TextBitOffset:16)                            ; F902FF  c1 9e 25 a3
	ld d, 0x10:opc                                   ; F90303  24 10
	calr TextShift_ShiftLeft                                   ; F90305  1e a0 01
	ldw bc, 0x08                                  ; F90308  31 08 00
	calr TextShift_CopyBtoC                                   ; F9030B  1e d6 01
	jr .LF90337                                   ; F9030E  68 27
.LF90310:
	cp	(LCD_TextBitOffset:16), 0x05                     ; F90310  c1 9e 25 3f 05
	jr nz, .LF90331                               ; F90315  6e 1a
	calr LCD_TextCol_SetCursor                                   ; F90317  1e 64 05
	ld XIX,0x0000257a                             ; F9031A  44 7a 25 00 00
	ldw bc, 0x10                                  ; F9031F  31 10 00
	calr LCD_TextCol_WriteRaw                                   ; F90322  1e 1d 05
	incw 0x01, (LCD_TextColumnAddr:16)                        ; F90325  d1 9c 25 61
	ldw wa, 0x08                                  ; F90329  30 08 00
	calr TextShift_ClearBufC                                     ; F9032C  1e ed 00
	jr .LF90337                                   ; F9032F  68 06
.LF90331:
	ldw bc, 0x08                                  ; F90331  31 08 00
	calr TextShift_CopyBtoC                                   ; F90334  1e ad 01
.LF90337:
	cpw	(LCD_TextCharsLeft:16), 0x0000                   ; F90337  d1 9a 25 3f 00 00
	jrl z, .LF903F4                               ; F9033D  76 b4 00
	inc 1,XIY                                     ; F90340  ed 61
	ld	a, (xiy+iz)                           ; F90342  c3 07 f4 f8 21
	ld w, 0x10:opc                                   ; F90347  20 10
	mul wa, w                                   ; F90349  c8 41
	xor XHL,XHL                                   ; F9034B  eb d3
	ld HL,WA                                      ; F9034D  d8 8b
	sla hl, 0x01                                  ; F9034F  db ec 01
	ld XIX,Font_Svc1C_16x16                       ; F90352  44 b0 ea f1 00
	add XIX,XHL                                   ; F90357  eb 84
	ld (LCD_TextGlyphPtr:16), xix                          ; F90359  f1 9f 25 64
	ldw bc, 0x10                                  ; F9035D  31 10 00
	calr TextShift_LoadGlyph16                                     ; F90360  1e ef 00
	decw 0x01, (LCD_TextCharsLeft:16)                        ; F90363  d1 9a 25 69
	add	(LCD_TextBitOffset:16), 0x0b                     ; F90367  c1 9e 25 38 0b
.LF9036C:
	cp	(LCD_TextBitOffset:16), 0x08                     ; F9036C  c1 9e 25 3f 08
	jr c, .LF9037A                                ; F90371  67 07
	sub	(LCD_TextBitOffset:16), 0x08                    ; F90373  c1 9e 25 3a 08
	jr .LF9036C                                   ; F90378  68 f2
.LF9037A:
	ld d, 0x10:opc                                   ; F9037A  24 10
	calr TextShift_ShiftRight                                     ; F9037C  1e f8 00
	ld d, 0x10:opc                                   ; F9037F  24 10
	calr TextShift_OrCintoA                                   ; F90381  1e 6f 01
	calr LCD_TextCol_SetCursor                                   ; F90384  1e f7 04
	ld XIX,0x0000256a                             ; F90387  44 6a 25 00 00
	ldw bc, 0x10                                  ; F9038C  31 10 00
	calr LCD_TextCol_WriteRaw                                   ; F9038F  1e b0 04
	incw 0x01, (LCD_TextColumnAddr:16)                        ; F90392  d1 9c 25 61
	cp	(LCD_TextBitOffset:16), 0x05                     ; F90396  c1 9e 25 3f 05
	jr ule, .LF903C9                              ; F9039B  63 2c
	calr LCD_TextCol_SetCursor                                   ; F9039D  1e de 04
	ld XIX,0x0000257a                             ; F903A0  44 7a 25 00 00
	ldw bc, 0x10                                  ; F903A5  31 10 00
	calr LCD_TextCol_WriteRaw                                   ; F903A8  1e 97 04
	incw 0x01, (LCD_TextColumnAddr:16)                        ; F903AB  d1 9c 25 61
	ldw bc, 0x10                                  ; F903AF  31 10 00
	calr TextShift_LoadGlyph16                                     ; F903B2  1e 9d 00
	ld c, 0x08:opc                                   ; F903B5  23 08
	sub c, (LCD_TextBitOffset:16)                            ; F903B7  c1 9e 25 a3
	ld d, 0x10:opc                                   ; F903BB  24 10
	calr TextShift_ShiftLeft                                     ; F903BD  1e e8 00
	ldw bc, 0x08                                  ; F903C0  31 08 00
	calr TextShift_CopyBtoC                                   ; F903C3  1e 1e 01
	jrl .LF90337                                  ; F903C6  78 6e ff
.LF903C9:
	cp	(LCD_TextBitOffset:16), 0x05                     ; F903C9  c1 9e 25 3f 05
	jr nz, .LF903EB                               ; F903CE  6e 1b
	calr LCD_TextCol_SetCursor                                   ; F903D0  1e ab 04
	ld XIX,0x0000257a                             ; F903D3  44 7a 25 00 00
	ldw bc, 0x10                                  ; F903D8  31 10 00
	calr LCD_TextCol_WriteRaw                                   ; F903DB  1e 64 04
	incw 0x01, (LCD_TextColumnAddr:16)                        ; F903DE  d1 9c 25 61
	ldw wa, 0x08                                  ; F903E2  30 08 00
	calr TextShift_ClearBufC                                     ; F903E5  1e 34 00
	jrl .LF90337                                  ; F903E8  78 4c ff
.LF903EB:
	ldw bc, 0x08                                  ; F903EB  31 08 00
	calr TextShift_CopyBtoC                                     ; F903EE  1e f3 00
	jrl .LF90337                                  ; F903F1  78 43 ff
.LF903F4:
	cp	(LCD_TextBitOffset:16), 0x05                     ; F903F4  c1 9e 25 3f 05
	jr z, .LF90409                                ; F903F9  66 0e
	calr LCD_TextCol_SetCursor                                   ; F903FB  1e 80 04
	ld XIX,0x0000258a                             ; F903FE  44 8a 25 00 00
	ldw bc, 0x10                                  ; F90403  31 10 00
	calr LCD_TextCol_MergeTail16                                   ; F90406  1e d5 01
.LF90409:
	ret                                           ; F90409  0e

; ---------------------------------------------------------------------
; TextShift_ClearBufA -- zero WA words of the first staging buffer
;
; Called from: svc 0x17 at 0xF90120 (WA = 8, so 16 bytes = buffer A) and
;          svc 0x1C at 0xF90266 (WA = 16, so 32 bytes = buffers A AND B)
; Inputs:  WA = the number of 16-bit words to zero
; Outputs: (0x256A) onward zeroed; BC preserved, WA = 0
; Evidence: `ld XIX,0x0000256a` then `ld (XIX+),WA` -- a WORD store with
;          post-increment, so WA words is 2*WA bytes.  Service 0x1C asking for
;          32 bytes is not a mistake: its 16-wide glyphs use A and B together
;          and the two buffers are adjacent.
; Notes:   TextShift_ClearBufC (below) is the same 18 bytes with ONE byte
;          different, the low byte of that immediate.
; ---------------------------------------------------------------------
TextShift_ClearBufA:
	pushw bc                                      ; F9040A  29
	ld BC,WA                                      ; F9040B  d8 89
	xor WA,WA                                     ; F9040D  d8 d0
	ld XIX,0x0000256a                             ; F9040F  44 6a 25 00 00
.LF90414:
	ld (xix+), wa                              ; F90414  f5 f1 50
	djnz16 bc, .LF90414                           ; F90417  d9 1c fa
	popw bc                                       ; F9041A  49
	ret                                           ; F9041B  0e

; ---------------------------------------------------------------------
; TextShift_ClearBufC -- zero WA words of the third staging buffer
;
; Called from: svc 0x1C at 0xF9032C and 0xF903E5, both with WA = 8 (16 bytes)
; Inputs:  WA = the number of 16-bit words to zero
; Outputs: (0x258A) onward zeroed; BC preserved (pushed), WA = 0
; Evidence: `ld XIX,0x0000258a` and a `ld (XIX+),WA` post-increment store loop.
; ---------------------------------------------------------------------
TextShift_ClearBufC:
	pushw bc                                      ; F9041C  29
	ld BC,WA                                      ; F9041D  d8 89
	xor WA,WA                                     ; F9041F  d8 d0
	ld XIX,0x0000258a                             ; F90421  44 8a 25 00 00
.LF90426:
	ld (xix+), wa                              ; F90426  f5 f1 50
	djnz16 bc, .LF90426                           ; F90429  d9 1c fa
	popw bc                                       ; F9042C  49
	ret                                           ; F9042D  0e

; ---------------------------------------------------------------------
; TextShift_LoadGlyph8 -- copy BC one-byte glyph rows into buffer A, zero B
;
; Called from: LCD_Svc_17_DrawText8x8Packed (0xF90177, 0xF901EE), BC = 8
; Inputs:  BC = rows; (0x259F) = a 32-bit pointer to the glyph's first byte
; Outputs: TextShift_BufA[i] = glyph[i] and TextShift_BufB[i] = 0 for i < BC.
;          XHL and XIY saved and restored.
; Evidence: one byte read per row (`ld A,(XIY)` + `inc 1,XIY`) against
;          TextShift_LoadGlyph16's word read -- this is the 8-wide loader.
; ---------------------------------------------------------------------
TextShift_LoadGlyph8:
	push XHL                                      ; F9042E  3b
	push XIY                                      ; F9042F  3d
	xor WA,WA                                     ; F90430  d8 d0
	ld XHL,0x0000257a                             ; F90432  43 7a 25 00 00
	ld XIX,0x0000256a                             ; F90437  44 6a 25 00 00
	ld xiy, (LCD_TextGlyphPtr:16)                          ; F9043C  e1 9f 25 25
.LF90440:
	ld A,(XIY)                                    ; F90440  85 21
	ld (XIX),A                                    ; F90442  b4 41
	ld (XHL),W                                    ; F90444  b3 40
	inc 1,XIY                                     ; F90446  ed 61
	inc 1,XIX                                     ; F90448  ec 61
	inc 1,XHL                                     ; F9044A  eb 61
	djnz16 bc, .LF90440                           ; F9044C  d9 1c f1
	pop XIY                                       ; F9044F  5d
	pop XHL                                       ; F90450  5b
	ret                                           ; F90451  0e

; ---------------------------------------------------------------------
; TextShift_LoadGlyph16 -- copy BC two-byte glyph rows into buffers A and B
;
; Called from: LCD_Svc_1C_DrawText16x16Packed (four sites), BC = 16
; Inputs:  BC = rows; (0x259F) = a 32-bit pointer to the glyph
; Outputs: TextShift_BufA[i] = the row's FIRST byte, TextShift_BufB[i] = its
;          SECOND byte ANDed with 0xE0, for i < BC.
; Evidence: ★ THE 0xE0 IS WHAT FIXES THE GLYPH WIDTH AT 11.  It keeps three
;          bits of the second byte and throws the other five away, so a row is
;          8 + 3 = 11 pixels wide -- and 11 is exactly the advance
;          LCD_Svc_1C_DrawText16x16Packed adds to (0x259E) per character
;          (`add (0x259e),0x0b`).  Two independent constants agreeing.
; ---------------------------------------------------------------------
TextShift_LoadGlyph16:
	push XHL                                      ; F90452  3b
	push XIY                                      ; F90453  3d
	ld XHL,0x0000257a                             ; F90454  43 7a 25 00 00
	ld XIX,0x0000256a                             ; F90459  44 6a 25 00 00
	ld xiy, (LCD_TextGlyphPtr:16)                          ; F9045E  e1 9f 25 25
.LF90462:
	ld WA,(XIY)                                   ; F90462  95 20
	ld (XIX),A                                    ; F90464  b4 41
	and W,0xe0                                    ; F90466  c8 cc e0
	ld (XHL),W                                    ; F90469  b3 40
	inc 2,XIY                                     ; F9046B  ed 62
	inc 1,XIX                                     ; F9046D  ec 61
	inc 1,XHL                                     ; F9046F  eb 61
	djnz16 bc, .LF90462                           ; F90471  d9 1c ee
	pop XIY                                       ; F90474  5d
	pop XHL                                       ; F90475  5b
	ret                                           ; F90476  0e

; ---------------------------------------------------------------------
; TextShift_ShiftRight -- shift the (A,B) row pairs right by (0x259E) bits
;
; Called from: both packed-text services, four sites, with D = 8 or 16
; Inputs:  D = rows; (0x259E) = the shift count, 0..8
; Outputs: for each row, the 16-bit value (BufA[i] << 8 | BufB[i]) shifted right
;          by that count and stored back.  XIY saved and restored.
; Evidence: ★ THIS IS WHAT MAKES THE PACKED TEXT SERVICES SUB-BYTE.  The pair of
;          buffers is loaded into BC as (B = BufA[i], C = BufB[i]) -- the high
;          byte from A -- and shifted with the register-count `srl A,BC` form,
;          then written back the same way round.  A glyph can therefore start at
;          ANY pixel column, which is what services 0x06/0x07/0x08 and the rest
;          of the text family cannot do: they blit whole bytes.
; Notes:   the shift is skipped when the count is zero, because the TLCS-900
;          shift-by-a-register forms shift by 16 when the count byte is 0
;          (the `cp A,0` / `jr Z` before it) -- MAME's core computes
;          `count = (s & 0x0f) ? (s & 0x0f) : 16`
;          (../mame/src/devices/cpu/tlcs900/900tbl.hxx:1104-1106).
;          Both shift instructions are the
;          `cb ff` / `cb fc` register-count encodings llvm-mc cannot spell, so
;          they stay as .byte with unidasm's text beside them.
; ---------------------------------------------------------------------
TextShift_ShiftRight:
	push XIY                                      ; F90477  3d
	ld XIY,0x0000256a                             ; F90478  45 6a 25 00 00
	ld XIX,0x0000257a                             ; F9047D  44 7a 25 00 00
	xor E,E                                       ; F90482  cd d5
	ld c, (LCD_TextBitOffset:16)                            ; F90484  c1 9e 25 23
.LF90488:
	cp E,D                                        ; F90488  cc f5
	jr nc, .LF904A6                               ; F9048A  6f 1a
	ld W,(XIY)                                    ; F9048C  85 20
	ld A,(XIX)                                    ; F9048E  84 21
	ex16 wa, bc                                   ; F90490  d9 b8
	cp a, 0x00:i3                                   ; F90492  c9 d8
	jr z, .LF90498                                ; F90494  66 02
	.byte 0xd9, 0xff                              ; F90496  d9 ff
.LF90498:
	ex16 wa, bc                                   ; F90498  d9 b8
	ld (XIY),W                                    ; F9049A  b5 40
	ld (XIX),A                                    ; F9049C  b4 41
	inc 1,XIY                                     ; F9049E  ed 61
	inc 1,XIX                                     ; F904A0  ec 61
	inc 1,E                                       ; F904A2  cd 61
	jr .LF90488                                   ; F904A4  68 e2
.LF904A6:
	pop XIY                                       ; F904A6  5d
	ret                                           ; F904A7  0e

; ---------------------------------------------------------------------
; TextShift_ShiftLeft -- shift the (A,B) row pairs LEFT by C bits
;
; Called from: LCD_Svc_1C_DrawText16x16Packed (0xF90305, 0xF903BD), both times
;          with C = 8 - (0x259E), computed at the call site
; Inputs:  D = rows; C = the shift count
; Outputs: as TextShift_ShiftRight but leftward.
; Evidence: instruction for instruction TextShift_ShiftRight with `sla A,BC`
;          (0xcb 0xfc) instead of `srl A,BC` (0xcb 0xff) and without the
;          `ld C,(0x259e)` that fetches the count -- 45 bytes against 49, the
;          four being that load.  The count comes from the caller instead.
; ---------------------------------------------------------------------
TextShift_ShiftLeft:
	push XIY                                      ; F904A8  3d
	ld XIY,0x0000256a                             ; F904A9  45 6a 25 00 00
	ld XIX,0x0000257a                             ; F904AE  44 7a 25 00 00
	xor E,E                                       ; F904B3  cd d5
.LF904B5:
	cp E,D                                        ; F904B5  cc f5
	jr nc, .LF904D3                               ; F904B7  6f 1a
	ld W,(XIY)                                    ; F904B9  85 20
	ld A,(XIX)                                    ; F904BB  84 21
	ex16 wa, bc                                   ; F904BD  d9 b8
	cp a, 0x00:i3                                   ; F904BF  c9 d8
	jr z, .LF904C5                                ; F904C1  66 02
	.byte 0xd9, 0xfc                              ; F904C3  d9 fc
.LF904C5:
	ex16 wa, bc                                   ; F904C5  d9 b8
	ld (XIY),W                                    ; F904C7  b5 40
	ld (XIX),A                                    ; F904C9  b4 41
	inc 1,XIY                                     ; F904CB  ed 61
	inc 1,XIX                                     ; F904CD  ec 61
	inc 1,E                                       ; F904CF  cd 61
	jr .LF904B5                                   ; F904D1  68 e2
.LF904D3:
	pop XIY                                       ; F904D3  5d
	ret                                           ; F904D4  0e

; ---------------------------------------------------------------------
; TextShift_CopyAtoC -- copy BC words of buffer A into buffer C
;
; Called from: svc 0x17 (0xF901B8) and svc 0x1C (0xF90236), BC = 4 and 8
; Inputs:  BC = words (so 8 or 16 bytes)
; Outputs: (0x258A..) = (0x256A..)
; Evidence: a single `ldirw` between the two immediates.
; ---------------------------------------------------------------------
TextShift_CopyAtoC:
	push XIY                                      ; F904D5  3d
	ld XIY,0x0000256a                             ; F904D6  45 6a 25 00 00
	ld XIX,0x0000258a                             ; F904DB  44 8a 25 00 00
	ldirw                                         ; F904E0  95 11
	pop XIY                                       ; F904E2  5d
	ret                                           ; F904E3  0e

; ---------------------------------------------------------------------
; TextShift_CopyBtoC -- copy BC words of buffer B into buffer C
;
; Called from: six sites across both services, BC = 4 or 8
; Inputs:  BC = words
; Outputs: (0x258A..) = (0x257A..)
; Evidence: TextShift_CopyAtoC with 0x256A replaced by 0x257A -- 15 bytes each
;          and exactly one differing byte, the low byte of that immediate.
; ---------------------------------------------------------------------
TextShift_CopyBtoC:
	push XIY                                      ; F904E4  3d
	ld XIY,0x0000257a                             ; F904E5  45 7a 25 00 00
	ld XIX,0x0000258a                             ; F904EA  44 8a 25 00 00
	ldirw                                         ; F904EF  95 11
	pop XIY                                       ; F904F1  5d
	ret                                           ; F904F2  0e

; ---------------------------------------------------------------------
; TextShift_OrCintoA -- OR buffer C into buffer A, D rows
;
; Called from: svc 0x17 (0xF9020D) and svc 0x1C (0xF90381), D = 8 and 16
; Inputs:  D = rows
; Outputs: TextShift_BufA[i] |= TextShift_BufC[i]
; Evidence: the two buffer bases are literal -- `ld XIY,0x0000256A` (buffer A)
;          at 0xF904F4 and `ld XIX,0x0000258A` (buffer C) at 0xF904F9 -- and
;          the loop body is `ld A,(XIX) / or (XIY),A` at 0xF90504/0xF90506, a
;          memory-DESTINATION or, so the result lands in A and C is only read.
;          That is the name. The buffer identities come from
;          notes/prom_a_byte_checks.py ("TextShift buffers: 0x256A, 0x257A,
;          0x258A, then 0x259A -- 16 bytes each"), and the same script now
;          pins that this routine has exactly the two callers named above.
;          ⚠ what the merge MEANS is the reading in Notes, taken from the call
;          order.
; Notes:   this is how the PREVIOUS character's overflow -- parked in C by
;          TextShift_CopyBtoC -- is merged into the byte column the NEXT
;          character starts in.  That reading comes from the call order in the
;          two services, not from this routine alone.
; ---------------------------------------------------------------------
TextShift_OrCintoA:
	push XIY                                      ; F904F3  3d
	ld XIY,0x0000256a                             ; F904F4  45 6a 25 00 00
	ld XIX,0x0000258a                             ; F904F9  44 8a 25 00 00
	xor E,E                                       ; F904FE  cd d5
.LF90500:
	cp E,D                                        ; F90500  cc f5
	jr nc, .LF90510                               ; F90502  6f 0c
	ld A,(XIX)                                    ; F90504  84 21
	or (XIY),A                                    ; F90506  85 e9
	inc 1,XIY                                     ; F90508  ed 61
	inc 1,XIX                                     ; F9050A  ec 61
	inc 1,E                                       ; F9050C  cd 61
	jr .LF90500                                   ; F9050E  68 f0
.LF90510:
	pop XIY                                       ; F90510  5d
	ret                                           ; F90511  0e

; ---------------------------------------------------------------------
; LCD_TextCol_MergeHead16 -- write a buffer down one byte-column, merging each
; byte with what is already on the panel
;
; Called from: LCD_Svc_1C_DrawText16x16Packed (0xF902D7) and nowhere else.
;          ⚠ That negative is a SEARCH: notes/prom_a_byte_checks.py re-derives
;          it from every 24-bit little-endian address in prom_a + prom_b and
;          every PC-relative displacement in prom_a.
; Inputs:  BC = rows; XIX = the source buffer; (0x259E) = the bit offset, used
;          by the mask fetcher below; (0x255A) is scratch.
; Outputs: BC display bytes written, each one
;              (what was there AND LCD_TextColMask_Head16[(0x259E)])
;              OR (the buffer byte)
;          IZ saved and restored.
; Evidence: the controller has no read-modify-write, so per row this issues
;          CSRR (0x47) and reads the cursor address back into (0x255A), MREAD
;          (0x43) and reads the byte, masks it, CSRW (0x46) to put the cursor
;          back where the read left it, CSRDIR DOWN (0x4F), MWRITE (0x42), and
;          writes the merged byte.  Six commands per byte -- the same dance
;          LCD_PlotPointAt does for one pixel.
;
; ★ THIS ROUTINE EXISTS FOUR TIMES, AND THREE OF THE FOUR COPIES ARE THE SAME
;   172 BYTES.  LCD_TextCol_MergeTail16 (0xF905DE) and LCD_TextCol_MergeTail8
;   (0xF90776) are byte-for-byte IDENTICAL to this one -- 172 of 172, checked by
;   notes/prom_a_byte_checks.py, not by eye.  They behave differently only
;   because each one's `calr` to its mask fetcher has the same displacement
;   (0x005A) and each fetcher sits immediately after its own copy, so identical
;   code reaches four different tables.  LCD_TextCol_MergeHead8 (0xF906AA) is
;   the fourth copy and differs in exactly THIRTEEN bytes, offsets 154-166: the
;   same thirteen bytes -- `inc 1,IZ`, the nine-byte BUSY poll and `ld (XHL),A`
;   -- in a different order, the increment after the write instead of before.
; ---------------------------------------------------------------------
LCD_TextCol_MergeHead16:
	pushw iz                                      ; F90512  2e
	ld XHL,0x00790000                             ; F90513  43 00 00 79 00
	xor IZ,IZ                                     ; F90518  de d6
.LF9051A:
	cp IZ,BC                                      ; F9051A  d9 f6
	jrl nc, .LF905BC                              ; F9051C  7f 9d 00
	bit	0, (0xc6:8)                            ; F9051F  f0 c6 c8
	jr nz, .LF90528                               ; F90522  6e 04
.LF90524:
	bit 6,(XHL)                                   ; F90524  b3 ce
	jr nz, .LF90524                               ; F90526  6e fc
.LF90528:
	ld (XHL+0x01),0x47                            ; F90528  bb 01 00 47
	bit	0, (0xc6:8)                            ; F9052C  f0 c6 c8
	jr nz, .LF90535                               ; F9052F  6e 04
.LF90531:
	bit 6,(XHL)                                   ; F90531  b3 ce
	jr nz, .LF90531                               ; F90533  6e fc
.LF90535:
	ld A,(XHL+0x01)                               ; F90535  8b 01 21
	bit	0, (0xc6:8)                            ; F90538  f0 c6 c8
	jr nz, .LF90541                               ; F9053B  6e 04
.LF9053D:
	bit 6,(XHL)                                   ; F9053D  b3 ce
	jr nz, .LF9053D                               ; F9053F  6e fc
.LF90541:
	ld W,(XHL+0x01)                               ; F90541  8b 01 20
	ld (LCD_RunAddress:16), wa                           ; F90544  f1 5a 25 50
	bit	0, (0xc6:8)                            ; F90548  f0 c6 c8
	jr nz, .LF90551                               ; F9054B  6e 04
.LF9054D:
	bit 6,(XHL)                                   ; F9054D  b3 ce
	jr nz, .LF9054D                               ; F9054F  6e fc
.LF90551:
	ld (XHL+0x01),0x43                            ; F90551  bb 01 00 43
	bit	0, (0xc6:8)                            ; F90555  f0 c6 c8
	jr nz, .LF9055E                               ; F90558  6e 04
.LF9055A:
	bit 6,(XHL)                                   ; F9055A  b3 ce
	jr nz, .LF9055A                               ; F9055C  6e fc
.LF9055E:
	ld E,(XHL+0x01)                               ; F9055E  8b 01 25
	calr .LF905BE                                 ; F90561  1e 5a 00
	bit	0, (0xc6:8)                            ; F90564  f0 c6 c8
	jr nz, .LF9056D                               ; F90567  6e 04
.LF90569:
	bit 6,(XHL)                                   ; F90569  b3 ce
	jr nz, .LF90569                               ; F9056B  6e fc
.LF9056D:
	ld (XHL+0x01),0x46                            ; F9056D  bb 01 00 46
	ld wa, (LCD_RunAddress:16)                          ; F90571  d1 5a 25 20
	bit	0, (0xc6:8)                            ; F90575  f0 c6 c8
	jr nz, .LF9057E                               ; F90578  6e 04
.LF9057A:
	bit 6,(XHL)                                   ; F9057A  b3 ce
	jr nz, .LF9057A                               ; F9057C  6e fc
.LF9057E:
	ld (XHL),A                                    ; F9057E  b3 41
	bit	0, (0xc6:8)                            ; F90580  f0 c6 c8
	jr nz, .LF90589                               ; F90583  6e 04
.LF90585:
	bit 6,(XHL)                                   ; F90585  b3 ce
	jr nz, .LF90585                               ; F90587  6e fc
.LF90589:
	ld (XHL),W                                    ; F90589  b3 40
	bit	0, (0xc6:8)                            ; F9058B  f0 c6 c8
	jr nz, .LF90594                               ; F9058E  6e 04
.LF90590:
	bit 6,(XHL)                                   ; F90590  b3 ce
	jr nz, .LF90590                               ; F90592  6e fc
.LF90594:
	ld (XHL+0x01),0x4f                            ; F90594  bb 01 00 4f
	bit	0, (0xc6:8)                            ; F90598  f0 c6 c8
	jr nz, .LF905A1                               ; F9059B  6e 04
.LF9059D:
	bit 6,(XHL)                                   ; F9059D  b3 ce
	jr nz, .LF9059D                               ; F9059F  6e fc
.LF905A1:
	ld (XHL+0x01),0x42                            ; F905A1  bb 01 00 42
	ld	a, (xix+iz)                           ; F905A5  c3 07 f0 f8 21
	or A,E                                        ; F905AA  cd e1
	inc 1,IZ                                      ; F905AC  de 61
	bit	0, (0xc6:8)                            ; F905AE  f0 c6 c8
	jr nz, .LF905B7                               ; F905B1  6e 04
.LF905B3:
	bit 6,(XHL)                                   ; F905B3  b3 ce
	jr nz, .LF905B3                               ; F905B5  6e fc
.LF905B7:
	ld (XHL),A                                    ; F905B7  b3 41
	jrl .LF9051A                                  ; F905B9  78 5e ff
.LF905BC:
	popw iz                                       ; F905BC  4e
	ret                                           ; F905BD  0e
.LF905BE:

; ---------------------------------------------------------------------
; LCD_TextColMask_Head16_Fetch -- E &= LCD_TextColMask_Head16[(0x259E)]
;
; Called from: LCD_TextCol_MergeHead16 (0xF90561)
; Inputs:  E = the byte just MREAD off the panel; (0x259E) = the bit offset, 0..8
; Outputs: E masked; A = the mask.  XHL and XIX saved and restored.
; Evidence: the table address is the literal in `ld XIX,0x00F905D5` at 0xF905C6
;          and the index is `ld L,(0x259E)` at 0xF905C0, so "E &=
;          Head16[(0x259E)]" is those two instructions plus the AND that
;          follows them. The four-copies claim is a MEASUREMENT, not an
;          impression: notes/prom_a_byte_checks.py asserts each fetcher is 23
;          bytes and that each differs from this one in exactly two bytes,
;          offsets 9 and 10. The same script pins this copy's single caller.
; Notes:   this routine also exists four times.  All four are 23 bytes and any
;          two of them differ in exactly TWO bytes -- offsets 9 and 10, the low
;          and middle bytes of the `ld XIX,imm32` that names the table.  Checked
;          by notes/prom_a_byte_checks.py.
; ---------------------------------------------------------------------
LCD_TextColMask_Head16_Fetch:
	push XHL                                      ; F905BE  3b
	push XIX                                      ; F905BF  3c
	ld l, (LCD_TextBitOffset:16)                            ; F905C0  c1 9e 25 27
	xor H,H                                       ; F905C4  ce d6
	ld XIX,LCD_TextColMask_Head16                 ; F905C6  44 d5 05 f9 00
	ld	a, (xix+hl)                           ; F905CB  c3 07 f0 ec 21
	and E,A                                       ; F905D0  c9 c5
	pop XIX                                       ; F905D2  5c
	pop XHL                                       ; F905D3  5b
	ret                                           ; F905D4  0e

; ---------------------------------------------------------------------
; LCD_TextColMask_Head16 -- 9 bytes: keep pixels 0..k-1, i.e. 0xFF << (8-k)
;
; Read by:  LCD_TextColMask_Head16_Fetch (0xF905C6), indexed by (0x259E), 0..8.
; Layout:   9 bytes, 0xF905D5-0xF905DD; 0xF905DE is LCD_TextCol_MergeTail16's
;           first instruction, which is what fixes the length.
; Evidence: entry k = 0xFF << (8-k) for every k = 0..8, so the mask preserves
;           the pixels to the LEFT of where the string starts -- which is
;           exactly what the FIRST byte-column of a string needs.  The same nine
;           bytes appear at 0xF9076D (LCD_TextColMask_Head8) and at 0xF900A7
;           (LCD_PatternRightMask_Table): three byte-identical copies, and two
;           more nine-byte tables at 0xF8F7AF and 0xF8FE77 that differ from them
;           in one entry (index 8).  All five comparisons are checks in
;           notes/prom_a_byte_checks.py.
; ---------------------------------------------------------------------
LCD_TextColMask_Head16:
	.byte 0x00			; F905D5  index 0
	.byte 0x80			; F905D6  index 1
	.byte 0xC0			; F905D7  index 2
	.byte 0xE0			; F905D8  index 3
	.byte 0xF0			; F905D9  index 4
	.byte 0xF8			; F905DA  index 5
	.byte 0xFC			; F905DB  index 6
	.byte 0xFE			; F905DC  index 7
	.byte 0xFF			; F905DD  index 8

; ---------------------------------------------------------------------
; LCD_TextCol_MergeTail16 -- byte-for-byte LCD_TextCol_MergeHead16, reaching
; LCD_TextColMask_Tail16 instead
;
; Called from: LCD_Svc_1C_DrawText16x16Packed (0xF90406) and nowhere else
; Evidence: all 172 bytes equal to the copy at 0xF90512 -- the two differ only
;          in WHERE they sit, because each one's mask fetcher follows it at the
;          same displacement.  Checked by notes/prom_a_byte_checks.py.
; ---------------------------------------------------------------------
LCD_TextCol_MergeTail16:
	pushw iz                                      ; F905DE  2e
	ld XHL,0x00790000                             ; F905DF  43 00 00 79 00
	xor IZ,IZ                                     ; F905E4  de d6
.LF905E6:
	cp IZ,BC                                      ; F905E6  d9 f6
	jrl nc, .LF90688                              ; F905E8  7f 9d 00
	bit	0, (0xc6:8)                            ; F905EB  f0 c6 c8
	jr nz, .LF905F4                               ; F905EE  6e 04
.LF905F0:
	bit 6,(XHL)                                   ; F905F0  b3 ce
	jr nz, .LF905F0                               ; F905F2  6e fc
.LF905F4:
	ld (XHL+0x01),0x47                            ; F905F4  bb 01 00 47
	bit	0, (0xc6:8)                            ; F905F8  f0 c6 c8
	jr nz, .LF90601                               ; F905FB  6e 04
.LF905FD:
	bit 6,(XHL)                                   ; F905FD  b3 ce
	jr nz, .LF905FD                               ; F905FF  6e fc
.LF90601:
	ld A,(XHL+0x01)                               ; F90601  8b 01 21
	bit	0, (0xc6:8)                            ; F90604  f0 c6 c8
	jr nz, .LF9060D                               ; F90607  6e 04
.LF90609:
	bit 6,(XHL)                                   ; F90609  b3 ce
	jr nz, .LF90609                               ; F9060B  6e fc
.LF9060D:
	ld W,(XHL+0x01)                               ; F9060D  8b 01 20
	ld (LCD_RunAddress:16), wa                           ; F90610  f1 5a 25 50
	bit	0, (0xc6:8)                            ; F90614  f0 c6 c8
	jr nz, .LF9061D                               ; F90617  6e 04
.LF90619:
	bit 6,(XHL)                                   ; F90619  b3 ce
	jr nz, .LF90619                               ; F9061B  6e fc
.LF9061D:
	ld (XHL+0x01),0x43                            ; F9061D  bb 01 00 43
	bit	0, (0xc6:8)                            ; F90621  f0 c6 c8
	jr nz, .LF9062A                               ; F90624  6e 04
.LF90626:
	bit 6,(XHL)                                   ; F90626  b3 ce
	jr nz, .LF90626                               ; F90628  6e fc
.LF9062A:
	ld E,(XHL+0x01)                               ; F9062A  8b 01 25
	calr .LF9068A                                 ; F9062D  1e 5a 00
	bit	0, (0xc6:8)                            ; F90630  f0 c6 c8
	jr nz, .LF90639                               ; F90633  6e 04
.LF90635:
	bit 6,(XHL)                                   ; F90635  b3 ce
	jr nz, .LF90635                               ; F90637  6e fc
.LF90639:
	ld (XHL+0x01),0x46                            ; F90639  bb 01 00 46
	ld wa, (LCD_RunAddress:16)                          ; F9063D  d1 5a 25 20
	bit	0, (0xc6:8)                            ; F90641  f0 c6 c8
	jr nz, .LF9064A                               ; F90644  6e 04
.LF90646:
	bit 6,(XHL)                                   ; F90646  b3 ce
	jr nz, .LF90646                               ; F90648  6e fc
.LF9064A:
	ld (XHL),A                                    ; F9064A  b3 41
	bit	0, (0xc6:8)                            ; F9064C  f0 c6 c8
	jr nz, .LF90655                               ; F9064F  6e 04
.LF90651:
	bit 6,(XHL)                                   ; F90651  b3 ce
	jr nz, .LF90651                               ; F90653  6e fc
.LF90655:
	ld (XHL),W                                    ; F90655  b3 40
	bit	0, (0xc6:8)                            ; F90657  f0 c6 c8
	jr nz, .LF90660                               ; F9065A  6e 04
.LF9065C:
	bit 6,(XHL)                                   ; F9065C  b3 ce
	jr nz, .LF9065C                               ; F9065E  6e fc
.LF90660:
	ld (XHL+0x01),0x4f                            ; F90660  bb 01 00 4f
	bit	0, (0xc6:8)                            ; F90664  f0 c6 c8
	jr nz, .LF9066D                               ; F90667  6e 04
.LF90669:
	bit 6,(XHL)                                   ; F90669  b3 ce
	jr nz, .LF90669                               ; F9066B  6e fc
.LF9066D:
	ld (XHL+0x01),0x42                            ; F9066D  bb 01 00 42
	ld	a, (xix+iz)                           ; F90671  c3 07 f0 f8 21
	or A,E                                        ; F90676  cd e1
	inc 1,IZ                                      ; F90678  de 61
	bit	0, (0xc6:8)                            ; F9067A  f0 c6 c8
	jr nz, .LF90683                               ; F9067D  6e 04
.LF9067F:
	bit 6,(XHL)                                   ; F9067F  b3 ce
	jr nz, .LF9067F                               ; F90681  6e fc
.LF90683:
	ld (XHL),A                                    ; F90683  b3 41
	jrl .LF905E6                                  ; F90685  78 5e ff
.LF90688:
	popw iz                                       ; F90688  4e
	ret                                           ; F90689  0e
.LF9068A:

; ---------------------------------------------------------------------
; LCD_TextColMask_Tail16_Fetch -- E &= LCD_TextColMask_Tail16[(0x259E)]
;
; Called from: LCD_TextCol_MergeTail16 (0xF9062D)
; Evidence: 23 bytes, two of them different from
;          LCD_TextColMask_Head16_Fetch's -- the table address.
; ---------------------------------------------------------------------
LCD_TextColMask_Tail16_Fetch:
	push XHL                                      ; F9068A  3b
	push XIX                                      ; F9068B  3c
	ld l, (LCD_TextBitOffset:16)                            ; F9068C  c1 9e 25 27
	xor H,H                                       ; F90690  ce d6
	ld XIX,LCD_TextColMask_Tail16                 ; F90692  44 a1 06 f9 00
	ld	a, (xix+hl)                           ; F90697  c3 07 f0 ec 21
	and E,A                                       ; F9069C  c9 c5
	pop XIX                                       ; F9069E  5c
	pop XHL                                       ; F9069F  5b
	ret                                           ; F906A0  0e

; ---------------------------------------------------------------------
; LCD_TextColMask_Tail16 -- 9 bytes, the mask the 16x16 service's FINAL column
; write uses
;
; Read by:  LCD_TextColMask_Tail16_Fetch (0xF90692), indexed by (0x259E), 0..8.
; Evidence: the arithmetic rule is built and diffed against the ROM by
;          notes/prom_a_byte_checks.py ("LCD_TextColMask_Tail16 ==
;          0xFF>>((k+11)%8), 0 at the boundary: 9 of 9"), so "all nine fit" is
;          a script's output. Where the table starts and stops is held by the
;          byte gate: 0xF906A1 is the immediate its fetcher loads and 0xF906AA
;          is the next routine's first instruction.
;          ⚠ what the rule means IN PIXELS is explicitly not established -- see
;          below.
; Layout:   9 bytes, 0xF906A1-0xF906A9; 0xF906AA is LCD_TextCol_MergeHead8's
;           first instruction.
; ★ THE ARITHMETIC, WHICH IS A FACT ABOUT THE BYTES:  entry k is
;       0xFF >> ((k + 11) mod 8),  except that where (k + 11) mod 8 is zero the
;       entry is 0x00 rather than 0xFF.
;   11 is this service's glyph advance.  ALL NINE entries fit that rule --
;   verified by notes/prom_a_byte_checks.py, which builds the table from the
;   rule and compares.  The k = 5 entry is the zero-substituted one, and 5 is
;   precisely the offset at which LCD_Svc_1C_DrawText16x16Packed's tail returns
;   without writing anything, so that entry is never read.
; ⚠ WHAT THE RULE MEANS IN PIXELS IS **NOT** ESTABLISHED.  Which byte-column the
;   tail flush lands in depends on the loop's (0x259C) bookkeeping, and no
;   reading of that has been checked against hardware or against a trace.  The
;   rule above is offered as arithmetic that reproduces the bytes, not as a
;   statement about what survives on the panel.
; ---------------------------------------------------------------------
LCD_TextColMask_Tail16:
	.byte 0x1F			; F906A1  index 0
	.byte 0x0F			; F906A2  index 1
	.byte 0x07			; F906A3  index 2
	.byte 0x03			; F906A4  index 3
	.byte 0x01			; F906A5  index 4
	.byte 0x00			; F906A6  index 5
	.byte 0x7F			; F906A7  index 6
	.byte 0x3F			; F906A8  index 7
	.byte 0x1F			; F906A9  index 8

; ---------------------------------------------------------------------
; LCD_TextCol_MergeHead8 -- the fourth copy of the column merger, and the only
; one whose bytes differ
;
; Called from: LCD_Svc_17_DrawText8x8Packed (0xF9019B and 0xF901C6)
; Evidence: 159 of its 172 bytes equal LCD_TextCol_MergeHead16's; the thirteen
;          at offsets 154-166 are the SAME thirteen bytes reordered -- `inc
;          1,IZ`, the nine-byte BUSY poll and `ld (XHL),A` -- with the increment
;          after the write here and before it there.  Same effect, different
;          instruction order; both counts are checked by
;          notes/prom_a_byte_checks.py.
; ---------------------------------------------------------------------
LCD_TextCol_MergeHead8:
	pushw iz                                      ; F906AA  2e
	ld XHL,0x00790000                             ; F906AB  43 00 00 79 00
	xor IZ,IZ                                     ; F906B0  de d6
.LF906B2:
	cp IZ,BC                                      ; F906B2  d9 f6
	jrl nc, .LF90754                              ; F906B4  7f 9d 00
	bit	0, (0xc6:8)                            ; F906B7  f0 c6 c8
	jr nz, .LF906C0                               ; F906BA  6e 04
.LF906BC:
	bit 6,(XHL)                                   ; F906BC  b3 ce
	jr nz, .LF906BC                               ; F906BE  6e fc
.LF906C0:
	ld (XHL+0x01),0x47                            ; F906C0  bb 01 00 47
	bit	0, (0xc6:8)                            ; F906C4  f0 c6 c8
	jr nz, .LF906CD                               ; F906C7  6e 04
.LF906C9:
	bit 6,(XHL)                                   ; F906C9  b3 ce
	jr nz, .LF906C9                               ; F906CB  6e fc
.LF906CD:
	ld A,(XHL+0x01)                               ; F906CD  8b 01 21
	bit	0, (0xc6:8)                            ; F906D0  f0 c6 c8
	jr nz, .LF906D9                               ; F906D3  6e 04
.LF906D5:
	bit 6,(XHL)                                   ; F906D5  b3 ce
	jr nz, .LF906D5                               ; F906D7  6e fc
.LF906D9:
	ld W,(XHL+0x01)                               ; F906D9  8b 01 20
	ld (LCD_RunAddress:16), wa                           ; F906DC  f1 5a 25 50
	bit	0, (0xc6:8)                            ; F906E0  f0 c6 c8
	jr nz, .LF906E9                               ; F906E3  6e 04
.LF906E5:
	bit 6,(XHL)                                   ; F906E5  b3 ce
	jr nz, .LF906E5                               ; F906E7  6e fc
.LF906E9:
	ld (XHL+0x01),0x43                            ; F906E9  bb 01 00 43
	bit	0, (0xc6:8)                            ; F906ED  f0 c6 c8
	jr nz, .LF906F6                               ; F906F0  6e 04
.LF906F2:
	bit 6,(XHL)                                   ; F906F2  b3 ce
	jr nz, .LF906F2                               ; F906F4  6e fc
.LF906F6:
	ld E,(XHL+0x01)                               ; F906F6  8b 01 25
	calr .LF90756                                 ; F906F9  1e 5a 00
	bit	0, (0xc6:8)                            ; F906FC  f0 c6 c8
	jr nz, .LF90705                               ; F906FF  6e 04
.LF90701:
	bit 6,(XHL)                                   ; F90701  b3 ce
	jr nz, .LF90701                               ; F90703  6e fc
.LF90705:
	ld (XHL+0x01),0x46                            ; F90705  bb 01 00 46
	ld wa, (LCD_RunAddress:16)                          ; F90709  d1 5a 25 20
	bit	0, (0xc6:8)                            ; F9070D  f0 c6 c8
	jr nz, .LF90716                               ; F90710  6e 04
.LF90712:
	bit 6,(XHL)                                   ; F90712  b3 ce
	jr nz, .LF90712                               ; F90714  6e fc
.LF90716:
	ld (XHL),A                                    ; F90716  b3 41
	bit	0, (0xc6:8)                            ; F90718  f0 c6 c8
	jr nz, .LF90721                               ; F9071B  6e 04
.LF9071D:
	bit 6,(XHL)                                   ; F9071D  b3 ce
	jr nz, .LF9071D                               ; F9071F  6e fc
.LF90721:
	ld (XHL),W                                    ; F90721  b3 40
	bit	0, (0xc6:8)                            ; F90723  f0 c6 c8
	jr nz, .LF9072C                               ; F90726  6e 04
.LF90728:
	bit 6,(XHL)                                   ; F90728  b3 ce
	jr nz, .LF90728                               ; F9072A  6e fc
.LF9072C:
	ld (XHL+0x01),0x4f                            ; F9072C  bb 01 00 4f
	bit	0, (0xc6:8)                            ; F90730  f0 c6 c8
	jr nz, .LF90739                               ; F90733  6e 04
.LF90735:
	bit 6,(XHL)                                   ; F90735  b3 ce
	jr nz, .LF90735                               ; F90737  6e fc
.LF90739:
	ld (XHL+0x01),0x42                            ; F90739  bb 01 00 42
	ld	a, (xix+iz)                           ; F9073D  c3 07 f0 f8 21
	or A,E                                        ; F90742  cd e1
	bit	0, (0xc6:8)                            ; F90744  f0 c6 c8
	jr nz, .LF9074D                               ; F90747  6e 04
.LF90749:
	bit 6,(XHL)                                   ; F90749  b3 ce
	jr nz, .LF90749                               ; F9074B  6e fc
.LF9074D:
	ld (XHL),A                                    ; F9074D  b3 41
	inc 1,IZ                                      ; F9074F  de 61
	jrl .LF906B2                                  ; F90751  78 5e ff
.LF90754:
	popw iz                                       ; F90754  4e
	ret                                           ; F90755  0e
.LF90756:

; ---------------------------------------------------------------------
; LCD_TextColMask_Head8_Fetch -- E &= LCD_TextColMask_Head8[(0x259E)]
;
; Called from: LCD_TextCol_MergeHead8 (0xF906F9) and
;          LCD_TextCol_ReadIntoBufA (0xF908EB)
; Evidence: the same shape as the 16x16 fetcher, and the same measurement backs
;          it -- `ld L,(0x259E)` at 0xF90758 and `ld XIX,0x00F9076D` at
;          0xF9075E, with notes/prom_a_byte_checks.py asserting 23 bytes and
;          exactly two differing bytes (offsets 9 and 10) against 0xF905BE.
;          The same script pins that this copy has exactly the two callers
;          named above and no other.
; ---------------------------------------------------------------------
LCD_TextColMask_Head8_Fetch:
	push XHL                                      ; F90756  3b
	push XIX                                      ; F90757  3c
	ld l, (LCD_TextBitOffset:16)                            ; F90758  c1 9e 25 27
	xor H,H                                       ; F9075C  ce d6
	ld XIX,LCD_TextColMask_Head8                  ; F9075E  44 6d 07 f9 00
	ld	a, (xix+hl)                           ; F90763  c3 07 f0 ec 21
	and E,A                                       ; F90768  c9 c5
	pop XIX                                       ; F9076A  5c
	pop XHL                                       ; F9076B  5b
	ret                                           ; F9076C  0e

; ---------------------------------------------------------------------
; LCD_TextColMask_Head8 -- 9 bytes: keep pixels 0..k-1, i.e. 0xFF << (8-k)
;
; Read by:  LCD_TextColMask_Head8_Fetch (0xF9075E), indexed by (0x259E), 0..8.
; Layout:   9 bytes, 0xF9076D-0xF90775; 0xF90776 is LCD_TextCol_MergeTail8's
;           first instruction.
; Evidence: byte for byte LCD_TextColMask_Head16 -- 9 of 9 equal.
; ---------------------------------------------------------------------
LCD_TextColMask_Head8:
	.byte 0x00			; F9076D  index 0
	.byte 0x80			; F9076E  index 1
	.byte 0xC0			; F9076F  index 2
	.byte 0xE0			; F90770  index 3
	.byte 0xF0			; F90771  index 4
	.byte 0xF8			; F90772  index 5
	.byte 0xFC			; F90773  index 6
	.byte 0xFE			; F90774  index 7
	.byte 0xFF			; F90775  index 8

; ---------------------------------------------------------------------
; LCD_TextCol_MergeTail8 -- the third byte-identical copy of the column merger
;
; Called from: LCD_Svc_17_DrawText8x8Packed (0xF9024D and 0xF9025A)
; Evidence: all 172 bytes equal LCD_TextCol_MergeHead16's and
;          LCD_TextCol_MergeTail16's.
; ---------------------------------------------------------------------
LCD_TextCol_MergeTail8:
	pushw iz                                      ; F90776  2e
	ld XHL,0x00790000                             ; F90777  43 00 00 79 00
	xor IZ,IZ                                     ; F9077C  de d6
.LF9077E:
	cp IZ,BC                                      ; F9077E  d9 f6
	jrl nc, .LF90820                              ; F90780  7f 9d 00
	bit	0, (0xc6:8)                            ; F90783  f0 c6 c8
	jr nz, .LF9078C                               ; F90786  6e 04
.LF90788:
	bit 6,(XHL)                                   ; F90788  b3 ce
	jr nz, .LF90788                               ; F9078A  6e fc
.LF9078C:
	ld (XHL+0x01),0x47                            ; F9078C  bb 01 00 47
	bit	0, (0xc6:8)                            ; F90790  f0 c6 c8
	jr nz, .LF90799                               ; F90793  6e 04
.LF90795:
	bit 6,(XHL)                                   ; F90795  b3 ce
	jr nz, .LF90795                               ; F90797  6e fc
.LF90799:
	ld A,(XHL+0x01)                               ; F90799  8b 01 21
	bit	0, (0xc6:8)                            ; F9079C  f0 c6 c8
	jr nz, .LF907A5                               ; F9079F  6e 04
.LF907A1:
	bit 6,(XHL)                                   ; F907A1  b3 ce
	jr nz, .LF907A1                               ; F907A3  6e fc
.LF907A5:
	ld W,(XHL+0x01)                               ; F907A5  8b 01 20
	ld (LCD_RunAddress:16), wa                           ; F907A8  f1 5a 25 50
	bit	0, (0xc6:8)                            ; F907AC  f0 c6 c8
	jr nz, .LF907B5                               ; F907AF  6e 04
.LF907B1:
	bit 6,(XHL)                                   ; F907B1  b3 ce
	jr nz, .LF907B1                               ; F907B3  6e fc
.LF907B5:
	ld (XHL+0x01),0x43                            ; F907B5  bb 01 00 43
	bit	0, (0xc6:8)                            ; F907B9  f0 c6 c8
	jr nz, .LF907C2                               ; F907BC  6e 04
.LF907BE:
	bit 6,(XHL)                                   ; F907BE  b3 ce
	jr nz, .LF907BE                               ; F907C0  6e fc
.LF907C2:
	ld E,(XHL+0x01)                               ; F907C2  8b 01 25
	calr .LF90822                                 ; F907C5  1e 5a 00
	bit	0, (0xc6:8)                            ; F907C8  f0 c6 c8
	jr nz, .LF907D1                               ; F907CB  6e 04
.LF907CD:
	bit 6,(XHL)                                   ; F907CD  b3 ce
	jr nz, .LF907CD                               ; F907CF  6e fc
.LF907D1:
	ld (XHL+0x01),0x46                            ; F907D1  bb 01 00 46
	ld wa, (LCD_RunAddress:16)                          ; F907D5  d1 5a 25 20
	bit	0, (0xc6:8)                            ; F907D9  f0 c6 c8
	jr nz, .LF907E2                               ; F907DC  6e 04
.LF907DE:
	bit 6,(XHL)                                   ; F907DE  b3 ce
	jr nz, .LF907DE                               ; F907E0  6e fc
.LF907E2:
	ld (XHL),A                                    ; F907E2  b3 41
	bit	0, (0xc6:8)                            ; F907E4  f0 c6 c8
	jr nz, .LF907ED                               ; F907E7  6e 04
.LF907E9:
	bit 6,(XHL)                                   ; F907E9  b3 ce
	jr nz, .LF907E9                               ; F907EB  6e fc
.LF907ED:
	ld (XHL),W                                    ; F907ED  b3 40
	bit	0, (0xc6:8)                            ; F907EF  f0 c6 c8
	jr nz, .LF907F8                               ; F907F2  6e 04
.LF907F4:
	bit 6,(XHL)                                   ; F907F4  b3 ce
	jr nz, .LF907F4                               ; F907F6  6e fc
.LF907F8:
	ld (XHL+0x01),0x4f                            ; F907F8  bb 01 00 4f
	bit	0, (0xc6:8)                            ; F907FC  f0 c6 c8
	jr nz, .LF90805                               ; F907FF  6e 04
.LF90801:
	bit 6,(XHL)                                   ; F90801  b3 ce
	jr nz, .LF90801                               ; F90803  6e fc
.LF90805:
	ld (XHL+0x01),0x42                            ; F90805  bb 01 00 42
	ld	a, (xix+iz)                           ; F90809  c3 07 f0 f8 21
	or A,E                                        ; F9080E  cd e1
	inc 1,IZ                                      ; F90810  de 61
	bit	0, (0xc6:8)                            ; F90812  f0 c6 c8
	jr nz, .LF9081B                               ; F90815  6e 04
.LF90817:
	bit 6,(XHL)                                   ; F90817  b3 ce
	jr nz, .LF90817                               ; F90819  6e fc
.LF9081B:
	ld (XHL),A                                    ; F9081B  b3 41
	jrl .LF9077E                                  ; F9081D  78 5e ff
.LF90820:
	popw iz                                       ; F90820  4e
	ret                                           ; F90821  0e
.LF90822:

; ---------------------------------------------------------------------
; LCD_TextColMask_Tail8_Fetch -- E &= LCD_TextColMask_Tail8[(0x259E)]
;
; Called from: LCD_TextCol_MergeTail8 (0xF907C5)
; Evidence: `ld L,(0x259E)` at 0xF90824 and `ld XIX,0x00F90839` at 0xF9082A
;          name the index and the table; notes/prom_a_byte_checks.py asserts
;          this fetcher is 23 bytes and differs from 0xF905BE in exactly two
;          bytes (offsets 9 and 10), and that its only caller is the one named
;          above.
; ---------------------------------------------------------------------
LCD_TextColMask_Tail8_Fetch:
	push XHL                                      ; F90822  3b
	push XIX                                      ; F90823  3c
	ld l, (LCD_TextBitOffset:16)                            ; F90824  c1 9e 25 27
	xor H,H                                       ; F90828  ce d6
	ld XIX,LCD_TextColMask_Tail8                  ; F9082A  44 39 08 f9 00
	ld	a, (xix+hl)                           ; F9082F  c3 07 f0 ec 21
	and E,A                                       ; F90834  c9 c5
	pop XIX                                       ; F90836  5c
	pop XHL                                       ; F90837  5b
	ret                                           ; F90838  0e

; ---------------------------------------------------------------------
; LCD_TextColMask_Tail8 -- 9 bytes, the mask the 8x8 service's FINAL column
; write uses
;
; Read by:  LCD_TextColMask_Tail8_Fetch (0xF9082A), indexed by (0x259E), 0..8.
; Evidence: the rule and its ONE exception are both a script's output --
;          notes/prom_a_byte_checks.py ("LCD_TextColMask_Tail8 fits the same
;          rule with W=6 in 8 of 9, index 1 apart"), which builds the table
;          from the rule and diffs it rather than asserting a sentence. The
;          extent is held by the byte gate: 0xF90839 is the immediate its
;          fetcher loads and 0xF90842 is the next routine.
;          ⚠ index 1's 0x00 has no explanation in the rule; that is stated, not
;          smoothed.
; Layout:   9 bytes, 0xF90839-0xF90841; 0xF90842 is LCD_TextCol_WriteRaw's
;           first instruction.
; ★ THE ARITHMETIC:  entry k is 0xFF >> ((k + 6) mod 8), with 0x00 where that
;   comes out zero -- the same rule as LCD_TextColMask_Tail16 with this
;   service's advance, 6, in place of 11.  EIGHT of the nine entries fit it;
;   index 1 holds 0x00 where the rule gives 0x01.  Both the eight and the one
;   are produced by notes/prom_a_byte_checks.py, which builds the rule's table
;   and diffs it.
; ⚠ The k = 2 entry is the zero-substituted one -- 2 is where a 6-wide glyph
;   ends flush with a byte boundary -- but unlike the 16x16 service, this one
;   does NOT return early at that offset; it flushes buffer A with a mask of
;   0x00.  And index 1's 0x00 has no explanation in the rule at all.  Whether
;   either is deliberate is NOT established, and no claim is made here that the
;   firmware is right or wrong; the bytes are recorded so that whoever traces a
;   caller can settle it.
; ---------------------------------------------------------------------
LCD_TextColMask_Tail8:
	.byte 0x03			; F90839  index 0
	.byte 0x00			; F9083A  index 1
	.byte 0x00			; F9083B  index 2
	.byte 0x7F			; F9083C  index 3
	.byte 0x3F			; F9083D  index 4
	.byte 0x1F			; F9083E  index 5
	.byte 0x0F			; F9083F  index 6
	.byte 0x07			; F90840  index 7
	.byte 0x03			; F90841  index 8

; ---------------------------------------------------------------------
; LCD_TextCol_WriteRaw -- write BC buffer bytes straight down a column
;
; Called from: six sites across the two packed-text services (0xF9022A,
;          0xF902F0, 0xF90322, 0xF9038F, 0xF903A8, 0xF903DB)
; Inputs:  BC = rows; XIX = the buffer; the cursor already positioned by
;          LCD_TextCol_SetCursor
; Outputs: BC display bytes overwritten -- NO read, NO mask, NO merge.  XIZ
;          saved and restored.
; Evidence: CSRDIR DOWN (0x4F) then MWRITE (0x42) once, then a plain loop of
;          `ld A,(XIX+IZ)` / `ld (XHL),A`.  It is used for the byte columns that
;          lie wholly inside the string, where nothing of the panel needs
;          keeping; the merging copies are used at the two ends.
; ---------------------------------------------------------------------
LCD_TextCol_WriteRaw:
	push XIZ                                      ; F90842  3e
	ld XHL,0x00790000                             ; F90843  43 00 00 79 00
	bit	0, (0xc6:8)                            ; F90848  f0 c6 c8
	jr nz, .LF90851                               ; F9084B  6e 04
.LF9084D:
	bit 6,(XHL)                                   ; F9084D  b3 ce
	jr nz, .LF9084D                               ; F9084F  6e fc
.LF90851:
	ld (XHL+0x01),0x4f                            ; F90851  bb 01 00 4f
	bit	0, (0xc6:8)                            ; F90855  f0 c6 c8
	jr nz, .LF9085E                               ; F90858  6e 04
.LF9085A:
	bit 6,(XHL)                                   ; F9085A  b3 ce
	jr nz, .LF9085A                               ; F9085C  6e fc
.LF9085E:
	ld (XHL+0x01),0x42                            ; F9085E  bb 01 00 42
	xor IZ,IZ                                     ; F90862  de d6
.LF90864:
	cp IZ,BC                                      ; F90864  d9 f6
	jr nc, .LF9087C                               ; F90866  6f 14
	ld	a, (xix+iz)                           ; F90868  c3 07 f0 f8 21
	inc 1,IZ                                      ; F9086D  de 61
	bit	0, (0xc6:8)                            ; F9086F  f0 c6 c8
	jr nz, .LF90878                               ; F90872  6e 04
.LF90874:
	bit 6,(XHL)                                   ; F90874  b3 ce
	jr nz, .LF90874                               ; F90876  6e fc
.LF90878:
	ld (XHL),A                                    ; F90878  b3 41
	jr .LF90864                                   ; F9087A  68 e8
.LF9087C:
	pop XIZ                                       ; F9087C  5e
	ret                                           ; F9087D  0e

; ---------------------------------------------------------------------
; LCD_TextCol_SetCursor -- CSRDIR DOWN, then CSRW with (0x259C)
;
; Called from: twelve sites across the two packed-text services (0xF90190,
;          0xF901AC, 0xF901BB, 0xF9021F, 0xF9023B, 0xF902CC, 0xF902E5,
;          0xF90317, 0xF90384, 0xF9039D, 0xF903D0, 0xF903FB)
; Inputs:  (0x259C) = the display-RAM address of the byte column to write
; Outputs: the cursor set there and its direction set to DOWN, so the next
;          MWRITE run walks a column.  WA and XHL clobbered.
; Evidence: the routine sends CSRDIR DOWN and then CSRW with (0x259C), which is
;          what the name says, and the twelve call sites are no longer a hand
;          count -- notes/prom_a_byte_checks.py re-derives them from every PC-
;          relative branch in prom_a and asserts the exact list
;          ("LCD_TextCol_SetCursor: exactly 12 caller(s), and they are the
;          listed ones").
; ---------------------------------------------------------------------
LCD_TextCol_SetCursor:
	ld XHL,0x00790000                             ; F9087E  43 00 00 79 00
	bit	0, (0xc6:8)                            ; F90883  f0 c6 c8
	jr nz, .LF9088C                               ; F90886  6e 04
.LF90888:
	bit 6,(XHL)                                   ; F90888  b3 ce
	jr nz, .LF90888                               ; F9088A  6e fc
.LF9088C:
	ld (XHL+0x01),0x4f                            ; F9088C  bb 01 00 4f
	bit	0, (0xc6:8)                            ; F90890  f0 c6 c8
	jr nz, .LF90899                               ; F90893  6e 04
.LF90895:
	bit 6,(XHL)                                   ; F90895  b3 ce
	jr nz, .LF90895                               ; F90897  6e fc
.LF90899:
	ld (XHL+0x01),0x46                            ; F90899  bb 01 00 46
	ld wa, (LCD_TextColumnAddr:16)                          ; F9089D  d1 9c 25 20
	bit	0, (0xc6:8)                            ; F908A1  f0 c6 c8
	jr nz, .LF908AA                               ; F908A4  6e 04
.LF908A6:
	bit 6,(XHL)                                   ; F908A6  b3 ce
	jr nz, .LF908A6                               ; F908A8  6e fc
.LF908AA:
	ld (XHL),A                                    ; F908AA  b3 41
	bit	0, (0xc6:8)                            ; F908AC  f0 c6 c8
	jr nz, .LF908B5                               ; F908AF  6e 04
.LF908B1:
	bit 6,(XHL)                                   ; F908B1  b3 ce
	jr nz, .LF908B1                               ; F908B3  6e fc
.LF908B5:
	ld (XHL),W                                    ; F908B5  b3 40
	ret                                           ; F908B7  0e

; ---------------------------------------------------------------------
; LCD_TextCol_ReadIntoBufA -- read a column off the panel and OR it into buffer A
;
; Called from: LCD_Svc_17_DrawText8x8Packed (0xF901B2) and nowhere else
; Inputs:  BC = rows; the cursor already set by LCD_TextCol_SetCursor
; Outputs: TextShift_BufA[i] |= (the panel byte at row i, masked by
;          LCD_TextColMask_Head8)
; Evidence: "and nowhere else" is a SEARCH, and it is now runnable --
;          notes/prom_a_byte_checks.py resolves every PC-relative branch in
;          prom_a and every 3-byte LE address in prom_a + prom_b, and finds
;          exactly one caller, 0xF901B2, and no site naming this address as
;          data. The read half is the body: the panel byte comes back through
;          the 0x790000 window and is ORed into buffer A after
;          LCD_TextColMask_Head8_Fetch masks it.
; Notes:   the read half of a read-modify-write, done once for the FIRST
;          character of a string when its start offset is small enough that the
;          glyph shares its first byte with whatever was already there.
; ---------------------------------------------------------------------
LCD_TextCol_ReadIntoBufA:
	push XIZ                                      ; F908B8  3e
	push XIX                                      ; F908B9  3c
	ld XHL,0x00790000                             ; F908BA  43 00 00 79 00
	bit	0, (0xc6:8)                            ; F908BF  f0 c6 c8
	jr nz, .LF908C8                               ; F908C2  6e 04
.LF908C4:
	bit 6,(XHL)                                   ; F908C4  b3 ce
	jr nz, .LF908C4                               ; F908C6  6e fc
.LF908C8:
	ld (XHL+0x01),0x4f                            ; F908C8  bb 01 00 4f
	bit	0, (0xc6:8)                            ; F908CC  f0 c6 c8
	jr nz, .LF908D5                               ; F908CF  6e 04
.LF908D1:
	bit 6,(XHL)                                   ; F908D1  b3 ce
	jr nz, .LF908D1                               ; F908D3  6e fc
.LF908D5:
	ld (XHL+0x01),0x43                            ; F908D5  bb 01 00 43
	xor IZ,IZ                                     ; F908D9  de d6
.LF908DB:
	cp IZ,BC                                      ; F908DB  d9 f6
	jr nc, .LF908FC                               ; F908DD  6f 1d
	bit	0, (0xc6:8)                            ; F908DF  f0 c6 c8
	jr nz, .LF908E8                               ; F908E2  6e 04
.LF908E4:
	bit 6,(XHL)                                   ; F908E4  b3 ce
	jr nz, .LF908E4                               ; F908E6  6e fc
.LF908E8:
	ld E,(XHL+0x01)                               ; F908E8  8b 01 25
	calr LCD_TextColMask_Head8_Fetch                                   ; F908EB  1e 68 fe
	ld XIX,0x0000256a                             ; F908EE  44 6a 25 00 00
	or	(xix+iz), e                           ; F908F3  c3 07 f0 f8 ed
	inc 1,IZ                                      ; F908F8  de 61
	jr .LF908DB                                   ; F908FA  68 df
.LF908FC:
	pop XIX                                       ; F908FC  5c
	pop XIZ                                       ; F908FD  5e
	ret                                           ; F908FE  0e

; ---------------------------------------------------------------------
; LCD_Svc_1E_ScrollCurrentLayer -- SWI7 service 0x1E: move the current layer's
; window in display RAM and re-send SCROLL
;
; Called from: SWI7_ServiceTable slot 0x1E (0xF8EA3E)
; Inputs:  C -- bits 7:6 a direction, bits 3:0 an amount of 0..15.
;          (0x2540) selects the layer.
; Outputs: that layer's base address changed by the amount, written back into
;          whichever of (0x2541)/(0x2543)/(0x2545) the layer table points at,
;          and the controller's SCROLL command re-sent with all three SADs and
;          both SLs.  (0x2555) holds the new base.  WA, HL, XHL, XIY clobbered.
; Evidence: ★ THIS IS THE PANEL'S HARDWARE SCROLL, and the four arms are read
;          straight off the arithmetic.  With n = C and 0x0F:
;
;            C and 0xC0 = 0x00   base := base + n*0x28
;            C and 0xC0 = 0x40   base := base - n*0x28
;            C and 0xC0 = 0x80   base := base - n
;            C and 0xC0 = 0xC0   base := base + n
;
;          0x28 is AP, the 40 bytes SYSTEM SET gives a scan line, so the first
;          two arms move the window by n LINES and the last two by n BYTE
;          COLUMNS -- eight pixels each.  The multiply is a literal
;          `ld DE,0x0028` + `mul XWA,DE` in both line arms.  It then walks
;          LCD_LayerBasePtr_Table exactly as LCD_SelectCurrentLayer does --
;          `(0x2540)` zero-extended, times 4, indexed into 0xF8EEB1 -- and
;          stores the new value through the pointer it finds, so the change
;          survives the next LCD_SelectCurrentLayer.
;          The SCROLL it then issues is the same eight parameter bytes
;          LCD_Init_SED1330 sends, except that SAD1/SAD2/SAD3 come from the
;          three RAM words instead of from constants, and the two SLs are the
;          same 0xF0 = 240.  Like the setup and like services 0x0F/0x10 it does
;          not poll BUSY -- single NOPs separate the accesses.
;
; ⚠ THE WRITE-BACK IS 32 BITS WIDE AND THE FIELD IS 16.  `ld XWA,(0x2555)` reads
;   FOUR bytes -- the layer base at (0x2555)/(0x2556) and AP at
;   (0x2557)/(0x2558) -- and `ld (XHL),XWA` writes four bytes through the layer
;   pointer.  Every reader of those words is 16-bit (LCD_SelectCurrentLayer's
;   `ld WA,(XHL)`, and this routine's own SCROLL), so the extra two bytes are
;   pure collateral, and where they land depends on the layer:
;       layer 0 -> (0x2543), i.e. SAD2, becomes 0x0028
;       layer 1 -> (0x2545), i.e. SAD3, becomes 0x0028
;       layer 2 -> (0x2547)/(0x2548), the line draw's swap flag and the low half
;                  of its slope -- both recomputed by LCD_Line_ChooseMajorAxis
;                  on every line, so nothing is lost
;   Only the layer-2 case is harmless.  That is a READING of the addresses, not
;   a measurement, and it is recorded rather than acted on: no caller of this
;   service is traced, so which layer it is used on is unknown.  Anyone
;   modelling this controller should reproduce the 32-bit store as it is.
; Unknown:  callers; and whether "base + n*AP" scrolls the image up or down on
;   the glass, which depends on the panel's scan order and is not determined by
;   anything in this firmware.
; ---------------------------------------------------------------------
LCD_Svc_1E_ScrollCurrentLayer:
	calr LCD_SelectCurrentLayer                                   ; F908FF  1e 91 e5
	ld A,C                                        ; F90902  cb 89
	and A,0x0f                                    ; F90904  c9 cc 0f
	xor W,W                                       ; F90907  c8 d0
	and C,0xc0                                    ; F90909  cb cc c0
	cp c, 0x00:i3                                   ; F9090C  cb d8
	jr z, .LF90926                                ; F9090E  66 16
	cp C,0x40                                     ; F90910  cb cf 40
	jr z, .LF90931                                ; F90913  66 1c
	cp C,0x80                                     ; F90915  cb cf 80
	jr z, .LF90920                                ; F90918  66 06
	add	(LCD_CurrentLayerBase:16), wa                       ; F9091A  d1 55 25 88
	jr .LF9093A                                   ; F9091E  68 1a
.LF90920:
	sub	(LCD_CurrentLayerBase:16), wa                       ; F90920  d1 55 25 a8
	jr .LF9093A                                   ; F90924  68 14
.LF90926:
	ldw de, 0x28                                  ; F90926  32 28 00
	mul xwa, de                                  ; F90929  da 40
	add	(LCD_CurrentLayerBase:16), wa                       ; F9092B  d1 55 25 88
	jr .LF9093A                                   ; F9092F  68 09
.LF90931:
	ldw de, 0x28                                  ; F90931  32 28 00
	mul xwa, de                                  ; F90934  da 40
	sub	(LCD_CurrentLayerBase:16), wa                       ; F90936  d1 55 25 a8
.LF9093A:
	xor H,H                                       ; F9093A  ce d6
	ld l, (LCD_CurrentLayer:16)                            ; F9093C  c1 40 25 27
	sla hl, 0x02                                  ; F90940  db ec 02
	ld XIY,LCD_LayerBasePtr_Table                 ; F90943  45 b1 ee f8 00
	ld	xhl, (xiy+hl)                         ; F90948  e3 07 f4 ec 23
	ld xwa, (LCD_CurrentLayerBase:16)                          ; F9094D  e1 55 25 20
	ld (XHL),XWA                                  ; F90951  b3 60
	ld XIY,0x00790000                             ; F90953  45 00 00 79 00
	nop                                           ; F90958  00
	ld (XIY+0x01),0x44                            ; F90959  bd 01 00 44
	nop                                           ; F9095D  00
	ld wa, (LCD_Layer0_SAD:16)                          ; F9095E  d1 41 25 20
	ld (XIY),A                                    ; F90962  b5 41
	nop                                           ; F90964  00
	nop                                           ; F90965  00
	ld (XIY),W                                    ; F90966  b5 40
	nop                                           ; F90968  00
	nop                                           ; F90969  00
	ld (XIY),0xf0                                 ; F9096A  b5 00 f0
	nop                                           ; F9096D  00
	ld wa, (LCD_Layer1_SAD:16)                          ; F9096E  d1 43 25 20
	ld (XIY),A                                    ; F90972  b5 41
	nop                                           ; F90974  00
	nop                                           ; F90975  00
	ld (XIY),W                                    ; F90976  b5 40
	nop                                           ; F90978  00
	nop                                           ; F90979  00
	ld (XIY),0xf0                                 ; F9097A  b5 00 f0
	nop                                           ; F9097D  00
	ld wa, (LCD_Layer2_SAD:16)                          ; F9097E  d1 45 25 20
	ld (XIY),A                                    ; F90982  b5 41
	nop                                           ; F90984  00
	nop                                           ; F90985  00
	ld (XIY),W                                    ; F90986  b5 40
	ret                                           ; F90988  0e

; ==============================================================================
; 0xF90989-0xF92C61 -- UI code, four pointer-table dispatches and a BITMASK one
; ==============================================================================
;
; Between SWI7's two packed text services (0xF90118-0xF90988) and the UI screen
; code at 0xF92C62-0xF96017, and the same kind of thing as the latter: routines
; that hand a 32-entry pointer table to the directory slot T_F41B08.  It is the
; single biggest consumer of that directory in prom_a -- 177 of its `call`s go
; to a 0xF41xxx slot.
;
; ★ WHAT IS NEW HERE: FieldRedraw_CallPerSetBit, a BITMASK dispatcher.  It takes a mask in A
;   and a table of eight routine pointers in XIY and calls, in bit order, the
;   entry for every bit that is set.  Four tables are handed to it, and the
;   masks come from (0x2679), (0x267A) and their neighbours.  That is the shape
;   of a "redraw every field whose dirty bit is set" pass, which is why the four
;   tables are named FieldRedrawPtrs_* -- ⚠ named for the SHAPE of the reader,
;   since what the eight fields ARE is not established.
;
; ⚠ WHAT THIS PASS DID NOT DO
;   It did not name the routines.  Every one is `sub_XXXXXX` except the two the
;   readers define.  It answers no emulation gap; it was chosen because it is a
;   whole .incbin span that the frontier ranks second (22 unconverted directory
;   slots, 8,280 bytes of contiguous target extent) and because closing it
;   leaves this quarter of prom_a unbroken from 0xF8E800 to 0xF96017.
; ==============================================================================

sub_F90989:
	ldw (UI_Request:16), 0x40ab                              ; F90989  f1 70 20 02 ab 40
	ld (UI_StatusCode:16), 0x24                                 ; F9098F  f1 80 28 00 24
	and	(0x20a9:16), 0xfe                            ; F90994  c1 a9 20 3c fe
	cp	(UI_ScreenId_Previous:16), 0xa3                            ; F90999  c1 7d 20 3f a3
	jr z, .LF909A4                                           ; F9099E  66 04
	call T_Drawbar_EnterScreenIfMarked                                        ; F909A0  1d 68 2e f4
.LF909A4:
	bit	4, (UI_ScreenFlags:16)                               ; F909A4  f1 95 20 cc
	jr nz, .LF909BC                                          ; F909A8  6e 12
	ld XWA,Paint_SoundMode_DeadCopy                                    ; F909AA  40 cf 09 f9 00
	push XWA                                             ; F909AF  38
	call T_CallbackQueue_Post                            ; F909B0  1d 84 2e f4
	inc 4,XSP                                            ; F909B4  ef 64
	ld a, 0x01:opc                                          ; F909B6  21 01
	call T_Kernel_SemaSignal                             ; F909B8  1d 88 2d f4
.LF909BC:
	ld XWA,Paint_SoundModeFields_DeadCopy                                    ; F909BC  40 42 0a f9 00
	push XWA                                             ; F909C1  38
	call T_CallbackQueue_Post                            ; F909C2  1d 84 2e f4
	inc 4,XSP                                            ; F909C6  ef 64
	ld a, 0x01:opc                                          ; F909C8  21 01
	call T_Kernel_SemaSignal                             ; F909CA  1d 88 2d f4
	ret                                                  ; F909CE  0e
; Paint_SoundMode_DeadCopy -- never-called older copy of Paint_SoundMode (0xF90DDB)
; Evidence: 108 of its 115 bytes align with 0xF90DDB; the single-byte differences at 0xF90A10, 0xF90A1E and 0xF90A23
;   are list operands (0xF28331/0xF28345 here vs Paint_SoundMode_DL/DL_Drawbar live, 10 bytes lower), and the tail calls
;   differ.  Only sub_F90989 names it (`ld XWA` at 0xF909AA), and nothing names sub_F90989 (24-bit scan of prom_a and
;   prom_b: 0 hits). Part of the stale block 0xF90989-0xF90BFF that the module at 0xF90C00 cuts off mid-instruction.
Paint_SoundMode_DeadCopy:   ; entry: named by 1 `ld` operand, first at 0xF909AA
	xor C,C                                              ; F909CF  cb d3
	ld a, 0x0c:opc                                          ; F909D1  21 0c
	swi 7                                                ; F909D3  ff
	ld a, 0x10:opc                                          ; F909D4  21 10
	swi 7                                                ; F909D6  ff
	cp	(Variant_Flag:8), 0x02                               ; F909D7  c0 c4 3f 02
	jr z, .LF90A05                                           ; F909DB  66 28
	ld (LCD_CurrentLayer:16), 0x00                                 ; F909DD  f1 40 25 00 00
	ld XIY,DL_F27C00                                     ; F909E2  45 00 7c f2 00
	ld XIX,DL_F28064                                     ; F909E7  44 64 80 f2 00
	call T_DisplayList_Run                               ; F909EC  1d f0 17 f4
	ld (LCD_CurrentLayer:16), 0x02                                 ; F909F0  f1 40 25 00 02
	ld XIY,DL_F28064                                     ; F909F5  45 64 80 f2 00
	ld XIX,DL_F2808C                                     ; F909FA  44 8c 80 f2 00
	call T_DisplayList_Run                               ; F909FF  1d f0 17 f4
	jr .LF90A2B                                              ; F90A03  68 26
.LF90A05:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F90A05  f1 40 25 00 00
	ld XIY,DL_F2808C                                     ; F90A0A  45 8c 80 f2 00
	ld XIX,Paint_SoundMode_DeadCopy_DL                                     ; F90A0F  44 31 83 f2 00
	call T_DisplayList_Run                               ; F90A14  1d f0 17 f4
	ld (LCD_CurrentLayer:16), 0x02                                 ; F90A18  f1 40 25 00 02
	ld XIY,Paint_SoundMode_DeadCopy_DL                                     ; F90A1D  45 31 83 f2 00
	ld XIX,0x00f28345                                    ; F90A22  44 45 83 f2 00
	call T_DisplayList_Run                               ; F90A27  1d f0 17 f4
.LF90A2B:
	or	(ModeScreen_DirtyFields:16), 0xff                            ; F90A2B  c1 76 26 3e ff
	or	(ModeScreen_DirtyFields2:16), 0x07                            ; F90A30  c1 77 26 3e 07
	orw	(0x2116:16), 0x0044                  ; F90A35  d1 16 21 3e 44 00
; stale: the live twin at +0x40C calls ModeScreen_DrawGmModeGlyph
	calr	ModeScreen_DrawGmModeGlyph - 0x494                              ; F90A3B  1e e4 02
; stale, old target 0xF90D51; the live twin is a `ret`, so no live counterpart
	calr	0x0310                                          ; F90A3E  1e 10 03
	ret                                                  ; F90A41  0e
; Paint_SoundModeFields_DeadCopy -- never-called older copy of Paint_SoundModeFields (0xF90E4B)
; Evidence: aligns with 0xF90E4E-0xF90F9F (the live routine after its `calr Paint_Drawbar`) at 309 of 332 bytes; the
;   differences are calr displacements, list operands and two fields read from (XIY+3)/(XIY+8) where the live code
;   reads (0x0710)/(0x0711).  Named only by sub_F90989 (`ld XWA` at 0xF909BC), which nothing references.
Paint_SoundModeFields_DeadCopy:   ; entry: named by 1 `ld` operand, first at 0xF909BC
	ld (LCD_CurrentLayer:16), 0x00                                 ; F90A42  f1 40 25 00 00
; stale: the live twin calls PartRecord_GetPtr
	calr	PartRecord_GetPtr - 0x859                       ; F90A47  1e 96 32
	ld A,(XIY)                                           ; F90A4A  85 21
	ld W,(XIY+0x01)                                      ; F90A4C  8d 01 20
	and W,0x7f                                           ; F90A4F  c8 cc 7f
	ld b, (UI_PartIndex:16)                                   ; F90A52  c1 50 22 22
	call T_SoundName_Lookup                                        ; F90A56  1d 10 10 f4
	ldw bc, 0x10                                         ; F90A5A  31 10 00
	xor HL,HL                                            ; F90A5D  db d3
	ldw ix, 0x09b4                                       ; F90A5F  34 b4 09
	ld a, 0x21:opc                                          ; F90A62  21 21
	swi 7                                                ; F90A64  ff
; stale: the live twin calls PartRecord_GetSecondHalfPtr
	calr	PartRecord_GetSecondHalfPtr - 0x859             ; F90A65  1e 8c 32
	ld A,(XIY+0x1d)                                      ; F90A68  8d 1d 21
	and A,0xff                                           ; F90A6B  c9 cc ff
	ld (UI_DrawScratch:16), a                                   ; F90A6E  f1 40 26 41
	ld A,(XIY+0x1b)                                      ; F90A72  8d 1b 21
	and A,0xff                                           ; F90A75  c9 cc ff
	sll a, 0x03                                          ; F90A78  c9 ee 03
	ld W,(XIY+0x1c)                                      ; F90A7B  8d 1c 20
	and W,0xff                                           ; F90A7E  c8 cc ff
	or A,W                                               ; F90A81  c8 e1
	inc 1,A                                              ; F90A83  c9 61
	extz WA                                              ; F90A85  d8 12
	call T_Value_ToAsciiDigits3                          ; F90A87  1d 00 1b f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; F90A8B  f1 40 25 00 00
	ld XIY,0x00f29710                                    ; F90A90  45 10 97 f2 00
	ld XIX,0x00f2972e                                    ; F90A95  44 2e 97 f2 00
	call T_DisplayListB_Run                              ; F90A9A  1d f4 17 f4
; stale: the live twin calls PartRecord_GetPtr
	calr	PartRecord_GetPtr - 0x859                       ; F90A9E  1e 3f 32
	bit	0, (ModeScreen_DirtyFields:16)                               ; F90AA1  f1 76 26 c8
	jr z, .LF90AB9                                           ; F90AA5  66 12
	push XIY                                             ; F90AA7  3d
	ld A,(XIY+0x03)                                      ; F90AA8  8d 03 21
	ld (UI_DrawScratch:16), a                                   ; F90AAB  f1 40 26 41
	ld XIY,0x00f2841b                                    ; F90AAF  45 1b 84 f2 00
	call T_DLB_Handler_Decimal2Words                                        ; F90AB4  1d 0c 18 f4
	pop XIY                                              ; F90AB8  5d
.LF90AB9:
	bit	1, (ModeScreen_DirtyFields:16)                               ; F90AB9  f1 76 26 c9
	jr z, .LF90AD1                                           ; F90ABD  66 12
	push XIY                                             ; F90ABF  3d
	ld A,(XIY+0x08)                                      ; F90AC0  8d 08 21
	ld (UI_DrawScratch+1:16), a                                   ; F90AC3  f1 41 26 41
	ld XIY,0x00f28427                                    ; F90AC7  45 27 84 f2 00
	call T_DLB_Handler_StringTable2                      ; F90ACC  1d fc 17 f4
	pop XIY                                              ; F90AD0  5d
.LF90AD1:
	bit	2, (ModeScreen_DirtyFields:16)                               ; F90AD1  f1 76 26 ca
	jr z, .LF90AE9                                           ; F90AD5  66 12
	push XIY                                             ; F90AD7  3d
	ld A,(XIY+0x05)                                      ; F90AD8  8d 05 21
	ld (UI_DrawScratch+2:16), a                                   ; F90ADB  f1 42 26 41
	ld XIY,0x00f28438                                    ; F90ADF  45 38 84 f2 00
	call T_DLB_Handler_Decimal2Words                                        ; F90AE4  1d 0c 18 f4
	pop XIY                                              ; F90AE8  5d
.LF90AE9:
	bit	3, (ModeScreen_DirtyFields:16)                               ; F90AE9  f1 76 26 cb
	jr z, .LF90B01                                           ; F90AED  66 12
	push XIY                                             ; F90AEF  3d
	ld A,(XIY+0x07)                                      ; F90AF0  8d 07 21
	ld (UI_DrawScratch+3:16), a                                   ; F90AF3  f1 43 26 41
	ld XIY,0x00f28444                                    ; F90AF7  45 44 84 f2 00
	call T_DLB_Handler_Decimal2Words                                        ; F90AFC  1d 0c 18 f4
Paint_SoundModeFields_DeadCopy__F90B00:
	pop XIY                                              ; F90B00  5d
.LF90B01:
	bit	4, (ModeScreen_DirtyFields:16)                               ; F90B01  f1 76 26 cc
	jr z, .LF90B19                                           ; F90B05  66 12
	push XIY                                             ; F90B07  3d
	ld A,(XIY+0x0d)                                      ; F90B08  8d 0d 21
	ld (UI_DrawScratch+4:16), a                                   ; F90B0B  f1 44 26 41
	ld XIY,0x00f2868a                                    ; F90B0F  45 8a 86 f2 00
	call T_DLB_Handler_StringTable2                      ; F90B14  1d fc 17 f4
	pop XIY                                              ; F90B18  5d
.LF90B19:
	bit	5, (ModeScreen_DirtyFields:16)                               ; F90B19  f1 76 26 cd
	jr z, .LF90B31                                           ; F90B1D  66 12
	push XIY                                             ; F90B1F  3d
	ld A,(XIY+0x0d)                                      ; F90B20  8d 0d 21
	ld (UI_DrawScratch+5:16), a                                   ; F90B23  f1 45 26 41
	ld XIY,0x00f28450                                    ; F90B27  45 50 84 f2 00
	call T_DLB_Handler_StringTable2                      ; F90B2C  1d fc 17 f4
	pop XIY                                              ; F90B30  5d
.LF90B31:
	bit	7, (ModeScreen_DirtyFields:16)                               ; F90B31  f1 76 26 cf
	jr z, .LF90B52                                           ; F90B35  66 1b
	push XIY                                             ; F90B37  3d
	ld A,(XIY+0x06)                                      ; F90B38  8d 06 21
	and A,0x7f                                           ; F90B3B  c9 cc 7f
	cp a, 0x00:i3                                          ; F90B3E  c9 d8
	jr z, .LF90B44                                           ; F90B40  66 02
	ld a, 0x01:opc                                          ; F90B42  21 01
.LF90B44:
	ld (UI_DrawScratch+6:16), a                                   ; F90B44  f1 46 26 41
	ld XIY,0x00f286a1                                    ; F90B48  45 a1 86 f2 00
	call T_DLB_Handler_StringTable2                      ; F90B4D  1d fc 17 f4
	pop XIY                                              ; F90B51  5d
.LF90B52:
	bit	6, (ModeScreen_DirtyFields:16)                               ; F90B52  f1 76 26 ce
	jr z, .LF90B7B                                           ; F90B56  66 23
	push XIY                                             ; F90B58  3d
	ld XIY,0x000078b2                                    ; F90B59  45 b2 78 00 00
	ld	a, (xiy+0:8)                                 ; F90B5E  8d 00 21
	sub A,0x1c                                           ; F90B61  c9 ca 1c
	extz WA                                              ; F90B64  d8 12
	cp wa, 0x00:i3                                         ; F90B66  d8 d8
	jr z, .LF90B6D                                           ; F90B68  66 03
	div A,0x0c                                           ; F90B6A  c9 0a 0c
.LF90B6D:
	ld (UI_DrawScratch+7:16), a                                   ; F90B6D  f1 47 26 41
	ld XIY,0x00f28790                                    ; F90B71  45 90 87 f2 00
	call T_DLB_Handler_StringTable2                      ; F90B76  1d fc 17 f4
	pop XIY                                              ; F90B7A  5d
.LF90B7B:
	calr ModeScreen_PaintDirtyFields2_DeadCopy                                            ; F90B7B  1e 10 00
	ld (ModeScreen_DirtyFields:16), 0x00                                 ; F90B7E  f1 76 26 00 00
	ld (ModeScreen_DirtyFields2:16), 0x00                                 ; F90B83  f1 77 26 00 00
	ld c, 0x07:opc                                          ; F90B88  23 07
	ld a, 0x0c:opc                                          ; F90B8A  21 0c
	swi 7                                                ; F90B8C  ff
	ret                                                  ; F90B8D  0e
; ModeScreen_PaintDirtyFields2_DeadCopy -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 3 time(s) in the 38
; instructions to its first `ret`:
;     site 0xF90BB4  interpreter B  list 0xF286B8-0xF286E4
;     site 0xF90BC9  interpreter B  list 0xF28724-0xF28750
;     site 0xF90BE8  interpreter A  list 0xF287C1-0xF287CB
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; ModeScreen_PaintDirtyFields2_DeadCopy: Never-run older copy of ModeScreen_PaintDirtyFields2: on
;   ModeScreen_DirtyFields2 bit 0 / bit 1 redraws the part record's +0x18 / +0x19 fields with layer-1 lists by
;   Variant_Flag; the first 38 bytes match the live routine, and unlike it this copy still has a variant-2 arm (lists
;   0xF28724-0xF28750) where the live one keeps a `jr +0`. Paint_SoundModeFields_DeadCopy calls it at the point where
;   Paint_SoundModeFields calls ModeScreen_PaintDirtyFields2; truncated at 0xF90C00 by the module there. Basis: caller
;   + body + live twin. (notes/naming-pilot-2026-10-06/proposals_wave8_b8.json)
ModeScreen_PaintDirtyFields2_DeadCopy:
	bit	0, (ModeScreen_DirtyFields2:16)                               ; F90B8E  f1 77 26 c8
	jr z, .LF90BCD                                           ; F90B92  66 39
; stale: 0xF93CF4, the old address the twin-paired call at 0xF90A65 names
	call	PartRecord_GetSecondHalfPtr - 0x859             ; F90B94  1d f4 3c f9
	ld A,(XIY+0x18)                                      ; F90B98  8d 18 21
	ld (UI_DrawScratch:16), a                                   ; F90B9B  f1 40 26 41
	cp	(Variant_Flag:8), 0x02                               ; F90B9F  c0 c4 3f 02
	jr z, .LF90BBA                                           ; F90BA3  66 15
	ld (LCD_CurrentLayer:16), 0x01                                 ; F90BA5  f1 40 25 00 01
	ld XIY,0x00f286b8                                    ; F90BAA  45 b8 86 f2 00
	ld XIX,0x00f286e4                                    ; F90BAF  44 e4 86 f2 00
	call T_DisplayListB_Run                              ; F90BB4  1d f4 17 f4
	jr .LF90BCD                                              ; F90BB8  68 13
.LF90BBA:
	ld (LCD_CurrentLayer:16), 0x01                                 ; F90BBA  f1 40 25 00 01
	ld XIY,0x00f28724                                    ; F90BBF  45 24 87 f2 00
	ld XIX,0x00f28750                                    ; F90BC4  44 50 87 f2 00
	call T_DisplayListB_Run                              ; F90BC9  1d f4 17 f4
.LF90BCD:
	bit	1, (ModeScreen_DirtyFields2:16)                               ; F90BCD  f1 77 26 c9
; stale: old target 0xF90C49, inside the block the module at 0xF90C00 overwrote
	jr	z, 0x76                                           ; F90BD1  66 76
	cp	(Variant_Flag:8), 0x02                               ; F90BD3  c0 c4 3f 02
; stale: old target 0xF90C49, as above
	jr	z, 0x70                                           ; F90BD7  66 70
	ld (LCD_CurrentLayer:16), 0x01                                 ; F90BD9  f1 40 25 00 01
	ld XIY,ModeScreen_PaintDirtyFields2_DeadCopy_DL                                ; F90BDE  45 c1 87 f2 00
	ld XIX,0x00f287cb                                    ; F90BE3  44 cb 87 f2 00
	call T_DisplayList_Run                               ; F90BE8  1d f0 17 f4
; stale: as at 0xF90B94
	call	PartRecord_GetSecondHalfPtr - 0x859             ; F90BEC  1d f4 3c f9
	ld A,(XIY+0x19)                                      ; F90BF0  8d 19 21
; stale, old target 0xF93D1F; no live twin to pair it with
	calr	0x3129                                          ; F90BF3  1e 29 31
	dec 1,A                                              ; F90BF6  c9 69
	ld (UI_DrawScratch:16), a                                   ; F90BF8  f1 40 26 41
	push XIY                                             ; F90BFC  3d
; The stale block ends here, cut off by the module at 0xF90C00: the first three bytes of an `ld XIY,imm32`.
	.byte	0x45, 0xd5, 0x87                                ; F90BFD  45 d5 87
; ModeEnter_Sound -- ENTER method of mode 1 (sound mode)
; Evidence: PanelScreen_VtableTable entry 1 -> T_ModeEnter_Sound (`jp 0xF90C00`, +4 T_F41504 = T_F41504_Nop).  `or
;   (0x2134),0x0002` requests PanelLed_ShowModeMenu (id 0x0002), as ModeEnter_Combination does; then UI_PartIndex := 0,
;   `calr Mode_SwitchToSound` and SoundGroup_LoadSelectionFromPart.  It was hidden by the stale block's cut-off
;   instruction above, decoded as `ld XIY,0x34d187d5` running into it.
ModeEnter_Sound:
	orw	(0x2134:16), 0x0002                              ; F90C00  d1 34 21 3e 02 00
	ld (UI_PartIndex:16), 0x00                                 ; F90C06  f1 50 22 00 00
	calr Mode_SwitchToSound                                            ; F90C0B  1e 64 00
	calr SoundGroup_LoadSelectionFromPart                                          ; F90C0E  1e 6d 37
	ret                                                  ; F90C11  0e
T_F41504_Nop:
	ret                                                  ; F90C12  0e
; ModeEnter_Combination -- ENTER method of mode 2 (combination mode)
; Evidence: PanelScreen_VtableTable entry 2 -> T_ModeEnter_Combination (`jp 0xF90C13`, +4 T_F4150C = ModeLeave_Combination). `or
;   (0x2134),0x0002` requests PanelLed_ShowModeMenu (id 0x0002), then `calr Mode_SwitchToCombination` and SoundGroup_LoadSelectionFromGlobal.
;   (T_ModeEnter_Combination is also the +8 slot of mode 1's object, which view A never calls.)
ModeEnter_Combination:
	orw	(0x2134:16), 0x0002                  ; F90C13  d1 34 21 3e 02 00
	calr Mode_SwitchToCombination                                            ; F90C19  1e 05 00
	calr SoundGroup_LoadSelectionFromGlobal                                          ; F90C1C  1e 97 37
	ret                                                  ; F90C1F  0e
T_F4150C_Nop:
	ret                                                  ; F90C20  0e
; Mode_SwitchToCombination -- switch the part block from sound-mode to combination-mode contents
; Evidence: no-op when (0x7F02) & 0xF0 is already 0x10; else (0x7F02) = (0x7F02)&0x0F | 0x10, Queue2C00 record
;   {0x98,0x00,0x10,0xF0}, `ldirw` 0x160 words 0x7620 -> 0x7000 (save), T_ParamImage_SnapshotCombination_Entry, 0x7300 -> 0x7620 (load), T_ParamImage_QueueDiffCombination,
;   T_Queue2C00_DrainPassB.  0x10 is the nibble PanelState_Init maps to mode 2, whose screen draws "C0MBINATI0N M0DE".
;   Published T_Mode_SwitchToCombination (2 refs) and called by ModeEnter_Combination.
Mode_SwitchToCombination:
	ld a, (0x7f02:16)                                   ; F90C21  c1 02 7f 21
	and A,0xf0                                           ; F90C25  c9 cc f0
	cp A,0x10                                            ; F90C28  c9 cf 10
	jr z, .LF90C71                                           ; F90C2B  66 44
	and	(0x7f02:16), 0x0f                            ; F90C2D  c1 02 7f 3c 0f
	or	(0x7f02:16), 0x10                            ; F90C32  c1 02 7f 3e 10
	ld a, 0x10:opc                                          ; F90C37  21 10
	ld e, 0x98:opc                                          ; F90C39  25 98
	ld d, 0x00:opc                                          ; F90C3B  24 00
	ld w, 0xf0:opc                                          ; F90C3D  20 f0
	call T_Queue2C00_AppendRegs                          ; F90C3F  1d 38 0f f4
	ld XIY,Combination_Current                                    ; F90C43  45 20 76 00 00
	ld XIX,0x00007000                                    ; F90C48  44 00 70 00 00
	ld XBC,0x00000160                                    ; F90C4D  41 60 01 00 00
	ldirw                                                ; F90C52  95 11
	call T_ParamImage_SnapshotCombination_Entry                                        ; F90C54  1d 4c 02 f4
	ld XIY,0x00007300                                    ; F90C58  45 00 73 00 00
	ld XIX,Combination_Current                                    ; F90C5D  44 20 76 00 00
	ld XBC,0x00000160                                    ; F90C62  41 60 01 00 00
	ldirw                                                ; F90C67  95 11
	call T_ParamImage_QueueDiffCombination                                        ; F90C69  1d 48 02 f4
	call T_Queue2C00_DrainPassB                          ; F90C6D  1d 38 00 f4
.LF90C71:
	ret                                                  ; F90C71  0e
; Mode_SwitchToSound -- switch the part block back to sound-mode contents
; Evidence: the mirror of Mode_SwitchToCombination: no-op when (0x7F02) & 0xF0 == 0; else nibble 0x00, Queue2C00
;   record {0x98,0x00,0x00,0xF0}, 0x7620 -> 0x7300 (save), T_ParamImage_SnapshotCombination_Entry, 0x7000 -> 0x7620 (load), T_ParamImage_QueueDiffCombination, pass-B drain.
;   Called by mode 1's Enter, ModeEnter_Sound (`calr` at 0xF90C0B), and published T_Mode_SwitchToSound (4 refs).
Mode_SwitchToSound:
	ld a, (0x7f02:16)                                   ; F90C72  c1 02 7f 21
	and A,0xf0                                           ; F90C76  c9 cc f0
	cp a, 0x00:i3                                          ; F90C79  c9 d8
	jr z, .LF90CC1                                           ; F90C7B  66 44
	and	(0x7f02:16), 0x0f                            ; F90C7D  c1 02 7f 3c 0f
	or	(0x7f02:16), 0x00                            ; F90C82  c1 02 7f 3e 00
	ld a, 0x00:opc                                          ; F90C87  21 00
	ld e, 0x98:opc                                          ; F90C89  25 98
	ld d, 0x00:opc                                          ; F90C8B  24 00
	ld w, 0xf0:opc                                          ; F90C8D  20 f0
	call T_Queue2C00_AppendRegs                          ; F90C8F  1d 38 0f f4
	ld XIY,Combination_Current                                    ; F90C93  45 20 76 00 00
	ld XIX,0x00007300                                    ; F90C98  44 00 73 00 00
	ld XBC,0x00000160                                    ; F90C9D  41 60 01 00 00
	ldirw                                                ; F90CA2  95 11
	call T_ParamImage_SnapshotCombination_Entry                                        ; F90CA4  1d 4c 02 f4
	ld XIY,0x00007000                                    ; F90CA8  45 00 70 00 00
	ld XIX,Combination_Current                                    ; F90CAD  44 20 76 00 00
	ld XBC,0x00000160                                    ; F90CB2  41 60 01 00 00
	ldirw                                                ; F90CB7  95 11
	call T_ParamImage_QueueDiffCombination                                        ; F90CB9  1d 48 02 f4
	call T_Queue2C00_DrainPassB                          ; F90CBD  1d 38 00 f4
.LF90CC1:
	ret                                                  ; F90CC1  0e
; InstallPainter_SoundMode_Entry -- ENTER method of screen 1, a pure wrapper for InstallPainter_SoundMode
; Evidence: PanelScreen_VtableTable_ViewB entry 1 (SCREEN ID 0x01) -> T_InstallPainter_SoundMode_Entry `jp 0xF90CC2`; the body is `calr
;   InstallPainter_SoundMode / ret`.
InstallPainter_SoundMode_Entry:
	calr InstallPainter_SoundMode                                            ; F90CC2  1e 93 00
	ret                                                  ; F90CC5  0e
; ScreenLeave_SoundMode -- LEAVE method of screen 1 (SOUND MODE): give the dial back to value editing
; Evidence: T_InstallPainter_SoundMode_Entry+4 = T_ScreenLeave_SoundMode `jp 0xF90CC6`; body `calr PanelDial_UnbindFromButtons / ret`.
ScreenLeave_SoundMode:
	calr PanelDial_UnbindFromButtons                                          ; F90CC6  1e 17 05
	ret                                                  ; F90CC9  0e
; ScreenButton_SoundMode -- BUTTON method of screen 1 (SOUND MODE): dispatch the code through its 32-entry table
; Evidence: T_ScreenButton_SoundMode `jp 0xF90CCA`; `ld XIX,DisplayListPtrs_F90CD8 / call T_PanelButton_CallTableEntry` (PanelButton_CallTableEntry), as
;   that table's header already records.
ScreenButton_SoundMode:
	ld XIX,DisplayListPtrs_F90CD8                        ; F90CCA  44 d8 0c f9 00
	call T_PanelButton_CallTableEntry                                        ; F90CCF  1d 08 1b f4
	ret                                                  ; F90CD3  0e
sub_F90CD4:
	calr sub_F914AE                                          ; F90CD4  1e d7 07
	ret                                                  ; F90CD7  0e
; ---------------------------------------------------------------------
; DisplayListPtrs_F90CD8 -- 32 LE32 pointers
; Read by: ONE site, 0xF90CCA `ld XIX,0x00F90CD8 / call T_PanelButton_CallTableEntry`.
; ENTRY COUNT 32 comes from the CALLEE'S bound, the same way the seven
;          tables of the 0xF92C62 module get theirs: T_PanelButton_CallTableEntry resolves to
;          prom_a 0xF8BDC5, whose first instruction is
;          `cp HL,0x001F / jr ugt` -- index 0x1F is the last one it lets
;          through.  The shape run measured by notes/prom_a_ptr_tables.py
;          agrees: 32 entries, 0 nulls.
; Selector: the panel BUTTON CODE.  ScreenButton_SoundMode (0xF90CCA) is the +8
;          BUTTON method of PanelScreen_VtableTable entry 0x21 (prom_b
;          slot 0xF41528); PanelButton_Route calls it with the code in HL
;          and at (XIZ+8), and it indexes this table with it:
;          `ld XIX,<this> / call T_PanelButton_CallTableEntry`, and T_PanelButton_CallTableEntry = 0xF8BDC5 calls
;          (this + 4*L) after `cp HL,0x001F`.
;          Dispatch_FF3D39's CONTROL LEGEND names each code.
;          (notes/proma-2026-09-25/gen_button_selectors.py, B1-B3)
; ★ 2026-09-25 (lane proma): the selector was recorded as open here.
; ---------------------------------------------------------------------

DisplayListPtrs_F90CD8:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	SoftKeyCol1_Oct
	on_key	KEY_SoftKeyCol2,	SoftKeyCol2_LvlVol
	on_key	KEY_SoftKeyCol3,	SoftKeyCol3_Pan
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_Eff1
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_Eff2
	on_key	KEY_SoftKeyCol6,	SoftKeyCol6_Rev
	on_key	KEY_SoftKeyCol7,	SoftKeyCol7_Int
	on_key	KEY_SoftKeyCol8,	SoftKeyCol8_Midi
	on_key	KEY_LcdRow1,		LcdKeyRow1_SoundMode
	on_key	KEY_LcdRow2,		DisplayListPtrs_F90CD8_Nop9
	on_key	KEY_LcdRow3,		DisplayListPtrs_F90CD8_Nop10
	on_key	KEY_LcdRow4,		LcdKeyRow4_SoundModeOrC0mbinati0nM0de
	on_key	KEY_LcdRow5,		DisplayListPtrs_F90CD8_Nop12
	on_key	KEY_MinusPlus,		DisplayListPtrs_F90CD8_Nop13
	on_key	KEY_Code0E,		DisplayListPtrs_F90CD8_Nop14
	on_key	KEY_Exit,		ExitKey_SoundMode
	on_key	KEY_Page,		DisplayListPtrs_F90CD8_Nop16
	on_key	KEY_SoftKeyCol1Alt,	SoftKeyCol1_Oct_AltCode
	on_key	KEY_SoftKeyCol2Alt,	SoftKeyCol2_LvlVol_AltCode
	on_key	KEY_SoftKeyCol3Alt,	SoftKeyCol3_Pan_AltCode
	on_key	KEY_SoftKeyCol4Alt,	SoftKeyCol4_Eff1_AltCode
	on_key	KEY_SoftKeyCol5Alt,	SoftKeyCol5_Eff2_AltCode
	on_key	KEY_SoftKeyCol6Alt,	SoftKeyCol6_Rev_AltCode
	on_key	KEY_SoftKeyCol7Alt,	SoftKeyCol7_Int_AltCode
	on_key	KEY_SoftKeyCol8Alt,	SoftKeyCol8_Midi_AltCode
	on_key	KEY_PageAlt,		DisplayListPtrs_F90CD8_Nop25
	on_key	KEY_Code1A,		DisplayListPtrs_F90CD8_Nop26
	on_key	KEY_NumberPad,		DisplayListPtrs_F90CD8_Nop27
	on_key	KEY_Code1C,		DisplayListPtrs_F90CD8_Nop28
	on_key	KEY_Code1D,		DisplayListPtrs_F90CD8_Nop29
	on_key	KEY_Compare,		DisplayListPtrs_F90CD8_Nop30
	on_key	KEY_Code1F,		DisplayListPtrs_F90CD8_Nop31
	keymap_end
; InstallPainter_SoundMode -- set up screen 1 and install its painters (Paint_SoundMode, Paint_SoundModeFields)
; Evidence: when (0x207C) != (0x207D): T_CallbackQueue_ResetAndRestartTask2, (0x2666) = (0x266A) = 0xFFFFFFFF,
;   (0x209B) = 0x0181, or (0x2075),0x01.  Then T_CallbackQueue_Post of Paint_SoundMode (skipped while (0x2095) bit 4
;   is set) and of Paint_SoundModeFields, each followed by T_Kernel_SemaSignal(1).  Screen: its background lists
;   DL_F27C00-DL_F28064 (v1) / DL_F2808C-Paint_SoundMode_DL (v2) draw "SOUND MODE".
InstallPainter_SoundMode:
	ld a, (UI_ScreenId:16)                                   ; F90D58  c1 7c 20 21
	cp (UI_ScreenId_Previous:16), a                                    ; F90D5C  c1 7d 20 f9
	jr z, .LF90DAB                                       ; F90D60  66 49
	call T_CallbackQueue_ResetAndRestartTask2            ; F90D62  1d 80 2e f4
	and	(UI_ScreenFlags:16), 0xef                            ; F90D66  c1 95 20 3c ef
	ld XWA,0xffffffff                                    ; F90D6B  40 ff ff ff ff
	ld (0x2666:16), xwa                                 ; F90D70  f1 66 26 60
	ld (0x266a:16), xwa                                 ; F90D74  f1 6a 26 60
	ldw (PanelDial_DownButton:16), 0x0181                              ; F90D78  f1 9b 20 02 81 01
	or	(UI_RequestBits:16), 0x01                            ; F90D7E  c1 75 20 3e 01
	and	(0x2688:16), 0xfc                            ; F90D83  c1 88 26 3c fc
	bit	0, (0x20a9:16)                               ; F90D88  f1 a9 20 c8
	jr z, .LF90DA0                                       ; F90D8C  66 12
	ldw (UI_Request:16), 0x40ab                              ; F90D8E  f1 70 20 02 ab 40
	ld (UI_StatusCode:16), 0x24                                 ; F90D94  f1 80 28 00 24
	and	(0x20a9:16), 0xfe                            ; F90D99  c1 a9 20 3c fe
	jr .LF90DAB                                          ; F90D9E  68 0b
.LF90DA0:
	cp	(UI_ScreenId_Previous:16), 0xa3                            ; F90DA0  c1 7d 20 3f a3
	jr z, .LF90DAB                                       ; F90DA5  66 04
	call T_Drawbar_EnterScreenIfMarked                                        ; F90DA7  1d 68 2e f4
.LF90DAB:
	bit	4, (UI_ScreenFlags:16)                               ; F90DAB  f1 95 20 cc
	jr nz, .LF90DC8                                      ; F90DAF  6e 17
	and	(0x2688:16), 0xfc                            ; F90DB1  c1 88 26 3c fc
	ld XWA,Paint_SoundMode                                    ; F90DB6  40 db 0d f9 00
	push XWA                                             ; F90DBB  38
	call T_CallbackQueue_Post                            ; F90DBC  1d 84 2e f4
	inc 4,XSP                                            ; F90DC0  ef 64
	ld a, 0x01:opc                                          ; F90DC2  21 01
	call T_Kernel_SemaSignal                             ; F90DC4  1d 88 2d f4
.LF90DC8:
	ld XWA,Paint_SoundModeFields                                    ; F90DC8  40 4b 0e f9 00
	push XWA                                             ; F90DCD  38
	call T_CallbackQueue_Post                            ; F90DCE  1d 84 2e f4
	inc 4,XSP                                            ; F90DD2  ef 64
	ld a, 0x01:opc                                          ; F90DD4  21 01
	call T_Kernel_SemaSignal                             ; F90DD6  1d 88 2d f4
	ret                                                  ; F90DDA  0e
; Paint_SoundMode -- paints the screen whose own text reads "SOUND MODE" (soft-key labels "OCT" .. "MIDI")
; Evidence: T_DisplayList_Run on DL_F27C00-DL_F28064 + DL_F28064-DL_F2808C (v1) or DL_F2808C-Paint_SoundMode_DL +
;   Paint_SoundMode_DL-DL_Drawbar (v2, (0xC4)=2); both list sets carry `.ascii "SOUND MODE"` and the eight soft-key labels at
;   y=0xD4, x=10..288.  Then marks all fields dirty ((0x2676)=0xFF, (0x2677)|=7), requests LED ids 0x0044 and calls
;   ModeScreen_DrawGmModeGlyph. Posted by InstallPainter_SoundMode.
Paint_SoundMode:   ; entry: named by 1 `ld` operand, first at 0xF90DB6
	xor C,C                                              ; F90DDB  cb d3
	ld a, 0x0c:opc                                          ; F90DDD  21 0c
	swi 7                                                ; F90DDF  ff
	ld a, 0x10:opc                                          ; F90DE0  21 10
	swi 7                                                ; F90DE2  ff
	cp	(Variant_Flag:8), 0x02                               ; F90DE3  c0 c4 3f 02
	jr z, .LF90E11                                       ; F90DE7  66 28
	ld (LCD_CurrentLayer:16), 0x00                                 ; F90DE9  f1 40 25 00 00
	ld XIY,DL_F27C00                                     ; F90DEE  45 00 7c f2 00
	ld XIX,DL_F28064                                     ; F90DF3  44 64 80 f2 00
	call T_DisplayList_Run                               ; F90DF8  1d f0 17 f4
	ld (LCD_CurrentLayer:16), 0x02                                 ; F90DFC  f1 40 25 00 02
	ld XIY,DL_F28064                                     ; F90E01  45 64 80 f2 00
	ld XIX,DL_F2808C                                     ; F90E06  44 8c 80 f2 00
	call T_DisplayList_Run                               ; F90E0B  1d f0 17 f4
	jr .LF90E37                                          ; F90E0F  68 26
.LF90E11:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F90E11  f1 40 25 00 00
	ld XIY,DL_F2808C                                     ; F90E16  45 8c 80 f2 00
	ld XIX,Paint_SoundMode_DL                                     ; F90E1B  44 3b 83 f2 00
	call T_DisplayList_Run                               ; F90E20  1d f0 17 f4
	ld (LCD_CurrentLayer:16), 0x02                                 ; F90E24  f1 40 25 00 02
	ld XIY,Paint_SoundMode_DL                                     ; F90E29  45 3b 83 f2 00
	ld XIX,DL_Drawbar                                    ; F90E2E  44 4f 83 f2 00
	call T_DisplayList_Run                               ; F90E33  1d f0 17 f4
.LF90E37:
	or	(ModeScreen_DirtyFields:16), 0xff                            ; F90E37  c1 76 26 3e ff
	or	(ModeScreen_DirtyFields2:16), 0x07                            ; F90E3C  c1 77 26 3e 07
	orw	(0x2116:16), 0x0044                  ; F90E41  d1 16 21 3e 44 00
	calr ModeScreen_DrawGmModeGlyph                                      ; F90E47  1e 6c 03
	ret                                                  ; F90E4A  0e
; Paint_SoundModeFields -- redraw SOUND MODE's value fields: sound number and the dirty soft-key columns
; Evidence: `calr Paint_Drawbar`; XIY = PartRecord_GetPtr record, A = (+0x1B)<<3 | (+0x1C), +1 -> T_Value_ToAsciiDigits3 ->
;   DL_F29765; then (0x2676) bits: 0 (0x0710)+0x1E, 1 (0x0711), 2 +5, 3 +7, 4/5 +0x0D, 7 +6 on/off, 6 (0x78B2) as
;   ((v-0x1C)/12) -- the OCT..MIDI columns; ModeScreen_PaintDirtyFields2 for (0x2677); clears both masks.  Posted by
;   InstallPainter_SoundMode.
Paint_SoundModeFields:   ; entry: named by 1 `ld` operand, first at 0xF90DC8
	calr Paint_Drawbar                                      ; F90E4B  1e f1 02
	ld (LCD_CurrentLayer:16), 0x00                                 ; F90E4E  f1 40 25 00 00
	calr PartRecord_GetPtr                                          ; F90E53  1e e3 36
	ld A,(XIY)                                           ; F90E56  85 21
	ld W,(XIY+0x01)                                      ; F90E58  8d 01 20
	and W,0x7f                                           ; F90E5B  c8 cc 7f
	ld b, (UI_PartIndex:16)                                   ; F90E5E  c1 50 22 22
	call T_SoundName_Lookup                                        ; F90E62  1d 10 10 f4
	ldw bc, 0x10                                         ; F90E66  31 10 00
	xor HL,HL                                            ; F90E69  db d3
	ldw ix, 0x09b4                                       ; F90E6B  34 b4 09
	ld a, 0x21:opc                                          ; F90E6E  21 21
	swi 7                                                ; F90E70  ff
	calr PartRecord_GetSecondHalfPtr                                          ; F90E71  1e d9 36
	ld A,(XIY+0x1d)                                      ; F90E74  8d 1d 21
	and A,0xff                                           ; F90E77  c9 cc ff
	ld (UI_DrawScratch:16), a                                   ; F90E7A  f1 40 26 41
	ld A,(XIY+0x1b)                                      ; F90E7E  8d 1b 21
	and A,0xff                                           ; F90E81  c9 cc ff
	sll a, 0x03                                          ; F90E84  c9 ee 03
	ld W,(XIY+0x1c)                                      ; F90E87  8d 1c 20
	and W,0xff                                           ; F90E8A  c8 cc ff
	or A,W                                               ; F90E8D  c8 e1
	inc 1,A                                              ; F90E8F  c9 61
	extz WA                                              ; F90E91  d8 12
	call T_Value_ToAsciiDigits3                          ; F90E93  1d 00 1b f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; F90E97  f1 40 25 00 00
	ld XIY,DL_F29765                                     ; F90E9C  45 65 97 f2 00
	ld XIX,Paint_C0mbinati0nM0dePage2Sound1_DL                                     ; F90EA1  44 83 97 f2 00
	call T_DisplayListB_Run                              ; F90EA6  1d f4 17 f4
	calr PartRecord_GetPtr                                          ; F90EAA  1e 8c 36
	bit	0, (ModeScreen_DirtyFields:16)                               ; F90EAD  f1 76 26 c8
	jr z, .LF90EC9                                       ; F90EB1  66 16
	push XIY                                             ; F90EB3  3d
	ld a, (0x0710:16)                                   ; F90EB4  c1 10 07 21
	add A,0x1e                                           ; F90EB8  c9 c8 1e
	ld (UI_DrawScratch:16), a                                   ; F90EBB  f1 40 26 41
	ld XIY,0x00f2845b                                    ; F90EBF  45 5b 84 f2 00
	call T_DLB_Handler_DecimalSigned2Words               ; F90EC4  1d 14 18 f4
	pop XIY                                              ; F90EC8  5d
.LF90EC9:
	bit	1, (ModeScreen_DirtyFields:16)                               ; F90EC9  f1 76 26 c9
	jr z, .LF90EE2                                       ; F90ECD  66 13
	push XIY                                             ; F90ECF  3d
	ld a, (0x0711:16)                                   ; F90ED0  c1 11 07 21
	ld (UI_DrawScratch+1:16), a                                   ; F90ED4  f1 41 26 41
	ld XIY,0x00f28468                                    ; F90ED8  45 68 84 f2 00
; (sub_F90EDD removed 2026-10-04: no code names it and the line above falls through into it -- part of Paint_SoundModeFields;
;  notes/prom_a_stray_label_removal.py)
	call T_DLB_Handler_StringTable2                      ; F90EDD  1d fc 17 f4
	pop XIY                                              ; F90EE1  5d
.LF90EE2:
	bit	2, (ModeScreen_DirtyFields:16)                               ; F90EE2  f1 76 26 ca
	jr z, .LF90EFA                                       ; F90EE6  66 12
	push XIY                                             ; F90EE8  3d
	ld A,(XIY+0x05)                                      ; F90EE9  8d 05 21
	ld (UI_DrawScratch+2:16), a                                   ; F90EEC  f1 42 26 41
	ld XIY,0x00f28479                                    ; F90EF0  45 79 84 f2 00
	call T_DLB_Handler_Decimal2Words                                        ; F90EF5  1d 0c 18 f4
	pop XIY                                              ; F90EF9  5d
.LF90EFA:
	bit	3, (ModeScreen_DirtyFields:16)                               ; F90EFA  f1 76 26 cb
	jr Z,.LF90F12                                        ; F90EFE  66 12
	push XIY                                             ; F90F00  3d
	ld A,(XIY+0x07)                                      ; F90F01  8d 07 21
	ld (UI_DrawScratch+3:16), a                                   ; F90F04  f1 43 26 41
	ld XIY,0x00f28485                                    ; F90F08  45 85 84 f2 00
	call T_DLB_Handler_Decimal2Words                                        ; F90F0D  1d 0c 18 f4
	pop XIY                                              ; F90F11  5d
.LF90F12:
	bit	4, (ModeScreen_DirtyFields:16)                               ; F90F12  f1 76 26 cc
	jr z, .LF90F2A                                       ; F90F16  66 12
	push XIY                                             ; F90F18  3d
	ld A,(XIY+0x0d)                                      ; F90F19  8d 0d 21
	ld (UI_DrawScratch+4:16), a                                   ; F90F1C  f1 44 26 41
	ld XIY,DL_F286CB                                     ; F90F20  45 cb 86 f2 00
	call T_DLB_Handler_StringTable2                      ; F90F25  1d fc 17 f4
	pop XIY                                              ; F90F29  5d
.LF90F2A:
	bit	5, (ModeScreen_DirtyFields:16)                               ; F90F2A  f1 76 26 cd
	jr z, .LF90F42                                       ; F90F2E  66 12
	push XIY                                             ; F90F30  3d
	ld A,(XIY+0x0d)                                      ; F90F31  8d 0d 21
	ld (UI_DrawScratch+5:16), a                                   ; F90F34  f1 45 26 41
	ld XIY,0x00f28491                                    ; F90F38  45 91 84 f2 00
	call T_DLB_Handler_StringTable2                      ; F90F3D  1d fc 17 f4
	pop XIY                                              ; F90F41  5d
.LF90F42:
	bit	7, (ModeScreen_DirtyFields:16)                               ; F90F42  f1 76 26 cf
	jr z, .LF90F63                                       ; F90F46  66 1b
	push XIY                                             ; F90F48  3d
	ld A,(XIY+0x06)                                      ; F90F49  8d 06 21
	and A,0x7f                                           ; F90F4C  c9 cc 7f
	cp a, 0x00:i3                                          ; F90F4F  c9 d8
	jr z, .LF90F55                                       ; F90F51  66 02
	ld a, 0x01:opc                                          ; F90F53  21 01
.LF90F55:
	ld (UI_DrawScratch+6:16), a                                   ; F90F55  f1 46 26 41
	ld XIY,DL_F286E2                                     ; F90F59  45 e2 86 f2 00
	call T_DLB_Handler_StringTable2                      ; F90F5E  1d fc 17 f4
	pop XIY                                              ; F90F62  5d
.LF90F63:
	bit	6, (ModeScreen_DirtyFields:16)                               ; F90F63  f1 76 26 ce
	jr z, .LF90F8C                                       ; F90F67  66 23
	push XIY                                             ; F90F69  3d
	ld XIY,0x000078b2                                    ; F90F6A  45 b2 78 00 00
	ld	a, (xiy+0:8)                                 ; F90F6F  8d 00 21
	sub A,0x1c                                           ; F90F72  c9 ca 1c
	extz WA                                              ; F90F75  d8 12
	cp wa, 0x00:i3                                         ; F90F77  d8 d8
	jr z, .LF90F7E                                       ; F90F79  66 03
	div A,0x0c                                           ; F90F7B  c9 0a 0c
.LF90F7E:
	ld (UI_DrawScratch+7:16), a                                   ; F90F7E  f1 47 26 41
	ld XIY,0x00f287d1                                    ; F90F82  45 d1 87 f2 00
	call T_DLB_Handler_StringTable2                      ; F90F87  1d fc 17 f4
	pop XIY                                              ; F90F8B  5d
.LF90F8C:
	calr ModeScreen_PaintDirtyFields2                                      ; F90F8C  1e 10 00
	ld (ModeScreen_DirtyFields:16), 0x00                                 ; F90F8F  f1 76 26 00 00
	ld (ModeScreen_DirtyFields2:16), 0x00                                 ; F90F94  f1 77 26 00 00
	ld c, 0x07:opc                                          ; F90F99  23 07
	ld a, 0x0c:opc                                          ; F90F9B  21 0c
	swi 7                                                ; F90F9D  ff
	ret                                                  ; F90F9E  0e
; ModeScreen_PaintDirtyFields2 -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 13 time(s) in the 119
; instructions to its first `ret`:
;     site 0xF90FC5  interpreter B  list 0xF286F9-0xF28725
;     site 0xF90FE6  interpreter A  list 0xF28802-0xF2880C
;     site 0xF91009  interpreter B  list 0xF28820-0xF2882B
;     site 0xF9102F  interpreter B  list 0xF288D1-0xF288E0
;     site 0xF91045  interpreter B  list 0xF288E0-0xF288EF
;     site 0xF91067  interpreter A  list 0xF2880C-0xF28816
;     site 0xF9108A  interpreter B  list 0xF2885B-0xF28866
;     site 0xF910B0  interpreter B  list 0xF288EF-0xF288FE
;     site 0xF910C6  interpreter B  list 0xF288FE-0xF2890D
;     site 0xF910DB  interpreter A  list 0xF28816-0xF28820
;     site 0xF910FE  interpreter B  list 0xF28896-0xF288A1
;     site 0xF91124  interpreter B  list 0xF2890D-0xF2891C
;     site 0xF9113A  interpreter B  list 0xF2891C-0xF2892B
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; ModeScreen_PaintDirtyFields2: For each set bit 0/1/2 of ModeScreen_DirtyFields2 redraws the selected part's second-
;   half record field +0x18 / +0x19 / +0x1A (value plus label pairs, layer 1 lists on variant 1). The shared tail of
;   the SOUND MODE and COMBINATION MODE page-1 field painters, which clear both dirty masks after it. Basis: callers +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave3_h.json)
ModeScreen_PaintDirtyFields2:
	bit	0, (ModeScreen_DirtyFields2:16)                               ; F90F9F  f1 77 26 c8
	jr z, .LF90FCB                                       ; F90FA3  66 26
	call PartRecord_GetSecondHalfPtr                                        ; F90FA5  1d 4d 45 f9
	ld A,(XIY+0x18)                                      ; F90FA9  8d 18 21
	ld (UI_DrawScratch:16), a                                   ; F90FAC  f1 40 26 41
	cp	(Variant_Flag:8), 0x02                               ; F90FB0  c0 c4 3f 02
	jr z, .LF90FCB                                       ; F90FB4  66 15
	ld (LCD_CurrentLayer:16), 0x01                                 ; F90FB6  f1 40 25 00 01
	ld XIY,ModeScreen_PaintDirtyFields2_DL1                                     ; F90FBB  45 f9 86 f2 00
	ld XIX,DLTable_F28725                                ; F90FC0  44 25 87 f2 00
	call T_DisplayListB_Run                              ; F90FC5  1d f4 17 f4
	jr .LF90FCB                                          ; F90FC9  68 00
.LF90FCB:
	bit	1, (ModeScreen_DirtyFields2:16)                               ; F90FCB  f1 77 26 c9
	jr z, .LF9104B                                       ; F90FCF  66 7a
	cp	(Variant_Flag:8), 0x02                               ; F90FD1  c0 c4 3f 02
	jr z, .LF9104B                                       ; F90FD5  66 74
	ld (LCD_CurrentLayer:16), 0x01                                 ; F90FD7  f1 40 25 00 01
	ld XIY,ModeScreen_PaintDirtyFields2_DL2                                     ; F90FDC  45 02 88 f2 00
	ld XIX,ModeScreen_PaintDirtyFields2_DL6                                     ; F90FE1  44 0c 88 f2 00
	call T_DisplayList_Run                               ; F90FE6  1d f0 17 f4
	call PartRecord_GetSecondHalfPtr                                        ; F90FEA  1d 4d 45 f9
	ld A,(XIY+0x19)                                      ; F90FEE  8d 19 21
	calr BitMask_LowestSetBitOrdinal_SaveC                                          ; F90FF1  1e 84 35
	cp a, 0x00:i3                                          ; F90FF4  c9 d8
	jr z, .LF90FFA                                       ; F90FF6  66 02
	dec 1,A                                              ; F90FF8  c9 69
.LF90FFA:
	ld (UI_DrawScratch:16), a                                   ; F90FFA  f1 40 26 41
	push XIY                                             ; F90FFE  3d
	ld XIY,ModeScreen_PaintDirtyFields2_DL3                                     ; F90FFF  45 20 88 f2 00
	ld XIX,DLBoxes_F2882B                                   ; F91004  44 2b 88 f2 00
	call T_DisplayListB_Run                              ; F91009  1d f4 17 f4
	pop XIY                                              ; F9100D  5d
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9100E  f1 40 25 00 00
	ld w, (UI_PartIndex:16)                                   ; F91013  c1 50 22 20
	ld A,(XIY+0x19)                                      ; F91017  8d 19 21
	call T_CreatorSelect_ReadSlotLabelIds                                        ; F9101A  1d 38 10 f4
	push XIY                                             ; F9101E  3d
	ld A,(XIY)                                           ; F9101F  85 21
	call T_UiText_CopyLabel13_To_22F0                                        ; F91021  1d 30 33 f4
	ld XIY,ModeScreen_PaintDirtyFields2_DL4                                     ; F91025  45 d1 88 f2 00
	ld XIX,ModeScreen_PaintDirtyFields2_DL5                                     ; F9102A  44 e0 88 f2 00
	call T_DisplayListB_Run                              ; F9102F  1d f4 17 f4
	pop XIY                                              ; F91033  5d
	ld A,(XIY+0x01)                                      ; F91034  8d 01 21
	call T_UiText_CopyLabel13_To_22F0                                        ; F91037  1d 30 33 f4
	ld XIY,ModeScreen_PaintDirtyFields2_DL5                                     ; F9103B  45 e0 88 f2 00
	ld XIX,ModeScreen_PaintDirtyFields2_DL8                                     ; F91040  44 ef 88 f2 00
	call T_DisplayListB_Run                              ; F91045  1d f4 17 f4
	jr .LF9104B                                          ; F91049  68 00
.LF9104B:
	bit	2, (ModeScreen_DirtyFields2:16)                               ; F9104B  f1 77 26 ca
	jrl z, .LF9113E                                      ; F9104F  76 ec 00
	cp	(Variant_Flag:8), 0x02                               ; F91052  c0 c4 3f 02
	jr z, .LF910CC                                       ; F91056  66 74
	ld (LCD_CurrentLayer:16), 0x01                                 ; F91058  f1 40 25 00 01
	ld XIY,ModeScreen_PaintDirtyFields2_DL6                                     ; F9105D  45 0c 88 f2 00
	ld XIX,ModeScreen_PaintDirtyFields2_DL10                                     ; F91062  44 16 88 f2 00
	call T_DisplayList_Run                               ; F91067  1d f0 17 f4
	call PartRecord_GetSecondHalfPtr                                        ; F9106B  1d 4d 45 f9
	ld A,(XIY+0x1a)                                      ; F9106F  8d 1a 21
	calr BitMask_LowestSetBitOrdinal_SaveC                                          ; F91072  1e 03 35
	cp a, 0x00:i3                                          ; F91075  c9 d8
	jr z, .LF9107B                                       ; F91077  66 02
	dec 1,A                                              ; F91079  c9 69
.LF9107B:
	ld (UI_DrawScratch:16), a                                   ; F9107B  f1 40 26 41
	push XIY                                             ; F9107F  3d
	ld XIY,ModeScreen_PaintDirtyFields2_DL7                                     ; F91080  45 5b 88 f2 00
	ld XIX,Data_F28866                                   ; F91085  44 66 88 f2 00
	call T_DisplayListB_Run                              ; F9108A  1d f4 17 f4
	pop XIY                                              ; F9108E  5d
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9108F  f1 40 25 00 00
	ld w, (UI_PartIndex:16)                                   ; F91094  c1 50 22 20
	ld A,(XIY+0x1a)                                      ; F91098  8d 1a 21
	call T_CreatorSelect_ReadSlotLabelIds                                        ; F9109B  1d 38 10 f4
	push XIY                                             ; F9109F  3d
	ld A,(XIY)                                           ; F910A0  85 21
	call T_UiText_CopyLabel13_To_22F0                                        ; F910A2  1d 30 33 f4
	ld XIY,ModeScreen_PaintDirtyFields2_DL8                                     ; F910A6  45 ef 88 f2 00
	ld XIX,ModeScreen_PaintDirtyFields2_DL9                                     ; F910AB  44 fe 88 f2 00
	call T_DisplayListB_Run                              ; F910B0  1d f4 17 f4
	pop XIY                                              ; F910B4  5d
	ld A,(XIY+0x01)                                      ; F910B5  8d 01 21
	call T_UiText_CopyLabel13_To_22F0                                        ; F910B8  1d 30 33 f4
	ld XIY,ModeScreen_PaintDirtyFields2_DL9                                     ; F910BC  45 fe 88 f2 00
	ld XIX,ModeScreen_PaintDirtyFields2_DL12                                     ; F910C1  44 0d 89 f2 00
	call T_DisplayListB_Run                              ; F910C6  1d f4 17 f4
	jr .LF9113E                                          ; F910CA  68 72
.LF910CC:
	ld (LCD_CurrentLayer:16), 0x01                                 ; F910CC  f1 40 25 00 01
	ld XIY,ModeScreen_PaintDirtyFields2_DL10                                     ; F910D1  45 16 88 f2 00
	ld XIX,ModeScreen_PaintDirtyFields2_DL3                                     ; F910D6  44 20 88 f2 00
	call T_DisplayList_Run                               ; F910DB  1d f0 17 f4
	call PartRecord_GetSecondHalfPtr                                        ; F910DF  1d 4d 45 f9
	ld A,(XIY+0x1a)                                      ; F910E3  8d 1a 21
	calr BitMask_LowestSetBitOrdinal_SaveC                                          ; F910E6  1e 8f 34
	cp a, 0x00:i3                                          ; F910E9  c9 d8
	jr z, .LF910EF                                       ; F910EB  66 02
	dec 1,A                                              ; F910ED  c9 69
.LF910EF:
	ld (UI_DrawScratch:16), a                                   ; F910EF  f1 40 26 41
	push XIY                                             ; F910F3  3d
	ld XIY,ModeScreen_PaintDirtyFields2_DL11                                     ; F910F4  45 96 88 f2 00
	ld XIX,Data_F288A1                                   ; F910F9  44 a1 88 f2 00
	call T_DisplayListB_Run                              ; F910FE  1d f4 17 f4
	pop XIY                                              ; F91102  5d
	ld (LCD_CurrentLayer:16), 0x00                                 ; F91103  f1 40 25 00 00
	ld w, (UI_PartIndex:16)                                   ; F91108  c1 50 22 20
	ld A,(XIY+0x1a)                                      ; F9110C  8d 1a 21
	call T_CreatorSelect_ReadSlotLabelIds                                        ; F9110F  1d 38 10 f4
	push XIY                                             ; F91113  3d
	ld A,(XIY)                                           ; F91114  85 21
	call T_UiText_CopyLabel13_To_22F0                                        ; F91116  1d 30 33 f4
	ld XIY,ModeScreen_PaintDirtyFields2_DL12                                     ; F9111A  45 0d 89 f2 00
	ld XIX,ModeScreen_PaintDirtyFields2_DL13                                     ; F9111F  44 1c 89 f2 00
	call T_DisplayListB_Run                              ; F91124  1d f4 17 f4
	pop XIY                                              ; F91128  5d
	ld A,(XIY+0x01)                                      ; F91129  8d 01 21
	call T_UiText_CopyLabel13_To_22F0                                        ; F9112C  1d 30 33 f4
	ld XIY,ModeScreen_PaintDirtyFields2_DL13                                     ; F91130  45 1c 89 f2 00
	ld XIX,ModeScreen_DrawGmModeGlyph_DL2                                     ; F91135  44 2b 89 f2 00
	call T_DisplayListB_Run                              ; F9113A  1d f4 17 f4
.LF9113E:
	ret                                                  ; F9113E  0e
; Paint_Drawbar -- paints the screen whose own text reads "DRAWBAR"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 4 time(s); XIY = list start, XIX = list end.  1 of those 4 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xF91166  interpreter A  list 0xF2834F  DL_Drawbar
;        text: "DRAWBAR"
; Evidence: the list address is the `ld XIY,0x00F2834F` IMMEDIATE at the
;          instruction two before the cited `call`, and the text quoted
;          above is the `.ascii` the interpreter draws verbatim.  Every
;          alphabetic morpheme of this name occurs in that text; the
;          check is notes/prom_a_understanding_round5.py --morphemes.
;          `Paint_` is a structural verb, not ROM text.
;          ⚠ ROUND 5: where the label reads `InstallPainter_`, the body contains
;          ZERO display-list calls -- it INSTALLS the callback that paints this
;          screen, through `call 0xF42E84`. The screen association is real one hop
;          away; the earlier `Paint_` verb claimed the body did the drawing and it
;          does not. Any display-list COUNT in a header above such a label is the
;          installed callback's, not this routine's.
; Unknown: whether this routine also handles input for the screen, and
;          whether any other routine paints it.  Neither was searched.
; ---------------------------------------------------------------------
Paint_Drawbar:
	call T_Drawbar_WaitReloadMark                                        ; F9113F  1d 6c 2e f4
	cp a, 0x01:i3                                          ; F91143  c9 d9
	jr nz, .LF9117F                                      ; F91145  6e 38
	bit	1, (0x2688:16)                               ; F91147  f1 88 26 c9
	jr nz, .LF911B5                                      ; F9114B  6e 68
	and	(0x2688:16), 0xfc                            ; F9114D  c1 88 26 3c fc
	or	(0x2688:16), 0x02                            ; F91152  c1 88 26 3e 02
	ld (LCD_CurrentLayer:16), 0x01                                 ; F91157  f1 40 25 00 01
	ld XIY,DL_Drawbar                                    ; F9115C  45 4f 83 f2 00
	ld XIX,Paint_Drawbar_DL1                                     ; F91161  44 73 83 f2 00
	call T_DisplayList_Run                               ; F91166  1d f0 17 f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9116A  f1 40 25 00 00
	ld XIY,Paint_Drawbar_DL1                                     ; F9116F  45 73 83 f2 00
	ld XIX,Paint_Drawbar_DL2                                     ; F91174  44 7d 83 f2 00
	call T_DisplayList_Run                               ; F91179  1d f0 17 f4
	jr .LF911B5                                          ; F9117D  68 36
.LF9117F:
	bit	0, (0x2688:16)                               ; F9117F  f1 88 26 c8
	jr nz, .LF911B5                                      ; F91183  6e 30
	and	(0x2688:16), 0xfc                            ; F91185  c1 88 26 3c fc
	or	(0x2688:16), 0x01                            ; F9118A  c1 88 26 3e 01
	ld (LCD_CurrentLayer:16), 0x01                                 ; F9118F  f1 40 25 00 01
	ld XIY,Paint_Drawbar_DL1                                     ; F91194  45 73 83 f2 00
	ld XIX,Paint_Drawbar_DL2                                     ; F91199  44 7d 83 f2 00
	call T_DisplayList_Run                               ; F9119E  1d f0 17 f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; F911A2  f1 40 25 00 00
	ld XIY,Paint_Drawbar_DL2                                     ; F911A7  45 7d 83 f2 00
	ld XIX,Data_F283A7                                   ; F911AC  44 a7 83 f2 00
	call T_DisplayList_Run                               ; F911B1  1d f0 17 f4
.LF911B5:
	ret                                                  ; F911B5  0e
; ModeScreen_DrawGmModeGlyph -- a display-list painter whose SCREEN IS NOT ESTABLISHED
;
; Its body reaches the display-list interpreters 2 time(s) in the 11
; instructions to its first `ret`:
;     site 0xF911CB  interpreter A  list 0xF28930-0xF28938
;     site 0xF911DB  interpreter A  list 0xF2892B-0xF28930
; Evidence: the list bounds are the `ld XIY,0x00...` and `ld XIX,0x00...`
;          immediates of the LAST such loads before each cited `call` -- within
;          five instructions above it; --selftest measures every distance;
;          0xF417F0 enters interpreter A and 0xF417F4 interpreter B
;          (notes/FINDINGS-ui-display-list.md).
; Unknown: WHAT SCREEN.  Not one of these lists holds an `.ascii` record,
;          so the rule that named 24 of prom_a's painters -- take the
;          name from the text the list draws -- has nothing to read here.
;          The label stays sub_XXXXXX on purpose; naming it would need the
;          list's opcodes decoded or a caller that says what it is.
; ---------------------------------------------------------------------
; ModeScreen_DrawGmModeGlyph: On layer 0: GM mode ((0x7F4D) bit 2) set -> ModeScreen_DrawGmModeGlyph_DL2, glyph 0x1E at 0x0DB1; clear ->
;   ModeScreen_DrawGmModeGlyph_DL1, the op-0E record over the same 3x24 cell. Called by Paint_SoundMode and Paint_C0mbinati0nM0dePage1.
;   Basis: callers + body (+ the GM-mode bit in two notes). (notes/naming-pilot-2026-10-06/proposals_wave2_e.json)
ModeScreen_DrawGmModeGlyph:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F911B6  f1 40 25 00 00
	bit	2, (0x7f4d:16)                               ; F911BB  f1 4d 7f ca
	jr nz, .LF911D1                                      ; F911BF  6e 10
	ld XIY,ModeScreen_DrawGmModeGlyph_DL1                                     ; F911C1  45 30 89 f2 00
	ld XIX,Paint_C0mbinati0nM0dePage1_DL1                                     ; F911C6  44 38 89 f2 00
	call T_DisplayList_Run                               ; F911CB  1d f0 17 f4
	jr .LF911DF                                          ; F911CF  68 0e
.LF911D1:
	ld XIY,ModeScreen_DrawGmModeGlyph_DL2                                     ; F911D1  45 2b 89 f2 00
	ld XIX,ModeScreen_DrawGmModeGlyph_DL1                                     ; F911D6  44 30 89 f2 00
	call T_DisplayList_Run                               ; F911DB  1d f0 17 f4
.LF911DF:
	ret                                                  ; F911DF  0e
; PanelDial_UnbindFromButtons -- clear (0x2075) bit 0 so the dial edits values again
; Evidence: `and (0x2075),0xfe / ret`.  PanelEvent_Code21_Dial and PanelButton_Route route the dial / -1/+1 as the
;   buttons in (0x209B)/(0x209C) only while that bit is set; the SOUND MODE soft-key handlers set it (`or
;   (0x2075),0x09`). Called by ScreenLeave_SoundMode.
PanelDial_UnbindFromButtons:
	and	(UI_RequestBits:16), 0xfe                            ; F911E0  c1 75 20 3c fe
	ret                                                  ; F911E5  0e
; SoftKeyCol1_Oct -- soft-key column 1 (OCT) handler: step in W, then SoftKeyCol1_Oct_Step
; Evidence: entry [0] of DisplayListPtrs_F90CD8 (SOUND MODE) and of DisplayListPtrs_F914FB (COMBINATION page 1); code
;   0 = SOFT KEY column 1 (FINDINGS-prom_a-panel-control-map.md 1); both screens label column 1 "OCT". Prefix `add
;   W,0x06` (the (0x2075) bit-2 test adds nothing here); the key's pair flag (W bit 7, set for the lower key) is the
;   step's sign (bit 7 of W is the sign for both Value_ApplyNibbleDeltaClamped and Value_StepWordClamped).
SoftKeyCol1_Oct:   ; entry: named by 2 `.long` operands, first at 0xF90CD8
	add W,0x06                                           ; F911E6  c8 c8 06
	bit	2, (UI_RequestBits:16)                               ; F911E9  f1 75 20 ca
	jr z, SoftKeyCol1_Oct_Join                                     ; F911ED  66 00
SoftKeyCol1_Oct_Join:
	ldw (PanelDial_DownButton:16), 0x80                                ; F911EF  f1 9b 20 02 80 00
	or	(UI_RequestBits:16), 0x09                            ; F911F5  c1 75 20 3e 09
	ld XIY,0x000078b2                                    ; F911FA  45 b2 78 00 00
	ld	l, (xiy+0:8)                                 ; F911FF  8d 00 27
	ldw ix, 0x64                                         ; F91202  34 64 00
	ldw iy, 0x1c                                         ; F91205  35 1c 00
	extz HL                                              ; F91208  db 12
	ld DE,HL                                             ; F9120A  db 8a
	push W                                               ; F9120C  c8 04
	pushw hl                                             ; F9120E  2b
	calr Value_StepWordClamped                                          ; F9120F  1e 9e 33
	popw hl                                              ; F91212  4b
	pop W                                                ; F91213  c8 05
	cp DE,HL                                             ; F91215  db f2
	jr z, .LF9123A                                       ; F91217  66 21
	ldw ix, 0x64                                         ; F91219  34 64 00
	ldw iy, 0x1c                                         ; F9121C  35 1c 00
	calr Value_StepWordClamped                                          ; F9121F  1e 8e 33
	ld XIY,0x000078b2                                    ; F91222  45 b2 78 00 00
	and	(xiy+0:8), 0x80                              ; F91227  8d 00 3c 80
	or	(xiy+0:8), e                         ; F9122B  8d 00 ed
	ld A,E                                               ; F9122E  cd 89
	ld e, 0x79:opc                                          ; F91230  25 79
	ld d, 0x00:opc                                          ; F91232  24 00
	ld w, 0x7f:opc                                          ; F91234  20 7f
	call T_Queue2E00_AppendRegs                          ; F91236  1d 3c 0f f4
.LF9123A:
	ret                                                  ; F9123A  0e
; SoftKeyCol2_LvlVol -- soft-key column 2 (LVL / VOL) handler: step in W, then SoftKeyCol2_LvlVol_Step
; Evidence: entry [1] of DisplayListPtrs_F90CD8 (SOUND MODE) and of DisplayListPtrs_F914FB (COMBINATION page 1); code
;   1 = SOFT KEY column 2 (FINDINGS-prom_a-panel-control-map.md 1); SOUND MODE labels column 2 "LVL", COMBINATION page
;   1 "VOL". Prefix `add W,1`, `add W,2` more when (0x2075) bit 2 is set; the key's pair flag (W bit 7, set for the
;   lower key) is the step's sign (bit 7 of W is the sign for both Value_ApplyNibbleDeltaClamped and Value_StepWordClamped).
SoftKeyCol2_LvlVol:   ; entry: named by 2 `.long` operands, first at 0xF90CDC
	add W,0x01                                           ; F9123B  c8 c8 01
	bit	2, (UI_RequestBits:16)                               ; F9123E  f1 75 20 ca
	jr z, SoftKeyCol2_LvlVol_Join                                     ; F91242  66 03
	add W,0x02                                           ; F91244  c8 c8 02
SoftKeyCol2_LvlVol_Join:
	ldw (PanelDial_DownButton:16), 0x0181                              ; F91247  f1 9b 20 02 81 01
	or	(UI_RequestBits:16), 0x09                            ; F9124D  c1 75 20 3e 09
	cp	(UI_ScreenId:16), 0x01                            ; F91252  c1 7c 20 3f 01
	jr nz, .LF9125E                                      ; F91257  6e 05
	calr SoundMode_StepLvl                                          ; F91259  1e 87 14
	jr .LF91268                                          ; F9125C  68 0a
.LF9125E:
	calr PartRecord_GetPtr                                          ; F9125E  1e d8 32
	ld e, (UI_PartIndex:16)                                   ; F91261  c1 50 22 25
	calr C0mbinati0nM0de_StepPartVol                                          ; F91265  1e 61 14
.LF91268:
	ret                                                  ; F91268  0e
; SoftKeyCol3_Pan -- soft-key column 3 (PAN) handler: step in W, then SoftKeyCol3_Pan_Step
; Evidence: entry [2] of DisplayListPtrs_F90CD8 (SOUND MODE) and of DisplayListPtrs_F914FB (COMBINATION page 1); code
;   2 = SOFT KEY column 3 (FINDINGS-prom_a-panel-control-map.md 1); both screens label column 3 "PAN". Prefix `add
;   W,1`, `add W,2` more when (0x2075) bit 2 is set; the key's pair flag (W bit 7, set for the lower key) is the
;   step's sign (bit 7 of W is the sign for both Value_ApplyNibbleDeltaClamped and Value_StepWordClamped).
SoftKeyCol3_Pan:   ; entry: named by 2 `.long` operands, first at 0xF90CE0
	add W,0x01                                           ; F91269  c8 c8 01
	bit	2, (UI_RequestBits:16)                               ; F9126C  f1 75 20 ca
	jr z, SoftKeyCol3_Pan_Join                                     ; F91270  66 03
	add W,0x02                                           ; F91272  c8 c8 02
SoftKeyCol3_Pan_Join:
	ldw (PanelDial_DownButton:16), 0x0282                              ; F91275  f1 9b 20 02 82 02
	or	(UI_RequestBits:16), 0x09                            ; F9127B  c1 75 20 3e 09
	cp	(UI_ScreenId:16), 0x01                            ; F91280  c1 7c 20 3f 01
	jr nz, .LF9128C                                      ; F91285  6e 05
	calr SoundMode_StepPan                                          ; F91287  1e 18 14
	jr .LF91296                                          ; F9128A  68 0a
.LF9128C:
	calr PartRecord_GetPtr                                          ; F9128C  1e aa 32
	ld e, (UI_PartIndex:16)                                   ; F9128F  c1 50 22 25
	calr C0mbinati0nM0de_StepPartPan                                          ; F91293  1e fd 13
.LF91296:
	ret                                                  ; F91296  0e
; SoftKeyCol4_Eff1 -- soft-key column 4 (EFF1) handler: step in W, then SoftKeyCol4_Eff1_Step
; Evidence: entry [3] of DisplayListPtrs_F90CD8 (SOUND MODE) and of DisplayListPtrs_F914FB (COMBINATION page 1); code
;   3 = SOFT KEY column 4 (FINDINGS-prom_a-panel-control-map.md 1); both screens label column 4 "EFF1". Prefix `add
;   W,1`, `add W,2` more when (0x2075) bit 2 is set; the key's pair flag (W bit 7, set for the lower key) is the
;   step's sign (bit 7 of W is the sign for both Value_ApplyNibbleDeltaClamped and Value_StepWordClamped).
SoftKeyCol4_Eff1:   ; entry: named by 2 `.long` operands, first at 0xF90CE4
	add W,0x01                                           ; F91297  c8 c8 01
	bit	2, (UI_RequestBits:16)                               ; F9129A  f1 75 20 ca
	jr z, SoftKeyCol4_Eff1_Join                                     ; F9129E  66 03
	add W,0x02                                           ; F912A0  c8 c8 02
SoftKeyCol4_Eff1_Join:
	ldw (PanelDial_DownButton:16), 0x0383                              ; F912A3  f1 9b 20 02 83 03
	or	(UI_RequestBits:16), 0x09                            ; F912A9  c1 75 20 3e 09
	calr PartRecord_GetPtr                                          ; F912AE  1e 88 32
	ld A,(XIY+0x05)                                      ; F912B1  8d 05 21
	ld b, 0x7f:opc                                          ; F912B4  22 7f
	ld c, 0x00:opc                                          ; F912B6  23 00
	ld e, (UI_PartIndex:16)                                   ; F912B8  c1 50 22 25
	ld d, 0x05:opc                                          ; F912BC  24 05
	ld h, 0x7f:opc                                          ; F912BE  26 7f
	cp	(UI_ScreenId:16), 0x01                            ; F912C0  c1 7c 20 3f 01
	jr nz, .LF912E4                                      ; F912C5  6e 1d
	ld L,A                                               ; F912C7  c9 8f
	pushw hl                                             ; F912C9  2b
	call T_Value_ApplyNibbleDeltaClamped                                        ; F912CA  1d 04 1b f4
	popw hl                                              ; F912CE  4b
	cp A,L                                               ; F912CF  cf f1
	jr z, .LF912E7                                       ; F912D1  66 14
	ld (XIY+0x05),A                                      ; F912D3  bd 05 41
	ld W,H                                               ; F912D6  ce 88
	ld d, 0x05:opc                                          ; F912D8  24 05
	ld e, (UI_PartIndex:16)                                   ; F912DA  c1 50 22 25
	call T_Queue2E00_AppendRegs                          ; F912DE  1d 3c 0f f4
	jr .LF912E7                                          ; F912E2  68 03
.LF912E4:
	calr Value_StepAndPostIfChanged                                          ; F912E4  1e 7a 32
.LF912E7:
	ret                                                  ; F912E7  0e
; SoftKeyCol5_Eff2 -- soft-key column 5 (EFF2) handler
; Evidence: entry [4] of DisplayListPtrs_F90CD8 (SOUND MODE) and of DisplayListPtrs_F914FB (COMBINATION page 1); code
;   4 = SOFT KEY column 5 (FINDINGS-prom_a-panel-control-map.md 1); both screens label column 5 "EFF2". (0x209B) =
;   0x0484, or (0x2075),0x01; record +6 toggles 0x00 (lower key) / 0x7F (upper key), the upper key requesting screen
;   0xB6 (0x2070 = 0x40B6) instead when the PartRecord_GetSecondHalfPtr record +3 and +4 are both non-zero; the change goes to
;   Queue2E00 {part,6} on screen 1, to List2030 elsewhere.
SoftKeyCol5_Eff2:
	ldw (PanelDial_DownButton:16), 0x0484                              ; F912E8  f1 9b 20 02 84 04
	or	(UI_RequestBits:16), 0x01                            ; F912EE  c1 75 20 3e 01
	calr PartRecord_GetPtr                                          ; F912F3  1e 43 32
	ld e, (UI_PartIndex:16)                                   ; F912F6  c1 50 22 25
	ld A,(XIY+0x06)                                      ; F912FA  8d 06 21
	and A,0x7f                                           ; F912FD  c9 cc 7f
	bit 0x07,W                                           ; F91300  c8 33 07
	jr z, .LF9130F                                       ; F91303  66 0a
	cp A,0x7f                                            ; F91305  c9 cf 7f
	jr nz, .LF91349                                      ; F91308  6e 3f
	and A,0x80                                           ; F9130A  c9 cc 80
	jr .LF9132E                                          ; F9130D  68 1f
.LF9130F:
	cp A,0x7f                                            ; F9130F  c9 cf 7f
	jr z, .LF91349                                       ; F91312  66 35
	calr PartRecord_GetSecondHalfPtr                                          ; F91314  1e 36 32
	cp (XIY+0x03),0x00                                   ; F91317  8d 03 3f 00
	jr z, .LF9132B                                       ; F9131B  66 0e
	cp (XIY+0x04),0x00                                   ; F9131D  8d 04 3f 00
	jr z, .LF9132B                                       ; F91321  66 08
	ldw (UI_Request:16), 0x40b6                              ; F91323  f1 70 20 02 b6 40
	jr .LF91349                                          ; F91329  68 1e
.LF9132B:
	or A,0x7f                                            ; F9132B  c9 ce 7f
.LF9132E:
	calr PartRecord_GetPtr                                          ; F9132E  1e 08 32
	ld w, 0x7f:opc                                          ; F91331  20 7f
	ld d, 0x06:opc                                          ; F91333  24 06
	cp	(UI_ScreenId:16), 0x01                            ; F91335  c1 7c 20 3f 01
	jr nz, .LF91345                                      ; F9133A  6e 09
	ld (XIY+0x06),A                                      ; F9133C  bd 06 41
	call T_Queue2E00_AppendRegs                          ; F9133F  1d 3c 0f f4
	jr .LF91349                                          ; F91343  68 04
.LF91345:
	call T_List2030_AppendRegs                           ; F91345  1d 40 0f f4
.LF91349:
	ret                                                  ; F91349  0e
; SoftKeyCol6_Rev -- soft-key column 6 (REV) handler: step in W, then SoftKeyCol6_Rev_Step
; Evidence: entry [5] of DisplayListPtrs_F90CD8 (SOUND MODE) and of DisplayListPtrs_F914FB (COMBINATION page 1); code
;   5 = SOFT KEY column 6 (FINDINGS-prom_a-panel-control-map.md 1); both screens label column 6 "REV". Prefix `add
;   W,1`, `add W,2` more when (0x2075) bit 2 is set; the key's pair flag (W bit 7, set for the lower key) is the
;   step's sign (bit 7 of W is the sign for both Value_ApplyNibbleDeltaClamped and Value_StepWordClamped).
SoftKeyCol6_Rev:   ; entry: named by 2 `.long` operands, first at 0xF90CEC
	add W,0x01                                           ; F9134A  c8 c8 01
	bit	2, (UI_RequestBits:16)                               ; F9134D  f1 75 20 ca
	jr z, SoftKeyCol6_Rev_Join                                     ; F91351  66 03
	add W,0x02                                           ; F91353  c8 c8 02
SoftKeyCol6_Rev_Join:
	ldw (PanelDial_DownButton:16), 0x0585                              ; F91356  f1 9b 20 02 85 05
	or	(UI_RequestBits:16), 0x09                            ; F9135C  c1 75 20 3e 09
	calr PartRecord_GetPtr                                          ; F91361  1e d5 31
	ld A,(XIY+0x07)                                      ; F91364  8d 07 21
	ld b, 0x7f:opc                                          ; F91367  22 7f
	ld c, 0x00:opc                                          ; F91369  23 00
	ld e, (UI_PartIndex:16)                                   ; F9136B  c1 50 22 25
	ld d, 0x07:opc                                          ; F9136F  24 07
	ld h, 0x7f:opc                                          ; F91371  26 7f
	cp	(UI_ScreenId:16), 0x01                            ; F91373  c1 7c 20 3f 01
	jr nz, .LF91397                                      ; F91378  6e 1d
	ld L,A                                               ; F9137A  c9 8f
	pushw hl                                             ; F9137C  2b
	call T_Value_ApplyNibbleDeltaClamped                                        ; F9137D  1d 04 1b f4
	popw hl                                              ; F91381  4b
	cp A,L                                               ; F91382  cf f1
	jr z, .LF9139A                                       ; F91384  66 14
	ld (XIY+0x07),A                                      ; F91386  bd 07 41
	ld W,H                                               ; F91389  ce 88
	ld d, 0x07:opc                                          ; F9138B  24 07
	ld e, (UI_PartIndex:16)                                   ; F9138D  c1 50 22 25
	call T_Queue2E00_AppendRegs                          ; F91391  1d 3c 0f f4
	jr .LF9139A                                          ; F91395  68 03
.LF91397:
	calr Value_StepAndPostIfChanged                                          ; F91397  1e c7 31
.LF9139A:
	ret                                                  ; F9139A  0e
; SoftKeyCol7_Int -- soft-key column 7 (INT) handler
; Evidence: entry [6] of DisplayListPtrs_F90CD8 (SOUND MODE) and of DisplayListPtrs_F914FB (COMBINATION page 1); code
;   6 = SOFT KEY column 7 (FINDINGS-prom_a-panel-control-map.md 1); both screens label column 7 "INT". (0x209B) =
;   0x0686, or (0x2075),0x01, XIY = PartRecord_GetPtr, E = part, then C0mbinati0nM0de_SetPartInt.
SoftKeyCol7_Int:
	ldw (PanelDial_DownButton:16), 0x0686                              ; F9139B  f1 9b 20 02 86 06
	or	(UI_RequestBits:16), 0x01                            ; F913A1  c1 75 20 3e 01
	calr PartRecord_GetPtr                                          ; F913A6  1e 90 31
	ld e, (UI_PartIndex:16)                                   ; F913A9  c1 50 22 25
	calr C0mbinati0nM0de_SetPartInt                                          ; F913AD  1e b5 12
	ret                                                  ; F913B0  0e
; SoftKeyCol8_Midi -- soft-key column 8 (MIDI) handler: step in W, then SoftKeyCol8_Midi_Step
; Evidence: entry [7] of DisplayListPtrs_F90CD8 (SOUND MODE only); code 7 = SOFT KEY column 8; SOUND MODE labels it
;   "MIDI". Prefix `add W,1`, `add W,2` more when (0x2075) bit 2 is set; the key's pair flag (W bit 7, set for the
;   lower key) is the step's sign (bit 7 of W is the sign for both Value_ApplyNibbleDeltaClamped and Value_StepWordClamped).
SoftKeyCol8_Midi:   ; entry: named by 1 `.long` operand, first at 0xF90CF4
	add W,0x01                                           ; F913B1  c8 c8 01
	bit	2, (UI_RequestBits:16)                               ; F913B4  f1 75 20 ca
	jr z, SoftKeyCol8_Midi_Join                                     ; F913B8  66 03
	add W,0x02                                           ; F913BA  c8 c8 02
SoftKeyCol8_Midi_Join:
	ldw (PanelDial_DownButton:16), 0x0787                              ; F913BD  f1 9b 20 02 87 07
	or	(UI_RequestBits:16), 0x09                            ; F913C3  c1 75 20 3e 09
	calr PartRecord_GetPtr                                          ; F913C8  1e 6e 31
	ld A,(XIY+0x0d)                                      ; F913CB  8d 0d 21
	and A,0x1f                                           ; F913CE  c9 cc 1f
	ld b, 0x1f:opc                                          ; F913D1  22 1f
	ld c, 0x00:opc                                          ; F913D3  23 00
	ld e, (UI_PartIndex:16)                                   ; F913D5  c1 50 22 25
	ld d, 0x0d:opc                                          ; F913D9  24 0d
	ld h, 0x1f:opc                                          ; F913DB  26 1f
	ld L,A                                               ; F913DD  c9 8f
	push W                                               ; F913DF  c8 04
	pushw hl                                             ; F913E1  2b
	call T_Value_ApplyNibbleDeltaClamped                                        ; F913E2  1d 04 1b f4
	popw hl                                              ; F913E6  4b
	pop W                                                ; F913E7  c8 05
	cp A,L                                               ; F913E9  cf f1
	jr z, .LF913FA                                       ; F913EB  66 0d
	ld W,H                                               ; F913ED  ce 88
	and (XIY+0x0d),0xe0                                  ; F913EF  8d 0d 3c e0
	or (XIY+0x0d),A                                      ; F913F3  8d 0d e9
	call T_Queue2E00_AppendRegs                          ; F913F6  1d 3c 0f f4
.LF913FA:
	ret                                                  ; F913FA  0e
; LcdKeyRow1_SoundMode: slot 8 (LCD key row 1) of DisplayListPtrs_F90CD8, the SOUND MODE button table ScreenButton_SoundMode reads; when W bit 7 is set, T_Drawbar_EnterScreenIfMarked.
LcdKeyRow1_SoundMode:   ; entry: named by 1 `.long` operand, first at 0xF90CF8
	bit 0x07,W                                           ; F913FB  c8 33 07
	jr Z,.LF91404                                        ; F913FE  66 04
	call T_Drawbar_EnterScreenIfMarked                                        ; F91400  1d 68 2e f4
.LF91404:
	ret                                                  ; F91404  0e
DisplayListPtrs_F90CD8_Nop9:   ; entry: named by 1 `.long` operand, first at 0xF90CFC
	ret                                                  ; F91405  0e
DisplayListPtrs_F90CD8_Nop10:   ; entry: named by 1 `.long` operand, first at 0xF90D00
	ret                                                  ; F91406  0e
; LcdKeyRow4_SoundModeOrC0mbinati0nM0de: slot 11 (LCD key row 4) of both DisplayListPtrs_F90CD8 (SOUND MODE) and DisplayListPtrs_F914FB
;   (COMBINATION MODE page 1).
LcdKeyRow4_SoundModeOrC0mbinati0nM0de:   ; entry: named by 2 `.long` operands, first at 0xF90D04
	call PartRecord_GetSecondHalfPtr                                        ; F91407  1d 4d 45 f9
	ld A,(XIY+0x18)                                      ; F9140B  8d 18 21
	bit 0x07,W                                           ; F9140E  c8 33 07
	jr z, .LF9141C                                       ; F91411  66 09
	cp a, 0x01:i3                                          ; F91413  c9 d9
	jr nz, .LF91432                                      ; F91415  6e 1b
	and A,0xfe                                           ; F91417  c9 cc fe
	jr .LF91423                                          ; F9141A  68 07
.LF9141C:
	cp a, 0x01:i3                                          ; F9141C  c9 d9
	jr z, .LF91432                                       ; F9141E  66 12
	or A,0x01                                            ; F91420  c9 ce 01
.LF91423:
	ld e, (UI_PartIndex:16)                                   ; F91423  c1 50 22 25
	or E,0x20                                            ; F91427  cd ce 20
	ld d, 0x18:opc                                          ; F9142A  24 18
	ld w, 0x01:opc                                          ; F9142C  20 01
	call T_List2030_AppendRegs                           ; F9142E  1d 40 0f f4
.LF91432:
	ret                                                  ; F91432  0e
DisplayListPtrs_F90CD8_Nop12:   ; entry: named by 1 `.long` operand, first at 0xF90D08
	ret                                                  ; F91433  0e
DisplayListPtrs_F90CD8_Nop13:   ; entry: named by 1 `.long` operand, first at 0xF90D0C
	ret                                                  ; F91434  0e
DisplayListPtrs_F90CD8_Nop14:   ; entry: named by 1 `.long` operand, first at 0xF90D10
	ret                                                  ; F91435  0e
; ExitKey_SoundMode -- SOUND MODE's EXIT handler: clear bit 3 of (0x2075)
; Evidence: entry [15] (code 0x0F = EXIT, FINDINGS-prom_a-panel-control-map.md 1) of DisplayListPtrs_F90CD8, named
;   nowhere else; `and (0x2075),0xf7`, then a `bit 7,W / jr nz` to the next instruction (no effect), `ret`.
ExitKey_SoundMode:   ; entry: named by 1 `.long` operand, first at 0xF90D14
	and	(UI_RequestBits:16), 0xf7                            ; F91436  c1 75 20 3c f7
	bit 0x07,W                                           ; F9143B  c8 33 07
	jr nz, .LF91440                                      ; F9143E  6e 00
.LF91440:
	ret                                                  ; F91440  0e
DisplayListPtrs_F90CD8_Nop16:   ; entry: named by 1 `.long` operand, first at 0xF90D18
	ret                                                  ; F91441  0e
; SoftKeyCol1_Oct_AltCode -- column 1 handler for the rewritten code 0x11 (= 0 + 0x11)
; Evidence: entry [17] of DisplayListPtrs_F90CD8 and DisplayListPtrs_F914FB; prefix `add W,0x06`, then `jp
;   SoftKeyCol1_Oct_Step`.  Code c + 0x11 is what PanelAction_PairPos0/1_HeldMaskAltCode deliver when code c is
;   already held (variant-1 groups 3-6).
SoftKeyCol1_Oct_AltCode:   ; entry: named by 2 `.long` operands, first at 0xF90D1C
	add W,0x06                                           ; F91442  c8 c8 06
	bit	2, (UI_RequestBits:16)                               ; F91445  f1 75 20 ca
	jr z, .LF9144B                                       ; F91449  66 00
.LF9144B:
	jp SoftKeyCol1_Oct_Join                                        ; F9144B  1b ef 11 f9
; SoftKeyCol2_LvlVol_AltCode -- column 2 handler for the rewritten code 0x12 (= 1 + 0x11)
; Evidence: entry [18] of DisplayListPtrs_F90CD8 and DisplayListPtrs_F914FB; prefix `add W,1`, +6 more with (0x2075)
;   bit 2, then `jp SoftKeyCol2_LvlVol_Step`.  Code c + 0x11 is what PanelAction_PairPos0/1_HeldMaskAltCode deliver
;   when code c is already held (variant-1 groups 3-6).
SoftKeyCol2_LvlVol_AltCode:   ; entry: named by 2 `.long` operands, first at 0xF90D20
	add W,0x01                                           ; F9144F  c8 c8 01
	bit	2, (UI_RequestBits:16)                               ; F91452  f1 75 20 ca
	jr z, .LF9145B                                       ; F91456  66 03
	add W,0x06                                           ; F91458  c8 c8 06
.LF9145B:
	jp SoftKeyCol2_LvlVol_Join                                        ; F9145B  1b 47 12 f9
; SoftKeyCol3_Pan_AltCode -- column 3 handler for the rewritten code 0x13 (= 2 + 0x11)
; Evidence: entry [19] of DisplayListPtrs_F90CD8 and DisplayListPtrs_F914FB; prefix `add W,1`, +6 more with (0x2075)
;   bit 2, then `jp SoftKeyCol3_Pan_Step`.  Code c + 0x11 is what PanelAction_PairPos0/1_HeldMaskAltCode deliver when
;   code c is already held (variant-1 groups 3-6).
SoftKeyCol3_Pan_AltCode:   ; entry: named by 2 `.long` operands, first at 0xF90D24
	add W,0x01                                           ; F9145F  c8 c8 01
	bit	2, (UI_RequestBits:16)                               ; F91462  f1 75 20 ca
	jr z, .LF9146B                                       ; F91466  66 03
	add W,0x06                                           ; F91468  c8 c8 06
.LF9146B:
	jp SoftKeyCol3_Pan_Join                                        ; F9146B  1b 75 12 f9
; SoftKeyCol4_Eff1_AltCode -- column 4 handler for the rewritten code 0x14 (= 3 + 0x11)
; Evidence: entry [20] of DisplayListPtrs_F90CD8 and DisplayListPtrs_F914FB; prefix `add W,1`, +6 more with (0x2075)
;   bit 2, then `jp SoftKeyCol4_Eff1_Step`.  Code c + 0x11 is what PanelAction_PairPos0/1_HeldMaskAltCode deliver when
;   code c is already held (variant-1 groups 3-6).
SoftKeyCol4_Eff1_AltCode:   ; entry: named by 2 `.long` operands, first at 0xF90D28
	add W,0x01                                           ; F9146F  c8 c8 01
	bit	2, (UI_RequestBits:16)                               ; F91472  f1 75 20 ca
	jr z, .LF9147B                                       ; F91476  66 03
	add W,0x06                                           ; F91478  c8 c8 06
.LF9147B:
	jp SoftKeyCol4_Eff1_Join                                        ; F9147B  1b a3 12 f9
; SoftKeyCol5_Eff2_AltCode -- column 5 handler for the rewritten code 0x15 (= 4 + 0x11)
; Evidence: entry [21] of DisplayListPtrs_F90CD8 and DisplayListPtrs_F914FB; prefix nothing, then `jp
;   SoftKeyCol5_Eff2`.  Code c + 0x11 is what PanelAction_PairPos0/1_HeldMaskAltCode deliver when code c is already
;   held (variant-1 groups 3-6).
SoftKeyCol5_Eff2_AltCode:   ; entry: named by 2 `.long` operands, first at 0xF90D2C
	jp SoftKeyCol5_Eff2                                        ; F9147F  1b e8 12 f9
; SoftKeyCol6_Rev_AltCode -- column 6 handler for the rewritten code 0x16 (= 5 + 0x11)
; Evidence: entry [22] of DisplayListPtrs_F90CD8 and DisplayListPtrs_F914FB; prefix `add W,1`, +6 more with (0x2075)
;   bit 2, then `jp SoftKeyCol6_Rev_Step`.  Code c + 0x11 is what PanelAction_PairPos0/1_HeldMaskAltCode deliver when
;   code c is already held (variant-1 groups 3-6).
SoftKeyCol6_Rev_AltCode:   ; entry: named by 2 `.long` operands, first at 0xF90D30
	add W,0x01                                           ; F91483  c8 c8 01
	bit	2, (UI_RequestBits:16)                               ; F91486  f1 75 20 ca
	jr z, .LF9148F                                       ; F9148A  66 03
	add W,0x06                                           ; F9148C  c8 c8 06
.LF9148F:
	jp SoftKeyCol6_Rev_Join                                        ; F9148F  1b 56 13 f9
; SoftKeyCol7_Int_AltCode -- column 7 handler for the rewritten code 0x17 (= 6 + 0x11)
; Evidence: entry [23] of DisplayListPtrs_F90CD8 and DisplayListPtrs_F914FB; prefix nothing, then `jp
;   SoftKeyCol7_Int`.  Code c + 0x11 is what PanelAction_PairPos0/1_HeldMaskAltCode deliver when code c is already
;   held (variant-1 groups 3-6).
SoftKeyCol7_Int_AltCode:   ; entry: named by 2 `.long` operands, first at 0xF90D34
	jp SoftKeyCol7_Int                                        ; F91493  1b 9b 13 f9
; SoftKeyCol8_Midi_AltCode -- column 8 handler for the rewritten code 0x18 (= 7 + 0x11)
; Evidence: entry [24] of DisplayListPtrs_F90CD8; prefix `add W,1`, +3 more with (0x2075) bit 2, then `jp
;   SoftKeyCol8_Midi_Step`.  Code c + 0x11 is what PanelAction_PairPos0/1_HeldMaskAltCode deliver when code c is
;   already held (variant-1 groups 3-6).
SoftKeyCol8_Midi_AltCode:   ; entry: named by 1 `.long` operand, first at 0xF90D38
	add W,0x01                                           ; F91497  c8 c8 01
	bit	2, (UI_RequestBits:16)                               ; F9149A  f1 75 20 ca
	jr z, .LF914A3                                       ; F9149E  66 03
	add W,0x03                                           ; F914A0  c8 c8 03
.LF914A3:
	jp SoftKeyCol8_Midi_Join                                        ; F914A3  1b bd 13 f9
DisplayListPtrs_F90CD8_Nop25:   ; entry: named by 2 `.long` operands, first at 0xF90D3C
	ret                                                  ; F914A7  0e
DisplayListPtrs_F90CD8_Nop26:   ; entry: named by 1 `.long` operand, first at 0xF90D40
	ret                                                  ; F914A8  0e
DisplayListPtrs_F90CD8_Nop27:   ; entry: named by 1 `.long` operand, first at 0xF90D44
	ret                                                  ; F914A9  0e
DisplayListPtrs_F90CD8_Nop28:   ; entry: named by 1 `.long` operand, first at 0xF90D48
	ret                                                  ; F914AA  0e
DisplayListPtrs_F90CD8_Nop29:   ; entry: named by 1 `.long` operand, first at 0xF90D4C
	ret                                                  ; F914AB  0e
DisplayListPtrs_F90CD8_Nop30:   ; entry: named by 1 `.long` operand, first at 0xF90D50
	ret                                                  ; F914AC  0e
DisplayListPtrs_F90CD8_Nop31:   ; entry: named by 1 `.long` operand, first at 0xF90D54
	ret                                                  ; F914AD  0e
sub_F914AE:
	ret                                                  ; F914AE  0e
; GmMode_RepaintModeScreen: T_GmMode_RepaintModeScreen, UiListB_Class91: byte 3 with the GM bit (0x04) changed, while (0x97) bit 1 is set and the screen is SOUND
;   MODE (1) or COMBINATION MODE (2): UI_Request_Hi |= 0x10.
GmMode_RepaintModeScreen:
	ld a, (UiEvent_Byte1:16)                                   ; F914AF  c1 b8 20 21
	cp a, 0x03:i3                                          ; F914B3  c9 db
	jr nz, .LF914D8                                      ; F914B5  6e 21
	ld a, (UiEvent_Byte3:16)                                   ; F914B7  c1 ba 20 21
	bit 0x02,A                                           ; F914BB  c9 33 02
	jr z, .LF914D8                                       ; F914BE  66 18
	bit	1, (0x97:8)                                   ; F914C0  f0 97 c9
	jr z, .LF914D8                                       ; F914C3  66 13
	ld a, (UI_ScreenId:16)                                   ; F914C5  c1 7c 20 21
	cp a, 0x01:i3                                          ; F914C9  c9 d9
	jr z, .LF914D3                                       ; F914CB  66 06
	cp a, 0x02:i3                                          ; F914CD  c9 da
	jr z, .LF914D3                                       ; F914CF  66 02
	jr .LF914D8                                          ; F914D1  68 05
.LF914D3:
	or	(UI_Request_Hi:16), 0x10                            ; F914D3  c1 71 20 3e 10
.LF914D8:
	ret                                                  ; F914D8  0e
; InstallPainter_C0mbinati0nM0de_Entry -- ENTER method of screen 2, a pure wrapper for InstallPainter_C0mbinati0nM0de
; Evidence: PanelScreen_VtableTable_ViewB entry 2 (SCREEN ID 0x02) -> T_InstallPainter_C0mbinati0nM0de_Entry `jp 0xF914D9`; the body is `calr
;   InstallPainter_C0mbinati0nM0de / ret`.
InstallPainter_C0mbinati0nM0de_Entry:
	calr InstallPainter_C0mbinati0nM0de                                          ; F914D9  1e 1f 01
	ret                                                  ; F914DC  0e
; ScreenLeave_C0mbinati0nM0de -- LEAVE method of screen 2 (COMBINATION MODE)
; Evidence: T_InstallPainter_C0mbinati0nM0de_Entry+4 = T_ScreenLeave_C0mbinati0nM0de `jp 0xF914DD`; body `calr ScreenLeaveBody_C0mbinati0nM0de / ret`.
ScreenLeave_C0mbinati0nM0de:
	calr ScreenLeaveBody_C0mbinati0nM0de                                          ; F914DD  1e 5c 09
	ret                                                  ; F914E0  0e
; ScreenButton_C0mbinati0nM0de -- BUTTON method of screen 2: dispatch through the current page's 32-entry table
; Evidence: T_ScreenButton_C0mbinati0nM0de `jp 0xF914E1`; `ld XIX,DisplayListPtrs_F914FB / cp (0x2687),0 / jr z` else
;   DisplayListPtrs_F9157B, then T_PanelButton_CallTableEntry (PanelButton_CallTableEntry).  (0x2687) == 0 is page 1
;   (InstallPainter_C0mbinati0nM0de posts the "PAGE1/2" painter then); ⚠ the two tables' headers name the arms the
;   other way round.
ScreenButton_C0mbinati0nM0de:
	ld XIX,DisplayListPtrs_F914FB                        ; F914E1  44 fb 14 f9 00
	cp	(CombinationMode_Page:16), 0x00                            ; F914E6  c1 87 26 3f 00
	jr z, .LF914F2                                       ; F914EB  66 05
	ld XIX,DisplayListPtrs_F9157B                        ; F914ED  44 7b 15 f9 00
.LF914F2:
	call T_PanelButton_CallTableEntry                                        ; F914F2  1d 08 1b f4
	ret                                                  ; F914F6  0e
sub_F914F7:
	calr sub_F923EB                                          ; F914F7  1e f1 0e
	ret                                                  ; F914FA  0e
; ---------------------------------------------------------------------
; DisplayListPtrs_F914FB -- 32 LE32 pointers, the (0x2687) != 0 arm
; Read by: 0xF914E1 `ld XIX,0x00F914FB`, then `cp (0x2687),0x00 / jr z,
;          <load the other table> / call T_PanelButton_CallTableEntry`.  So this table is the
;          arm taken when (0x2687) is NON-zero and 0xF9157B is the zero
;          arm -- one byte of state picks between two 32-entry tables.
; ENTRY COUNT 32 is the callee's bound (0xF8BDC5 `cp HL,0x001F`), and it
;          is corroborated by the sibling: 0xF9157B - 0xF914FB = 0x80.
; ⚠ notes/prom_a_ptr_tables.py reports ONE 64-entry run here.  It is two
;          32-entry tables; the run detector cannot see the second base
;          because nothing separates them in the bytes.
; ---------------------------------------------------------------------

DisplayListPtrs_F914FB:
	.long SoftKeyCol1_Oct                                 ; F914FB  [  0]
	.long SoftKeyCol2_LvlVol                                 ; F914FF  [  1]
	.long SoftKeyCol3_Pan                                 ; F91503  [  2]
	.long SoftKeyCol4_Eff1                                 ; F91507  [  3]
	.long SoftKeyCol5_Eff2                                 ; F9150B  [  4]
	.long SoftKeyCol6_Rev                                 ; F9150F  [  5]
	.long SoftKeyCol7_Int                                 ; F91513  [  6]
	.long SoftKeyCol8_C0mbinati0nM0de                                 ; F91517  [  7]
	.long DisplayListPtrs_F914FB_Nop8                                 ; F9151B  [  8]
	.long DisplayListPtrs_F914FB_Nop8                                 ; F9151F  [  9]
	.long DisplayListPtrs_F914FB_Nop8                                 ; F91523  [ 10]
	.long LcdKeyRow4_SoundModeOrC0mbinati0nM0de                                 ; F91527  [ 11]
	.long DisplayListPtrs_F914FB_Nop8                                 ; F9152B  [ 12]
	.long DisplayListPtrs_F914FB_Nop8                                 ; F9152F  [ 13]
	.long DisplayListPtrs_F914FB_Nop8                                 ; F91533  [ 14]
	.long ExitKey_C0mbinati0nM0de                                 ; F91537  [ 15]
	.long PageKey_C0mbinati0nM0de                                 ; F9153B  [ 16]
	.long SoftKeyCol1_Oct_AltCode                                 ; F9153F  [ 17]
	.long SoftKeyCol2_LvlVol_AltCode                                 ; F91543  [ 18]
	.long SoftKeyCol3_Pan_AltCode                                 ; F91547  [ 19]
	.long SoftKeyCol4_Eff1_AltCode                                 ; F9154B  [ 20]
	.long SoftKeyCol5_Eff2_AltCode                                 ; F9154F  [ 21]
	.long SoftKeyCol6_Rev_AltCode                                 ; F91553  [ 22]
	.long SoftKeyCol7_Int_AltCode                                 ; F91557  [ 23]
	.long C0mbinati0nM0de_Button24                                 ; F9155B  [ 24]
	.long DisplayListPtrs_F90CD8_Nop25                                 ; F9155F  [ 25]
	.long DisplayListPtrs_F914FB_Nop26                                 ; F91563  [ 26]
	.long DisplayListPtrs_F914FB_Nop27                                 ; F91567  [ 27]
	.long DisplayListPtrs_F914FB_Nop28                                 ; F9156B  [ 28]
	.long DisplayListPtrs_F914FB_Nop29                                 ; F9156F  [ 29]
	.long DisplayListPtrs_F914FB_Nop30                                 ; F91573  [ 30]
	.long DisplayListPtrs_F914FB_Nop31                                 ; F91577  [ 31]
; ---------------------------------------------------------------------
; DisplayListPtrs_F9157B -- 32 LE32 pointers, the (0x2687) == 0 arm
; Read by: 0xF914ED `ld XIX,0x00F9157B`, the taken arm of the `jr z` at
;          0xF914EB.  Same callee, same bound of 32.
; ---------------------------------------------------------------------

DisplayListPtrs_F9157B:
	.long SoftKeyCol1_C0mbinati0nM0de_Page2                                 ; F9157B  [  0]
	.long SoftKeyCol2_C0mbinati0nM0de_Page2                                 ; F9157F  [  1]
	.long SoftKeyCol3_C0mbinati0nM0de_Page2                                 ; F91583  [  2]
	.long SoftKeyCol4_C0mbinati0nM0de_Page2                                 ; F91587  [  3]
	.long SoftKeyCol5_C0mbinati0nM0de_Page2                                 ; F9158B  [  4]
	.long SoftKeyCol6_C0mbinati0nM0de_Page2                                 ; F9158F  [  5]
	.long SoftKeyCol7_C0mbinati0nM0de_Page2                                 ; F91593  [  6]
	.long SoftKeyCol8_C0mbinati0nM0de                                 ; F91597  [  7]
	.long LcdKeyRow1_C0mbinati0nM0de_Page2                                 ; F9159B  [  8]
	.long LcdKeyRow2_C0mbinati0nM0de_Page2                                 ; F9159F  [  9]
	.long LcdKeyRow3_C0mbinati0nM0de_Page2                                 ; F915A3  [ 10]
	.long LcdKeyRow4_C0mbinati0nM0de_Page2                                 ; F915A7  [ 11]
	.long DisplayListPtrs_F9157B_Nop12                                 ; F915AB  [ 12]
	.long DisplayListPtrs_F9157B_Nop13                                 ; F915AF  [ 13]
	.long DisplayListPtrs_F9157B_Nop14                                 ; F915B3  [ 14]
	.long ExitKey_C0mbinati0nM0de                                 ; F915B7  [ 15]
	.long PageKey_C0mbinati0nM0de                                 ; F915BB  [ 16]
	.long C0mbinati0nM0de_Page2_Button17                                 ; F915BF  [ 17]
	.long C0mbinati0nM0de_Page2_Button18                                 ; F915C3  [ 18]
	.long C0mbinati0nM0de_Page2_Button19                                 ; F915C7  [ 19]
	.long C0mbinati0nM0de_Page2_Button20                                 ; F915CB  [ 20]
	.long C0mbinati0nM0de_Page2_Button21                                 ; F915CF  [ 21]
	.long C0mbinati0nM0de_Page2_Button22                                 ; F915D3  [ 22]
	.long C0mbinati0nM0de_Page2_Button23                                 ; F915D7  [ 23]
	.long C0mbinati0nM0de_Button24                                 ; F915DB  [ 24]
	.long DisplayListPtrs_F9157B_Nop25                                 ; F915DF  [ 25]
	.long DisplayListPtrs_F914FB_Nop26                                 ; F915E3  [ 26]
	.long DisplayListPtrs_F914FB_Nop27                                 ; F915E7  [ 27]
	.long DisplayListPtrs_F914FB_Nop28                                 ; F915EB  [ 28]
	.long DisplayListPtrs_F914FB_Nop29                                 ; F915EF  [ 29]
	.long DisplayListPtrs_F914FB_Nop30                                 ; F915F3  [ 30]
	.long DisplayListPtrs_F914FB_Nop31                                 ; F915F7  [ 31]
; InstallPainter_C0mbinati0nM0de -- set up screen 2 and install the painter of its current page
; Evidence: on an id change: T_CallbackQueue_ResetAndRestartTask2, (0x2687) = 0, (0x2666) = (0x266A) = all ones,
;   (0x2250) = 0; or (0x2075),0x01.  Unless (0x2095) bit 4: page 1 ((0x2687)=0) -> (0x209B) = 0x0181 and post
;   Paint_C0mbinati0nM0dePage1 (lists Paint_C0mbinati0nM0dePage1_DL1.. "PAGE1/2", "C0MBINATI0N M0DE"); page 2 -> PanelDial_BindToPartColumn and post
;   Paint_C0mbinati0nM0dePage2. Then continues into InstallPainter_C0mbinati0nM0deFields.
InstallPainter_C0mbinati0nM0de:
	ld a, (UI_ScreenId:16)                                   ; F915FB  c1 7c 20 21
	cp (UI_ScreenId_Previous:16), a                                    ; F915FF  c1 7d 20 f9
	jr z, .LF9163B                                       ; F91603  66 36
	call T_CallbackQueue_ResetAndRestartTask2            ; F91605  1d 80 2e f4
	ld (CombinationMode_Page:16), 0x00                                 ; F91609  f1 87 26 00 00
	ld XWA,0xffffffff                                    ; F9160E  40 ff ff ff ff
	ld (0x2666:16), xwa                                 ; F91613  f1 66 26 60
	ld (0x266a:16), xwa                                 ; F91617  f1 6a 26 60
	and	(UI_ScreenFlags:16), 0xef                            ; F9161B  c1 95 20 3c ef
	ld (UI_PartIndex:16), 0x00                                 ; F91620  f1 50 22 00 00
	bit	0, (0x20a9:16)                               ; F91625  f1 a9 20 c8
	jr z, .LF9163B                                       ; F91629  66 10
	ldw (UI_Request:16), 0x40ab                              ; F9162B  f1 70 20 02 ab 40
	ld (UI_StatusCode:16), 0x24                                 ; F91631  f1 80 28 00 24
	and	(0x20a9:16), 0xfe                            ; F91636  c1 a9 20 3c fe
.LF9163B:
	or	(UI_RequestBits:16), 0x01                            ; F9163B  c1 75 20 3e 01
	bit	4, (UI_ScreenFlags:16)                               ; F91640  f1 95 20 cc
	jr nz, InstallPainter_C0mbinati0nM0de_Join                                    ; F91644  6e 36
	cp	(CombinationMode_Page:16), 0x00                            ; F91646  c1 87 26 3f 00
	jr nz, .LF91667                                      ; F9164B  6e 1a
	ldw (PanelDial_DownButton:16), 0x0181                              ; F9164D  f1 9b 20 02 81 01
	ld XWA,Paint_C0mbinati0nM0dePage1                                    ; F91653  40 7e 1c f9 00
	push XWA                                             ; F91658  38
	call T_CallbackQueue_Post                            ; F91659  1d 84 2e f4
	inc 4,XSP                                            ; F9165D  ef 64
	ld a, 0x01:opc                                          ; F9165F  21 01
	call T_Kernel_SemaSignal                             ; F91661  1d 88 2d f4
	jr InstallPainter_C0mbinati0nM0de_Join                                        ; F91665  68 15
.LF91667:
	calr PanelDial_BindToPartColumn                                      ; F91667  1e 27 01
	ld XWA,Draw_C0mbinati0nM0dePage22Sound                                    ; F9166A  40 aa 16 f9 00
	push XWA                                             ; F9166F  38
	call T_CallbackQueue_Post                            ; F91670  1d 84 2e f4
	inc 4,XSP                                            ; F91674  ef 64
	ld a, 0x01:opc                                          ; F91676  21 01
; (sub_F91678 removed 2026-10-04: no code names it and the line above falls through into it -- part of InstallPainter_C0mbinati0nM0de;
;  notes/prom_a_stray_label_removal.py)
	call T_Kernel_SemaSignal                             ; F91678  1d 88 2d f4
; InstallPainter_C0mbinati0nM0de_Join -- paints the screen whose own text reads "C0MBINATI0N M0DE", "PAGE2/2", "SOUND:"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 4 time(s); XIY = list start, XIX = list end.  1 of those 4 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xF916C1  interpreter A  list 0xF29135  DL_C0mbinati0nM0dePage22Sound
;        text: "C0MBINATI0N M0DE"; "PAGE2/2"; "SOUND:"; "SOUND"; "SOLO"; "INT"
; Evidence: the list address is the `ld XIY,0x00F29135` IMMEDIATE at the
;          instruction two before the cited `call`, and the text quoted
;          above is the `.ascii` the interpreter draws verbatim.  Every
;          alphabetic morpheme of this name occurs in that text; the
;          check is notes/prom_a_understanding_round5.py --morphemes.
;          `Paint_` is a structural verb, not ROM text.
;          ⚠ ROUND 5: where the label reads `InstallPainter_`, the body contains
;          ZERO display-list calls -- it INSTALLS the callback that paints this
;          screen, through `call 0xF42E84`. The screen association is real one hop
;          away; the earlier `Paint_` verb claimed the body did the drawing and it
;          does not. Any display-list COUNT in a header above such a label is the
;          installed callback's, not this routine's.
; Unknown: whether this routine also handles input for the screen, and
;          whether any other routine paints it.  Neither was searched.
; ⚠⚠ NAME RETRACTED IN ROUND 5, AND THE REASON MATTERS MORE THAN THE NAME.
;    This routine was called Paint_C0mbinati0nM0de. The screen text quoted above is real
;    and every morpheme of that name really is in it -- but the text belongs to a
;    DIFFERENT function. The namer credited each display-list site to the nearest
;    preceding label BY SOURCE LINE and never checked the routine's own `ret`, so a
;    site inside an unlabelled function was attributed to whatever label came before
;    it. The routine that really owns that screen is InstallPainter_C0mbinati0nM0de, which installs the painter
;    at 0xF916AA via `ld XWA,0x00f916aa` at 0xF9166A. 0xF9167C installs two OTHER
;    callbacks, and neither contains any text at all.
;    That is LOCATED, not IDENTIFIED -- the failure this tree has documented before.
;    The evidence below is left in place because it is true about the SCREEN; what is
;    not established is that THIS routine paints it.
; Unknown: what this routine is for. Its body contains ZERO display-list calls.
; ---------------------------------------------------------------------
InstallPainter_C0mbinati0nM0de_Join:
	cp	(CombinationMode_Page:16), 0x00                            ; F9167C  c1 87 26 3f 00
	jr nz, .LF91697                                      ; F91681  6e 14
	ld XWA,C0mbinati0nM0de_RepaintPage1Fields                                    ; F91683  40 f2 1c f9 00
	push XWA                                             ; F91688  38
	call T_CallbackQueue_Post                            ; F91689  1d 84 2e f4
	inc 4,XSP                                            ; F9168D  ef 64
	ld a, 0x01:opc                                          ; F9168F  21 01
	call T_Kernel_SemaSignal                             ; F91691  1d 88 2d f4
	jr .LF916A9                                          ; F91695  68 12
.LF91697:
	ld XWA,Paint_C0mbinati0nM0dePage2Fields                                    ; F91697  40 25 17 f9 00
	push XWA                                             ; F9169C  38
	call T_CallbackQueue_Post                            ; F9169D  1d 84 2e f4
	inc 4,XSP                                            ; F916A1  ef 64
	ld a, 0x01:opc                                          ; F916A3  21 01
	call T_Kernel_SemaSignal                             ; F916A5  1d 88 2d f4
.LF916A9:
	ret                                                  ; F916A9  0e
Draw_C0mbinati0nM0dePage22Sound:   ; entry: named by 1 `ld` operand, first at 0xF9166A
	xor C,C                                              ; F916AA  cb d3
	ld a, 0x0c:opc                                          ; F916AC  21 0c
	swi 7                                                ; F916AE  ff
	ld a, 0x10:opc                                          ; F916AF  21 10
	swi 7                                                ; F916B1  ff
	ld (LCD_CurrentLayer:16), 0x00                                 ; F916B2  f1 40 25 00 00
	ld XIY,DL_C0mbinati0nM0dePage22Sound                 ; F916B7  45 35 91 f2 00
	ld XIX,DL_F29672                                     ; F916BC  44 72 96 f2 00
	call T_DisplayList_Run                               ; F916C1  1d f0 17 f4
	ld (CombinationMode_EditRow:16), 0x00                                 ; F916C5  f1 78 26 00 00
	or	(CombinationMode_EditRow:16), 0x02                            ; F916CA  c1 78 26 3e 02
	ld XIY,DL_F296CC                                     ; F916CF  45 cc 96 f2 00
	ld XIX,0x00f296d6                                    ; F916D4  44 d6 96 f2 00
	call T_DisplayList_Run                               ; F916D9  1d f0 17 f4
	ld (CombinationMode_ShownPart:16), 0xff                                 ; F916DD  f1 7e 26 00 ff
	calr C0mbinati0nM0de_ShowSelectedPart                                          ; F916E2  1e 48 0f
	ld (CombinationMode_DirtySound:16), 0xff                                 ; F916E5  f1 79 26 00 ff
	ld (CombinationMode_DirtyInt:16), 0xff                                 ; F916EA  f1 7a 26 00 ff
	ld (CombinationMode_DirtyPan:16), 0xff                                 ; F916EF  f1 7b 26 00 ff
	ld (CombinationMode_DirtyVol:16), 0xff                                 ; F916F4  f1 7c 26 00 ff
	call T_UiPaint_PageLabelBackdrop                                        ; F916F9  1d 18 2e f4
	ld (LCD_CurrentLayer:16), 0x01                                 ; F916FD  f1 40 25 00 01
	ld XIY,DL_F29672                                     ; F91702  45 72 96 f2 00
	ld XIX,DL_F2967C                                     ; F91707  44 7c 96 f2 00
	call T_DisplayList_Run                               ; F9170C  1d f0 17 f4
	bit	0, (CombinationMode_Solo:16)                               ; F91710  f1 7d 26 c8
	jr z, .LF91724                                       ; F91714  66 0e
	ld XIY,DL_F2967C                                     ; F91716  45 7c 96 f2 00
	ld XIX,DL_F29686                                     ; F9171B  44 86 96 f2 00
	call T_DisplayList_Run                               ; F91720  1d f0 17 f4
.LF91724:
	ret                                                  ; F91724  0e
; Paint_C0mbinati0nM0dePage2Fields -- redraw COMBINATION MODE page 2's dirty fields
; Evidence: (0x2679) != 0 -> C0mbinati0nM0de_ShowSelectedPartSoundName first; then FieldRedraw_CallPerSetBit with
;   FieldRedrawPtrs_F91865/_F91885/_F918A5/_F918C5 and masks (0x2679)/(0x267A)/(0x267B)/(0x267C) ((0x2540) layer
;   0,1,0,0); clears the four masks; swi 7 fn 0x0C. Posted by InstallPainter_C0mbinati0nM0deFields when (0x2687) != 0.
Paint_C0mbinati0nM0dePage2Fields:   ; entry: named by 1 `ld` operand, first at 0xF91697
	cp	(CombinationMode_DirtySound:16), 0x00                            ; F91725  c1 79 26 3f 00
	jr z, .LF9172F                                       ; F9172A  66 03
	calr C0mbinati0nM0de_ShowSelectedPartSoundName                                          ; F9172C  1e b6 01
.LF9172F:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9172F  f1 40 25 00 00
	ld XIY,FieldRedrawPtrs_F91865                        ; F91734  45 65 18 f9 00
	ld a, (CombinationMode_DirtySound:16)                                   ; F91739  c1 79 26 21
	call FieldRedraw_CallPerSetBit                                      ; F9173D  1d f4 17 f9
	ld (LCD_CurrentLayer:16), 0x01                                 ; F91741  f1 40 25 00 01
	ld XIY,FieldRedrawPtrs_F91885                        ; F91746  45 85 18 f9 00
	ld a, (CombinationMode_DirtyInt:16)                                   ; F9174B  c1 7a 26 21
	call FieldRedraw_CallPerSetBit                                      ; F9174F  1d f4 17 f9
	ld (LCD_CurrentLayer:16), 0x00                                 ; F91753  f1 40 25 00 00
	ld XIY,FieldRedrawPtrs_F918A5                        ; F91758  45 a5 18 f9 00
	ld a, (CombinationMode_DirtyPan:16)                                   ; F9175D  c1 7b 26 21
	call FieldRedraw_CallPerSetBit                                      ; F91761  1d f4 17 f9
	ld (LCD_CurrentLayer:16), 0x00                                 ; F91765  f1 40 25 00 00
	ld XIY,FieldRedrawPtrs_F918C5                        ; F9176A  45 c5 18 f9 00
	ld a, (CombinationMode_DirtyVol:16)                                   ; F9176F  c1 7c 26 21
	call FieldRedraw_CallPerSetBit                                      ; F91773  1d f4 17 f9
	ld (CombinationMode_DirtySound:16), 0x00                                 ; F91777  f1 79 26 00 00
	ld (CombinationMode_DirtyInt:16), 0x00                                 ; F9177C  f1 7a 26 00 00
	ld (CombinationMode_DirtyPan:16), 0x00                                 ; F91781  f1 7b 26 00 00
	ld (CombinationMode_DirtyVol:16), 0x00                                 ; F91786  f1 7c 26 00 00
	ld c, 0x07:opc                                          ; F9178B  23 07
	ld a, 0x0c:opc                                          ; F9178D  21 0c
	swi 7                                                ; F9178F  ff
	ret                                                  ; F91790  0e
; PanelDial_BindToPartColumn -- point the dial at the soft-key column of the current part (0..7)
; Evidence: (0x2250) = k in 0..7 -> `ldw (0x209B),{0x0080,0x0181,...,0x0787}`, the same words the SoftKeyColN handlers
;   store; PanelEvent_Code21_Dial routes the dial as the (0x209B)/(0x209C) button pair.  Called by
;   InstallPainter_C0mbinati0nM0de for page 2 (one column per part).
PanelDial_BindToPartColumn:
	ld a, (UI_PartIndex:16)                                   ; F91791  c1 50 22 21
	cp a, 0x00:i3                                          ; F91795  c9 d8
	jr nz, .LF917A1                                      ; F91797  6e 08
	ldw (PanelDial_DownButton:16), 0x80                                ; F91799  f1 9b 20 02 80 00
	jr .LF917F3                                          ; F9179F  68 52
.LF917A1:
	cp a, 0x01:i3                                          ; F917A1  c9 d9
	jr nz, .LF917AD                                      ; F917A3  6e 08
	ldw (PanelDial_DownButton:16), 0x0181                              ; F917A5  f1 9b 20 02 81 01
	jr .LF917F3                                          ; F917AB  68 46
.LF917AD:
	cp a, 0x02:i3                                          ; F917AD  c9 da
	jr nz, .LF917B9                                      ; F917AF  6e 08
	ldw (PanelDial_DownButton:16), 0x0282                              ; F917B1  f1 9b 20 02 82 02
	jr .LF917F3                                          ; F917B7  68 3a
.LF917B9:
	cp a, 0x03:i3                                          ; F917B9  c9 db
	jr nz, .LF917C5                                      ; F917BB  6e 08
	ldw (PanelDial_DownButton:16), 0x0383                              ; F917BD  f1 9b 20 02 83 03
	jr .LF917F3                                          ; F917C3  68 2e
.LF917C5:
	cp a, 0x04:i3                                          ; F917C5  c9 dc
	jr nz, .LF917D1                                      ; F917C7  6e 08
	ldw (PanelDial_DownButton:16), 0x0484                              ; F917C9  f1 9b 20 02 84 04
	jr .LF917F3                                          ; F917CF  68 22
.LF917D1:
	cp a, 0x05:i3                                          ; F917D1  c9 dd
	jr nz, .LF917DD                                      ; F917D3  6e 08
	ldw (PanelDial_DownButton:16), 0x0585                              ; F917D5  f1 9b 20 02 85 05
	jr .LF917F3                                          ; F917DB  68 16
.LF917DD:
	cp a, 0x06:i3                                          ; F917DD  c9 de
	jr nz, .LF917E9                                      ; F917DF  6e 08
	ldw (PanelDial_DownButton:16), 0x0686                              ; F917E1  f1 9b 20 02 86 06
	jr .LF917F3                                          ; F917E7  68 0a
.LF917E9:
	cp a, 0x07:i3                                          ; F917E9  c9 df
	jr nz, .LF917F3                                      ; F917EB  6e 06
	ldw (PanelDial_DownButton:16), 0x0787                              ; F917ED  f1 9b 20 02 87 07
.LF917F3:
	ret                                                  ; F917F3  0e
; FieldRedraw_CallPerSetBit -- call routine k of the 8-entry table XIY for every set bit k of A
; Evidence: eight `bit k,A / jr z / ld XIX,(XIY+4k) / push XIY / push A / call (xix)` blocks, k = 0..7
;   (0xF917F4-0xF91864); the module banner's "BITMASK dispatcher".  Called by Paint_C0mbinati0nM0dePage2Fields with
;   the FieldRedrawPtrs_* tables.
FieldRedraw_CallPerSetBit:
	bit 0x00,A                                           ; F917F4  c9 33 00
	jr z, .LF91802                                       ; F917F7  66 09
	ld	xix, (xiy+0:8)                               ; F917F9  ad 00 24
	push XIY                                             ; F917FC  3d
	push_a                                               ; F917FD  14
	call (xix)                                           ; F917FE  b4 e8
	pop_a                                                ; F91800  15
	pop XIY                                              ; F91801  5d
.LF91802:
	bit 0x01,A                                           ; F91802  c9 33 01
	jr z, .LF91810                                       ; F91805  66 09
	ld XIX,(XIY+0x04)                                    ; F91807  ad 04 24
	push XIY                                             ; F9180A  3d
	push_a                                               ; F9180B  14
	call (xix)                                           ; F9180C  b4 e8
	pop_a                                                ; F9180E  15
	pop XIY                                              ; F9180F  5d
.LF91810:
	bit 0x02,A                                           ; F91810  c9 33 02
	jr z, .LF9181E                                       ; F91813  66 09
	ld XIX,(XIY+0x08)                                    ; F91815  ad 08 24
	push XIY                                             ; F91818  3d
	push_a                                               ; F91819  14
	call (xix)                                           ; F9181A  b4 e8
	pop_a                                                ; F9181C  15
	pop XIY                                              ; F9181D  5d
.LF9181E:
	bit 0x03,A                                           ; F9181E  c9 33 03
	jr z, .LF9182C                                       ; F91821  66 09
	ld XIX,(XIY+0x0c)                                    ; F91823  ad 0c 24
	push XIY                                             ; F91826  3d
	push_a                                               ; F91827  14
	call (xix)                                           ; F91828  b4 e8
	pop_a                                                ; F9182A  15
	pop XIY                                              ; F9182B  5d
.LF9182C:
	bit 0x04,A                                           ; F9182C  c9 33 04
	jr z, .LF9183A                                       ; F9182F  66 09
	ld XIX,(XIY+0x10)                                    ; F91831  ad 10 24
	push XIY                                             ; F91834  3d
	push_a                                               ; F91835  14
	call (xix)                                           ; F91836  b4 e8
	pop_a                                                ; F91838  15
	pop XIY                                              ; F91839  5d
.LF9183A:
	bit 0x05,A                                           ; F9183A  c9 33 05
	jr z, .LF91848                                       ; F9183D  66 09
	ld XIX,(XIY+0x14)                                    ; F9183F  ad 14 24
	push XIY                                             ; F91842  3d
	push_a                                               ; F91843  14
	call (xix)                                           ; F91844  b4 e8
	pop_a                                                ; F91846  15
	pop XIY                                              ; F91847  5d
.LF91848:
	bit 0x06,A                                           ; F91848  c9 33 06
	jr z, .LF91856                                       ; F9184B  66 09
	ld XIX,(XIY+0x18)                                    ; F9184D  ad 18 24
	push XIY                                             ; F91850  3d
	push_a                                               ; F91851  14
	call (xix)                                           ; F91852  b4 e8
	pop_a                                                ; F91854  15
	pop XIY                                              ; F91855  5d
.LF91856:
	bit 0x07,A                                           ; F91856  c9 33 07
	jr z, .LF91864                                       ; F91859  66 09
	ld XIX,(XIY+0x1c)                                    ; F9185B  ad 1c 24
	push XIY                                             ; F9185E  3d
	push_a                                               ; F9185F  14
	call (xix)                                           ; F91860  b4 e8
	pop_a                                                ; F91862  15
	pop XIY                                              ; F91863  5d
.LF91864:
	ret                                                  ; F91864  0e
; ---------------------------------------------------------------------
; FieldRedrawPtrs_F91865 -- 8 routine pointers, one per BIT
; Read by: 0xF91734 `ld XIY,0x00F91865`, handed to FieldRedraw_CallPerSetBit.
; ENTRY COUNT 8 is the READER'S: FieldRedraw_CallPerSetBit tests bit 0 through
;          bit 7 of A and, for each set bit k, calls the pointer at
;          (XIY + 4*k) -- 0x00, 0x04, 0x08, 0x0C, 0x10, 0x14, 0x18,
;          0x1C, and no ninth offset exists in it.  So both the
;          count and the 4-byte stride are read off the reader.
; ⚠ notes/prom_a_ptr_tables.py reports 0xF91865 as ONE 32-entry
;          run.  It is four 8-entry tables: 0xF91865, 0xF91885,
;          0xF918A5 and 0xF918C5 are each loaded by their own
;          `ld XIY` and are exactly 0x20 apart.
; Evidence: all 8 values are inside this module.
; ---------------------------------------------------------------------

FieldRedrawPtrs_F91865:
	.long Paint_C0mbinati0nM0dePage2Sound1                                 ; F91865  [  0]
	.long Paint_C0mbinati0nM0dePage2Sound2                                 ; F91869  [  1]
	.long Paint_C0mbinati0nM0dePage2Sound3                                 ; F9186D  [  2]
	.long Paint_C0mbinati0nM0dePage2Sound4                                 ; F91871  [  3]
	.long Paint_C0mbinati0nM0dePage2Sound5                                 ; F91875  [  4]
	.long Paint_C0mbinati0nM0dePage2Sound6                                 ; F91879  [  5]
	.long Paint_C0mbinati0nM0dePage2Sound7                                 ; F9187D  [  6]
	.long C0mbinati0nM0de_DrawPart8Sound                                 ; F91881  [  7]
; ---------------------------------------------------------------------
; FieldRedrawPtrs_F91885 -- 8 routine pointers, one per BIT
; Read by: 0xF91746 `ld XIY,0x00F91885`, handed to FieldRedraw_CallPerSetBit.
; ENTRY COUNT 8 is the READER'S: FieldRedraw_CallPerSetBit tests bit 0 through
;          bit 7 of A and, for each set bit k, calls the pointer at
;          (XIY + 4*k) -- 0x00, 0x04, 0x08, 0x0C, 0x10, 0x14, 0x18,
;          0x1C, and no ninth offset exists in it.  So both the
;          count and the 4-byte stride are read off the reader.
; ⚠ notes/prom_a_ptr_tables.py reports 0xF91865 as ONE 32-entry
;          run.  It is four 8-entry tables: 0xF91865, 0xF91885,
;          0xF918A5 and 0xF918C5 are each loaded by their own
;          `ld XIY` and are exactly 0x20 apart.
; Evidence: all 8 values are inside this module.
; ---------------------------------------------------------------------

FieldRedrawPtrs_F91885:
	.long C0mbinati0nM0de_DrawPart1Int                                 ; F91885  [  0]
	.long C0mbinati0nM0de_DrawPart2Int                                 ; F91889  [  1]
	.long C0mbinati0nM0de_DrawPart3Int                                 ; F9188D  [  2]
	.long C0mbinati0nM0de_DrawPart4Int                                 ; F91891  [  3]
	.long C0mbinati0nM0de_DrawPart5Int                                 ; F91895  [  4]
	.long C0mbinati0nM0de_DrawPart6Int                                 ; F91899  [  5]
	.long C0mbinati0nM0de_DrawPart7Int                                 ; F9189D  [  6]
	.long C0mbinati0nM0de_DrawPart8Int                                 ; F918A1  [  7]
; ---------------------------------------------------------------------
; FieldRedrawPtrs_F918A5 -- 8 routine pointers, one per BIT
; Read by: 0xF91758 `ld XIY,0x00F918A5`, handed to FieldRedraw_CallPerSetBit.
; ENTRY COUNT 8 is the READER'S: FieldRedraw_CallPerSetBit tests bit 0 through
;          bit 7 of A and, for each set bit k, calls the pointer at
;          (XIY + 4*k) -- 0x00, 0x04, 0x08, 0x0C, 0x10, 0x14, 0x18,
;          0x1C, and no ninth offset exists in it.  So both the
;          count and the 4-byte stride are read off the reader.
; ⚠ notes/prom_a_ptr_tables.py reports 0xF91865 as ONE 32-entry
;          run.  It is four 8-entry tables: 0xF91865, 0xF91885,
;          0xF918A5 and 0xF918C5 are each loaded by their own
;          `ld XIY` and are exactly 0x20 apart.
; Evidence: all 8 values are inside this module.
; ---------------------------------------------------------------------

FieldRedrawPtrs_F918A5:
	.long C0mbinati0nM0de_DrawPart1Pan                                 ; F918A5  [  0]
	.long C0mbinati0nM0de_DrawPart2Pan                                 ; F918A9  [  1]
	.long C0mbinati0nM0de_DrawPart3Pan                                 ; F918AD  [  2]
	.long C0mbinati0nM0de_DrawPart4Pan                                 ; F918B1  [  3]
	.long C0mbinati0nM0de_DrawPart5Pan                                 ; F918B5  [  4]
	.long C0mbinati0nM0de_DrawPart6Pan                                 ; F918B9  [  5]
	.long C0mbinati0nM0de_DrawPart7Pan                                 ; F918BD  [  6]
	.long C0mbinati0nM0de_DrawPart8Pan                                 ; F918C1  [  7]
; ---------------------------------------------------------------------
; FieldRedrawPtrs_F918C5 -- 8 routine pointers, one per BIT
; Read by: 0xF9176A `ld XIY,0x00F918C5`, handed to FieldRedraw_CallPerSetBit.
; ENTRY COUNT 8 is the READER'S: FieldRedraw_CallPerSetBit tests bit 0 through
;          bit 7 of A and, for each set bit k, calls the pointer at
;          (XIY + 4*k) -- 0x00, 0x04, 0x08, 0x0C, 0x10, 0x14, 0x18,
;          0x1C, and no ninth offset exists in it.  So both the
;          count and the 4-byte stride are read off the reader.
; ⚠ notes/prom_a_ptr_tables.py reports 0xF91865 as ONE 32-entry
;          run.  It is four 8-entry tables: 0xF91865, 0xF91885,
;          0xF918A5 and 0xF918C5 are each loaded by their own
;          `ld XIY` and are exactly 0x20 apart.
; Evidence: all 8 values are inside this module.
; ---------------------------------------------------------------------

FieldRedrawPtrs_F918C5:
	.long C0mbinati0nM0de_DrawPart1Vol                                 ; F918C5  [  0]
	.long C0mbinati0nM0de_DrawPart2Vol                                 ; F918C9  [  1]
	.long C0mbinati0nM0de_DrawPart3Vol                                 ; F918CD  [  2]
	.long C0mbinati0nM0de_DrawPart4Vol                                 ; F918D1  [  3]
	.long C0mbinati0nM0de_DrawPart5Vol                                 ; F918D5  [  4]
	.long C0mbinati0nM0de_DrawPart6Vol                                 ; F918D9  [  5]
	.long C0mbinati0nM0de_DrawPart7Vol                                 ; F918DD  [  6]
	.long C0mbinati0nM0de_DrawPart8Vol                                 ; F918E1  [  7]
; C0mbinati0nM0de_ShowSelectedPartSoundName: COMBINATION MODE page 2: draws the selected part's sound name (part
;   record 0xF2AB50[UI_PartIndex], T_SoundName_Lookup) at (0x9B, 0x1B), then C0mbinati0nM0de_ShowSelectedPart. Posted
;   by the page-2 soft keys after they pick a part; run by Paint_C0mbinati0nM0dePage2Fields. Basis: callers + body.
;   (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_a.json)
C0mbinati0nM0de_ShowSelectedPartSoundName:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F918E5  f1 40 25 00 00
	ld XIZ,0x00f2ab50                                    ; F918EA  46 50 ab f2 00
	ld l, (UI_PartIndex:16)                                   ; F918EF  c1 50 22 27
	xor H,H                                              ; F918F3  ce d6
	sla hl, 0x02                                         ; F918F5  db ec 02
	ld	xiz, (xiz+hl)                                ; F918F8  e3 07 f8 ec 26
	ld W,(XIZ+0x01)                                      ; F918FD  8e 01 20
	and W,0x7f                                           ; F91900  c8 cc 7f
	ld	a, (xiz+0:8)                                 ; F91903  8e 00 21
	ld b, (UI_PartIndex:16)                                   ; F91906  c1 50 22 22
	call T_SoundName_Lookup                                        ; F9190A  1d 10 10 f4
	ldw bc, 0x10                                         ; F9190E  31 10 00
	xor HL,HL                                            ; F91911  db d3
	ldw (LCD_X0:16), 0x9b                                ; F91913  f1 30 25 02 9b 00
	ldw (LCD_Y0:16), 0x1b                                ; F91919  f1 32 25 02 1b 00
	ld a, 0x17:opc                                          ; F9191F  21 17
	swi 7                                                ; F91921  ff
	calr C0mbinati0nM0de_ShowSelectedPart                                          ; F91922  1e 08 0d
	ret                                                  ; F91925  0e
; Paint_C0mbinati0nM0dePage2Sound1 -- draw part 1's sound number in COMBINATION MODE page 2's SOUND row
; Evidence: entry [0] of FieldRedrawPtrs_F91865 (bit 0 of (0x2679)); A = (0x76DD) << 3 | (0x76DE), +1 -- record 0 of
;   RecordPtrs_RAM76A2_Panel at +0x3B/+0x3C, the group/member pair Paint_SoundModeFields formats the same way -- to
;   (0x2640), then T_DisplayListB_Run.  Page 2's text reads "SOUND:".
Paint_C0mbinati0nM0dePage2Sound1:   ; entry: named by 1 `.long` operand, first at 0xF91865
	ld a, (0x76dd:16)                                   ; F91926  c1 dd 76 21
	sla a, 0x03                                          ; F9192A  c9 ec 03
	or a, (0x76de:16)                                    ; F9192D  c1 de 76 e1
	inc 1,A                                              ; F91931  c9 61
	ld (UI_DrawScratch:16), a                                   ; F91933  f1 40 26 41
	ld XIY,Paint_C0mbinati0nM0dePage2Sound1_DL                                     ; F91937  45 83 97 f2 00
	ld XIX,DLText_PartCodes                                   ; F9193C  44 a0 97 f2 00
	call T_DisplayListB_Run                              ; F91941  1d f4 17 f4
	ret                                                  ; F91945  0e
; Paint_C0mbinati0nM0dePage2Sound2 -- draw part 2's sound number in COMBINATION MODE page 2's SOUND row
; Evidence: entry [1] of FieldRedrawPtrs_F91865 (bit 1 of (0x2679)); A = (0x771D) << 3 | (0x771E), +1 -- record 1 of
;   RecordPtrs_RAM76A2_Panel at +0x3B/+0x3C, the group/member pair Paint_SoundModeFields formats the same way -- to
;   (0x2640), then T_DisplayListB_Run.  Page 2's text reads "SOUND:".
Paint_C0mbinati0nM0dePage2Sound2:   ; entry: named by 1 `.long` operand, first at 0xF91869
	ld a, (0x771d:16)                                   ; F91946  c1 1d 77 21
	sla a, 0x03                                          ; F9194A  c9 ec 03
	or a, (0x771e:16)                                    ; F9194D  c1 1e 77 e1
	inc 1,A                                              ; F91951  c9 61
	ld (UI_DrawScratch:16), a                                   ; F91953  f1 40 26 41
	ld XIY,Paint_C0mbinati0nM0dePage2Sound2_DL                                     ; F91957  45 63 98 f2 00
	ld XIX,Paint_C0mbinati0nM0dePage2Sound3_DL                                     ; F9195C  44 80 98 f2 00
	call T_DisplayListB_Run                              ; F91961  1d f4 17 f4
	ret                                                  ; F91965  0e
; Paint_C0mbinati0nM0dePage2Sound3 -- draw part 3's sound number in COMBINATION MODE page 2's SOUND row
; Evidence: entry [2] of FieldRedrawPtrs_F91865 (bit 2 of (0x2679)); A = (0x775D) << 3 | (0x775E), +1 -- record 2 of
;   RecordPtrs_RAM76A2_Panel at +0x3B/+0x3C, the group/member pair Paint_SoundModeFields formats the same way -- to
;   (0x2640), then T_DisplayListB_Run.  Page 2's text reads "SOUND:".
Paint_C0mbinati0nM0dePage2Sound3:   ; entry: named by 1 `.long` operand, first at 0xF9186D
	ld a, (0x775d:16)                                   ; F91966  c1 5d 77 21
	sla a, 0x03                                          ; F9196A  c9 ec 03
	or a, (0x775e:16)                                    ; F9196D  c1 5e 77 e1
	inc 1,A                                              ; F91971  c9 61
	ld (UI_DrawScratch:16), a                                   ; F91973  f1 40 26 41
	ld XIY,Paint_C0mbinati0nM0dePage2Sound3_DL                                     ; F91977  45 80 98 f2 00
	ld XIX,Paint_C0mbinati0nM0dePage2Sound4_DL                                     ; F9197C  44 9d 98 f2 00
	call T_DisplayListB_Run                              ; F91981  1d f4 17 f4
	ret                                                  ; F91985  0e
; Paint_C0mbinati0nM0dePage2Sound4 -- draw part 4's sound number in COMBINATION MODE page 2's SOUND row
; Evidence: entry [3] of FieldRedrawPtrs_F91865 (bit 3 of (0x2679)); A = (0x779D) << 3 | (0x779E), +1 -- record 3 of
;   RecordPtrs_RAM76A2_Panel at +0x3B/+0x3C, the group/member pair Paint_SoundModeFields formats the same way -- to
;   (0x2640), then T_DisplayListB_Run.  Page 2's text reads "SOUND:".
Paint_C0mbinati0nM0dePage2Sound4:   ; entry: named by 1 `.long` operand, first at 0xF91871
	ld a, (0x779d:16)                                   ; F91986  c1 9d 77 21
	sla a, 0x03                                          ; F9198A  c9 ec 03
	or a, (0x779e:16)                                    ; F9198D  c1 9e 77 e1
	inc 1,A                                              ; F91991  c9 61
	ld (UI_DrawScratch:16), a                                   ; F91993  f1 40 26 41
	ld XIY,Paint_C0mbinati0nM0dePage2Sound4_DL                                     ; F91997  45 9d 98 f2 00
	ld XIX,Paint_C0mbinati0nM0dePage2Sound5_DL                                     ; F9199C  44 ba 98 f2 00
	call T_DisplayListB_Run                              ; F919A1  1d f4 17 f4
	ret                                                  ; F919A5  0e
; Paint_C0mbinati0nM0dePage2Sound5 -- draw part 5's sound number in COMBINATION MODE page 2's SOUND row
; Evidence: entry [4] of FieldRedrawPtrs_F91865 (bit 4 of (0x2679)); A = (0x77DD) << 3 | (0x77DE), +1 -- record 4 of
;   RecordPtrs_RAM76A2_Panel at +0x3B/+0x3C, the group/member pair Paint_SoundModeFields formats the same way -- to
;   (0x2640), then T_DisplayListB_Run.  Page 2's text reads "SOUND:".
Paint_C0mbinati0nM0dePage2Sound5:   ; entry: named by 1 `.long` operand, first at 0xF91875
	ld a, (0x77dd:16)                                   ; F919A6  c1 dd 77 21
	sla a, 0x03                                          ; F919AA  c9 ec 03
	or a, (0x77de:16)                                    ; F919AD  c1 de 77 e1
	inc 1,A                                              ; F919B1  c9 61
	ld (UI_DrawScratch:16), a                                   ; F919B3  f1 40 26 41
	ld XIY,Paint_C0mbinati0nM0dePage2Sound5_DL                                     ; F919B7  45 ba 98 f2 00
	ld XIX,Paint_C0mbinati0nM0dePage2Sound6_DL                                     ; F919BC  44 d7 98 f2 00
	call T_DisplayListB_Run                              ; F919C1  1d f4 17 f4
	ret                                                  ; F919C5  0e
; Paint_C0mbinati0nM0dePage2Sound6 -- draw part 6's sound number in COMBINATION MODE page 2's SOUND row
; Evidence: entry [5] of FieldRedrawPtrs_F91865 (bit 5 of (0x2679)); A = (0x781D) << 3 | (0x781E), +1 -- record 5 of
;   RecordPtrs_RAM76A2_Panel at +0x3B/+0x3C, the group/member pair Paint_SoundModeFields formats the same way -- to
;   (0x2640), then T_DisplayListB_Run.  Page 2's text reads "SOUND:".
Paint_C0mbinati0nM0dePage2Sound6:   ; entry: named by 1 `.long` operand, first at 0xF91879
	ld a, (0x781d:16)                                   ; F919C6  c1 1d 78 21
	sla a, 0x03                                          ; F919CA  c9 ec 03
	or a, (0x781e:16)                                    ; F919CD  c1 1e 78 e1
	inc 1,A                                              ; F919D1  c9 61
	ld (UI_DrawScratch:16), a                                   ; F919D3  f1 40 26 41
	ld XIY,Paint_C0mbinati0nM0dePage2Sound6_DL                                     ; F919D7  45 d7 98 f2 00
	ld XIX,Paint_C0mbinati0nM0dePage2Sound7_DL                                     ; F919DC  44 f4 98 f2 00
	call T_DisplayListB_Run                              ; F919E1  1d f4 17 f4
	ret                                                  ; F919E5  0e
; Paint_C0mbinati0nM0dePage2Sound7 -- draw part 7's sound number in COMBINATION MODE page 2's SOUND row
; Evidence: entry [6] of FieldRedrawPtrs_F91865 (bit 6 of (0x2679)); A = (0x785D) << 3 | (0x785E), +1 -- record 6 of
;   RecordPtrs_RAM76A2_Panel at +0x3B/+0x3C, the group/member pair Paint_SoundModeFields formats the same way -- to
;   (0x2640), then T_DisplayListB_Run.  Page 2's text reads "SOUND:".
Paint_C0mbinati0nM0dePage2Sound7:   ; entry: named by 1 `.long` operand, first at 0xF9187D
	ld a, (0x785d:16)                                   ; F919E6  c1 5d 78 21
	sla a, 0x03                                          ; F919EA  c9 ec 03
	or a, (0x785e:16)                                    ; F919ED  c1 5e 78 e1
	inc 1,A                                              ; F919F1  c9 61
	ld (UI_DrawScratch:16), a                                   ; F919F3  f1 40 26 41
	ld XIY,Paint_C0mbinati0nM0dePage2Sound7_DL                                     ; F919F7  45 f4 98 f2 00
	ld XIX,C0mbinati0nM0de_DrawPart8Sound_DL                                     ; F919FC  44 11 99 f2 00
	call T_DisplayListB_Run                              ; F91A01  1d f4 17 f4
	ret                                                  ; F91A05  0e
; C0mbinati0nM0de_DrawPart8Sound -- COMBINATION MODE page 2, SOUND row, column PT8: draws part 8's sound as bank code + 3-digit number
; Evidence: entry [7] of FieldRedrawPtrs_F91865 (bit 7 of (0x2679), run by sub_F917F4 from sub_F91725, the page-2 field repaint sub_F9167C posts when (0x2687) != 0).
; (0x2640) = ((0x789D) << 3 | (0x789E)) + 1 at 0xF91A06-0xF91A13; then C0mbinati0nM0de_DrawPart8Sound_DL..C0mbinati0nM0de_DrawPart1Int_DL (interpreter B, 0xF91A21) draws (0x789F) through DLText_PartCodes ("R1-", "U1-", ...) at (0x124,0x30) and (0x2640) as 3 digits at (0x124,0x3A).
; 0x789D-0x789F are +0x3B..+0x3D of part record 8 (0x7862 = 0x76A2 + 7*0x40, entry 7 of the 0xF2AB50 table); x 0x124 is the PT8 column of DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart8Sound:   ; entry: named by 1 `.long` operand, first at 0xF91881
	ld a, (0x789d:16)                                   ; F91A06  c1 9d 78 21
	sla a, 0x03                                          ; F91A0A  c9 ec 03
	or a, (0x789e:16)                                    ; F91A0D  c1 9e 78 e1
	inc 1,A                                              ; F91A11  c9 61
	ld (UI_DrawScratch:16), a                                   ; F91A13  f1 40 26 41
	ld XIY,C0mbinati0nM0de_DrawPart8Sound_DL                                     ; F91A17  45 11 99 f2 00
	ld XIX,C0mbinati0nM0de_DrawPart1Int_DL                                     ; F91A1C  44 2e 99 f2 00
	call T_DisplayListB_Run                              ; F91A21  1d f4 17 f4
	ret                                                  ; F91A25  0e
; C0mbinati0nM0de_DrawPart1Int -- COMBINATION MODE page 2, INT row, column PT1: draws part 1's INT flag as a two-position indicator
; Evidence: entry [0] of FieldRedrawPtrs_F91885 (bit 0 of (0x267A), run by sub_F917F4 from the page-2 field repaint sub_F91725).
; Runs C0mbinati0nM0de_DrawPart1Int_DL (interpreter B, two op-03 records): (0x76AF) AND 0x20 >> 5 indexes DLTable_F29944 for an swi 0x1B (LCD_Svc_1B_EraseRect) and the other table for an swi 0x05 (LCD_Svc_05_FillRect) -- one box up, one box down.
; 0x76AF is +0x0D of part record 1 (0x76A2); bit 5 is the bit C0mbinati0nM0de_SetPartInt sets and clears. The row is labelled "INT" at (0x0D,0x49) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart1Int:   ; entry: named by 1 `.long` operand, first at 0xF91885
	ld XIY,C0mbinati0nM0de_DrawPart1Int_DL                                     ; F91A26  45 2e 99 f2 00
	ld XIX,DLTable_F29944                                ; F91A2B  44 44 99 f2 00
	call T_DisplayListB_Run                              ; F91A30  1d f4 17 f4
	ret                                                  ; F91A34  0e
; C0mbinati0nM0de_DrawPart2Int -- COMBINATION MODE page 2, INT row, column PT2: draws part 2's INT flag as a two-position indicator
; Evidence: entry [1] of FieldRedrawPtrs_F91885 (bit 1 of (0x267A), run by sub_F917F4 from the page-2 field repaint sub_F91725).
; Runs C0mbinati0nM0de_DrawPart2Int_DL (interpreter B, two op-03 records): (0x76EF) AND 0x20 >> 5 indexes DLTable_F2997A for an swi 0x1B (LCD_Svc_1B_EraseRect) and the other table for an swi 0x05 (LCD_Svc_05_FillRect) -- one box up, one box down.
; 0x76EF is +0x0D of part record 2 (0x76E2); bit 5 is the bit C0mbinati0nM0de_SetPartInt sets and clears. The row is labelled "INT" at (0x0D,0x49) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart2Int:   ; entry: named by 1 `.long` operand, first at 0xF91889
	ld XIY,C0mbinati0nM0de_DrawPart2Int_DL                                     ; F91A35  45 64 99 f2 00
	ld XIX,DLTable_F2997A                                ; F91A3A  44 7a 99 f2 00
	call T_DisplayListB_Run                              ; F91A3F  1d f4 17 f4
	ret                                                  ; F91A43  0e
; C0mbinati0nM0de_DrawPart3Int -- COMBINATION MODE page 2, INT row, column PT3: draws part 3's INT flag as a two-position indicator
; Evidence: entry [2] of FieldRedrawPtrs_F91885 (bit 2 of (0x267A), run by sub_F917F4 from the page-2 field repaint sub_F91725).
; Runs C0mbinati0nM0de_DrawPart3Int_DL (interpreter B, two op-03 records): (0x772F) AND 0x20 >> 5 indexes DLTable_F299B0 for an swi 0x1B (LCD_Svc_1B_EraseRect) and the other table for an swi 0x05 (LCD_Svc_05_FillRect) -- one box up, one box down.
; 0x772F is +0x0D of part record 3 (0x7722); bit 5 is the bit C0mbinati0nM0de_SetPartInt sets and clears. The row is labelled "INT" at (0x0D,0x49) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart3Int:   ; entry: named by 1 `.long` operand, first at 0xF9188D
	ld XIY,C0mbinati0nM0de_DrawPart3Int_DL                                     ; F91A44  45 9a 99 f2 00
	ld XIX,DLTable_F299B0                                ; F91A49  44 b0 99 f2 00
	call T_DisplayListB_Run                              ; F91A4E  1d f4 17 f4
	ret                                                  ; F91A52  0e
; C0mbinati0nM0de_DrawPart4Int -- COMBINATION MODE page 2, INT row, column PT4: draws part 4's INT flag as a two-position indicator
; Evidence: entry [3] of FieldRedrawPtrs_F91885 (bit 3 of (0x267A), run by sub_F917F4 from the page-2 field repaint sub_F91725).
; Runs C0mbinati0nM0de_DrawPart4Int_DL (interpreter B, two op-03 records): (0x776F) AND 0x20 >> 5 indexes DLTable_F299E6 for an swi 0x1B (LCD_Svc_1B_EraseRect) and the other table for an swi 0x05 (LCD_Svc_05_FillRect) -- one box up, one box down.
; 0x776F is +0x0D of part record 4 (0x7762); bit 5 is the bit C0mbinati0nM0de_SetPartInt sets and clears. The row is labelled "INT" at (0x0D,0x49) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart4Int:   ; entry: named by 1 `.long` operand, first at 0xF91891
	ld XIY,C0mbinati0nM0de_DrawPart4Int_DL                                     ; F91A53  45 d0 99 f2 00
	ld XIX,DLTable_F299E6                                ; F91A58  44 e6 99 f2 00
	call T_DisplayListB_Run                              ; F91A5D  1d f4 17 f4
	ret                                                  ; F91A61  0e
; C0mbinati0nM0de_DrawPart5Int -- COMBINATION MODE page 2, INT row, column PT5: draws part 5's INT flag as a two-position indicator
; Evidence: entry [4] of FieldRedrawPtrs_F91885 (bit 4 of (0x267A), run by sub_F917F4 from the page-2 field repaint sub_F91725).
; Runs C0mbinati0nM0de_DrawPart5Int_DL (interpreter B, two op-03 records): (0x77AF) AND 0x20 >> 5 indexes DLTable_F29A1C for an swi 0x1B (LCD_Svc_1B_EraseRect) and the other table for an swi 0x05 (LCD_Svc_05_FillRect) -- one box up, one box down.
; 0x77AF is +0x0D of part record 5 (0x77A2); bit 5 is the bit C0mbinati0nM0de_SetPartInt sets and clears. The row is labelled "INT" at (0x0D,0x49) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart5Int:   ; entry: named by 1 `.long` operand, first at 0xF91895
	ld XIY,C0mbinati0nM0de_DrawPart5Int_DL                                     ; F91A62  45 06 9a f2 00
	ld XIX,DLTable_F29A1C                                ; F91A67  44 1c 9a f2 00
	call T_DisplayListB_Run                              ; F91A6C  1d f4 17 f4
	ret                                                  ; F91A70  0e
; C0mbinati0nM0de_DrawPart6Int -- COMBINATION MODE page 2, INT row, column PT6: draws part 6's INT flag as a two-position indicator
; Evidence: entry [5] of FieldRedrawPtrs_F91885 (bit 5 of (0x267A), run by sub_F917F4 from the page-2 field repaint sub_F91725).
; Runs C0mbinati0nM0de_DrawPart6Int_DL (interpreter B, two op-03 records): (0x77EF) AND 0x20 >> 5 indexes DLTable_F29A52 for an swi 0x1B (LCD_Svc_1B_EraseRect) and the other table for an swi 0x05 (LCD_Svc_05_FillRect) -- one box up, one box down.
; 0x77EF is +0x0D of part record 6 (0x77E2); bit 5 is the bit C0mbinati0nM0de_SetPartInt sets and clears. The row is labelled "INT" at (0x0D,0x49) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart6Int:   ; entry: named by 1 `.long` operand, first at 0xF91899
	ld XIY,C0mbinati0nM0de_DrawPart6Int_DL                                     ; F91A71  45 3c 9a f2 00
	ld XIX,DLTable_F29A52                                ; F91A76  44 52 9a f2 00
	call T_DisplayListB_Run                              ; F91A7B  1d f4 17 f4
	ret                                                  ; F91A7F  0e
; C0mbinati0nM0de_DrawPart7Int -- COMBINATION MODE page 2, INT row, column PT7: draws part 7's INT flag as a two-position indicator
; Evidence: entry [6] of FieldRedrawPtrs_F91885 (bit 6 of (0x267A), run by sub_F917F4 from the page-2 field repaint sub_F91725).
; Runs C0mbinati0nM0de_DrawPart7Int_DL (interpreter B, two op-03 records): (0x782F) AND 0x20 >> 5 indexes DLTable_F29A88 for an swi 0x1B (LCD_Svc_1B_EraseRect) and the other table for an swi 0x05 (LCD_Svc_05_FillRect) -- one box up, one box down.
; 0x782F is +0x0D of part record 7 (0x7822); bit 5 is the bit C0mbinati0nM0de_SetPartInt sets and clears. The row is labelled "INT" at (0x0D,0x49) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart7Int:   ; entry: named by 1 `.long` operand, first at 0xF9189D
	ld XIY,C0mbinati0nM0de_DrawPart7Int_DL                                     ; F91A80  45 72 9a f2 00
	ld XIX,DLTable_F29A88                                ; F91A85  44 88 9a f2 00
	call T_DisplayListB_Run                              ; F91A8A  1d f4 17 f4
	ret                                                  ; F91A8E  0e
; C0mbinati0nM0de_DrawPart8Int -- COMBINATION MODE page 2, INT row, column PT8: draws part 8's INT flag as a two-position indicator
; Evidence: entry [7] of FieldRedrawPtrs_F91885 (bit 7 of (0x267A), run by sub_F917F4 from the page-2 field repaint sub_F91725).
; Runs C0mbinati0nM0de_DrawPart8Int_DL (interpreter B, two op-03 records): (0x786F) AND 0x20 >> 5 indexes DLTable_F29ABE for an swi 0x1B (LCD_Svc_1B_EraseRect) and the other table for an swi 0x05 (LCD_Svc_05_FillRect) -- one box up, one box down.
; 0x786F is +0x0D of part record 8 (0x7862); bit 5 is the bit C0mbinati0nM0de_SetPartInt sets and clears. The row is labelled "INT" at (0x0D,0x49) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart8Int:   ; entry: named by 1 `.long` operand, first at 0xF918A1
	ld XIY,C0mbinati0nM0de_DrawPart8Int_DL                                     ; F91A8F  45 a8 9a f2 00
	ld XIX,DLTable_F29ABE                                ; F91A94  44 be 9a f2 00
	call T_DisplayListB_Run                              ; F91A99  1d f4 17 f4
	ret                                                  ; F91A9D  0e
; C0mbinati0nM0de_DrawPart1Pan -- COMBINATION MODE page 2, PAN row, column PT1: draws part 1's pan as text and as a 24x24 knob glyph
; Evidence: entry [0] of FieldRedrawPtrs_F918A5 (bit 0 of (0x267B)); on layer (0x2540) = 2 runs C0mbinati0nM0de_DrawPart1Pan_DL (interpreter B): (0x76AA) AND 0x7F through DLText_PanL64CtrR63 at (0x00A,0x7B);
; then L = (0x76AA) AND 0x7F, IX = 0x1451, call T_DrawValueGlyph_24x24.
; 0x76AA is +0x08 of part record 1, the byte C0mbinati0nM0de_StepPartPan steps; the row is labelled "PAN" at (0x0D,0x70) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart1Pan:   ; entry: named by 1 `.long` operand, first at 0xF918A5
	ld (LCD_CurrentLayer:16), 0x02                                 ; F91A9E  f1 40 25 00 02
	ld XIY,C0mbinati0nM0de_DrawPart1Pan_DL                                     ; F91AA3  45 de 9a f2 00
	ld XIX,C0mbinati0nM0de_DrawPart2Pan_DL                                     ; F91AA8  44 ef 9a f2 00
	call T_DisplayListB_Run                              ; F91AAD  1d f4 17 f4
	ld l, (CombiPart_Pan:16)                                   ; F91AB1  c1 aa 76 27
	and L,0x7f                                           ; F91AB5  cf cc 7f
	ldw ix, 0x1451                                       ; F91AB8  34 51 14
	call T_DrawValueGlyph_24x24                          ; F91ABB  1d 34 18 f4
	ret                                                  ; F91ABF  0e
; C0mbinati0nM0de_DrawPart2Pan -- COMBINATION MODE page 2, PAN row, column PT2: draws part 2's pan as text and as a 24x24 knob glyph
; Evidence: entry [1] of FieldRedrawPtrs_F918A5 (bit 1 of (0x267B)); on layer (0x2540) = 2 runs C0mbinati0nM0de_DrawPart2Pan_DL (interpreter B): (0x76EA) AND 0x7F through DLText_PanL64CtrR63 at (0x032,0x7B);
; then L = (0x76EA) AND 0x7F, IX = 0x1456, call T_DrawValueGlyph_24x24.
; 0x76EA is +0x08 of part record 2, the byte C0mbinati0nM0de_StepPartPan steps; the row is labelled "PAN" at (0x0D,0x70) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart2Pan:   ; entry: named by 1 `.long` operand, first at 0xF918A9
	ld (LCD_CurrentLayer:16), 0x02                                 ; F91AC0  f1 40 25 00 02
	ld XIY,C0mbinati0nM0de_DrawPart2Pan_DL                                     ; F91AC5  45 ef 9a f2 00
	ld XIX,C0mbinati0nM0de_DrawPart3Pan_DL                                     ; F91ACA  44 00 9b f2 00
	call T_DisplayListB_Run                              ; F91ACF  1d f4 17 f4
	ld l, (CombiPart_Pan+1*0x40:16)                                   ; F91AD3  c1 ea 76 27
	and L,0x7f                                           ; F91AD7  cf cc 7f
	ldw ix, 0x1456                                       ; F91ADA  34 56 14
	call T_DrawValueGlyph_24x24                          ; F91ADD  1d 34 18 f4
	ret                                                  ; F91AE1  0e
; C0mbinati0nM0de_DrawPart3Pan -- COMBINATION MODE page 2, PAN row, column PT3: draws part 3's pan as text and as a 24x24 knob glyph
; Evidence: entry [2] of FieldRedrawPtrs_F918A5 (bit 2 of (0x267B)); on layer (0x2540) = 2 runs C0mbinati0nM0de_DrawPart3Pan_DL (interpreter B): (0x772A) AND 0x7F through DLText_PanL64CtrR63 at (0x05A,0x7B);
; then L = (0x772A) AND 0x7F, IX = 0x145B, call T_DrawValueGlyph_24x24.
; 0x772A is +0x08 of part record 3, the byte C0mbinati0nM0de_StepPartPan steps; the row is labelled "PAN" at (0x0D,0x70) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart3Pan:   ; entry: named by 1 `.long` operand, first at 0xF918AD
	ld (LCD_CurrentLayer:16), 0x02                                 ; F91AE2  f1 40 25 00 02
	ld XIY,C0mbinati0nM0de_DrawPart3Pan_DL                                     ; F91AE7  45 00 9b f2 00
	ld XIX,C0mbinati0nM0de_DrawPart4Pan_DL                                     ; F91AEC  44 11 9b f2 00
	call T_DisplayListB_Run                              ; F91AF1  1d f4 17 f4
	ld l, (CombiPart_Pan+2*0x40:16)                                   ; F91AF5  c1 2a 77 27
	and L,0x7f                                           ; F91AF9  cf cc 7f
	ldw ix, 0x145b                                       ; F91AFC  34 5b 14
	call T_DrawValueGlyph_24x24                          ; F91AFF  1d 34 18 f4
	ret                                                  ; F91B03  0e
; C0mbinati0nM0de_DrawPart4Pan -- COMBINATION MODE page 2, PAN row, column PT4: draws part 4's pan as text and as a 24x24 knob glyph
; Evidence: entry [3] of FieldRedrawPtrs_F918A5 (bit 3 of (0x267B)); on layer (0x2540) = 2 runs C0mbinati0nM0de_DrawPart4Pan_DL (interpreter B): (0x776A) AND 0x7F through DLText_PanL64CtrR63 at (0x082,0x7B);
; then L = (0x776A) AND 0x7F, IX = 0x1460, call T_DrawValueGlyph_24x24.
; 0x776A is +0x08 of part record 4, the byte C0mbinati0nM0de_StepPartPan steps; the row is labelled "PAN" at (0x0D,0x70) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart4Pan:   ; entry: named by 1 `.long` operand, first at 0xF918B1
	ld (LCD_CurrentLayer:16), 0x02                                 ; F91B04  f1 40 25 00 02
	ld XIY,C0mbinati0nM0de_DrawPart4Pan_DL                                     ; F91B09  45 11 9b f2 00
	ld XIX,C0mbinati0nM0de_DrawPart5Pan_DL                                     ; F91B0E  44 22 9b f2 00
	call T_DisplayListB_Run                              ; F91B13  1d f4 17 f4
	ld l, (CombiPart_Pan+3*0x40:16)                                   ; F91B17  c1 6a 77 27
	and L,0x7f                                           ; F91B1B  cf cc 7f
	ldw ix, 0x1460                                       ; F91B1E  34 60 14
	call T_DrawValueGlyph_24x24                          ; F91B21  1d 34 18 f4
	ret                                                  ; F91B25  0e
; C0mbinati0nM0de_DrawPart5Pan -- COMBINATION MODE page 2, PAN row, column PT5: draws part 5's pan as text and as a 24x24 knob glyph
; Evidence: entry [4] of FieldRedrawPtrs_F918A5 (bit 4 of (0x267B)); on layer (0x2540) = 2 runs C0mbinati0nM0de_DrawPart5Pan_DL (interpreter B): (0x77AA) AND 0x7F through DLText_PanL64CtrR63 at (0x0AA,0x7B);
; then L = (0x77AA) AND 0x7F, IX = 0x1465, call T_DrawValueGlyph_24x24.
; 0x77AA is +0x08 of part record 5, the byte C0mbinati0nM0de_StepPartPan steps; the row is labelled "PAN" at (0x0D,0x70) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart5Pan:   ; entry: named by 1 `.long` operand, first at 0xF918B5
	ld (LCD_CurrentLayer:16), 0x02                                 ; F91B26  f1 40 25 00 02
	ld XIY,C0mbinati0nM0de_DrawPart5Pan_DL                                     ; F91B2B  45 22 9b f2 00
	ld XIX,C0mbinati0nM0de_DrawPart6Pan_DL                                     ; F91B30  44 33 9b f2 00
	call T_DisplayListB_Run                              ; F91B35  1d f4 17 f4
	ld l, (CombiPart_Pan+4*0x40:16)                                   ; F91B39  c1 aa 77 27
	and L,0x7f                                           ; F91B3D  cf cc 7f
	ldw ix, 0x1465                                       ; F91B40  34 65 14
	call T_DrawValueGlyph_24x24                          ; F91B43  1d 34 18 f4
	ret                                                  ; F91B47  0e
; C0mbinati0nM0de_DrawPart6Pan -- COMBINATION MODE page 2, PAN row, column PT6: draws part 6's pan as text and as a 24x24 knob glyph
; Evidence: entry [5] of FieldRedrawPtrs_F918A5 (bit 5 of (0x267B)); on layer (0x2540) = 2 runs C0mbinati0nM0de_DrawPart6Pan_DL (interpreter B): (0x77EA) AND 0x7F through DLText_PanL64CtrR63 at (0x0D2,0x7B);
; then L = (0x77EA) AND 0x7F, IX = 0x146A, call T_DrawValueGlyph_24x24.
; 0x77EA is +0x08 of part record 6, the byte C0mbinati0nM0de_StepPartPan steps; the row is labelled "PAN" at (0x0D,0x70) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart6Pan:   ; entry: named by 1 `.long` operand, first at 0xF918B9
	ld (LCD_CurrentLayer:16), 0x02                                 ; F91B48  f1 40 25 00 02
	ld XIY,C0mbinati0nM0de_DrawPart6Pan_DL                                     ; F91B4D  45 33 9b f2 00
	ld XIX,C0mbinati0nM0de_DrawPart7Pan_DL                                     ; F91B52  44 44 9b f2 00
	call T_DisplayListB_Run                              ; F91B57  1d f4 17 f4
	ld l, (CombiPart_Pan+5*0x40:16)                                   ; F91B5B  c1 ea 77 27
	and L,0x7f                                           ; F91B5F  cf cc 7f
	ldw ix, 0x146a                                       ; F91B62  34 6a 14
	call T_DrawValueGlyph_24x24                          ; F91B65  1d 34 18 f4
	ret                                                  ; F91B69  0e
; C0mbinati0nM0de_DrawPart7Pan -- COMBINATION MODE page 2, PAN row, column PT7: draws part 7's pan as text and as a 24x24 knob glyph
; Evidence: entry [6] of FieldRedrawPtrs_F918A5 (bit 6 of (0x267B)); on layer (0x2540) = 2 runs C0mbinati0nM0de_DrawPart7Pan_DL (interpreter B): (0x782A) AND 0x7F through DLText_PanL64CtrR63 at (0x0FA,0x7B);
; then L = (0x782A) AND 0x7F, IX = 0x146F, call T_DrawValueGlyph_24x24.
; 0x782A is +0x08 of part record 7, the byte C0mbinati0nM0de_StepPartPan steps; the row is labelled "PAN" at (0x0D,0x70) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart7Pan:   ; entry: named by 1 `.long` operand, first at 0xF918BD
	ld (LCD_CurrentLayer:16), 0x02                                 ; F91B6A  f1 40 25 00 02
	ld XIY,C0mbinati0nM0de_DrawPart7Pan_DL                                     ; F91B6F  45 44 9b f2 00
	ld XIX,C0mbinati0nM0de_DrawPart8Pan_DL                                     ; F91B74  44 55 9b f2 00
	call T_DisplayListB_Run                              ; F91B79  1d f4 17 f4
	ld l, (CombiPart_Pan+6*0x40:16)                                   ; F91B7D  c1 2a 78 27
	and L,0x7f                                           ; F91B81  cf cc 7f
	ldw ix, 0x146f                                       ; F91B84  34 6f 14
	call T_DrawValueGlyph_24x24                          ; F91B87  1d 34 18 f4
	ret                                                  ; F91B8B  0e
; C0mbinati0nM0de_DrawPart8Pan -- COMBINATION MODE page 2, PAN row, column PT8: draws part 8's pan as text and as a 24x24 knob glyph
; Evidence: entry [7] of FieldRedrawPtrs_F918A5 (bit 7 of (0x267B)); on layer (0x2540) = 2 runs C0mbinati0nM0de_DrawPart8Pan_DL (interpreter B): (0x786A) AND 0x7F through DLText_PanL64CtrR63 at (0x122,0x7B);
; then L = (0x786A) AND 0x7F, IX = 0x1474, call T_DrawValueGlyph_24x24.
; 0x786A is +0x08 of part record 8, the byte C0mbinati0nM0de_StepPartPan steps; the row is labelled "PAN" at (0x0D,0x70) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart8Pan:   ; entry: named by 1 `.long` operand, first at 0xF918C1
	ld (LCD_CurrentLayer:16), 0x02                                 ; F91B8C  f1 40 25 00 02
	ld XIY,C0mbinati0nM0de_DrawPart8Pan_DL                                     ; F91B91  45 55 9b f2 00
	ld XIX,C0mbinati0nM0de_DrawPart1Vol_DL                                     ; F91B96  44 66 9b f2 00
	call T_DisplayListB_Run                              ; F91B9B  1d f4 17 f4
	ld l, (CombiPart_Pan+7*0x40:16)                                   ; F91B9F  c1 6a 78 27
	and L,0x7f                                           ; F91BA3  cf cc 7f
	ldw ix, 0x1474                                       ; F91BA6  34 74 14
	call T_DrawValueGlyph_24x24                          ; F91BA9  1d 34 18 f4
	ret                                                  ; F91BAD  0e
; C0mbinati0nM0de_DrawPart1Vol -- COMBINATION MODE page 2, VOL row, column PT1: draws part 1's volume as 3 digits and as a level bitmap
; Evidence: entry [0] of FieldRedrawPtrs_F918C5 (bit 0 of (0x267C)); runs C0mbinati0nM0de_DrawPart1Vol_DL (interpreter B: (0x76A5) AND 0x7F as 3 decimal digits at (0x00A,0xA7));
; then A = (0x76A5), IX = 0x1BA8, call LCD_BlitValueBar, which blits (swi 3, 5 bytes x 0x2E rows) entry A/8+1 (entry 0 for A = 0) of the 17-entry bitmap pointer table at 0xF29BC6.
; 0x76A5 is +0x03 of part record 1, the byte C0mbinati0nM0de_StepPartVol steps; the row is labelled "VOL" at (0x0D,0x9B) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart1Vol:   ; entry: named by 1 `.long` operand, first at 0xF918C5
	ld XIY,C0mbinati0nM0de_DrawPart1Vol_DL                                     ; F91BAE  45 66 9b f2 00
	ld XIX,C0mbinati0nM0de_DrawPart2Vol_DL                                     ; F91BB3  44 72 9b f2 00
	call T_DisplayListB_Run                              ; F91BB8  1d f4 17 f4
	ld a, (CombiPart_Volume:16)                                   ; F91BBC  c1 a5 76 21
	ldw ix, 0x1ba8                                       ; F91BC0  34 a8 1b
	call LCD_BlitValueBar                                        ; F91BC3  1d 8c 45 f9
	ret                                                  ; F91BC7  0e
; C0mbinati0nM0de_DrawPart2Vol -- COMBINATION MODE page 2, VOL row, column PT2: draws part 2's volume as 3 digits and as a level bitmap
; Evidence: entry [1] of FieldRedrawPtrs_F918C5 (bit 1 of (0x267C)); runs C0mbinati0nM0de_DrawPart2Vol_DL (interpreter B: (0x76E5) AND 0x7F as 3 decimal digits at (0x032,0xA7));
; then A = (0x76E5), IX = 0x1BAD, call LCD_BlitValueBar, which blits (swi 3, 5 bytes x 0x2E rows) entry A/8+1 (entry 0 for A = 0) of the 17-entry bitmap pointer table at 0xF29BC6.
; 0x76E5 is +0x03 of part record 2, the byte C0mbinati0nM0de_StepPartVol steps; the row is labelled "VOL" at (0x0D,0x9B) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart2Vol:   ; entry: named by 1 `.long` operand, first at 0xF918C9
	ld XIY,C0mbinati0nM0de_DrawPart2Vol_DL                                     ; F91BC8  45 72 9b f2 00
	ld XIX,C0mbinati0nM0de_DrawPart3Vol_DL                                     ; F91BCD  44 7e 9b f2 00
	call T_DisplayListB_Run                              ; F91BD2  1d f4 17 f4
	ld a, (CombiPart_Volume+1*0x40:16)                                   ; F91BD6  c1 e5 76 21
	ldw ix, 0x1bad                                       ; F91BDA  34 ad 1b
	call LCD_BlitValueBar                                        ; F91BDD  1d 8c 45 f9
	ret                                                  ; F91BE1  0e
; C0mbinati0nM0de_DrawPart3Vol -- COMBINATION MODE page 2, VOL row, column PT3: draws part 3's volume as 3 digits and as a level bitmap
; Evidence: entry [2] of FieldRedrawPtrs_F918C5 (bit 2 of (0x267C)); runs C0mbinati0nM0de_DrawPart3Vol_DL (interpreter B: (0x7725) AND 0x7F as 3 decimal digits at (0x05A,0xA7));
; then A = (0x7725), IX = 0x1BB2, call LCD_BlitValueBar, which blits (swi 3, 5 bytes x 0x2E rows) entry A/8+1 (entry 0 for A = 0) of the 17-entry bitmap pointer table at 0xF29BC6.
; 0x7725 is +0x03 of part record 3, the byte C0mbinati0nM0de_StepPartVol steps; the row is labelled "VOL" at (0x0D,0x9B) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart3Vol:   ; entry: named by 1 `.long` operand, first at 0xF918CD
	ld XIY,C0mbinati0nM0de_DrawPart3Vol_DL                                     ; F91BE2  45 7e 9b f2 00
	ld XIX,C0mbinati0nM0de_DrawPart4Vol_DL                                     ; F91BE7  44 8a 9b f2 00
	call T_DisplayListB_Run                              ; F91BEC  1d f4 17 f4
	ld a, (CombiPart_Volume+2*0x40:16)                                   ; F91BF0  c1 25 77 21
	ldw ix, 0x1bb2                                       ; F91BF4  34 b2 1b
	call LCD_BlitValueBar                                        ; F91BF7  1d 8c 45 f9
	ret                                                  ; F91BFB  0e
; C0mbinati0nM0de_DrawPart4Vol -- COMBINATION MODE page 2, VOL row, column PT4: draws part 4's volume as 3 digits and as a level bitmap
; Evidence: entry [3] of FieldRedrawPtrs_F918C5 (bit 3 of (0x267C)); runs C0mbinati0nM0de_DrawPart4Vol_DL (interpreter B: (0x7765) AND 0x7F as 3 decimal digits at (0x082,0xA7));
; then A = (0x7765), IX = 0x1BB7, call LCD_BlitValueBar, which blits (swi 3, 5 bytes x 0x2E rows) entry A/8+1 (entry 0 for A = 0) of the 17-entry bitmap pointer table at 0xF29BC6.
; 0x7765 is +0x03 of part record 4, the byte C0mbinati0nM0de_StepPartVol steps; the row is labelled "VOL" at (0x0D,0x9B) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart4Vol:   ; entry: named by 1 `.long` operand, first at 0xF918D1
	ld XIY,C0mbinati0nM0de_DrawPart4Vol_DL                                     ; F91BFC  45 8a 9b f2 00
	ld XIX,C0mbinati0nM0de_DrawPart5Vol_DL                                     ; F91C01  44 96 9b f2 00
	call T_DisplayListB_Run                              ; F91C06  1d f4 17 f4
	ld a, (CombiPart_Volume+3*0x40:16)                                   ; F91C0A  c1 65 77 21
	ldw ix, 0x1bb7                                       ; F91C0E  34 b7 1b
	call LCD_BlitValueBar                                        ; F91C11  1d 8c 45 f9
	ret                                                  ; F91C15  0e
; C0mbinati0nM0de_DrawPart5Vol -- COMBINATION MODE page 2, VOL row, column PT5: draws part 5's volume as 3 digits and as a level bitmap
; Evidence: entry [4] of FieldRedrawPtrs_F918C5 (bit 4 of (0x267C)); runs C0mbinati0nM0de_DrawPart5Vol_DL (interpreter B: (0x77A5) AND 0x7F as 3 decimal digits at (0x0AA,0xA7));
; then A = (0x77A5), IX = 0x1BBC, call LCD_BlitValueBar, which blits (swi 3, 5 bytes x 0x2E rows) entry A/8+1 (entry 0 for A = 0) of the 17-entry bitmap pointer table at 0xF29BC6.
; 0x77A5 is +0x03 of part record 5, the byte C0mbinati0nM0de_StepPartVol steps; the row is labelled "VOL" at (0x0D,0x9B) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart5Vol:   ; entry: named by 1 `.long` operand, first at 0xF918D5
	ld XIY,C0mbinati0nM0de_DrawPart5Vol_DL                                     ; F91C16  45 96 9b f2 00
	ld XIX,C0mbinati0nM0de_DrawPart6Vol_DL                                     ; F91C1B  44 a2 9b f2 00
	call T_DisplayListB_Run                              ; F91C20  1d f4 17 f4
	ld a, (CombiPart_Volume+4*0x40:16)                                   ; F91C24  c1 a5 77 21
	ldw ix, 0x1bbc                                       ; F91C28  34 bc 1b
	call LCD_BlitValueBar                                        ; F91C2B  1d 8c 45 f9
	ret                                                  ; F91C2F  0e
; C0mbinati0nM0de_DrawPart6Vol -- COMBINATION MODE page 2, VOL row, column PT6: draws part 6's volume as 3 digits and as a level bitmap
; Evidence: entry [5] of FieldRedrawPtrs_F918C5 (bit 5 of (0x267C)); runs C0mbinati0nM0de_DrawPart6Vol_DL (interpreter B: (0x77E5) AND 0x7F as 3 decimal digits at (0x0D2,0xA7));
; then A = (0x77E5), IX = 0x1BC1, call LCD_BlitValueBar, which blits (swi 3, 5 bytes x 0x2E rows) entry A/8+1 (entry 0 for A = 0) of the 17-entry bitmap pointer table at 0xF29BC6.
; 0x77E5 is +0x03 of part record 6, the byte C0mbinati0nM0de_StepPartVol steps; the row is labelled "VOL" at (0x0D,0x9B) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart6Vol:   ; entry: named by 1 `.long` operand, first at 0xF918D9
	ld XIY,C0mbinati0nM0de_DrawPart6Vol_DL                                     ; F91C30  45 a2 9b f2 00
	ld XIX,C0mbinati0nM0de_DrawPart7Vol_DL                                     ; F91C35  44 ae 9b f2 00
	call T_DisplayListB_Run                              ; F91C3A  1d f4 17 f4
	ld a, (CombiPart_Volume+5*0x40:16)                                   ; F91C3E  c1 e5 77 21
	ldw ix, 0x1bc1                                       ; F91C42  34 c1 1b
	call LCD_BlitValueBar                                        ; F91C45  1d 8c 45 f9
	ret                                                  ; F91C49  0e
; C0mbinati0nM0de_DrawPart7Vol -- COMBINATION MODE page 2, VOL row, column PT7: draws part 7's volume as 3 digits and as a level bitmap
; Evidence: entry [6] of FieldRedrawPtrs_F918C5 (bit 6 of (0x267C)); runs C0mbinati0nM0de_DrawPart7Vol_DL (interpreter B: (0x7825) AND 0x7F as 3 decimal digits at (0x0FA,0xA7));
; then A = (0x7825), IX = 0x1BC6, call LCD_BlitValueBar, which blits (swi 3, 5 bytes x 0x2E rows) entry A/8+1 (entry 0 for A = 0) of the 17-entry bitmap pointer table at 0xF29BC6.
; 0x7825 is +0x03 of part record 7, the byte C0mbinati0nM0de_StepPartVol steps; the row is labelled "VOL" at (0x0D,0x9B) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart7Vol:   ; entry: named by 1 `.long` operand, first at 0xF918DD
	ld XIY,C0mbinati0nM0de_DrawPart7Vol_DL                                     ; F91C4A  45 ae 9b f2 00
	ld XIX,C0mbinati0nM0de_DrawPart8Vol_DL                                     ; F91C4F  44 ba 9b f2 00
	call T_DisplayListB_Run                              ; F91C54  1d f4 17 f4
	ld a, (CombiPart_Volume+6*0x40:16)                                   ; F91C58  c1 25 78 21
	ldw ix, 0x1bc6                                       ; F91C5C  34 c6 1b
	call LCD_BlitValueBar                                        ; F91C5F  1d 8c 45 f9
	ret                                                  ; F91C63  0e
; C0mbinati0nM0de_DrawPart8Vol -- COMBINATION MODE page 2, VOL row, column PT8: draws part 8's volume as 3 digits and as a level bitmap
; Evidence: entry [7] of FieldRedrawPtrs_F918C5 (bit 7 of (0x267C)); runs C0mbinati0nM0de_DrawPart8Vol_DL (interpreter B: (0x7865) AND 0x7F as 3 decimal digits at (0x122,0xA7));
; then A = (0x7865), IX = 0x1BCB, call LCD_BlitValueBar, which blits (swi 3, 5 bytes x 0x2E rows) entry A/8+1 (entry 0 for A = 0) of the 17-entry bitmap pointer table at 0xF29BC6.
; 0x7865 is +0x03 of part record 8, the byte C0mbinati0nM0de_StepPartVol steps; the row is labelled "VOL" at (0x0D,0x9B) in DL_C0mbinati0nM0dePage22Sound.
C0mbinati0nM0de_DrawPart8Vol:   ; entry: named by 1 `.long` operand, first at 0xF918E1
	ld XIY,C0mbinati0nM0de_DrawPart8Vol_DL                                     ; F91C64  45 ba 9b f2 00
	ld XIX,0x00f29bc6                                    ; F91C69  44 c6 9b f2 00
	call T_DisplayListB_Run                              ; F91C6E  1d f4 17 f4
	ld a, (CombiPart_Volume+7*0x40:16)                                   ; F91C72  c1 65 78 21
	ldw ix, 0x1bcb                                       ; F91C76  34 cb 1b
	call LCD_BlitValueBar                                        ; F91C79  1d 8c 45 f9
	ret                                                  ; F91C7D  0e
; Paint_C0mbinati0nM0dePage1 -- paints COMBINATION MODE page 1: the lists whose text reads "PAGE1/2", "C0MBINATI0N M0DE", "OCT" "VOL" "PAN" "EFF1" "EFF2" "REV" "INT", "PART"
; Evidence: posted by sub_F915FB (`ld XWA,0x00F91C7E` at 0xF91653) only when (0x2687) == 0; clears with swi 0x0C (C=0) and swi 0x10, then (0xC4) != 2 runs Paint_C0mbinati0nM0dePage1_DL1..Paint_C0mbinati0nM0dePage1_DL3, (0xC4) == 2 runs Paint_C0mbinati0nM0dePage1_DL3..DL_C0mbinati0nM0dePage22Sound (layers 0 then 2).
; (0xC4) is the panel variant Variant_SetFromPB0 writes (2 = the SX-WSA1R). Afterwards marks every page-1 field dirty ((0x2676) |= 0xFF, (0x2677) |= 0x07), calls T_UiPaint_PageLabelBackdrop and ModeScreen_DrawGmModeGlyph.
; Page 2 ("PAGE2/2") is painted by sub_F916AA, the other arm of the same `cp (0x2687),0x00` in sub_F915FB.
Paint_C0mbinati0nM0dePage1:   ; entry: named by 1 `ld` operand, first at 0xF91653
	xor C,C                                              ; F91C7E  cb d3
	ld a, 0x0c:opc                                          ; F91C80  21 0c
	swi 7                                                ; F91C82  ff
	ld a, 0x10:opc                                          ; F91C83  21 10
	swi 7                                                ; F91C85  ff
	cp	(Variant_Flag:8), 0x02                               ; F91C86  c0 c4 3f 02
	jr z, .LF91CB4                                       ; F91C8A  66 28
	ld (LCD_CurrentLayer:16), 0x00                                 ; F91C8C  f1 40 25 00 00
	ld XIY,Paint_C0mbinati0nM0dePage1_DL1                                     ; F91C91  45 38 89 f2 00
	ld XIX,Paint_C0mbinati0nM0dePage1_DL2                                     ; F91C96  44 f3 8d f2 00
	call T_DisplayList_Run                               ; F91C9B  1d f0 17 f4
	ld (LCD_CurrentLayer:16), 0x02                                 ; F91C9F  f1 40 25 00 02
	ld XIY,Paint_C0mbinati0nM0dePage1_DL2                                     ; F91CA4  45 f3 8d f2 00
	ld XIX,Paint_C0mbinati0nM0dePage1_DL3                                     ; F91CA9  44 1b 8e f2 00
	call T_DisplayList_Run                               ; F91CAE  1d f0 17 f4
	jr .LF91CDA                                          ; F91CB2  68 26
.LF91CB4:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F91CB4  f1 40 25 00 00
	ld XIY,Paint_C0mbinati0nM0dePage1_DL3                                     ; F91CB9  45 1b 8e f2 00
	ld XIX,Paint_C0mbinati0nM0dePage1_DL4                                     ; F91CBE  44 21 91 f2 00
	call T_DisplayList_Run                               ; F91CC3  1d f0 17 f4
	ld (LCD_CurrentLayer:16), 0x02                                 ; F91CC7  f1 40 25 00 02
	ld XIY,Paint_C0mbinati0nM0dePage1_DL4                                     ; F91CCC  45 21 91 f2 00
	ld XIX,DL_C0mbinati0nM0dePage22Sound                 ; F91CD1  44 35 91 f2 00
	call T_DisplayList_Run                               ; F91CD6  1d f0 17 f4
.LF91CDA:
	or	(ModeScreen_DirtyFields:16), 0xff                            ; F91CDA  c1 76 26 3e ff
	or	(ModeScreen_DirtyFields2:16), 0x07                            ; F91CDF  c1 77 26 3e 07
	orw	(0x2116:16), 0x0044                  ; F91CE4  d1 16 21 3e 44 00
	call T_UiPaint_PageLabelBackdrop                                        ; F91CEA  1d 18 2e f4
	calr ModeScreen_DrawGmModeGlyph                                          ; F91CEE  1e c5 f4
	ret                                                  ; F91CF1  0e
; C0mbinati0nM0de_RepaintPage1Fields -- COMBINATION MODE page 1 field refresh: redraws the combination name and number, then every field of the selected part whose dirty bit is set
; Evidence: posted by sub_F9167C when (0x2687) == 0 (0xF91683) and by C0mbinati0nM0de_StepSelectedPart. Name: T_CombiName_Lookup (CombiName_Lookup, fallback Msg0716_Str_CombiName "Combi Name *****") drawn by swi 0x21 (LCD_Svc_21_DrawText16x24) at IX 0x09B4;
; number: bank code (0x7F0A) and ((0x7F08) << 3 | (0x7F09)) + 1 through DL_F29765 (DLText_PartCodes). Then, from the record of part (0x2250) (PartRecord_GetPtr), per bit of (0x2676): 0 +0x03, 1 +0x08 (pan text 0xF28468), 2 +0x05, 3 +0x07, 4 +0x0D, 7 +0x06 (0/1),
; 5 (0x2250) itself, 6 ((0x78B2) - 0x1C) / 12 -- the octave the OCT column's soft key edits. Then ModeScreen_PaintDirtyFields2 for (0x2677), clears (0x2676)/(0x2677), swi 0x0C with C = 7.
C0mbinati0nM0de_RepaintPage1Fields:   ; entry: named by 2 `ld` operands, first at 0xF91683
	ld (LCD_CurrentLayer:16), 0x00                                 ; F91CF2  f1 40 25 00 00
	ld a, (0x7f03:16)                                   ; F91CF7  c1 03 7f 21
	ld w, (0x7f04:16)                                   ; F91CFB  c1 04 7f 20
	ld b, 0x98:opc                                          ; F91CFF  22 98
	call T_CombiName_Lookup                                        ; F91D01  1d 2c 10 f4
	ldw bc, 0x10                                         ; F91D05  31 10 00
	xor HL,HL                                            ; F91D08  db d3
	ldw ix, 0x09b4                                       ; F91D0A  34 b4 09
	ld a, 0x21:opc                                          ; F91D0D  21 21
	swi 7                                                ; F91D0F  ff
	ld XIY,0x00007f02                                    ; F91D10  45 02 7f 00 00
	ld A,(XIY+0x08)                                      ; F91D15  8d 08 21
	and A,0xff                                           ; F91D18  c9 cc ff
	ld (UI_DrawScratch:16), a                                   ; F91D1B  f1 40 26 41
	ld A,(XIY+0x06)                                      ; F91D1F  8d 06 21
	and A,0xff                                           ; F91D22  c9 cc ff
	sll a, 0x03                                          ; F91D25  c9 ee 03
	ld W,(XIY+0x07)                                      ; F91D28  8d 07 20
	and W,0xff                                           ; F91D2B  c8 cc ff
	or A,W                                               ; F91D2E  c8 e1
	inc 1,A                                              ; F91D30  c9 61
	extz WA                                              ; F91D32  d8 12
	call T_Value_ToAsciiDigits3                          ; F91D34  1d 00 1b f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; F91D38  f1 40 25 00 00
	ld XIY,DL_F29765                                     ; F91D3D  45 65 97 f2 00
	ld XIX,Paint_C0mbinati0nM0dePage2Sound1_DL                                     ; F91D42  44 83 97 f2 00
	call T_DisplayListB_Run                              ; F91D47  1d f4 17 f4
	calr PartRecord_GetPtr                                          ; F91D4B  1e eb 27
	bit	0, (ModeScreen_DirtyFields:16)                               ; F91D4E  f1 76 26 c8
	jr z, .LF91D66                                       ; F91D52  66 12
	push XIY                                             ; F91D54  3d
	ld A,(XIY+0x03)                                      ; F91D55  8d 03 21
	ld (UI_DrawScratch:16), a                                   ; F91D58  f1 40 26 41
	ld XIY,0x00f2844f                                    ; F91D5C  45 4f 84 f2 00
	call T_DLB_Handler_Decimal2Words                                        ; F91D61  1d 0c 18 f4
	pop XIY                                              ; F91D65  5d
.LF91D66:
	bit	1, (ModeScreen_DirtyFields:16)                               ; F91D66  f1 76 26 c9
	jr z, .LF91D7E                                       ; F91D6A  66 12
	push XIY                                             ; F91D6C  3d
	ld A,(XIY+0x08)                                      ; F91D6D  8d 08 21
	ld (UI_DrawScratch+1:16), a                                   ; F91D70  f1 41 26 41
	ld XIY,0x00f28468                                    ; F91D74  45 68 84 f2 00
	call T_DLB_Handler_StringTable2                      ; F91D79  1d fc 17 f4
	pop XIY                                              ; F91D7D  5d
.LF91D7E:
	bit	2, (ModeScreen_DirtyFields:16)                               ; F91D7E  f1 76 26 ca
	jr z, .LF91D96                                       ; F91D82  66 12
	push XIY                                             ; F91D84  3d
	ld A,(XIY+0x05)                                      ; F91D85  8d 05 21
	ld (UI_DrawScratch+2:16), a                                   ; F91D88  f1 42 26 41
	ld XIY,0x00f28479                                    ; F91D8C  45 79 84 f2 00
	call T_DLB_Handler_Decimal2Words                                        ; F91D91  1d 0c 18 f4
	pop XIY                                              ; F91D95  5d
.LF91D96:
	bit	3, (ModeScreen_DirtyFields:16)                               ; F91D96  f1 76 26 cb
	jr z, .LF91DAE                                       ; F91D9A  66 12
	push XIY                                             ; F91D9C  3d
	ld A,(XIY+0x07)                                      ; F91D9D  8d 07 21
	ld (UI_DrawScratch+3:16), a                                   ; F91DA0  f1 43 26 41
	ld XIY,0x00f28485                                    ; F91DA4  45 85 84 f2 00
	call T_DLB_Handler_Decimal2Words                                        ; F91DA9  1d 0c 18 f4
	pop XIY                                              ; F91DAD  5d
.LF91DAE:
	bit	4, (ModeScreen_DirtyFields:16)                               ; F91DAE  f1 76 26 cc
	jr z, .LF91DC6                                       ; F91DB2  66 12
	push XIY                                             ; F91DB4  3d
	ld A,(XIY+0x0d)                                      ; F91DB5  8d 0d 21
	ld (UI_DrawScratch+4:16), a                                   ; F91DB8  f1 44 26 41
	ld XIY,DL_F286CB                                     ; F91DBC  45 cb 86 f2 00
	call T_DLB_Handler_StringTable2                      ; F91DC1  1d fc 17 f4
	pop XIY                                              ; F91DC5  5d
.LF91DC6:
	bit	5, (ModeScreen_DirtyFields:16)                               ; F91DC6  f1 76 26 cd
	jr z, .LF91DDF                                       ; F91DCA  66 13
	push XIY                                             ; F91DCC  3d
	ld a, (UI_PartIndex:16)                                   ; F91DCD  c1 50 22 21
	ld (UI_DrawScratch+5:16), a                                   ; F91DD1  f1 45 26 41
	ld XIY,C0mbinati0nM0de_RepaintPage1Fields_DL                                     ; F91DD5  45 a2 86 f2 00
	call T_DLB_Handler_StringTable2                      ; F91DDA  1d fc 17 f4
	pop XIY                                              ; F91DDE  5d
.LF91DDF:
	bit	7, (ModeScreen_DirtyFields:16)                               ; F91DDF  f1 76 26 cf
	jr z, .LF91E00                                       ; F91DE3  66 1b
	push XIY                                             ; F91DE5  3d
	ld A,(XIY+0x06)                                      ; F91DE6  8d 06 21
	and A,0x7f                                           ; F91DE9  c9 cc 7f
	cp a, 0x00:i3                                          ; F91DEC  c9 d8
	jr z, .LF91DF2                                       ; F91DEE  66 02
	ld a, 0x01:opc                                          ; F91DF0  21 01
.LF91DF2:
	ld (UI_DrawScratch+6:16), a                                   ; F91DF2  f1 46 26 41
	ld XIY,DL_F286E2                                     ; F91DF6  45 e2 86 f2 00
	call T_DLB_Handler_StringTable2                      ; F91DFB  1d fc 17 f4
	pop XIY                                              ; F91DFF  5d
.LF91E00:
	bit	6, (ModeScreen_DirtyFields:16)                               ; F91E00  f1 76 26 ce
	jr z, .LF91E29                                       ; F91E04  66 23
	push XIY                                             ; F91E06  3d
	ld XIY,0x000078b2                                    ; F91E07  45 b2 78 00 00
	ld	a, (xiy+0:8)                                 ; F91E0C  8d 00 21
	sub A,0x1c                                           ; F91E0F  c9 ca 1c
	extz WA                                              ; F91E12  d8 12
	cp wa, 0x00:i3                                         ; F91E14  d8 d8
	jr z, .LF91E1B                                       ; F91E16  66 03
	div A,0x0c                                           ; F91E18  c9 0a 0c
.LF91E1B:
	ld (UI_DrawScratch+7:16), a                                   ; F91E1B  f1 47 26 41
	ld XIY,0x00f287d1                                    ; F91E1F  45 d1 87 f2 00
	call T_DLB_Handler_StringTable2                      ; F91E24  1d fc 17 f4
	pop XIY                                              ; F91E28  5d
.LF91E29:
	calr ModeScreen_PaintDirtyFields2                                          ; F91E29  1e 73 f1
	ld (ModeScreen_DirtyFields:16), 0x00                                 ; F91E2C  f1 76 26 00 00
	ld (ModeScreen_DirtyFields2:16), 0x00                                 ; F91E31  f1 77 26 00 00
	ld c, 0x07:opc                                          ; F91E36  23 07
	ld a, 0x0c:opc                                          ; F91E38  21 0c
	swi 7                                                ; F91E3A  ff
	ret                                                  ; F91E3B  0e
; ScreenLeaveBody_C0mbinati0nM0de -- the whole body of the COMBINATION MODE screen's Leave method: switches SOLO off
; Evidence: called only by sub_F914DD, the +4 slot of screen object T_InstallPainter_C0mbinati0nM0de_Entry (PanelScreen_VtableTable_ViewB entry 2, screen id 2), whose +0 Enter sub_F914D9 -> sub_F915FB installs the "C0MBINATI0N M0DE" painters.
; Body: `and (0x267D),0xFE`, then push 0 / call T_NoteRouting_SetSoloAndRebuild (NoteRouting_SetSoloAndRebuild clears bit 5 of (0x602498)) -- the same pair LcdKeyRow1_C0mbinati0nM0de_Page2 uses for its SOLO-off arm.
ScreenLeaveBody_C0mbinati0nM0de:
	and	(CombinationMode_Solo:16), 0xfe                            ; F91E3C  c1 7d 26 3c fe
	ld a, 0x00:opc                                          ; F91E41  21 00
	push_a                                               ; F91E43  14
	call T_NoteRouting_SetSoloAndRebuild                                        ; F91E44  1d ec 11 f4
	inc 1,XSP                                            ; F91E48  ef 61
	ret                                                  ; F91E4A  0e
; SoftKeyCol1_C0mbinati0nM0de_Page2 -- SOFT KEY column 1 on COMBINATION MODE page 2: select part 1, or step its value if it is already selected
; Evidence: slot [0] of DisplayListPtrs_F9157B, the table sub_F914E1 (screen 2's +8 Button method) hands to T_PanelButton_CallTableEntry when (0x2687) != 0 -- page 2, painted by sub_F916AA ("PAGE2/2", columns PT1..PT8). Code 0 is SOFT KEY col 1 (notes/FINDINGS-prom_a-panel-control-map.md).
; Body: sets the step magnitude in W to 1 (3 when (0x2075) bit 2 is set) -- the field T_Value_ApplyNibbleDeltaClamped reads, with bit 7 as the sign -- then falls into C0mbinati0nM0de_SelectOrEditPart1.
SoftKeyCol1_C0mbinati0nM0de_Page2:   ; entry: named by 1 `.long` operand, first at 0xF9157B
	inc 1,W                                              ; F91E4B  c8 61
	bit	2, (UI_RequestBits:16)                               ; F91E4D  f1 75 20 ca
	jr z, SoftKeyCol1_C0mbinati0nM0de_Page2_Join                                     ; F91E51  66 02
	inc 2,W                                              ; F91E53  c8 62
SoftKeyCol1_C0mbinati0nM0de_Page2_Join:
	cp	(UI_PartIndex:16), 0x00                            ; F91E55  c1 50 22 3f 00
	jr z, .LF91E9A                                       ; F91E5A  66 3e
	bit	2, (UI_RequestBits:16)                               ; F91E5C  f1 75 20 ca
	jr z, .LF91E67                                       ; F91E60  66 05
	and	(UI_RequestBits:16), 0xf7                            ; F91E62  c1 75 20 3c f7
.LF91E67:
	ldw (PanelDial_DownButton:16), 0x80                                ; F91E67  f1 9b 20 02 80 00
	or	(UI_RequestBits:16), 0x09                            ; F91E6D  c1 75 20 3e 09
	ld a, 0x00:opc                                          ; F91E72  21 00
	ld (UI_PartIndex:16), a                                   ; F91E74  f1 50 22 41
	ld e, 0x90:opc                                          ; F91E78  25 90
	ld d, 0x10:opc                                          ; F91E7A  24 10
	ld w, 0xff:opc                                          ; F91E7C  20 ff
	call T_Queue2E00_AppendRegs                          ; F91E7E  1d 3c 0f f4
	call T_NoteRouting_Rebuild                                        ; F91E82  1d bc 11 f4
	ld XWA,C0mbinati0nM0de_ShowSelectedPartSoundName                                    ; F91E86  40 e5 18 f9 00
	push XWA                                             ; F91E8B  38
	call T_CallbackQueue_Post                            ; F91E8C  1d 84 2e f4
	inc 4,XSP                                            ; F91E90  ef 64
	ld a, 0x01:opc                                          ; F91E92  21 01
	call T_Kernel_SemaSignal                             ; F91E94  1d 88 2d f4
	jr .LF91EA8                                          ; F91E98  68 0e
.LF91E9A:
	ldw (PanelDial_DownButton:16), 0x80                                ; F91E9A  f1 9b 20 02 80 00
	or	(UI_RequestBits:16), 0x09                            ; F91EA0  c1 75 20 3e 09
	calr C0mbinati0nM0de_EditSelectedRow                                      ; F91EA5  1e 44 05
.LF91EA8:
	ret                                                  ; F91EA8  0e
; SoftKeyCol2_C0mbinati0nM0de_Page2 -- SOFT KEY column 2 on COMBINATION MODE page 2: select part 2, or step its value if it is already selected
; Evidence: slot [1] of DisplayListPtrs_F9157B, the table sub_F914E1 (screen 2's +8 Button method) hands to T_PanelButton_CallTableEntry when (0x2687) != 0 -- page 2, painted by sub_F916AA ("PAGE2/2", columns PT1..PT8). Code 1 is SOFT KEY col 2 (notes/FINDINGS-prom_a-panel-control-map.md).
; Body: sets the step magnitude in W to 1 (3 when (0x2075) bit 2 is set) -- the field T_Value_ApplyNibbleDeltaClamped reads, with bit 7 as the sign -- then falls into C0mbinati0nM0de_SelectOrEditPart2.
SoftKeyCol2_C0mbinati0nM0de_Page2:   ; entry: named by 1 `.long` operand, first at 0xF9157F
	inc 1,W                                              ; F91EA9  c8 61
	bit	2, (UI_RequestBits:16)                               ; F91EAB  f1 75 20 ca
	jr z, SoftKeyCol2_C0mbinati0nM0de_Page2_Join                                     ; F91EAF  66 02
	inc 2,W                                              ; F91EB1  c8 62
SoftKeyCol2_C0mbinati0nM0de_Page2_Join:
	cp	(UI_PartIndex:16), 0x01                            ; F91EB3  c1 50 22 3f 01
	jr z, .LF91EF8                                       ; F91EB8  66 3e
	bit	2, (UI_RequestBits:16)                               ; F91EBA  f1 75 20 ca
	jr z, .LF91EC5                                       ; F91EBE  66 05
	and	(UI_RequestBits:16), 0xf7                            ; F91EC0  c1 75 20 3c f7
.LF91EC5:
	ldw (PanelDial_DownButton:16), 0x0181                              ; F91EC5  f1 9b 20 02 81 01
	or	(UI_RequestBits:16), 0x09                            ; F91ECB  c1 75 20 3e 09
	ld a, 0x01:opc                                          ; F91ED0  21 01
	ld (UI_PartIndex:16), a                                   ; F91ED2  f1 50 22 41
	ld e, 0x90:opc                                          ; F91ED6  25 90
	ld d, 0x10:opc                                          ; F91ED8  24 10
	ld w, 0xff:opc                                          ; F91EDA  20 ff
	call T_Queue2E00_AppendRegs                          ; F91EDC  1d 3c 0f f4
	call T_NoteRouting_Rebuild                                        ; F91EE0  1d bc 11 f4
	ld XWA,C0mbinati0nM0de_ShowSelectedPartSoundName                                    ; F91EE4  40 e5 18 f9 00
	push XWA                                             ; F91EE9  38
	call T_CallbackQueue_Post                            ; F91EEA  1d 84 2e f4
	inc 4,XSP                                            ; F91EEE  ef 64
	ld a, 0x01:opc                                          ; F91EF0  21 01
	call T_Kernel_SemaSignal                             ; F91EF2  1d 88 2d f4
	jr .LF91F06                                          ; F91EF6  68 0e
.LF91EF8:
	ldw (PanelDial_DownButton:16), 0x0181                              ; F91EF8  f1 9b 20 02 81 01
	or	(UI_RequestBits:16), 0x09                            ; F91EFE  c1 75 20 3e 09
	calr C0mbinati0nM0de_EditSelectedRow                                      ; F91F03  1e e6 04
.LF91F06:
	ret                                                  ; F91F06  0e
; SoftKeyCol3_C0mbinati0nM0de_Page2 -- SOFT KEY column 3 on COMBINATION MODE page 2: select part 3, or step its value if it is already selected
; Evidence: slot [2] of DisplayListPtrs_F9157B, the table sub_F914E1 (screen 2's +8 Button method) hands to T_PanelButton_CallTableEntry when (0x2687) != 0 -- page 2, painted by sub_F916AA ("PAGE2/2", columns PT1..PT8). Code 2 is SOFT KEY col 3 (notes/FINDINGS-prom_a-panel-control-map.md).
; Body: sets the step magnitude in W to 1 (3 when (0x2075) bit 2 is set) -- the field T_Value_ApplyNibbleDeltaClamped reads, with bit 7 as the sign -- then falls into C0mbinati0nM0de_SelectOrEditPart3.
SoftKeyCol3_C0mbinati0nM0de_Page2:   ; entry: named by 1 `.long` operand, first at 0xF91583
	inc 1,W                                              ; F91F07  c8 61
	bit	2, (UI_RequestBits:16)                               ; F91F09  f1 75 20 ca
	jr z, SoftKeyCol3_C0mbinati0nM0de_Page2_Join                                     ; F91F0D  66 02
	inc 2,W                                              ; F91F0F  c8 62
SoftKeyCol3_C0mbinati0nM0de_Page2_Join:
	cp	(UI_PartIndex:16), 0x02                            ; F91F11  c1 50 22 3f 02
	jr z, .LF91F56                                       ; F91F16  66 3e
	bit	2, (UI_RequestBits:16)                               ; F91F18  f1 75 20 ca
	jr z, .LF91F23                                       ; F91F1C  66 05
	and	(UI_RequestBits:16), 0xf7                            ; F91F1E  c1 75 20 3c f7
.LF91F23:
	ldw (PanelDial_DownButton:16), 0x0282                              ; F91F23  f1 9b 20 02 82 02
	or	(UI_RequestBits:16), 0x09                            ; F91F29  c1 75 20 3e 09
	ld a, 0x02:opc                                          ; F91F2E  21 02
	ld (UI_PartIndex:16), a                                   ; F91F30  f1 50 22 41
	ld e, 0x90:opc                                          ; F91F34  25 90
	ld d, 0x10:opc                                          ; F91F36  24 10
	ld w, 0xff:opc                                          ; F91F38  20 ff
	call T_Queue2E00_AppendRegs                          ; F91F3A  1d 3c 0f f4
	call T_NoteRouting_Rebuild                                        ; F91F3E  1d bc 11 f4
	ld XWA,C0mbinati0nM0de_ShowSelectedPartSoundName                                    ; F91F42  40 e5 18 f9 00
	push XWA                                             ; F91F47  38
	call T_CallbackQueue_Post                            ; F91F48  1d 84 2e f4
	inc 4,XSP                                            ; F91F4C  ef 64
	ld a, 0x01:opc                                          ; F91F4E  21 01
	call T_Kernel_SemaSignal                             ; F91F50  1d 88 2d f4
	jr .LF91F64                                          ; F91F54  68 0e
.LF91F56:
	ldw (PanelDial_DownButton:16), 0x0282                              ; F91F56  f1 9b 20 02 82 02
	or	(UI_RequestBits:16), 0x09                            ; F91F5C  c1 75 20 3e 09
	calr C0mbinati0nM0de_EditSelectedRow                                      ; F91F61  1e 88 04
.LF91F64:
	ret                                                  ; F91F64  0e
; SoftKeyCol4_C0mbinati0nM0de_Page2 -- SOFT KEY column 4 on COMBINATION MODE page 2: select part 4, or step its value if it is already selected
; Evidence: slot [3] of DisplayListPtrs_F9157B, the table sub_F914E1 (screen 2's +8 Button method) hands to T_PanelButton_CallTableEntry when (0x2687) != 0 -- page 2, painted by sub_F916AA ("PAGE2/2", columns PT1..PT8). Code 3 is SOFT KEY col 4 (notes/FINDINGS-prom_a-panel-control-map.md).
; Body: sets the step magnitude in W to 1 (3 when (0x2075) bit 2 is set) -- the field T_Value_ApplyNibbleDeltaClamped reads, with bit 7 as the sign -- then falls into C0mbinati0nM0de_SelectOrEditPart4.
SoftKeyCol4_C0mbinati0nM0de_Page2:   ; entry: named by 1 `.long` operand, first at 0xF91587
	or W,0x01                                            ; F91F65  c8 ce 01
	bit	2, (UI_RequestBits:16)                               ; F91F68  f1 75 20 ca
	jr z, SoftKeyCol4_C0mbinati0nM0de_Page2_Join                                     ; F91F6C  66 02
	inc 2,W                                              ; F91F6E  c8 62
SoftKeyCol4_C0mbinati0nM0de_Page2_Join:
	cp	(UI_PartIndex:16), 0x03                            ; F91F70  c1 50 22 3f 03
	jr z, .LF91FB5                                       ; F91F75  66 3e
	bit	2, (UI_RequestBits:16)                               ; F91F77  f1 75 20 ca
	jr z, .LF91F82                                       ; F91F7B  66 05
	and	(UI_RequestBits:16), 0xf7                            ; F91F7D  c1 75 20 3c f7
.LF91F82:
	ldw (PanelDial_DownButton:16), 0x0383                              ; F91F82  f1 9b 20 02 83 03
	or	(UI_RequestBits:16), 0x09                            ; F91F88  c1 75 20 3e 09
	ld a, 0x03:opc                                          ; F91F8D  21 03
	ld (UI_PartIndex:16), a                                   ; F91F8F  f1 50 22 41
	ld e, 0x90:opc                                          ; F91F93  25 90
	ld d, 0x10:opc                                          ; F91F95  24 10
	ld w, 0xff:opc                                          ; F91F97  20 ff
	call T_Queue2E00_AppendRegs                          ; F91F99  1d 3c 0f f4
	call T_NoteRouting_Rebuild                                        ; F91F9D  1d bc 11 f4
	ld XWA,C0mbinati0nM0de_ShowSelectedPartSoundName                                    ; F91FA1  40 e5 18 f9 00
	push XWA                                             ; F91FA6  38
	call T_CallbackQueue_Post                            ; F91FA7  1d 84 2e f4
	inc 4,XSP                                            ; F91FAB  ef 64
	ld a, 0x01:opc                                          ; F91FAD  21 01
	call T_Kernel_SemaSignal                             ; F91FAF  1d 88 2d f4
	jr .LF91FC3                                          ; F91FB3  68 0e
.LF91FB5:
	ldw (PanelDial_DownButton:16), 0x0383                              ; F91FB5  f1 9b 20 02 83 03
	or	(UI_RequestBits:16), 0x09                            ; F91FBB  c1 75 20 3e 09
	calr C0mbinati0nM0de_EditSelectedRow                                      ; F91FC0  1e 29 04
.LF91FC3:
	ret                                                  ; F91FC3  0e
; SoftKeyCol5_C0mbinati0nM0de_Page2 -- SOFT KEY column 5 on COMBINATION MODE page 2: select part 5, or step its value if it is already selected
; Evidence: slot [4] of DisplayListPtrs_F9157B, the table sub_F914E1 (screen 2's +8 Button method) hands to T_PanelButton_CallTableEntry when (0x2687) != 0 -- page 2, painted by sub_F916AA ("PAGE2/2", columns PT1..PT8). Code 4 is SOFT KEY col 5 (notes/FINDINGS-prom_a-panel-control-map.md).
; Body: sets the step magnitude in W to 1 (3 when (0x2075) bit 2 is set) -- the field T_Value_ApplyNibbleDeltaClamped reads, with bit 7 as the sign -- then falls into C0mbinati0nM0de_SelectOrEditPart5.
SoftKeyCol5_C0mbinati0nM0de_Page2:   ; entry: named by 1 `.long` operand, first at 0xF9158B
	or W,0x01                                            ; F91FC4  c8 ce 01
	bit	2, (UI_RequestBits:16)                               ; F91FC7  f1 75 20 ca
	jr z, SoftKeyCol5_C0mbinati0nM0de_Page2_Join                                     ; F91FCB  66 02
	inc 2,W                                              ; F91FCD  c8 62
SoftKeyCol5_C0mbinati0nM0de_Page2_Join:
	cp	(UI_PartIndex:16), 0x04                            ; F91FCF  c1 50 22 3f 04
	jr z, .LF92014                                       ; F91FD4  66 3e
	bit	2, (UI_RequestBits:16)                               ; F91FD6  f1 75 20 ca
	jr z, .LF91FE1                                       ; F91FDA  66 05
	and	(UI_RequestBits:16), 0xf7                            ; F91FDC  c1 75 20 3c f7
.LF91FE1:
	ldw (PanelDial_DownButton:16), 0x0484                              ; F91FE1  f1 9b 20 02 84 04
	or	(UI_RequestBits:16), 0x09                            ; F91FE7  c1 75 20 3e 09
	ld a, 0x04:opc                                          ; F91FEC  21 04
	ld (UI_PartIndex:16), a                                   ; F91FEE  f1 50 22 41
	ld e, 0x90:opc                                          ; F91FF2  25 90
	ld d, 0x10:opc                                          ; F91FF4  24 10
	ld w, 0xff:opc                                          ; F91FF6  20 ff
	call T_Queue2E00_AppendRegs                          ; F91FF8  1d 3c 0f f4
	call T_NoteRouting_Rebuild                                        ; F91FFC  1d bc 11 f4
	ld XWA,C0mbinati0nM0de_ShowSelectedPartSoundName                                    ; F92000  40 e5 18 f9 00
	push XWA                                             ; F92005  38
	call T_CallbackQueue_Post                            ; F92006  1d 84 2e f4
	inc 4,XSP                                            ; F9200A  ef 64
	ld a, 0x01:opc                                          ; F9200C  21 01
	call T_Kernel_SemaSignal                             ; F9200E  1d 88 2d f4
	jr .LF92022                                          ; F92012  68 0e
.LF92014:
	ldw (PanelDial_DownButton:16), 0x0484                              ; F92014  f1 9b 20 02 84 04
	or	(UI_RequestBits:16), 0x09                            ; F9201A  c1 75 20 3e 09
	calr C0mbinati0nM0de_EditSelectedRow                                      ; F9201F  1e ca 03
.LF92022:
	ret                                                  ; F92022  0e
; SoftKeyCol6_C0mbinati0nM0de_Page2 -- SOFT KEY column 6 on COMBINATION MODE page 2: select part 6, or step its value if it is already selected
; Evidence: slot [5] of DisplayListPtrs_F9157B, the table sub_F914E1 (screen 2's +8 Button method) hands to T_PanelButton_CallTableEntry when (0x2687) != 0 -- page 2, painted by sub_F916AA ("PAGE2/2", columns PT1..PT8). Code 5 is SOFT KEY col 6 (notes/FINDINGS-prom_a-panel-control-map.md).
; Body: sets the step magnitude in W to 1 (3 when (0x2075) bit 2 is set) -- the field T_Value_ApplyNibbleDeltaClamped reads, with bit 7 as the sign -- then falls into C0mbinati0nM0de_SelectOrEditPart6.
SoftKeyCol6_C0mbinati0nM0de_Page2:   ; entry: named by 1 `.long` operand, first at 0xF9158F
	or W,0x01                                            ; F92023  c8 ce 01
	bit	2, (UI_RequestBits:16)                               ; F92026  f1 75 20 ca
	jr z, SoftKeyCol6_C0mbinati0nM0de_Page2_Join                                     ; F9202A  66 02
	inc 2,W                                              ; F9202C  c8 62
SoftKeyCol6_C0mbinati0nM0de_Page2_Join:
	cp	(UI_PartIndex:16), 0x05                            ; F9202E  c1 50 22 3f 05
	jr z, .LF92073                                       ; F92033  66 3e
	bit	2, (UI_RequestBits:16)                               ; F92035  f1 75 20 ca
	jr z, .LF92040                                       ; F92039  66 05
	and	(UI_RequestBits:16), 0xf7                            ; F9203B  c1 75 20 3c f7
.LF92040:
	ldw (PanelDial_DownButton:16), 0x0585                              ; F92040  f1 9b 20 02 85 05
	or	(UI_RequestBits:16), 0x09                            ; F92046  c1 75 20 3e 09
	ld a, 0x05:opc                                          ; F9204B  21 05
	ld (UI_PartIndex:16), a                                   ; F9204D  f1 50 22 41
	ld e, 0x90:opc                                          ; F92051  25 90
	ld d, 0x10:opc                                          ; F92053  24 10
	ld w, 0xff:opc                                          ; F92055  20 ff
	call T_Queue2E00_AppendRegs                          ; F92057  1d 3c 0f f4
	call T_NoteRouting_Rebuild                                        ; F9205B  1d bc 11 f4
	ld XWA,C0mbinati0nM0de_ShowSelectedPartSoundName                                    ; F9205F  40 e5 18 f9 00
	push XWA                                             ; F92064  38
	call T_CallbackQueue_Post                            ; F92065  1d 84 2e f4
	inc 4,XSP                                            ; F92069  ef 64
	ld a, 0x01:opc                                          ; F9206B  21 01
	call T_Kernel_SemaSignal                             ; F9206D  1d 88 2d f4
	jr .LF92081                                          ; F92071  68 0e
.LF92073:
	ldw (PanelDial_DownButton:16), 0x0585                              ; F92073  f1 9b 20 02 85 05
	or	(UI_RequestBits:16), 0x09                            ; F92079  c1 75 20 3e 09
	calr C0mbinati0nM0de_EditSelectedRow                                      ; F9207E  1e 6b 03
.LF92081:
	ret                                                  ; F92081  0e
; SoftKeyCol7_C0mbinati0nM0de_Page2 -- SOFT KEY column 7 on COMBINATION MODE page 2: select part 7, or step its value if it is already selected
; Evidence: slot [6] of DisplayListPtrs_F9157B, the table sub_F914E1 (screen 2's +8 Button method) hands to T_PanelButton_CallTableEntry when (0x2687) != 0 -- page 2, painted by sub_F916AA ("PAGE2/2", columns PT1..PT8). Code 6 is SOFT KEY col 7 (notes/FINDINGS-prom_a-panel-control-map.md).
; Body: sets the step magnitude in W to 1 (3 when (0x2075) bit 2 is set) -- the field T_Value_ApplyNibbleDeltaClamped reads, with bit 7 as the sign -- then falls into C0mbinati0nM0de_SelectOrEditPart7.
SoftKeyCol7_C0mbinati0nM0de_Page2:   ; entry: named by 1 `.long` operand, first at 0xF91593
	or W,0x01                                            ; F92082  c8 ce 01
	bit	2, (UI_RequestBits:16)                               ; F92085  f1 75 20 ca
	jr z, SoftKeyCol7_C0mbinati0nM0de_Page2_Join                                     ; F92089  66 02
	inc 2,W                                              ; F9208B  c8 62
SoftKeyCol7_C0mbinati0nM0de_Page2_Join:
	cp	(UI_PartIndex:16), 0x06                            ; F9208D  c1 50 22 3f 06
	jr z, .LF920D2                                       ; F92092  66 3e
	bit	2, (UI_RequestBits:16)                               ; F92094  f1 75 20 ca
	jr z, .LF9209F                                       ; F92098  66 05
	and	(UI_RequestBits:16), 0xf7                            ; F9209A  c1 75 20 3c f7
.LF9209F:
	ldw (PanelDial_DownButton:16), 0x0686                              ; F9209F  f1 9b 20 02 86 06
	or	(UI_RequestBits:16), 0x09                            ; F920A5  c1 75 20 3e 09
	ld a, 0x06:opc                                          ; F920AA  21 06
	ld (UI_PartIndex:16), a                                   ; F920AC  f1 50 22 41
	ld e, 0x90:opc                                          ; F920B0  25 90
	ld d, 0x10:opc                                          ; F920B2  24 10
	ld w, 0xff:opc                                          ; F920B4  20 ff
	call T_Queue2E00_AppendRegs                          ; F920B6  1d 3c 0f f4
	call T_NoteRouting_Rebuild                                        ; F920BA  1d bc 11 f4
	ld XWA,C0mbinati0nM0de_ShowSelectedPartSoundName                                    ; F920BE  40 e5 18 f9 00
	push XWA                                             ; F920C3  38
	call T_CallbackQueue_Post                            ; F920C4  1d 84 2e f4
	inc 4,XSP                                            ; F920C8  ef 64
	ld a, 0x01:opc                                          ; F920CA  21 01
	call T_Kernel_SemaSignal                             ; F920CC  1d 88 2d f4
	jr .LF920E0                                          ; F920D0  68 0e
.LF920D2:
	ldw (PanelDial_DownButton:16), 0x0686                              ; F920D2  f1 9b 20 02 86 06
	or	(UI_RequestBits:16), 0x09                            ; F920D8  c1 75 20 3e 09
	calr C0mbinati0nM0de_EditSelectedRow                                      ; F920DD  1e 0c 03
.LF920E0:
	ret                                                  ; F920E0  0e
; SoftKeyCol8_C0mbinati0nM0de -- SOFT KEY column 8 on both COMBINATION MODE pages: PART down/up on page 1, select part 8 on page 2
; Evidence: slot [7] of DisplayListPtrs_F914FB (used when (0x2687) == 0, page 1) and of DisplayListPtrs_F9157B ((0x2687) != 0, page 2); code 7 = SOFT KEY col 8.
; Body: `or W,0x01` (+2 more when (0x2075) bit 2 is set) -- the step for T_Value_ApplyNibbleDeltaClamped -- then falls into C0mbinati0nM0de_SelectOrEditPart8OrStepPart.
SoftKeyCol8_C0mbinati0nM0de:   ; entry: named by 2 `.long` operands, first at 0xF91517
	or W,0x01                                            ; F920E1  c8 ce 01
	bit	2, (UI_RequestBits:16)                               ; F920E4  f1 75 20 ca
	jr z, SoftKeyCol8_C0mbinati0nM0de_Join                                     ; F920E8  66 02
	inc 2,W                                              ; F920EA  c8 62
SoftKeyCol8_C0mbinati0nM0de_Join:
	cp	(CombinationMode_Page:16), 0x00                            ; F920EC  c1 87 26 3f 00
	jr z, .LF92148                                       ; F920F1  66 55
	cp	(UI_PartIndex:16), 0x07                            ; F920F3  c1 50 22 3f 07
	jr z, .LF92138                                       ; F920F8  66 3e
	bit	2, (UI_RequestBits:16)                               ; F920FA  f1 75 20 ca
	jr Z,.LF92105                                        ; F920FE  66 05
	and	(UI_RequestBits:16), 0xf7                            ; F92100  c1 75 20 3c f7
.LF92105:
	ldw (PanelDial_DownButton:16), 0x0787                              ; F92105  f1 9b 20 02 87 07
	or	(UI_RequestBits:16), 0x09                            ; F9210B  c1 75 20 3e 09
	ld a, 0x07:opc                                          ; F92110  21 07
	ld (UI_PartIndex:16), a                                   ; F92112  f1 50 22 41
	ld e, 0x90:opc                                          ; F92116  25 90
	ld d, 0x10:opc                                          ; F92118  24 10
	ld w, 0xff:opc                                          ; F9211A  20 ff
	call T_Queue2E00_AppendRegs                          ; F9211C  1d 3c 0f f4
	call T_NoteRouting_Rebuild                                        ; F92120  1d bc 11 f4
	ld XWA,C0mbinati0nM0de_ShowSelectedPartSoundName                                    ; F92124  40 e5 18 f9 00
	push XWA                                             ; F92129  38
	call T_CallbackQueue_Post                            ; F9212A  1d 84 2e f4
	inc 4,XSP                                            ; F9212E  ef 64
	ld a, 0x01:opc                                          ; F92130  21 01
	call T_Kernel_SemaSignal                             ; F92132  1d 88 2d f4
	jr .LF9214B                                          ; F92136  68 13
.LF92138:
	ldw (PanelDial_DownButton:16), 0x0787                              ; F92138  f1 9b 20 02 87 07
	or	(UI_RequestBits:16), 0x09                            ; F9213E  c1 75 20 3e 09
	calr C0mbinati0nM0de_EditSelectedRow                                      ; F92143  1e a6 02
	jr .LF9214B                                          ; F92146  68 03
.LF92148:
	calr C0mbinati0nM0de_StepSelectedPart                                      ; F92148  1e 01 00
.LF9214B:
	ret                                                  ; F9214B  0e
; C0mbinati0nM0de_StepSelectedPart -- COMBINATION MODE page 1 PART down/up: steps the selected part (0x2250) by the key's signed step, clamped to 0..7, and repaints page 1
; Evidence: A = (0x2250), B = 7, C = 0, call T_Value_ApplyNibbleDeltaClamped (sub_F8BD73: A + SignedNibbleDelta_Table[W], clamped to [C,B]). If changed: (0x2250) = A, T_Queue2E00_AppendRegs {E=0x90, D=0x10, A, W=0xFF}, T_NoteRouting_Rebuild,
; (0x2676) |= 0xFF and (0x2677) |= 0x07 (every page-1 field dirty), T_CallbackQueue_ResetAndRestartTask2, post C0mbinati0nM0de_RepaintPage1Fields.
; Called only by C0mbinati0nM0de_SelectOrEditPart8OrStepPart when (0x2687) == 0; page 1's lists carry the caption "PART".
C0mbinati0nM0de_StepSelectedPart:
	ldw (PanelDial_DownButton:16), 0x0787                              ; F9214C  f1 9b 20 02 87 07
	or	(UI_RequestBits:16), 0x09                            ; F92152  c1 75 20 3e 09
	ld a, (UI_PartIndex:16)                                   ; F92157  c1 50 22 21
	ld b, 0x07:opc                                          ; F9215B  22 07
	ld c, 0x00:opc                                          ; F9215D  23 00
	ld L,A                                               ; F9215F  c9 8f
	pushw hl                                             ; F92161  2b
	call T_Value_ApplyNibbleDeltaClamped                                        ; F92162  1d 04 1b f4
	popw hl                                              ; F92166  4b
	cp A,L                                               ; F92167  cf f1
	jr z, .LF9219D                                       ; F92169  66 32
	ld (UI_PartIndex:16), a                                   ; F9216B  f1 50 22 41
	ld e, 0x90:opc                                          ; F9216F  25 90
	ld d, 0x10:opc                                          ; F92171  24 10
	ld w, 0xff:opc                                          ; F92173  20 ff
	call T_Queue2E00_AppendRegs                          ; F92175  1d 3c 0f f4
	call T_NoteRouting_Rebuild                                        ; F92179  1d bc 11 f4
	or	(ModeScreen_DirtyFields:16), 0xff                            ; F9217D  c1 76 26 3e ff
	or	(ModeScreen_DirtyFields2:16), 0x07                            ; F92182  c1 77 26 3e 07
	call T_CallbackQueue_ResetAndRestartTask2            ; F92187  1d 80 2e f4
	ld XWA,C0mbinati0nM0de_RepaintPage1Fields                                    ; F9218B  40 f2 1c f9 00
	push XWA                                             ; F92190  38
	call T_CallbackQueue_Post                            ; F92191  1d 84 2e f4
	inc 4,XSP                                            ; F92195  ef 64
	ld a, 0x01:opc                                          ; F92197  21 01
	call T_Kernel_SemaSignal                             ; F92199  1d 88 2d f4
.LF9219D:
	ret                                                  ; F9219D  0e
; LcdKeyRow1_C0mbinati0nM0de_Page2 -- LCD row-1 keys on COMBINATION MODE page 2: the left key selects the SOUND row, the right key toggles SOLO
; Evidence: slot [8] (code 0x08 = LCD row 1) of DisplayListPtrs_F9157B. W bit 7 set (pair position 0 = LEFT): (0x2678) = 1, post C0mbinati0nM0de_HighlightSoundRow.
; W bit 7 clear (RIGHT): toggle (0x267D) bit 0, T_NoteRouting_SetSoloAndRebuild with the new state (NoteRouting_SetSoloAndRebuild sets/clears bit 5 of (0x602498)), post C0mbinati0nM0de_SoloIndicatorOff or C0mbinati0nM0de_SoloIndicatorOn.
; Page 2's list draws "SOUND" at (0x07,0x22) on the left and "SOLO" at (0x121,0x22) on the right of LCD row 1.
LcdKeyRow1_C0mbinati0nM0de_Page2:   ; entry: named by 1 `.long` operand, first at 0xF9159B
	bit 0x07,W                                           ; F9219E  c8 33 07
	jr z, .LF921C1                                       ; F921A1  66 1e
	ld (CombinationMode_EditRow:16), 0x00                                 ; F921A3  f1 78 26 00 00
	or	(CombinationMode_EditRow:16), 0x01                            ; F921A8  c1 78 26 3e 01
	ld XWA,C0mbinati0nM0de_HighlightSoundRow                                    ; F921AD  40 0a 22 f9 00
	push XWA                                             ; F921B2  38
	call T_CallbackQueue_Post                            ; F921B3  1d 84 2e f4
	inc 4,XSP                                            ; F921B7  ef 64
	ld a, 0x01:opc                                          ; F921B9  21 01
	call T_Kernel_SemaSignal                             ; F921BB  1d 88 2d f4
	jr .LF92209                                          ; F921BF  68 48
.LF921C1:
	bit	0, (CombinationMode_Solo:16)                               ; F921C1  f1 7d 26 c8
	jr z, .LF921E9                                       ; F921C5  66 22
	and	(CombinationMode_Solo:16), 0xfe                            ; F921C7  c1 7d 26 3c fe
	ld a, 0x00:opc                                          ; F921CC  21 00
	push_a                                               ; F921CE  14
	call T_NoteRouting_SetSoloAndRebuild                                        ; F921CF  1d ec 11 f4
	inc 1,XSP                                            ; F921D3  ef 61
	ld XWA,C0mbinati0nM0de_SoloIndicatorOff                                    ; F921D5  40 2c 22 f9 00
	push XWA                                             ; F921DA  38
	call T_CallbackQueue_Post                            ; F921DB  1d 84 2e f4
	inc 4,XSP                                            ; F921DF  ef 64
	ld a, 0x01:opc                                          ; F921E1  21 01
	call T_Kernel_SemaSignal                             ; F921E3  1d 88 2d f4
	jr .LF92209                                          ; F921E7  68 20
.LF921E9:
	or	(CombinationMode_Solo:16), 0x01                            ; F921E9  c1 7d 26 3e 01
	ld a, 0x01:opc                                          ; F921EE  21 01
	push_a                                               ; F921F0  14
	call T_NoteRouting_SetSoloAndRebuild                                        ; F921F1  1d ec 11 f4
	inc 1,XSP                                            ; F921F5  ef 61
	ld XWA,C0mbinati0nM0de_SoloIndicatorOn                                    ; F921F7  40 40 22 f9 00
	push XWA                                             ; F921FC  38
	call T_CallbackQueue_Post                            ; F921FD  1d 84 2e f4
	inc 4,XSP                                            ; F92201  ef 64
	ld a, 0x01:opc                                          ; F92203  21 01
	call T_Kernel_SemaSignal                             ; F92205  1d 88 2d f4
.LF92209:
	ret                                                  ; F92209  0e
; C0mbinati0nM0de_HighlightSoundRow -- COMBINATION MODE page 2: marks SOUND as the row the soft keys edit
; Evidence: on layer (0x2540) = 1 runs DL_F29686..C0mbinati0nM0de_HighlightSoundRow_DL (four op-1B EraseRect boxes at x 0x07-0x25, y 0x21 / 0x48 / 0x6F / 0x9A -- the SOUND / INT / PAN / VOL labels) then C0mbinati0nM0de_HighlightSoundRow_DL..C0mbinati0nM0de_HighlightIntRow_DL (op-05 FillRect over the y 0x21 box, the "SOUND" label at y 0x22).
; Posted by LcdKeyRow1_C0mbinati0nM0de_Page2 right after it sets (0x2678) = 1, the bit C0mbinati0nM0de_EditSelectedRow dispatches on.
C0mbinati0nM0de_HighlightSoundRow:   ; entry: named by 1 `ld` operand, first at 0xF921AD
	ld (LCD_CurrentLayer:16), 0x01                                 ; F9220A  f1 40 25 00 01
	ld XIY,DL_F29686                                     ; F9220F  45 86 96 f2 00
	ld XIX,C0mbinati0nM0de_HighlightSoundRow_DL                                     ; F92214  44 ae 96 f2 00
	call T_DisplayList_Run                               ; F92219  1d f0 17 f4
	ld XIY,C0mbinati0nM0de_HighlightSoundRow_DL                                     ; F9221D  45 ae 96 f2 00
	ld XIX,C0mbinati0nM0de_HighlightIntRow_DL                                     ; F92222  44 b8 96 f2 00
	call T_DisplayList_Run                               ; F92227  1d f0 17 f4
	ret                                                  ; F9222B  0e
; C0mbinati0nM0de_SoloIndicatorOff -- erases the box over the "SOLO" label on COMBINATION MODE page 2
; Evidence: (0x2540) = 1 then DL_F29672..DL_F2967C, one op-1B EraseRect (0x121,0x21)-(0x139,0x29) -- page 2's list draws "SOLO" at (0x121,0x22).
; Posted by LcdKeyRow1_C0mbinati0nM0de_Page2 when it clears (0x267D) bit 0; sub_F916AA runs the same list unconditionally and C0mbinati0nM0de_SoloIndicatorOn's list when (0x267D) bit 0 is set.
C0mbinati0nM0de_SoloIndicatorOff:   ; entry: named by 1 `ld` operand, first at 0xF921D5
	ld (LCD_CurrentLayer:16), 0x01                                 ; F9222C  f1 40 25 00 01
	ld XIY,DL_F29672                                     ; F92231  45 72 96 f2 00
	ld XIX,DL_F2967C                                     ; F92236  44 7c 96 f2 00
	call T_DisplayList_Run                               ; F9223B  1d f0 17 f4
	ret                                                  ; F9223F  0e
; C0mbinati0nM0de_SoloIndicatorOn -- fills the box over the "SOLO" label on COMBINATION MODE page 2
; Evidence: DL_F2967C..DL_F29686, one op-05 FillRect (0x121,0x21)-(0x139,0x29); posted by LcdKeyRow1_C0mbinati0nM0de_Page2 when it sets (0x267D) bit 0.
; Unlike C0mbinati0nM0de_SoloIndicatorOff it does not set (0x2540), so it draws on whatever layer is current when the callback runs.
C0mbinati0nM0de_SoloIndicatorOn:   ; entry: named by 1 `ld` operand, first at 0xF921F7
	ld XIY,DL_F2967C                                     ; F92240  45 7c 96 f2 00
	ld XIX,DL_F29686                                     ; F92245  44 86 96 f2 00
	call T_DisplayList_Run                               ; F9224A  1d f0 17 f4
	ret                                                  ; F9224E  0e
; LcdKeyRow2_C0mbinati0nM0de_Page2 -- LCD row-2 keys on COMBINATION MODE page 2: the left key selects the INT row, the right key does nothing
; Evidence: slot [9] (code 0x09 = LCD row 2) of DisplayListPtrs_F9157B. W bit 7 set (pair position 0 = LEFT): (0x2678) = 8 and post C0mbinati0nM0de_HighlightIntRow; clear: `ret`.
; Row 2's label on page 2 is "INT" (DL_C0mbinati0nM0dePage22Sound).
LcdKeyRow2_C0mbinati0nM0de_Page2:   ; entry: named by 1 `.long` operand, first at 0xF9159F
	bit 0x07,W                                           ; F9224F  c8 33 07
	jr z, .LF92270                                       ; F92252  66 1c
	ld (CombinationMode_EditRow:16), 0x00                                 ; F92254  f1 78 26 00 00
	or	(CombinationMode_EditRow:16), 0x08                            ; F92259  c1 78 26 3e 08
	ld XWA,C0mbinati0nM0de_HighlightIntRow                                    ; F9225E  40 71 22 f9 00
	push XWA                                             ; F92263  38
	call T_CallbackQueue_Post                            ; F92264  1d 84 2e f4
	inc 4,XSP                                            ; F92268  ef 64
	ld a, 0x01:opc                                          ; F9226A  21 01
	call T_Kernel_SemaSignal                             ; F9226C  1d 88 2d f4
.LF92270:
	ret                                                  ; F92270  0e
; C0mbinati0nM0de_HighlightIntRow -- COMBINATION MODE page 2: marks INT as the row the soft keys edit
; Evidence: on layer (0x2540) = 1 runs DL_F29686..C0mbinati0nM0de_HighlightSoundRow_DL (four op-1B EraseRect boxes at x 0x07-0x25, y 0x21 / 0x48 / 0x6F / 0x9A -- the SOUND / INT / PAN / VOL labels) then C0mbinati0nM0de_HighlightIntRow_DL..C0mbinati0nM0de_HighlightPanRow_DL (op-05 FillRect over the y 0x48 box, the "INT" label at y 0x49).
; Posted by LcdKeyRow2_C0mbinati0nM0de_Page2 right after it sets (0x2678) = 8, the bit C0mbinati0nM0de_EditSelectedRow dispatches on.
C0mbinati0nM0de_HighlightIntRow:   ; entry: named by 1 `ld` operand, first at 0xF9225E
	ld (LCD_CurrentLayer:16), 0x01                                 ; F92271  f1 40 25 00 01
	ld XIY,DL_F29686                                     ; F92276  45 86 96 f2 00
	ld XIX,C0mbinati0nM0de_HighlightSoundRow_DL                                     ; F9227B  44 ae 96 f2 00
	call T_DisplayList_Run                               ; F92280  1d f0 17 f4
	ld XIY,C0mbinati0nM0de_HighlightIntRow_DL                                     ; F92284  45 b8 96 f2 00
	ld XIX,C0mbinati0nM0de_HighlightPanRow_DL                                     ; F92289  44 c2 96 f2 00
	call T_DisplayList_Run                               ; F9228E  1d f0 17 f4
	ret                                                  ; F92292  0e
; LcdKeyRow3_C0mbinati0nM0de_Page2 -- LCD row-3 keys on COMBINATION MODE page 2: the left key selects the PAN row, the right key does nothing
; Evidence: slot [10] (code 0x0A = LCD row 3) of DisplayListPtrs_F9157B. W bit 7 set (pair position 0 = LEFT): (0x2678) = 4 and post C0mbinati0nM0de_HighlightPanRow; clear: `ret`.
; Row 3's label on page 2 is "PAN" (DL_C0mbinati0nM0dePage22Sound).
LcdKeyRow3_C0mbinati0nM0de_Page2:   ; entry: named by 1 `.long` operand, first at 0xF915A3
	bit 0x07,W                                           ; F92293  c8 33 07
	jr z, .LF922B4                                       ; F92296  66 1c
	ld (CombinationMode_EditRow:16), 0x00                                 ; F92298  f1 78 26 00 00
	or	(CombinationMode_EditRow:16), 0x04                            ; F9229D  c1 78 26 3e 04
	ld XWA,C0mbinati0nM0de_HighlightPanRow                                    ; F922A2  40 b5 22 f9 00
	push XWA                                             ; F922A7  38
	call T_CallbackQueue_Post                            ; F922A8  1d 84 2e f4
	inc 4,XSP                                            ; F922AC  ef 64
	ld a, 0x01:opc                                          ; F922AE  21 01
	call T_Kernel_SemaSignal                             ; F922B0  1d 88 2d f4
.LF922B4:
	ret                                                  ; F922B4  0e
; C0mbinati0nM0de_HighlightPanRow -- COMBINATION MODE page 2: marks PAN as the row the soft keys edit
; Evidence: on layer (0x2540) = 1 runs DL_F29686..C0mbinati0nM0de_HighlightSoundRow_DL (four op-1B EraseRect boxes at x 0x07-0x25, y 0x21 / 0x48 / 0x6F / 0x9A -- the SOUND / INT / PAN / VOL labels) then C0mbinati0nM0de_HighlightPanRow_DL..DL_F296CC (op-05 FillRect over the y 0x6F box, the "PAN" label at y 0x70).
; Posted by LcdKeyRow3_C0mbinati0nM0de_Page2 right after it sets (0x2678) = 4, the bit C0mbinati0nM0de_EditSelectedRow dispatches on.
C0mbinati0nM0de_HighlightPanRow:   ; entry: named by 1 `ld` operand, first at 0xF922A2
	ld (LCD_CurrentLayer:16), 0x01                                 ; F922B5  f1 40 25 00 01
	ld XIY,DL_F29686                                     ; F922BA  45 86 96 f2 00
	ld XIX,C0mbinati0nM0de_HighlightSoundRow_DL                                     ; F922BF  44 ae 96 f2 00
	call T_DisplayList_Run                               ; F922C4  1d f0 17 f4
	ld XIY,C0mbinati0nM0de_HighlightPanRow_DL                                     ; F922C8  45 c2 96 f2 00
	ld XIX,DL_F296CC                                     ; F922CD  44 cc 96 f2 00
	call T_DisplayList_Run                               ; F922D2  1d f0 17 f4
	ret                                                  ; F922D6  0e
; LcdKeyRow4_C0mbinati0nM0de_Page2 -- LCD row-4 keys on COMBINATION MODE page 2: the left key selects the VOL row, the right key does nothing
; Evidence: slot [11] (code 0x0B = LCD row 4) of DisplayListPtrs_F9157B. W bit 7 set (pair position 0 = LEFT): (0x2678) = 2 and post C0mbinati0nM0de_HighlightVolRow; clear: `ret`.
; Row 4's label on page 2 is "VOL" (DL_C0mbinati0nM0dePage22Sound).
LcdKeyRow4_C0mbinati0nM0de_Page2:   ; entry: named by 1 `.long` operand, first at 0xF915A7
	bit 0x07,W                                           ; F922D7  c8 33 07
	jr z, .LF922F8                                       ; F922DA  66 1c
	ld (CombinationMode_EditRow:16), 0x00                                 ; F922DC  f1 78 26 00 00
	or	(CombinationMode_EditRow:16), 0x02                            ; F922E1  c1 78 26 3e 02
	ld XWA,C0mbinati0nM0de_HighlightVolRow                                    ; F922E6  40 f9 22 f9 00
	push XWA                                             ; F922EB  38
	call T_CallbackQueue_Post                            ; F922EC  1d 84 2e f4
	inc 4,XSP                                            ; F922F0  ef 64
	ld a, 0x01:opc                                          ; F922F2  21 01
	call T_Kernel_SemaSignal                             ; F922F4  1d 88 2d f4
.LF922F8:
	ret                                                  ; F922F8  0e
; C0mbinati0nM0de_HighlightVolRow -- COMBINATION MODE page 2: marks VOL as the row the soft keys edit
; Evidence: on layer (0x2540) = 1 runs DL_F29686..C0mbinati0nM0de_HighlightSoundRow_DL (four op-1B EraseRect boxes at x 0x07-0x25, y 0x21 / 0x48 / 0x6F / 0x9A -- the SOUND / INT / PAN / VOL labels) then DL_F296CC..0xF296D6 (op-05 FillRect over the y 0x9A box, the "VOL" label at y 0x9B).
; Posted by LcdKeyRow4_C0mbinati0nM0de_Page2 right after it sets (0x2678) = 2, the bit C0mbinati0nM0de_EditSelectedRow dispatches on.
C0mbinati0nM0de_HighlightVolRow:   ; entry: named by 1 `ld` operand, first at 0xF922E6
	ld (LCD_CurrentLayer:16), 0x01                                 ; F922F9  f1 40 25 00 01
	ld XIY,DL_F29686                                     ; F922FE  45 86 96 f2 00
	ld XIX,C0mbinati0nM0de_HighlightSoundRow_DL                                     ; F92303  44 ae 96 f2 00
	call T_DisplayList_Run                               ; F92308  1d f0 17 f4
	ld XIY,DL_F296CC                                     ; F9230C  45 cc 96 f2 00
	ld XIX,0x00f296d6                                    ; F92311  44 d6 96 f2 00
	call T_DisplayList_Run                               ; F92316  1d f0 17 f4
	ret                                                  ; F9231A  0e
DisplayListPtrs_F9157B_Nop12:   ; entry: named by 1 `.long` operand, first at 0xF915AB
	ret                                                  ; F9231B  0e
DisplayListPtrs_F9157B_Nop13:   ; entry: named by 1 `.long` operand, first at 0xF915AF
	ret                                                  ; F9231C  0e
DisplayListPtrs_F9157B_Nop14:   ; entry: named by 1 `.long` operand, first at 0xF915B3
	ret                                                  ; F9231D  0e
; ExitKey_C0mbinati0nM0de -- EXIT on COMBINATION MODE: from page 2 returns to page 1; on page 1 only clears (0x2075) bit 3
; Evidence: slot [15] (code 0x0F = EXIT) of both DisplayListPtrs_F914FB and DisplayListPtrs_F9157B. `and (0x2075),0xF7`; then, if W bit 7 is clear (EXIT is pair position 1) and (0x2687) == 1:
; (0x2687) = 0 and (0x2071) |= 0x10, which PanelButton_Route turns into `or (0x2072),0x10` (redraw) at 0xF86230.
ExitKey_C0mbinati0nM0de:   ; entry: named by 2 `.long` operands, first at 0xF91537
	and	(UI_RequestBits:16), 0xf7                            ; F9231E  c1 75 20 3c f7
	bit 0x07,W                                           ; F92323  c8 33 07
	jr nz, .LF92339                                      ; F92326  6e 11
	cp	(CombinationMode_Page:16), 0x01                            ; F92328  c1 87 26 3f 01
	jr nz, .LF92339                                      ; F9232D  6e 0a
	ld (CombinationMode_Page:16), 0x00                                 ; F9232F  f1 87 26 00 00
	or	(UI_Request_Hi:16), 0x10                            ; F92334  c1 71 20 3e 10
.LF92339:
	ret                                                  ; F92339  0e
; PageKey_C0mbinati0nM0de -- PAGE v / PAGE ^ on COMBINATION MODE: v shows page 1 ((0x2687) = 0), ^ shows page 2 ((0x2687) = 1)
; Evidence: slot [16] (code 0x10 = PAGE) of both DisplayListPtrs_F914FB and DisplayListPtrs_F9157B. W bit 7 set (pair position 0 = PAGE v): if (0x2687) != 0, (0x2687) = 0; clear (PAGE ^): if (0x2687) != 1, (0x2687) = 1; each change sets (0x2071) bit 4 (redraw).
; sub_F915FB paints with Paint_C0mbinati0nM0dePage1 ("PAGE1/2") when (0x2687) == 0 and with sub_F916AA ("PAGE2/2") otherwise; it also resets (0x2687) to 0 on entry.
PageKey_C0mbinati0nM0de:   ; entry: named by 2 `.long` operands, first at 0xF9153B
	bit 0x07,W                                           ; F9233A  c8 33 07
	jr nz, .LF92352                                      ; F9233D  6e 13
	cp	(CombinationMode_Page:16), 0x01                            ; F9233F  c1 87 26 3f 01
	jr z, .LF92363                                       ; F92344  66 1d
	ld (CombinationMode_Page:16), 0x01                                 ; F92346  f1 87 26 00 01
	or	(UI_Request_Hi:16), 0x10                            ; F9234B  c1 71 20 3e 10
	jr .LF92363                                          ; F92350  68 11
.LF92352:
	cp	(CombinationMode_Page:16), 0x00                            ; F92352  c1 87 26 3f 00
	jr z, .LF92363                                       ; F92357  66 0a
	ld (CombinationMode_Page:16), 0x00                                 ; F92359  f1 87 26 00 00
	or	(UI_Request_Hi:16), 0x10                            ; F9235E  c1 71 20 3e 10
.LF92363:
	ret                                                  ; F92363  0e
; C0mbinati0nM0de_Page2_Button17 -- DisplayListPtrs_F9157B slot 0x11, NOT NAMED: slot 0x11 is only the VARIANT-1 already-held rewrite of base code 0x00 (SoftKeyCol1); it adjusts W and joins that
;   handler.  The SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
C0mbinati0nM0de_Page2_Button17:   ; entry: named by 1 `.long` operand, first at 0xF915BF
	add W,0x01                                           ; F92364  c8 c8 01
	bit	2, (UI_RequestBits:16)                               ; F92367  f1 75 20 ca
	jr z, .LF92370                                       ; F9236B  66 03
	add W,0x06                                           ; F9236D  c8 c8 06
.LF92370:
	jp SoftKeyCol1_C0mbinati0nM0de_Page2_Join                                        ; F92370  1b 55 1e f9
; C0mbinati0nM0de_Page2_Button18 -- DisplayListPtrs_F9157B slot 0x12, NOT NAMED: slot 0x12 is only the VARIANT-1 already-held rewrite of base code 0x01 (SoftKeyCol2); it adjusts W and joins that
;   handler.  The SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
C0mbinati0nM0de_Page2_Button18:   ; entry: named by 1 `.long` operand, first at 0xF915C3
	add W,0x01                                           ; F92374  c8 c8 01
	bit	2, (UI_RequestBits:16)                               ; F92377  f1 75 20 ca
	jr z, .LF92380                                       ; F9237B  66 03
	add W,0x06                                           ; F9237D  c8 c8 06
.LF92380:
	jp SoftKeyCol2_C0mbinati0nM0de_Page2_Join                                        ; F92380  1b b3 1e f9
; C0mbinati0nM0de_Page2_Button19 -- DisplayListPtrs_F9157B slot 0x13, NOT NAMED: slot 0x13 is only the VARIANT-1 already-held rewrite of base code 0x02 (SoftKeyCol3); it adjusts W and joins that
;   handler.  The SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
C0mbinati0nM0de_Page2_Button19:   ; entry: named by 1 `.long` operand, first at 0xF915C7
	add W,0x01                                           ; F92384  c8 c8 01
	bit	2, (UI_RequestBits:16)                               ; F92387  f1 75 20 ca
	jr z, .LF92390                                       ; F9238B  66 03
	add W,0x06                                           ; F9238D  c8 c8 06
.LF92390:
	jp SoftKeyCol3_C0mbinati0nM0de_Page2_Join                                        ; F92390  1b 11 1f f9
; C0mbinati0nM0de_Page2_Button20 -- DisplayListPtrs_F9157B slot 0x14, NOT NAMED: slot 0x14 is only the VARIANT-1 already-held rewrite of base code 0x03 (SoftKeyCol4); it adjusts W and joins that
;   handler.  The SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
C0mbinati0nM0de_Page2_Button20:   ; entry: named by 1 `.long` operand, first at 0xF915CB
	add W,0x01                                           ; F92394  c8 c8 01
	bit	2, (UI_RequestBits:16)                               ; F92397  f1 75 20 ca
	jr z, .LF923A0                                       ; F9239B  66 03
	add W,0x06                                           ; F9239D  c8 c8 06
.LF923A0:
	jp SoftKeyCol4_C0mbinati0nM0de_Page2_Join                                        ; F923A0  1b 70 1f f9
; C0mbinati0nM0de_Page2_Button21 -- DisplayListPtrs_F9157B slot 0x15, NOT NAMED: slot 0x15 is only the VARIANT-1 already-held rewrite of base code 0x04 (SoftKeyCol5); it adjusts W and joins that
;   handler.  The SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
C0mbinati0nM0de_Page2_Button21:   ; entry: named by 1 `.long` operand, first at 0xF915CF
	add W,0x01                                           ; F923A4  c8 c8 01
	bit	2, (UI_RequestBits:16)                               ; F923A7  f1 75 20 ca
	jr z, .LF923B0                                       ; F923AB  66 03
	add W,0x06                                           ; F923AD  c8 c8 06
.LF923B0:
	jp SoftKeyCol5_C0mbinati0nM0de_Page2_Join                                        ; F923B0  1b cf 1f f9
; C0mbinati0nM0de_Page2_Button22 -- DisplayListPtrs_F9157B slot 0x16, NOT NAMED: slot 0x16 is only the VARIANT-1 already-held rewrite of base code 0x05 (SoftKeyCol6); it adjusts W and joins that
;   handler.  The SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
C0mbinati0nM0de_Page2_Button22:   ; entry: named by 1 `.long` operand, first at 0xF915D3
	add W,0x01                                           ; F923B4  c8 c8 01
	bit	2, (UI_RequestBits:16)                               ; F923B7  f1 75 20 ca
	jr z, .LF923C0                                       ; F923BB  66 03
	add W,0x06                                           ; F923BD  c8 c8 06
.LF923C0:
	jp SoftKeyCol6_C0mbinati0nM0de_Page2_Join                                        ; F923C0  1b 2e 20 f9
; C0mbinati0nM0de_Page2_Button23 -- DisplayListPtrs_F9157B slot 0x17, NOT NAMED: slot 0x17 is only the VARIANT-1 already-held rewrite of base code 0x06 (SoftKeyCol7); it adjusts W and joins that
;   handler.  The SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
C0mbinati0nM0de_Page2_Button23:   ; entry: named by 1 `.long` operand, first at 0xF915D7
	add W,0x01                                           ; F923C4  c8 c8 01
	bit	2, (UI_RequestBits:16)                               ; F923C7  f1 75 20 ca
	jr z, .LF923D0                                       ; F923CB  66 03
	add W,0x06                                           ; F923CD  c8 c8 06
.LF923D0:
	jp SoftKeyCol7_C0mbinati0nM0de_Page2_Join                                        ; F923D0  1b 8d 20 f9
; C0mbinati0nM0de_Button24 -- slot 0x18 of both DisplayListPtrs_F914FB and _F9157B (COMBINATION MODE pages 1 and 2), NOT NAMED: slot 0x18 is only the VARIANT-1 already-held rewrite of base code 0x07 (SoftKeyCol8); it adjusts W and joins that
;   handler.  The SX-WSA1R is variant 2, so the slot is never delivered here (wave7_panel_names_round11).
C0mbinati0nM0de_Button24:   ; entry: named by 2 `.long` operands, first at 0xF9155B
	add W,0x01                                           ; F923D4  c8 c8 01
	bit	2, (UI_RequestBits:16)                               ; F923D7  f1 75 20 ca
	jr z, .LF923E0                                       ; F923DB  66 03
	add W,0x06                                           ; F923DD  c8 c8 06
.LF923E0:
	jp SoftKeyCol8_C0mbinati0nM0de_Join                                        ; F923E0  1b ec 20 f9
DisplayListPtrs_F9157B_Nop25:   ; entry: named by 1 `.long` operand, first at 0xF915DF
	ret                                                  ; F923E4  0e
DisplayListPtrs_F914FB_Nop26:   ; entry: named by 2 `.long` operands, first at 0xF91563
	ret                                                  ; F923E5  0e
DisplayListPtrs_F914FB_Nop27:   ; entry: named by 2 `.long` operands, first at 0xF91567
	ret                                                  ; F923E6  0e
DisplayListPtrs_F914FB_Nop28:   ; entry: named by 2 `.long` operands, first at 0xF9156B
	ret                                                  ; F923E7  0e
DisplayListPtrs_F914FB_Nop29:   ; entry: named by 2 `.long` operands, first at 0xF9156F
	ret                                                  ; F923E8  0e
DisplayListPtrs_F914FB_Nop30:   ; entry: named by 2 `.long` operands, first at 0xF91573
	ret                                                  ; F923E9  0e
DisplayListPtrs_F914FB_Nop31:   ; entry: named by 2 `.long` operands, first at 0xF91577
	ret                                                  ; F923EA  0e
sub_F923EB:
	ret                                                  ; F923EB  0e
; C0mbinati0nM0de_EditSelectedRow -- COMBINATION MODE page 2: steps the selected part's value in the highlighted row
; Evidence: E = (0x2250), XIY = entry (0x2250) of the part-record pointer table at 0xF2AB50 (0x76A2 + 0x40*k); then by (0x2678): bit 0 -> C0mbinati0nM0de_StepPartSound, bit 3 -> C0mbinati0nM0de_SetPartInt,
; bit 2 -> C0mbinati0nM0de_StepPartPan, bit 1 -> C0mbinati0nM0de_StepPartVol -- the SOUND / INT / PAN / VOL rows LcdKeyRow1..4_C0mbinati0nM0de_Page2 select.
; Called by C0mbinati0nM0de_SelectOrEditPart1..7 and _SelectOrEditPart8OrStepPart when the key's part is already selected; W carries the step (bit 7 = direction).
C0mbinati0nM0de_EditSelectedRow:
	ld l, (UI_PartIndex:16)                                   ; F923EC  c1 50 22 27
	ld E,L                                               ; F923F0  cf 8d
	xor H,H                                              ; F923F2  ce d6
	sla hl, 0x02                                         ; F923F4  db ec 02
	ld XIY,0x00f2ab50                                    ; F923F7  45 50 ab f2 00
	ld	xiy, (xiy+hl)                                ; F923FC  e3 07 f4 ec 25
	bit	0, (CombinationMode_EditRow:16)                               ; F92401  f1 78 26 c8
	jr nz, .LF9241B                                      ; F92405  6e 14
	bit	3, (CombinationMode_EditRow:16)                               ; F92407  f1 78 26 cb
	jr nz, .LF92420                                      ; F9240B  6e 13
	bit	2, (CombinationMode_EditRow:16)                               ; F9240D  f1 78 26 ca
	jr nz, .LF92425                                      ; F92411  6e 12
	bit	1, (CombinationMode_EditRow:16)                               ; F92413  f1 78 26 c9
	jr nz, .LF9242A                                      ; F92417  6e 11
	jr .LF9242D                                          ; F92419  68 12
.LF9241B:
	calr C0mbinati0nM0de_StepPartSound                                      ; F9241B  1e 10 00
	jr .LF9242D                                          ; F9241E  68 0d
.LF92420:
	calr C0mbinati0nM0de_SetPartInt                                          ; F92420  1e 42 02
	jr .LF9242D                                          ; F92423  68 08
.LF92425:
	calr C0mbinati0nM0de_StepPartPan                                          ; F92425  1e 6b 02
	jr .LF9242D                                          ; F92428  68 03
.LF9242A:
	calr C0mbinati0nM0de_StepPartVol                                          ; F9242A  1e 9c 02
.LF9242D:
	ret                                                  ; F9242D  0e
; C0mbinati0nM0de_StepPartSound -- steps the selected part's sound one place: member within group, carrying into group and then bank at the ends
; Evidence: XIY = PartRecord_GetSecondHalfPtr (0xF2ABD0 entry (0x2250) = record + 0x20); +0x1D bank, +0x1B group, +0x1C member go to (0x2682)/(0x2683)/(0x2684). The member steps within 0..T_SoundGroup_MaxMemberIndex_Get (Value_StepWordClamped clamps DE to [IY,IX]);
; at its limit the group steps (limit 0x0F; (0x08E8)-1 for bank 0x10; 1, or 0 for UD, in the drum banks), and at that limit the bank steps through ValueList_F92618 / ValueList_F92623 (chosen by (0x08EC) bit 0) --
; 00 01 08 09 [10] 20 28 29 18 19 1A, which DLText_PartCodes draws as R1- R2- U1- U2- [E1-] RD1 UD1 UD2 M1- M2- M3-.
; Posts T_List2030_AppendRegs {E=part, D=0, A=bank, W=bank} and {E=part, D=0, A=group, W=member}; the record bytes are the +0x3B..+0x3D that C0mbinati0nM0de_DrawPart8Sound draws.
C0mbinati0nM0de_StepPartSound:
	and W,0x81                                           ; F9242E  c8 cc 81
	push W                                               ; F92431  c8 04
	calr PartRecord_GetSecondHalfPtr                                          ; F92433  1e 17 21
	ld H,(XIY+0x1c)                                      ; F92436  8d 1c 26
	and H,0xff                                           ; F92439  ce cc ff
	ld L,(XIY+0x1b)                                      ; F9243C  8d 1b 27
	and L,0xff                                           ; F9243F  cf cc ff
	ld W,(XIY+0x1d)                                      ; F92442  8d 1d 20
	and W,0xff                                           ; F92445  c8 cc ff
	ld (0x2682:16), w                                   ; F92448  f1 82 26 40
	ld (0x2683:16), l                                   ; F9244C  f1 83 26 47
	ld (0x2684:16), h                                   ; F92450  f1 84 26 46
	ld A,L                                               ; F92454  cf 89
	ld b, (UI_PartIndex:16)                                   ; F92456  c1 50 22 22
	call T_SoundGroup_MaxMemberIndex_Get                 ; F9245A  1d 1c 10 f4
	ld (0x2685:16), a                                   ; F9245E  f1 85 26 41
	extz WA                                              ; F92462  d8 12
	ld IX,WA                                             ; F92464  d8 8c
	ldw iy, 0x00                                         ; F92466  35 00 00
	pop W                                                ; F92469  c8 05
	ld l, (0x2684:16)                                   ; F9246B  c1 84 26 27
	extz HL                                              ; F9246F  db 12
	ld DE,HL                                             ; F92471  db 8a
	push W                                               ; F92473  c8 04
	pushw hl                                             ; F92475  2b
	call Value_StepWordClamped                                        ; F92476  1d b0 45 f9
	popw hl                                              ; F9247A  4b
	pop W                                                ; F9247B  c8 05
	cp DE,HL                                             ; F9247D  db f2
	jrl nz, .LF925EF                                     ; F9247F  7e 6d 01
	cp	(0x2682:16), 0x10                            ; F92482  c1 82 26 3f 10
	jr nz, .LF92495                                      ; F92487  6e 0c
	ld c, (0x08e8:16)                                   ; F92489  c1 e8 08 23
	dec 1,C                                              ; F9248D  cb 69
	xor B,B                                              ; F9248F  ca d2
	ld IX,BC                                             ; F92491  d9 8c
	jr .LF924B2                                          ; F92493  68 1d
.LF92495:
	bit	4, (0x2682:16)                               ; F92495  f1 82 26 cc
	jr nz, .LF924AF                                      ; F92499  6e 14
	bit	5, (0x2682:16)                               ; F9249B  f1 82 26 cd
	jr z, .LF924AF                                       ; F9249F  66 0e
	ldw ix, 0x01                                         ; F924A1  34 01 00
	bit	3, (0x2682:16)                               ; F924A4  f1 82 26 cb
	jr z, .LF924B2                                       ; F924A8  66 08
	ldw ix, 0x00                                         ; F924AA  34 00 00
	jr .LF924B2                                          ; F924AD  68 03
.LF924AF:
	ldw ix, 0x0f                                         ; F924AF  34 0f 00
.LF924B2:
	ldw iy, 0x00                                         ; F924B2  35 00 00
	ld e, (0x2683:16)                                   ; F924B5  c1 83 26 25
	extz DE                                              ; F924B9  da 12
	ld HL,DE                                             ; F924BB  da 8b
	push W                                               ; F924BD  c8 04
	pushw hl                                             ; F924BF  2b
	call Value_StepWordClamped                                        ; F924C0  1d b0 45 f9
	popw hl                                              ; F924C4  4b
	pop W                                                ; F924C5  c8 05
	cp DE,HL                                             ; F924C7  db f2
	jrl nz, .LF92597                                     ; F924C9  7e cb 00
	ld XIX,ValueList_F92618                              ; F924CC  44 18 26 f9 00
	bit	0, (0x08ec:16)                               ; F924D1  f1 ec 08 c8
	jr nz, .LF924DC                                      ; F924D5  6e 05
	ld XIX,ValueList_F92623                              ; F924D7  44 23 26 f9 00
.LF924DC:
	ld l, (0x2682:16)                                   ; F924DC  c1 82 26 27
	xor DE,DE                                            ; F924E0  da d2
.LF924E2:
	cp	l, (xix+de)                          ; F924E2  c3 07 f0 e8 f7
	jr z, .LF924ED                                       ; F924E7  66 04
	inc 1,DE                                             ; F924E9  da 61
	jr .LF924E2                                          ; F924EB  68 f5
.LF924ED:
	ld HL,DE                                             ; F924ED  da 8b
	ldw ix, 0x0a                                         ; F924EF  34 0a 00
	bit	0, (0x08ec:16)                               ; F924F2  f1 ec 08 c8
	jr nz, .LF924FB                                      ; F924F6  6e 03
	ldw ix, 0x09                                         ; F924F8  34 09 00
.LF924FB:
	ldw iy, 0x00                                         ; F924FB  35 00 00
	push W                                               ; F924FE  c8 04
	pushw hl                                             ; F92500  2b
	call Value_StepWordClamped                                        ; F92501  1d b0 45 f9
	popw hl                                              ; F92505  4b
	pop W                                                ; F92506  c8 05
	cp DE,HL                                             ; F92508  db f2
	jrl z, .LF92617                                      ; F9250A  76 0a 01
	ld XIX,ValueList_F92618                              ; F9250D  44 18 26 f9 00
	bit	0, (0x08ec:16)                               ; F92512  f1 ec 08 c8
	jr nz, .LF9251D                                      ; F92516  6e 05
	ld XIX,ValueList_F92623                              ; F92518  44 23 26 f9 00
.LF9251D:
	ld	a, (xix+de)                                  ; F9251D  c3 07 f0 e8 21
	ld (0x2682:16), a                                   ; F92522  f1 82 26 41
	bit 0x07,W                                           ; F92526  c8 33 07
	jr z, .LF9258B                                       ; F92529  66 60
	cp	(0x2682:16), 0x10                            ; F9252B  c1 82 26 3f 10
	jr nz, .LF92555                                      ; F92530  6e 23
	push W                                               ; F92532  c8 04
	ld c, (0x08e8:16)                                   ; F92534  c1 e8 08 23
	dec 1,C                                              ; F92538  cb 69
	ld (0x2683:16), c                                   ; F9253A  f1 83 26 43
	ld A,C                                               ; F9253E  cb 89
	ld w, (0x2682:16)                                   ; F92540  c1 82 26 20
	ld b, (UI_PartIndex:16)                                   ; F92544  c1 50 22 22
	call T_SoundGroup_MaxMemberIndex_Get                 ; F92548  1d 1c 10 f4
	pop W                                                ; F9254C  c8 05
	ld (0x2684:16), a                                   ; F9254E  f1 84 26 41
	jrl .LF925F3                                         ; F92552  78 9e 00
.LF92555:
	bit	4, (0x2682:16)                               ; F92555  f1 82 26 cc
	jr nz, .LF9257F                                      ; F92559  6e 24
	bit	5, (0x2682:16)                               ; F9255B  f1 82 26 cd
	jr z, .LF9257F                                       ; F9255F  66 1e
	ld (0x2683:16), 0x01                                 ; F92561  f1 83 26 00 01
	bit	3, (0x2682:16)                               ; F92566  f1 82 26 cb
	jr z, .LF92578                                       ; F9256A  66 0c
	ld (0x2683:16), 0x00                                 ; F9256C  f1 83 26 00 00
	ld (0x2684:16), 0x01                                 ; F92571  f1 84 26 00 01
	jr .LF925F3                                          ; F92576  68 7b
.LF92578:
	ld (0x2684:16), 0x07                                 ; F92578  f1 84 26 00 07
	jr .LF925F3                                          ; F9257D  68 74
.LF9257F:
	ld (0x2684:16), 0x07                                 ; F9257F  f1 84 26 00 07
	ld (0x2683:16), 0x0f                                 ; F92584  f1 83 26 00 0f
	jr .LF925F3                                          ; F92589  68 68
.LF9258B:
	ld (0x2683:16), 0x00                                 ; F9258B  f1 83 26 00 00
	ld (0x2684:16), 0x00                                 ; F92590  f1 84 26 00 00
	jr .LF925F3                                          ; F92595  68 5c
.LF92597:
	ld (0x2683:16), e                                   ; F92597  f1 83 26 45
	bit 0x07,W                                           ; F9259B  c8 33 07
	jr z, .LF925E8                                       ; F9259E  66 48
	cp	(0x2682:16), 0x10                            ; F925A0  c1 82 26 3f 10
	jr nz, .LF925C1                                      ; F925A5  6e 1a
	push W                                               ; F925A7  c8 04
	ld a, (0x2683:16)                                   ; F925A9  c1 83 26 21
	ld w, (0x2682:16)                                   ; F925AD  c1 82 26 20
	ld b, (UI_PartIndex:16)                                   ; F925B1  c1 50 22 22
	call T_SoundGroup_MaxMemberIndex_Get                 ; F925B5  1d 1c 10 f4
	pop W                                                ; F925B9  c8 05
	ld (0x2684:16), a                                   ; F925BB  f1 84 26 41
	jr .LF925F3                                          ; F925BF  68 32
.LF925C1:
	bit	4, (0x2682:16)                               ; F925C1  f1 82 26 cc
	jr nz, .LF925E1                                      ; F925C5  6e 1a
	bit	5, (0x2682:16)                               ; F925C7  f1 82 26 cd
	jr z, .LF925E1                                       ; F925CB  66 14
	bit	3, (0x2682:16)                               ; F925CD  f1 82 26 cb
	jr z, .LF925DA                                       ; F925D1  66 07
	ld (0x2684:16), 0x01                                 ; F925D3  f1 84 26 00 01
	jr .LF925F3                                          ; F925D8  68 19
.LF925DA:
	ld (0x2684:16), 0x07                                 ; F925DA  f1 84 26 00 07
	jr .LF925F3                                          ; F925DF  68 12
.LF925E1:
	ld (0x2684:16), 0x07                                 ; F925E1  f1 84 26 00 07
	jr .LF925F3                                          ; F925E6  68 0b
.LF925E8:
	ld (0x2684:16), 0x00                                 ; F925E8  f1 84 26 00 00
	jr .LF925F3                                          ; F925ED  68 04
.LF925EF:
	ld (0x2684:16), e                                   ; F925EF  f1 84 26 45
.LF925F3:
	ld e, (UI_PartIndex:16)                                   ; F925F3  c1 50 22 25
	ld d, 0x00:opc                                          ; F925F7  24 00
	ld a, (0x2682:16)                                   ; F925F9  c1 82 26 21
	ld w, (0x2682:16)                                   ; F925FD  c1 82 26 20
	call T_List2030_AppendRegs                           ; F92601  1d 40 0f f4
	ld e, (UI_PartIndex:16)                                   ; F92605  c1 50 22 25
	ld d, 0x00:opc                                          ; F92609  24 00
	ld a, (0x2683:16)                                   ; F9260B  c1 83 26 21
	ld w, (0x2684:16)                                   ; F9260F  c1 84 26 20
	call T_List2030_AppendRegs                           ; F92613  1d 40 0f f4
.LF92617:
	ret                                                  ; F92617  0e
; ---------------------------------------------------------------------
; ValueList_F92618 -- 11 bytes: 00 01 08 09 10 20 28 29 18 19 1A
; Read by: 0xF924CC and 0xF9250D, both `ld XIX,0x00F92618`, each the
;          bit-SET arm of `bit 0,(0x08EC)`; the clear arm loads
;          ValueList_F92623.  The search is
;          `L = (0x2682) / DE = 0 / cp L,(XIX+DE) / jr z / inc DE / loop`,
;          i.e. FIND THE INDEX of the current value in this list.
; ENTRY COUNT 11 is the READER'S BOUND, not the extent: having found the
;          index, 0xF924EF loads `IX = 0x000A` on this arm (0x0009 on the
;          other) and calls Value_StepWordClamped, which CLAMPS its result to
;          [IY, IX] -- so 0x0A is the last legal index and the list has
;          eleven entries.  The extent agrees: 0xF92623 is the other
;          list's base.
; Unknown:  what the values mean.  They are not an index space -- 0x00,
;          0x01, 0x08, 0x09, 0x10, 0x20, 0x28, 0x29, 0x18, 0x19, 0x1A --
;          and (0x2682) is written back with the chosen one at 0xF92522.
; ---------------------------------------------------------------------

ValueList_F92618:
	.byte 0x00, 0x01, 0x08, 0x09, 0x10, 0x20, 0x28, 0x29, 0x18, 0x19, 0x1a    ; F92618
; ---------------------------------------------------------------------
; ValueList_F92623 -- 10 bytes: 00 01 08 09 20 28 29 18 19 1A
; Read by: 0xF924D7 and 0xF92518, the `bit 0,(0x08EC)` CLEAR arm.
; ENTRY COUNT 10 is the reader's bound: the same call site loads
;          `IX = 0x0009` on this arm.
; ★ It is ValueList_F92618 with 0x10 removed -- one value that the
;          (0x08EC) bit 0 state does not offer.  That is what the two
;          lists differ by, byte for byte, and --check asserts it.
; ---------------------------------------------------------------------

ValueList_F92623:
	.byte 0x00, 0x01, 0x08, 0x09, 0x20, 0x28, 0x29, 0x18, 0x19, 0x1a          ; F92623
; C0mbinati0nM0de_ShowSelectedPart -- COMBINATION MODE page 2: draws "PART<n>" for the selected part and moves the highlight box to its PTn label
; Evidence: skipped when (0x2250) == (0x267E). Layer 0: record 0xF296D6 (T_DLB_Handler_StringTable2) draws entry (0x2250) & 7 of DLTable_F296E7 ("PART1".."PART8") at (0x4D,0x1B).
; Layer 1: record 0xF2970F ((0x267E) & 7, swi 0x1B EraseRect) and record 0xF2971A ((0x2250) & 7, swi 0x05 FillRect), both indexing DLTable_F29725 -- boxes at y 0xE2-0xEC under the PT1..PT8 labels (y 0xE4); then (0x267E) = (0x2250).
; Called by sub_F916AA (the page-2 painter) and C0mbinati0nM0de_ShowSelectedPartSoundName (posted after a part is selected).
C0mbinati0nM0de_ShowSelectedPart:
	ld a, (UI_PartIndex:16)                                   ; F9262D  c1 50 22 21
	cp	a, (CombinationMode_ShownPart:16)                               ; F92631  c1 7e 26 f1
	jr z, .LF92664                                       ; F92635  66 2d
	ld (LCD_CurrentLayer:16), 0x00                                 ; F92637  f1 40 25 00 00
	ld XIY,0x00f296d6                                    ; F9263C  45 d6 96 f2 00
	call T_DLB_Handler_StringTable2                      ; F92641  1d fc 17 f4
	ld (LCD_CurrentLayer:16), 0x01                                 ; F92645  f1 40 25 00 01
	ld XIY,0x00f2970f                                    ; F9264A  45 0f 97 f2 00
	call T_DLB_Handler_Array8_2                                        ; F9264F  1d 20 18 f4
	ld XIY,0x00f2971a                                    ; F92653  45 1a 97 f2 00
	call T_DLB_Handler_Array8                                        ; F92658  1d 1c 18 f4
	ld a, (UI_PartIndex:16)                                   ; F9265C  c1 50 22 21
	ld (CombinationMode_ShownPart:16), a                                   ; F92660  f1 7e 26 41
.LF92664:
	ret                                                  ; F92664  0e
; C0mbinati0nM0de_SetPartInt -- sets (key position 0) or clears (position 1) the INT flag, bit 5 of record +0x0D of the part in XIY, and posts the change
; Evidence: A = (XIY+0x0D) & 0x20; W bit 7 set: `or (XIY+0x0D),0x20` unless already set; clear: `and (XIY+0x0D),0xDF` unless already clear; then T_Queue2E00_AppendRegs with D = 0x0D, W = 0x20 (the mask), A = the new bit, E = the caller's part.
; Callers: C0mbinati0nM0de_EditSelectedRow (INT row, (0x2678) bit 3) and sub_F9139B (soft-key column 7, under "INT" in both the SOUND MODE and the page-1 column captions). C0mbinati0nM0de_DrawPart1Int..8Int draw this bit.
C0mbinati0nM0de_SetPartInt:
	ld A,(XIY+0x0d)                                      ; F92665  8d 0d 21
	and A,0x20                                           ; F92668  c9 cc 20
	bit 0x07,W                                           ; F9266B  c8 33 07
	jr nz, .LF9267E                                      ; F9266E  6e 0e
	cp A,0x20                                            ; F92670  c9 cf 20
	jr nz, .LF92692                                      ; F92673  6e 1d
	and (XIY+0x0d),0xdf                                  ; F92675  8d 0d 3c df
	and A,0xdf                                           ; F92679  c9 cc df
	jr .LF9268A                                          ; F9267C  68 0c
.LF9267E:
	cp A,0x20                                            ; F9267E  c9 cf 20
	jr z, .LF92692                                       ; F92681  66 0f
	or	(xiy+13), 0x20                               ; F92683  8d 0d 3e 20
	or A,0x20                                            ; F92687  c9 ce 20
.LF9268A:
	ld w, 0x20:opc                                          ; F9268A  20 20
	ld d, 0x0d:opc                                          ; F9268C  24 0d
	call T_Queue2E00_AppendRegs                          ; F9268E  1d 3c 0f f4
.LF92692:
	ret                                                  ; F92692  0e
; C0mbinati0nM0de_StepPartPan -- steps record +0x08 (pan) of the part in XIY by the key's step, clamped to 0..127, and posts the new value
; Evidence: A = (XIY+0x08), B = 0x7F, C = 0, D = 0x08, H = 0x7F, calr Value_StepAndPostIfChanged (T_Value_ApplyNibbleDeltaClamped; if the value changed, T_List2030_AppendRegs {E=caller's part, D=8, A=new, W=0x7F}) -- the record byte itself is not written here.
; Callers: C0mbinati0nM0de_EditSelectedRow (PAN row) and sub_F91275 (soft-key column 3, under "PAN", when (0x207C) != 1). C0mbinati0nM0de_DrawPart1Pan..8Pan draw this byte.
C0mbinati0nM0de_StepPartPan:
	ld A,(XIY+0x08)                                      ; F92693  8d 08 21
	ld b, 0x7f:opc                                          ; F92696  22 7f
	ld c, 0x00:opc                                          ; F92698  23 00
	ld d, 0x08:opc                                          ; F9269A  24 08
	ld h, 0x7f:opc                                          ; F9269C  26 7f
	calr Value_StepAndPostIfChanged                                          ; F9269E  1e c0 1e
	ret                                                  ; F926A1  0e
; SoundMode_StepPan -- SOUND MODE soft-key column 3 ("PAN"): steps (0x0711) by the key's step, clamped to 0..127, and posts it
; Evidence: called only by sub_F91275 when (0x207C) == 1 -- screen id 1, whose painter runs DL_F27C00 ("SOUND MODE", columns OCT LVL PAN EFF1 EFF2 REV INT MIDI). T_Value_ApplyNibbleDeltaClamped with B = 0x7F, C = 0; if changed, (0x0711) = A and T_Queue2E00_AppendRegs {E=0xA8, D=0x13, A, W=0x7F}.
; sub_F90E4B draws (0x0711) at 0xF90ED0 through the same pan string-table record (0xF28468) as the combination PAN column, and SoundMode_ResetPan resets it to 0x40 with the same {0xA8,0x13} event.
SoundMode_StepPan:
	ld a, (0x0711:16)                                   ; F926A2  c1 11 07 21
	ld b, 0x7f:opc                                          ; F926A6  22 7f
	ld c, 0x00:opc                                          ; F926A8  23 00
	ld L,A                                               ; F926AA  c9 8f
	push W                                               ; F926AC  c8 04
	pushw hl                                             ; F926AE  2b
	call T_Value_ApplyNibbleDeltaClamped                                        ; F926AF  1d 04 1b f4
	popw hl                                              ; F926B3  4b
	pop W                                                ; F926B4  c8 05
	cp A,L                                               ; F926B6  cf f1
	jr z, .LF926C8                                       ; F926B8  66 0e
	ld (0x0711:16), a                                   ; F926BA  f1 11 07 41
	ld w, 0x7f:opc                                          ; F926BE  20 7f
	ld e, 0xa8:opc                                          ; F926C0  25 a8
	ld d, 0x13:opc                                          ; F926C2  24 13
	call T_Queue2E00_AppendRegs                          ; F926C4  1d 3c 0f f4
.LF926C8:
	ret                                                  ; F926C8  0e
; C0mbinati0nM0de_StepPartVol -- steps record +0x03 (volume) of the part in XIY by the key's step, clamped to 0..127, and posts the new value
; Evidence: A = (XIY+0x03), B = 0x7F, C = 0, D = 3, H = 0x7F; a step magnitude of 7 is raised to 10 (`cp L,0x07 / inc 3,W` at 0xF926D9); calr Value_StepAndPostIfChanged (T_Value_ApplyNibbleDeltaClamped, then T_List2030_AppendRegs {E=part, D=3, A=new, W=0x7F} if changed).
; Callers: C0mbinati0nM0de_EditSelectedRow (VOL row) and sub_F91247 (soft-key column 2, under "VOL", when (0x207C) != 1). C0mbinati0nM0de_DrawPart1Vol..8Vol draw this byte.
C0mbinati0nM0de_StepPartVol:
	ld A,(XIY+0x03)                                      ; F926C9  8d 03 21
	ld b, 0x7f:opc                                          ; F926CC  22 7f
	ld c, 0x00:opc                                          ; F926CE  23 00
	ld d, 0x03:opc                                          ; F926D0  24 03
	ld h, 0x7f:opc                                          ; F926D2  26 7f
	ld L,W                                               ; F926D4  c8 8f
	and L,0x0f                                           ; F926D6  cf cc 0f
	cp l, 0x07:i3                                          ; F926D9  cf df
	jr nz, .LF926DF                                      ; F926DB  6e 02
	inc 3,W                                              ; F926DD  c8 63
.LF926DF:
	calr Value_StepAndPostIfChanged                                          ; F926DF  1e 7f 1e
	ret                                                  ; F926E2  0e
; SoundMode_StepLvl -- SOUND MODE soft-key column 2 ("LVL"): steps (0x0710) by the key's step within -30..+30 and posts it
; Evidence: called only by sub_F91247 when (0x207C) == 1 (SOUND MODE; DL_F27C00's second column caption is "LVL"). A = (0x0710) + 0x1E, T_Value_ApplyNibbleDeltaClamped with B = 0x3C, C = 0; if changed, (0x0710) = A - 0x1E and T_Queue2E00_AppendRegs {E=0xA8, D=0x12, A, W=0x7F}.
; 0xF90EB4 draws (0x0710) + 0x1E through T_DLB_Handler_DecimalSigned2Words, and SoundMode_ResetLvl resets it to 0 with the same {0xA8,0x12} event.
SoundMode_StepLvl:
	ld a, (0x0710:16)                                   ; F926E3  c1 10 07 21
	add A,0x1e                                           ; F926E7  c9 c8 1e
	ld b, 0x3c:opc                                          ; F926EA  22 3c
	ld c, 0x00:opc                                          ; F926EC  23 00
	ld L,A                                               ; F926EE  c9 8f
	push W                                               ; F926F0  c8 04
	pushw hl                                             ; F926F2  2b
	call T_Value_ApplyNibbleDeltaClamped                                        ; F926F3  1d 04 1b f4
	popw hl                                              ; F926F7  4b
	pop W                                                ; F926F8  c8 05
	cp A,L                                               ; F926FA  cf f1
	jr z, .LF9270F                                       ; F926FC  66 11
	sub A,0x1e                                           ; F926FE  c9 ca 1e
	ld (0x0710:16), a                                   ; F92701  f1 10 07 41
	ld w, 0x7f:opc                                          ; F92705  20 7f
	ld e, 0xa8:opc                                          ; F92707  25 a8
	ld d, 0x12:opc                                          ; F92709  24 12
	call T_Queue2E00_AppendRegs                          ; F9270B  1d 3c 0f f4
.LF9270F:
	ret                                                  ; F9270F  0e
; ---------------------------------------------------------------------
; InstallPainter_SoundGroupMenu_Entry -- a PURE WRAPPER for InstallPainter_SoundGroupMenu: it IS that
; routine, so it is named for it.  Its whole extent is
; one `calr` and the `ret` that follows it, and the routine
; ends at 0xF92714, where the next top-level label begins.
; Evidence: the `calr` at 0xF92710 targets 0xF927A6, which carries the
;          label InstallPainter_SoundGroupMenu.  The extent is measured to the next top-level
;          label, never to a source line -- notes/wave7-verify-probes/
;          wave7_r5_prom_a_painter_scope.py records what scoping to a
;          source line cost the round-5 pass.
; ---------------------------------------------------------------------

InstallPainter_SoundGroupMenu_Entry:
	calr InstallPainter_SoundGroupMenu                                            ; F92710  1e 93 00
	ret                                                  ; F92713  0e
; ---------------------------------------------------------------------
; ScreenLeave_SoundGroupMenu -- the LEAVE method of the screen object at
;          PanelScreen_VtableTable entry 0xC0, i.e. SCREEN ID 0xA0 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0xC0 -> the screen object at
;          0xF41540, whose +4 slot is `jp 0xF92714`, and from no other live
;          screen object's two callable slots.
; Evidence: the +4 offset is PanelScreen_VtableTable's own (its header's
;          checks V1-V6): +0 ENTER is called by PanelScreen_CallEnter_A/B, +4
;          LEAVE by PanelScreen_CallLeave_A/B with the id that just STOPPED
;          being current, +8 BUTTON by PanelButton_Route (0xF8621E).
; Screen:   SoundGroupMenu -- inherited from the +0 ENTER label
;          InstallPainter_SoundGroupMenu_Entry, not from any text this pass
;          read.
; Was `sub_F92714`.
; ---------------------------------------------------------------------
ScreenLeave_SoundGroupMenu:
	calr ScreenLeave_SoundGroupMenu_Nop                                          ; F92714  1e 3d 03
	ret                                                  ; F92717  0e
; ---------------------------------------------------------------------
; ScreenButton_SoundGroupMenu -- the BUTTON method of the screen object at
;          PanelScreen_VtableTable entry 0xC0, i.e. SCREEN ID 0xA0 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0xC0 -> the screen object at
;          0xF41540, whose +8 slot is `jp 0xF92718`, and from no other live
;          screen object's two callable slots.
; Evidence: the +8 offset is PanelScreen_VtableTable's own (its header's
;          checks V1-V6): +0 ENTER is called by PanelScreen_CallEnter_A/B, +4
;          LEAVE by PanelScreen_CallLeave_A/B with the id that just STOPPED
;          being current, +8 BUTTON by PanelButton_Route (0xF8621E).
; Screen:   SoundGroupMenu -- inherited from the +0 ENTER label
;          InstallPainter_SoundGroupMenu_Entry, not from any text this pass
;          read.
; Was `sub_F92718`.
; ---------------------------------------------------------------------
ScreenButton_SoundGroupMenu:
	ld XIX,DisplayListPtrs_F92726                        ; F92718  44 26 27 f9 00
	call T_PanelButton_CallTableEntry                                        ; F9271D  1d 08 1b f4
	ret                                                  ; F92721  0e
sub_F92722:
	calr sub_F92C4F                                          ; F92722  1e 2a 05
	ret                                                  ; F92725  0e
; ---------------------------------------------------------------------
; DisplayListPtrs_F92726 -- 32 LE32 pointers
; Read by: ONE site, 0xF92718 `ld XIX,0x00F92726 / call T_PanelButton_CallTableEntry`.
; ENTRY COUNT 32 is the callee's bound (0xF8BDC5 `cp HL,0x001F`).
; ---------------------------------------------------------------------

DisplayListPtrs_F92726:
	.long SoundBank_SelectR1OrU1                                 ; F92726  [  0]
	.long SoundBank_SelectR2OrU2                                 ; F9272A  [  1]
	.long SoundBank_SelectDrum                                 ; F9272E  [  2]
	.long SoundBank_SelectExt                                 ; F92732  [  3]
	.long SoundGroup_StepSelected                                 ; F92736  [  4]
	.long SoftKeyCol6_SoundGroupMenu                                 ; F9273A  [  5]
	.long DisplayListPtrs_F92726_Nop6                                 ; F9273E  [  6]
	.long DisplayListPtrs_F92726_Nop7                                 ; F92742  [  7]
	.long LcdKeyRow1_SoundGroupMenu                                 ; F92746  [  8]
	.long LcdKeyRow2_SoundGroupMenu                                 ; F9274A  [  9]
	.long LcdKeyRow3_SoundGroupMenu                                 ; F9274E  [ 10]
	.long DisplayListPtrs_F92726_Nop11                                 ; F92752  [ 11]
	.long DisplayListPtrs_F92726_Nop12                                 ; F92756  [ 12]
	.long DisplayListPtrs_F92726_Nop13                                 ; F9275A  [ 13]
	.long DisplayListPtrs_F92726_Nop14                                 ; F9275E  [ 14]
	.long ExitKey_SoundGroupMenu                                 ; F92762  [ 15]
	.long DisplayListPtrs_F914FB_Nop8                                 ; F92766  [ 16]
	.long SoundBank_SelectR1OrU1                                 ; F9276A  [ 17]
	.long SoundBank_SelectR2OrU2                                 ; F9276E  [ 18]
	.long SoundBank_SelectDrum                                 ; F92772  [ 19]
	.long SoundBank_SelectExt                                 ; F92776  [ 20]
	.long SoundGroup_StepSelected                                 ; F9277A  [ 21]
	.long SoftKeyCol6_SoundGroupMenu                                 ; F9277E  [ 22]
	.long DisplayListPtrs_F92726_Nop6                                 ; F92782  [ 23]
	.long DisplayListPtrs_F92726_Nop7                                 ; F92786  [ 24]
	.long DisplayListPtrs_F914FB_Nop8                                 ; F9278A  [ 25]
	.long DisplayListPtrs_F914FB_Nop8                                 ; F9278E  [ 26]
	.long DisplayListPtrs_F914FB_Nop8                                 ; F92792  [ 27]
	.long DisplayListPtrs_F914FB_Nop8                                 ; F92796  [ 28]
	.long DisplayListPtrs_F914FB_Nop8                                 ; F9279A  [ 29]
	.long DisplayListPtrs_F914FB_Nop8                                 ; F9279E  [ 30]
	.long DisplayListPtrs_F914FB_Nop8                                 ; F927A2  [ 31]
; InstallPainter_SoundGroupMenu -- paints the screen whose own text reads "SOUND", "GROUP", "MENU"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 2 time(s); XIY = list start, XIX = list end.  1 of those 2 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xF92828  interpreter A  list 0xF2B130  DL_SoundGroupMenuReMap1ReMap2
;        text: "SOUND"; "GROUP"; "MENU"; "1."; "9."; "2."
; Evidence: the list address is the `ld XIY,0x00F2B130` IMMEDIATE at the
;          instruction two before the cited `call`, and the text quoted
;          above is the `.ascii` the interpreter draws verbatim.  Every
;          alphabetic morpheme of this name occurs in that text; the
;          check is notes/prom_a_understanding_round5.py --morphemes.
;          `Paint_` is a structural verb, not ROM text.
;          ⚠ ROUND 5: where the label reads `InstallPainter_`, the body contains
;          ZERO display-list calls -- it INSTALLS the callback that paints this
;          screen, through `call 0xF42E84`. The screen association is real one hop
;          away; the earlier `Paint_` verb claimed the body did the drawing and it
;          does not. Any display-list COUNT in a header above such a label is the
;          installed callback's, not this routine's.
; Unknown: whether this routine also handles input for the screen, and
;          whether any other routine paints it.  Neither was searched.
; ---------------------------------------------------------------------
InstallPainter_SoundGroupMenu:
	or	(0xc6:8), 0x01                               ; F927A6  c0 c6 3e 01
	ld a, (UI_ScreenId:16)                                   ; F927AA  c1 7c 20 21
	cp (UI_ScreenId_Previous:16), a                                    ; F927AE  c1 7d 20 f9
	jr z, .LF927D1                                       ; F927B2  66 1d
	and	(UI_ScreenFlags:16), 0xef                            ; F927B4  c1 95 20 3c ef
	ld XWA,0xffffffff                                    ; F927B9  40 ff ff ff ff
	ld (0x2666:16), xwa                                 ; F927BE  f1 66 26 60
	ld (0x266a:16), xwa                                 ; F927C2  f1 6a 26 60
	ldw (PanelDial_DownButton:16), 0x0484                              ; F927C6  f1 9b 20 02 84 04
	or	(UI_RequestBits:16), 0x01                            ; F927CC  c1 75 20 3e 01
.LF927D1:
	bit	4, (UI_ScreenFlags:16)                               ; F927D1  f1 95 20 cc
	jr nz, .LF927ED                                      ; F927D5  6e 16
	call T_CallbackQueue_ResetAndRestartTask2            ; F927D7  1d 80 2e f4
	ld XWA,Draw_SoundGroupMenuReMap1ReMap2                                    ; F927DB  40 00 28 f9 00
	push XWA                                             ; F927E0  38
	call T_CallbackQueue_Post                            ; F927E1  1d 84 2e f4
	inc 4,XSP                                            ; F927E5  ef 64
	ld a, 0x01:opc                                          ; F927E7  21 01
	call T_Kernel_SemaSignal                             ; F927E9  1d 88 2d f4
.LF927ED:
	ld XWA,SoundGroupMenu_MoveGroupHighlight                                    ; F927ED  40 ae 28 f9 00
	push XWA                                             ; F927F2  38
	call T_CallbackQueue_Post                            ; F927F3  1d 84 2e f4
	inc 4,XSP                                            ; F927F7  ef 64
	ld a, 0x01:opc                                          ; F927F9  21 01
	call T_Kernel_SemaSignal                             ; F927FB  1d 88 2d f4
	ret                                                  ; F927FF  0e
Draw_SoundGroupMenuReMap1ReMap2:   ; entry: named by 1 `ld` operand, first at 0xF927DB
	ld a, 0x0f:opc                                          ; F92800  21 0f
	swi 7                                                ; F92802  ff
	xor C,C                                              ; F92803  cb d3
	ld a, 0x0c:opc                                          ; F92805  21 0c
	swi 7                                                ; F92807  ff
	ld (LCD_CurrentLayer:16), 0x00                                 ; F92808  f1 40 25 00 00
	ld XIY,Draw_SoundGroupMenuReMap1ReMap2_DL                                     ; F9280D  45 81 af f2 00
	ld XIX,DL_SoundGroupMenuReMap1ReMap2                 ; F92812  44 30 b1 f2 00
	calr SoundBank_IsReMap                                          ; F92817  1e 6d 09
	cp a, 0x01:i3                                          ; F9281A  c9 d9
	jr nz, .LF92828                                      ; F9281C  6e 0a
	ld XIY,DL_SoundGroupMenuReMap1ReMap2                 ; F9281E  45 30 b1 f2 00
	ld XIX,0x00f2b2e3                                    ; F92823  44 e3 b2 f2 00
.LF92828:
	call T_DisplayList_Run                               ; F92828  1d f0 17 f4
	ld (LCD_CurrentLayer:16), 0x01                                 ; F9282C  f1 40 25 00 01
	ld XIY,0x00f2b2e3                                    ; F92831  45 e3 b2 f2 00
	ld XIX,DLTable_F2B2F9                                ; F92836  44 f9 b2 f2 00
	calr SoundBank_IsReMap                                          ; F9283B  1e 49 09
	cp a, 0x01:i3                                          ; F9283E  c9 d9
	jr nz, .LF9284C                                      ; F92840  6e 0a
	ld XIY,DL_F2B379                                     ; F92842  45 79 b3 f2 00
	ld XIX,Data_F2B38F                                   ; F92847  44 8f b3 f2 00
.LF9284C:
	call T_DisplayListB_Run                              ; F9284C  1d f4 17 f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; F92850  f1 40 25 00 00
	ld e, 0x10:opc                                          ; F92855  25 10
	cp	(SoundSel_Bank:16), 0x10                            ; F92857  c1 6a 21 3f 10
	jr nz, .LF92862                                      ; F9285C  6e 04
	ld e, (0x08e8:16)                                   ; F9285E  c1 e8 08 25
.LF92862:
	xor D,D                                              ; F92862  cc d4
.LF92864:
	ld A,D                                               ; F92864  cc 89
	ld b, (UI_PartIndex:16)                                   ; F92866  c1 50 22 22
	ld w, (SoundSel_Bank:16)                                   ; F9286A  c1 6a 21 20
	push E                                               ; F9286E  cd 04
	push D                                               ; F92870  cc 04
	call T_SoundGroupName_Lookup                                        ; F92872  1d 18 10 f4
	pop D                                                ; F92876  cc 05
	push D                                               ; F92878  cc 04
	ld XIZ,0x00f2b40f                                    ; F9287A  46 0f b4 f2 00
	sla d, 0x01                                          ; F9287F  cc ec 01
	ld	ix, (xiz+d)                                  ; F92882  d3 03 f8 e9 24
	ldw hl, 0x00                                         ; F92887  33 00 00
	ldw bc, 0x10                                         ; F9288A  31 10 00
	ld a, 0x06:opc                                          ; F9288D  21 06
	swi 7                                                ; F9288F  ff
	pop D                                                ; F92890  cc 05
	inc 1,D                                              ; F92892  cc 61
	pop E                                                ; F92894  cd 05
	djnz8 e, .LF92864                                    ; F92896  cd 1c cb
	bit	3, (SoundSel_Bank:16)                               ; F92899  f1 6a 21 cb
	jr nz, .LF928A4                                      ; F9289D  6e 05
	calr Draw_Ext1                                      ; F9289F  1e 39 01
	jr .LF928A7                                          ; F928A2  68 03
.LF928A4:
	calr BankLegend_EraseRow                                      ; F928A4  1e 99 01
.LF928A7:
	calr Paint_Drum                                      ; F928A7  1e 31 00
	calr BankLegend_DrawUser                                      ; F928AA  1e 72 00
	ret                                                  ; F928AD  0e
; SoundGroupMenu_MoveGroupHighlight -- moves the SOUND GROUP MENU highlight box from the last-highlighted group to the selected group (0x2169)
; Evidence: (0x2640) = (0x2675), (0x2675) = (0x2169); on layer 1 record 0xF2B42F (op 03, swi 0x1B EraseRect) uses entry (0x2640) and record 0xF2B43A (op 03, swi 0x05 FillRect) entry (0x2169) of DLTable_F2B445, 16 boxes;
; then swi 0x0C with C = 7. Posted by InstallPainter_SoundGroupMenu (0xF927ED) after the painter. (0x2169) is the group SoundGroup_StepSelected steps.
SoundGroupMenu_MoveGroupHighlight:   ; entry: named by 1 `ld` operand, first at 0xF927ED
	ld a, (SoundGroupMenu_Highlight:16)                                   ; F928AE  c1 75 26 21
	ld (UI_DrawScratch:16), a                                   ; F928B2  f1 40 26 41
	ld a, (SoundSel_Group:16)                                   ; F928B6  c1 69 21 21
	ld (SoundGroupMenu_Highlight:16), a                                   ; F928BA  f1 75 26 41
	ld (LCD_CurrentLayer:16), 0x01                                 ; F928BE  f1 40 25 00 01
	ld XIY,0x00f2b42f                                    ; F928C3  45 2f b4 f2 00
	call T_DLB_Handler_Array8_2                                        ; F928C8  1d 20 18 f4
	ld XIY,0x00f2b43a                                    ; F928CC  45 3a b4 f2 00
	call T_DLB_Handler_Array8                                        ; F928D1  1d 1c 18 f4
	ld c, 0x07:opc                                          ; F928D5  23 07
	ld a, 0x0c:opc                                          ; F928D7  21 0c
	swi 7                                                ; F928D9  ff
	ret                                                  ; F928DA  0e
; Paint_Drum -- paints the screen whose own text reads "DRUM"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 3 time(s); XIY = list start, XIX = list end.  1 of those 3 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xF928F1  interpreter A  list 0xF2BA20  DL_Drum
;        text: "DRUM"
; Evidence: the list address is the `ld XIY,0x00F2BA20` IMMEDIATE at the
;          instruction two before the cited `call`, and the text quoted
;          above is the `.ascii` the interpreter draws verbatim.  Every
;          alphabetic morpheme of this name occurs in that text; the
;          check is notes/prom_a_understanding_round5.py --morphemes.
;          `Paint_` is a structural verb, not ROM text.
;          ⚠ ROUND 5: where the label reads `InstallPainter_`, the body contains
;          ZERO display-list calls -- it INSTALLS the callback that paints this
;          screen, through `call 0xF42E84`. The screen association is real one hop
;          away; the earlier `Paint_` verb claimed the body did the drawing and it
;          does not. Any display-list COUNT in a header above such a label is the
;          installed callback's, not this routine's.
; Unknown: whether this routine also handles input for the screen, and
;          whether any other routine paints it.  Neither was searched.
; ---------------------------------------------------------------------
Paint_Drum:
	calr SoundBank_IsReMap                                          ; F928DB  1e a9 08
	cp a, 0x01:i3                                          ; F928DE  c9 d9
	jr z, .LF9291E                                       ; F928E0  66 3c
	ld (LCD_CurrentLayer:16), 0x00                                 ; F928E2  f1 40 25 00 00
	ld XIY,DL_Drum                                       ; F928E7  45 20 ba f2 00
	ld XIX,Paint_Drum_DL1                                     ; F928EC  44 50 ba f2 00
	call T_DisplayList_Run                               ; F928F1  1d f0 17 f4
	ld (LCD_CurrentLayer:16), 0x01                                 ; F928F5  f1 40 25 00 01
	bit	5, (SoundSel_Bank:16)                               ; F928FA  f1 6a 21 cd
	jr Z,.LF92910                                        ; F928FE  66 10
	ld XIY,Paint_Drum_DL1                                     ; F92900  45 50 ba f2 00
	ld XIX,Paint_Drum_DL2                                     ; F92905  44 5a ba f2 00
	call T_DisplayList_Run                               ; F9290A  1d f0 17 f4
	jr .LF9291E                                          ; F9290E  68 0e
.LF92910:
	ld XIY,Paint_Drum_DL2                                     ; F92910  45 5a ba f2 00
	ld XIX,DL_F2BA64                                     ; F92915  44 64 ba f2 00
	call T_DisplayList_Run                               ; F9291A  1d f0 17 f4
.LF9291E:
	ret                                                  ; F9291E  0e
; BankLegend_DrawUser -- draws the USER-side bank soft-key legend ("USR1" or "USR2") and boxes it unless a drum bank is selected
; Evidence: SoundBank_IsReMap -> only DL_F2BB03 on layer 1 (erase the legend row). Else, only when (0x216A) bit 3 is set (U1/U2/UD1/UD2): bit 0 picks DL_Usr2..BankLegend_DrawUser_DL1 ("USR2", column 2) or DL_Usr1..BankLegend_DrawUser_DL3 ("USR1", column 1) on layer 0;
; on layer 1 the legend box is filled (BankLegend_DrawUser_DL1 / BankLegend_DrawUser_DL3, op 05) when bit 5 (drum) is clear, and the other boxes erased (BankLegend_DrawUser_DL2 / BankLegend_DrawUser_DL4, op 1B).
; Callers: Paint_SoundGroupMenuScreen, GroupSoundDisplayHold_RepaintFields, sub_F93631 (COMBINATION GROUP MENU) and GroupCombiDisplayHold_PaintGroupAndNames (GROUP: COMBI. DISPLAY HOLD).
BankLegend_DrawUser:
	calr SoundBank_IsReMap                                          ; F9291F  1e 65 08
	cp a, 0x01:i3                                          ; F92922  c9 d9
	jrl z, .LF929C7                                      ; F92924  76 a0 00
	ld (LCD_CurrentLayer:16), 0x00                                 ; F92927  f1 40 25 00 00
	ld a, (SoundSel_Bank:16)                                   ; F9292C  c1 6a 21 21
	bit 0x03,A                                           ; F92930  c9 33 03
	jrl z, .LF929DA                                      ; F92933  76 a4 00
	bit 0x00,A                                           ; F92936  c9 33 00
	jr z, .LF92972                                       ; F92939  66 37
	ld XIY,DL_Usr2                                       ; F9293B  45 66 bd f2 00
	ld XIX,BankLegend_DrawUser_DL1                                     ; F92940  44 96 bd f2 00
	call T_DisplayList_Run                               ; F92945  1d f0 17 f4
	ld (LCD_CurrentLayer:16), 0x01                                 ; F92949  f1 40 25 00 01
	bit	5, (SoundSel_Bank:16)                               ; F9294E  f1 6a 21 cd
	jr nz, .LF929A9                                      ; F92952  6e 55
	ld XIY,BankLegend_DrawUser_DL1                                     ; F92954  45 96 bd f2 00
	ld XIX,BankLegend_DrawUser_DL4                                     ; F92959  44 a0 bd f2 00
	call T_DisplayList_Run                               ; F9295E  1d f0 17 f4
	ld XIY,BankLegend_DrawUser_DL2                                     ; F92962  45 52 bd f2 00
	ld XIX,DL_Usr2                                       ; F92967  44 66 bd f2 00
	call T_DisplayList_Run                               ; F9296C  1d f0 17 f4
	jr .LF929DA                                          ; F92970  68 68
.LF92972:
	ld XIY,DL_Usr1                                       ; F92972  45 18 bd f2 00
	ld XIX,BankLegend_DrawUser_DL3                                     ; F92977  44 48 bd f2 00
	call T_DisplayList_Run                               ; F9297C  1d f0 17 f4
	ld (LCD_CurrentLayer:16), 0x01                                 ; F92980  f1 40 25 00 01
	bit	5, (SoundSel_Bank:16)                               ; F92985  f1 6a 21 cd
	jr nz, .LF929A9                                      ; F92989  6e 1e
	ld XIY,BankLegend_DrawUser_DL3                                     ; F9298B  45 48 bd f2 00
	ld XIX,BankLegend_DrawUser_DL2                                     ; F92990  44 52 bd f2 00
	call T_DisplayList_Run                               ; F92995  1d f0 17 f4
	ld XIY,BankLegend_DrawUser_DL4                                     ; F92999  45 a0 bd f2 00
	ld XIX,GroupCombiDisplayHold_DrawNumberRange_DL2                                     ; F9299E  44 b4 bd f2 00
	call T_DisplayList_Run                               ; F929A3  1d f0 17 f4
	jr .LF929DA                                          ; F929A7  68 31
.LF929A9:
	ld XIY,BankLegend_DrawUser_DL2                                     ; F929A9  45 52 bd f2 00
	ld XIX,DL_Usr2                                       ; F929AE  44 66 bd f2 00
	call T_DisplayList_Run                               ; F929B3  1d f0 17 f4
	ld XIY,BankLegend_DrawUser_DL4                                     ; F929B7  45 a0 bd f2 00
	ld XIX,GroupCombiDisplayHold_DrawNumberRange_DL2                                     ; F929BC  44 b4 bd f2 00
	call T_DisplayList_Run                               ; F929C1  1d f0 17 f4
	jr .LF929DA                                          ; F929C5  68 13
.LF929C7:
	ld (LCD_CurrentLayer:16), 0x01                                 ; F929C7  f1 40 25 00 01
	ld XIY,DL_F2BB03                                     ; F929CC  45 03 bb f2 00
	ld XIX,0x00f2bb0d                                    ; F929D1  44 0d bb f2 00
	call T_DisplayList_Run                               ; F929D6  1d f0 17 f4
.LF929DA:
	ret                                                  ; F929DA  0e
Draw_Ext1:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F929DB  f1 40 25 00 00
	ld XIY,DL_Ext1                                       ; F929E0  45 73 ba f2 00
	ld XIX,DL_F2BB03                                     ; F929E5  44 03 bb f2 00
	call T_DisplayList_Run                               ; F929EA  1d f0 17 f4
	ld (LCD_CurrentLayer:16), 0x01                                 ; F929EE  f1 40 25 00 01
	ld XIY,DL_F2BB03                                     ; F929F3  45 03 bb f2 00
	ld XIX,0x00f2bb0d                                    ; F929F8  44 0d bb f2 00
	call T_DisplayList_Run                               ; F929FD  1d f0 17 f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; F92A01  f1 40 25 00 00
	ld XIY,0x00f2bb0d                                    ; F92A06  45 0d bb f2 00
	call T_DLB_Handler_Array8                                        ; F92A0B  1d 1c 18 f4
	ret                                                  ; F92A0F  0e
Draw_Ext1_2:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F92A10  f1 40 25 00 00
	ld XIY,DL_Ext1                                       ; F92A15  45 73 ba f2 00
	ld XIX,0x00f2bad3                                    ; F92A1A  44 d3 ba f2 00
	call T_DisplayList_Run                               ; F92A1F  1d f0 17 f4
	ld (LCD_CurrentLayer:16), 0x01                                 ; F92A23  f1 40 25 00 01
	ld XIY,DL_F2BB03                                     ; F92A28  45 03 bb f2 00
	ld XIX,0x00f2bb0d                                    ; F92A2D  44 0d bb f2 00
	call T_DisplayList_Run                               ; F92A32  1d f0 17 f4
	ld XIY,0x00f2bb0d                                    ; F92A36  45 0d bb f2 00
	call T_DLB_Handler_Array8                                        ; F92A3B  1d 1c 18 f4
	ret                                                  ; F92A3F  0e
; BankLegend_EraseRow -- erases the bank soft-key legend strip (x 0x06-0xA2, y 0xE0-0xED) on layer 0
; Evidence: (0x2540) = 0, then DL_F2BB03..0xF2BB0D, a single op-1B (LCD_Svc_1B_EraseRect) record (0x0006,0x00E0)-(0x00A2,0x00ED) -- the strip where DL_Ext1, DL_Usr1/DL_Usr2 and DL_Drum frame their legends; site 0xF92A4F.
; The list bounds are the `ld XIY` / `ld XIX` immediates before that call (the earlier header's evidence). Callers: Paint_SoundGroupMenuScreen, GroupSoundDisplayHold_RepaintFields, sub_F93631, GroupCombiDisplayHold_PaintGroupAndNames -- each when (0x216A) bit 3 is set, before BankLegend_DrawUser.
BankLegend_EraseRow:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F92A40  f1 40 25 00 00
	ld XIY,DL_F2BB03                                     ; F92A45  45 03 bb f2 00
	ld XIX,0x00f2bb0d                                    ; F92A4A  44 0d bb f2 00
	call T_DisplayList_Run                               ; F92A4F  1d f0 17 f4
	ret                                                  ; F92A53  0e
ScreenLeave_SoundGroupMenu_Nop:
	ret                                                  ; F92A54  0e
; SoundBank_SelectR1OrU1 -- sets the selected sound bank (0x216A) to R1 (0x00) on the ROM side, or U1 (0x08) when U1/UD1 is selected, and posts the BANK event
; Evidence: does nothing when SoundBank_IsReMap or on U2/UD2 (bits 3 and 0 set). Writes (0x216A) and posts {E=0xA8, D=0x07, A=bank, W=0x3F} with T_Queue2E00_AppendRegs -- class A8 code 07 is the BANK buttons' event (notes/FINDINGS-prom_a-panel-control-map.md).
; Then (0x2075) &= 0xF7, and (0x2071) |= 0x10 on SOUND GROUP MENU (screen 0xA0) or (0x2095) |= 0x10 elsewhere. 0x00 / 0x08 = "R1-" / "U1-" in DLText_PartCodes.
; Slot [0] (SOFT KEY col 1, legend "R0M1" / "USR1") of DisplayListPtrs_F92726 (SOUND GROUP MENU) and reached from SoftKeyCol1_GroupSoundDisplayHold.
SoundBank_SelectR1OrU1:
	calr SoundBank_IsReMap                                          ; F92A55  1e 2f 07
	cp a, 0x01:i3                                          ; F92A58  c9 d9
	jr z, .LF92AA0                                       ; F92A5A  66 44
	ld a, (SoundSel_Bank:16)                                   ; F92A5C  c1 6a 21 21
	bit 0x03,A                                           ; F92A60  c9 33 03
	jr nz, .LF92A69                                      ; F92A63  6e 04
	ld a, 0x00:opc                                          ; F92A65  21 00
	jr .LF92A74                                          ; F92A67  68 0b
.LF92A69:
	ld a, (SoundSel_Bank:16)                                   ; F92A69  c1 6a 21 21
	bit 0x00,A                                           ; F92A6D  c9 33 00
	jr nz, .LF92AA0                                      ; F92A70  6e 2e
	ld a, 0x08:opc                                          ; F92A72  21 08
.LF92A74:
	cp (SoundSel_Bank:16), a                                    ; F92A74  c1 6a 21 f9
	jr z, .LF92AA0                                       ; F92A78  66 26
	ld (SoundSel_Bank:16), a                                   ; F92A7A  f1 6a 21 41
	ld e, 0xa8:opc                                          ; F92A7E  25 a8
	ld d, 0x07:opc                                          ; F92A80  24 07
	ld w, 0x3f:opc                                          ; F92A82  20 3f
	call T_Queue2E00_AppendRegs                          ; F92A84  1d 3c 0f f4
	and	(UI_RequestBits:16), 0xf7                            ; F92A88  c1 75 20 3c f7
	cp	(UI_ScreenId:16), 0xa0                            ; F92A8D  c1 7c 20 3f a0
	jr z, .LF92A9B                                       ; F92A92  66 07
	or	(UI_ScreenFlags:16), 0x10                            ; F92A94  c1 95 20 3e 10
	jr .LF92AA0                                          ; F92A99  68 05
.LF92A9B:
	or	(UI_Request_Hi:16), 0x10                            ; F92A9B  c1 71 20 3e 10
.LF92AA0:
	ret                                                  ; F92AA0  0e
; SoundBank_SelectR2OrU2 -- sets the selected sound bank (0x216A) to R2 (0x01) on the ROM side, or U2 (0x09) when U2/UD2 is selected, and posts the BANK event
; Evidence: does nothing when SoundBank_IsReMap or on U1/UD1 (bit 3 set, bit 0 clear). Writes (0x216A) and posts {E=0xA8, D=0x07, A=bank, W=0x3F} with T_Queue2E00_AppendRegs -- class A8 code 07 is the BANK buttons' event (notes/FINDINGS-prom_a-panel-control-map.md).
; Then (0x2075) &= 0xF7, and (0x2071) |= 0x10 on SOUND GROUP MENU (screen 0xA0) or (0x2095) |= 0x10 elsewhere. 0x01 / 0x09 = "R2-" / "U2-" in DLText_PartCodes.
; Slot [1] (SOFT KEY col 2, legend "R0M2" / "USR2") of DisplayListPtrs_F92726 (SOUND GROUP MENU) and reached from SoftKeyCol2_GroupSoundDisplayHold.
SoundBank_SelectR2OrU2:
	calr SoundBank_IsReMap                                          ; F92AA1  1e e3 06
	cp a, 0x01:i3                                          ; F92AA4  c9 d9
	jr z, .LF92AEC                                       ; F92AA6  66 44
	ld a, (SoundSel_Bank:16)                                   ; F92AA8  c1 6a 21 21
	bit 0x03,A                                           ; F92AAC  c9 33 03
	jr nz, .LF92AB5                                      ; F92AAF  6e 04
	ld a, 0x01:opc                                          ; F92AB1  21 01
	jr .LF92AC0                                          ; F92AB3  68 0b
.LF92AB5:
	ld a, (SoundSel_Bank:16)                                   ; F92AB5  c1 6a 21 21
	bit 0x00,A                                           ; F92AB9  c9 33 00
	jr z, .LF92AEC                                       ; F92ABC  66 2e
	ld a, 0x09:opc                                          ; F92ABE  21 09
.LF92AC0:
	cp (SoundSel_Bank:16), a                                    ; F92AC0  c1 6a 21 f9
	jr z, .LF92AEC                                       ; F92AC4  66 26
	ld (SoundSel_Bank:16), a                                   ; F92AC6  f1 6a 21 41
	ld e, 0xa8:opc                                          ; F92ACA  25 a8
	ld d, 0x07:opc                                          ; F92ACC  24 07
	ld w, 0x3f:opc                                          ; F92ACE  20 3f
	call T_Queue2E00_AppendRegs                          ; F92AD0  1d 3c 0f f4
	and	(UI_RequestBits:16), 0xf7                            ; F92AD4  c1 75 20 3c f7
	cp	(UI_ScreenId:16), 0xa0                            ; F92AD9  c1 7c 20 3f a0
	jr z, .LF92AE7                                       ; F92ADE  66 07
	or	(UI_ScreenFlags:16), 0x10                            ; F92AE0  c1 95 20 3e 10
	jr .LF92AEC                                          ; F92AE5  68 05
.LF92AE7:
	or	(UI_Request_Hi:16), 0x10                            ; F92AE7  c1 71 20 3e 10
.LF92AEC:
	ret                                                  ; F92AEC  0e
; SoundBank_SelectDrum -- sets the selected sound bank (0x216A) to the drum bank: RD (0x20) on the ROM side, or the user bank OR 0x20 (UD1 0x28 / UD2 0x29), and posts the BANK event
; Evidence: does nothing when SoundBank_IsReMap or when a user drum bank (bit 5) is already selected. Writes (0x216A) and posts {E=0xA8, D=0x07, A=bank, W=0x3F} with T_Queue2E00_AppendRegs -- class A8 code 07 is the BANK buttons' event (notes/FINDINGS-prom_a-panel-control-map.md).
; Then (0x2075) &= 0xF7, and (0x2071) |= 0x10 on SOUND GROUP MENU (screen 0xA0) or (0x2095) |= 0x10 elsewhere. 0x20 / 0x28 / 0x29 = "RD1" / "UD1" / "UD2" in DLText_PartCodes.
; Slot [2] (SOFT KEY col 3, legend "DRUM" from Paint_Drum) of DisplayListPtrs_F92726 (SOUND GROUP MENU) and reached from SoftKeyCol3_GroupSoundDisplayHold.
SoundBank_SelectDrum:
	calr SoundBank_IsReMap                                          ; F92AED  1e 97 06
	cp a, 0x01:i3                                          ; F92AF0  c9 d9
	jr z, .LF92B3D                                       ; F92AF2  66 49
	ld a, (SoundSel_Bank:16)                                   ; F92AF4  c1 6a 21 21
	bit 0x03,A                                           ; F92AF8  c9 33 03
	jr nz, .LF92B01                                      ; F92AFB  6e 04
	ld a, 0x20:opc                                          ; F92AFD  21 20
	jr .LF92B11                                          ; F92AFF  68 10
.LF92B01:
	ld a, (SoundSel_Bank:16)                                   ; F92B01  c1 6a 21 21
	bit 0x05,A                                           ; F92B05  c9 33 05
	jr nz, .LF92B0F                                      ; F92B08  6e 05
	or A,0x20                                            ; F92B0A  c9 ce 20
	jr .LF92B11                                          ; F92B0D  68 02
.LF92B0F:
	jr .LF92B3D                                          ; F92B0F  68 2c
.LF92B11:
	cp (SoundSel_Bank:16), a                                    ; F92B11  c1 6a 21 f9
	jr z, .LF92B3D                                       ; F92B15  66 26
	ld (SoundSel_Bank:16), a                                   ; F92B17  f1 6a 21 41
	ld e, 0xa8:opc                                          ; F92B1B  25 a8
	ld d, 0x07:opc                                          ; F92B1D  24 07
	ld w, 0x3f:opc                                          ; F92B1F  20 3f
	call T_Queue2E00_AppendRegs                          ; F92B21  1d 3c 0f f4
	and	(UI_RequestBits:16), 0xf7                            ; F92B25  c1 75 20 3c f7
	cp	(UI_ScreenId:16), 0xa0                            ; F92B2A  c1 7c 20 3f a0
	jr z, .LF92B38                                       ; F92B2F  66 07
	or	(UI_ScreenFlags:16), 0x10                            ; F92B31  c1 95 20 3e 10
	jr .LF92B3D                                          ; F92B36  68 05
.LF92B38:
	or	(UI_Request_Hi:16), 0x10                            ; F92B38  c1 71 20 3e 10
.LF92B3D:
	ret                                                  ; F92B3D  0e
; SoundBank_SelectExt -- sets the selected sound bank (0x216A) to E1 (0x10), and posts the BANK event
; Evidence: does nothing when SoundBank_IsReMap, on the USER side (bit 3 set) or when (0x08EC) bit 0 is clear. Writes (0x216A) and posts {E=0xA8, D=0x07, A=bank, W=0x3F} with T_Queue2E00_AppendRegs -- class A8 code 07 is the BANK buttons' event (notes/FINDINGS-prom_a-panel-control-map.md).
; Then (0x2075) &= 0xF7, and (0x2071) |= 0x10 on SOUND GROUP MENU (screen 0xA0) or (0x2095) |= 0x10 elsewhere. 0x10 = "E1-" in DLText_PartCodes.
; Slot [3] (SOFT KEY col 4, legend "EXT1") of DisplayListPtrs_F92726 (SOUND GROUP MENU) and reached from SoftKeyCol4_GroupSoundDisplayHold.
SoundBank_SelectExt:
	calr SoundBank_IsReMap                                          ; F92B3E  1e 46 06
	cp a, 0x01:i3                                          ; F92B41  c9 d9
	jr z, .LF92B82                                       ; F92B43  66 3d
	ld w, (SoundSel_Bank:16)                                   ; F92B45  c1 6a 21 20
	bit 0x03,W                                           ; F92B49  c8 33 03
	jr nz, .LF92B82                                      ; F92B4C  6e 34
	bit	0, (0x08ec:16)                               ; F92B4E  f1 ec 08 c8
	jr z, .LF92B82                                       ; F92B52  66 2e
	ld a, 0x10:opc                                          ; F92B54  21 10
	cp (SoundSel_Bank:16), a                                    ; F92B56  c1 6a 21 f9
	jr z, .LF92B82                                       ; F92B5A  66 26
	ld (SoundSel_Bank:16), a                                   ; F92B5C  f1 6a 21 41
	ld e, 0xa8:opc                                          ; F92B60  25 a8
	ld d, 0x07:opc                                          ; F92B62  24 07
	ld w, 0x3f:opc                                          ; F92B64  20 3f
	call T_Queue2E00_AppendRegs                          ; F92B66  1d 3c 0f f4
	and	(UI_RequestBits:16), 0xf7                            ; F92B6A  c1 75 20 3c f7
	cp	(UI_ScreenId:16), 0xa0                            ; F92B6F  c1 7c 20 3f a0
	jr z, .LF92B7D                                       ; F92B74  66 07
	or	(UI_ScreenFlags:16), 0x10                            ; F92B76  c1 95 20 3e 10
	jr .LF92B82                                          ; F92B7B  68 05
.LF92B7D:
	or	(UI_Request_Hi:16), 0x10                            ; F92B7D  c1 71 20 3e 10
.LF92B82:
	ret                                                  ; F92B82  0e
; SoundGroup_StepSelected -- steps the selected group (0x2169) down (key position 0) or up (position 1) and posts the group event
; Evidence: `xor W,0x80` first, then by bank (0x216A): UD1/UD2 (0x28/0x29) nothing; RD (0x20) 0..1; E1 (0x10) down to 0 but UP CLAMPED AT 1 -- the `jr nz` at 0xF92BC8 reuses the RD arm's `cp A,0x01`, so `cp A,B` (B = (0x08E8)-1) at 0xF92BD4 is unreachable; other banks 0..0x0F.
; On a change: (0x2075) |= 8, (0x2169) = A, T_Queue2E00_AppendRegs {E=0xA8, D=0x08, A=group, W=0x0F}.
; Slot [4] (SOFT KEY col 5) of DisplayListPtrs_F92726 and reached from SoftKeyCol5_GroupSoundDisplayHold.
SoundGroup_StepSelected:
	xor W,0x80                                           ; F92B83  c8 cd 80
	ld a, (SoundSel_Bank:16)                                   ; F92B86  c1 6a 21 21
	cp A,0x28                                            ; F92B8A  c9 cf 28
	jr z, .LF92BA0                                       ; F92B8D  66 11
	cp A,0x29                                            ; F92B8F  c9 cf 29
	jr z, .LF92BA0                                       ; F92B92  66 0c
	cp A,0x20                                            ; F92B94  c9 cf 20
	jr z, .LF92BA2                                       ; F92B97  66 09
	cp A,0x10                                            ; F92B99  c9 cf 10
	jr z, .LF92BBB                                       ; F92B9C  66 1d
	jr .LF92BDA                                          ; F92B9E  68 3a
.LF92BA0:
	jr .LF92C07                                          ; F92BA0  68 65
.LF92BA2:
	ld a, (SoundSel_Group:16)                                   ; F92BA2  c1 69 21 21
	bit 0x07,W                                           ; F92BA6  c8 33 07
	jr nz, .LF92BB3                                      ; F92BA9  6e 08
	cp a, 0x00:i3                                          ; F92BAB  c9 d8
	jr z, .LF92C07                                       ; F92BAD  66 58
	dec 1,A                                              ; F92BAF  c9 69
	jr .LF92BF4                                          ; F92BB1  68 41
.LF92BB3:
	inc 1,A                                              ; F92BB3  c9 61
	cp a, 0x01:i3                                          ; F92BB5  c9 d9
	jr ule, .LF92BF4                                     ; F92BB7  63 3b
	jr .LF92C07                                          ; F92BB9  68 4c
.LF92BBB:
	ld a, (SoundSel_Group:16)                                   ; F92BBB  c1 69 21 21
	ld b, (0x08e8:16)                                   ; F92BBF  c1 e8 08 22
	dec 1,B                                              ; F92BC3  ca 69
	bit 0x07,W                                           ; F92BC5  c8 33 07
	jr nz, .LF92BB3                                      ; F92BC8  6e e9
	cp a, 0x00:i3                                          ; F92BCA  c9 d8
	jr z, .LF92C07                                       ; F92BCC  66 39
	dec 1,A                                              ; F92BCE  c9 69
	jr .LF92BF4                                          ; F92BD0  68 22
	inc 1,A                                              ; F92BD2  c9 61
	cp A,B                                               ; F92BD4  ca f1
	jr ule, .LF92BF4                                     ; F92BD6  63 1c
	jr .LF92C07                                          ; F92BD8  68 2d
.LF92BDA:
	ld a, (SoundSel_Group:16)                                   ; F92BDA  c1 69 21 21
	bit 0x07,W                                           ; F92BDE  c8 33 07
	jr nz, .LF92BEB                                      ; F92BE1  6e 08
	cp a, 0x00:i3                                          ; F92BE3  c9 d8
	jr z, .LF92C07                                       ; F92BE5  66 20
	dec 1,A                                              ; F92BE7  c9 69
	jr .LF92BF4                                          ; F92BE9  68 09
.LF92BEB:
	inc 1,A                                              ; F92BEB  c9 61
	cp A,0x0f                                            ; F92BED  c9 cf 0f
	jr ule, .LF92BF4                                     ; F92BF0  63 02
	jr .LF92C07                                          ; F92BF2  68 13
.LF92BF4:
	or	(UI_RequestBits:16), 0x08                            ; F92BF4  c1 75 20 3e 08
	ld (SoundSel_Group:16), a                                   ; F92BF9  f1 69 21 41
	ld e, 0xa8:opc                                          ; F92BFD  25 a8
	ld d, 0x08:opc                                          ; F92BFF  24 08
	ld w, 0x0f:opc                                          ; F92C01  20 0f
	call T_Queue2E00_AppendRegs                          ; F92C03  1d 3c 0f f4
.LF92C07:
	ret                                                  ; F92C07  0e
; SoftKeyCol6_SoundGroupMenu -- the "OK" soft key of SOUND GROUP MENU: requests the GROUP: SOUND DISPLAY HOLD screen (id 0xA1)
; Evidence: slots [5] and [22] of DisplayListPtrs_F92726; `ld (0x2070),0x80A1` = screen-request id 0xA1 with (0x2071) = 0x80; when (0x2092) bit 0, (0x2071) = 0x40 and (0x2075) |= 0x80.
; "OK" is drawn at IX 0x236B (x 0xD8, y 0xE2), column 6. Screen 0xA1 is PanelScreen_VtableTable_ViewB entry 0xA1, T_F41550 (InstallPainter_GroupSoundDisplayHold_Entry).
SoftKeyCol6_SoundGroupMenu:   ; entry: named by 2 `.long` operands, first at 0xF9273A
	ldw (UI_Request:16), 0x80a1                              ; F92C08  f1 70 20 02 a1 80
	bit	0, (UI_ScreenHoldState:16)                               ; F92C0E  f1 92 20 c8
	jr z, .LF92C1E                                       ; F92C12  66 0a
	ld (UI_Request_Hi:16), 0x40                                 ; F92C14  f1 71 20 00 40
	or	(UI_RequestBits:16), 0x80                            ; F92C19  c1 75 20 3e 80
.LF92C1E:
	ret                                                  ; F92C1E  0e
DisplayListPtrs_F92726_Nop6:   ; entry: named by 2 `.long` operands, first at 0xF9273E
	ret                                                  ; F92C1F  0e
DisplayListPtrs_F92726_Nop7:   ; entry: named by 2 `.long` operands, first at 0xF92742
	ret                                                  ; F92C20  0e
; LcdKeyRow1_SoundGroupMenu -- LCD row-1 keys on SOUND GROUP MENU: no visible effect
; Evidence: slot [8] (code 0x08 = LCD row 1) of DisplayListPtrs_F92726; the body is `calr SoundGroup_SelectedMaxMemberIndex / ret`, and that callee only reads (T_SoundGroup_MaxMemberIndex_Get) -- its A / XIY / L are discarded.
LcdKeyRow1_SoundGroupMenu:   ; entry: named by 1 `.long` operand, first at 0xF92746
	calr SoundGroup_SelectedMaxMemberIndex                                          ; F92C21  1e 5b 03
	ret                                                  ; F92C24  0e
; LcdKeyRow2_SoundGroupMenu -- LCD row-2 keys on SOUND GROUP MENU: no visible effect
; Evidence: slot [9] (code 0x09 = LCD row 2) of DisplayListPtrs_F92726; the body is `calr SoundGroup_SelectedMaxMemberIndex / ret`, and that callee only reads (T_SoundGroup_MaxMemberIndex_Get) -- its A / XIY / L are discarded.
LcdKeyRow2_SoundGroupMenu:   ; entry: named by 1 `.long` operand, first at 0xF9274A
	calr SoundGroup_SelectedMaxMemberIndex                                          ; F92C25  1e 57 03
	ret                                                  ; F92C28  0e
; LcdKeyRow3_SoundGroupMenu -- LCD row-3 keys on SOUND GROUP MENU: no visible effect
; Evidence: slot [10] (code 0x0A = LCD row 3) of DisplayListPtrs_F92726; the body is `calr SoundGroup_SelectedMaxMemberIndex / ret`, and that callee only reads (T_SoundGroup_MaxMemberIndex_Get) -- its A / XIY / L are discarded.
LcdKeyRow3_SoundGroupMenu:   ; entry: named by 1 `.long` operand, first at 0xF9274E
	calr SoundGroup_SelectedMaxMemberIndex                                          ; F92C29  1e 53 03
	ret                                                  ; F92C2C  0e
DisplayListPtrs_F92726_Nop11:   ; entry: named by 1 `.long` operand, first at 0xF92752
	ret                                                  ; F92C2D  0e
DisplayListPtrs_F92726_Nop12:   ; entry: named by 1 `.long` operand, first at 0xF92756
	ret                                                  ; F92C2E  0e
DisplayListPtrs_F92726_Nop13:   ; entry: named by 1 `.long` operand, first at 0xF9275A
	ret                                                  ; F92C2F  0e
DisplayListPtrs_F92726_Nop14:   ; entry: named by 1 `.long` operand, first at 0xF9275E
	ret                                                  ; F92C30  0e
; ExitKey_SoundGroupMenu -- EXIT on SOUND GROUP MENU: requests screen 1 (SOUND MODE)
; Evidence: slot [15] (code 0x0F = EXIT) of DisplayListPtrs_F92726. When W bit 7 is clear (EXIT is pair position 1): (0x2070) = 0x8001 -- screen id 1, whose painter draws "SOUND MODE" (DL_F27C00) --
; and, when (0x2092) bit 0 is set, (0x209A) = 1 and (0x2071) = 0.
ExitKey_SoundGroupMenu:   ; entry: named by 1 `.long` operand, first at 0xF92762
	bit 0x07,W                                           ; F92C31  c8 33 07
	jr nz, .LF92C4E                                      ; F92C34  6e 18
	ldw (UI_Request:16), 0x8001                              ; F92C36  f1 70 20 02 01 80
	bit	0, (UI_ScreenHoldState:16)                               ; F92C3C  f1 92 20 c8
	jr z, .LF92C4C                                       ; F92C40  66 0a
	ld (UI_ScreenHoldPending:16), 0x01                                 ; F92C42  f1 9a 20 00 01
	ld (UI_Request_Hi:16), 0x00                                 ; F92C47  f1 71 20 00 00
.LF92C4C:
	jr .LF92C4E                                          ; F92C4C  68 00
.LF92C4E:
	ret                                                  ; F92C4E  0e
sub_F92C4F:
	ret                                                  ; F92C4F  0e
; ---------------------------------------------------------------------
; InstallPainter_GroupSoundDisplayHold_Entry -- a PURE WRAPPER for InstallPainter_GroupSoundDisplayHold: it IS that
; routine, so it is named for it.  Its whole extent is
; one `calr` and the `ret` that follows it, and the routine
; ends at 0xF92C54, where the next top-level label begins.
; Evidence: the `calr` at 0xF92C50 targets 0xF92CE7, which carries the
;          label InstallPainter_GroupSoundDisplayHold.  The extent is measured to the next top-level
;          label, never to a source line -- notes/wave7-verify-probes/
;          wave7_r5_prom_a_painter_scope.py records what scoping to a
;          source line cost the round-5 pass.
; ---------------------------------------------------------------------

InstallPainter_GroupSoundDisplayHold_Entry:
	calr InstallPainter_GroupSoundDisplayHold                                            ; F92C50  1e 94 00
	ret                                                  ; F92C53  0e
; ---------------------------------------------------------------------
; ScreenLeave_GroupSoundDisplayHold -- the LEAVE method of the screen object
;          at PanelScreen_VtableTable entry 0xC1, i.e. SCREEN ID 0xA1 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0xC1 -> the screen object at
;          0xF41550, whose +4 slot is `jp 0xF92C54`, and from no other live
;          screen object's two callable slots.
; Evidence: the +4 offset is PanelScreen_VtableTable's own (its header's
;          checks V1-V6): +0 ENTER is called by PanelScreen_CallEnter_A/B, +4
;          LEAVE by PanelScreen_CallLeave_A/B with the id that just STOPPED
;          being current, +8 BUTTON by PanelButton_Route (0xF8621E).
; Screen:   GroupSoundDisplayHold -- inherited from the +0 ENTER label
;          InstallPainter_GroupSoundDisplayHold_Entry, not from any text this
;          pass read.
; Was `sub_F92C54`.
; ---------------------------------------------------------------------
ScreenLeave_GroupSoundDisplayHold:
	calr ScreenLeave_GroupSoundDisplayHold_Nop                                          ; F92C54  1e cc 02
	ret                                                  ; F92C57  0e
; ---------------------------------------------------------------------
; ScreenButton_GroupSoundDisplayHold -- the BUTTON method of the screen
;          object at PanelScreen_VtableTable entry 0xC1, i.e. SCREEN ID 0xA1
;          through PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0xC1 -> the screen object at
;          0xF41550, whose +8 slot is `jp 0xF92C58`, and from no other live
;          screen object's two callable slots.
; Evidence: the +8 offset is PanelScreen_VtableTable's own (its header's
;          checks V1-V6): +0 ENTER is called by PanelScreen_CallEnter_A/B, +4
;          LEAVE by PanelScreen_CallLeave_A/B with the id that just STOPPED
;          being current, +8 BUTTON by PanelButton_Route (0xF8621E).
; Screen:   GroupSoundDisplayHold -- inherited from the +0 ENTER label
;          InstallPainter_GroupSoundDisplayHold_Entry, not from any text this
;          pass read.
; Was `sub_F92C58`.
; ---------------------------------------------------------------------
ScreenButton_GroupSoundDisplayHold:
	ld XIX,ScreenButtonHandlers_GroupSoundDisplayHold                        ; F92C58  44 66 2c f9 00
	call T_PanelButton_CallTableEntry                                        ; F92C5D  1d 08 1b f4
	ret                                                  ; F92C61  0e
; ==============================================================================
; 0xF92C62-0xF96017 -- more UI screen code, and SEVEN more pointer tables
; ==============================================================================
;
; Converted 2026-08-25 (wave 5 round 3), for the same reasons and with the same
; caveats as the 0xF99021 block above: it is what the frontier ranks, it draws
; screens, and it answers no emulation gap.
;
; Decode certification (`python3 notes/prom_a_linear_decode_check.py 0xF92C62
; 0xF96018 --offenders`): 0 call/calr from an instruction in the span to a
; non-boundary, 0 phantom ones either, and 0xF96018 -- the span's end -- is an
; instruction boundary of a decode that runs past it.  0xF92C62 is itself a
; prom_b directory target, so the decode's START is pinned by the directory.
;
; The seven tables are found the same way, by notes/prom_a_ptr_tables.py, and
; four of the seven are 32-entry tables handed to T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5,
; whose first instruction is `cp HL,0x001F / jr ugt`.  So their count comes from
; the CALLEE's bound, not from the run length -- and the two agree in all four.
; ==============================================================================
sub_F92C62:
	calr sub_F92C62_Nop                                          ; F92C62  1e be 04
	ret                                                  ; F92C65  0e
; ---------------------------------------------------------------------
; ScreenButtonHandlers_GroupSoundDisplayHold -- 32 LE32 pointers
;
; Read by: ONE site, 0xF92C58 `ld XIX,0x00F92C66 / call T_PanelButton_CallTableEntry`.
; ENTRY COUNT 32: T_PanelButton_CallTableEntry resolves to prom_a 0xF8BDC5, whose first instruction
;          is `cp HL,0x001F / jr ugt` -- 0x1F is the last index it lets through.
;          ★ LAST-ENTRY TEST: 0xF92C66 + 32*4 = 0xF92CE6, the word there is
;          0x2673F10E (not pointer-shaped), and 0xF92CE6 is where the decode
;          resumes.  It is also the minimum value any entry holds.
; Evidence: the reader, the callee's own bound, and the shape run measured by
;          notes/prom_a_ptr_tables.py; all three agree.
; Selector: the panel BUTTON CODE.  ScreenButton_GroupSoundDisplayHold (0xF92C58) is the +8
;          BUTTON method of PanelScreen_VtableTable entry 0xC1 (prom_b
;          slot 0xF41558); PanelButton_Route calls it with the code in HL
;          and at (XIZ+8), and it indexes this table with it:
;          `ld XIX,<this> / call T_PanelButton_CallTableEntry`, and T_PanelButton_CallTableEntry = 0xF8BDC5 calls
;          (this + 4*L) after `cp HL,0x001F`.
;          Dispatch_FF3D39's CONTROL LEGEND names each code.
;          (notes/proma-2026-09-25/gen_button_selectors.py, B1-B3)
; ★ 2026-09-25 (lane proma): the selector was recorded as open here.
; ---------------------------------------------------------------------
ScreenButtonHandlers_GroupSoundDisplayHold:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	SoftKeyCol1_GroupSoundDisplayHold
	on_key	KEY_SoftKeyCol2,	SoftKeyCol2_GroupSoundDisplayHold
	on_key	KEY_SoftKeyCol3,	SoftKeyCol3_GroupSoundDisplayHold
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_GroupSoundDisplayHold
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_GroupSoundDisplayHold
	on_key	KEY_SoftKeyCol6,	SoftKeyCol6_GroupSoundDisplayHold
	on_key	KEY_SoftKeyCol7,	SoftKeyCol7_GroupSoundDisplayHold
	on_key	KEY_SoftKeyCol8,	SoftKeyCol8_GroupSoundDisplayHold
	on_key	KEY_LcdRow1,		LcdKeyRow1_GroupSoundDisplayHold
	on_key	KEY_LcdRow2,		LcdKeyRow2_GroupSoundDisplayHold
	on_key	KEY_LcdRow3,		LcdKeyRow3_GroupSoundDisplayHold
	on_key	KEY_LcdRow4,		LcdKeyRow4_GroupSoundDisplayHold
	on_key	KEY_LcdRow5,		.LF92FC6
	on_key	KEY_MinusPlus,		ScreenButtonHandlers_GroupSoundDisplayHold_Nop13
	on_key	KEY_Code0E,		ScreenButtonHandlers_GroupSoundDisplayHold_Nop14
	on_key	KEY_Exit,		ExitKey_GroupSoundDisplayHold
	on_key	KEY_Page,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_SoftKeyCol1Alt,	SoftKeyCol1_GroupSoundDisplayHold
	on_key	KEY_SoftKeyCol2Alt,	SoftKeyCol2_GroupSoundDisplayHold
	on_key	KEY_SoftKeyCol3Alt,	SoftKeyCol3_GroupSoundDisplayHold
	on_key	KEY_SoftKeyCol4Alt,	SoftKeyCol4_GroupSoundDisplayHold
	on_key	KEY_SoftKeyCol5Alt,	SoftKeyCol5_GroupSoundDisplayHold
	on_key	KEY_SoftKeyCol6Alt,	SoftKeyCol6_GroupSoundDisplayHold
	on_key	KEY_SoftKeyCol7Alt,	SoftKeyCol7_GroupSoundDisplayHold
	on_key	KEY_SoftKeyCol8Alt,	SoftKeyCol8_GroupSoundDisplayHold
	on_key	KEY_PageAlt,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Code1A,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_NumberPad,		NumberPadKey_GroupSoundDisplayHold
	on_key	KEY_Code1C,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Code1D,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Compare,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Code1F,		DisplayListPtrs_F914FB_Nop8
	keymap_end
DisplayListPtrs_F914FB_Nop8:   ; entry: named by 67 `.long` operands, first at 0xF9151B
	ret                                                  ; F92CE6  0e
; InstallPainter_GroupSoundDisplayHold -- paints the screen whose own text reads "GROUP:", "SOUND", "DISPLAY"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 1 time(s); XIY = list start, XIX = list end.  1 of those 1 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xF92D66  interpreter A  list 0xF2B574  DL_GroupSoundDisplayHoldGr0up
;        text: "GROUP:"; "SOUND"; "DISPLAY"; "HOLD"; "GR0UP"; "MENU"
; Evidence: the list address is the `ld XIY,0x00F2B574` IMMEDIATE at the
;          instruction two before the cited `call`, and the text quoted
;          above is the `.ascii` the interpreter draws verbatim.  Every
;          alphabetic morpheme of this name occurs in that text; the
;          check is notes/prom_a_understanding_round5.py --morphemes.
;          `Paint_` is a structural verb, not ROM text.
;          ⚠ ROUND 5: where the label reads `InstallPainter_`, the body contains
;          ZERO display-list calls -- it INSTALLS the callback that paints this
;          screen, through `call 0xF42E84`. The screen association is real one hop
;          away; the earlier `Paint_` verb claimed the body did the drawing and it
;          does not. Any display-list COUNT in a header above such a label is the
;          installed callback's, not this routine's.
; Unknown: whether this routine also handles input for the screen, and
;          whether any other routine paints it.  Neither was searched.
; ---------------------------------------------------------------------
InstallPainter_GroupSoundDisplayHold:
	bit	6, (0x2673:16)                               ; F92CE7  f1 73 26 ce
	jr nz, .LF92CF7                                      ; F92CEB  6e 0a
	bit	7, (0x2673:16)                               ; F92CED  f1 73 26 cf
	jr nz, .LF92CF7                                      ; F92CF1  6e 04
	call T_CallbackQueue_ResetAndRestartTask2            ; F92CF3  1d 80 2e f4
.LF92CF7:
	and	(UI_RequestBits:16), 0xfe                            ; F92CF7  c1 75 20 3c fe
	ld a, (UI_ScreenId:16)                                   ; F92CFC  c1 7c 20 21
	cp (UI_ScreenId_Previous:16), a                                    ; F92D00  c1 7d 20 f9
	jr z, .LF92D1F                                       ; F92D04  66 19
	and	(UI_ScreenFlags:16), 0xef                            ; F92D06  c1 95 20 3c ef
	or	(0x2673:16), 0x40                            ; F92D0B  c1 73 26 3e 40
	cp	(Variant_Flag:8), 0x01                               ; F92D10  c0 c4 3f 01
	jr z, .LF92D1F                                       ; F92D14  66 09
	call T_Blink_Stop                                    ; F92D16  1d 24 2e f4
	or	(UI_RequestBits:16), 0x02                            ; F92D1A  c1 75 20 3e 02
.LF92D1F:
	bit	4, (UI_ScreenFlags:16)                               ; F92D1F  f1 95 20 cc
	jr nz, .LF92D3C                                      ; F92D23  6e 17
	or	(0x2673:16), 0x80                            ; F92D25  c1 73 26 3e 80
	ld XIX,Draw_GroupSoundDisplayHoldGr0up                                    ; F92D2A  44 4f 2d f9 00
	push XIX                                             ; F92D2F  3c
	call T_CallbackQueue_Post                            ; F92D30  1d 84 2e f4
	inc 4,XSP                                            ; F92D34  ef 64
	ld a, 0x01:opc                                          ; F92D36  21 01
	call T_Kernel_SemaSignal                             ; F92D38  1d 88 2d f4
.LF92D3C:
	ld XIX,GroupSoundDisplayHold_RepaintFields                                    ; F92D3C  44 70 2d f9 00
	push XIX                                             ; F92D41  3c
	call T_CallbackQueue_Post                            ; F92D42  1d 84 2e f4
	inc 4,XSP                                            ; F92D46  ef 64
	ld a, 0x01:opc                                          ; F92D48  21 01
	call T_Kernel_SemaSignal                             ; F92D4A  1d 88 2d f4
	ret                                                  ; F92D4E  0e
Draw_GroupSoundDisplayHoldGr0up:   ; entry: named by 1 `ld` operand, first at 0xF92D2A
	ld a, 0x0f:opc                                          ; F92D4F  21 0f
	swi 7                                                ; F92D51  ff
	xor C,C                                              ; F92D52  cb d3
	ld a, 0x0c:opc                                          ; F92D54  21 0c
	swi 7                                                ; F92D56  ff
	ld (LCD_CurrentLayer:16), 0x00                                 ; F92D57  f1 40 25 00 00
	ld XIY,DL_GroupSoundDisplayHoldGr0up                 ; F92D5C  45 74 b5 f2 00
	ld XIX,DL_GroupCombiDisplayHoldGr0up                 ; F92D61  44 36 b7 f2 00
	call T_DisplayList_Run                               ; F92D66  1d f0 17 f4
	and	(0x2673:16), 0x7f                            ; F92D6A  c1 73 26 3c 7f
	ret                                                  ; F92D6F  0e
; GroupSoundDisplayHold_RepaintFields -- draws the live part of GROUP: SOUND DISPLAY HOLD: group name, number range, group number, bank legends, HOLD state and the member names
; Evidence: posted by InstallPainter_GroupSoundDisplayHold (0xF92D3C). Group name: T_SoundGroupName_Lookup (A=(0x2169), B=(0x2250), W=(0x216A)) drawn 16 characters by swi 6 at IX 0x0129; then GroupSoundDisplayHold_DrawNumberRange, DisplayHold_ShowGroupNumber,
; BankLegend_DrawRom12Ext / BankLegend_EraseRow (by (0x216A) bit 3), Paint_Drum, BankLegend_DrawUser, DisplayHold_DrawHoldHighlight.
; (0x2672) = index of the last 8-name page, from T_SoundGroup_MaxMemberIndex_Get; max index <= 8: GroupSoundDisplayHold_DrawMemberNames + GroupSoundDisplayHold_HighlightSelected directly, <= 15: GroupMembers_ShowPageOfTwo, else GroupMembers_ShowPageOfMany. Ends with (0x2673) &= 0xBF.
GroupSoundDisplayHold_RepaintFields:   ; entry: named by 1 `ld` operand, first at 0xF92D3C
	call T_Blink_Stop                                    ; F92D70  1d 24 2e f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; F92D74  f1 40 25 00 00
	calr GroupDisplayHold_ClearNameSlots                                          ; F92D79  1e b1 07
	ld XIY,0x00f2b8f9                                    ; F92D7C  45 f9 b8 f2 00
	call T_DLB_Handler_StringTable                       ; F92D81  1d f8 17 f4
	ld a, (SoundSel_Group:16)                                   ; F92D85  c1 69 21 21
	ld b, (UI_PartIndex:16)                                   ; F92D89  c1 50 22 22
	ld w, (SoundSel_Bank:16)                                   ; F92D8D  c1 6a 21 20
	call T_SoundGroupName_Lookup                                        ; F92D91  1d 18 10 f4
	ldw ix, 0x0129                                       ; F92D95  34 29 01
	ldw hl, 0x00                                         ; F92D98  33 00 00
	ldw bc, 0x10                                         ; F92D9B  31 10 00
	ld a, 0x06:opc                                          ; F92D9E  21 06
	swi 7                                                ; F92DA0  ff
	calr GroupSoundDisplayHold_DrawNumberRange                                      ; F92DA1  1e fb 03
	calr DisplayHold_ShowGroupNumber                                      ; F92DA4  1e 7d 03
	ld (LCD_CurrentLayer:16), 0x00                                 ; F92DA7  f1 40 25 00 00
	bit	3, (SoundSel_Bank:16)                               ; F92DAC  f1 6a 21 cb
	jr nz, .LF92DB7                                      ; F92DB0  6e 05
	calr Draw_Ext1                                          ; F92DB2  1e 26 fc
	jr .LF92DBA                                          ; F92DB5  68 03
.LF92DB7:
	calr BankLegend_EraseRow                                          ; F92DB7  1e 86 fc
.LF92DBA:
	calr Paint_Drum                                          ; F92DBA  1e 1e fb
	calr BankLegend_DrawUser                                          ; F92DBD  1e 5f fb
	calr DisplayHold_DrawHoldHighlight                                      ; F92DC0  1e 9a 03
	ld a, (SoundSel_Group:16)                                   ; F92DC3  c1 69 21 21
	ld b, (UI_PartIndex:16)                                   ; F92DC7  c1 50 22 22
	ld w, (SoundSel_Bank:16)                                   ; F92DCB  c1 6a 21 20
	call T_SoundGroup_MaxMemberIndex_Get                 ; F92DCF  1d 1c 10 f4
	ld L,A                                               ; F92DD3  c9 8f
	cp a, 0x07:i3                                          ; F92DD5  c9 df
	jr z, .LF92DDB                                       ; F92DD7  66 02
	inc 1,A                                              ; F92DD9  c9 61
.LF92DDB:
	xor W,W                                              ; F92DDB  c8 d0
	ld c, 0x08:opc                                          ; F92DDD  23 08
	div wa, c                                          ; F92DDF  cb 51
	cp w, 0x00:i3                                          ; F92DE1  c8 d8
	jr z, .LF92DE7                                       ; F92DE3  66 02
	inc 1,A                                              ; F92DE5  c9 61
.LF92DE7:
	dec 1,A                                              ; F92DE7  c9 69
	ld (0x2672:16), a                                   ; F92DE9  f1 72 26 41
	ld A,L                                               ; F92DED  cf 89
	xor W,W                                              ; F92DEF  c8 d0
	cp WA,0x0008                                         ; F92DF1  d8 cf 08 00
	jr ugt, .LF92E16                                     ; F92DF5  6b 1f
	ld (GroupMembers_Page:16), 0x00                                 ; F92DF7  f1 70 26 00 00
	calr PartRecord_GetPtr                                          ; F92DFC  1e 3a 17
	ld l, (SoundSel_Group:16)                                   ; F92DFF  c1 69 21 27
	and L,0xff                                           ; F92E03  cf cc ff
	ldw de, 0x00                                         ; F92E06  32 00 00
	calr GroupSoundDisplayHold_DrawMemberNames                                          ; F92E09  1e a3 06
	calr GroupSoundDisplayHold_HighlightSelected                                      ; F92E0C  1e 89 05
	ld c, 0x03:opc                                          ; F92E0F  23 03
	ld a, 0x0c:opc                                          ; F92E11  21 0c
	swi 7                                                ; F92E13  ff
	jr .LF92E30                                          ; F92E14  68 1a
.LF92E16:
	cp WA,0x000f                                         ; F92E16  d8 cf 0f 00
	jr ugt, .LF92E27                                     ; F92E1A  6b 0b
	calr PartRecord_GetPtr                                          ; F92E1C  1e 1a 17
	and L,0xff                                           ; F92E1F  cf cc ff
	calr GroupMembers_ShowPageOfTwo                                      ; F92E22  1e 11 00
	jr .LF92E30                                          ; F92E25  68 09
.LF92E27:
	calr PartRecord_GetPtr                                          ; F92E27  1e 0f 17
	and L,0xff                                           ; F92E2A  cf cc ff
	calr GroupMembers_ShowPageOfMany                                      ; F92E2D  1e 46 00
.LF92E30:
	and	(0x2673:16), 0xbf                            ; F92E30  c1 73 26 3c bf
	ret                                                  ; F92E35  0e
; GroupMembers_ShowPageOfTwo -- for a group with max member index 9..15, shows the 8-name page that contains index L (L <= 7: members 0-7, else 8..WA)
; Evidence: L <= 7: (0x2670) = 0, GroupSoundDisplayHold_DrawMemberNames with DE = 0, WA = 7; else (0x2670) = 1, DE = 8, WA as passed (the max index); XIY = part record (PartRecord_GetPtr), L = (0x2169) for GroupSoundDisplayHold_DrawMemberNames; then GroupSoundDisplayHold_HighlightSelected and swi 0x0C with C = 3.
; Called by GroupSoundDisplayHold_RepaintFields (`cp WA,0x000F` at 0xF92E16), GroupMembers_ShowFirstOfTwoPages and GroupMembers_ShowSecondOfTwoPages.
GroupMembers_ShowPageOfTwo:
	cp l, 0x07:i3                                          ; F92E36  cf df
	jr ugt, .LF92E56                                     ; F92E38  6b 1c
	ld (GroupMembers_Page:16), 0x00                                 ; F92E3A  f1 70 26 00 00
	calr PartRecord_GetPtr                                          ; F92E3F  1e f7 16
	ld l, (SoundSel_Group:16)                                   ; F92E42  c1 69 21 27
	and L,0xff                                           ; F92E46  cf cc ff
	xor H,H                                              ; F92E49  ce d6
	ldw de, 0x00                                         ; F92E4B  32 00 00
	ldw wa, 0x07                                         ; F92E4E  30 07 00
	calr GroupSoundDisplayHold_DrawMemberNames                                          ; F92E51  1e 5b 06
	jr .LF92E6D                                          ; F92E54  68 17
.LF92E56:
	ld (GroupMembers_Page:16), 0x01                                 ; F92E56  f1 70 26 00 01
	calr PartRecord_GetPtr                                          ; F92E5B  1e db 16
	ld l, (SoundSel_Group:16)                                   ; F92E5E  c1 69 21 27
	and L,0xff                                           ; F92E62  cf cc ff
	xor H,H                                              ; F92E65  ce d6
	ldw de, 0x08                                         ; F92E67  32 08 00
	calr GroupSoundDisplayHold_DrawMemberNames                                          ; F92E6A  1e 42 06
.LF92E6D:
	calr GroupSoundDisplayHold_HighlightSelected                                      ; F92E6D  1e 28 05
	ld c, 0x03:opc                                          ; F92E70  23 03
	ld a, 0x0c:opc                                          ; F92E72  21 0c
	swi 7                                                ; F92E74  ff
	ret                                                  ; F92E75  0e
; GroupMembers_ShowPageOfMany -- for a group with max member index above 15, shows the 8-name page that contains index L
; Evidence: L <= 7: (0x2670) = 0, DE = 0, WA = 7; otherwise (0x2670) = L/8, DE = 8*(0x2670), and WA = DE + 7, or WA as passed (the max index) when L is past ((0x2672)-1)*8+7, the last full page; GroupSoundDisplayHold_DrawMemberNames draws the names,
; then GroupSoundDisplayHold_HighlightSelected and swi 0x0C (C = 3). Callers: GroupSoundDisplayHold_RepaintFields, GroupMembers_ShowFirstOfManyPages, GroupMembers_ShowNextOfManyPages and GroupCombiDisplayHold_ShowNextOfManyPages (the COMBI. screen's twin).
GroupMembers_ShowPageOfMany:
	cp l, 0x07:i3                                          ; F92E76  cf df
	jr ugt, .LF92E96                                     ; F92E78  6b 1c
	ld (GroupMembers_Page:16), 0x00                                 ; F92E7A  f1 70 26 00 00
	calr PartRecord_GetPtr                                          ; F92E7F  1e b7 16
	ld l, (SoundSel_Group:16)                                   ; F92E82  c1 69 21 27
	and L,0xff                                           ; F92E86  cf cc ff
	xor H,H                                              ; F92E89  ce d6
	ldw de, 0x00                                         ; F92E8B  32 00 00
	ldw wa, 0x07                                         ; F92E8E  30 07 00
	calr GroupSoundDisplayHold_DrawMemberNames                                          ; F92E91  1e 1b 06
	jr .LF92F0D                                          ; F92E94  68 77
.LF92E96:
	pushw wa                                             ; F92E96  28
	ld a, (0x2672:16)                                   ; F92E97  c1 72 26 21
	dec 1,A                                              ; F92E9B  c9 69
	xor W,W                                              ; F92E9D  c8 d0
	ld c, 0x08:opc                                          ; F92E9F  23 08
	mul wa, c                                          ; F92EA1  cb 41
	add WA,0x0007                                        ; F92EA3  d8 c8 07 00
	ld DE,WA                                             ; F92EA7  d8 8a
	popw wa                                              ; F92EA9  48
	cp L,E                                               ; F92EAA  cd f7
	jr ugt, .LF92EDB                                     ; F92EAC  6b 2d
	ld A,L                                               ; F92EAE  cf 89
	xor W,W                                              ; F92EB0  c8 d0
	ld l, 0x08:opc                                          ; F92EB2  27 08
	div wa, l                                          ; F92EB4  cf 51
	ld (GroupMembers_Page:16), a                                   ; F92EB6  f1 70 26 41
	calr PartRecord_GetPtr                                          ; F92EBA  1e 7c 16
	ld l, (SoundSel_Group:16)                                   ; F92EBD  c1 69 21 27
	and L,0xff                                           ; F92EC1  cf cc ff
	xor H,H                                              ; F92EC4  ce d6
	ld a, (GroupMembers_Page:16)                                   ; F92EC6  c1 70 26 21
	xor W,W                                              ; F92ECA  c8 d0
	ld c, 0x08:opc                                          ; F92ECC  23 08
	mul wa, c                                          ; F92ECE  cb 41
	ld DE,WA                                             ; F92ED0  d8 8a
	add WA,0x0007                                        ; F92ED2  d8 c8 07 00
	calr GroupSoundDisplayHold_DrawMemberNames                                          ; F92ED6  1e d6 05
	jr .LF92F0D                                          ; F92ED9  68 32
.LF92EDB:
	pushw wa                                             ; F92EDB  28
	pushw de                                             ; F92EDC  2a
	ld A,L                                               ; F92EDD  cf 89
	xor W,W                                              ; F92EDF  c8 d0
	ld l, 0x08:opc                                          ; F92EE1  27 08
	div wa, l                                          ; F92EE3  cf 51
	ld (GroupMembers_Page:16), a                                   ; F92EE5  f1 70 26 41
	popw de                                              ; F92EE9  4a
	popw wa                                              ; F92EEA  48
	ld (LCD_CurrentLayer:16), 0x00                                 ; F92EEB  f1 40 25 00 00
	calr PartRecord_GetPtr                                          ; F92EF0  1e 46 16
	ld l, (SoundSel_Group:16)                                   ; F92EF3  c1 69 21 27
	and L,0xff                                           ; F92EF7  cf cc ff
	xor H,H                                              ; F92EFA  ce d6
	pushw wa                                             ; F92EFC  28
	ld a, (GroupMembers_Page:16)                                   ; F92EFD  c1 70 26 21
	xor W,W                                              ; F92F01  c8 d0
	ld c, 0x08:opc                                          ; F92F03  23 08
	mul wa, c                                          ; F92F05  cb 41
	ld DE,WA                                             ; F92F07  d8 8a
	popw wa                                              ; F92F09  48
	calr GroupSoundDisplayHold_DrawMemberNames                                          ; F92F0A  1e a2 05
.LF92F0D:
	calr GroupSoundDisplayHold_HighlightSelected                                      ; F92F0D  1e 88 04
	ld c, 0x03:opc                                          ; F92F10  23 03
	ld a, 0x0c:opc                                          ; F92F12  21 0c
	swi 7                                                ; F92F14  ff
	ret                                                  ; F92F15  0e
; PosTable_GetEntryIX -- IX = the 16-bit word at index E of the word table at XIZ (D is cleared first)
; Evidence: `xor D,D / ld IX,DE / sla 0x01,IX / ld IX,(XIZ+IX)` at 0xF92F16-0xF92F1D.
; GroupSoundDisplayHold_DrawMemberNames calls it with XIZ = an entry of DLPtrTable_F2B510 (five word arrays) and then draws a 16-character name with swi 6 at that IX; GroupCombiDisplayHold_DrawMemberNames is the other caller.
PosTable_GetEntryIX:
	xor D,D                                              ; F92F16  cc d4
	ld IX,DE                                             ; F92F18  da 8c
	sla ix, 0x01                                         ; F92F1A  dc ec 01
	ld	ix, (xiz+ix)                                 ; F92F1D  d3 07 f8 f0 24
	ret                                                  ; F92F22  0e
ScreenLeave_GroupSoundDisplayHold_Nop:
	ret                                                  ; F92F23  0e
; SoftKeyCol1_GroupSoundDisplayHold -- SOFT KEY column 1 on GROUP: SOUND DISPLAY HOLD: the same action as on SOUND GROUP MENU, SoundBank_SelectR1OrU1
; Evidence: slots [0] and [17] of ScreenButtonHandlers_GroupSoundDisplayHold (code 0 = SOFT KEY col 1); the body is `calr SoundBank_SelectR1OrU1 / ret`, and SoundBank_SelectR1OrU1 is slot [0] of DisplayListPtrs_F92726 (SOUND GROUP MENU) too.
SoftKeyCol1_GroupSoundDisplayHold:   ; entry: named by 2 `.long` operands, first at 0xF92C66
	calr SoundBank_SelectR1OrU1                                          ; F92F24  1e 2e fb
	ret                                                  ; F92F27  0e
; SoftKeyCol2_GroupSoundDisplayHold -- SOFT KEY column 2 on GROUP: SOUND DISPLAY HOLD: the same action as on SOUND GROUP MENU, SoundBank_SelectR2OrU2
; Evidence: slots [1] and [18] of ScreenButtonHandlers_GroupSoundDisplayHold (code 1 = SOFT KEY col 2); the body is `calr SoundBank_SelectR2OrU2 / ret`, and SoundBank_SelectR2OrU2 is slot [1] of DisplayListPtrs_F92726 (SOUND GROUP MENU) too.
SoftKeyCol2_GroupSoundDisplayHold:   ; entry: named by 2 `.long` operands, first at 0xF92C6A
	calr SoundBank_SelectR2OrU2                                          ; F92F28  1e 76 fb
	ret                                                  ; F92F2B  0e
; SoftKeyCol3_GroupSoundDisplayHold -- SOFT KEY column 3 on GROUP: SOUND DISPLAY HOLD: the same action as on SOUND GROUP MENU, SoundBank_SelectDrum
; Evidence: slots [2] and [19] of ScreenButtonHandlers_GroupSoundDisplayHold (code 2 = SOFT KEY col 3); the body is `calr SoundBank_SelectDrum / ret`, and SoundBank_SelectDrum is slot [2] of DisplayListPtrs_F92726 (SOUND GROUP MENU) too.
SoftKeyCol3_GroupSoundDisplayHold:   ; entry: named by 2 `.long` operands, first at 0xF92C6E
	calr SoundBank_SelectDrum                                          ; F92F2C  1e be fb
	ret                                                  ; F92F2F  0e
; SoftKeyCol4_GroupSoundDisplayHold -- SOFT KEY column 4 on GROUP: SOUND DISPLAY HOLD: the same action as on SOUND GROUP MENU, SoundBank_SelectExt
; Evidence: slots [3] and [20] of ScreenButtonHandlers_GroupSoundDisplayHold (code 3 = SOFT KEY col 4); the body is `calr SoundBank_SelectExt / ret`, and SoundBank_SelectExt is slot [3] of DisplayListPtrs_F92726 (SOUND GROUP MENU) too.
SoftKeyCol4_GroupSoundDisplayHold:   ; entry: named by 2 `.long` operands, first at 0xF92C72
	calr SoundBank_SelectExt                                          ; F92F30  1e 0b fc
	ret                                                  ; F92F33  0e
; SoftKeyCol5_GroupSoundDisplayHold -- SOFT KEY column 5 on GROUP: SOUND DISPLAY HOLD: the same action as on SOUND GROUP MENU, SoundGroup_StepSelected
; Evidence: slots [4] and [21] of ScreenButtonHandlers_GroupSoundDisplayHold (code 4 = SOFT KEY col 5); the body is `calr SoundGroup_StepSelected / ret`, and SoundGroup_StepSelected is slot [4] of DisplayListPtrs_F92726 (SOUND GROUP MENU) too.
SoftKeyCol5_GroupSoundDisplayHold:   ; entry: named by 2 `.long` operands, first at 0xF92C76
	calr SoundGroup_StepSelected                                          ; F92F34  1e 4c fc
	ret                                                  ; F92F37  0e
; SoftKeyCol6_GroupSoundDisplayHold -- the "GR0UP MENU" soft key of GROUP: SOUND DISPLAY HOLD: requests SOUND GROUP MENU (screen 0xA0)
; Evidence: slots [5] and [22] of ScreenButtonHandlers_GroupSoundDisplayHold; `ld (0x2070),0x80A0` = screen-request id 0xA0 with (0x2071) = 0x80; when (0x2092) bit 0, (0x2071) = 0x40 and (0x2075) |= 0x80.
; DL_GroupSoundDisplayHoldGr0up draws "GR0UP" and "MENU" at IX 0x1EDF / 0x227A (x 0xB8 / 0xD0, y 0xC5 / 0xDC), over column 6. Screen 0xA0 is T_F41540 (InstallPainter_SoundGroupMenu_Entry).
SoftKeyCol6_GroupSoundDisplayHold:   ; entry: named by 2 `.long` operands, first at 0xF92C7A
	ldw (UI_Request:16), 0x80a0                              ; F92F38  f1 70 20 02 a0 80
	bit	0, (UI_ScreenHoldState:16)                               ; F92F3E  f1 92 20 c8
	jr z, .LF92F4E                                       ; F92F42  66 0a
	ld (UI_Request_Hi:16), 0x40                                 ; F92F44  f1 71 20 00 40
	or	(UI_RequestBits:16), 0x80                            ; F92F49  c1 75 20 3e 80
.LF92F4E:
	ret                                                  ; F92F4E  0e
; SoftKeyCol7_GroupSoundDisplayHold -- SOFT KEY column 7 on GROUP: SOUND DISPLAY HOLD: toggles DISPLAY HOLD ((0x267F) bit 0)
; Evidence: slots [6] and [23] of ScreenButtonHandlers_GroupSoundDisplayHold; `xor (0x267F),0x01`, then posts DisplayHold_DrawHoldHighlight. "DISPLAY" / "HOLD" are drawn at IX 0x2190 / 0x2371 (x 0x100 / 0x108, y 0xD6 / 0xE2),
; inside the box (0xFE,0xD4)-(0x139,0xEC) that spans columns 7 and 8 -- both keys share this body. GroupSoundDisplayHold_PickSound leaves the screen only when the bit is clear.
SoftKeyCol7_GroupSoundDisplayHold:   ; entry: named by 2 `.long` operands, first at 0xF92C7E
	xor	(DisplayHold_Flag:16), 0x01                            ; F92F4F  c1 7f 26 3d 01
	ld XIX,DisplayHold_DrawHoldHighlight                                    ; F92F54  44 5d 31 f9 00
	push XIX                                             ; F92F59  3c
	call T_CallbackQueue_Post                            ; F92F5A  1d 84 2e f4
	inc 4,XSP                                            ; F92F5E  ef 64
	ld a, 0x01:opc                                          ; F92F60  21 01
	call T_Kernel_SemaSignal                             ; F92F62  1d 88 2d f4
	ret                                                  ; F92F66  0e
; SoftKeyCol8_GroupSoundDisplayHold -- SOFT KEY column 8 on GROUP: SOUND DISPLAY HOLD: toggles DISPLAY HOLD ((0x267F) bit 0)
; Evidence: slots [7] and [24] of ScreenButtonHandlers_GroupSoundDisplayHold; `xor (0x267F),0x01`, then posts DisplayHold_DrawHoldHighlight. "DISPLAY" / "HOLD" are drawn at IX 0x2190 / 0x2371 (x 0x100 / 0x108, y 0xD6 / 0xE2),
; inside the box (0xFE,0xD4)-(0x139,0xEC) that spans columns 7 and 8 -- both keys share this body. GroupSoundDisplayHold_PickSound leaves the screen only when the bit is clear.
SoftKeyCol8_GroupSoundDisplayHold:   ; entry: named by 2 `.long` operands, first at 0xF92C82
	xor	(DisplayHold_Flag:16), 0x01                            ; F92F67  c1 7f 26 3d 01
	ld XIX,DisplayHold_DrawHoldHighlight                                    ; F92F6C  44 5d 31 f9 00
	push XIX                                             ; F92F71  3c
	call T_CallbackQueue_Post                            ; F92F72  1d 84 2e f4
	inc 4,XSP                                            ; F92F76  ef 64
	ld a, 0x01:opc                                          ; F92F78  21 01
	call T_Kernel_SemaSignal                             ; F92F7A  1d 88 2d f4
	ret                                                  ; F92F7E  0e
; SoundGroup_SelectedMaxMemberIndex -- A = the max member index of the selected group (0x2169) in the selected bank (0x216A) for part (0x2250); also XIY = that part's record, C = L = the group
; Evidence: PartRecord_GetPtr (XIY = entry (0x2250) of 0xF2AB50), C = L = A = (0x2169), B = (0x2250), W = (0x216A), call T_SoundGroup_MaxMemberIndex_Get; W is saved and restored around it.
; 13 callers, all in this module (the GROUP: SOUND DISPLAY HOLD handlers, LcdKeyRow1..3_SoundGroupMenu, GroupSoundDisplayHold_HighlightSelected).
SoundGroup_SelectedMaxMemberIndex:
	push W                                               ; F92F7F  c8 04
	calr PartRecord_GetPtr                                          ; F92F81  1e b5 15
	ld c, (SoundSel_Group:16)                                   ; F92F84  c1 69 21 23
	and C,0xff                                           ; F92F88  cb cc ff
	ld L,C                                               ; F92F8B  cb 8f
	ld A,L                                               ; F92F8D  cf 89
	ld b, (UI_PartIndex:16)                                   ; F92F8F  c1 50 22 22
	ld w, (SoundSel_Bank:16)                                   ; F92F93  c1 6a 21 20
	call T_SoundGroup_MaxMemberIndex_Get                 ; F92F97  1d 1c 10 f4
	pop W                                                ; F92F9B  c8 05
	ret                                                  ; F92F9D  0e
; LcdKeyRow1_GroupSoundDisplayHold -- LCD row-1 keys on GROUP: SOUND DISPLAY HOLD: pick the sound in row 1 of the shown page (left key) or of its right-hand column (right key, +4)
; Evidence: slot [8] (code 0x08 = LCD row 1) of ScreenButtonHandlers_GroupSoundDisplayHold; A = SoundGroup_SelectedMaxMemberIndex, HL = 0, calr GroupSoundDisplayHold_PickSound (which adds 4 when W bit 7 is clear, the right key).
LcdKeyRow1_GroupSoundDisplayHold:   ; entry: named by 1 `.long` operand, first at 0xF92C86
	calr SoundGroup_SelectedMaxMemberIndex                                      ; F92F9E  1e de ff
	ldw hl, 0x00                                         ; F92FA1  33 00 00
	calr GroupSoundDisplayHold_PickSound                                      ; F92FA4  1e 66 02
	ret                                                  ; F92FA7  0e
; LcdKeyRow2_GroupSoundDisplayHold -- LCD row-2 keys on GROUP: SOUND DISPLAY HOLD: pick the sound in row 2 of the shown page (left key) or of its right-hand column (right key, +4)
; Evidence: slot [9] (code 0x09 = LCD row 2) of ScreenButtonHandlers_GroupSoundDisplayHold; A = SoundGroup_SelectedMaxMemberIndex, HL = 1, calr GroupSoundDisplayHold_PickSound (which adds 4 when W bit 7 is clear, the right key).
LcdKeyRow2_GroupSoundDisplayHold:   ; entry: named by 1 `.long` operand, first at 0xF92C8A
	calr SoundGroup_SelectedMaxMemberIndex                                      ; F92FA8  1e d4 ff
	ldw hl, 0x01                                         ; F92FAB  33 01 00
	calr GroupSoundDisplayHold_PickSound                                      ; F92FAE  1e 5c 02
	ret                                                  ; F92FB1  0e
; LcdKeyRow3_GroupSoundDisplayHold -- LCD row-3 keys on GROUP: SOUND DISPLAY HOLD: pick the sound in row 3 of the shown page (left key) or of its right-hand column (right key, +4)
; Evidence: slot [10] (code 0x0A = LCD row 3) of ScreenButtonHandlers_GroupSoundDisplayHold; A = SoundGroup_SelectedMaxMemberIndex, HL = 2, calr GroupSoundDisplayHold_PickSound (which adds 4 when W bit 7 is clear, the right key).
LcdKeyRow3_GroupSoundDisplayHold:   ; entry: named by 1 `.long` operand, first at 0xF92C8E
	calr SoundGroup_SelectedMaxMemberIndex                                      ; F92FB2  1e ca ff
	ldw hl, 0x02                                         ; F92FB5  33 02 00
	calr GroupSoundDisplayHold_PickSound                                      ; F92FB8  1e 52 02
	ret                                                  ; F92FBB  0e
; LcdKeyRow4_GroupSoundDisplayHold -- LCD row-4 keys on GROUP: SOUND DISPLAY HOLD: pick the sound in row 4 of the shown page (left key) or of its right-hand column (right key, +4)
; Evidence: slot [11] (code 0x0B = LCD row 4) of ScreenButtonHandlers_GroupSoundDisplayHold; A = SoundGroup_SelectedMaxMemberIndex, HL = 3, calr GroupSoundDisplayHold_PickSound (which adds 4 when W bit 7 is clear, the right key).
LcdKeyRow4_GroupSoundDisplayHold:   ; entry: named by 1 `.long` operand, first at 0xF92C92
	calr SoundGroup_SelectedMaxMemberIndex                                      ; F92FBC  1e c0 ff
	ldw hl, 0x03                                         ; F92FBF  33 03 00
	calr GroupSoundDisplayHold_PickSound                                      ; F92FC2  1e 48 02
	ret                                                  ; F92FC5  0e
.LF92FC6:
	ret                                                  ; F92FC6  0e
	ld XWA,GroupMembers_ShowFirstOfTwoPages                                    ; F92FC7  40 2b 30 f9 00
	push XWA                                             ; F92FCC  38
	call T_CallbackQueue_Post                            ; F92FCD  1d 84 2e f4
	inc 4,XSP                                            ; F92FD1  ef 64
	ld a, 0x01:opc                                          ; F92FD3  21 01
	call T_Kernel_SemaSignal                             ; F92FD5  1d 88 2d f4
	jr .LF92FC6                                          ; F92FD9  68 eb
	ld XWA,GroupMembers_ShowSecondOfTwoPages                                    ; F92FDB  40 37 30 f9 00
	push XWA                                             ; F92FE0  38
	call T_CallbackQueue_Post                            ; F92FE1  1d 84 2e f4
	inc 4,XSP                                            ; F92FE5  ef 64
	ld a, 0x01:opc                                          ; F92FE7  21 01
	call T_Kernel_SemaSignal                             ; F92FE9  1d 88 2d f4
	jr .LF92FC6                                          ; F92FED  68 d7
	ld XWA,GroupMembers_ShowFirstOfManyPages                                    ; F92FEF  40 43 30 f9 00
	push XWA                                             ; F92FF4  38
	call T_CallbackQueue_Post                            ; F92FF5  1d 84 2e f4
	inc 4,XSP                                            ; F92FF9  ef 64
	ld a, 0x01:opc                                          ; F92FFB  21 01
	call T_Kernel_SemaSignal                             ; F92FFD  1d 88 2d f4
	jr .LF92FC6                                          ; F93001  68 c3
	ld XWA,GroupMembers_ShowNextOfManyPages                                    ; F93003  40 4f 30 f9 00
	push XWA                                             ; F93008  38
	call T_CallbackQueue_Post                            ; F93009  1d 84 2e f4
	inc 4,XSP                                            ; F9300D  ef 64
	ld a, 0x01:opc                                          ; F9300F  21 01
	call T_Kernel_SemaSignal                             ; F93011  1d 88 2d f4
	jr .LF92FC6                                          ; F93015  68 af
	ld XWA,GroupMembers_ShowNextOfManyPages                                    ; F93017  40 4f 30 f9 00
	push XWA                                             ; F9301C  38
	call T_CallbackQueue_Post                            ; F9301D  1d 84 2e f4
	inc 4,XSP                                            ; F93021  ef 64
	ld a, 0x01:opc                                          ; F93023  21 01
	call T_Kernel_SemaSignal                             ; F93025  1d 88 2d f4
	jr .LF92FC6                                          ; F93029  68 9b
; GroupMembers_ShowFirstOfTwoPages -- clears rows 29-235 of layer 0 and shows page 1 (members 0-7) of a two-page group
; Evidence: LCD_ClearLayer0_Rows29To235, SoundGroup_SelectedMaxMemberIndex, L = 0, GroupMembers_ShowPageOfTwo.
; UNREACHABLE: its only reference is the `ld XWA` immediate at 0xF92FC7, in a post block after the `ret` at 0xF92FC6 that no branch, table entry or 32-bit immediate in any image names (lane prom_a-s02 checked all four ROM dumps for the block addresses).
GroupMembers_ShowFirstOfTwoPages:   ; entry: named by 1 `ld` operand, first at 0xF92FC7
	calr LCD_ClearLayer0_Rows29To235                                          ; F9302B  1e 4e 04
	calr SoundGroup_SelectedMaxMemberIndex                                      ; F9302E  1e 4e ff
	ld l, 0x00:opc                                          ; F93031  27 00
	calr GroupMembers_ShowPageOfTwo                                      ; F93033  1e 00 fe
	ret                                                  ; F93036  0e
; GroupMembers_ShowSecondOfTwoPages -- clears rows 29-235 of layer 0 and shows page 2 (members 8..max) of a two-page group
; Evidence: LCD_ClearLayer0_Rows29To235, SoundGroup_SelectedMaxMemberIndex, L = 8, GroupMembers_ShowPageOfTwo.
; UNREACHABLE: its only reference is the `ld XWA` immediate at 0xF92FDB, in a post block after the `ret` at 0xF92FC6 that no branch, table entry or 32-bit immediate in any image names (lane prom_a-s02 checked all four ROM dumps for the block addresses).
GroupMembers_ShowSecondOfTwoPages:   ; entry: named by 1 `ld` operand, first at 0xF92FDB
	calr LCD_ClearLayer0_Rows29To235                                          ; F93037  1e 42 04
	calr SoundGroup_SelectedMaxMemberIndex                                      ; F9303A  1e 42 ff
	ld l, 0x08:opc                                          ; F9303D  27 08
	calr GroupMembers_ShowPageOfTwo                                      ; F9303F  1e f4 fd
	ret                                                  ; F93042  0e
; GroupMembers_ShowFirstOfManyPages -- clears rows 29-235 of layer 0 and shows the first page of a many-page group
; Evidence: LCD_ClearLayer0_Rows29To235, SoundGroup_SelectedMaxMemberIndex, L = 0, GroupMembers_ShowPageOfMany.
; UNREACHABLE: its only reference is the `ld XWA` immediate at 0xF92FEF, in a post block after the `ret` at 0xF92FC6 that no branch, table entry or 32-bit immediate in any image names (lane prom_a-s02 checked all four ROM dumps for the block addresses).
GroupMembers_ShowFirstOfManyPages:   ; entry: named by 1 `ld` operand, first at 0xF92FEF
	calr LCD_ClearLayer0_Rows29To235                                          ; F93043  1e 36 04
	calr SoundGroup_SelectedMaxMemberIndex                                      ; F93046  1e 36 ff
	ld l, 0x00:opc                                          ; F93049  27 00
	calr GroupMembers_ShowPageOfMany                                      ; F9304B  1e 28 fe
	ret                                                  ; F9304E  0e
; GroupMembers_ShowNextOfManyPages -- clears rows 29-235 of layer 0 and shows the page after the current one (0x2670) of a many-page group
; Evidence: LCD_ClearLayer0_Rows29To235, SoundGroup_SelectedMaxMemberIndex, L = ((0x2670)+1)*8, GroupMembers_ShowPageOfMany.
; UNREACHABLE: its only references are the `ld XWA` immediates at 0xF93003 and 0xF93017, in post blocks after the `ret` at 0xF92FC6 that no branch, table entry or 32-bit immediate in any image names (lane prom_a-s02 checked all four ROM dumps for the block addresses).
GroupMembers_ShowNextOfManyPages:   ; entry: named by 2 `ld` operands, first at 0xF93003
	calr LCD_ClearLayer0_Rows29To235                                          ; F9304F  1e 2a 04
	calr SoundGroup_SelectedMaxMemberIndex                                      ; F93052  1e 2a ff
	pushw wa                                             ; F93055  28
	ld a, (GroupMembers_Page:16)                                   ; F93056  c1 70 26 21
	inc 1,A                                              ; F9305A  c9 61
	xor W,W                                              ; F9305C  c8 d0
	ld l, 0x08:opc                                          ; F9305E  27 08
	mul wa, l                                          ; F93060  cf 41
	ld L,A                                               ; F93062  c9 8f
	popw wa                                              ; F93064  48
	calr GroupMembers_ShowPageOfMany                                      ; F93065  1e 0e fe
	ret                                                  ; F93068  0e
ScreenButtonHandlers_GroupSoundDisplayHold_Nop13:   ; entry: named by 1 `.long` operand, first at 0xF92C9A
	ret                                                  ; F93069  0e
ScreenButtonHandlers_GroupSoundDisplayHold_Nop14:   ; entry: named by 1 `.long` operand, first at 0xF92C9E
	ret                                                  ; F9306A  0e
; ExitKey_GroupSoundDisplayHold -- EXIT on GROUP: SOUND DISPLAY HOLD: requests screen 1 (SOUND MODE)
; Evidence: slot [15] (code 0x0F = EXIT) of ScreenButtonHandlers_GroupSoundDisplayHold. When W bit 7 is clear: (0x2070) = 0x8001 and, if (0x2092) bit 0 is set, (0x209A) = 1, (0x2071) = 0, (0x2075) &= 0x7F.
; Same shape as ExitKey_SoundGroupMenu plus the (0x2075) bit-7 clear.
ExitKey_GroupSoundDisplayHold:   ; entry: named by 1 `.long` operand, first at 0xF92CA2
	bit 0x07,W                                           ; F9306B  c8 33 07
	jr nz, .LF9308D                                      ; F9306E  6e 1d
	ldw (UI_Request:16), 0x8001                              ; F93070  f1 70 20 02 01 80
	bit	0, (UI_ScreenHoldState:16)                               ; F93076  f1 92 20 c8
	jr z, .LF9308B                                       ; F9307A  66 0f
	ld (UI_ScreenHoldPending:16), 0x01                                 ; F9307C  f1 9a 20 00 01
	ld (UI_Request_Hi:16), 0x00                                 ; F93081  f1 71 20 00 00
	and	(UI_RequestBits:16), 0x7f                            ; F93086  c1 75 20 3c 7f
.LF9308B:
	jr .LF9308D                                          ; F9308B  68 00
.LF9308D:
	ret                                                  ; F9308D  0e
; NumberPadKey_GroupSoundDisplayHold -- NUMBER PAD on GROUP: SOUND DISPLAY HOLD: types a group number and, when complete and in range, selects that group
; Evidence: slot [27] (code 0x1B = NUMBER PAD) of ScreenButtonHandlers_GroupSoundDisplayHold. (0x2823) == 0x20 -> T_Blink_Stop only. When (0x2267) & 0x0F == 0x0F: (0x2826) = 2, T_AsciiDigits3_ToValue;
; a value in 1..B (B = 16; 1 for UD1/UD2; 2 for RD; (0x08E8) for E1) becomes (0x2169) = value - 1, with T_Queue2E00_AppendRegs {E=0xA8, D=0x08, A=group, W=0x0F} and T_Blink_Stop.
; Every path except the first ends by posting DisplayHold_ShowTypedGroupDigits.
NumberPadKey_GroupSoundDisplayHold:   ; entry: named by 1 `.long` operand, first at 0xF92CD2
	cp	(0x2823:16), 0x20                            ; F9308E  c1 23 28 3f 20
	jr nz, .LF9309B                                      ; F93093  6e 06
	call T_Blink_Stop                                    ; F93095  1d 24 2e f4
	jr .LF93108                                          ; F93099  68 6d
.LF9309B:
	ld a, (0x2267:16)                                   ; F9309B  c1 67 22 21
	and A,0x0f                                           ; F9309F  c9 cc 0f
	cp A,0x0f                                            ; F930A2  c9 cf 0f
	jr nz, .LF930F6                                      ; F930A5  6e 4f
	ld (0x2826:16), 0x02                                 ; F930A7  f1 26 28 00 02
	call T_AsciiDigits3_ToValue                          ; F930AC  1d f0 32 f4
	ld b, 0x10:opc                                          ; F930B0  22 10
	ld d, (SoundSel_Bank:16)                                   ; F930B2  c1 6a 21 24
	cp D,0x28                                            ; F930B6  cc cf 28
	jr z, .LF930CC                                       ; F930B9  66 11
	cp D,0x29                                            ; F930BB  cc cf 29
	jr z, .LF930CC                                       ; F930BE  66 0c
	cp D,0x20                                            ; F930C0  cc cf 20
	jr z, .LF930D0                                       ; F930C3  66 0b
	cp D,0x10                                            ; F930C5  cc cf 10
	jr z, .LF930D4                                       ; F930C8  66 0a
	jr .LF930D8                                          ; F930CA  68 0c
.LF930CC:
	ld b, 0x01:opc                                          ; F930CC  22 01
	jr .LF930D8                                          ; F930CE  68 08
.LF930D0:
	ld b, 0x02:opc                                          ; F930D0  22 02
	jr .LF930D8                                          ; F930D2  68 04
.LF930D4:
	ld b, (0x08e8:16)                                   ; F930D4  c1 e8 08 22
.LF930D8:
	ld c, 0x01:opc                                          ; F930D8  23 01
	cp A,C                                               ; F930DA  cb f1
	jr c, .LF930F6                                       ; F930DC  67 18
	cp A,B                                               ; F930DE  ca f1
	jr ugt, .LF930F6                                     ; F930E0  6b 14
	dec 1,A                                              ; F930E2  c9 69
	ld (SoundSel_Group:16), a                                   ; F930E4  f1 69 21 41
	ld e, 0xa8:opc                                          ; F930E8  25 a8
	ld d, 0x08:opc                                          ; F930EA  24 08
	ld w, 0x0f:opc                                          ; F930EC  20 0f
	call T_Queue2E00_AppendRegs                          ; F930EE  1d 3c 0f f4
	call T_Blink_Stop                                    ; F930F2  1d 24 2e f4
.LF930F6:
	ld XWA,DisplayHold_ShowTypedGroupDigits                                    ; F930F6  40 09 31 f9 00
	push XWA                                             ; F930FB  38
	call T_CallbackQueue_Post                            ; F930FC  1d 84 2e f4
	inc 4,XSP                                            ; F93100  ef 64
	ld a, 0x01:opc                                          ; F93102  21 01
	call T_Kernel_SemaSignal                             ; F93104  1d 88 2d f4
.LF93108:
	ret                                                  ; F93108  0e
; DisplayHold_ShowTypedGroupDigits -- shows the digits typed so far in the group-number field, blinking
; Evidence: (0x2661) = word (0x2822); (0x2540) = 0; T_Blink_Command with record DL_F2BA64 (interpreter B: 2 characters of (0x2661) at IX 0x0166 = x 0x130, y 8 -- the field right of "GROUP:").
; Posted by NumberPadKey_GroupSoundDisplayHold and by NumberPadKey_GroupCombiDisplayHold, the GROUP: COMBI. DISPLAY HOLD twin.
DisplayHold_ShowTypedGroupDigits:   ; entry: named by 2 `ld` operands, first at 0xF930F6
	ld wa, (0x2822:16)                                 ; F93109  d1 22 28 20
	ld (Value_AsciiDigits:16), wa                                  ; F9310D  f1 61 26 50
	ld (LCD_CurrentLayer:16), 0x00                                 ; F93111  f1 40 25 00 00
	ld XIY,DL_F2BA64                                     ; F93116  45 64 ba f2 00
	push XIY                                             ; F9311B  3d
	call T_Blink_Command                                 ; F9311C  1d 20 2e f4
	inc 4,XSP                                            ; F93120  ef 64
	ret                                                  ; F93122  0e
sub_F92C62_Nop:
	ret                                                  ; F93123  0e
; DisplayHold_ShowGroupNumber -- draws the selected group's number, (0x2169)+1, as two characters after "GROUP:" -- blinking on panel variant 2
; Evidence: A = (0x2169) + 1, T_Value_ToAsciiDigits3_LeftJustified (sub_F8BC8A: Value_ToAsciiDigits3, left-justified into (0x2661)); (0xC4) != 2: layer 1, DL_F2BA64..DL_Ext1 through interpreter B (site 0xF93145, the only display-list site, as the earlier header said); (0xC4) == 2: layer 0, T_Blink_Command with DL_F2BA64.
; DL_F2BA64 draws 2 characters of (0x2661) at IX 0x0166 (x 0x130, y 8), right of "GROUP:" at (0x10D,0x0A) in both DISPLAY HOLD screens' lists.
; Callers: GroupSoundDisplayHold_RepaintFields, GroupCombiDisplayHold_PaintGroupAndNames; posted by GroupSoundDisplayHold_PickSound, GroupSoundDisplayHold_SelectMemberLastPage, GroupCombiDisplayHold_SelectMemberAtRow, GroupCombiDisplayHold_SelectMemberLastPage.
DisplayHold_ShowGroupNumber:
	ld a, (SoundSel_Group:16)                                   ; F93124  c1 69 21 21
	inc 1,A                                              ; F93128  c9 61
	extz WA                                              ; F9312A  d8 12
	call T_Value_ToAsciiDigits3_LeftJustified                                        ; F9312C  1d f4 1a f4
	cp	(Variant_Flag:8), 0x02                               ; F93130  c0 c4 3f 02
	jr z, .LF9314B                                       ; F93134  66 15
	ld (LCD_CurrentLayer:16), 0x01                                 ; F93136  f1 40 25 00 01
	ld XIY,DL_F2BA64                                     ; F9313B  45 64 ba f2 00
	ld XIX,DL_Ext1                                       ; F93140  44 73 ba f2 00
	call T_DisplayListB_Run                              ; F93145  1d f4 17 f4
	jr .LF9315C                                          ; F93149  68 11
.LF9314B:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9314B  f1 40 25 00 00
	ld XIY,DL_F2BA64                                     ; F93150  45 64 ba f2 00
	push XIY                                             ; F93155  3d
	call T_Blink_Command                                 ; F93156  1d 20 2e f4
	inc 4,XSP                                            ; F9315A  ef 64
.LF9315C:
	ret                                                  ; F9315C  0e
; DisplayHold_DrawHoldHighlight -- shows the DISPLAY HOLD state: fills (bit set) or erases (bit clear) the box over "DISPLAY HOLD"
; Evidence: layer 1; (0x267F) bit 0 set -> DisplayHold_DrawHoldHighlight_DL1..DisplayHold_DrawHoldHighlight_DL2 (op-05 FillRect (0xFE,0xD4)-(0x139,0xEC), site 0xF93172), clear -> DisplayHold_DrawHoldHighlight_DL2..DL_Drum (op-1B EraseRect, same box, site 0xF93182) -- the two sites the earlier header listed.
; The box holds "DISPLAY" (IX 0x2190) and "HOLD" (IX 0x2371) of both DISPLAY HOLD screens' lists. SoftKeyCol7/8_GroupSoundDisplayHold toggle the bit and post this routine (SoftKeyCol7_GroupCombiDisplayHold / SoftKeyCol8_GroupCombiDisplayHold on the COMBI. screen);
; callers GroupSoundDisplayHold_RepaintFields and GroupCombiDisplayHold_PaintGroupAndNames.
DisplayHold_DrawHoldHighlight:
	ld (LCD_CurrentLayer:16), 0x01                                 ; F9315D  f1 40 25 00 01
	bit	0, (DisplayHold_Flag:16)                               ; F93162  f1 7f 26 c8
	jr z, .LF93178                                       ; F93166  66 10
	ld XIY,DisplayHold_DrawHoldHighlight_DL1                                     ; F93168  45 0c ba f2 00
	ld XIX,DisplayHold_DrawHoldHighlight_DL2                                     ; F9316D  44 16 ba f2 00
	call T_DisplayList_Run                               ; F93172  1d f0 17 f4
	jr .LF93186                                          ; F93176  68 0e
.LF93178:
	ld XIY,DisplayHold_DrawHoldHighlight_DL2                                     ; F93178  45 16 ba f2 00
	ld XIX,DL_Drum                                       ; F9317D  44 20 ba f2 00
	call T_DisplayList_Run                               ; F93182  1d f0 17 f4
.LF93186:
	ret                                                  ; F93186  0e
; SoundBank_IsReMap -- A = 1 when the selected bank (0x216A) is 0x18, 0x19 or 0x1A, else A = 0
; Evidence: `cp W,0x18 / 0x19 / 0x1A` at 0xF9318D-0xF9319A. Those codes are "M1-" "M2-" "M3-" in DLText_PartCodes, and when this returns 1 Paint_SoundGroupMenuScreen draws DL_SoundGroupMenuReMap1ReMap2 ("RE-MAP1" "RE-MAP2" "RE-MAP3") instead of the "USER1" "USER2" "ROM/EXT" list.
; In those banks the selectors (SoundBank_Select*, SoundGroup_StepSelected) do nothing, Paint_Drum skips "DRUM" and BankLegend_DrawUser erases the legend row.
SoundBank_IsReMap:
	ld a, 0x01:opc                                          ; F93187  21 01
	ld w, (SoundSel_Bank:16)                                   ; F93189  c1 6a 21 20
	cp W,0x18                                            ; F9318D  c8 cf 18
	jr z, .LF9319E                                       ; F93190  66 0c
	cp W,0x19                                            ; F93192  c8 cf 19
	jr z, .LF9319E                                       ; F93195  66 07
	cp W,0x1a                                            ; F93197  c8 cf 1a
	jr z, .LF9319E                                       ; F9319A  66 02
	ld a, 0x00:opc                                          ; F9319C  21 00
.LF9319E:
	ret                                                  ; F9319E  0e
; GroupSoundDisplayHold_DrawNumberRange -- draws the selected group's sound-number range "first-last" in a frame
; Evidence: A = SoundGroup_SelectedMaxMemberIndex, then `jr` into GroupCombiDisplayHold_DrawNumberRange's body at .LF931A7: first = 8*(0x2169)+1, last = 8*(0x2169)+A+1, each through T_Value_ToAsciiDigits3 and an interpreter-B record
; (GroupCombiDisplayHold_DrawNumberRange_DL2 at IX 0x1D12, GroupCombiDisplayHold_DrawNumberRange_DL1 at IX 0x1D16), with GroupCombiDisplayHold_DrawNumberRange_DL3 drawing "-" at IX 0x1D15 and the frame. 8*group + member + 1 is the numbering C0mbinati0nM0de_DrawPart8Sound shows.
; Called only by GroupSoundDisplayHold_RepaintFields.
GroupSoundDisplayHold_DrawNumberRange:
	calr SoundGroup_SelectedMaxMemberIndex                                      ; F9319F  1e dd fd
	jr .LF931A7                                          ; F931A2  68 03
; GroupCombiDisplayHold_DrawNumberRange -- GROUP: COMBI. DISPLAY HOLD: draws the selected group's number range "first-last" in a frame
; Evidence: A = CombiGroup_MaxMemberIndexOfCurrent (T_SoundGroup_MaxMemberIndex_GetToneCopy with A = (0x2169), B = 0x98, W = (0x216A)); (0x2640) = 8*(0x2169)+A+1 and (0x2641) = 8*(0x2169)+1, each through T_Value_ToAsciiDigits3 into (0x2661) and drawn by interpreter B --
; GroupCombiDisplayHold_DrawNumberRange_DL1 at IX 0x1D16 (site 0xF931D8) and GroupCombiDisplayHold_DrawNumberRange_DL2 at IX 0x1D12 (0xF931F5) -- then GroupCombiDisplayHold_DrawNumberRange_DL3..GroupDisplayHold_ClearNameSlots_DL by interpreter A (0xF93208): the "-" at IX 0x1D15 and the frame lines. These are the three sites the earlier header listed.
; Called only by GroupCombiDisplayHold_PaintGroupAndNames, posted by InstallPainter_GroupCombiDisplayHold; GroupSoundDisplayHold_DrawNumberRange enters the same body.
GroupCombiDisplayHold_DrawNumberRange:
	calr CombiGroup_MaxMemberIndexOfCurrent                                          ; F931A4  1e 8c 09
.LF931A7:
	ld d, (SoundSel_Group:16)                                   ; F931A7  c1 69 21 24
	ld l, 0x08:opc                                          ; F931AB  27 08
	mul hl, d                                          ; F931AD  cc 47
	inc 1,A                                              ; F931AF  c9 61
	add L,A                                              ; F931B1  c9 87
	ld (UI_DrawScratch:16), l                                   ; F931B3  f1 40 26 47
	sub L,A                                              ; F931B7  c9 a7
	inc 1,L                                              ; F931B9  cf 61
	ld (UI_DrawScratch+1:16), l                                   ; F931BB  f1 41 26 47
	ld a, (UI_DrawScratch:16)                                   ; F931BF  c1 40 26 21
	extz WA                                              ; F931C3  d8 12
	call T_Value_ToAsciiDigits3                          ; F931C5  1d 00 1b f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; F931C9  f1 40 25 00 00
	ld XIY,GroupCombiDisplayHold_DrawNumberRange_DL1                                     ; F931CE  45 c3 bd f2 00
	ld XIX,GroupCombiDisplayHold_DrawNumberRange_DL3                                     ; F931D3  44 d2 bd f2 00
	call T_DisplayListB_Run                              ; F931D8  1d f4 17 f4
	ld a, (UI_DrawScratch+1:16)                                   ; F931DC  c1 41 26 21
	extz WA                                              ; F931E0  d8 12
	call T_Value_ToAsciiDigits3                          ; F931E2  1d 00 1b f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; F931E6  f1 40 25 00 00
	ld XIY,GroupCombiDisplayHold_DrawNumberRange_DL2                                     ; F931EB  45 b4 bd f2 00
	ld XIX,GroupCombiDisplayHold_DrawNumberRange_DL1                                     ; F931F0  44 c3 bd f2 00
	call T_DisplayListB_Run                              ; F931F5  1d f4 17 f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; F931F9  f1 40 25 00 00
	ld XIY,GroupCombiDisplayHold_DrawNumberRange_DL3                                     ; F931FE  45 d2 bd f2 00
	ld XIX,GroupDisplayHold_ClearNameSlots_DL                                     ; F93203  44 f5 bd f2 00
	call T_DisplayList_Run                               ; F93208  1d f0 17 f4
	ret                                                  ; F9320C  0e
; GroupSoundDisplayHold_PickSound -- assigns the sound in LCD row HL (left key) or HL+4 (right key) of the shown page to the current part, then leaves for the mode screen unless DISPLAY HOLD is on
; Evidence: member = 8*(0x2670) + HL, +4 when W bit 7 is clear; ignored when above A (the max index). (0x216B) = member; T_List2030_AppendRegs {E=(0x2250), D=0, A=(0x216A), W=0x3F} and {E=(0x2250), D=0, A=(0x2169), W=member} --
; the bank / group-member pair C0mbinati0nM0de_StepPartSound also posts. Then (0x2673) |= 8, T_Blink_Stop, posts DisplayHold_ShowGroupNumber and GroupSoundDisplayHold_HighlightSelected;
; if (0x267F) bit 0 is clear: (0x2070) = 0x8001 (SOUND MODE) when on screen 0xA1, else 0x8002 (COMBINATION MODE). With A != 8 on the last page ((0x2670) == (0x2672)) it calls GroupSoundDisplayHold_SelectMemberLastPage instead.
; Callers: LcdKeyRow1..4_GroupSoundDisplayHold.
GroupSoundDisplayHold_PickSound:
	cp A,0x08                                            ; F9320D  c9 cf 08
	jr z, .LF93222                                       ; F93210  66 10
	ld e, (GroupMembers_Page:16)                                   ; F93212  c1 70 26 25
	cp	e, (0x2672:16)                               ; F93216  c1 72 26 f5
	jr nz, .LF93222                                      ; F9321A  6e 06
	calr GroupSoundDisplayHold_SelectMemberLastPage                                      ; F9321C  1e a7 00
	jrl .LF932C5                                         ; F9321F  78 a3 00
.LF93222:
	pushw wa                                             ; F93222  28
	ld a, (GroupMembers_Page:16)                                   ; F93223  c1 70 26 21
	xor W,W                                              ; F93227  c8 d0
	ld e, 0x08:opc                                          ; F93229  25 08
	mul wa, e                                          ; F9322B  cd 41
	add HL,WA                                            ; F9322D  d8 83
	popw wa                                              ; F9322F  48
	bit 0x07,W                                           ; F93230  c8 33 07
	jr nz, .LF9323D                                      ; F93233  6e 08
	inc 1,L                                              ; F93235  cf 61
	inc 1,L                                              ; F93237  cf 61
	inc 1,L                                              ; F93239  cf 61
	inc 1,L                                              ; F9323B  cf 61
.LF9323D:
	cp A,L                                               ; F9323D  cf f1
	jrl c, .LF932C5                                      ; F9323F  77 83 00
	ld (SoundSel_Member:16), l                                   ; F93242  f1 6b 21 47
	ld e, (UI_PartIndex:16)                                   ; F93246  c1 50 22 25
	ld d, 0x00:opc                                          ; F9324A  24 00
	ld a, (SoundSel_Bank:16)                                   ; F9324C  c1 6a 21 21
	ld w, 0x3f:opc                                          ; F93250  20 3f
	call T_List2030_AppendRegs                           ; F93252  1d 40 0f f4
	ld e, (UI_PartIndex:16)                                   ; F93256  c1 50 22 25
	ld d, 0x00:opc                                          ; F9325A  24 00
	ld a, (SoundSel_Group:16)                                   ; F9325C  c1 69 21 21
	ld w, (SoundSel_Member:16)                                   ; F93260  c1 6b 21 20
	call T_List2030_AppendRegs                           ; F93264  1d 40 0f f4
	or	(0x2673:16), 0x08                            ; F93268  c1 73 26 3e 08
	call T_Blink_Stop                                    ; F9326D  1d 24 2e f4
	ld XWA,DisplayHold_ShowGroupNumber                                    ; F93271  40 24 31 f9 00
	push XWA                                             ; F93276  38
	call T_CallbackQueue_Post                            ; F93277  1d 84 2e f4
	inc 4,XSP                                            ; F9327B  ef 64
	ld a, 0x01:opc                                          ; F9327D  21 01
	call T_Kernel_SemaSignal                             ; F9327F  1d 88 2d f4
	ld XWA,GroupSoundDisplayHold_HighlightSelected                                    ; F93283  40 98 33 f9 00
	push XWA                                             ; F93288  38
	call T_CallbackQueue_Post                            ; F93289  1d 84 2e f4
	inc 4,XSP                                            ; F9328D  ef 64
	ld a, 0x01:opc                                          ; F9328F  21 01
	call T_Kernel_SemaSignal                             ; F93291  1d 88 2d f4
	bit	0, (DisplayHold_Flag:16)                               ; F93295  f1 7f 26 c8
	jr nz, .LF932C5                                      ; F93299  6e 2a
	cp	(UI_ScreenId:16), 0xa1                            ; F9329B  c1 7c 20 3f a1
	jr nz, .LF932AA                                      ; F932A0  6e 08
	ldw (UI_Request:16), 0x8001                              ; F932A2  f1 70 20 02 01 80
	jr .LF932B0                                          ; F932A8  68 06
.LF932AA:
	ldw (UI_Request:16), 0x8002                              ; F932AA  f1 70 20 02 02 80
.LF932B0:
	bit	0, (UI_ScreenHoldState:16)                               ; F932B0  f1 92 20 c8
	jr z, .LF932C5                                       ; F932B4  66 0f
	ld (UI_ScreenHoldPending:16), 0x01                                 ; F932B6  f1 9a 20 00 01
	ld (UI_Request_Hi:16), 0x00                                 ; F932BB  f1 71 20 00 00
	and	(UI_RequestBits:16), 0x7f                            ; F932C0  c1 75 20 3c 7f
.LF932C5:
	ret                                                  ; F932C5  0e
; GroupSoundDisplayHold_SelectMemberLastPage -- pick a group member from an LCD-row key when the shown page is the group's last page
; Evidence: only caller sub_F9320D (reached from ScreenButtonHandlers_GroupSoundDisplayHold [8]-[11]) branches here when (0x2670) == (0x2672) and A != 8.
; BC = word table 0xF93386[A mod 8] (B = last usable row, C = right-column offset); L = row + C (W bit 7 clear) + (0x2670)*8; if L <= A: (0x216B) = L,
; posts {(0x2250),0x00,(0x216A),0x3F} and {(0x2250),0x00,(0x2169),L} via T_List2030_AppendRegs, (0x2673) |= 8, T_Blink_Stop, queues sub_F93124 and
; GroupSoundDisplayHold_HighlightSelected; unless (0x267F) bit 0 (DISPLAY HOLD) requests screen 0x01 (from 0xA1) or 0x02 via (0x2070).
; In: A = max member index, HL = row 0..3, W bit 7 = which key of the row pair. Twin: GroupCombiDisplayHold_SelectMemberLastPage.
GroupSoundDisplayHold_SelectMemberLastPage:
	pushw wa                                             ; F932C6  28
	pushw hl                                             ; F932C7  2b
	xor W,W                                              ; F932C8  c8 d0
	ld e, 0x08:opc                                          ; F932CA  25 08
	div wa, e                                          ; F932CC  cd 51
	ld L,W                                               ; F932CE  c8 8f
	xor H,H                                              ; F932D0  ce d6
	sla hl, 0x01                                         ; F932D2  db ec 01
	push XIY                                             ; F932D5  3d
	ld XIY,GroupSoundDisplayHold_SelectMemberLastPage__F93386                                    ; F932D6  45 86 33 f9 00
	ld	bc, (xiy+hl)                                 ; F932DB  d3 07 f4 ec 21
	pop XIY                                              ; F932E0  5d
	popw hl                                              ; F932E1  4b
	popw wa                                              ; F932E2  48
	cp L,B                                               ; F932E3  ca f7
	jrl ugt, .LF93385                                    ; F932E5  7b 9d 00
	pushw wa                                             ; F932E8  28
	xor W,W                                              ; F932E9  c8 d0
	ld a, (GroupMembers_Page:16)                                   ; F932EB  c1 70 26 21
	ld e, 0x08:opc                                          ; F932EF  25 08
	mul wa, e                                          ; F932F1  cd 41
	add HL,WA                                            ; F932F3  d8 83
	popw wa                                              ; F932F5  48
	bit 0x07,W                                           ; F932F6  c8 33 07
	jr nz, .LF932FD                                      ; F932F9  6e 02
	add L,C                                              ; F932FB  cb 87
.LF932FD:
	cp A,L                                               ; F932FD  cf f1
	jrl c, .LF93385                                      ; F932FF  77 83 00
	ld (SoundSel_Member:16), l                                   ; F93302  f1 6b 21 47
	ld e, (UI_PartIndex:16)                                   ; F93306  c1 50 22 25
	ld d, 0x00:opc                                          ; F9330A  24 00
	ld a, (SoundSel_Bank:16)                                   ; F9330C  c1 6a 21 21
	ld w, 0x3f:opc                                          ; F93310  20 3f
	call T_List2030_AppendRegs                           ; F93312  1d 40 0f f4
	ld e, (UI_PartIndex:16)                                   ; F93316  c1 50 22 25
	ld d, 0x00:opc                                          ; F9331A  24 00
	ld a, (SoundSel_Group:16)                                   ; F9331C  c1 69 21 21
	ld w, (SoundSel_Member:16)                                   ; F93320  c1 6b 21 20
	call T_List2030_AppendRegs                           ; F93324  1d 40 0f f4
	or	(0x2673:16), 0x08                            ; F93328  c1 73 26 3e 08
	call T_Blink_Stop                                    ; F9332D  1d 24 2e f4
	ld XWA,DisplayHold_ShowGroupNumber                                    ; F93331  40 24 31 f9 00
	push XWA                                             ; F93336  38
	call T_CallbackQueue_Post                            ; F93337  1d 84 2e f4
	inc 4,XSP                                            ; F9333B  ef 64
	ld a, 0x01:opc                                          ; F9333D  21 01
	call T_Kernel_SemaSignal                             ; F9333F  1d 88 2d f4
	ld XWA,GroupSoundDisplayHold_HighlightSelected                                    ; F93343  40 98 33 f9 00
	push XWA                                             ; F93348  38
	call T_CallbackQueue_Post                            ; F93349  1d 84 2e f4
	inc 4,XSP                                            ; F9334D  ef 64
	ld a, 0x01:opc                                          ; F9334F  21 01
	call T_Kernel_SemaSignal                             ; F93351  1d 88 2d f4
	bit	0, (DisplayHold_Flag:16)                               ; F93355  f1 7f 26 c8
	jr nz, .LF93385                                      ; F93359  6e 2a
	cp	(UI_ScreenId:16), 0xa1                            ; F9335B  c1 7c 20 3f a1
	jr nz, .LF9336A                                      ; F93360  6e 08
	ldw (UI_Request:16), 0x8001                              ; F93362  f1 70 20 02 01 80
	jr .LF93370                                          ; F93368  68 06
.LF9336A:
	ldw (UI_Request:16), 0x8002                              ; F9336A  f1 70 20 02 02 80
.LF93370:
	bit	0, (UI_ScreenHoldState:16)                               ; F93370  f1 92 20 c8
	jr z, .LF93385                                       ; F93374  66 0f
	ld (UI_ScreenHoldPending:16), 0x01                                 ; F93376  f1 9a 20 00 01
	ld (UI_Request_Hi:16), 0x00                                 ; F9337B  f1 71 20 00 00
	and	(UI_RequestBits:16), 0x7f                            ; F93380  c1 75 20 3c 7f
.LF93385:
	ret                                                  ; F93385  0e
GroupSoundDisplayHold_SelectMemberLastPage__F93386:
	normal                                               ; F93386  01
	nop                                                  ; F93387  00
	normal                                               ; F93388  01
	nop                                                  ; F93389  00
	push SR                                              ; F9338A  02
	normal                                               ; F9338B  01
	push SR                                              ; F9338C  02
	normal                                               ; F9338D  01
	pop SR                                               ; F9338E  03
	push SR                                              ; F9338F  02
	pop SR                                               ; F93390  03
	push SR                                              ; F93391  02
	max                                                  ; F93392  04
	pop SR                                               ; F93393  03
	max                                                  ; F93394  04
	pop SR                                               ; F93395  03
	halt                                                 ; F93396  05
	max                                                  ; F93397  04
; GroupSoundDisplayHold_HighlightSelected -- erase layer 1's member-list area, then fill the box of the selected member if it is on the shown page
; Evidence: `calr 0xf3` = LCD_EraseLayer1_FixedRect (x 13..306, y 34..167); unless (0x2673) bit 3, the part record's +0x3B/+0x3D (PartRecord_GetSecondHalfPtr,
; (XIY+0x1B)/(XIY+0x1D)) must equal the shown group C and (0x216A); then (0x2671) = slot of (0x216B) on page (0x2670) (remapped through PtrTable_F93444 on
; the last page) and T_F4181C runs prom_b record 0xF2B4C5 = interpreter-B op 03, SWI7 0x05 FillRect of DLTable_F2B4D0[(0x2671)] (8 boxes, 2 columns x 4 rows).
; Callers: sub_F92D70/sub_F92E36/sub_F92E76 (GroupSoundDisplayHold painters); queued by sub_F9320D and GroupSoundDisplayHold_SelectMemberLastPage.
GroupSoundDisplayHold_HighlightSelected:
	calr LCD_EraseLayer1_FixedRect                                            ; F93398  1e f3 00
	calr SoundGroup_SelectedMaxMemberIndex                                      ; F9339B  1e e1 fb
	bit	3, (0x2673:16)                               ; F9339E  f1 73 26 cb
	jr nz, .LF933C5                                      ; F933A2  6e 21
	push_a                                               ; F933A4  14
	calr PartRecord_GetSecondHalfPtr                                          ; F933A5  1e a5 11
	ld L,(XIY+0x1b)                                      ; F933A8  8d 1b 27
	and L,0xff                                           ; F933AB  cf cc ff
	ld H,(XIY+0x1c)                                      ; F933AE  8d 1c 26
	and H,0x7f                                           ; F933B1  ce cc 7f
	ld W,(XIY+0x1d)                                      ; F933B4  8d 1d 20
	and W,0xff                                           ; F933B7  c8 cc ff
	pop_a                                                ; F933BA  15
	cp C,L                                               ; F933BB  cf f3
	jr nz, .LF9343E                                      ; F933BD  6e 7f
	cp	w, (SoundSel_Bank:16)                               ; F933BF  c1 6a 21 f0
	jr nz, .LF9343E                                      ; F933C3  6e 79
.LF933C5:
	ld l, (SoundSel_Member:16)                                   ; F933C5  c1 6b 21 27
	and L,0xff                                           ; F933C9  cf cc ff
	cp a, 0x07:i3                                          ; F933CC  c9 df
	jr nz, .LF933DF                                      ; F933CE  6e 0f
	ld (0x2671:16), l                                   ; F933D0  f1 71 26 47
	ld XIY,0x00f2b4c5                                    ; F933D4  45 c5 b4 f2 00
	call T_DLB_Handler_Array8                                        ; F933D9  1d 1c 18 f4
	jr .LF9343E                                          ; F933DD  68 5f
.LF933DF:
	xor W,W                                              ; F933DF  c8 d0
	ld IZ,WA                                             ; F933E1  d8 8e
	ld a, (GroupMembers_Page:16)                                   ; F933E3  c1 70 26 21
	xor W,W                                              ; F933E7  c8 d0
	ld e, 0x08:opc                                          ; F933E9  25 08
	mul wa, e                                          ; F933EB  cd 41
	cp L,A                                               ; F933ED  c9 f7
	jr c, .LF9343E                                       ; F933EF  67 4d
	add WA,0x0007                                        ; F933F1  d8 c8 07 00
	cp L,A                                               ; F933F5  c9 f7
	jr ugt, .LF9343E                                     ; F933F7  6b 45
	pushw hl                                             ; F933F9  2b
	pushw bc                                             ; F933FA  29
	ld A,L                                               ; F933FB  cf 89
	xor W,W                                              ; F933FD  c8 d0
	ld e, 0x08:opc                                          ; F933FF  25 08
	div wa, e                                          ; F93401  cd 51
	ld C,W                                               ; F93403  c8 8b
	ld a, (GroupMembers_Page:16)                                   ; F93405  c1 70 26 21
	cp	a, (0x2672:16)                               ; F93409  c1 72 26 f1
	jr nz, .LF9342F                                      ; F9340D  6e 20
	ld WA,IZ                                             ; F9340F  de 88
	div wa, e                                          ; F93411  cd 51
	ld L,W                                               ; F93413  c8 8f
	xor H,H                                              ; F93415  ce d6
	sla hl, 0x02                                         ; F93417  db ec 02
	ld XIY,PtrTable_F93444                               ; F9341A  45 44 34 f9 00
	ld	xiy, (xiy+hl)                                ; F9341F  e3 07 f4 ec 25
	ld L,C                                               ; F93424  cb 8f
	xor H,H                                              ; F93426  ce d6
	ld	a, (xiy+hl)                                  ; F93428  c3 07 f4 ec 21
	add C,A                                              ; F9342D  c9 83
.LF9342F:
	ld (0x2671:16), c                                   ; F9342F  f1 71 26 43
	ld XIY,0x00f2b4c5                                    ; F93433  45 c5 b4 f2 00
	call T_DLB_Handler_Array8                                        ; F93438  1d 1c 18 f4
	popw bc                                              ; F9343C  49
	popw hl                                              ; F9343D  4b
.LF9343E:
	ld c, 0x03:opc                                          ; F9343E  23 03
	ld a, 0x0c:opc                                          ; F93440  21 0c
	swi 7                                                ; F93442  ff
	ret                                                  ; F93443  0e
; ---------------------------------------------------------------------
; PtrTable_F93444 -- 7 LE32 pointers, each to a BYTE array
;
; Read by: 0xF9341A `ld XIY,0x00F93444 / ld XIY,(XIY+HL)` -- and then
;          `ld A,(XIY+HL)` at 0xF93428, so the selected entry is the base of a
;          byte array, not a branch target.  The index is
;          `(0x2670) / E` widened and x4 (`div WA,E / ld L,W / xor H,H /
;          sla 0x02,HL`).  A second site, 0xF93EAB, names the same base.
; ENTRY COUNT 7, from notes/prom_a_ptr_tables.py -- NOT from a bound; the
;          divide gives no compile-time limit.  ★ LAST-ENTRY TEST: the word at
;          0xF93460 is 0x00030000, which is not pointer-shaped, and 0xF93460 is
;          where the decode resumes.
; Evidence: the two readers and the shape run with its null control.
; Unknown:  everything the arrays contain.
; ---------------------------------------------------------------------
PtrTable_F93444:
	.long PtrTable_F93444__F93460                                 ; F93444  [  0]
	.long PtrTable_F93444__F93461                                 ; F93448  [  1]
	.long PtrTable_F93444__F93463                                 ; F9344C  [  2]
	.long PtrTable_F93444__F93466                                 ; F93450  [  3]
	.long PtrTable_F93444__F9346A                                 ; F93454  [  4]
	.long PtrTable_F93444__F9346F                                 ; F93458  [  5]
	.long PtrTable_F93444__F93475                                 ; F9345C  [  6]
PtrTable_F93444__F93460:
	nop                                                  ; F93460  00
PtrTable_F93444__F93461:
	nop                                                  ; F93461  00
	pop SR                                               ; F93462  03
PtrTable_F93444__F93463:
	nop                                                  ; F93463  00
	nop                                                  ; F93464  00
	push SR                                              ; F93465  02
PtrTable_F93444__F93466:
	nop                                                  ; F93466  00
	nop                                                  ; F93467  00
	push SR                                              ; F93468  02
	push SR                                              ; F93469  02
PtrTable_F93444__F9346A:
	nop                                                  ; F9346A  00
	nop                                                  ; F9346B  00
	nop                                                  ; F9346C  00
	normal                                               ; F9346D  01
	normal                                               ; F9346E  01
PtrTable_F93444__F9346F:
	nop                                                  ; F9346F  00
	nop                                                  ; F93470  00
	nop                                                  ; F93471  00
	normal                                               ; F93472  01
	normal                                               ; F93473  01
	normal                                               ; F93474  01
PtrTable_F93444__F93475:
	nop                                                  ; F93475  00
	nop                                                  ; F93476  00
	nop                                                  ; F93477  00
	nop                                                  ; F93478  00
	nop                                                  ; F93479  00
	nop                                                  ; F9347A  00
	nop                                                  ; F9347B  00
; ---------------------------------------------------------------------
; LCD_ClearLayer0_Rows29To235 -- zero the full width of layer 0 from row 29 to row 235
;
; Called from: prom_a SoundGroup_SelectedMaxMemberIndex (`calr`) at 0xF9302B, 0xF93037, 0xF93043, 0xF9304F
;          prom_a CombiGroup_MaxMemberIndexOfCurrent (`calr`) at 0xF93BDA, 0xF93BE6, 0xF93BF2, 0xF93BFE
; Issues:  SWI7 service 0x0E at 0xF9348C -- LCD_Svc_0E_ClearColumns, zero BC columns x HL bytes at IY in the current layer
; Evidence: `ld (0x2540),0x00`, `ld IY,0x0488`, `ld BC,0x0028`, `ld HL,0x00CF`, service
;           0x0E.  Service 0x0E takes IY as a byte offset inside the current layer, BC
;           as columns and HL as bytes down each column.  AP is 40 = 0x28, so BC = 40
;           is the full 320-pixel width and 0x0488 = 1160 = 29 x 40 EXACTLY -- the
;           offset is the start of row 29.  0xCF = 207 rows, so the last row cleared is
;           235.  ★ Service 0x0E's header also says `Unknown: callers`.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
LCD_ClearLayer0_Rows29To235:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9347C  f1 40 25 00 00
	ldw iy, 0x0488                                       ; F93481  35 88 04
	ldw bc, 0x28                                         ; F93484  31 28 00
	ldw hl, 0xcf                                         ; F93487  33 cf 00
	ld a, 0x0e:opc                                          ; F9348A  21 0e
	swi 7                                                ; F9348C  ff
	ret                                                  ; F9348D  0e
; ---------------------------------------------------------------------
; LCD_EraseLayer1_FixedRect -- erase one compile-time rectangle of layer 1
;
; Called from: prom_a GroupSoundDisplayHold_HighlightSelected (`calr`) at 0xF93398
;          prom_a GroupCombiDisplayHold_HighlightSelected (`calr`) at 0xF93E28
; Issues:  SWI7 service 0x1B at 0xF934AD -- LCD_Svc_1B_EraseRect, erase the rectangle in (0x2530..0x2536)
; Evidence: `ld (0x2540),0x01` then the four coordinate words written as immediates --
;           (0x2530)=0x000D, (0x2532)=0x0022, (0x2534)=0x0132, (0x2536)=0x00A7 -- and
;           service 0x1B, which erases the rectangle those four words hold.  So the
;           rectangle is x 13..306, y 34..167 and nothing about it comes from the
;           caller.  ★ Service 0x1B's header says `Unknown: callers`.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
LCD_EraseLayer1_FixedRect:
	ld (LCD_CurrentLayer:16), 0x01                                 ; F9348E  f1 40 25 00 01
	ldw (LCD_X0:16), 0x0d                                ; F93493  f1 30 25 02 0d 00
	ldw (LCD_Y0:16), 0x22                                ; F93499  f1 32 25 02 22 00
	ldw (LCD_X1:16), 0x0132                              ; F9349F  f1 34 25 02 32 01
	ldw (LCD_Y1:16), 0xa7                                ; F934A5  f1 36 25 02 a7 00
	ld a, 0x1b:opc                                          ; F934AB  21 1b
	swi 7                                                ; F934AD  ff
	ret                                                  ; F934AE  0e
; GroupSoundDisplayHold_DrawMemberNames -- draw the 16-character sound names of members DE..WA of the shown group into their layer-0 slots
; Evidence: XIZ = DLPtrTable_F2B510[A folded to 0..7] (prom_b screen-position word arrays); per member IX = position (sub_F92F16), (0x60F01C) = (0x2250),
; T_SoundSel_ClampToProgramAndBankRegs, then T_SoundName_Lookup = SoundName_Lookup (its not-found fallback is the ROM string "Sound Name *****") with B = (0x2250), and SWI7 0x06 with BC = 0x10.
; In: A = max member index, L = group, DE = first member, WA = last member. Callers: sub_F92D70, sub_F92E36, sub_F92E76. Twin: GroupCombiDisplayHold_DrawMemberNames.
GroupSoundDisplayHold_DrawMemberNames:
	pushw wa                                             ; F934AF  28
	pushw hl                                             ; F934B0  2b
	ld (LCD_CurrentLayer:16), 0x00                                 ; F934B1  f1 40 25 00 00
	cp a, 0x07:i3                                          ; F934B6  c9 df
	jr z, .LF934C4                                       ; F934B8  66 0a
.LF934BA:
	cp A,0x08                                            ; F934BA  c9 cf 08
	jr c, .LF934C4                                       ; F934BD  67 05
	sub A,0x08                                           ; F934BF  c9 ca 08
	jr .LF934BA                                          ; F934C2  68 f6
.LF934C4:
	xor H,H                                              ; F934C4  ce d6
	ld L,A                                               ; F934C6  c9 8f
	sla hl, 0x02                                         ; F934C8  db ec 02
	ld XIZ,DLPtrTable_F2B510                             ; F934CB  46 10 b5 f2 00
	ld	xiz, (xiz+hl)                                ; F934D0  e3 07 f8 ec 26
	popw hl                                              ; F934D5  4b
	popw wa                                              ; F934D6  48
	pushw wa                                             ; F934D7  28
	pushw bc                                             ; F934D8  29
	ld c, 0x03:opc                                          ; F934D9  23 03
	ld a, 0x0c:opc                                          ; F934DB  21 0c
	swi 7                                                ; F934DD  ff
	popw bc                                              ; F934DE  49
	popw wa                                              ; F934DF  48
.LF934E0:
	ld H,E                                               ; F934E0  cd 8e
	push XIZ                                             ; F934E2  3e
	pushw hl                                             ; F934E3  2b
	pushw de                                             ; F934E4  2a
	pushw wa                                             ; F934E5  28
	pushw de                                             ; F934E6  2a
	cp wa, 0x07:i3                                         ; F934E7  d8 df
	jr z, .LF934F7                                       ; F934E9  66 0c
.LF934EB:
	cp DE,0x0008                                         ; F934EB  da cf 08 00
	jr c, .LF934F7                                       ; F934EF  67 06
	sub DE,0x0008                                        ; F934F1  da ca 08 00
	jr .LF934EB                                          ; F934F5  68 f4
.LF934F7:
	calr PosTable_GetEntryIX                                          ; F934F7  1e 1c fa
	popw de                                              ; F934FA  4a
	ld a, (UI_PartIndex:16)                                   ; F934FB  c1 50 22 21
	ld (0x60f01c:24), a                                 ; F934FF  f2 1c f0 60 41
	ld w, (SoundSel_Bank:16)                                   ; F93504  c1 6a 21 20
	call T_SoundSel_ClampToProgramAndBankRegs                                        ; F93508  1d 8c 07 f4
	ld W,H                                               ; F9350C  ce 88
	ld A,L                                               ; F9350E  cf 89
	ld b, (UI_PartIndex:16)                                   ; F93510  c1 50 22 22
	call T_SoundName_Lookup                                        ; F93514  1d 10 10 f4
	ldw bc, 0x10                                         ; F93518  31 10 00
	xor HL,HL                                            ; F9351B  db d3
	ld a, 0x06:opc                                          ; F9351D  21 06
	swi 7                                                ; F9351F  ff
	popw wa                                              ; F93520  48
	popw de                                              ; F93521  4a
	popw hl                                              ; F93522  4b
	pop XIZ                                              ; F93523  5e
	cp DE,WA                                             ; F93524  d8 f2
	jr nc, .LF9352C                                      ; F93526  6f 04
	inc 1,DE                                             ; F93528  da 61
	jr .LF934E0                                          ; F9352A  68 b4
.LF9352C:
	ret                                                  ; F9352C  0e
; GroupDisplayHold_ClearNameSlots -- clear the eight 16-column member-name slots of a group display-hold screen on layer 0
; Evidence: (0x2540) = 0 and interpreter A over 0xF2BDF5-0xF2BE35 (site 0xF9353C).  That list has no .ascii (why it stayed sub_XXXXXX) but its eight records are
; op 0E, which is SWI7 service 0x0E (LCD_Svc_0E_ClearColumns: IY offset, BC columns, HL rows; FINDINGS-ui-display-list.md handler 0xF31A9F), each BC = 0x10, HL = 0x0E
; at 0x05A3/0x0BBB/0x11D3/0x17EB (left) and 0x05B5/0x0BCD/0x11E5/0x17FD (right).  Callers: sub_F92D70 (0xF92D79, GroupSoundDisplayHold) and
; GroupCombiDisplayHold_PaintGroupAndNames (0xF9394B) -- the two screens that then draw member names into those slots.
GroupDisplayHold_ClearNameSlots:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9352D  f1 40 25 00 00
	ld XIY,GroupDisplayHold_ClearNameSlots_DL                                     ; F93532  45 f5 bd f2 00
	ld XIX,MsgPad_F2BE35                                 ; F93537  44 35 be f2 00
	call T_DisplayList_Run                               ; F9353C  1d f0 17 f4
	ret                                                  ; F93540  0e
; ---------------------------------------------------------------------
; InstallPainter_CombinationGroupMenu_Entry -- a PURE WRAPPER for InstallPainter_CombinationGroupMenu: it IS that
; routine, so it is named for it.  Its whole extent is
; one `calr` and the `ret` that follows it, and the routine
; ends at 0xF93545, where the next top-level label begins.
; Evidence: the `calr` at 0xF93541 targets 0xF935D7, which carries the
;          label InstallPainter_CombinationGroupMenu.  The extent is measured to the next top-level
;          label, never to a source line -- notes/wave7-verify-probes/
;          wave7_r5_prom_a_painter_scope.py records what scoping to a
;          source line cost the round-5 pass.
; ---------------------------------------------------------------------

InstallPainter_CombinationGroupMenu_Entry:
	calr InstallPainter_CombinationGroupMenu                                            ; F93541  1e 93 00
	ret                                                  ; F93544  0e
; ---------------------------------------------------------------------
; ScreenLeave_CombinationGroupMenu -- the LEAVE method of the screen object
;          at PanelScreen_VtableTable entry 0xC5, i.e. SCREEN ID 0xA5 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0xC5 -> the screen object at
;          0xF41570, whose +4 slot is `jp 0xF93545`, and from no other live
;          screen object's two callable slots.
; Evidence: the +4 offset is PanelScreen_VtableTable's own (its header's
;          checks V1-V6): +0 ENTER is called by PanelScreen_CallEnter_A/B, +4
;          LEAVE by PanelScreen_CallLeave_A/B with the id that just STOPPED
;          being current, +8 BUTTON by PanelButton_Route (0xF8621E).
; Screen:   CombinationGroupMenu -- inherited from the +0 ENTER label
;          InstallPainter_CombinationGroupMenu_Entry, not from any text this
;          pass read.
; Was `sub_F93545`.
; ---------------------------------------------------------------------
ScreenLeave_CombinationGroupMenu:
	calr ScreenLeave_CombinationGroupMenu_Nop                                          ; F93545  1e bf 01
	ret                                                  ; F93548  0e
; ---------------------------------------------------------------------
; ScreenButton_CombinationGroupMenu -- the BUTTON method of the screen object
;          at PanelScreen_VtableTable entry 0xC5, i.e. SCREEN ID 0xA5 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0xC5 -> the screen object at
;          0xF41570, whose +8 slot is `jp 0xF93549`, and from no other live
;          screen object's two callable slots.
; Evidence: the +8 offset is PanelScreen_VtableTable's own (its header's
;          checks V1-V6): +0 ENTER is called by PanelScreen_CallEnter_A/B, +4
;          LEAVE by PanelScreen_CallLeave_A/B with the id that just STOPPED
;          being current, +8 BUTTON by PanelButton_Route (0xF8621E).
; Screen:   CombinationGroupMenu -- inherited from the +0 ENTER label
;          InstallPainter_CombinationGroupMenu_Entry, not from any text this
;          pass read.
; Was `sub_F93549`.
; ---------------------------------------------------------------------
ScreenButton_CombinationGroupMenu:
	ld XIX,ScreenButtonHandlers_CombinationGroupMenu                        ; F93549  44 57 35 f9 00
	call T_PanelButton_CallTableEntry                                        ; F9354E  1d 08 1b f4
	ret                                                  ; F93552  0e
sub_F93553:
	calr sub_F93822                                          ; F93553  1e cc 02
	ret                                                  ; F93556  0e
; ---------------------------------------------------------------------
; ScreenButtonHandlers_CombinationGroupMenu -- 32 LE32 pointers, same shape as ScreenButtonHandlers_GroupSoundDisplayHold
;
; Read by: 0xF93549 `ld XIX,0x00F93557 / call T_PanelButton_CallTableEntry`.
; ENTRY COUNT 32 from T_PanelButton_CallTableEntry's own `cp HL,0x001F`.  ★ base + 128 = 0xF935D7,
;          where the word is 0x013EC6C0 -- not pointer-shaped.
; Selector: the panel BUTTON CODE.  ScreenButton_CombinationGroupMenu (0xF93549) is the +8
;          BUTTON method of PanelScreen_VtableTable entry 0xC5 (prom_b
;          slot 0xF41578); PanelButton_Route calls it with the code in HL
;          and at (XIZ+8), and it indexes this table with it:
;          `ld XIX,<this> / call T_PanelButton_CallTableEntry`, and T_PanelButton_CallTableEntry = 0xF8BDC5 calls
;          (this + 4*L) after `cp HL,0x001F`.
;          Dispatch_FF3D39's CONTROL LEGEND names each code.
;          (notes/proma-2026-09-25/gen_button_selectors.py, B1-B3)
; ★ 2026-09-25 (lane proma): the selector was recorded as open here.
; Evidence: as ScreenButtonHandlers_GroupSoundDisplayHold.
; ---------------------------------------------------------------------
ScreenButtonHandlers_CombinationGroupMenu:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	SoftKeyCol1_CombinationGroupMenu
	on_key	KEY_SoftKeyCol2,	ScreenButtonHandlers_CombinationGroupMenu_Nop1
	on_key	KEY_SoftKeyCol3,	ScreenButtonHandlers_CombinationGroupMenu_Nop2
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_CombinationGroupMenu
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_CombinationGroupMenu
	on_key	KEY_SoftKeyCol6,	SoftKeyCol6_CombinationGroupMenu
	on_key	KEY_SoftKeyCol7,	ScreenButtonHandlers_CombinationGroupMenu_Nop6
	on_key	KEY_SoftKeyCol8,	ScreenButtonHandlers_CombinationGroupMenu_Nop7
	on_key	KEY_LcdRow1,		LcdKeyRow1_CombinationGroupMenu
	on_key	KEY_LcdRow2,		LcdKeyRow2_CombinationGroupMenu
	on_key	KEY_LcdRow3,		LcdKeyRow3_CombinationGroupMenu
	on_key	KEY_LcdRow4,		ScreenButtonHandlers_CombinationGroupMenu_Nop11
	on_key	KEY_LcdRow5,		ScreenButtonHandlers_CombinationGroupMenu_Nop12
	on_key	KEY_MinusPlus,		ScreenButtonHandlers_CombinationGroupMenu_Nop13
	on_key	KEY_Code0E,		ScreenButtonHandlers_CombinationGroupMenu_Nop14
	on_key	KEY_Exit,		ExitKey_CombinationGroupMenu
	on_key	KEY_Page,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_SoftKeyCol1Alt,	SoftKeyCol1_CombinationGroupMenu
	on_key	KEY_SoftKeyCol2Alt,	ScreenButtonHandlers_CombinationGroupMenu_Nop1
	on_key	KEY_SoftKeyCol3Alt,	ScreenButtonHandlers_CombinationGroupMenu_Nop2
	on_key	KEY_SoftKeyCol4Alt,	SoftKeyCol4_CombinationGroupMenu
	on_key	KEY_SoftKeyCol5Alt,	SoftKeyCol5_CombinationGroupMenu
	on_key	KEY_SoftKeyCol6Alt,	SoftKeyCol6_CombinationGroupMenu
	on_key	KEY_SoftKeyCol7Alt,	ScreenButtonHandlers_CombinationGroupMenu_Nop6
	on_key	KEY_SoftKeyCol8Alt,	ScreenButtonHandlers_CombinationGroupMenu_Nop7
	on_key	KEY_PageAlt,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Code1A,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_NumberPad,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Code1C,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Code1D,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Compare,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Code1F,		DisplayListPtrs_F914FB_Nop8
	keymap_end
; InstallPainter_CombinationGroupMenu -- paints the screen whose own text reads "COMBINATION GROUP MENU", "1.", "9."
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 2 time(s); XIY = list start, XIX = list end.  1 of those 2 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xF93659  interpreter A  list 0xF2ADD2  DL_CombinationGroupMenuReMap1
;        text: "COMBINATION GROUP MENU"; "1."; "9."; "2."; "10."; "3."
; Evidence: the list address is the `ld XIY,0x00F2ADD2` IMMEDIATE at the
;          instruction two before the cited `call`, and the text quoted
;          above is the `.ascii` the interpreter draws verbatim.  Every
;          alphabetic morpheme of this name occurs in that text; the
;          check is notes/prom_a_understanding_round5.py --morphemes.
;          `Paint_` is a structural verb, not ROM text.
;          ⚠ ROUND 5: where the label reads `InstallPainter_`, the body contains
;          ZERO display-list calls -- it INSTALLS the callback that paints this
;          screen, through `call 0xF42E84`. The screen association is real one hop
;          away; the earlier `Paint_` verb claimed the body did the drawing and it
;          does not. Any display-list COUNT in a header above such a label is the
;          installed callback's, not this routine's.
; Unknown: whether this routine also handles input for the screen, and
;          whether any other routine paints it.  Neither was searched.
; ---------------------------------------------------------------------
InstallPainter_CombinationGroupMenu:
	or	(0xc6:8), 0x01                               ; F935D7  c0 c6 3e 01
	ld a, (UI_ScreenId:16)                                   ; F935DB  c1 7c 20 21
	cp (UI_ScreenId_Previous:16), a                                    ; F935DF  c1 7d 20 f9
	jr z, .LF93602                                       ; F935E3  66 1d
	and	(UI_ScreenFlags:16), 0xef                            ; F935E5  c1 95 20 3c ef
	ld XWA,0xffffffff                                    ; F935EA  40 ff ff ff ff
	ld (0x2666:16), xwa                                 ; F935EF  f1 66 26 60
	ld (0x266a:16), xwa                                 ; F935F3  f1 6a 26 60
	ldw (PanelDial_DownButton:16), 0x0484                              ; F935F7  f1 9b 20 02 84 04
	or	(UI_RequestBits:16), 0x01                            ; F935FD  c1 75 20 3e 01
.LF93602:
	bit	4, (UI_ScreenFlags:16)                               ; F93602  f1 95 20 cc
	jr nz, .LF9361E                                      ; F93606  6e 16
	call T_CallbackQueue_ResetAndRestartTask2            ; F93608  1d 80 2e f4
	ld XWA,Draw_CombinationGroupMenuReMap1                                    ; F9360C  40 31 36 f9 00
	push XWA                                             ; F93611  38
	call T_CallbackQueue_Post                            ; F93612  1d 84 2e f4
	inc 4,XSP                                            ; F93616  ef 64
	ld a, 0x01:opc                                          ; F93618  21 01
	call T_Kernel_SemaSignal                             ; F9361A  1d 88 2d f4
.LF9361E:
	ld XWA,CombinationGroupMenu_MoveHighlight                                    ; F9361E  40 da 36 f9 00
	push XWA                                             ; F93623  38
	call T_CallbackQueue_Post                            ; F93624  1d 84 2e f4
	inc 4,XSP                                            ; F93628  ef 64
	ld a, 0x01:opc                                          ; F9362A  21 01
	call T_Kernel_SemaSignal                             ; F9362C  1d 88 2d f4
	ret                                                  ; F93630  0e
Draw_CombinationGroupMenuReMap1:   ; entry: named by 1 `ld` operand, first at 0xF9360C
	ld a, 0x0f:opc                                          ; F93631  21 0f
	swi 7                                                ; F93633  ff
	xor C,C                                              ; F93634  cb d3
	ld a, 0x0c:opc                                          ; F93636  21 0c
	swi 7                                                ; F93638  ff
	ld (LCD_CurrentLayer:16), 0x00                                 ; F93639  f1 40 25 00 00
	ld XIY,Draw_CombinationGroupMenuReMap1_DL                                     ; F9363E  45 50 ac f2 00
	ld XIX,DL_CombinationGroupMenuReMap1                 ; F93643  44 d2 ad f2 00
	calr SoundBank_IsReMap                                          ; F93648  1e 3c fb
	cp a, 0x01:i3                                          ; F9364B  c9 d9
	jr nz, .LF93659                                      ; F9364D  6e 0a
	ld XIY,DL_CombinationGroupMenuReMap1                 ; F9364F  45 d2 ad f2 00
	ld XIX,Draw_SoundGroupMenuReMap1ReMap2_DL                                     ; F93654  44 81 af f2 00
.LF93659:
	call T_DisplayList_Run                               ; F93659  1d f0 17 f4
	ld (LCD_CurrentLayer:16), 0x01                                 ; F9365D  f1 40 25 00 01
	ld XIY,0x00f2b2e3                                    ; F93662  45 e3 b2 f2 00
	ld XIX,DLTable_F2B2F9                                ; F93667  44 f9 b2 f2 00
	calr SoundBank_IsReMap                                          ; F9366C  1e 18 fb
	cp a, 0x01:i3                                          ; F9366F  c9 d9
	jr nz, .LF9367D                                      ; F93671  6e 0a
	ld XIY,DL_F2B379                                     ; F93673  45 79 b3 f2 00
	ld XIX,Data_F2B38F                                   ; F93678  44 8f b3 f2 00
.LF9367D:
	call T_DisplayListB_Run                              ; F9367D  1d f4 17 f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; F93681  f1 40 25 00 00
	ld e, 0x10:opc                                          ; F93686  25 10
	cp	(SoundSel_Bank:16), 0x10                            ; F93688  c1 6a 21 3f 10
	jr nz, .LF93693                                      ; F9368D  6e 04
	ld e, (0x08ea:16)                                   ; F9368F  c1 ea 08 25
.LF93693:
	xor D,D                                              ; F93693  cc d4
.LF93695:
	ld A,D                                               ; F93695  cc 89
	ld b, 0x98:opc                                          ; F93697  22 98
	ld w, (SoundSel_Bank:16)                                   ; F93699  c1 6a 21 20
	push E                                               ; F9369D  cd 04
	push D                                               ; F9369F  cc 04
	call T_CombiGroupName_Lookup                                        ; F936A1  1d 30 10 f4
	pop D                                                ; F936A5  cc 05
	push D                                               ; F936A7  cc 04
	ld XIZ,0x00f2b40f                                    ; F936A9  46 0f b4 f2 00
	sla d, 0x01                                          ; F936AE  cc ec 01
	ld	ix, (xiz+d)                                  ; F936B1  d3 03 f8 e9 24
	ldw hl, 0x00                                         ; F936B6  33 00 00
	ldw bc, 0x10                                         ; F936B9  31 10 00
	ld a, 0x06:opc                                          ; F936BC  21 06
	swi 7                                                ; F936BE  ff
	pop D                                                ; F936BF  cc 05
	inc 1,D                                              ; F936C1  cc 61
	pop E                                                ; F936C3  cd 05
	djnz8 e, .LF93695                                    ; F936C5  cd 1c cd
	bit	3, (SoundSel_Bank:16)                               ; F936C8  f1 6a 21 cb
	jr nz, .LF936D3                                      ; F936CC  6e 05
	calr Draw_Ext1_2                                          ; F936CE  1e 3f f3
	jr .LF936D6                                          ; F936D1  68 03
.LF936D3:
	calr BankLegend_EraseRow                                          ; F936D3  1e 6a f3
.LF936D6:
	calr BankLegend_DrawUser                                          ; F936D6  1e 46 f2
	ret                                                  ; F936D9  0e
; CombinationGroupMenu_MoveHighlight -- move the group cursor box on layer 1 from the last-drawn group to (0x2169)
; Evidence: queued by InstallPainter_CombinationGroupMenu at 0xF9361E.  (0x2640) = (0x2675), (0x2675) = (0x2169); T_F41820 on prom_b record 0xF2B42F
; (interpreter-B op 03, source (0x2640), SWI7 0x1B EraseRect of DLTable_F2B445[]) then T_F4181C on 0xF2B43A (source (0x2169), SWI7 0x05 FillRect);
; DLTable_F2B445 is 16 boxes, two columns of 8, matching the "1.".."16." layout; ends with SWI7 0x0C C = 7.
CombinationGroupMenu_MoveHighlight:   ; entry: named by 1 `ld` operand, first at 0xF9361E
	ld a, (SoundGroupMenu_Highlight:16)                                   ; F936DA  c1 75 26 21
	ld (UI_DrawScratch:16), a                                   ; F936DE  f1 40 26 41
	ld a, (SoundSel_Group:16)                                   ; F936E2  c1 69 21 21
	ld (SoundGroupMenu_Highlight:16), a                                   ; F936E6  f1 75 26 41
	ld (LCD_CurrentLayer:16), 0x01                                 ; F936EA  f1 40 25 00 01
	ld XIY,0x00f2b42f                                    ; F936EF  45 2f b4 f2 00
	call T_DLB_Handler_Array8_2                                        ; F936F4  1d 20 18 f4
	ld XIY,0x00f2b43a                                    ; F936F8  45 3a b4 f2 00
	call T_DLB_Handler_Array8                                        ; F936FD  1d 1c 18 f4
	ld c, 0x07:opc                                          ; F93701  23 07
	ld a, 0x0c:opc                                          ; F93703  21 0c
	swi 7                                                ; F93705  ff
	ret                                                  ; F93706  0e
ScreenLeave_CombinationGroupMenu_Nop:
	ret                                                  ; F93707  0e
; SoftKeyCol1_CombinationGroupMenu -- SOFT KEY column 1 on this screen: switch the group bank (0x216A) to 0x00 and post a BANK event
; Evidence: ScreenButtonHandlers_CombinationGroupMenu [0x00] and [0x11]; Dispatch_FF3D39's CONTROL LEGEND gives code 0x00 = SOFT KEY column 1, and
;          [c+0x11] is the same column's code re-pressed while already held (PanelButton_InterlockMask32 header; notes/proma-2026-09-25/gen_held_sets.py S1-S4).
; Body: unless (0x216A) bit 3 is set or it is already 0: (0x216A) = 0, T_Queue2E00_AppendRegs {0xA8, 0x07 (BANK), 0x00, 0x3F}, (0x2075) &= 0xF7, then a
; redraw request ((0x2071) |= 0x10 on screen 0xA5, else (0x2095) |= 0x10).  Also `calr` from SoftKeyCol1_GroupCombiDisplayHold.
SoftKeyCol1_CombinationGroupMenu:
	ld a, (SoundSel_Bank:16)                                   ; F93708  c1 6a 21 21
	bit 0x03,A                                           ; F9370C  c9 33 03
	jr nz, .LF9373F                                      ; F9370F  6e 2e
	ld a, 0x00:opc                                          ; F93711  21 00
	cp (SoundSel_Bank:16), a                                    ; F93713  c1 6a 21 f9
	jr z, .LF9373F                                       ; F93717  66 26
	ld (SoundSel_Bank:16), a                                   ; F93719  f1 6a 21 41
	ld e, 0xa8:opc                                          ; F9371D  25 a8
	ld d, 0x07:opc                                          ; F9371F  24 07
	ld w, 0x3f:opc                                          ; F93721  20 3f
	call T_Queue2E00_AppendRegs                          ; F93723  1d 3c 0f f4
	and	(UI_RequestBits:16), 0xf7                            ; F93727  c1 75 20 3c f7
	cp	(UI_ScreenId:16), 0xa5                            ; F9372C  c1 7c 20 3f a5
	jr z, .LF9373A                                       ; F93731  66 07
	or	(UI_ScreenFlags:16), 0x10                            ; F93733  c1 95 20 3e 10
	jr .LF9373F                                          ; F93738  68 05
.LF9373A:
	or	(UI_Request_Hi:16), 0x10                            ; F9373A  c1 71 20 3e 10
.LF9373F:
	ret                                                  ; F9373F  0e
ScreenButtonHandlers_CombinationGroupMenu_Nop1:   ; entry: named by 2 `.long` operands, first at 0xF9355B
	ret                                                  ; F93740  0e
ScreenButtonHandlers_CombinationGroupMenu_Nop2:   ; entry: named by 2 `.long` operands, first at 0xF9355F
	ret                                                  ; F93741  0e
; SoftKeyCol4_CombinationGroupMenu -- SOFT KEY column 4 on this screen: switch the group bank (0x216A) to 0x10, only while (0x08EC) bit 1 is set
; Evidence: ScreenButtonHandlers_CombinationGroupMenu [0x03] and [0x14]; Dispatch_FF3D39's CONTROL LEGEND gives code 0x03 = SOFT KEY column 4, and
;          [c+0x11] is the same column's code re-pressed while already held (PanelButton_InterlockMask32 header; notes/proma-2026-09-25/gen_held_sets.py S1-S4).
; Body: SoftKeyCol1's with 0x10 and an extra `bit 1,(0x08EC)` gate; CombiGroupName_Lookup (the group-name fetch) answers banks 0x10-0x17 with the ROM string
; "EXT Silent Group" when that same bit is clear.  Also `calr` from SoftKeyCol4_GroupCombiDisplayHold.
SoftKeyCol4_CombinationGroupMenu:
	ld a, (SoundSel_Bank:16)                                   ; F93742  c1 6a 21 21
	bit 0x03,A                                           ; F93746  c9 33 03
	jr nz, .LF9377F                                      ; F93749  6e 34
	bit	1, (0x08ec:16)                               ; F9374B  f1 ec 08 c9
	jr z, .LF9377F                                       ; F9374F  66 2e
	ld a, 0x10:opc                                          ; F93751  21 10
	cp (SoundSel_Bank:16), a                                    ; F93753  c1 6a 21 f9
	jr z, .LF9377F                                       ; F93757  66 26
	ld (SoundSel_Bank:16), a                                   ; F93759  f1 6a 21 41
	ld e, 0xa8:opc                                          ; F9375D  25 a8
	ld d, 0x07:opc                                          ; F9375F  24 07
	ld w, 0x3f:opc                                          ; F93761  20 3f
	call T_Queue2E00_AppendRegs                          ; F93763  1d 3c 0f f4
	and	(UI_RequestBits:16), 0xf7                            ; F93767  c1 75 20 3c f7
	cp	(UI_ScreenId:16), 0xa5                            ; F9376C  c1 7c 20 3f a5
	jr z, .LF9377A                                       ; F93771  66 07
	or	(UI_ScreenFlags:16), 0x10                            ; F93773  c1 95 20 3e 10
	jr .LF9377F                                          ; F93778  68 05
.LF9377A:
	or	(UI_Request_Hi:16), 0x10                            ; F9377A  c1 71 20 3e 10
.LF9377F:
	ret                                                  ; F9377F  0e
; SoftKeyCol5_CombinationGroupMenu -- SOFT KEY column 5 on this screen: step the selected group (0x2169) down (lower key) or up (upper key) and post it
; Evidence: ScreenButtonHandlers_CombinationGroupMenu [0x04] and [0x15]; Dispatch_FF3D39's CONTROL LEGEND gives code 0x04 = SOFT KEY column 5, and
;          [c+0x11] is the same column's code re-pressed while already held (PanelButton_InterlockMask32 header; notes/proma-2026-09-25/gen_held_sets.py S1-S4).
; Body: `xor W,0x80` then bit 7 of W (set = lower key, SoftKeyCol1_DrawbarScreen header) picks dec/inc within 0..15, or 0..(0x08EA)-1 when (0x216A) == 0x10;
; on a change (0x2075) |= 8, (0x2169) = A, T_Queue2E00_AppendRegs {0xA8, 0x08, A, 0x0F}.  InstallPainter_CombinationGroupMenu stores 0x0484 at (0x209B) and
; sets (0x2075) bit 0, so PanelEvent_Code21_Dial routes the dial here as code 0x04/0x84.  Also `calr` from SoftKeyCol5_GroupCombiDisplayHold.
SoftKeyCol5_CombinationGroupMenu:
	xor W,0x80                                           ; F93780  c8 cd 80
	ld a, (SoundSel_Bank:16)                                   ; F93783  c1 6a 21 21
	cp A,0x10                                            ; F93787  c9 cf 10
	jr z, .LF9378E                                       ; F9378A  66 02
	jr .LF937AD                                          ; F9378C  68 1f
.LF9378E:
	ld a, (SoundSel_Group:16)                                   ; F9378E  c1 69 21 21
	ld b, (0x08ea:16)                                   ; F93792  c1 ea 08 22
	dec 1,B                                              ; F93796  ca 69
	bit 0x07,W                                           ; F93798  c8 33 07
	jr nz, .LF937A5                                      ; F9379B  6e 08
	cp a, 0x00:i3                                          ; F9379D  c9 d8
	jr z, .LF937DA                                       ; F9379F  66 39
	dec 1,A                                              ; F937A1  c9 69
	jr .LF937C7                                          ; F937A3  68 22
.LF937A5:
	inc 1,A                                              ; F937A5  c9 61
	cp A,B                                               ; F937A7  ca f1
	jr ule, .LF937C7                                     ; F937A9  63 1c
	jr .LF937DA                                          ; F937AB  68 2d
.LF937AD:
	ld a, (SoundSel_Group:16)                                   ; F937AD  c1 69 21 21
	bit 0x07,W                                           ; F937B1  c8 33 07
	jr nz, .LF937BE                                      ; F937B4  6e 08
	cp a, 0x00:i3                                          ; F937B6  c9 d8
	jr z, .LF937DA                                       ; F937B8  66 20
	dec 1,A                                              ; F937BA  c9 69
	jr .LF937C7                                          ; F937BC  68 09
.LF937BE:
	inc 1,A                                              ; F937BE  c9 61
	cp A,0x0f                                            ; F937C0  c9 cf 0f
	jr ule, .LF937C7                                     ; F937C3  63 02
	jr .LF937DA                                          ; F937C5  68 13
.LF937C7:
	or	(UI_RequestBits:16), 0x08                            ; F937C7  c1 75 20 3e 08
	ld (SoundSel_Group:16), a                                   ; F937CC  f1 69 21 41
	ld e, 0xa8:opc                                          ; F937D0  25 a8
	ld d, 0x08:opc                                          ; F937D2  24 08
	ld w, 0x0f:opc                                          ; F937D4  20 0f
	call T_Queue2E00_AppendRegs                          ; F937D6  1d 3c 0f f4
.LF937DA:
	ret                                                  ; F937DA  0e
; SoftKeyCol6_CombinationGroupMenu -- SOFT KEY column 6 on this screen: request screen 0xA6 (GroupCombiDisplayHold)
; Evidence: ScreenButtonHandlers_CombinationGroupMenu [0x05] and [0x16]; Dispatch_FF3D39's CONTROL LEGEND gives code 0x05 = SOFT KEY column 6, and
;          [c+0x11] is the same column's code re-pressed while already held (PanelButton_InterlockMask32 header; notes/proma-2026-09-25/gen_held_sets.py S1-S4).
; Body: `ld (0x2070),0x80A6` = screen id 0xA6 + request flags 0x80; if (0x2092) bit 0: (0x2071) = 0x40, (0x2075) |= 0x80.  The list's "OK" legend
; sits at position 0x236B = x 216, inside column 6's band (x 200-239).
SoftKeyCol6_CombinationGroupMenu:   ; entry: named by 2 `.long` operands, first at 0xF9356B
	ldw (UI_Request:16), 0x80a6                              ; F937DB  f1 70 20 02 a6 80
	bit	0, (UI_ScreenHoldState:16)                               ; F937E1  f1 92 20 c8
	jr z, .LF937F1                                       ; F937E5  66 0a
	ld (UI_Request_Hi:16), 0x40                                 ; F937E7  f1 71 20 00 40
	or	(UI_RequestBits:16), 0x80                            ; F937EC  c1 75 20 3e 80
.LF937F1:
	ret                                                  ; F937F1  0e
ScreenButtonHandlers_CombinationGroupMenu_Nop6:   ; entry: named by 2 `.long` operands, first at 0xF9356F
	ret                                                  ; F937F2  0e
ScreenButtonHandlers_CombinationGroupMenu_Nop7:   ; entry: named by 2 `.long` operands, first at 0xF93573
	ret                                                  ; F937F3  0e
; LcdKeyRow1_CombinationGroupMenu -- LCD row 1 key pair on this screen: no lasting effect -- `calr CombiGroup_MaxMemberIndexOfCurrent / ret`, the result is discarded
; Evidence: ScreenButtonHandlers_CombinationGroupMenu [0x08] only; Dispatch_FF3D39's CONTROL LEGEND gives code 0x08 = the LCD-row-1 key pair (W bit 7 set = the left-hand key).
LcdKeyRow1_CombinationGroupMenu:
	calr CombiGroup_MaxMemberIndexOfCurrent                                          ; F937F4  1e 3c 03
	ret                                                  ; F937F7  0e
; LcdKeyRow2_CombinationGroupMenu -- LCD row 2 key pair on this screen: no lasting effect -- `calr CombiGroup_MaxMemberIndexOfCurrent / ret`, the result is discarded
; Evidence: ScreenButtonHandlers_CombinationGroupMenu [0x09] only; Dispatch_FF3D39's CONTROL LEGEND gives code 0x09 = the LCD-row-2 key pair (W bit 7 set = the left-hand key).
LcdKeyRow2_CombinationGroupMenu:   ; entry: named by 1 `.long` operand, first at 0xF9357B
	calr CombiGroup_MaxMemberIndexOfCurrent                                          ; F937F8  1e 38 03
	ret                                                  ; F937FB  0e
; LcdKeyRow3_CombinationGroupMenu -- LCD row 3 key pair on this screen: no lasting effect -- `calr CombiGroup_MaxMemberIndexOfCurrent / ret`, the result is discarded
; Evidence: ScreenButtonHandlers_CombinationGroupMenu [0x0A] only; Dispatch_FF3D39's CONTROL LEGEND gives code 0x0A = the LCD-row-3 key pair (W bit 7 set = the left-hand key).
LcdKeyRow3_CombinationGroupMenu:   ; entry: named by 1 `.long` operand, first at 0xF9357F
	calr CombiGroup_MaxMemberIndexOfCurrent                                          ; F937FC  1e 34 03
	ret                                                  ; F937FF  0e
ScreenButtonHandlers_CombinationGroupMenu_Nop11:   ; entry: named by 1 `.long` operand, first at 0xF93583
	ret                                                  ; F93800  0e
ScreenButtonHandlers_CombinationGroupMenu_Nop12:   ; entry: named by 1 `.long` operand, first at 0xF93587
	ret                                                  ; F93801  0e
ScreenButtonHandlers_CombinationGroupMenu_Nop13:   ; entry: named by 1 `.long` operand, first at 0xF9358B
	ret                                                  ; F93802  0e
ScreenButtonHandlers_CombinationGroupMenu_Nop14:   ; entry: named by 1 `.long` operand, first at 0xF9358F
	ret                                                  ; F93803  0e
; ExitKey_CombinationGroupMenu -- EXIT on the COMBINATION GROUP MENU: request screen 0x02
; Evidence: ScreenButtonHandlers_CombinationGroupMenu [0x0F] only; Dispatch_FF3D39's CONTROL LEGEND gives code 0x0F = EXIT.
; Body: acts only when W bit 7 is clear (code 0x0F exists only at pair position 1, where bit 7 is clear -- FINDINGS-prom_a-panel-control-map.md 1):
; (0x2070) = 0x8002, i.e. request screen 0x02; if (0x2092) bit 0: (0x209A) = 1 (PanelState_TakePendingHoldTime preloads the auto-return timer) and (0x2071) = 0.
ExitKey_CombinationGroupMenu:   ; entry: named by 1 `.long` operand, first at 0xF93593
	bit 0x07,W                                           ; F93804  c8 33 07
	jr nz, .LF93821                                      ; F93807  6e 18
	ldw (UI_Request:16), 0x8002                              ; F93809  f1 70 20 02 02 80
	bit	0, (UI_ScreenHoldState:16)                               ; F9380F  f1 92 20 c8
	jr z, .LF9381F                                       ; F93813  66 0a
	ld (UI_ScreenHoldPending:16), 0x01                                 ; F93815  f1 9a 20 00 01
	ld (UI_Request_Hi:16), 0x00                                 ; F9381A  f1 71 20 00 00
.LF9381F:
	jr .LF93821                                          ; F9381F  68 00
.LF93821:
	ret                                                  ; F93821  0e
sub_F93822:
	ret                                                  ; F93822  0e
; ---------------------------------------------------------------------
; InstallPainter_GroupCombiDisplayHold_Entry -- a PURE WRAPPER for InstallPainter_GroupCombiDisplayHold: it IS that
; routine, so it is named for it.  Its whole extent is
; one `calr` and the `ret` that follows it, and the routine
; ends at 0xF93827, where the next top-level label begins.
; Evidence: the `calr` at 0xF93823 targets 0xF938B9, which carries the
;          label InstallPainter_GroupCombiDisplayHold.  The extent is measured to the next top-level
;          label, never to a source line -- notes/wave7-verify-probes/
;          wave7_r5_prom_a_painter_scope.py records what scoping to a
;          source line cost the round-5 pass.
; ---------------------------------------------------------------------

InstallPainter_GroupCombiDisplayHold_Entry:
	calr InstallPainter_GroupCombiDisplayHold                                            ; F93823  1e 93 00
	ret                                                  ; F93826  0e
; ---------------------------------------------------------------------
; ScreenLeave_GroupCombiDisplayHold -- the LEAVE method of the screen object
;          at PanelScreen_VtableTable entry 0xC6, i.e. SCREEN ID 0xA6 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0xC6 -> the screen object at
;          0xF41580, whose +4 slot is `jp 0xF93827`, and from no other live
;          screen object's two callable slots.
; Evidence: the +4 offset is PanelScreen_VtableTable's own (its header's
;          checks V1-V6): +0 ENTER is called by PanelScreen_CallEnter_A/B, +4
;          LEAVE by PanelScreen_CallLeave_A/B with the id that just STOPPED
;          being current, +8 BUTTON by PanelButton_Route (0xF8621E).
; Screen:   GroupCombiDisplayHold -- inherited from the +0 ENTER label
;          InstallPainter_GroupCombiDisplayHold_Entry, not from any text this
;          pass read.
; Was `sub_F93827`.
; ---------------------------------------------------------------------
ScreenLeave_GroupCombiDisplayHold:
	calr ScreenLeave_GroupCombiDisplayHold_Nop                                          ; F93827  1e b3 02
	ret                                                  ; F9382A  0e
; ---------------------------------------------------------------------
; ScreenButton_GroupCombiDisplayHold -- the BUTTON method of the screen
;          object at PanelScreen_VtableTable entry 0xC6, i.e. SCREEN ID 0xA6
;          through PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0xC6 -> the screen object at
;          0xF41580, whose +8 slot is `jp 0xF9382B`, and from no other live
;          screen object's two callable slots.
; Evidence: the +8 offset is PanelScreen_VtableTable's own (its header's
;          checks V1-V6): +0 ENTER is called by PanelScreen_CallEnter_A/B, +4
;          LEAVE by PanelScreen_CallLeave_A/B with the id that just STOPPED
;          being current, +8 BUTTON by PanelButton_Route (0xF8621E).
; Screen:   GroupCombiDisplayHold -- inherited from the +0 ENTER label
;          InstallPainter_GroupCombiDisplayHold_Entry, not from any text this
;          pass read.
; Was `sub_F9382B`.
; ---------------------------------------------------------------------
ScreenButton_GroupCombiDisplayHold:
	ld XIX,ScreenButtonHandlers_GroupCombiDisplayHold                        ; F9382B  44 39 38 f9 00
	call T_PanelButton_CallTableEntry                                        ; F93830  1d 08 1b f4
	ret                                                  ; F93834  0e
sub_F93835:
	calr sub_F93CB8                                          ; F93835  1e 80 04
	ret                                                  ; F93838  0e
; ---------------------------------------------------------------------
; ScreenButtonHandlers_GroupCombiDisplayHold -- 32 LE32 pointers, same shape
;
; Read by: 0xF9382B `ld XIX,0x00F93839 / call T_PanelButton_CallTableEntry`.
; ENTRY COUNT 32 from T_PanelButton_CallTableEntry's own `cp HL,0x001F`.  ★ base + 128 = 0xF938B9,
;          where the word is 0xCE2673F1 -- not pointer-shaped.
; Selector: the panel BUTTON CODE.  ScreenButton_GroupCombiDisplayHold (0xF9382B) is the +8
;          BUTTON method of PanelScreen_VtableTable entry 0xC6 (prom_b
;          slot 0xF41588); PanelButton_Route calls it with the code in HL
;          and at (XIZ+8), and it indexes this table with it:
;          `ld XIX,<this> / call T_PanelButton_CallTableEntry`, and T_PanelButton_CallTableEntry = 0xF8BDC5 calls
;          (this + 4*L) after `cp HL,0x001F`.
;          Dispatch_FF3D39's CONTROL LEGEND names each code.
;          (notes/proma-2026-09-25/gen_button_selectors.py, B1-B3)
; ★ 2026-09-25 (lane proma): the selector was recorded as open here.
; Evidence: as ScreenButtonHandlers_GroupSoundDisplayHold.
; ---------------------------------------------------------------------
ScreenButtonHandlers_GroupCombiDisplayHold:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	SoftKeyCol1_GroupCombiDisplayHold
	on_key	KEY_SoftKeyCol2,	ScreenButtonHandlers_GroupCombiDisplayHold_Nop1
	on_key	KEY_SoftKeyCol3,	ScreenButtonHandlers_GroupCombiDisplayHold_Nop2
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_GroupCombiDisplayHold
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_GroupCombiDisplayHold
	on_key	KEY_SoftKeyCol6,	SoftKeyCol6_GroupCombiDisplayHold
	on_key	KEY_SoftKeyCol7,	SoftKeyCol7_GroupCombiDisplayHold
	on_key	KEY_SoftKeyCol8,	SoftKeyCol8_GroupCombiDisplayHold
	on_key	KEY_LcdRow1,		LcdKeyRow1_GroupCombiDisplayHold
	on_key	KEY_LcdRow2,		LcdKeyRow2_GroupCombiDisplayHold
	on_key	KEY_LcdRow3,		LcdKeyRow3_GroupCombiDisplayHold
	on_key	KEY_LcdRow4,		LcdKeyRow4_GroupCombiDisplayHold
	on_key	KEY_LcdRow5,		.LF93B75
	on_key	KEY_MinusPlus,		ScreenButtonHandlers_GroupCombiDisplayHold_Nop13
	on_key	KEY_Code0E,		ScreenButtonHandlers_GroupCombiDisplayHold_Nop14
	on_key	KEY_Exit,		ExitKey_GroupCombiDisplayHold
	on_key	KEY_Page,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_SoftKeyCol1Alt,	SoftKeyCol1_GroupCombiDisplayHold
	on_key	KEY_SoftKeyCol2Alt,	ScreenButtonHandlers_GroupCombiDisplayHold_Nop1
	on_key	KEY_SoftKeyCol3Alt,	ScreenButtonHandlers_GroupCombiDisplayHold_Nop2
	on_key	KEY_SoftKeyCol4Alt,	SoftKeyCol4_GroupCombiDisplayHold
	on_key	KEY_SoftKeyCol5Alt,	SoftKeyCol5_GroupCombiDisplayHold
	on_key	KEY_SoftKeyCol6Alt,	SoftKeyCol6_GroupCombiDisplayHold
	on_key	KEY_SoftKeyCol7Alt,	SoftKeyCol7_GroupCombiDisplayHold
	on_key	KEY_SoftKeyCol8Alt,	SoftKeyCol8_GroupCombiDisplayHold
	on_key	KEY_PageAlt,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Code1A,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_NumberPad,		NumberPadKey_GroupCombiDisplayHold
	on_key	KEY_Code1C,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Code1D,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Compare,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Code1F,		DisplayListPtrs_F914FB_Nop8
	keymap_end
; InstallPainter_GroupCombiDisplayHold -- paints the screen whose own text reads "GROUP:", "COMBI.", "DISPLAY"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 1 time(s); XIY = list start, XIX = list end.  1 of those 1 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xF93938  interpreter A  list 0xF2B736  DL_GroupCombiDisplayHoldGr0up
;        text: "GROUP:"; "COMBI."; "DISPLAY"; "HOLD"; "GR0UP"; "MENU"
; Evidence: the list address is the `ld XIY,0x00F2B736` IMMEDIATE at the
;          instruction two before the cited `call`, and the text quoted
;          above is the `.ascii` the interpreter draws verbatim.  Every
;          alphabetic morpheme of this name occurs in that text; the
;          check is notes/prom_a_understanding_round5.py --morphemes.
;          `Paint_` is a structural verb, not ROM text.
;          ⚠ ROUND 5: where the label reads `InstallPainter_`, the body contains
;          ZERO display-list calls -- it INSTALLS the callback that paints this
;          screen, through `call 0xF42E84`. The screen association is real one hop
;          away; the earlier `Paint_` verb claimed the body did the drawing and it
;          does not. Any display-list COUNT in a header above such a label is the
;          installed callback's, not this routine's.
; Unknown: whether this routine also handles input for the screen, and
;          whether any other routine paints it.  Neither was searched.
; ---------------------------------------------------------------------
InstallPainter_GroupCombiDisplayHold:
	bit	6, (0x2673:16)                               ; F938B9  f1 73 26 ce
	jr nz, .LF938C9                                      ; F938BD  6e 0a
	bit	7, (0x2673:16)                               ; F938BF  f1 73 26 cf
	jr nz, .LF938C9                                      ; F938C3  6e 04
	call T_CallbackQueue_ResetAndRestartTask2            ; F938C5  1d 80 2e f4
.LF938C9:
	and	(UI_RequestBits:16), 0xfe                            ; F938C9  c1 75 20 3c fe
	ld a, (UI_ScreenId:16)                                   ; F938CE  c1 7c 20 21
	cp (UI_ScreenId_Previous:16), a                                    ; F938D2  c1 7d 20 f9
	jr z, .LF938F1                                       ; F938D6  66 19
	and	(UI_ScreenFlags:16), 0xef                            ; F938D8  c1 95 20 3c ef
	or	(0x2673:16), 0x40                            ; F938DD  c1 73 26 3e 40
	cp	(Variant_Flag:8), 0x01                               ; F938E2  c0 c4 3f 01
	jr z, .LF938F1                                       ; F938E6  66 09
	call T_Blink_Stop                                    ; F938E8  1d 24 2e f4
	or	(UI_RequestBits:16), 0x02                            ; F938EC  c1 75 20 3e 02
.LF938F1:
	bit	4, (UI_ScreenFlags:16)                               ; F938F1  f1 95 20 cc
	jr nz, .LF9390E                                      ; F938F5  6e 17
	or	(0x2673:16), 0x80                            ; F938F7  c1 73 26 3e 80
	ld XIX,Draw_GroupCombiDisplayHoldGr0up                                    ; F938FC  44 21 39 f9 00
	push XIX                                             ; F93901  3c
	call T_CallbackQueue_Post                            ; F93902  1d 84 2e f4
	inc 4,XSP                                            ; F93906  ef 64
	ld a, 0x01:opc                                          ; F93908  21 01
	call T_Kernel_SemaSignal                             ; F9390A  1d 88 2d f4
.LF9390E:
	ld XIX,GroupCombiDisplayHold_PaintGroupAndNames                                    ; F9390E  44 42 39 f9 00
	push XIX                                             ; F93913  3c
	call T_CallbackQueue_Post                            ; F93914  1d 84 2e f4
	inc 4,XSP                                            ; F93918  ef 64
	ld a, 0x01:opc                                          ; F9391A  21 01
	call T_Kernel_SemaSignal                             ; F9391C  1d 88 2d f4
	ret                                                  ; F93920  0e
Draw_GroupCombiDisplayHoldGr0up:   ; entry: named by 1 `ld` operand, first at 0xF938FC
	ld a, 0x0f:opc                                          ; F93921  21 0f
	swi 7                                                ; F93923  ff
	xor C,C                                              ; F93924  cb d3
	ld a, 0x0c:opc                                          ; F93926  21 0c
	swi 7                                                ; F93928  ff
	ld (LCD_CurrentLayer:16), 0x00                                 ; F93929  f1 40 25 00 00
	ld XIY,DL_GroupCombiDisplayHoldGr0up                 ; F9392E  45 36 b7 f2 00
	ld XIX,0x00f2b8f9                                    ; F93933  44 f9 b8 f2 00
	call T_DisplayList_Run                               ; F93938  1d f0 17 f4
	and	(0x2673:16), 0x7f                            ; F9393C  c1 73 26 3c 7f
	ret                                                  ; F93941  0e
; GroupCombiDisplayHold_PaintGroupAndNames -- the second painter: group name and numbers, then the member names of the right page and the highlight
; Evidence: queued at 0xF9390E.  T_Blink_Stop, GroupDisplayHold_ClearNameSlots, B record 0xF2B8F9, T_CombiGroupName_Lookup (group-name fetch CombiGroupName_Lookup) + SWI7 0x06 of 16
; characters at IX 0x0129, sub_F931A4, sub_F93124, sub_F92A10/sub_F92A40 by (0x216A) bit 3, sub_F9291F, sub_F9315D (DISPLAY HOLD box).  Then (0x2672) = last
; page index from T_SoundGroup_MaxMemberIndex_GetToneCopy, and: max index <= 8 -> GroupCombiDisplayHold_DrawMemberNames + _HighlightSelected on page 0;
; 9..15 -> GroupCombiDisplayHold_ShowMemberPage_TwoPages; more -> _ManyPages; ends with (0x2673) &= 0xBF.
GroupCombiDisplayHold_PaintGroupAndNames:   ; entry: named by 1 `ld` operand, first at 0xF9390E
	call T_Blink_Stop                                    ; F93942  1d 24 2e f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; F93946  f1 40 25 00 00
	calr GroupDisplayHold_ClearNameSlots                                          ; F9394B  1e df fb
	ld XIY,0x00f2b8f9                                    ; F9394E  45 f9 b8 f2 00
	call T_DLB_Handler_StringTable                       ; F93953  1d f8 17 f4
	ld a, (SoundSel_Group:16)                                   ; F93957  c1 69 21 21
	ld b, 0x98:opc                                          ; F9395B  22 98
	ld w, (SoundSel_Bank:16)                                   ; F9395D  c1 6a 21 20
	call T_CombiGroupName_Lookup                                        ; F93961  1d 30 10 f4
	ldw ix, 0x0129                                       ; F93965  34 29 01
	ldw hl, 0x00                                         ; F93968  33 00 00
	ldw bc, 0x10                                         ; F9396B  31 10 00
	ld a, 0x06:opc                                          ; F9396E  21 06
	swi 7                                                ; F93970  ff
	calr GroupCombiDisplayHold_DrawNumberRange                                          ; F93971  1e 30 f8
	calr DisplayHold_ShowGroupNumber                                          ; F93974  1e ad f7
	bit	3, (SoundSel_Bank:16)                               ; F93977  f1 6a 21 cb
	jr nz, .LF93982                                      ; F9397B  6e 05
	calr Draw_Ext1_2                                          ; F9397D  1e 90 f0
	jr .LF93985                                          ; F93980  68 03
.LF93982:
	calr BankLegend_EraseRow                                          ; F93982  1e bb f0
.LF93985:
	calr BankLegend_DrawUser                                          ; F93985  1e 97 ef
	calr DisplayHold_DrawHoldHighlight                                          ; F93988  1e d2 f7
	ld a, (SoundSel_Group:16)                                   ; F9398B  c1 69 21 21
	ld w, (SoundSel_Bank:16)                                   ; F9398F  c1 6a 21 20
	ld b, 0x98:opc                                          ; F93993  22 98
	call T_SoundGroup_MaxMemberIndex_GetToneCopy         ; F93995  1d 34 10 f4
	ld L,A                                               ; F93999  c9 8f
	cp a, 0x07:i3                                          ; F9399B  c9 df
	jr z, .LF939A1                                       ; F9399D  66 02
	inc 1,A                                              ; F9399F  c9 61
.LF939A1:
	xor W,W                                              ; F939A1  c8 d0
	ld c, 0x08:opc                                          ; F939A3  23 08
	div wa, c                                          ; F939A5  cb 51
	cp w, 0x00:i3                                          ; F939A7  c8 d8
	jr z, .LF939AD                                       ; F939A9  66 02
	inc 1,A                                              ; F939AB  c9 61
.LF939AD:
	dec 1,A                                              ; F939AD  c9 69
	ld (0x2672:16), a                                   ; F939AF  f1 72 26 41
	ld A,L                                               ; F939B3  cf 89
	xor W,W                                              ; F939B5  c8 d0
	cp WA,0x0008                                         ; F939B7  d8 cf 08 00
	jr ugt, .LF939DC                                     ; F939BB  6b 1f
	ld (GroupMembers_Page:16), 0x00                                 ; F939BD  f1 70 26 00 00
	calr PartRecord_GetPtr                                          ; F939C2  1e 74 0b
	ld l, (SoundSel_Group:16)                                   ; F939C5  c1 69 21 27
	and L,0xff                                           ; F939C9  cf cc ff
	ldw de, 0x00                                         ; F939CC  32 00 00
	calr GroupCombiDisplayHold_DrawMemberNames                                      ; F939CF  1e 02 05
	calr GroupCombiDisplayHold_HighlightSelected                                      ; F939D2  1e 53 04
	ld c, 0x03:opc                                          ; F939D5  23 03
	ld a, 0x0c:opc                                          ; F939D7  21 0c
	swi 7                                                ; F939D9  ff
	jr .LF939F6                                          ; F939DA  68 1a
.LF939DC:
	cp WA,0x000f                                         ; F939DC  d8 cf 0f 00
	jr ugt, .LF939ED                                     ; F939E0  6b 0b
	calr PartRecord_GetPtr                                          ; F939E2  1e 54 0b
	and L,0xff                                           ; F939E5  cf cc ff
	calr GroupCombiDisplayHold_ShowMemberPage_TwoPages                                      ; F939E8  1e 11 00
	jr .LF939F6                                          ; F939EB  68 09
.LF939ED:
	calr PartRecord_GetPtr                                          ; F939ED  1e 49 0b
	and L,0xff                                           ; F939F0  cf cc ff
	calr GroupCombiDisplayHold_ShowMemberPage_ManyPages                                      ; F939F3  1e 46 00
.LF939F6:
	and	(0x2673:16), 0xbf                            ; F939F6  c1 73 26 3c bf
	ret                                                  ; F939FB  0e
; GroupCombiDisplayHold_ShowMemberPage_TwoPages -- draw the page holding member L of a two-page group, then the highlight
; Evidence: L <= 7 -> (0x2670) = 0, members 0..7; else (0x2670) = 1, members 8..A -- both through GroupCombiDisplayHold_DrawMemberNames (DE/WA = first/last),
; then GroupCombiDisplayHold_HighlightSelected and SWI7 0x0C C = 3.  GroupCombiDisplayHold_PaintGroupAndNames picks it for max member index 9..15
; (`cp WA,0x0008 / cp WA,0x000F`).  In: A = max member index, L = member.
GroupCombiDisplayHold_ShowMemberPage_TwoPages:
	cp l, 0x07:i3                                          ; F939FC  cf df
	jr UGT,.LF93A1C                                      ; F939FE  6b 1c
	ld (GroupMembers_Page:16), 0x00                                 ; F93A00  f1 70 26 00 00
	calr PartRecord_GetPtr                                          ; F93A05  1e 31 0b
	ld l, (SoundSel_Group:16)                                   ; F93A08  c1 69 21 27
	and L,0xff                                           ; F93A0C  cf cc ff
	xor H,H                                              ; F93A0F  ce d6
	ldw de, 0x00                                         ; F93A11  32 00 00
	ldw wa, 0x07                                         ; F93A14  30 07 00
	calr GroupCombiDisplayHold_DrawMemberNames                                      ; F93A17  1e ba 04
	jr .LF93A33                                          ; F93A1A  68 17
.LF93A1C:
	ld (GroupMembers_Page:16), 0x01                                 ; F93A1C  f1 70 26 00 01
	calr PartRecord_GetPtr                                          ; F93A21  1e 15 0b
	ld l, (SoundSel_Group:16)                                   ; F93A24  c1 69 21 27
	and L,0xff                                           ; F93A28  cf cc ff
	xor H,H                                              ; F93A2B  ce d6
	ldw de, 0x08                                         ; F93A2D  32 08 00
	calr GroupCombiDisplayHold_DrawMemberNames                                      ; F93A30  1e a1 04
.LF93A33:
	calr GroupCombiDisplayHold_HighlightSelected                                      ; F93A33  1e f2 03
	ld c, 0x03:opc                                          ; F93A36  23 03
	ld a, 0x0c:opc                                          ; F93A38  21 0c
	swi 7                                                ; F93A3A  ff
	ret                                                  ; F93A3B  0e
; GroupCombiDisplayHold_ShowMemberPage_ManyPages -- draw the page holding member L of a group with more than two pages, then a highlight
; Evidence: (0x2670) = L/8; members page*8..page*8+7, or page*8..A on the last page ((0x2672)), through GroupCombiDisplayHold_DrawMemberNames;
; picked by GroupCombiDisplayHold_PaintGroupAndNames for max member index > 15.  In: A = max member index, L = member.
; ⚠ Its page-0 arm is `jrl 0xF92F0D`, the tail of the SOUND twin sub_F92E76, so that arm ends in GroupSoundDisplayHold_HighlightSelected, not
; GroupCombiDisplayHold_HighlightSelected -- recorded as the ROM has it.
GroupCombiDisplayHold_ShowMemberPage_ManyPages:
	cp l, 0x07:i3                                          ; F93A3C  cf df
	jr ugt, .LF93A5D                                     ; F93A3E  6b 1d
	ld (GroupMembers_Page:16), 0x00                                 ; F93A40  f1 70 26 00 00
	calr PartRecord_GetPtr                                          ; F93A45  1e f1 0a
	ld l, (SoundSel_Group:16)                                   ; F93A48  c1 69 21 27
	and L,0xff                                           ; F93A4C  cf cc ff
	xor H,H                                              ; F93A4F  ce d6
	ldw de, 0x00                                         ; F93A51  32 00 00
	ldw wa, 0x07                                         ; F93A54  30 07 00
	calr GroupCombiDisplayHold_DrawMemberNames                                      ; F93A57  1e 7a 04
	jrl .LF92F0D                                            ; F93A5A  78 b0 f4
.LF93A5D:
	pushw wa                                             ; F93A5D  28
	ld a, (0x2672:16)                                   ; F93A5E  c1 72 26 21
	dec 1,A                                              ; F93A62  c9 69
	xor W,W                                              ; F93A64  c8 d0
	ld c, 0x08:opc                                          ; F93A66  23 08
	mul wa, c                                          ; F93A68  cb 41
	add WA,0x0007                                        ; F93A6A  d8 c8 07 00
	ld DE,WA                                             ; F93A6E  d8 8a
	popw wa                                              ; F93A70  48
	cp L,E                                               ; F93A71  cd f7
	jr ugt, .LF93AA2                                     ; F93A73  6b 2d
	ld A,L                                               ; F93A75  cf 89
	xor W,W                                              ; F93A77  c8 d0
	ld l, 0x08:opc                                          ; F93A79  27 08
	div wa, l                                          ; F93A7B  cf 51
	ld (GroupMembers_Page:16), a                                   ; F93A7D  f1 70 26 41
	calr PartRecord_GetPtr                                          ; F93A81  1e b5 0a
	ld l, (SoundSel_Group:16)                                   ; F93A84  c1 69 21 27
	and L,0xff                                           ; F93A88  cf cc ff
	xor H,H                                              ; F93A8B  ce d6
	ld a, (GroupMembers_Page:16)                                   ; F93A8D  c1 70 26 21
	xor W,W                                              ; F93A91  c8 d0
	ld c, 0x08:opc                                          ; F93A93  23 08
	mul wa, c                                          ; F93A95  cb 41
	ld DE,WA                                             ; F93A97  d8 8a
	add WA,0x0007                                        ; F93A99  d8 c8 07 00
	calr GroupCombiDisplayHold_DrawMemberNames                                      ; F93A9D  1e 34 04
	jr .LF93AD4                                          ; F93AA0  68 32
.LF93AA2:
	pushw wa                                             ; F93AA2  28
	pushw de                                             ; F93AA3  2a
	ld A,L                                               ; F93AA4  cf 89
	xor W,W                                              ; F93AA6  c8 d0
	ld l, 0x08:opc                                          ; F93AA8  27 08
	div wa, l                                          ; F93AAA  cf 51
	ld (GroupMembers_Page:16), a                                   ; F93AAC  f1 70 26 41
	popw de                                              ; F93AB0  4a
	popw wa                                              ; F93AB1  48
	ld (LCD_CurrentLayer:16), 0x00                                 ; F93AB2  f1 40 25 00 00
	calr PartRecord_GetPtr                                          ; F93AB7  1e 7f 0a
	ld l, (SoundSel_Group:16)                                   ; F93ABA  c1 69 21 27
	and L,0xff                                           ; F93ABE  cf cc ff
	xor H,H                                              ; F93AC1  ce d6
	pushw wa                                             ; F93AC3  28
	ld a, (GroupMembers_Page:16)                                   ; F93AC4  c1 70 26 21
	xor W,W                                              ; F93AC8  c8 d0
	ld c, 0x08:opc                                          ; F93ACA  23 08
	mul wa, c                                          ; F93ACC  cb 41
	ld DE,WA                                             ; F93ACE  d8 8a
	popw wa                                              ; F93AD0  48
	calr GroupCombiDisplayHold_DrawMemberNames                                      ; F93AD1  1e 00 04
.LF93AD4:
	calr GroupCombiDisplayHold_HighlightSelected                                      ; F93AD4  1e 51 03
	ld c, 0x03:opc                                          ; F93AD7  23 03
	ld a, 0x0c:opc                                          ; F93AD9  21 0c
	swi 7                                                ; F93ADB  ff
	ret                                                  ; F93ADC  0e
ScreenLeave_GroupCombiDisplayHold_Nop:
	ret                                                  ; F93ADD  0e
; SoftKeyCol1_GroupCombiDisplayHold -- SOFT KEY column 1 on this screen: switch the group bank to 0x00 -- `calr SoftKeyCol1_CombinationGroupMenu / ret`
; Evidence: ScreenButtonHandlers_GroupCombiDisplayHold [0x00] and [0x11]; Dispatch_FF3D39's CONTROL LEGEND gives code 0x00 = SOFT KEY column 1, and
;          [c+0x11] is the same column's code re-pressed while already held (PanelButton_InterlockMask32 header; notes/proma-2026-09-25/gen_held_sets.py S1-S4).
SoftKeyCol1_GroupCombiDisplayHold:   ; entry: named by 2 `.long` operands, first at 0xF93839
	calr SoftKeyCol1_CombinationGroupMenu                                          ; F93ADE  1e 27 fc
	ret                                                  ; F93AE1  0e
ScreenButtonHandlers_GroupCombiDisplayHold_Nop1:   ; entry: named by 2 `.long` operands, first at 0xF9383D
	ret                                                  ; F93AE2  0e
ScreenButtonHandlers_GroupCombiDisplayHold_Nop2:   ; entry: named by 2 `.long` operands, first at 0xF93841
	ret                                                  ; F93AE3  0e
; SoftKeyCol4_GroupCombiDisplayHold -- SOFT KEY column 4 on this screen: switch the group bank to 0x10 -- `calr SoftKeyCol4_CombinationGroupMenu / ret`
; Evidence: ScreenButtonHandlers_GroupCombiDisplayHold [0x03] and [0x14]; Dispatch_FF3D39's CONTROL LEGEND gives code 0x03 = SOFT KEY column 4, and
;          [c+0x11] is the same column's code re-pressed while already held (PanelButton_InterlockMask32 header; notes/proma-2026-09-25/gen_held_sets.py S1-S4).
SoftKeyCol4_GroupCombiDisplayHold:   ; entry: named by 2 `.long` operands, first at 0xF93845
	calr SoftKeyCol4_CombinationGroupMenu                                          ; F93AE4  1e 5b fc
	ret                                                  ; F93AE7  0e
; SoftKeyCol5_GroupCombiDisplayHold -- SOFT KEY column 5 on this screen: step the shown group down/up -- `calr SoftKeyCol5_CombinationGroupMenu / ret`
; Evidence: ScreenButtonHandlers_GroupCombiDisplayHold [0x04] and [0x15]; Dispatch_FF3D39's CONTROL LEGEND gives code 0x04 = SOFT KEY column 5, and
;          [c+0x11] is the same column's code re-pressed while already held (PanelButton_InterlockMask32 header; notes/proma-2026-09-25/gen_held_sets.py S1-S4).
; The list draws glyphs 0x8D/0x8E at 0x2096/0x22C6 (x 176, rows 208/222), inside column 5's band, above and below each other.
SoftKeyCol5_GroupCombiDisplayHold:   ; entry: named by 2 `.long` operands, first at 0xF93849
	calr SoftKeyCol5_CombinationGroupMenu                                          ; F93AE8  1e 95 fc
	ret                                                  ; F93AEB  0e
; SoftKeyCol6_GroupCombiDisplayHold -- SOFT KEY column 6 on this screen: request screen 0xA5 (CombinationGroupMenu)
; Evidence: ScreenButtonHandlers_GroupCombiDisplayHold [0x05] and [0x16]; Dispatch_FF3D39's CONTROL LEGEND gives code 0x05 = SOFT KEY column 6, and
;          [c+0x11] is the same column's code re-pressed while already held (PanelButton_InterlockMask32 header; notes/proma-2026-09-25/gen_held_sets.py S1-S4).
; Body: `ld (0x2070),0x80A5`; if (0x2092) bit 0: (0x2071) = 0x40, (0x2075) |= 0x80.  The list's "GR0UP" / "MENU" legend sits at 0x1EDF / 0x227A,
; x 184-239, centred on column 6's band.
SoftKeyCol6_GroupCombiDisplayHold:   ; entry: named by 2 `.long` operands, first at 0xF9384D
	ldw (UI_Request:16), 0x80a5                              ; F93AEC  f1 70 20 02 a5 80
	bit	0, (UI_ScreenHoldState:16)                               ; F93AF2  f1 92 20 c8
	jr z, .LF93B02                                       ; F93AF6  66 0a
	ld (UI_Request_Hi:16), 0x40                                 ; F93AF8  f1 71 20 00 40
	or	(UI_RequestBits:16), 0x80                            ; F93AFD  c1 75 20 3e 80
.LF93B02:
	ret                                                  ; F93B02  0e
; SoftKeyCol7_GroupCombiDisplayHold -- SOFT KEY column 7 on this screen: toggle DISPLAY HOLD
; Evidence: ScreenButtonHandlers_GroupCombiDisplayHold [0x06] and [0x17]; Dispatch_FF3D39's CONTROL LEGEND gives code 0x06 = SOFT KEY column 7, and
;          [c+0x11] is the same column's code re-pressed while already held (PanelButton_InterlockMask32 header; notes/proma-2026-09-25/gen_held_sets.py S1-S4).
; Body: `xor (0x267F),0x01`, then queues sub_F9315D, which fills (DisplayHold_DrawHoldHighlight_DL1, op 05) or erases (DisplayHold_DrawHoldHighlight_DL2, op 1B) the box x 254-313, y 212-236 around the
; "DISPLAY" / "HOLD" legend (0x2190 / 0x2371).  (0x267F) bit 0 is what GroupCombiDisplayHold_SelectMemberAtRow tests before leaving the screen.
SoftKeyCol7_GroupCombiDisplayHold:   ; entry: named by 2 `.long` operands, first at 0xF93851
	xor	(DisplayHold_Flag:16), 0x01                            ; F93B03  c1 7f 26 3d 01
	ld XIX,DisplayHold_DrawHoldHighlight                                    ; F93B08  44 5d 31 f9 00
	push XIX                                             ; F93B0D  3c
	call T_CallbackQueue_Post                            ; F93B0E  1d 84 2e f4
	inc 4,XSP                                            ; F93B12  ef 64
	ld a, 0x01:opc                                          ; F93B14  21 01
	call T_Kernel_SemaSignal                             ; F93B16  1d 88 2d f4
	ret                                                  ; F93B1A  0e
; SoftKeyCol8_GroupCombiDisplayHold -- SOFT KEY column 8 on this screen: toggle DISPLAY HOLD (byte-identical to column 7's)
; Evidence: ScreenButtonHandlers_GroupCombiDisplayHold [0x07] and [0x18]; Dispatch_FF3D39's CONTROL LEGEND gives code 0x07 = SOFT KEY column 8, and
;          [c+0x11] is the same column's code re-pressed while already held (PanelButton_InterlockMask32 header; notes/proma-2026-09-25/gen_held_sets.py S1-S4).
; Body: `xor (0x267F),0x01`, then queues sub_F9315D, which fills (DisplayHold_DrawHoldHighlight_DL1, op 05) or erases (DisplayHold_DrawHoldHighlight_DL2, op 1B) the box x 254-313, y 212-236 around the
; "DISPLAY" / "HOLD" legend (0x2190 / 0x2371).  (0x267F) bit 0 is what GroupCombiDisplayHold_SelectMemberAtRow tests before leaving the screen.
SoftKeyCol8_GroupCombiDisplayHold:   ; entry: named by 2 `.long` operands, first at 0xF93855
	xor	(DisplayHold_Flag:16), 0x01                            ; F93B1B  c1 7f 26 3d 01
	ld XIX,DisplayHold_DrawHoldHighlight                                    ; F93B20  44 5d 31 f9 00
	push XIX                                             ; F93B25  3c
	call T_CallbackQueue_Post                            ; F93B26  1d 84 2e f4
	inc 4,XSP                                            ; F93B2A  ef 64
	ld a, 0x01:opc                                          ; F93B2C  21 01
	call T_Kernel_SemaSignal                             ; F93B2E  1d 88 2d f4
	ret                                                  ; F93B32  0e
; CombiGroup_MaxMemberIndexOfCurrent -- A := the max member index of the shown group (0x2169) in bank (0x216A)
; Evidence: C = L = A = (0x2169), B = 0x98, W = (0x216A), call T_SoundGroup_MaxMemberIndex_GetToneCopy (W preserved).  Every caller is a
; CombinationGroupMenu / GroupCombiDisplayHold routine (13 sites incl. sub_F931A4 and the four dead-stub callbacks); its sound twin sub_F92F7F makes the same call through
; T_SoundGroup_MaxMemberIndex_Get with B = (0x2250).  Out: A = max member index (0xFF = unused group slot), C = L = group.
CombiGroup_MaxMemberIndexOfCurrent:
	push W                                               ; F93B33  c8 04
	ld c, (SoundSel_Group:16)                                   ; F93B35  c1 69 21 23
	and C,0xff                                           ; F93B39  cb cc ff
	ld L,C                                               ; F93B3C  cb 8f
	ld A,L                                               ; F93B3E  cf 89
	ld b, 0x98:opc                                          ; F93B40  22 98
	ld w, (SoundSel_Bank:16)                                   ; F93B42  c1 6a 21 20
	call T_SoundGroup_MaxMemberIndex_GetToneCopy         ; F93B46  1d 34 10 f4
	pop W                                                ; F93B4A  c8 05
	ret                                                  ; F93B4C  0e
; LcdKeyRow1_GroupCombiDisplayHold -- LCD row 1 key pair on this screen: select member row 0 -- CombiGroup_MaxMemberIndexOfCurrent, HL = 0, GroupCombiDisplayHold_SelectMemberAtRow
; Evidence: ScreenButtonHandlers_GroupCombiDisplayHold [0x08] only; Dispatch_FF3D39's CONTROL LEGEND gives code 0x08 = the LCD-row-1 key pair (W bit 7 set = the left-hand key).
LcdKeyRow1_GroupCombiDisplayHold:   ; entry: named by 1 `.long` operand, first at 0xF93859
	calr CombiGroup_MaxMemberIndexOfCurrent                                      ; F93B4D  1e e3 ff
	ldw hl, 0x00                                         ; F93B50  33 00 00
	calr GroupCombiDisplayHold_SelectMemberAtRow                                      ; F93B53  1e 63 01
	ret                                                  ; F93B56  0e
; LcdKeyRow2_GroupCombiDisplayHold -- LCD row 2 key pair on this screen: select member row 1 -- CombiGroup_MaxMemberIndexOfCurrent, HL = 1, GroupCombiDisplayHold_SelectMemberAtRow
; Evidence: ScreenButtonHandlers_GroupCombiDisplayHold [0x09] only; Dispatch_FF3D39's CONTROL LEGEND gives code 0x09 = the LCD-row-2 key pair (W bit 7 set = the left-hand key).
LcdKeyRow2_GroupCombiDisplayHold:   ; entry: named by 1 `.long` operand, first at 0xF9385D
	calr CombiGroup_MaxMemberIndexOfCurrent                                      ; F93B57  1e d9 ff
	ldw hl, 0x01                                         ; F93B5A  33 01 00
	calr GroupCombiDisplayHold_SelectMemberAtRow                                      ; F93B5D  1e 59 01
	ret                                                  ; F93B60  0e
; LcdKeyRow3_GroupCombiDisplayHold -- LCD row 3 key pair on this screen: select member row 2 -- CombiGroup_MaxMemberIndexOfCurrent, HL = 2, GroupCombiDisplayHold_SelectMemberAtRow
; Evidence: ScreenButtonHandlers_GroupCombiDisplayHold [0x0A] only; Dispatch_FF3D39's CONTROL LEGEND gives code 0x0A = the LCD-row-3 key pair (W bit 7 set = the left-hand key).
LcdKeyRow3_GroupCombiDisplayHold:   ; entry: named by 1 `.long` operand, first at 0xF93861
	calr CombiGroup_MaxMemberIndexOfCurrent                                      ; F93B61  1e cf ff
	ldw hl, 0x02                                         ; F93B64  33 02 00
	calr GroupCombiDisplayHold_SelectMemberAtRow                                      ; F93B67  1e 4f 01
	ret                                                  ; F93B6A  0e
; LcdKeyRow4_GroupCombiDisplayHold -- LCD row 4 key pair on this screen: select member row 3 -- CombiGroup_MaxMemberIndexOfCurrent, HL = 3, GroupCombiDisplayHold_SelectMemberAtRow
; Evidence: ScreenButtonHandlers_GroupCombiDisplayHold [0x0B] only; Dispatch_FF3D39's CONTROL LEGEND gives code 0x0B = the LCD-row-4 key pair (W bit 7 set = the left-hand key).
; [0x0C] (LCD row 5) is .LF93B75, a `ret` inside this routine's extent.
LcdKeyRow4_GroupCombiDisplayHold:   ; entry: named by 1 `.long` operand, first at 0xF93865
	calr CombiGroup_MaxMemberIndexOfCurrent                                      ; F93B6B  1e c5 ff
	ldw hl, 0x03                                         ; F93B6E  33 03 00
	calr GroupCombiDisplayHold_SelectMemberAtRow                                      ; F93B71  1e 45 01
	ret                                                  ; F93B74  0e
.LF93B75:
	ret                                                  ; F93B75  0e
	ld XWA,GroupCombiDisplayHold_ShowFirstOfTwoPages                                    ; F93B76  40 da 3b f9 00
	push XWA                                             ; F93B7B  38
	call T_CallbackQueue_Post                            ; F93B7C  1d 84 2e f4
	inc 4,XSP                                            ; F93B80  ef 64
	ld a, 0x01:opc                                          ; F93B82  21 01
	call T_Kernel_SemaSignal                             ; F93B84  1d 88 2d f4
	jr .LF93B75                                          ; F93B88  68 eb
	ld XWA,GroupCombiDisplayHold_ShowSecondOfTwoPages                                    ; F93B8A  40 e6 3b f9 00
	push XWA                                             ; F93B8F  38
	call T_CallbackQueue_Post                            ; F93B90  1d 84 2e f4
	inc 4,XSP                                            ; F93B94  ef 64
	ld a, 0x01:opc                                          ; F93B96  21 01
	call T_Kernel_SemaSignal                             ; F93B98  1d 88 2d f4
	jr .LF93B75                                          ; F93B9C  68 d7
	ld XWA,GroupCombiDisplayHold_ShowFirstOfManyPages                                    ; F93B9E  40 f2 3b f9 00
	push XWA                                             ; F93BA3  38
	call T_CallbackQueue_Post                            ; F93BA4  1d 84 2e f4
	inc 4,XSP                                            ; F93BA8  ef 64
	ld a, 0x01:opc                                          ; F93BAA  21 01
	call T_Kernel_SemaSignal                             ; F93BAC  1d 88 2d f4
	jr .LF93B75                                          ; F93BB0  68 c3
	ld XWA,GroupCombiDisplayHold_ShowNextOfManyPages                                    ; F93BB2  40 fe 3b f9 00
	push XWA                                             ; F93BB7  38
	call T_CallbackQueue_Post                            ; F93BB8  1d 84 2e f4
	inc 4,XSP                                            ; F93BBC  ef 64
	ld a, 0x01:opc                                          ; F93BBE  21 01
	call T_Kernel_SemaSignal                             ; F93BC0  1d 88 2d f4
	jr .LF93B75                                          ; F93BC4  68 af
	ld XWA,GroupCombiDisplayHold_ShowNextOfManyPages                                    ; F93BC6  40 fe 3b f9 00
	push XWA                                             ; F93BCB  38
	call T_CallbackQueue_Post                            ; F93BCC  1d 84 2e f4
	inc 4,XSP                                            ; F93BD0  ef 64
	ld a, 0x01:opc                                          ; F93BD2  21 01
	call T_Kernel_SemaSignal                             ; F93BD4  1d 88 2d f4
	jr .LF93B75                                          ; F93BD8  68 9b
; GroupCombiDisplayHold_ShowFirstOfTwoPages: Clears rows 29-235 of layer 0 and shows page 1 (members 0-7) of a two-
;   page group on GROUP: COMBI. DISPLAY HOLD: LCD_ClearLayer0_Rows29To235, CombiGroup_MaxMemberIndexOfCurrent, L = 0,
;   GroupCombiDisplayHold_ShowMemberPage_TwoPages -- the COMBI twin of GroupMembers_ShowFirstOfTwoPages. UNREACHABLE:
;   only the post block at 0xF93B76 names it, and nothing names that block. Basis: twin + referrer + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave8_c8.json)
GroupCombiDisplayHold_ShowFirstOfTwoPages:   ; entry: named by 1 `ld` operand, first at 0xF93B76
	calr LCD_ClearLayer0_Rows29To235                                          ; F93BDA  1e 9f f8
	calr CombiGroup_MaxMemberIndexOfCurrent                                      ; F93BDD  1e 53 ff
	ld l, 0x00:opc                                          ; F93BE0  27 00
	calr GroupCombiDisplayHold_ShowMemberPage_TwoPages                                      ; F93BE2  1e 17 fe
	ret                                                  ; F93BE5  0e
; GroupCombiDisplayHold_ShowSecondOfTwoPages: Clears rows 29-235 of layer 0 and shows page 2 (members 8..max) of a
;   two-page group on GROUP: COMBI. DISPLAY HOLD: CombiGroup_MaxMemberIndexOfCurrent, L = 8,
;   GroupCombiDisplayHold_ShowMemberPage_TwoPages -- the COMBI twin of GroupMembers_ShowSecondOfTwoPages. UNREACHABLE:
;   only the dead post block at 0xF93B8A names it. Basis: twin + referrer + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_c8.json)
GroupCombiDisplayHold_ShowSecondOfTwoPages:   ; entry: named by 1 `ld` operand, first at 0xF93B8A
	calr LCD_ClearLayer0_Rows29To235                                          ; F93BE6  1e 93 f8
	calr CombiGroup_MaxMemberIndexOfCurrent                                      ; F93BE9  1e 47 ff
	ld l, 0x08:opc                                          ; F93BEC  27 08
	calr GroupCombiDisplayHold_ShowMemberPage_TwoPages                                      ; F93BEE  1e 0b fe
	ret                                                  ; F93BF1  0e
; GroupCombiDisplayHold_ShowFirstOfManyPages: Clears rows 29-235 of layer 0 and shows the first page of a many-page
;   group on GROUP: COMBI. DISPLAY HOLD: CombiGroup_MaxMemberIndexOfCurrent, L = 0,
;   GroupCombiDisplayHold_ShowMemberPage_ManyPages -- the COMBI twin of GroupMembers_ShowFirstOfManyPages.
;   UNREACHABLE: only the dead post block at 0xF93B9E names it. Basis: twin + referrer + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_c8.json)
GroupCombiDisplayHold_ShowFirstOfManyPages:   ; entry: named by 1 `ld` operand, first at 0xF93B9E
	calr LCD_ClearLayer0_Rows29To235                                          ; F93BF2  1e 87 f8
	calr CombiGroup_MaxMemberIndexOfCurrent                                      ; F93BF5  1e 3b ff
	ld l, 0x00:opc                                          ; F93BF8  27 00
	calr GroupCombiDisplayHold_ShowMemberPage_ManyPages                                      ; F93BFA  1e 3f fe
	ret                                                  ; F93BFD  0e
; GroupCombiDisplayHold_ShowNextOfManyPages: Clears rows 29-235 of layer 0 and shows the page after GroupMembers_Page
;   of a many-page group: L = (GroupMembers_Page+1)*8, A = CombiGroup_MaxMemberIndexOfCurrent -- the COMBI twin of
;   GroupMembers_ShowNextOfManyPages, but it calls the SOUND painter GroupMembers_ShowPageOfMany (sound names),
;   recorded as the ROM has it. UNREACHABLE: only the dead post blocks at 0xF93BB2/0xF93BC6 name it. Basis: twin +
;   referrer + body. (notes/naming-pilot-2026-10-06/proposals_wave8_c8.json)
GroupCombiDisplayHold_ShowNextOfManyPages:   ; entry: named by 2 `ld` operands, first at 0xF93BB2
	calr LCD_ClearLayer0_Rows29To235                                          ; F93BFE  1e 7b f8
	calr CombiGroup_MaxMemberIndexOfCurrent                                      ; F93C01  1e 2f ff
	pushw wa                                             ; F93C04  28
	ld a, (GroupMembers_Page:16)                                   ; F93C05  c1 70 26 21
	inc 1,A                                              ; F93C09  c9 61
	xor W,W                                              ; F93C0B  c8 d0
	ld l, 0x08:opc                                          ; F93C0D  27 08
	mul wa, l                                          ; F93C0F  cf 41
	ld L,A                                               ; F93C11  c9 8f
	popw wa                                              ; F93C13  48
	calr GroupMembers_ShowPageOfMany                                          ; F93C14  1e 5f f2
	ret                                                  ; F93C17  0e
ScreenButtonHandlers_GroupCombiDisplayHold_Nop13:   ; entry: named by 1 `.long` operand, first at 0xF9386D
	ret                                                  ; F93C18  0e
ScreenButtonHandlers_GroupCombiDisplayHold_Nop14:   ; entry: named by 1 `.long` operand, first at 0xF93871
	ret                                                  ; F93C19  0e
; ExitKey_GroupCombiDisplayHold -- EXIT on the group display-hold screen 0xA6: request screen 0x02
; Evidence: ScreenButtonHandlers_GroupCombiDisplayHold [0x0F] only; Dispatch_FF3D39's CONTROL LEGEND gives code 0x0F = EXIT.
; Body: acts only when W bit 7 is clear (code 0x0F exists only at pair position 1, where bit 7 is clear -- FINDINGS-prom_a-panel-control-map.md 1):
; (0x2070) = 0x8002, i.e. request screen 0x02; if (0x2092) bit 0: (0x209A) = 1 (PanelState_TakePendingHoldTime preloads the auto-return timer) and (0x2071) = 0.
; Same body as ExitKey_CombinationGroupMenu plus `and (0x2075),0x7F` in the (0x2092) arm.
ExitKey_GroupCombiDisplayHold:   ; entry: named by 1 `.long` operand, first at 0xF93875
	bit 0x07,W                                           ; F93C1A  c8 33 07
	jr nz, .LF93C3C                                      ; F93C1D  6e 1d
	ldw (UI_Request:16), 0x8002                              ; F93C1F  f1 70 20 02 02 80
	bit	0, (UI_ScreenHoldState:16)                               ; F93C25  f1 92 20 c8
	jr z, .LF93C3A                                       ; F93C29  66 0f
	ld (UI_ScreenHoldPending:16), 0x01                                 ; F93C2B  f1 9a 20 00 01
	ld (UI_Request_Hi:16), 0x00                                 ; F93C30  f1 71 20 00 00
	and	(UI_RequestBits:16), 0x7f                            ; F93C35  c1 75 20 3c 7f
.LF93C3A:
	jr .LF93C3C                                          ; F93C3A  68 00
.LF93C3C:
	ret                                                  ; F93C3C  0e
; NumberPadKey_GroupCombiDisplayHold -- number-pad entry of a group number on screen 0xA6
; Evidence: ScreenButtonHandlers_GroupCombiDisplayHold [0x1B] only; Dispatch_FF3D39's CONTROL LEGEND gives code 0x1B = the number pad, whole field.  (0x2823) == 0x20 -> T_Blink_Stop only.  Else when
; (0x2267) & 0x0F == 0x0F (ordinal 12's value in PanelKeypad_OrdinalToKey_V2): (0x2826) = 2, T_AsciiDigits3_ToValue -> A; bound 1 (banks 0x28/0x29), 2 (0x20),
; (0x08EA) (0x10) or 16; if 1 <= A <= bound: (0x2169) = A-1, T_Queue2E00_AppendRegs {0xA8, 0x08, A-1, 0x0F}, T_Blink_Stop.  Then queues sub_F93109, which
; copies (0x2822) to (0x2661) and blinks the record DL_F2BA64.
NumberPadKey_GroupCombiDisplayHold:   ; entry: named by 1 `.long` operand, first at 0xF938A5
	cp	(0x2823:16), 0x20                            ; F93C3D  c1 23 28 3f 20
	jr nz, .LF93C4A                                      ; F93C42  6e 06
	call T_Blink_Stop                                    ; F93C44  1d 24 2e f4
	jr .LF93CB7                                          ; F93C48  68 6d
.LF93C4A:
	ld a, (0x2267:16)                                   ; F93C4A  c1 67 22 21
	and A,0x0f                                           ; F93C4E  c9 cc 0f
	cp A,0x0f                                            ; F93C51  c9 cf 0f
	jr nz, .LF93CA5                                      ; F93C54  6e 4f
	ld (0x2826:16), 0x02                                 ; F93C56  f1 26 28 00 02
	call T_AsciiDigits3_ToValue                          ; F93C5B  1d f0 32 f4
	ld b, 0x10:opc                                          ; F93C5F  22 10
	ld d, (SoundSel_Bank:16)                                   ; F93C61  c1 6a 21 24
	cp D,0x28                                            ; F93C65  cc cf 28
	jr z, .LF93C7B                                       ; F93C68  66 11
	cp D,0x29                                            ; F93C6A  cc cf 29
	jr z, .LF93C7B                                       ; F93C6D  66 0c
	cp D,0x20                                            ; F93C6F  cc cf 20
	jr z, .LF93C7F                                       ; F93C72  66 0b
	cp D,0x10                                            ; F93C74  cc cf 10
	jr z, .LF93C83                                       ; F93C77  66 0a
	jr .LF93C87                                          ; F93C79  68 0c
.LF93C7B:
	ld b, 0x01:opc                                          ; F93C7B  22 01
	jr .LF93C87                                          ; F93C7D  68 08
.LF93C7F:
	ld b, 0x02:opc                                          ; F93C7F  22 02
	jr .LF93C87                                          ; F93C81  68 04
.LF93C83:
	ld b, (0x08ea:16)                                   ; F93C83  c1 ea 08 22
.LF93C87:
	ld c, 0x01:opc                                          ; F93C87  23 01
	cp A,C                                               ; F93C89  cb f1
	jr c, .LF93CA5                                       ; F93C8B  67 18
	cp A,B                                               ; F93C8D  ca f1
	jr ugt, .LF93CA5                                     ; F93C8F  6b 14
	dec 1,A                                              ; F93C91  c9 69
	ld (SoundSel_Group:16), a                                   ; F93C93  f1 69 21 41
	ld e, 0xa8:opc                                          ; F93C97  25 a8
	ld d, 0x08:opc                                          ; F93C99  24 08
	ld w, 0x0f:opc                                          ; F93C9B  20 0f
	call T_Queue2E00_AppendRegs                          ; F93C9D  1d 3c 0f f4
	call T_Blink_Stop                                    ; F93CA1  1d 24 2e f4
.LF93CA5:
	ld XWA,DisplayHold_ShowTypedGroupDigits                                    ; F93CA5  40 09 31 f9 00
	push XWA                                             ; F93CAA  38
	call T_CallbackQueue_Post                            ; F93CAB  1d 84 2e f4
	inc 4,XSP                                            ; F93CAF  ef 64
	ld a, 0x01:opc                                          ; F93CB1  21 01
	call T_Kernel_SemaSignal                             ; F93CB3  1d 88 2d f4
.LF93CB7:
	ret                                                  ; F93CB7  0e
sub_F93CB8:
	ret                                                  ; F93CB8  0e
; GroupCombiDisplayHold_SelectMemberAtRow -- select the member under an LCD-row key and, unless DISPLAY HOLD, leave the screen
; Evidence: callers LcdKeyRow1..4_GroupCombiDisplayHold with HL = 0..3.  On the last page ((0x2670) == (0x2672), A != 8) -> GroupCombiDisplayHold_SelectMemberLastPage;
; else L = (0x2670)*8 + HL (+4 when W bit 7 is clear, the right-hand key; DLTable_F2B4D0 boxes 0-3 left, 4-7 right); if L <= A: (0x216B) = L,
; {0x98,0x01,(0x216A),0x3F} and {0x98,0x01,(0x2169),L} via T_List2030_AppendRegs, (0x2673) |= 8, T_Blink_Stop, queue sub_F93124 and _HighlightSelected;
; unless (0x267F) bit 0 (DISPLAY HOLD) request screen 0x01 (from 0xA1) else 0x02, or the auto-return when (0x2092) bit 0.  In: A = max member index.
GroupCombiDisplayHold_SelectMemberAtRow:
	cp A,0x08                                            ; F93CB9  c9 cf 08
	jr z, .LF93CCE                                       ; F93CBC  66 10
	ld e, (GroupMembers_Page:16)                                   ; F93CBE  c1 70 26 25
	cp	e, (0x2672:16)                               ; F93CC2  c1 72 26 f5
	jr nz, .LF93CCE                                      ; F93CC6  6e 06
	calr GroupCombiDisplayHold_SelectMemberLastPage                                      ; F93CC8  1e a2 00
	jrl .LF93D6C                                         ; F93CCB  78 9e 00
.LF93CCE:
	pushw wa                                             ; F93CCE  28
	ld a, (GroupMembers_Page:16)                                   ; F93CCF  c1 70 26 21
	xor W,W                                              ; F93CD3  c8 d0
	ld e, 0x08:opc                                          ; F93CD5  25 08
	mul wa, e                                          ; F93CD7  cd 41
	add HL,WA                                            ; F93CD9  d8 83
	popw wa                                              ; F93CDB  48
	bit 0x07,W                                           ; F93CDC  c8 33 07
	jr nz, .LF93CE9                                      ; F93CDF  6e 08
	inc 1,L                                              ; F93CE1  cf 61
	inc 1,L                                              ; F93CE3  cf 61
	inc 1,L                                              ; F93CE5  cf 61
	inc 1,L                                              ; F93CE7  cf 61
.LF93CE9:
	cp A,L                                               ; F93CE9  cf f1
	jr c, .LF93D6C                                       ; F93CEB  67 7f
	ld (SoundSel_Member:16), l                                   ; F93CED  f1 6b 21 47
	ld e, 0x98:opc                                          ; F93CF1  25 98
	ld d, 0x01:opc                                          ; F93CF3  24 01
	ld a, (SoundSel_Bank:16)                                   ; F93CF5  c1 6a 21 21
	ld w, 0x3f:opc                                          ; F93CF9  20 3f
	call T_List2030_AppendRegs                           ; F93CFB  1d 40 0f f4
	ld e, 0x98:opc                                          ; F93CFF  25 98
	ld d, 0x01:opc                                          ; F93D01  24 01
	ld a, (SoundSel_Group:16)                                   ; F93D03  c1 69 21 21
	ld w, (SoundSel_Member:16)                                   ; F93D07  c1 6b 21 20
	call T_List2030_AppendRegs                           ; F93D0B  1d 40 0f f4
	or	(0x2673:16), 0x08                            ; F93D0F  c1 73 26 3e 08
	call T_Blink_Stop                                    ; F93D14  1d 24 2e f4
	ld XWA,DisplayHold_ShowGroupNumber                                    ; F93D18  40 24 31 f9 00
	push XWA                                             ; F93D1D  38
	call T_CallbackQueue_Post                            ; F93D1E  1d 84 2e f4
	inc 4,XSP                                            ; F93D22  ef 64
	ld a, 0x01:opc                                          ; F93D24  21 01
	call T_Kernel_SemaSignal                             ; F93D26  1d 88 2d f4
	ld XWA,GroupCombiDisplayHold_HighlightSelected                                    ; F93D2A  40 28 3e f9 00
	push XWA                                             ; F93D2F  38
	call T_CallbackQueue_Post                            ; F93D30  1d 84 2e f4
	inc 4,XSP                                            ; F93D34  ef 64
	ld a, 0x01:opc                                          ; F93D36  21 01
	call T_Kernel_SemaSignal                             ; F93D38  1d 88 2d f4
	bit	0, (DisplayHold_Flag:16)                               ; F93D3C  f1 7f 26 c8
	jr nz, .LF93D6C                                      ; F93D40  6e 2a
	cp	(UI_ScreenId:16), 0xa1                            ; F93D42  c1 7c 20 3f a1
	jr nz, .LF93D51                                      ; F93D47  6e 08
	ldw (UI_Request:16), 0x8001                              ; F93D49  f1 70 20 02 01 80
	jr .LF93D57                                          ; F93D4F  68 06
.LF93D51:
	ldw (UI_Request:16), 0x8002                              ; F93D51  f1 70 20 02 02 80
.LF93D57:
	bit	0, (UI_ScreenHoldState:16)                               ; F93D57  f1 92 20 c8
	jr z, .LF93D6C                                       ; F93D5B  66 0f
	ld (UI_ScreenHoldPending:16), 0x01                                 ; F93D5D  f1 9a 20 00 01
	ld (UI_Request_Hi:16), 0x00                                 ; F93D62  f1 71 20 00 00
	and	(UI_RequestBits:16), 0x7f                            ; F93D67  c1 75 20 3c 7f
.LF93D6C:
	ret                                                  ; F93D6C  0e
; GroupCombiDisplayHold_SelectMemberLastPage -- GroupCombiDisplayHold_SelectMemberAtRow's arm for the group's last page
; Evidence: only caller GroupCombiDisplayHold_SelectMemberAtRow (0xF93CC8).  BC = word table 0xF93386[A mod 8] (B = last usable row, C = right-column
; offset -- the last page's members split evenly over the two columns); L = row (+C when W bit 7 clear) + (0x2670)*8; the commit path is the caller's,
; instruction for instruction.  Twin: GroupSoundDisplayHold_SelectMemberLastPage.
GroupCombiDisplayHold_SelectMemberLastPage:
	pushw wa                                             ; F93D6D  28
	pushw hl                                             ; F93D6E  2b
	xor W,W                                              ; F93D6F  c8 d0
	ld e, 0x08:opc                                          ; F93D71  25 08
	div wa, e                                          ; F93D73  cd 51
	ld L,W                                               ; F93D75  c8 8f
	xor H,H                                              ; F93D77  ce d6
	sla hl, 0x01                                         ; F93D79  db ec 01
	push XIY                                             ; F93D7C  3d
	ld XIY,GroupSoundDisplayHold_SelectMemberLastPage__F93386                                    ; F93D7D  45 86 33 f9 00
	ld	bc, (xiy+hl)                                 ; F93D82  d3 07 f4 ec 21
	pop XIY                                              ; F93D87  5d
	popw hl                                              ; F93D88  4b
	popw wa                                              ; F93D89  48
	cp L,B                                               ; F93D8A  ca f7
	jrl ugt, .LF93E27                                    ; F93D8C  7b 98 00
	pushw wa                                             ; F93D8F  28
	xor W,W                                              ; F93D90  c8 d0
	ld a, (GroupMembers_Page:16)                                   ; F93D92  c1 70 26 21
	ld e, 0x08:opc                                          ; F93D96  25 08
	mul wa, e                                          ; F93D98  cd 41
	add HL,WA                                            ; F93D9A  d8 83
	popw wa                                              ; F93D9C  48
	bit 0x07,W                                           ; F93D9D  c8 33 07
	jr nz, .LF93DA4                                      ; F93DA0  6e 02
	add L,C                                              ; F93DA2  cb 87
.LF93DA4:
	cp A,L                                               ; F93DA4  cf f1
	jr c, .LF93E27                                       ; F93DA6  67 7f
	ld (SoundSel_Member:16), l                                   ; F93DA8  f1 6b 21 47
	ld e, 0x98:opc                                          ; F93DAC  25 98
	ld d, 0x01:opc                                          ; F93DAE  24 01
	ld a, (SoundSel_Bank:16)                                   ; F93DB0  c1 6a 21 21
	ld w, 0x3f:opc                                          ; F93DB4  20 3f
	call T_List2030_AppendRegs                           ; F93DB6  1d 40 0f f4
	ld e, 0x98:opc                                          ; F93DBA  25 98
	ld d, 0x01:opc                                          ; F93DBC  24 01
	ld a, (SoundSel_Group:16)                                   ; F93DBE  c1 69 21 21
	ld w, (SoundSel_Member:16)                                   ; F93DC2  c1 6b 21 20
	call T_List2030_AppendRegs                           ; F93DC6  1d 40 0f f4
	or	(0x2673:16), 0x08                            ; F93DCA  c1 73 26 3e 08
	call T_Blink_Stop                                    ; F93DCF  1d 24 2e f4
	ld XWA,DisplayHold_ShowGroupNumber                                    ; F93DD3  40 24 31 f9 00
	push XWA                                             ; F93DD8  38
	call T_CallbackQueue_Post                            ; F93DD9  1d 84 2e f4
	inc 4,XSP                                            ; F93DDD  ef 64
	ld a, 0x01:opc                                          ; F93DDF  21 01
	call T_Kernel_SemaSignal                             ; F93DE1  1d 88 2d f4
	ld XWA,GroupCombiDisplayHold_HighlightSelected                                    ; F93DE5  40 28 3e f9 00
	push XWA                                             ; F93DEA  38
	call T_CallbackQueue_Post                            ; F93DEB  1d 84 2e f4
	inc 4,XSP                                            ; F93DEF  ef 64
	ld a, 0x01:opc                                          ; F93DF1  21 01
	call T_Kernel_SemaSignal                             ; F93DF3  1d 88 2d f4
	bit	0, (DisplayHold_Flag:16)                               ; F93DF7  f1 7f 26 c8
	jr nz, .LF93E27                                      ; F93DFB  6e 2a
	cp	(UI_ScreenId:16), 0xa1                            ; F93DFD  c1 7c 20 3f a1
	jr nz, .LF93E0C                                      ; F93E02  6e 08
	ldw (UI_Request:16), 0x8001                              ; F93E04  f1 70 20 02 01 80
	jr .LF93E12                                          ; F93E0A  68 06
.LF93E0C:
	ldw (UI_Request:16), 0x8002                              ; F93E0C  f1 70 20 02 02 80
.LF93E12:
	bit	0, (UI_ScreenHoldState:16)                               ; F93E12  f1 92 20 c8
	jr z, .LF93E27                                       ; F93E16  66 0f
	ld (UI_ScreenHoldPending:16), 0x01                                 ; F93E18  f1 9a 20 00 01
	ld (UI_Request_Hi:16), 0x00                                 ; F93E1D  f1 71 20 00 00
	and	(UI_RequestBits:16), 0x7f                            ; F93E22  c1 75 20 3c 7f
.LF93E27:
	ret                                                  ; F93E27  0e
; GroupCombiDisplayHold_HighlightSelected -- erase layer 1's member-list area, then fill the box of the selected member if it is on the shown page
; Evidence: LCD_EraseLayer1_FixedRect, CombiGroup_MaxMemberIndexOfCurrent; unless (0x2673) bit 3, (0x7F08) must equal the shown group C and (0x7F0A) the
; bank (0x216A); then (0x2671) = slot of (0x216B) on page (0x2670) (PtrTable_F93444 on the last page) and T_F4181C runs record 0xF2B4C5 (SWI7 0x05
; FillRect of DLTable_F2B4D0[(0x2671)]); SWI7 0x0C C = 3.  Twin: GroupSoundDisplayHold_HighlightSelected, which compares the part record instead.
GroupCombiDisplayHold_HighlightSelected:
	calr LCD_EraseLayer1_FixedRect                                          ; F93E28  1e 63 f6
	calr CombiGroup_MaxMemberIndexOfCurrent                                      ; F93E2B  1e 05 fd
	bit	3, (0x2673:16)                               ; F93E2E  f1 73 26 cb
	jr nz, .LF93E55                                      ; F93E32  6e 21
	push_a                                               ; F93E34  14
	ld l, (0x7f08:16)                                   ; F93E35  c1 08 7f 27
	and L,0xff                                           ; F93E39  cf cc ff
	ld h, (0x7f09:16)                                   ; F93E3C  c1 09 7f 26
	and H,0xff                                           ; F93E40  ce cc ff
	ld w, (0x7f0a:16)                                   ; F93E43  c1 0a 7f 20
	and W,0xff                                           ; F93E47  c8 cc ff
	pop_a                                                ; F93E4A  15
	cp C,L                                               ; F93E4B  cf f3
	jr nz, .LF93ECE                                      ; F93E4D  6e 7f
	cp	w, (SoundSel_Bank:16)                               ; F93E4F  c1 6a 21 f0
	jr nz, .LF93ECE                                      ; F93E53  6e 79
.LF93E55:
	ld l, (SoundSel_Member:16)                                   ; F93E55  c1 6b 21 27
	and L,0xff                                           ; F93E59  cf cc ff
	cp a, 0x07:i3                                          ; F93E5C  c9 df
	jr nz, .LF93E6F                                      ; F93E5E  6e 0f
	ld (0x2671:16), l                                   ; F93E60  f1 71 26 47
	ld XIY,0x00f2b4c5                                    ; F93E64  45 c5 b4 f2 00
	call T_DLB_Handler_Array8                                        ; F93E69  1d 1c 18 f4
	jr .LF93ECE                                          ; F93E6D  68 5f
.LF93E6F:
	xor W,W                                              ; F93E6F  c8 d0
	ld IZ,WA                                             ; F93E71  d8 8e
	ld a, (GroupMembers_Page:16)                                   ; F93E73  c1 70 26 21
	xor W,W                                              ; F93E77  c8 d0
	ld e, 0x08:opc                                          ; F93E79  25 08
	mul wa, e                                          ; F93E7B  cd 41
	cp L,A                                               ; F93E7D  c9 f7
	jr c, .LF93ECE                                       ; F93E7F  67 4d
	add WA,0x0007                                        ; F93E81  d8 c8 07 00
	cp L,A                                               ; F93E85  c9 f7
	jr ugt, .LF93ECE                                     ; F93E87  6b 45
	pushw hl                                             ; F93E89  2b
	pushw bc                                             ; F93E8A  29
	ld A,L                                               ; F93E8B  cf 89
	xor W,W                                              ; F93E8D  c8 d0
	ld e, 0x08:opc                                          ; F93E8F  25 08
	div wa, e                                          ; F93E91  cd 51
	ld C,W                                               ; F93E93  c8 8b
	ld a, (GroupMembers_Page:16)                                   ; F93E95  c1 70 26 21
	cp	a, (0x2672:16)                               ; F93E99  c1 72 26 f1
	jr nz, .LF93EBF                                      ; F93E9D  6e 20
	ld WA,IZ                                             ; F93E9F  de 88
	div wa, e                                          ; F93EA1  cd 51
	ld L,W                                               ; F93EA3  c8 8f
	xor H,H                                              ; F93EA5  ce d6
	sla hl, 0x02                                         ; F93EA7  db ec 02
	ld XIY,PtrTable_F93444                               ; F93EAA  45 44 34 f9 00
	ld	xiy, (xiy+hl)                                ; F93EAF  e3 07 f4 ec 25
	ld L,C                                               ; F93EB4  cb 8f
	xor H,H                                              ; F93EB6  ce d6
	ld	a, (xiy+hl)                                  ; F93EB8  c3 07 f4 ec 21
	add C,A                                              ; F93EBD  c9 83
.LF93EBF:
	ld (0x2671:16), c                                   ; F93EBF  f1 71 26 43
	ld XIY,0x00f2b4c5                                    ; F93EC3  45 c5 b4 f2 00
	call T_DLB_Handler_Array8                                        ; F93EC8  1d 1c 18 f4
	popw bc                                              ; F93ECC  49
	popw hl                                              ; F93ECD  4b
.LF93ECE:
	ld c, 0x03:opc                                          ; F93ECE  23 03
	ld a, 0x0c:opc                                          ; F93ED0  21 0c
	swi 7                                                ; F93ED2  ff
	ret                                                  ; F93ED3  0e
; GroupCombiDisplayHold_DrawMemberNames -- draw the 16-character combination names of members DE..WA of the shown group into their layer-0 slots
; Evidence: GroupSoundDisplayHold_DrawMemberNames' loop with 0x98 for (0x2250): (0x60F17F) = 0x98, T_CombiSel_ClampToNumberAndBankRegs, then T_CombiName_Lookup = CombiName_Lookup (its not-found
; fallback is the ROM string "Combi Name *****") with B = 0x98, and SWI7 0x06 with BC = 0x10.  In: A = max member index, L = group, DE..WA = members.
GroupCombiDisplayHold_DrawMemberNames:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F93ED4  f1 40 25 00 00
	pushw wa                                             ; F93ED9  28
	pushw hl                                             ; F93EDA  2b
	cp a, 0x07:i3                                          ; F93EDB  c9 df
	jr z, .LF93EE9                                       ; F93EDD  66 0a
.LF93EDF:
	cp A,0x08                                            ; F93EDF  c9 cf 08
	jr c, .LF93EE9                                       ; F93EE2  67 05
	sub A,0x08                                           ; F93EE4  c9 ca 08
	jr .LF93EDF                                          ; F93EE7  68 f6
.LF93EE9:
	xor H,H                                              ; F93EE9  ce d6
	ld L,A                                               ; F93EEB  c9 8f
	sla hl, 0x02                                         ; F93EED  db ec 02
	ld XIZ,DLPtrTable_F2B510                             ; F93EF0  46 10 b5 f2 00
	ld	xiz, (xiz+hl)                                ; F93EF5  e3 07 f8 ec 26
	popw hl                                              ; F93EFA  4b
	popw wa                                              ; F93EFB  48
	pushw wa                                             ; F93EFC  28
	pushw bc                                             ; F93EFD  29
	ld c, 0x03:opc                                          ; F93EFE  23 03
	ld a, 0x0c:opc                                          ; F93F00  21 0c
	swi 7                                                ; F93F02  ff
	popw bc                                              ; F93F03  49
	popw wa                                              ; F93F04  48
.LF93F05:
	ld H,E                                               ; F93F05  cd 8e
	push XIZ                                             ; F93F07  3e
	pushw hl                                             ; F93F08  2b
	pushw de                                             ; F93F09  2a
	pushw wa                                             ; F93F0A  28
	pushw de                                             ; F93F0B  2a
	cp wa, 0x07:i3                                         ; F93F0C  d8 df
	jr z, .LF93F1C                                       ; F93F0E  66 0c
.LF93F10:
	cp DE,0x0008                                         ; F93F10  da cf 08 00
	jr c, .LF93F1C                                       ; F93F14  67 06
	sub DE,0x0008                                        ; F93F16  da ca 08 00
	jr .LF93F10                                          ; F93F1A  68 f4
.LF93F1C:
	calr PosTable_GetEntryIX                                          ; F93F1C  1e f7 ef
	popw de                                              ; F93F1F  4a
	ld a, 0x98:opc                                          ; F93F20  21 98
	ld (0x60f17f:24), a                                 ; F93F22  f2 7f f1 60 41
	ld w, (SoundSel_Bank:16)                                   ; F93F27  c1 6a 21 20
	call T_CombiSel_ClampToNumberAndBankRegs                                        ; F93F2B  1d fc 07 f4
	ld W,H                                               ; F93F2F  ce 88
	ld A,L                                               ; F93F31  cf 89
	ld b, 0x98:opc                                          ; F93F33  22 98
	call T_CombiName_Lookup                                        ; F93F35  1d 2c 10 f4
	ldw bc, 0x10                                         ; F93F39  31 10 00
	xor HL,HL                                            ; F93F3C  db d3
	ld a, 0x06:opc                                          ; F93F3E  21 06
	swi 7                                                ; F93F40  ff
	popw wa                                              ; F93F41  48
	popw de                                              ; F93F42  4a
	popw hl                                              ; F93F43  4b
	pop XIZ                                              ; F93F44  5e
	cp DE,WA                                             ; F93F45  d8 f2
	jr nc, .LF93F4D                                      ; F93F47  6f 04
	inc 1,DE                                             ; F93F49  da 61
	jr .LF93F05                                          ; F93F4B  68 b8
.LF93F4D:
	ret                                                  ; F93F4D  0e
; UiEvent_MarkRedrawFromPartClass -- on screen 0x01 (or 0x02 with (0x2687) == 0), OR a per-event bit into (0x2676)/(0x2677) and request a redraw
; Evidence: prom_b slot T_F415B0, an entry of UiListB_Class00..1F, UiListB_Class79 and UiListB_ClassA8; XIY = the record, (0x20B8) its code.  Class 0x79 code 0
; -> (0x2676) |= 0x40; class 0xA8 code 0x12/0x13 -> |= 1/2; other classes code 0 -> (0x2677) |= 7, 3/8/5/7/6/0x0D -> (0x2676) |= 1/2/4/8/0x80/0x30.  Each then
; (0x2095) |= 0x10, which PanelState_SyncScreenFlags / PanelScreen_RunRedraw turn into a re-Enter of the current screen.  Screen 0x02 with (0x2687) != 0 goes to
; UiEvent_MarkPartRedrawBits.  ⚠ prom_b T_F41590-T_F4159C (all four methods of screen object 0xA7) jump here too.
UiEvent_MarkRedrawFromPartClass:
	ld a, (UI_ScreenId:16)                                   ; F93F4E  c1 7c 20 21
	cp a, 0x01:i3                                          ; F93F52  c9 d9
	jr z, .LF93F69                                       ; F93F54  66 13
	cp a, 0x02:i3                                          ; F93F56  c9 da
	jrl nz, .LF93FF1                                     ; F93F58  7e 96 00
	cp	(CombinationMode_Page:16), 0x00                            ; F93F5B  c1 87 26 3f 00
	jr z, .LF93F69                                       ; F93F60  66 07
	call UiEvent_MarkPartRedrawBits                                      ; F93F62  1d 37 40 f9
	jrl .LF93FF1                                         ; F93F66  78 88 00
.LF93F69:
	cp (XIY),0x79                                        ; F93F69  85 3f 79
	jr nz, .LF93F78                                      ; F93F6C  6e 0a
	ld a, (UiEvent_Byte1:16)                                   ; F93F6E  c1 b8 20 21
	cp a, 0x00:i3                                          ; F93F72  c9 d8
	jr z, .LF93FE7                                       ; F93F74  66 71
	jr .LF93FF1                                          ; F93F76  68 79
.LF93F78:
	cp (XIY),0xa8                                        ; F93F78  85 3f a8
	jr nz, .LF93F8D                                      ; F93F7B  6e 10
	ld a, (UiEvent_Byte1:16)                                   ; F93F7D  c1 b8 20 21
	cp A,0x12                                            ; F93F81  c9 cf 12
	jr z, .LF93FBD                                       ; F93F84  66 37
	cp A,0x13                                            ; F93F86  c9 cf 13
	jr z, .LF93FC4                                       ; F93F89  66 39
	jr .LF93FF1                                          ; F93F8B  68 64
.LF93F8D:
	ld a, (UiEvent_Byte1:16)                                   ; F93F8D  c1 b8 20 21
	cp a, 0x00:i3                                          ; F93F91  c9 d8
	jr z, .LF93FB6                                       ; F93F93  66 21
	cp a, 0x03:i3                                          ; F93F95  c9 db
	jr z, .LF93FBD                                       ; F93F97  66 24
	cp A,0x08                                            ; F93F99  c9 cf 08
	jr z, .LF93FC4                                       ; F93F9C  66 26
	cp a, 0x05:i3                                          ; F93F9E  c9 dd
	jr z, .LF93FCB                                       ; F93FA0  66 29
	cp a, 0x07:i3                                          ; F93FA2  c9 df
	jr z, .LF93FD2                                       ; F93FA4  66 2c
	cp A,0x0d                                            ; F93FA6  c9 cf 0d
	jr z, .LF93FE0                                       ; F93FA9  66 35
	cp A,0x0d                                            ; F93FAB  c9 cf 0d
	jr z, .LF93FE0                                       ; F93FAE  66 30
	cp a, 0x06:i3                                          ; F93FB0  c9 de
	jr z, .LF93FD9                                       ; F93FB2  66 25
	jr .LF93FF1                                          ; F93FB4  68 3b
.LF93FB6:
	or	(ModeScreen_DirtyFields2:16), 0x07                            ; F93FB6  c1 77 26 3e 07
	jr .LF93FEC                                          ; F93FBB  68 2f
.LF93FBD:
	or	(ModeScreen_DirtyFields:16), 0x01                            ; F93FBD  c1 76 26 3e 01
	jr .LF93FEC                                          ; F93FC2  68 28
.LF93FC4:
	or	(ModeScreen_DirtyFields:16), 0x02                            ; F93FC4  c1 76 26 3e 02
	jr .LF93FEC                                          ; F93FC9  68 21
.LF93FCB:
	or	(ModeScreen_DirtyFields:16), 0x04                            ; F93FCB  c1 76 26 3e 04
	jr .LF93FEC                                          ; F93FD0  68 1a
.LF93FD2:
	or	(ModeScreen_DirtyFields:16), 0x08                            ; F93FD2  c1 76 26 3e 08
	jr .LF93FEC                                          ; F93FD7  68 13
.LF93FD9:
	or	(ModeScreen_DirtyFields:16), 0x80                            ; F93FD9  c1 76 26 3e 80
	jr .LF93FEC                                          ; F93FDE  68 0c
.LF93FE0:
	or	(ModeScreen_DirtyFields:16), 0x30                            ; F93FE0  c1 76 26 3e 30
	jr .LF93FEC                                          ; F93FE5  68 05
.LF93FE7:
	or	(ModeScreen_DirtyFields:16), 0x40                            ; F93FE7  c1 76 26 3e 40
.LF93FEC:
	or	(UI_ScreenFlags:16), 0x10                            ; F93FEC  c1 95 20 3e 10
.LF93FF1:
	ret                                                  ; F93FF1  0e
; UiEvent_MarkRedrawFromClass20Block -- the same redraw marking for event classes 0x20-0x3F: codes 0x18/0x19/0x1A set (0x2677) bits 0/1/2
; Evidence: prom_b slot T_UiEvent_MarkRedrawFromClass20Block is an entry of UiListB_Class20..UiListB_Class3F and of no other list; screen gate as UiEvent_MarkRedrawFromPartClass
; ((0x207C) == 0x01, or 0x02 with (0x2687) == 0); then (0x2095) |= 0x10.  What the bits of (0x2677) select is not established.
UiEvent_MarkRedrawFromClass20Block:
	ld a, (UI_ScreenId:16)                                   ; F93FF2  c1 7c 20 21
	cp a, 0x01:i3                                          ; F93FF6  c9 d9
	jr z, .LF94007                                       ; F93FF8  66 0d
	cp a, 0x02:i3                                          ; F93FFA  c9 da
	jr nz, .LF94036                                      ; F93FFC  6e 38
	cp	(CombinationMode_Page:16), 0x00                            ; F93FFE  c1 87 26 3f 00
	jr z, .LF94007                                       ; F94003  66 02
	jr .LF94036                                          ; F94005  68 2f
.LF94007:
	ld a, (UiEvent_Byte1:16)                                   ; F94007  c1 b8 20 21
	cp A,0x18                                            ; F9400B  c9 cf 18
	jr z, .LF9401C                                       ; F9400E  66 0c
	cp A,0x19                                            ; F94010  c9 cf 19
	jr z, .LF94023                                       ; F94013  66 0e
	cp A,0x1a                                            ; F94015  c9 cf 1a
	jr z, .LF9402A                                       ; F94018  66 10
	jr .LF94036                                          ; F9401A  68 1a
.LF9401C:
	or	(ModeScreen_DirtyFields2:16), 0x01                            ; F9401C  c1 77 26 3e 01
	jr .LF94031                                          ; F94021  68 0e
.LF94023:
	or	(ModeScreen_DirtyFields2:16), 0x02                            ; F94023  c1 77 26 3e 02
	jr .LF94031                                          ; F94028  68 07
.LF9402A:
	or	(ModeScreen_DirtyFields2:16), 0x04                            ; F9402A  c1 77 26 3e 04
	jr .LF94031                                          ; F9402F  68 00
.LF94031:
	or	(UI_ScreenFlags:16), 0x10                            ; F94031  c1 95 20 3e 10
.LF94036:
	ret                                                  ; F94036  0e
; UiEvent_MarkPartRedrawBits -- for a part event of class 0..7, set bit (class) of one of four per-code bitmaps and request a redraw
; Evidence: only caller UiEvent_MarkRedrawFromPartClass (screen 0x02 with (0x2687) != 0).  A = (XIY) <= 7; `scf / stcf A,(m)` sets bit A of (0x2679) for
; code 0, (0x267A) for 0x0D, (0x267B) for 8, (0x267C) for 3; then (0x2095) |= 0x10.  The dead `ret` at 0xF94077 follows it.
UiEvent_MarkPartRedrawBits:
	ld A,(XIY)                                           ; F94037  85 21
	cp a, 0x07:i3                                          ; F94039  c9 df
	jr ugt, .LF94076                                     ; F9403B  6b 39
	ld w, (UiEvent_Byte1:16)                                   ; F9403D  c1 b8 20 20
	cp w, 0x00:i3                                          ; F94041  c8 d8
	jr z, .LF9406A                                       ; F94043  66 25
	cp w, 0x03:i3                                          ; F94045  c8 db
	jr z, .LF94055                                       ; F94047  66 0c
	cp W,0x08                                            ; F94049  c8 cf 08
	jr z, .LF9405C                                       ; F9404C  66 0e
	cp W,0x0d                                            ; F9404E  c8 cf 0d
	jr z, .LF94063                                       ; F94051  66 10
	jr .LF94076                                          ; F94053  68 21
.LF94055:
	scf                                                  ; F94055  11
	stcf	a, (CombinationMode_DirtyVol:16)                       ; F94056  f1 7c 26 2c
	jr .LF94071                                          ; F9405A  68 15
.LF9405C:
	scf                                                  ; F9405C  11
	stcf	a, (CombinationMode_DirtyPan:16)                       ; F9405D  f1 7b 26 2c
	jr .LF94071                                          ; F94061  68 0e
.LF94063:
	scf                                                  ; F94063  11
	stcf	a, (CombinationMode_DirtyInt:16)                       ; F94064  f1 7a 26 2c
	jr .LF94071                                          ; F94068  68 07
.LF9406A:
	scf                                                  ; F9406A  11
	stcf	a, (CombinationMode_DirtySound:16)                       ; F9406B  f1 79 26 2c
	jr .LF94071                                          ; F9406F  68 00
.LF94071:
	or	(UI_ScreenFlags:16), 0x10                            ; F94071  c1 95 20 3e 10
.LF94076:
	ret                                                  ; F94076  0e
	ret                                                  ; F94077  0e
; ScreenEnter_PowerOnSplash -- the +0 ENTER method of screen 0xAA, the screen PanelState_Init requests at power-on
; Evidence: PanelScreen_VtableTable_ViewB[0xAA] = T_ScreenEnter_PowerOnSplash, whose +0 slot is `jp 0xF94078`; PanelState_Init stores 0x40AA to (0x2070) (screen id 0xAA
; + request flag 0x40).  Body: `calr Paint_PowerOnSplash_Entry / ret`.
ScreenEnter_PowerOnSplash:
	calr Paint_PowerOnSplash_Entry                                            ; F94078  1e 93 00
	ret                                                  ; F9407B  0e
; ScreenLeave_PowerOnSplash -- the +4 LEAVE method of screen 0xAA
; Evidence: T_ScreenLeave_PowerOnSplash (`jp 0xF9407C`) is the +4 slot of the object PanelScreen_VtableTable_ViewB[0xAA] names; body `calr ScreenLeaveBody_PowerOnSplash / ret`.
ScreenLeave_PowerOnSplash:
	calr ScreenLeave_PowerOnSplash_Nop                                          ; F9407C  1e e2 01
	ret                                                  ; F9407F  0e
; ScreenButton_PowerOnSplash -- the +8 BUTTON method of screen 0xAA
; Evidence: T_ScreenButton_PowerOnSplash (`jp 0xF94080`) is the +8 slot; body `ld XIX,DisplayListPtrs_F9408E / call T_PanelButton_CallTableEntry`.  That table's only live entry is [0x0F]
; (EXIT) = 0xF94262, which requests screen 0x01, or 0x02 when (0x7F02) & 0xF0 != 0, with flags 0x02 -- so EXIT skips the splash.
ScreenButton_PowerOnSplash:
	ld XIX,DisplayListPtrs_F9408E                        ; F94080  44 8e 40 f9 00
	call T_PanelButton_CallTableEntry                                        ; F94085  1d 08 1b f4
	ret                                                  ; F94089  0e
sub_F9408A:
	calr sub_F9427C                                          ; F9408A  1e ef 01
	ret                                                  ; F9408D  0e
; ---------------------------------------------------------------------
; DisplayListPtrs_F9408E -- 32 LE32 pointers, same shape
;
; Read by: 0xF94080 `ld XIX,0x00F9408E / call T_PanelButton_CallTableEntry`.
; ENTRY COUNT 32 from T_PanelButton_CallTableEntry's own `cp HL,0x001F`.  ★ base + 128 = 0xF9410E,
;          where the word is 0x0E00011E -- not pointer-shaped.
; Selector: the panel BUTTON CODE.  ScreenButton_PowerOnSplash (0xF94080) is the +8
;          BUTTON method of PanelScreen_VtableTable entry 0xCA (prom_b
;          slot 0xF41518); PanelButton_Route calls it with the code in HL
;          and at (XIZ+8), and it indexes this table with it:
;          `ld XIX,<this> / call T_PanelButton_CallTableEntry`, and T_PanelButton_CallTableEntry = 0xF8BDC5 calls
;          (this + 4*L) after `cp HL,0x001F`.
;          Dispatch_FF3D39's CONTROL LEGEND names each code.
;          (notes/proma-2026-09-25/gen_button_selectors.py, B1-B3)
; ★ 2026-09-25 (lane proma): the selector was recorded as open here.
; Evidence: as ScreenButtonHandlers_GroupSoundDisplayHold.
; ---------------------------------------------------------------------
DisplayListPtrs_F9408E:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	DisplayListPtrs_F914FB_Nop8
	on_key	KEY_SoftKeyCol2,	DisplayListPtrs_F914FB_Nop8
	on_key	KEY_SoftKeyCol3,	DisplayListPtrs_F914FB_Nop8
	on_key	KEY_SoftKeyCol4,	DisplayListPtrs_F914FB_Nop8
	on_key	KEY_SoftKeyCol5,	DisplayListPtrs_F914FB_Nop8
	on_key	KEY_SoftKeyCol6,	DisplayListPtrs_F914FB_Nop8
	on_key	KEY_SoftKeyCol7,	DisplayListPtrs_F914FB_Nop8
	on_key	KEY_SoftKeyCol8,	DisplayListPtrs_F914FB_Nop8
	on_key	KEY_LcdRow1,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_LcdRow2,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_LcdRow3,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_LcdRow4,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_LcdRow5,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_MinusPlus,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Code0E,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Exit,		ExitKey_PowerOnSplash
	on_key	KEY_Page,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_SoftKeyCol1Alt,	DisplayListPtrs_F914FB_Nop8
	on_key	KEY_SoftKeyCol2Alt,	DisplayListPtrs_F914FB_Nop8
	on_key	KEY_SoftKeyCol3Alt,	DisplayListPtrs_F914FB_Nop8
	on_key	KEY_SoftKeyCol4Alt,	DisplayListPtrs_F914FB_Nop8
	on_key	KEY_SoftKeyCol5Alt,	DisplayListPtrs_F914FB_Nop8
	on_key	KEY_SoftKeyCol6Alt,	DisplayListPtrs_F914FB_Nop8
	on_key	KEY_SoftKeyCol7Alt,	DisplayListPtrs_F914FB_Nop8
	on_key	KEY_SoftKeyCol8Alt,	DisplayListPtrs_F914FB_Nop8
	on_key	KEY_PageAlt,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Code1A,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_NumberPad,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Code1C,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Code1D,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Compare,		DisplayListPtrs_F914FB_Nop8
	on_key	KEY_Code1F,		DisplayListPtrs_F914FB_Nop8
	keymap_end
; Paint_PowerOnSplash_Entry -- a PURE WRAPPER for Paint_PowerOnSplash: `calr 0xF94112 / ret`, named for it
; Evidence: its only caller is ScreenEnter_PowerOnSplash (0xF94078); the extent ends at 0xF94112, where Paint_PowerOnSplash begins.
Paint_PowerOnSplash_Entry:
	calr Paint_PowerOnSplash                                      ; F9410E  1e 01 00
	ret                                                  ; F94111  0e
; Paint_PowerOnSplash -- draw the power-on splash (dithered halves sliding together, then the Technics wordmark), or ALL INITIAL SETTING!
; Evidence: (0x97) bit 0 set, bit 4 clear -> LCD_DrawAllInitialSettingMessage (FACTORY CLEAR sets (0x97) bit 0 before re-entering RESET).  First Enter
; ((0x207C) != (0x207D)): SWI7 0x03 blits SplashImage_DitherA (IX 0) and SplashImage_DitherB (IX 0x4C00), SWI7 0x0C C = 5, (0x2541)/(0x2543) = 0x2580,
; (0x2545) = 0x2680, (0x207E) = 0.  Each re-Enter ((0x2071) |= 0x10, (0x209A) = 0xFF): phase 0 runs LCD_ScrollLayer0_Back3Lines / _ScrollLayer2_Forward3Lines
; every >= 0x14 counts of (0x80) until (0x2545) reaches 0x4C00; phase 1 counts (0x2680) = 0x800 down, then blits SplashImage_Wordmark to layer 1,
; SWI7 0x0C C = 2, (0x209A) = 0x3F (auto-return, PanelState_TakePendingHoldTime).  Caller: Paint_PowerOnSplash_Entry.
Paint_PowerOnSplash:
	bit	0, (0x97:8)                                   ; F94112  f0 97 c8
	jr z, .LF94122                                       ; F94115  66 0b
	bit	4, (0x97:8)                                   ; F94117  f0 97 cc
	jr nz, .LF94122                                      ; F9411A  6e 06
	calr LCD_DrawAllInitialSettingMessage                                      ; F9411C  1e f1 00
	jrl .LF941F3                                         ; F9411F  78 d1 00
.LF94122:
	ld a, (UI_ScreenId:16)                                   ; F94122  c1 7c 20 21
	cp	a, (UI_ScreenId_Previous:16)                               ; F94126  c1 7d 20 f1
	jr z, .LF9416F                                       ; F9412A  66 43
	xor C,C                                              ; F9412C  cb d3
	ld a, 0x0c:opc                                          ; F9412E  21 0c
	swi 7                                                ; F94130  ff
	ld XIY,SplashImage_DitherA                           ; F94131  45 00 80 ff 00
	ldw ix, 0x00                                         ; F94136  34 00 00
	ldw hl, 0xf0                                         ; F94139  33 f0 00
	ldw bc, 0x28                                         ; F9413C  31 28 00
	ld a, 0x03:opc                                          ; F9413F  21 03
	swi 7                                                ; F94141  ff
	ld XIY,SplashImage_DitherB                           ; F94142  45 80 a5 ff 00
	ldw ix, 0x4c00                                       ; F94147  34 00 4c
	ldw hl, 0xf0                                         ; F9414A  33 f0 00
	ldw bc, 0x28                                         ; F9414D  31 28 00
	ld a, 0x03:opc                                          ; F94150  21 03
	swi 7                                                ; F94152  ff
	ld c, 0x05:opc                                          ; F94153  23 05
	ld a, 0x0c:opc                                          ; F94155  21 0c
	swi 7                                                ; F94157  ff
	ldw (LCD_Layer0_SAD:16), 0x2580                              ; F94158  f1 41 25 02 80 25
	ldw (LCD_Layer2_SAD:16), 0x2680                              ; F9415E  f1 45 25 02 80 26
	ldw (LCD_Layer1_SAD:16), 0x2580                              ; F94164  f1 43 25 02 80 25
	ld (UI_ScreenStage:16), 0x00                                 ; F9416A  f1 7e 20 00 00
.LF9416F:
	bit	4, (UI_RequestBits:16)                               ; F9416F  f1 75 20 cc
	jrl nz, .LF941F3                                     ; F94173  7e 7d 00
	cp	(UI_ScreenStage:16), 0x00                            ; F94176  c1 7e 20 3f 00
	jr nz, .LF941C6                                      ; F9417B  6e 49
	ld	wa, (Tick_Count:8)                                 ; F9417D  d0 80 20
	sub	wa, (0x2680:16)                              ; F94180  d1 80 26 a0
	cp WA,0x0014                                         ; F94184  d8 cf 14 00
	jr c, .LF941A7                                       ; F94188  67 1d
	cpw	(LCD_Layer0_SAD:16), 0x0000                          ; F9418A  d1 41 25 3f 00 00
	jr ule, .LF94195                                     ; F94190  63 03
	calr LCD_ScrollLayer0_Back3Lines                                      ; F94192  1e 5f 00
.LF94195:
	cpw	(LCD_Layer2_SAD:16), 0x4c00                          ; F94195  d1 45 25 3f 00 4c
	jr nc, .LF941B9                                      ; F9419B  6f 1c
	calr LCD_ScrollLayer2_Forward3Lines                                      ; F9419D  1e 62 00
	ld	wa, (Tick_Count:8)                                 ; F941A0  d0 80 20
	ld (0x2680:16), wa                                  ; F941A3  f1 80 26 50
.LF941A7:
	ld (UI_ScreenHoldPending:16), 0xff                                 ; F941A7  f1 9a 20 00 ff
	or	(UI_Request_Hi:16), 0x10                            ; F941AC  c1 71 20 3e 10
	jr .LF941EE                                          ; F941B1  68 3b
.LF941B3:
	decw 0x01, (0x2680:16)                               ; F941B3  d1 80 26 69
	jr .LF941A7                                          ; F941B7  68 ee
.LF941B9:
	ldw (0x2680:16), 0x0800                              ; F941B9  f1 80 26 02 00 08
	ld (UI_ScreenStage:16), 0x01                                 ; F941BF  f1 7e 20 00 01
	jr .LF941A7                                          ; F941C4  68 e1
.LF941C6:
	cpw	(0x2680:16), 0x0000                          ; F941C6  d1 80 26 3f 00 00
	jr nz, .LF941B3                                      ; F941CC  6e e5
	ld (LCD_CurrentLayer:16), 0x01                                 ; F941CE  f1 40 25 00 01
	ld XIY,SplashImage_Wordmark                          ; F941D3  45 00 cb ff 00
	ldw ix, 0x00                                         ; F941D8  34 00 00
	ldw hl, 0xf0                                         ; F941DB  33 f0 00
	ldw bc, 0x28                                         ; F941DE  31 28 00
	ld a, 0x03:opc                                          ; F941E1  21 03
	swi 7                                                ; F941E3  ff
	ld c, 0x02:opc                                          ; F941E4  23 02
	ld a, 0x0c:opc                                          ; F941E6  21 0c
	swi 7                                                ; F941E8  ff
	ld (UI_ScreenHoldPending:16), 0x3f                                 ; F941E9  f1 9a 20 00 3f
.LF941EE:
	bit	4, (0x97:8)                                   ; F941EE  f0 97 cc
	jr z, .LF941F3                                       ; F941F1  66 00
.LF941F3:
	ret                                                  ; F941F3  0e
; ---------------------------------------------------------------------
; LCD_ScrollLayer0_Back3Lines -- hardware-scroll layer 0 back by three scan lines
;
; Called from: prom_a Paint_PowerOnSplash (`calr`) at 0xF94192
; Issues:  SWI7 service 0x1E at 0xF94200 -- LCD_Svc_1E_ScrollCurrentLayer, move the current layer's window
; Evidence: `ld (0x2540),0x00` selects layer 0; `ld C,0x40` + `or C,0x03` makes C =
;           0x43; service 0x1E reads bits 7:6 as the arm and bits 3:0 as the amount,
;           and arm 0x40 is `base := base - n*0x28` with 0x28 = AP = 40 bytes per scan
;           line.  n = 3.  ★ Service 0x1E's own header says `Unknown: callers`; this
;           routine and LCD_ScrollLayer2_Forward3Lines are two of them.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
LCD_ScrollLayer0_Back3Lines:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F941F4  f1 40 25 00 00
	ld c, 0x40:opc                                          ; F941F9  23 40
	or C,0x03                                            ; F941FB  cb ce 03
	ld a, 0x1e:opc                                          ; F941FE  21 1e
	swi 7                                                ; F94200  ff
	ret                                                  ; F94201  0e
; ---------------------------------------------------------------------
; LCD_ScrollLayer2_Forward3Lines -- hardware-scroll layer 2 forward by three scan lines
;
; Called from: prom_a Paint_PowerOnSplash (`calr`) at 0xF9419D
; Issues:  SWI7 service 0x1E at 0xF9420E -- LCD_Svc_1E_ScrollCurrentLayer, move the current layer's window
; Evidence: `ld (0x2540),0x02`, then C = 0x00 | 0x03 = 0x03: arm 0x00 of service 0x1E is
;           `base := base + n*0x28`, n = 3.  Same routine as the one above with the two
;           immediates changed, which is what makes the pair readable.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
LCD_ScrollLayer2_Forward3Lines:
	ld (LCD_CurrentLayer:16), 0x02                                 ; F94202  f1 40 25 00 02
	ld c, 0x00:opc                                          ; F94207  23 00
	or C,0x03                                            ; F94209  cb ce 03
	ld a, 0x1e:opc                                          ; F9420C  21 1e
	swi 7                                                ; F9420E  ff
	ret                                                  ; F9420F  0e
; ---------------------------------------------------------------------
; LCD_DrawAllInitialSettingMessage -- draw the 20-character message ALL INITIAL SETTING! and light layer 1
;
; Called from: prom_a Paint_PowerOnSplash (`calr`) at 0xF9411C
; Issues:  SWI7 service 0x08 at 0xF94225 -- LCD_Svc_08_DrawText16x16, draw 16x16 text
; Issues:  SWI7 service 0x0C at 0xF9422A -- LCD_Svc_0C_SetLayersOn, rebuild DISP ON: C bits 0/1/2 = layers 1/2/3 steady on
; Evidence: `ld XIY,0x00F9422C` + `ld BC,0x0014` + `ld IX,0x07D0` + service 0x08, and
;           the twenty ROM bytes at 0xF9422C are the ASCII `ALL INITIAL SETTING!`
;           (checked byte for byte by --selftest).  It then issues service 0x0C with
;           C = 1, leaving layer 1 alone visible.  Every morpheme of the name is that
;           ROM string; `Draw` and `Message` are structural.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
LCD_DrawAllInitialSettingMessage:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F94210  f1 40 25 00 00
	ld XIY,Str_AllInitialSetting                                    ; F94215  45 2c 42 f9 00
	ldw hl, 0x00                                         ; F9421A  33 00 00
	ldw bc, 0x14                                         ; F9421D  31 14 00
	ldw ix, 0x07d0                                       ; F94220  34 d0 07
	ld a, 0x08:opc                                          ; F94223  21 08
	swi 7                                                ; F94225  ff
	ld c, 0x01:opc                                          ; F94226  23 01
	ld a, 0x0c:opc                                          ; F94228  21 0c
	swi 7                                                ; F9422A  ff
	ret                                                  ; F9422B  0e
; The 20 characters LCD_DrawAllInitialSettingMessage draws (BC = 0x14, SWI 7 service 8).  These bytes were
; decoded as instructions, and the decode ran on two bytes into the next routine at 0xF94240 (2026-10-04).
Str_AllInitialSetting:
	.ascii "ALL INITIAL SETTING!"                         ; F9422C  41 4c 4c 20 49 4e 49 54 49 41 4c 20 53 45 54 54 49 4e 47 21
	ld (LCD_CurrentLayer:16), 0x00                                 ; F94240  f1 40 25 00 00
	ldw (LCD_X0:16), 0x92                                ; F94245  f1 30 25 02 92 00
	ldw (LCD_Y0:16), 0xd8                                ; F9424B  f1 32 25 02 d8 00
	ldw (LCD_X1:16), 0xa2                                ; F94251  f1 34 25 02 a2 00
	ldw (LCD_Y1:16), 0xd8                                ; F94257  f1 36 25 02 d8 00
	ld a, 0x01:opc                                          ; F9425D  21 01
	swi 7                                                ; F9425F  ff
	ret                                                  ; F94260  0e
ScreenLeave_PowerOnSplash_Nop:
	ret                                                  ; F94261  0e
; ExitKey_PowerOnSplash: slot 15 (EXIT) of DisplayListPtrs_F9408E, the POWER ON SPLASH button table; UI_Request = 0x0201 when
;   (0x7F02) & 0xF0 is 0, else 0x0202.
ExitKey_PowerOnSplash:
	ld a, (0x7f02:16)                                   ; F94262  c1 02 7f 21
	and A,0xf0                                           ; F94266  c9 cc f0
	cp a, 0x00:i3                                          ; F94269  c9 d8
	jr nz, .LF94275                                      ; F9426B  6e 08
	ldw (UI_Request:16), 0x0201                              ; F9426D  f1 70 20 02 01 02
	jr .LF9427B                                          ; F94273  68 06
.LF94275:
	ldw (UI_Request:16), 0x0202                              ; F94275  f1 70 20 02 02 02
.LF9427B:
	ret                                                  ; F9427B  0e
sub_F9427C:
	ret                                                  ; F9427C  0e
; UiEvent_SyncSoundSelection -- keep the group/member/bank cells (0x2169)/(0x216B)/(0x216A) in step with part, bank and group events
; Evidence: prom_b slot T_UiEvent_SyncSoundSelection, an entry of UiListB_Class00..1F, UiListB_Class90, UiListB_Class98, UiListB_ClassA8; XIY = the record.  Class 0xA8 code 0x07
; (BANK, FINDINGS-prom_a-panel-control-map.md 1): SoundGroup_ReloadSelection, then if (0x20BA) & 0x3F: (0x216A) = (0x20B9) & 0x3F and, when it changed,
; (0x2169) = 0.  Class 0xA8 code 0x08: (0x2169) = (0x20B9) & 0x0F.  Class 0x90 code 0x10, class 0x98 code 1/0, and a part class <= 0x1F equal to (0x2250)
; with code 0: SoundGroup_ReloadSelection.
UiEvent_SyncSoundSelection:
	ld C,(XIY)                                           ; F9427D  85 23
	cp C,0xa8                                            ; F9427F  cb cf a8
	jr z, .LF942B6                                       ; F94282  66 32
	cp C,0x90                                            ; F94284  cb cf 90
	jrl z, .LF94324                                      ; F94287  76 9a 00
	cp C,0x98                                            ; F9428A  cb cf 98
	jrl z, .LF942FF                                      ; F9428D  76 6f 00
	cp C,0x1f                                            ; F94290  cb cf 1f
	jrl ugt, .LF94339                                    ; F94293  7b a3 00
	ld a, (UiEvent_Byte1:16)                                   ; F94296  c1 b8 20 21
	cp a, 0x00:i3                                          ; F9429A  c9 d8
	jrl nz, .LF94339                                     ; F9429C  7e 9a 00
	ld a, (UiEvent_Byte3:16)                                   ; F9429F  c1 ba 20 21
	and A,0xff                                           ; F942A3  c9 cc ff
	jrl z, .LF94339                                      ; F942A6  76 90 00
	cp	c, (UI_PartIndex:16)                               ; F942A9  c1 50 22 f3
	jrl nz, .LF94339                                     ; F942AD  7e 89 00
	calr SoundGroup_ReloadSelection                                      ; F942B0  1e 87 00
	jrl .LF94339                                         ; F942B3  78 83 00
.LF942B6:
	ld a, (UiEvent_Byte1:16)                                   ; F942B6  c1 b8 20 21
	cp a, 0x07:i3                                          ; F942BA  c9 df
	jr z, .LF942DB                                       ; F942BC  66 1d
	cp A,0x08                                            ; F942BE  c9 cf 08
	jrl nz, .LF94339                                     ; F942C1  7e 75 00
	ld a, (UiEvent_Byte3:16)                                   ; F942C4  c1 ba 20 21
	and A,0x0f                                           ; F942C8  c9 cc 0f
	jrl z, .LF94339                                      ; F942CB  76 6b 00
	ld a, (UiEvent_Byte2:16)                                   ; F942CE  c1 b9 20 21
	and A,0x0f                                           ; F942D2  c9 cc 0f
	ld (SoundSel_Group:16), a                                   ; F942D5  f1 69 21 41
	jr .LF94339                                          ; F942D9  68 5e
.LF942DB:
	calr SoundGroup_ReloadSelection                                      ; F942DB  1e 5c 00
	ld a, (UiEvent_Byte3:16)                                   ; F942DE  c1 ba 20 21
	and A,0x3f                                           ; F942E2  c9 cc 3f
	jr z, .LF94339                                       ; F942E5  66 52
	ld a, (UiEvent_Byte2:16)                                   ; F942E7  c1 b9 20 21
	and A,0x3f                                           ; F942EB  c9 cc 3f
	cp	a, (SoundSel_Bank:16)                               ; F942EE  c1 6a 21 f1
	jr z, .LF94339                                       ; F942F2  66 45
	ld (SoundSel_Bank:16), a                                   ; F942F4  f1 6a 21 41
	ld (SoundSel_Group:16), 0x00                                 ; F942F8  f1 69 21 00 00
	jr .LF94339                                          ; F942FD  68 3a
.LF942FF:
	ld a, (UiEvent_Byte1:16)                                   ; F942FF  c1 b8 20 21
	cp a, 0x01:i3                                          ; F94303  c9 d9
	jr z, .LF94316                                       ; F94305  66 0f
	cp a, 0x00:i3                                          ; F94307  c9 d8
	jr nz, .LF94339                                      ; F94309  6e 2e
	ld a, (UiEvent_Byte3:16)                                   ; F9430B  c1 ba 20 21
	and A,0x10                                           ; F9430F  c9 cc 10
	jr z, .LF94339                                       ; F94312  66 25
	jr .LF9431F                                          ; F94314  68 09
.LF94316:
	ld a, (UiEvent_Byte3:16)                                   ; F94316  c1 ba 20 21
	and A,0x7f                                           ; F9431A  c9 cc 7f
	jr z, .LF94339                                       ; F9431D  66 1a
.LF9431F:
	calr SoundGroup_ReloadSelection                                      ; F9431F  1e 18 00
	jr .LF94339                                          ; F94322  68 15
.LF94324:
	ld a, (UiEvent_Byte1:16)                                   ; F94324  c1 b8 20 21
	cp A,0x10                                            ; F94328  c9 cf 10
	jr nz, .LF94339                                      ; F9432B  6e 0c
	ld a, (UiEvent_Byte3:16)                                   ; F9432D  c1 ba 20 21
	and A,0xff                                           ; F94331  c9 cc ff
	jr z, .LF94339                                       ; F94334  66 03
	calr SoundGroup_ReloadSelection                                      ; F94336  1e 01 00
.LF94339:
	ret                                                  ; F94339  0e
; SoundGroup_ReloadSelection -- reload (0x2169)/(0x216B)/(0x216A) from the current part's record or from the global cells
; Evidence: SoundGroup_LoadSelectionFromPart when (0x7F02) & 0xF0 == 0, or mode (0x2078) in {3,4,5,6,7,8,9,0x16}, or (0x207A) == 0xB7; otherwise
; SoundGroup_LoadSelectionFromGlobal.  Published as T_SoundGroup_ReloadSelection (prom_b 0xF56B62, prom_a 0xF99F0C, 0xF9FED9) and called four times by UiEvent_SyncSoundSelection.
SoundGroup_ReloadSelection:
	ld a, (0x7f02:16)                                   ; F9433A  c1 02 7f 21
	and A,0xf0                                           ; F9433E  c9 cc f0
	cp a, 0x00:i3                                          ; F94341  c9 d8
	jr z, .LF9437A                                       ; F94343  66 35
	ld a, (PanelMode:16)                                   ; F94345  c1 78 20 21
	cp A,0x16                                            ; F94349  c9 cf 16
	jr z, .LF9437A                                       ; F9434C  66 2c
	cp A,0x09                                            ; F9434E  c9 cf 09
	jr z, .LF9437A                                       ; F94351  66 27
	cp a, 0x03:i3                                          ; F94353  c9 db
	jr z, .LF9437A                                       ; F94355  66 23
	cp a, 0x06:i3                                          ; F94357  c9 de
	jr z, .LF9437A                                       ; F94359  66 1f
	cp a, 0x05:i3                                          ; F9435B  c9 dd
	jr z, .LF9437A                                       ; F9435D  66 1b
	cp a, 0x04:i3                                          ; F9435F  c9 dc
	jr z, .LF9437A                                       ; F94361  66 17
	cp a, 0x07:i3                                          ; F94363  c9 df
	jr z, .LF9437A                                       ; F94365  66 13
	cp A,0x08                                            ; F94367  c9 cf 08
	jr z, .LF9437A                                       ; F9436A  66 0e
	ld a, (UI_ScreenLatch:16)                                   ; F9436C  c1 7a 20 21
	cp A,0xb7                                            ; F94370  c9 cf b7
	jr z, .LF9437A                                       ; F94373  66 05
	calr SoundGroup_LoadSelectionFromGlobal                                      ; F94375  1e 3e 00
	jr .LF9437D                                          ; F94378  68 03
.LF9437A:
	calr SoundGroup_LoadSelectionFromPart                                      ; F9437A  1e 01 00
.LF9437D:
	ret                                                  ; F9437D  0e
; SoundGroup_LoadSelectionFromPart -- copy the current part's group/member/bank into (0x2169)/(0x216B)/(0x216A)
; Evidence: unless (0x2078) == 2: PartRecord_GetSecondHalfPtr, then (0x2674) = old (0x216A), (0x216A) = (XIY+0x1D), (0x2169) = (XIY+0x1B),
; (0x216B) = (XIY+0x1C) (record +0x3D/+0x3B/+0x3C), and `or (0x2116),0x0044`.  Callers: SoundGroup_ReloadSelection, numeric calr from ModeScreen_PaintDirtyFields2_DeadCopy (0xF90C0E).
SoundGroup_LoadSelectionFromPart:
	ld a, (PanelMode:16)                                   ; F9437E  c1 78 20 21
	cp a, 0x02:i3                                          ; F94382  c9 da
	jr z, .LF943B5                                       ; F94384  66 2f
	calr PartRecord_GetSecondHalfPtr                                      ; F94386  1e c4 01
	ld W,(XIY+0x1d)                                      ; F94389  8d 1d 20
	and W,0xff                                           ; F9438C  c8 cc ff
	ld L,(XIY+0x1b)                                      ; F9438F  8d 1b 27
	and L,0xff                                           ; F94392  cf cc ff
	ld H,(XIY+0x1c)                                      ; F94395  8d 1c 26
	and H,0xff                                           ; F94398  ce cc ff
	ld a, (SoundSel_Bank:16)                                   ; F9439B  c1 6a 21 21
	ld (SoundGroup_PreviousBank:16), a                                   ; F9439F  f1 74 26 41
	ld (SoundSel_Bank:16), w                                   ; F943A3  f1 6a 21 40
	ld (SoundSel_Group:16), l                                   ; F943A7  f1 69 21 47
	ld (SoundSel_Member:16), h                                   ; F943AB  f1 6b 21 46
	orw	(0x2116:16), 0x0044                  ; F943AF  d1 16 21 3e 44 00
.LF943B5:
	ret                                                  ; F943B5  0e
; SoundGroup_LoadSelectionFromGlobal -- copy the global group/member/bank cells (0x7F08)/(0x7F09)/(0x7F0A) into (0x2169)/(0x216B)/(0x216A)
; Evidence: unless (0x2078) == 1: (0x2674) = old (0x216A), (0x216A) = (0x7F0A), (0x2169) = (0x7F08), (0x216B) = (0x7F09), `or (0x2116),0x0044` -- the
; same shape as SoundGroup_LoadSelectionFromPart; (0x7F08)/(0x7F0A) are what GroupCombiDisplayHold_HighlightSelected compares against.
; Callers: SoundGroup_ReloadSelection, sub_F90C13 (0xF90C1C).
SoundGroup_LoadSelectionFromGlobal:
	ld a, (PanelMode:16)                                   ; F943B6  c1 78 20 21
	cp a, 0x01:i3                                          ; F943BA  c9 d9
	jr z, .LF943ED                                       ; F943BC  66 2f
	ld l, (0x7f08:16)                                   ; F943BE  c1 08 7f 27
	and L,0xff                                           ; F943C2  cf cc ff
	ld h, (0x7f09:16)                                   ; F943C5  c1 09 7f 26
	and H,0xff                                           ; F943C9  ce cc ff
	ld w, (0x7f0a:16)                                   ; F943CC  c1 0a 7f 20
	and W,0xff                                           ; F943D0  c8 cc ff
	ld a, (SoundSel_Bank:16)                                   ; F943D3  c1 6a 21 21
	ld (SoundGroup_PreviousBank:16), a                                   ; F943D7  f1 74 26 41
	ld (SoundSel_Bank:16), w                                   ; F943DB  f1 6a 21 40
	ld (SoundSel_Group:16), l                                   ; F943DF  f1 69 21 47
	ld (SoundSel_Member:16), h                                   ; F943E3  f1 6b 21 46
	orw	(0x2116:16), 0x0044                  ; F943E7  d1 16 21 3e 44 00
.LF943ED:
	ret                                                  ; F943ED  0e
; UiEventClassA8_ShowGroupScreen -- on a BANK (0xA8/0x07) or group (0xA8/0x08) event, open or redraw the group display-hold screen
; Evidence: prom_b slot T_UiEventClassA8_ShowGroupScreen, the only entry of UiListC_ClassA8.  Mode (0x2078) 1 or 2 (else UiEventClassA8_ShowGroupScreenOtherMode).  Code 0x08: screen
; 0x01 or 0xA0 (SoundGroupMenu) -> request 0xA1 (GroupSoundDisplayHold); 0x02 or 0xA5 -> 0xA6 (GroupCombiDisplayHold); 0xA1/0xA6 -> (0x2095) |= 0x10;
; 0xA3 -> 0xA1 with (0x2075) |= 0x80.  Code 0x07: 0x01 -> 0xA1, 0x02 -> 0xA6, 0xA1/0xA6 -> redraw, 0xA0/0xA5 -> (0x2071) |= 0x10.
UiEventClassA8_ShowGroupScreen:
	ld a, (PanelMode:16)                                   ; F943EE  c1 78 20 21
	cp a, 0x01:i3                                          ; F943F2  c9 d9
	jr z, .LF94400                                       ; F943F4  66 0a
	cp a, 0x02:i3                                          ; F943F6  c9 da
	jr z, .LF94400                                       ; F943F8  66 06
	calr UiEventClassA8_ShowGroupScreenOtherMode                                      ; F943FA  1e a4 00
	jrl .LF944A0                                         ; F943FD  78 a0 00
.LF94400:
	ld a, (UiEvent_Byte1:16)                                   ; F94400  c1 b8 20 21
	cp a, 0x07:i3                                          ; F94404  c9 df
	jr z, .LF94462                                       ; F94406  66 5a
	cp A,0x08                                            ; F94408  c9 cf 08
	jrl nz, .LF944A0                                     ; F9440B  7e 92 00
	ld a, (UI_ScreenId:16)                                   ; F9440E  c1 7c 20 21
	cp a, 0x01:i3                                          ; F94412  c9 d9
	jr nz, .LF9441C                                      ; F94414  6e 06
	ldw (UI_Request:16), 0x80a1                              ; F94416  f1 70 20 02 a1 80
.LF9441C:
	cp A,0xa0                                            ; F9441C  c9 cf a0
	jr nz, .LF94427                                      ; F9441F  6e 06
	ldw (UI_Request:16), 0x80a1                              ; F94421  f1 70 20 02 a1 80
.LF94427:
	cp A,0xa1                                            ; F94427  c9 cf a1
	jr nz, .LF94431                                      ; F9442A  6e 05
	or	(UI_ScreenFlags:16), 0x10                            ; F9442C  c1 95 20 3e 10
.LF94431:
	cp a, 0x02:i3                                          ; F94431  c9 da
	jr nz, .LF9443B                                      ; F94433  6e 06
	ldw (UI_Request:16), 0x80a6                              ; F94435  f1 70 20 02 a6 80
.LF9443B:
	cp A,0xa5                                            ; F9443B  c9 cf a5
	jr nz, .LF94446                                      ; F9443E  6e 06
	ldw (UI_Request:16), 0x80a6                              ; F94440  f1 70 20 02 a6 80
.LF94446:
	cp A,0xa6                                            ; F94446  c9 cf a6
	jr nz, .LF94450                                      ; F94449  6e 05
	or	(UI_ScreenFlags:16), 0x10                            ; F9444B  c1 95 20 3e 10
.LF94450:
	cp A,0xa3                                            ; F94450  c9 cf a3
	jr nz, .LF94460                                      ; F94453  6e 0b
	ldw (UI_Request:16), 0x80a1                              ; F94455  f1 70 20 02 a1 80
	or	(UI_RequestBits:16), 0x80                            ; F9445B  c1 75 20 3e 80
.LF94460:
	jr .LF944A0                                          ; F94460  68 3e
.LF94462:
	ld a, (UI_ScreenId:16)                                   ; F94462  c1 7c 20 21
	cp a, 0x01:i3                                          ; F94466  c9 d9
	jr z, .LF94484                                       ; F94468  66 1a
	cp A,0xa1                                            ; F9446A  c9 cf a1
	jr z, .LF94494                                       ; F9446D  66 25
	cp A,0xa0                                            ; F9446F  c9 cf a0
	jr z, .LF9449B                                       ; F94472  66 27
	cp a, 0x02:i3                                          ; F94474  c9 da
	jr z, .LF9448C                                       ; F94476  66 14
	cp A,0xa6                                            ; F94478  c9 cf a6
	jr z, .LF94494                                       ; F9447B  66 17
	cp A,0xa5                                            ; F9447D  c9 cf a5
	jr z, .LF9449B                                       ; F94480  66 19
	jr .LF944A0                                          ; F94482  68 1c
.LF94484:
	ldw (UI_Request:16), 0x80a1                              ; F94484  f1 70 20 02 a1 80
	jr .LF944A0                                          ; F9448A  68 14
.LF9448C:
	ldw (UI_Request:16), 0x80a6                              ; F9448C  f1 70 20 02 a6 80
	jr .LF944A0                                          ; F94492  68 0c
.LF94494:
	or	(UI_ScreenFlags:16), 0x10                            ; F94494  c1 95 20 3e 10
	jr .LF944A0                                          ; F94499  68 05
.LF9449B:
	or	(UI_Request_Hi:16), 0x10                            ; F9449B  c1 71 20 3e 10
.LF944A0:
	ret                                                  ; F944A0  0e
; UiEventClassA8_ShowGroupScreenOtherMode -- the same for modes other than 1 and 2: request 0x40A1 or 0x40A6, or redraw it if already shown
; Evidence: only caller UiEventClassA8_ShowGroupScreen (0xF943FA); codes 0x07/0x08 only.  (0x7F02) & 0xF0 == 0: modes 0x17-0x1B ignored, else 0xA1;
; otherwise 0xA1 when (0x207A) == 0xB7 or mode in {3..9, 0x16}, else 0xA6.  Requests store 0x40A1/0x40A6 to (0x2070) and (0x2075) |= 0x80;
; when that screen is already current, (0x2095) |= 0x10 instead.
UiEventClassA8_ShowGroupScreenOtherMode:
	ld a, (UiEvent_Byte1:16)                                   ; F944A1  c1 b8 20 21
	cp a, 0x07:i3                                          ; F944A5  c9 df
	jr z, .LF944AF                                       ; F944A7  66 06
	cp A,0x08                                            ; F944A9  c9 cf 08
	jrl nz, .LF94538                                     ; F944AC  7e 89 00
.LF944AF:
	ld a, (0x7f02:16)                                   ; F944AF  c1 02 7f 21
	and A,0xf0                                           ; F944B3  c9 cc f0
	cp a, 0x00:i3                                          ; F944B6  c9 d8
	jr nz, .LF944ED                                      ; F944B8  6e 33
	ld a, (PanelMode:16)                                   ; F944BA  c1 78 20 21
	cp A,0x17                                            ; F944BE  c9 cf 17
	jr z, .LF94538                                       ; F944C1  66 75
	cp A,0x18                                            ; F944C3  c9 cf 18
	jr z, .LF94538                                       ; F944C6  66 70
	cp A,0x19                                            ; F944C8  c9 cf 19
	jr z, .LF94538                                       ; F944CB  66 6b
	cp A,0x1a                                            ; F944CD  c9 cf 1a
	jr z, .LF94538                                       ; F944D0  66 66
	cp A,0x1b                                            ; F944D2  c9 cf 1b
	jr z, .LF94538                                       ; F944D5  66 61
.LF944D7:
	ld a, (UI_ScreenId:16)                                   ; F944D7  c1 7c 20 21
	cp A,0xa1                                            ; F944DB  c9 cf a1
	jr z, .LF94533                                       ; F944DE  66 53
	ldw (UI_Request:16), 0x40a1                              ; F944E0  f1 70 20 02 a1 40
	or	(UI_RequestBits:16), 0x80                            ; F944E6  c1 75 20 3e 80
	jr .LF94538                                          ; F944EB  68 4b
.LF944ED:
	ld a, (UI_ScreenLatch:16)                                   ; F944ED  c1 7a 20 21
	cp A,0xb7                                            ; F944F1  c9 cf b7
	jr z, .LF944D7                                       ; F944F4  66 e1
	ld a, (PanelMode:16)                                   ; F944F6  c1 78 20 21
	cp A,0x16                                            ; F944FA  c9 cf 16
	jr z, .LF944D7                                       ; F944FD  66 d8
	cp A,0x09                                            ; F944FF  c9 cf 09
	jr z, .LF944D7                                       ; F94502  66 d3
	cp a, 0x03:i3                                          ; F94504  c9 db
	jr z, .LF944D7                                       ; F94506  66 cf
	cp a, 0x06:i3                                          ; F94508  c9 de
	jr z, .LF944D7                                       ; F9450A  66 cb
	cp a, 0x05:i3                                          ; F9450C  c9 dd
	jr z, .LF944D7                                       ; F9450E  66 c7
	cp a, 0x04:i3                                          ; F94510  c9 dc
	jr z, .LF944D7                                       ; F94512  66 c3
	cp a, 0x07:i3                                          ; F94514  c9 df
	jr z, .LF944D7                                       ; F94516  66 bf
	cp A,0x08                                            ; F94518  c9 cf 08
	jr z, .LF944D7                                       ; F9451B  66 ba
	ld a, (UI_ScreenId:16)                                   ; F9451D  c1 7c 20 21
	cp A,0xa6                                            ; F94521  c9 cf a6
	jr z, .LF94533                                       ; F94524  66 0d
	ldw (UI_Request:16), 0x40a6                              ; F94526  f1 70 20 02 a6 40
	or	(UI_RequestBits:16), 0x80                            ; F9452C  c1 75 20 3e 80
	jr .LF94538                                          ; F94531  68 05
.LF94533:
	or	(UI_ScreenFlags:16), 0x10                            ; F94533  c1 95 20 3e 10
.LF94538:
	ret                                                  ; F94538  0e
; PartRecord_GetPtr -- XIY := the 64-byte RAM part record of part (0x2250)
; Evidence: L = (0x2250)*4, XIY = LE32 at 0xF2AB50 + L; prom_b's array there is 0x76A2 + 0x40*i with one 0x80 step, the same 32 bases as
; RecordPtrs_RAM76A2_Panel, and MidiOut_PartRecordPtrs_00 maps part k to the same records + 0x0D.  28 call sites, 0xF90E4B..0xF93A3C.
PartRecord_GetPtr:
	ld l, (UI_PartIndex:16)                                   ; F94539  c1 50 22 27
	sla l, 0x02                                          ; F9453D  cf ec 02
	xor H,H                                              ; F94540  ce d6
	ld XIY,0x00f2ab50                                    ; F94542  45 50 ab f2 00
	ld	xiy, (xiy+hl)                                ; F94547  e3 07 f4 ec 25
	ret                                                  ; F9454C  0e
; PartRecord_GetSecondHalfPtr -- XIY := part record of part (0x2250) + 0x20
; Evidence: the same shape as PartRecord_GetPtr against 0xF2ABD0, whose 32 words are the 0xF2AB50 array + 0x20 entry for entry (prom_b's own note).
; Callers then read (XIY+0x1B/0x1C/0x1D) = record +0x3B/+0x3C/+0x3D as group/member/bank (SoundGroup_LoadSelectionFromPart).
PartRecord_GetSecondHalfPtr:
	ld l, (UI_PartIndex:16)                                   ; F9454D  c1 50 22 27
	sla l, 0x02                                          ; F94551  cf ec 02
	xor H,H                                              ; F94554  ce d6
	ld XIY,0x00f2abd0                                    ; F94556  45 d0 ab f2 00
	ld	xiy, (xiy+hl)                                ; F9455B  e3 07 f4 ec 25
	ret                                                  ; F94560  0e
; Value_StepAndPostIfChanged -- step A by the encoded delta in W within [C, B]; if it changed, post {E, D, A, H} to the 0x2030 list
; Evidence: L = A, T_Value_ApplyNibbleDeltaClamped (sub_F8BD73: A + SignedNibbleDelta_Table[(W&0x0F)|((W&0x80)>>3)], clamped to C..B), `cp A,L / jr z`, then W = H and
; T_List2030_AppendRegs.  Callers: sub_F912A3, sub_F91356, sub_F92693, sub_F926C9.
Value_StepAndPostIfChanged:
	ld L,A                                               ; F94561  c9 8f
	push W                                               ; F94563  c8 04
	pushw hl                                             ; F94565  2b
	call T_Value_ApplyNibbleDeltaClamped                                        ; F94566  1d 04 1b f4
	popw hl                                              ; F9456A  4b
	pop W                                                ; F9456B  c8 05
	cp A,L                                               ; F9456D  cf f1
	jr z, .LF94577                                       ; F9456F  66 06
	ld W,H                                               ; F94571  ce 88
	call T_List2030_AppendRegs                           ; F94573  1d 40 0f f4
.LF94577:
	ret                                                  ; F94577  0e
; BitMask_LowestSetBitOrdinal_SaveC -- A := 1 + index of A's lowest set bit, 0 for 0; C preserved
; Evidence: `cps A,0 / jr z`, then C counts `srl A,1` until carry; identical to BitMask_LowestSetBitOrdinal (0xF95118) plus `push C / pop C`.
; Callers: ModeScreen_PaintDirtyFields2 (0xF90FF1, 0xF91072, 0xF910E6).
BitMask_LowestSetBitOrdinal_SaveC:
	cp a, 0x00:i3                                          ; F94578  c9 d8
	jr z, .LF9458B                                       ; F9457A  66 0f
	push C                                               ; F9457C  cb 04
	xor C,C                                              ; F9457E  cb d3
.LF94580:
	inc 1,C                                              ; F94580  cb 61
	srl a, 0x01                                          ; F94582  c9 ef 01
	jr nc, .LF94580                                      ; F94585  6f f9
	ld A,C                                               ; F94587  cb 89
	pop C                                                ; F94589  cb 05
.LF9458B:
	ret                                                  ; F9458B  0e
; LCD_BlitValueBar -- draw a 0..127 value as one of 17 bar frames at IX (current layer)
; Evidence: index = 0 for A = 0, else A/8 + 1 (so 1..127 -> frames 1..16); XIY = prom_b pointer table 0xF29BC6[index] (17 records of 0xE6 bytes, frame 0 blank,
; frame 16 full -- prom_b's note); SWI7 0x03 (LCD_Svc_03_BlitColumns) with BC = 5 columns, HL = 0x2E rows, 5 x 46 = 0xE6 exactly.  IX = the caller's.
; Callers: sub_F91BAE..sub_F91C64 (8), and T_LCD_BlitValueBar (prom_b 0xF4F00E, prom_a 0xF9C00E).
LCD_BlitValueBar:
	xor W,W                                              ; F9458C  c8 d0
	cp a, 0x00:i3                                          ; F9458E  c9 d8
	jr z, .LF9459C                                       ; F94590  66 0a
	div A,0x08                                           ; F94592  c9 0a 08
	xor W,W                                              ; F94595  c8 d0
	inc 1,WA                                             ; F94597  d8 61
	sll wa, 0x02                                         ; F94599  d8 ee 02
.LF9459C:
	ld XIY,0x00f29bc6                                    ; F9459C  45 c6 9b f2 00
	ld	xiy, (xiy+wa)                                ; F945A1  e3 07 f4 e0 25
	ldw bc, 0x05                                         ; F945A6  31 05 00
	ldw hl, 0x2e                                         ; F945A9  33 2e 00
	ld a, 0x03:opc                                          ; F945AC  21 03
	swi 7                                                ; F945AE  ff
	ret                                                  ; F945AF  0e
; Value_StepWordClamped -- DE := clamp(DE + delta(W), IY, IX), the 16-bit sibling of sub_F8BD73
; Evidence: index (W & 7) | ((W & 0x80) >> 4) into the 16 bytes at 0xF945E4 (0..7, then 0, -1..-7 -- framed as code after the `ret`), sign-extended and added
; to DE; a negative sum from a negative delta becomes 0; then max with IY, min with IX.  Callers: sub_F911EF (2), sub_F9242E (3).
Value_StepWordClamped:
	ld L,W                                               ; F945B0  c8 8f
	and L,0x07                                           ; F945B2  cf cc 07
	and W,0x80                                           ; F945B5  c8 cc 80
	srl w, 0x04                                          ; F945B8  c8 ef 04
	or W,L                                               ; F945BB  cf e0
	ld XHL,Value_StepWordClamped__F945E4                                    ; F945BD  43 e4 45 f9 00
	ld	l, (xhl+w)                                   ; F945C2  c3 03 ec e1 27
	exts HL                                              ; F945C7  db 13
	add DE,HL                                            ; F945C9  db 82
	bit 0x0f,DE                                          ; F945CB  da 33 0f
	jr z, .LF945D7                                       ; F945CE  66 07
	bit 0x0f,HL                                          ; F945D0  db 33 0f
	jr z, .LF945DD                                       ; F945D3  66 08
	xor DE,DE                                            ; F945D5  da d2
.LF945D7:
	cp DE,IY                                             ; F945D7  dd f2
	jr nc, .LF945DD                                      ; F945D9  6f 02
	ld DE,IY                                             ; F945DB  dd 8a
.LF945DD:
	cp DE,IX                                             ; F945DD  dc f2
	jr ule, .LF945E3                                     ; F945DF  63 02
	ld DE,IX                                             ; F945E1  dc 8a
.LF945E3:
	ret                                                  ; F945E3  0e
Value_StepWordClamped__F945E4:
	nop                                                  ; F945E4  00
	normal                                               ; F945E5  01
	push SR                                              ; F945E6  02
	pop SR                                               ; F945E7  03
	max                                                  ; F945E8  04
	halt                                                 ; F945E9  05
	ei 0x07                                              ; F945EA  06 07
	nop                                                  ; F945EC  00
	swi 7                                                ; F945ED  ff
	swi 6                                                ; F945EE  fe
	swi 5                                                ; F945EF  fd
	swi 4                                                ; F945F0  fc
	swi 3                                                ; F945F1  fb
	swi 2                                                ; F945F2  fa
	swi 1                                                ; F945F3  f9
; UiEventClass7A_QueueDialValueRedraw -- on a class-0x7A event with code 0 or 1, queue the redraw of the dial value
; Evidence: prom_b slot T_UiEventClass7A_QueueDialValueRedraw, entry [1] of UiListB_Class7A; class 0x7A is what PanelDial_PostClass7A posts for (0x7EE2).  (0x20B8) == 0 -> `jr z`
; to PanelDial_QueueValueRedraw_Entry; == 1 falls into it; anything else returns.
UiEventClass7A_QueueDialValueRedraw:
	ld a, (UiEvent_Byte1:16)                                   ; F945F4  c1 b8 20 21
	cp a, 0x00:i3                                          ; F945F8  c9 d8
	jr z, PanelDial_QueueValueRedraw_Entry                                     ; F945FA  66 04
	cp a, 0x01:i3                                          ; F945FC  c9 d9
	jr NZ,.LF94603                                       ; F945FE  6e 03
; PanelDial_QueueValueRedraw_Entry -- a PURE WRAPPER for PanelDial_QueueValueRedraw (`calr 0xF94604 / ret`)
; Evidence: published as T_PanelDial_QueueValueRedraw_Entry (called from prom_b 0xF55CAE and 0xF55D5F) and reached from UiEventClass7A_QueueDialValueRedraw.
PanelDial_QueueValueRedraw_Entry:
	calr PanelDial_QueueValueRedraw                                      ; F94600  1e 01 00
.LF94603:
	ret                                                  ; F94603  0e
; PanelDial_QueueValueRedraw -- queue PanelDial_DrawValueDigits on the callback queue when (0x97) bit 1 is set
; Evidence: `bit 1,(0x97) / jr z`, then `ld XWA,0xF9461C / push / call T_CallbackQueue_Post` and T_Kernel_SemaSignal with A = 1 -- the queueing idiom
; the InstallPainter_* routines use.  Only caller PanelDial_QueueValueRedraw_Entry.
PanelDial_QueueValueRedraw:
	bit	1, (0x97:8)                                   ; F94604  f0 97 c9
	jr z, .LF9461B                                       ; F94607  66 12
	ld XWA,PanelDial_DrawValueDigits                                    ; F94609  40 1c 46 f9 00
	push XWA                                             ; F9460E  38
	call T_CallbackQueue_Post                            ; F9460F  1d 84 2e f4
	inc 4,XSP                                            ; F94613  ef 64
	ld a, 0x01:opc                                          ; F94615  21 01
	call T_Kernel_SemaSignal                             ; F94617  1d 88 2d f4
.LF9461B:
	ret                                                  ; F9461B  0e
; PanelDial_DrawValueDigits -- draw the dial value (0x7EE2) as three 16x16 digits on screen 0x06 or 0x12
; Evidence: A = (0x7EE2), W = (0x7EE3) & 1 (the 9-bit value PanelDial_ApplyStep steps), T_Value_ToAsciiDigits3_RightJustified = sub_F8BCAF (Value_ToAsciiDigits3 into 0x2661..0x2663,
; leading digits blanked); IX = 0x1281 on screen 0x06, 0x1079 on 0x12, else nothing; layer 0, "---" when (0x7F32) bit 2; SWI7 0x08
; (LCD_Svc_08_DrawText16x16) of BC = 3 characters from 0x2661.  Queued by PanelDial_QueueValueRedraw.
PanelDial_DrawValueDigits:   ; entry: named by 1 `ld` operand, first at 0xF94609
	ld XIY,0x00007ee2                                    ; F9461C  45 e2 7e 00 00
	ld	a, (xiy+0:8)                                 ; F94621  8d 00 21
	ld W,(XIY+0x01)                                      ; F94624  8d 01 20
	and W,0x01                                           ; F94627  c8 cc 01
	call T_Value_ToAsciiDigits3_RightJustified                                        ; F9462A  1d f0 1a f4
	ld a, (UI_ScreenId:16)                                   ; F9462E  c1 7c 20 21
	cp a, 0x06:i3                                          ; F94632  c9 de
	jr nz, .LF9463D                                      ; F94634  6e 07
	ldw ix, 0x1281                                       ; F94636  34 81 12
	ld a, 0x08:opc                                          ; F94639  21 08
	jr .LF94649                                          ; F9463B  68 0c
.LF9463D:
	cp A,0x12                                            ; F9463D  c9 cf 12
	jr nz, .LF9466A                                      ; F94640  6e 28
	ldw ix, 0x1079                                       ; F94642  34 79 10
	ld a, 0x08:opc                                          ; F94645  21 08
	jr .LF94649                                          ; F94647  68 00
.LF94649:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F94649  f1 40 25 00 00
	bit	2, (MidiCfg_ModeBits:16)                               ; F9464E  f1 32 7f ca
	jr z, .LF9465F                                       ; F94652  66 0b
	ldw (Value_AsciiDigits:16), 0x2d2d                              ; F94654  f1 61 26 02 2d 2d
	ld (Value_AsciiDigits+2:16), 0x2d                                 ; F9465A  f1 63 26 00 2d
.LF9465F:
	ld XIY,Value_AsciiDigits                                    ; F9465F  45 61 26 00 00
	xor HL,HL                                            ; F94664  db d3
	ldw bc, 0x03                                         ; F94666  31 03 00
	swi 7                                                ; F94669  ff
.LF9466A:
	ret                                                  ; F9466A  0e

; 0xF9466B-0xF94BFF -- 1429 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 1429, 1, 0x0E
