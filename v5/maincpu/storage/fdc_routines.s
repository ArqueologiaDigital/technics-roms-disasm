; =============================================================================
; fdc_routines.asm - Floppy Disk Controller Routines
; =============================================================================
; This file contains all FDC (Floppy Disk Controller) routines for the KN5000.
;
; The KN5000 uses a standard PC-compatible FDC for its 3.5" floppy drive.
; These routines handle:
;   - Low-level FDC register access (read/write status, data)
;   - DMA setup for disk transfers
;   - Command dispatching and execution
;   - Format parameter configuration
;   - Drive detection and status
;
; Address range: 0xf96d54 - 0xf98009
;
; Dependencies:
;   - fdc_constants.asm must be included before this file
;   - Requires FDC_MAP__BASE_ADDR and FDC__DMA_ACKNOWLEDGE
; =============================================================================

FDC_Read_Status:	.include "includes/generated/cc900/FDC_Read_Status.s"	; C: cc900/fdc_routines_m270.c

FDC_ReadDataRegister:	.include "includes/generated/cc900/FDC_ReadDataRegister.s"	; C: cc900/fdc_routines_m270.c

; --- FDC_Send_Command: Write command byte to FDC data register ---
; Stores accumulator A to FDC data port (0x110008),
; waits for FDC ready via status register polling,
; then returns. Uses (R+d16) addressing for FDC port access.
FDC_Send_Command:	.include "includes/generated/cc900/FDC_Send_Command.s"	; C: cc900/fdc_routines_m270_b.c
FDC_Write_Data_Entry_Helper:
	ldmm8	0x8a68, 0x8a6a
	ld	(0x8a6a:16), a
	ret
; FDC_WriteDataRegister: Writes A to the uPD72068 data register (0x11000A): command and parameter bytes. Basis:
;   callers + body -- FDC_SendCommandByte, FDC_SendParameterByte, INT4_SendSpecifyCmd and FDC_CONFIG_VERIFY call it.
FDC_WriteDataRegister:	.include "includes/generated/cc900/FDC_WriteDataRegister.s"	; C: cc900/fdc_routines_m270_c.c

; --- FDC_WaitReady: Wait for FDC ready with timeout and DMA transfer ---
; Two-phase wait loop (masks 0x1f and 0x90) checking FDC status register.
; Uses prevbank (D7 FA) for timeout flag management.
; Contains 7-entry command dispatch (commands 0-5 + default):
;   Each entry: stdi8 35436, N; calr <handler>; stdi16 35362, 0
; Handles DMA channel setup, result status checking, and retry logic.
; Timeout limit: 500 timer ticks (checked against timer at address 1033).
; Uses (R+d16) addressing extensively for FDC port and state variable access.
FDC_WaitReady:
	push XIZ
	ld iz, (SYSTEM_TIMESTAMP:16)
	ldw QIZ, 0x0080
	cpw QIZ, 0x0080
	jr nz, .Lc_f96763
.Lc_f9673a:
FDC_WaitReady_Loop:
	calr FDC_Read_Status
	and L,0x1f
	ld A,L
	extz WA
	cp wa, 0:i3
	jr nz, .Lc_f9674b
	ld QIZ,0
.Lc_f9674b:
FDC_WaitReady_Skip:
	ld wa, (SYSTEM_TIMESTAMP:16)
	sub WA,IZ
	cp WA,0x01f4
	jr ule, .Lc_f9675c
	ldw QIZ, 0xffff
.Lc_f9675c:
FDC_WaitReady_Skip2:
	cpw QIZ, 0x0080
	jr z, .Lc_f9673a
.Lc_f96763:
FDC_WaitReady_Skip3:
	cp QIZ,0
	jr z, .Lc_f9676d
	ld wa, 1:i3
	calr FDC_Set_Status
.Lc_f9676d:
FDC_WaitReady_Epilogue:
	pop XIZ
	ret
; FDC_WaitParamByteReady: Waits until the uPD72068 main status register (0x110008) shows RQM|CB (mask 0x90 = 0x90: a
;   command is in progress and the FDC requests the next byte); after 500 ticks of SYSTEM_TIMESTAMP it gives up and
;   records status 1 (FDC_Set_Status). Basis: callers + body + twin -- FDC_SendParameterByte calls it before writing
;   each parameter byte to the data register; the bootloader twin is FDC_WaitComplete (table_data, header 'Wait for
;   the FDC parameter phase'), called by the bootloader's FDC_SendParameterByte.
FDC_WaitParamByteReady:	.include "includes/generated/cc900/FDC_WaitParamByteReady.s"	; C: cc900/fdc_routines_m270_xr_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	FDC_WaitParamByteReady_Loop2, FDC_WaitParamByteReady + 17
	.set	FDC_WaitParamByteReady_Skip4, FDC_WaitParamByteReady + 31
	.set	FDC_WaitParamByteReady_Skip5, FDC_WaitParamByteReady + 48
	.set	FDC_WaitParamByteReady_Skip6, FDC_WaitParamByteReady + 55
	.set	FDC_WaitParamByteReady_Epilogue2, FDC_WaitParamByteReady + 65
FDC_INIT:	.include "includes/generated/cc900/FDC_INIT.s"	; C: cc900/fdc_routines_m270.c
FDC_CONFIG_VERIFY:
	push	xiz
	calr	FDC_ClearStatus_InitTimer
	calr	FDC_DRIVE_DETECT
	cp	hl, 0xffff
	jr	z, FDC_CONFIG_VERIFY_Skip
	calr	FDC_DRIVE_STATUS
	cp	hl, 0xffff
	jr	z, FDC_CONFIG_VERIFY_Skip
	ld	(FDC_CURRENT_CYLINDER:16), 255
FDC_CONFIG_VERIFY_Skip:
	cp	(FDC_INIT_FLAG:16), 255
	jrl	z, FDC_WaitReady_Epilogue3
	ld	(FDC_INIT_FLAG:16), 255
	ldw	wa, 54
	calr	FDC_Send_Command
	ld	wa, 2:i3
	calr	SOME_DELAY
	calr	FDC_DRIVE_DETECT
	cp	hl, 0xffff
	jr	z, FDC_CONFIG_VERIFY_Skip2
	calr	FDC_DRIVE_STATUS
	cp	hl, 0xffff
	jr	z, FDC_CONFIG_VERIFY_Skip2
	calr	FDC_ClearStatus_InitTimer
	calr	FDC_CMD_DISPATCH_SUB
	cp	(FDC_ERROR_CODE:16), 0
	jr	z, FDC_CONFIG_VERIFY_Loop3
	ld	(FDC_INIT_FLAG:16), 0
	jrl	FDC_WaitReady_Epilogue3
FDC_CONFIG_VERIFY_Loop3:
	calr	FDC_Read_Status
	bit	7, l
	jr	z, FDC_CONFIG_VERIFY_Loop3
	calr	FDC_Read_Status
	bit	6, l
	jr	nz, FDC_WaitReady_Skip8
	ld	l, 0:opc
	cp	l, 128
	jr	z, FDC_WaitReady_Skip7
FDC_CONFIG_VERIFY_Loop4:
	calr	FDC_Read_Status
	and	l, 240
	cp	l, 128
	jr	nz, FDC_CONFIG_VERIFY_Loop4
FDC_WaitReady_Skip7:
	ldw	wa, 8
	calr	FDC_WriteDataRegister
FDC_WaitReady_Skip8:
	lda	xiz, (FDC_RESULT:16)
	inc	1, xiz
FDC_CONFIG_VERIFY_Loop5:
	calr	FDC_Wait_Ready_Timeout
	calr	FDC_ReadDataRegister
	ld	(xiz+), l
FDC_CONFIG_VERIFY_Loop6:
	calr	FDC_Read_Status
	bit	7, l
	jr	z, FDC_CONFIG_VERIFY_Loop6
	calr	FDC_Read_Status
	bit	6, l
	jr	nz, FDC_CONFIG_VERIFY_Loop5
	calr	FDC_Exception_Status_Decoder
	cp	(0x89a9:16), 128
	jr	nz, FDC_CONFIG_VERIFY_Loop3
FDC_CONFIG_VERIFY_Skip2:
	ld	wa, 3:i3
	calr	FDC_CMD_SEND
	cp	(FDC_ERROR_CODE:16), 0
	jr	z, FDC_WaitReady_Skip9
	ld	(FDC_INIT_FLAG:16), 0
	jrl	FDC_WaitReady_Epilogue3
FDC_WaitReady_Skip9:
	ldw	wa, 79
	calr	FDC_CMD_SEND
	cp	(FDC_ERROR_CODE:16), 0
	jr	z, FDC_WaitReady_Skip10
	ld	(FDC_INIT_FLAG:16), 0
	jrl	FDC_WaitReady_Epilogue3
FDC_WaitReady_Skip10:
	ld	a, (0x89b6:16)
	and	a, 15
	extz	wa
	cp	wa, 0:i3
	jrl	mi, FDC_WaitReady_Skip11
	cp	wa, 5:i3
	jrl	gt, FDC_WaitReady_Skip11
	add	wa, wa
	lda	xix, (FDC_WaitReady_CaseTable:24)
	ld	wa, (xix+wa)
	lda	xix, (FDC_CONFIG_VERIFY_Code:24)
	jp	t, (xix+wa)
FDC_CONFIG_VERIFY_Code:
	ld	(FDC_DRIVE_MODE:16), 0
	ldw	(0x896a:16), 0
	ldib_erp	251, 0
	ld	wa, 2:i3
	calr	FDC_Write_Data_Entry_Helper
	jr	FDC_WaitReady_Join
FDC_CONFIG_VERIFY_Case1:
	ld	(FDC_DRIVE_MODE:16), 0
	ldw	(0x896a:16), 0
	ldi_erpb	251, 192
	ld	wa, 2:i3
	calr	FDC_Write_Data_Entry_Helper
	jr	FDC_WaitReady_Join
FDC_CONFIG_VERIFY_Case2:
	ld	(FDC_DRIVE_MODE:16), 2
	ldw	(0x896a:16), 0
	ldi_erpb	251, 64
	ld	wa, 0:i3
	calr	FDC_Write_Data_Entry_Helper
	jr	FDC_WaitReady_Join
FDC_CONFIG_VERIFY_Case3:
	ld	(FDC_DRIVE_MODE:16), 3
	ldw	(0x896a:16), 0
	ldi_erpb	251, 64
	ld	wa, 0:i3
	calr	FDC_Write_Data_Entry_Helper
	jr	FDC_WaitReady_Join
FDC_CONFIG_VERIFY_Case4:
	ld	(FDC_DRIVE_MODE:16), 4
	ldw	(0x896a:16), 0
	ldib_erp	251, 0
	ld	wa, 2:i3
	calr	FDC_Write_Data_Entry_Helper
	jr	FDC_WaitReady_Join
FDC_CONFIG_VERIFY_Case5:
	ld	(FDC_DRIVE_MODE:16), 5
	ldw	(0x896a:16), 0
	ldib_erp	251, 0
	ld	wa, 2:i3
	calr	FDC_Write_Data_Entry_Helper
	jr	FDC_WaitReady_Join
FDC_WaitReady_Skip11:
	ld	(FDC_DRIVE_MODE:16), 0
	ldw	(0x896a:16), 0
	ldib_erp	251, 0
	ld	wa, 2:i3
	calr	FDC_Write_Data_Entry_Helper
FDC_WaitReady_Join:
	ldto_berp	a, 251
	or	a, 11
	extz	wa
	calr	FDC_CMD_SEND
	cp	(FDC_ERROR_CODE:16), 0
	jr	z, FDC_WaitReady_Skip12
	ld	(FDC_INIT_FLAG:16), 0
	jr	FDC_WaitReady_Epilogue3
FDC_WaitReady_Skip12:
	calr	FDC_CMD_ENABLE
	cp	(FDC_ERROR_CODE:16), 0
	jr	z, FDC_WaitReady_Skip13
	ld	(FDC_INIT_FLAG:16), 0
	jr	FDC_WaitReady_Epilogue3
FDC_WaitReady_Skip13:
	calr	FDC_CmdRecalibrate
	ld	(FDC_INIT_FLAG:16), 0
FDC_WaitReady_Epilogue3:
	pop	xiz
	ret
FDC_CMD_DISPATCH_SUB:
	ldw WA, 0x0036
	calr FDC_Send_Command
	ld wa, 2:i3
	calr SOME_DELAY
	calr FDC_Read_Status
	cp L,0xff
	jr nz, .Lc_f969a1
	ldw WA, 0x00fc
	calr FDC_Set_Status
.Lc_f969a1:
	ld hl, 0:i3
	ret
; FDC command dispatcher
; Reads command from (89A4h), dispatches to 12 handlers (0-0xb)
; Uses offset table at 0xea98b2
FDC_COMMAND_DISPATCHER:
	ld	(FDC_DRIVE:16), 0
	ld	wa, (FDC_COMMAND_INDEX:16)
	cp	wa, 11
	jr	ugt, FDC_CheckDriveCount	; -> 0xF969D7
	add	wa, wa
	lda	xix, (FDC_COMMAND_DISPATCHER_CaseTable:24)
	ld	wa, (xix+wa)
	lda	xix, (FDC_CMD_HANDLER_BASE:24)
	jp	t, (xix+wa)
; FDC command handler base - entry point for command 0
FDC_CMD_HANDLER_BASE:
	calr	FDC_SetupFormatParams
	ld	l, (FDC_ERROR_CODE:16)
	ret
FDC_ReturnZero:
	ld l, 0x0:opc
	ret

FDC_ErrorInvalidDrive:
	calr FDC_Validate_Drive_Head

FDC_CheckDriveCount:
	ld	wa, (FDC_REQ_DRIVE:16)
	ld	(FDC_DRIVE:16), a
	cp	(FDC_DRIVE:16), 1
	jr	ule, FDC_ValidateCommand
	ldw	wa, 254
	jrl	FDC_Set_Status
FDC_ValidateCommand:
	ld	wa, (FDC_COMMAND_INDEX:16)
	cp	wa, 4:i3
	jr	z, FDC_ValidateTrack
	cp	wa, 3:i3
	jr	z, FDC_ValidateTrack
	cp	wa, 2:i3
	jr	z, FDC_ValidateTrack
	cp	wa, 5:i3
	jr	z, FDC_Command5Handler
	cp	wa, 11
	jr	z, FDC_NoOpReturn
	cp	wa, 1:i3
	jr	nz, FDC_ValidateTrack
FDC_NoOpReturn:
	ld l, 0x0:opc
	ret

FDC_Command5Handler:
	calr	FDC_Command5_Epilogue
	ld	l, (FDC_ERROR_CODE:16)
	ret
FDC_ValidateTrack:
	ld	wa, (FDC_REQ_TRACK:16)
	ld	(FDC_PARAM_C:16), a
	ld	(FDC_TARGET_TRACK:16), a
	extz	wa
	cp	wa, (35408:16)
	jr	c, FDC_HandleCmd2	; -> 0xF96A2F
	ldw	wa, 254
	jrl	FDC_Set_Status	; -> 0xF971A0
FDC_HandleCmd2:
	cpw	(FDC_COMMAND_INDEX:16), 2
	jr	nz, FDC_CheckSectorCount
	calr	FDC_CheckHead
	ld	l, (FDC_ERROR_CODE:16)
	ret
FDC_CheckSectorCount:
	cpw	(FDC_REQ_COUNT:16), 0
	jr	nz, FDC_CheckSectorNum
	ldw	wa, 0xfe
	jrl	FDC_Set_Status
FDC_CheckSectorNum:
	ld	wa, (FDC_REQ_SECTOR:16)
	ld	(FDC_PARAM_R:16), a
	cp	(FDC_PARAM_R:16), 0
	jr	nz, FDC_CheckFormatType
	ldw	wa, 0xfe
	jrl	FDC_Set_Status
FDC_CheckFormatType:
	ld	a, (FDC_DRIVE_MODE:16)
	cp	a, 0:i3
	jr	z, FDC_FormatDefault
	cp	a, 5:i3
	jr	z, FDC_FormatDefault
	cp	a, 4:i3
	jr	z, FDC_FormatType4
	cp	a, 3:i3
	jr	z, FDC_FormatType3
	cp	a, 2:i3
	jr	nz, FDC_ErrorInvalid
	cp	(FDC_PARAM_R:16), 8
	jr	ule, FDC_ValidExecute
	ldw	wa, 0xfe
	jrl	FDC_Set_Status
FDC_FormatType3:
	cp	(FDC_PARAM_R:16), 18
	jr	ule, FDC_ValidExecute
	ldw	wa, 0xfe
	jrl	FDC_Set_Status
FDC_FormatType4:
	cp	(FDC_PARAM_R:16), 255
	jr	nz, FDC_Format4Check
	calr	FDC_CheckHead
	ld	l, (FDC_ERROR_CODE:16)
	ret
FDC_Format4Check:
	cp	(FDC_PARAM_R:16), 9
	jr	ule, FDC_ValidExecute
	ldw	wa, 0xfe
	jrl	FDC_Set_Status
FDC_FormatDefault:
	cp	(FDC_PARAM_R:16), 9
	jr	ule, FDC_ValidExecute
	ldw	wa, 0xfe
	jrl	FDC_Set_Status
FDC_ErrorInvalid:
	ldw wa, 0xfe
	jrl FDC_Set_Status

FDC_ValidExecute:
	calr	FDC_CheckHead
	ld	l, (FDC_ERROR_CODE:16)
	ret
FDC_SetupFormatParams:
	ld	wa, (FDC_REQ_TRACK:16)
	ld	(35254:16), a
	and	a, 15
	cp	a, 3:i3
	jrl	z, FDC_Format1440K
	cp	a, 2:i3
	jr	z, FDC_FormatDD
	cp	a, 5:i3
	jr	z, FDC_FormatHD
	cp	a, 4:i3
	jr	z, FDC_FormatHD
	cp	a, 0:i3
	jrl	nz, FDC_FormatUnknown
FDC_FormatHD:
	ld	(FDC_PARAM_N:16), 2
	ld	(FDC_PARAM_STP:16), 1
	ld	(FDC_PARAM_EOT:16), 9
	ld	(FDC_FORMAT_SC:16), 9
	ld	(FDC_PARAM_GPL:16), 27
	ld	(FDC_FORMAT_GPL:16), 84
	ldw	(35406:16), 79
	ldw	(35408:16), 80
	ldw	(35410:16), 9
	ldw	(FDC_SECTOR_LIMIT:16), 10
	jr	FDC_InitStateVars
FDC_FormatDD:
	ld	(FDC_PARAM_N:16), 3
	ld	(FDC_PARAM_STP:16), 1
	ld	(FDC_PARAM_EOT:16), 8
	ld	(FDC_FORMAT_SC:16), 8
	ld	(FDC_PARAM_GPL:16), 83
	ld	(FDC_FORMAT_GPL:16), 116
	ldw	(35406:16), 76
	ldw	(35408:16), 77
	ldw	(35410:16), 8
	ldw	(FDC_SECTOR_LIMIT:16), 9
	jr	FDC_InitStateVars
FDC_Format1440K:
	ld	(FDC_PARAM_N:16), 2
	ld	(FDC_PARAM_STP:16), 1
	ld	(FDC_PARAM_EOT:16), 18
	ld	(FDC_FORMAT_SC:16), 18
	ld	(FDC_PARAM_GPL:16), 27
	ld	(FDC_FORMAT_GPL:16), 108
	ldw	(35406:16), 79
	ldw	(35408:16), 80
	ldw	(35410:16), 18
	ldw	(FDC_SECTOR_LIMIT:16), 19
	jr	FDC_InitStateVars
FDC_FormatUnknown:
	ldw wa, 0xfe
	calr FDC_Set_Status

FDC_InitStateVars:	.include "includes/generated/cc900/FDC_InitStateVars.s"	; C: cc900/fdc_routines_m0.c
FDC_CheckHead:	.include "includes/generated/cc900/FDC_CheckHead.s"	; C: cc900/fdc_routines_m270_xr.c
FDC_Command5_Epilogue:
	ret
FDC_Validate_Drive_Head:	.include "includes/generated/cc900/FDC_Validate_Drive_Head.s"	; C: cc900/fdc_routines_m270_xr.c





FDC_NOP_Delay:
	dec 2, xsp
	ld (xsp), a
	ld a, (xsp)
	decm8 1, (xsp)
	cp a, 0:i3
	jr z, FDC_NOP_Delay_Exit

FDC_NOP_Delay_Loop:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld a, (xsp)
	decm8 1, (xsp)
	cp a, 0:i3
	jr nz, FDC_NOP_Delay_Loop

FDC_NOP_Delay_Exit:
	inc 2, xsp
	ret


FDC_Pulse_PH0:	.include "includes/generated/cc900/FDC_Pulse_PH0.s"	; C: cc900/fdc_routines_m270.c


FDC_Init_Sequence_1:
	jr	FDC_Port_Reset_Or_Noop


FDC_Port_Reset_Or_Noop:
	ret


FDC_Setup_DMA_Mode:
	ld	bc, (FDC_SECTOR_COUNT:16)
	ldc_cr16	bc, 0x4c
	ld	a, (FDC_CMD_OPCODE:16)
	cp	a, 0x4d
	jr	z, FDC_Setup_DMA_Read_Mode
	cp	a, 0xc9
	jr	z, FDC_Setup_DMA_Read_Mode
	cp	a, 0xc5
	jr	z, FDC_Setup_DMA_Read_Mode
	cp	a, 0xdd
	jr	z, FDC_Setup_DMA_Write_Mode
	cp	a, 0xd9
	jr	z, FDC_Setup_DMA_Write_Mode
	cp	a, 0xd1
	jr	z, FDC_Setup_DMA_Write_Mode
	cp	a, 0x4a
	jr	z, FDC_Setup_DMA_Write_Mode
	cp	a, 0x42
	jr	z, FDC_Setup_DMA_Write_Mode
	cp	a, 0xcc
	jr	z, FDC_Setup_DMA_Write_Mode
	cp	a, 0xc6
	ret	nz
FDC_Setup_DMA_Write_Mode:
	jr FDC_Setup_DMA_Ack_Dest

FDC_Setup_DMA_Read_Mode:
	calr FDC_Setup_DMA_Src_Ack

FDC_DMA_Setup_Exit:
	ret

FDC_Setup_DMA_Ack_Dest:
	ld	xhl, 0x120000
	ldc_cr32	xhl, 0x0c
	ld	xhl, (FDC_REQ_BUFFER:16)
	ldc_cr32	xhl, 0x2c
	ld	a, 0x0:opc
	ldc_cr8	a, 0x4e
	jr	FDC_Port_Reset_Or_Noop
FDC_Setup_DMA_Src_Ack:
	ld	xhl, (FDC_REQ_BUFFER:16)
	ldc_cr32	xhl, 0x0c
	ld	xhl, 0x120000
	ldc_cr32	xhl, 0x2c
	ld	a, 0x8:opc
	ldc_cr8	a, 0x4e
	jr	FDC_Port_Reset_Or_Noop
FDC_MC_EXIT_Code_Helper:
	ld	bc, (FDC_SECTOR_COUNT:16)
	ldc_cr16	bc, 0x4c
	ret
FDC_Wait_Ready_Timeout:
	push xiz
	ld iz, (SYSTEM_TIMESTAMP:16)
	ldi_erpw 0xfa, 0x80, 0x00
	cp_erpw 0xfa, 0x80, 0x00
	jr nz, FDC_WaitReady_TimedOut

FDC_WaitReady_StatusLoop:
	calr FDC_Read_Status
	res 4, l
	ld a, l
	cp a, 0x80
	jr z, FDC_WaitReady_TimeoutCheck
	cp a, 0xc0
	jr nz, FDC_WaitReady_TimeoutCheck
	ldiw_erp 0xfa, 0

FDC_WaitReady_TimeoutCheck:
	ld wa, (SYSTEM_TIMESTAMP:16)
	sub wa, iz
	cp wa, 0x1f4
	jr ule, FDC_WaitReady_LoopContinue
	ldi_erpw 0xfa, 0xff, 0xff

FDC_WaitReady_LoopContinue:
	cp_erpw 0xfa, 0x80, 0x00
	jr z, FDC_WaitReady_StatusLoop

FDC_WaitReady_TimedOut:
	cpiw_erp 0xfa, 0
	jr z, FDC_WaitReady_Complete
	ld wa, 2:i3
	calr FDC_Set_Status

FDC_WaitReady_Complete:
	pop xiz
	ret


FDC_Wait_Status_Timeout:
	push xiz
	ld iz, (SYSTEM_TIMESTAMP:16)
	ldi_erpw 0xfa, 0x80, 0x00
	cp_erpw 0xfa, 0x80, 0x00
	jr nz, FDC_WaitStatus_TimedOut

FDC_WaitStatus_StatusLoop:
	calr FDC_Read_Status
	and l, 0xe0
	cp l, 0x80
	jr z, FDC_WaitStatus_CheckTimeout
	cp l, 0xc0
	jr nz, FDC_WaitStatus_CheckTimeout
	ldiw_erp 0xfa, 0

FDC_WaitStatus_CheckTimeout:
	ld wa, (SYSTEM_TIMESTAMP:16)
	sub wa, iz
	cp wa, 0x1f4
	jr ule, FDC_WaitStatus_TimeoutCheck
	ldi_erpw 0xfa, 0xff, 0xff

FDC_WaitStatus_TimeoutCheck:
	cp_erpw 0xfa, 0x80, 0x00
	jr z, FDC_WaitStatus_StatusLoop

FDC_WaitStatus_TimedOut:
	cpiw_erp 0xfa, 0
	jr z, FDC_WaitStatus_Complete
	ld wa, 2:i3
	calr FDC_Set_Status

FDC_WaitStatus_Complete:
	pop xiz
	ret


; --- FDC_ResultPhase_Read: Read FDC result phase data into buffer ---
; Reads FDC status register in a loop, checking top 2 bits:
;   0xc0 = command complete, 0x80 = data ready for transfer.
; When data ready, reads byte from FDC and stores to buffer at 35424[index].
; Includes timeout checking against timer at address 1033.
; Contains 6 parameter-passing wrapper stubs at the end, each:
;   dec 2,xsp / ld (xsp),a / calr <func> / ld a,(xsp) / extz wa /
;   calr <store> / inc 2,xsp / ret
; Uses (R+d16) and dec/inc xsp addressing (not in LLVM).
FDC_ResultPhase_Read:
; [v10] --- FDC_ResultPhase_Read: Read FDC result phase data into buffer ---
; [v10] Reads FDC status register in a loop, checking top 2 bits:
; [v10] 0xc0 = command complete, 0x80 = data ready for transfer.
; [v10] When data ready, reads byte from FDC and stores to buffer at 35424[index].
; [v10] Includes timeout checking against timer at address 1033.
; [v10] Contains 6 parameter-passing wrapper stubs at the end, each:
; [v10] dec 2,xsp / ld (xsp),a / calr <func> / ld a,(xsp) / extz wa /
; [v10] calr <store> / inc 2,xsp / ret
; [v10] Uses (R+d16) and dec/inc xsp addressing (not in LLVM).
	dec	2, xsp
	push	xiz
	ldw	(xsp+0x4), (SYSTEM_TIMESTAMP)
	ldw	qiz, 128
	cpw	qiz, 128
	jr	nz, FDC_ResultPhase_Read_Skip2
FDC_ResultPhase_Read_Loop:
	calr	FDC_Read_Status
	res	4, l
	ld	a, l
	cp	a, 192
	jr	z, FDC_ResultPhase_Read_Skip
	cp	a, 128
	jr	nz, FDC_ResultPhase_Read_Join
	ld	qiz, 0
	jr	FDC_ResultPhase_Read_Join
FDC_ResultPhase_Read_Skip:
	ld	iz, 1:i3
	ld	qiz, 0
	cp	qiz, 0
	jr	nz, FDC_ResultPhase_Read_Join
FDC_ResultPhase_Read_Loop2:
	calr	FDC_ReadDataRegister
	lda	xwa, (FDC_RESULT:16)
	ld	bc, iz
	extz	xbc
	add	xbc, xwa
	ld	(xbc), l
	calr	FDC_Read_Status
	inc	1, iz
	cp	qiz, 0
	jr	z, FDC_ResultPhase_Read_Loop2
FDC_ResultPhase_Read_Join:
	ld	wa, (SYSTEM_TIMESTAMP:16)
	sub	wa, (xsp+0x4)
	cp	wa, 0x1f4
	jr	ule, FDC_ResultPhase_Read_Skip3
	ldw	qiz, 65535
FDC_ResultPhase_Read_Skip3:
	cpw	qiz, 128
	jr	z, FDC_ResultPhase_Read_Loop
FDC_ResultPhase_Read_Skip2:
	cp	qiz, 0
	jr	z, FDC_ResultPhase_Read_Epilogue3
	ld	wa, 3:i3
	calr	FDC_Set_Status
FDC_ResultPhase_Read_Epilogue3:
	pop	xiz
	inc	2, xsp
	ret
; FDC_SendCommandByte: Drains any pending result phase (FDC_ResultPhase_Read) and writes A to the uPD72068 data
;   register 0x11000A -- the first byte of a uPD765-style command. Basis: callers + body + twin -- FDC_CMD_SEND sends
;   every non-auxiliary opcode through it before the parameter bytes; bootloader twin FDC_SendCommandByte.
FDC_SendCommandByte:	.include "includes/generated/cc900/FDC_SendCommandByte.s"	; C: cc900/fdc_routines_m270.c
; FDC_SendParameterByte: Waits (500-tick timeout, status 1) until the main status register shows RQM|CB (0x90) and
;   writes A to the data register 0x11000A -- one command parameter byte. Basis: callers + body + twin -- FDC_CMD_SEND
;   sends the unit/head byte through it and the SPECIFY / SEEK / FORMAT / READ-WRITE parameter senders call it once
;   per byte; bootloader twin FDC_SendParameterByte.
FDC_SendParameterByte:	.include "includes/generated/cc900/FDC_SendParameterByte.s"	; C: cc900/fdc_routines_m270_b.c
FDC_WriteAuxCmdByte:	.include "includes/generated/cc900/FDC_WriteAuxCmdByte.s"	; C: cc900/fdc_routines_m270_c.c
FDC_SendAuxCmd:
	dec	2, xsp
	ld	(xsp), a
	calr	FDC_ResultPhase_Read
	cp	(FDC_ERROR_CODE:16), 0
	jr	nz, FDC_ResultPhase_Read_Epilogue
	ld	a, (xsp)
	extz	wa
	calr	FDC_WriteAuxCmdByte
FDC_ResultPhase_Read_Epilogue:
	inc	2, xsp
	ret
FDC_SendAuxCmdReadResult:
	dec	2, xsp
	ld	(xsp), a
	calr	FDC_ResultPhase_Read
	cp	(FDC_ERROR_CODE:16), 0
	jr	nz, FDC_ResultPhase_Read_Epilogue2
	ld	a, (xsp)
	extz	wa
	calr	FDC_WriteAuxCmdByte
	calr	FDC_Wait_Ready_Timeout
	calr	FDC_ReadDataRegister
	ld	(0x89a9:16), l
FDC_ResultPhase_Read_Epilogue2:
	inc	2, xsp
	ret
FDC_Exception_Status_Decoder:	.include "includes/generated/cc900/FDC_Exception_Status_Decoder.s"	; C: cc900/fdc_routines_m270_xr.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	FDC_StatusDecode_DriveNotReady, FDC_Exception_Status_Decoder + 34
	.set	FDC_StatusDecode_InvalidCommand, FDC_Exception_Status_Decoder + 42
	.set	FDC_StatusDecode_AbnormalTerm, FDC_Exception_Status_Decoder + 45
	.set	FDC_StatusDecode_Overrun, FDC_Exception_Status_Decoder + 53
	.set	FDC_StatusDecode_CheckST2, FDC_Exception_Status_Decoder + 61
	.set	FDC_StatusDecode_BadCylinder, FDC_Exception_Status_Decoder + 75
	.set	FDC_StatusDecode_WrongCylinder, FDC_Exception_Status_Decoder + 86
	.set	FDC_StatusDecode_ScanEqual, FDC_Exception_Status_Decoder + 97
	.set	FDC_StatusDecode_DataFieldError, FDC_Exception_Status_Decoder + 108
	.set	FDC_StatusDecode_ControlMark, FDC_Exception_Status_Decoder + 119
	.set	FDC_StatusDecode_DefaultError, FDC_Exception_Status_Decoder + 130
	.set	FDC_StatusDecode_UnknownIC, FDC_Exception_Status_Decoder + 136


;==================== (guessed) start of floppy routines =======================


; --- FDC_HardwareSetup: Configure FDC I/O ports and validate parameters ---
; Section 1: I/O register initialization (3x ldio/mask/set/store sequences)
;   for FDC-related I/O port configuration.
; Section 2: Format type validation - cascading cp/jr checks against
;   format codes (0x33, 0x34, 0x35, 0x36, 0x47, 0x4f, etc.).
; Section 3: Format parameter loading - sector size, head count,
;   track count from memory locations 35369-35386.
; Section 4: DMA parameter validation - checks that sector count,
;   byte count, buffer pointers are non-zero before proceeding.
; Returns: HL=0xffff on failure, 0 on success.
; Uses ldio, (R+d16) addressing. 460 bytes.
FDC_HardwareSetup:
; [v10] ==================== (guessed) start of floppy routines =======================
; [v10] --- FDC_HardwareSetup: Configure FDC I/O ports and validate parameters ---
; [v10] Section 1: I/O register initialization (3x ldio/mask/set/store sequences)
; [v10] for FDC-related I/O port configuration.
; [v10] Section 2: Format type validation - cascading cp/jr checks against
; [v10] format codes (0x33, 0x34, 0x35, 0x36, 0x47, 0x4f, etc.).
; [v10] Section 3: Format parameter loading - sector size, head count,
; [v10] track count from memory locations 35369-35386.
; [v10] Section 4: DMA parameter validation - checks that sector count,
; [v10] byte count, buffer pointers are non-zero before proceeding.
; [v10] Returns: HL=0xffff on failure, 0 on success.
; [v10] Uses ldio, (R+d16) addressing. 460 bytes.
	ld	(INTCLR:8), 11:io
	lda	xbc, (INTE45:8)
	ld	a, (xbc)
	and	a, 248
	set	2, a
	ld	(xbc), a
	ld	(INTCLR:8), 40:io
	lda	xbc, (INTETC23:8)
	ld	a, (xbc)
	and	a, 143
	or	a, 80
	ld	(xbc), a
	ld	(INTCLR:8), 12:io
	lda	xbc, (INTE45:8)
	ld	a, (xbc)
	and	a, 143
	or	a, 96
	ld	(xbc), a
	ret
FDC_CMD_SEND:
	dec	2, xsp
	ld	(xsp), a
	calr	FDC_WaitReady
	cp	(FDC_ERROR_CODE:16), 0
	jrl	nz, FDC_HardwareSetup_Epilogue
	ld	a, (xsp)
	ld	(FDC_CMD_OPCODE:16), a
	calr	FDC_ValidateOpcode
	cp	l, 0:i3
	jrl	nz, FDC_HardwareSetup_Epilogue
	ld	a, (xsp)
	cp	a, 51
	jr	z, FDC_CMD_SEND_Skip2
	cp	a, 52
	jr	z, FDC_CMD_SEND_Skip2
	cp	a, 54
	jr	z, FDC_CMD_SEND_Skip
	cp	a, 53
	jr	z, FDC_CMD_SEND_Skip
	cp	a, 71
	jr	nz, FDC_CMD_SEND_Skip3
FDC_CMD_SEND_Skip:
	ld	a, (xsp)
	extz	wa
	calr	FDC_SendAuxCmd
	jrl	FDC_HardwareSetup_Epilogue
FDC_CMD_SEND_Skip2:
	ld	a, (xsp)
	extz	wa
	calr	FDC_SendAuxCmdReadResult
	jrl	FDC_HardwareSetup_Epilogue
FDC_CMD_SEND_Skip3:
	ld	a, (xsp)
	res	4, a
	cp	a, 79
	jr	nz, FDC_CMD_SEND_Skip4
	ld	a, (xsp)
	extz	wa
	calr	FDC_SendAuxCmdReadResult
	jrl	FDC_HardwareSetup_Epilogue
FDC_CMD_SEND_Skip4:
	ld	a, (xsp)
	and	a, 15
	cp	a, 14
	jr	z, FDC_CMD_SEND_Skip5
	ld	a, (xsp)
	and	a, 15
	cp	a, 11
	jr	nz, FDC_HardwareSetup_Skip6
FDC_CMD_SEND_Skip5:
	ld	a, (xsp)
	extz	wa
	calr	FDC_SendAuxCmdReadResult
	jr	FDC_HardwareSetup_Epilogue
FDC_HardwareSetup_Skip6:
	ld	a, (xsp)
	extz	wa
	calr	FDC_SendCommandByte
	cp	(FDC_ERROR_CODE:16), 0
	jr	nz, FDC_HardwareSetup_Epilogue
	cp	(xsp), 8
	jr	z, FDC_HardwareSetup_Epilogue
	cp	(xsp), 3
	jr	nz, FDC_HardwareSetup_Skip7
	calr	FDC_SendParams_Specify
	jr	FDC_HardwareSetup_Epilogue
FDC_HardwareSetup_Skip7:
	ld	a, (FDC_HEAD:16)
	and	a, 1
	sll	a, 2
	ld	e, a
	ld	a, (FDC_DRIVE:16)
	and	a, 3
	ld	c, a
	ld	a, e
	or	a, c
	ld	a, e
	set	0, a
	extz	wa
	calr	FDC_SendParameterByte
	ld	a, (xsp)
	cp	a, 15
	jr	z, FDC_CMD_SEND_Skip10
	cp	a, 77
	jr	z, FDC_CMD_SEND_Skip9
	cp	a, 7:i3
	jr	z, FDC_CMD_SEND_Skip8
	cp	a, 4:i3
	jr	z, FDC_CMD_SEND_Skip8
	cp	a, 74
	jr	nz, FDC_HardwareSetup_Skip11
FDC_CMD_SEND_Skip8:
	jr	FDC_HardwareSetup_Epilogue
FDC_CMD_SEND_Skip9:
	calr	FDC_SendParams_Format
	jr	FDC_HardwareSetup_Epilogue
FDC_CMD_SEND_Skip10:
	calr	FDC_SendParam_SeekTrack
	jr	FDC_HardwareSetup_Epilogue
FDC_HardwareSetup_Skip11:
	calr	FDC_SendParams_ReadWrite
FDC_HardwareSetup_Epilogue:
	inc	2, xsp
	ret
FDC_ValidateOpcode:
	ld	a, (FDC_CMD_OPCODE:16)
	cp	a, 79
	jr	z, FDC_HardwareSetup_Skip12
	cp	a, 51
	jr	z, FDC_HardwareSetup_Skip12
	cp	a, 52
	jr	z, FDC_HardwareSetup_Skip12
	cp	a, 71
	jr	z, FDC_HardwareSetup_Skip12
	cp	a, 53
	jr	nz, FDC_HardwareSetup_Skip13
FDC_HardwareSetup_Skip12:
	ld	l, 0:opc
	ret
FDC_HardwareSetup_Skip13:
	ld	a, (FDC_CMD_OPCODE:16)
	and	a, 31
	cp	a, 30
	jr	z, FDC_HardwareSetup_Skip14
	cp	a, 29
	jr	z, FDC_HardwareSetup_Skip14
	cp	a, 25
	jr	z, FDC_HardwareSetup_Skip14
	cp	a, 16
	jr	z, FDC_HardwareSetup_Helper5_Skip
	cp	a, 17
	jr	z, FDC_HardwareSetup_Skip14
	cp	a, 15
	jr	ugt, FDC_HardwareSetup_Helper5_Skip
	cp	a, 2:i3
	jr	c, FDC_HardwareSetup_Helper5_Skip
FDC_HardwareSetup_Skip14:
	ld	l, 0:opc
	ret
FDC_HardwareSetup_Helper5_Skip:
	ld L, 0x01:opc
	ret
FDC_HardwareSetup_Join:
	ld	a, (FDC_PARAM_STP:16)
	and	a, 3
	extz	wa
	jrl	FDC_SendParameterByte
FDC_SendParams_Specify:
	ld	a, (FDC_SPECIFY_SRT:16)
	sll	a, 4
	ld	e, a
	ld	a, (FDC_SPECIFY_HUT:16)
	and	a, 15
	ld	c, a
	ld	a, e
	or	a, c
	extz	wa
	calr	FDC_SendParameterByte
	ld	a, (FDC_SPECIFY_HLT:16)
	sll	a, 1
	ld	e, a
	ld	a, (FDC_SPECIFY_ND:16)
	and	a, 1
	ld	c, a
	ld	a, e
	or	a, c
	extz	wa
	jrl	FDC_SendParameterByte
FDC_SendParams_Format:
	ld	a, (FDC_PARAM_N:16)
	and	a, 7
	extz	wa
	calr	FDC_SendParameterByte
	ld	a, (FDC_FORMAT_SC:16)
	extz	wa
	calr	FDC_SendParameterByte
	ld	a, (FDC_FORMAT_GPL:16)
	extz	wa
	calr	FDC_SendParameterByte
	ld	a, (FDC_FORMAT_FILL:16)
	extz	wa
	jrl	FDC_SendParameterByte
FDC_SendParam_SeekTrack:
	ld	a, (FDC_TARGET_TRACK:16)
	extz	wa
	jrl	FDC_SendParameterByte
FDC_SendParams_ReadWrite:
	ld	a, (FDC_PARAM_C:16)
	extz	wa
	calr	FDC_SendParameterByte
	ld	a, (FDC_PARAM_H:16)
	and	a, 1
	extz	wa
	calr	FDC_SendParameterByte
	ld	a, (FDC_PARAM_R:16)
	extz	wa
	calr	FDC_SendParameterByte
	ld	a, (FDC_PARAM_N:16)
	and	a, 7
	extz	wa
	calr	FDC_SendParameterByte
	ld	a, (FDC_PARAM_EOT:16)
	extz	wa
	calr	FDC_SendParameterByte
	ld	a, (FDC_PARAM_GPL:16)
	extz	wa
	calr	FDC_SendParameterByte
	ld	a, (FDC_CMD_OPCODE:16)
	cp	a, 221
	jr	z, FDC_HardwareSetup_Skip16
	cp	a, 217
	jr	z, FDC_HardwareSetup_Skip16
	cp	a, 209
	jr	nz, FDC_HardwareSetup_Skip17
FDC_HardwareSetup_Skip16:
	jrl	FDC_HardwareSetup_Join
FDC_HardwareSetup_Skip17:
	ld	a, (FDC_PARAM_DTL:16)
	extz	wa
	calr	FDC_SendParameterByte
	ret
FDC_DETECT_CHECK:	.include "includes/generated/cc900/FDC_DETECT_CHECK.s"	; C: cc900/fdc_routines_xr.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	FDC_DETECT_CHECK_Skip, FDC_DETECT_CHECK + 11
	.set	FDC_DETECT_CHECK_Skip2, FDC_DETECT_CHECK + 22
	.set	FDC_DETECT_CHECK_Skip3, FDC_DETECT_CHECK + 33
	.set	FDC_DETECT_CHECK_Skip4, FDC_DETECT_CHECK + 44
	.set	FDC_DETECT_CHECK_Skip5, FDC_DETECT_CHECK + 55
	.set	FDC_DETECT_CHECK_Skip6, FDC_DETECT_CHECK + 66
FDC_DRIVE_DETECT:	.include "includes/generated/cc900/FDC_DRIVE_DETECT.s"	; C: cc900/fdc_routines_xr.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	FDC_DRIVE_DETECT_Skip, FDC_DRIVE_DETECT + 11
	.set	FDC_DRIVE_DETECT_Skip2, FDC_DRIVE_DETECT + 22
	.set	FDC_DRIVE_DETECT_Skip3, FDC_DRIVE_DETECT + 33
	.set	FDC_DRIVE_DETECT_Skip4, FDC_DRIVE_DETECT + 44
	.set	FDC_DRIVE_DETECT_Skip5, FDC_DRIVE_DETECT + 55
	.set	FDC_DRIVE_DETECT_Skip6, FDC_DRIVE_DETECT + 71
	.set	FDC_DRIVE_DETECT_Skip7, FDC_DRIVE_DETECT + 75
FDC_DRIVE_STATUS:	.include "includes/generated/cc900/FDC_DRIVE_STATUS.s"	; C: cc900/fdc_routines_m270_xr.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	FDC_DRIVE_STATUS_Skip8, FDC_DRIVE_STATUS + 11
	.set	FDC_DRIVE_STATUS_Skip9, FDC_DRIVE_STATUS + 22
FDC_PRE_OP_CHECK:
	ret
FDC_Set_Status:
	cp (FDC_ERROR_CODE:16), 0x00
	jr nz, FDC_SetStatus_AlreadySet
	ld (FDC_ERROR_CODE:16), a
	cp A,0x36
	jr z, FDC_SetStatus_DataFieldErr
	cp A,0x35
	jr z, FDC_SetStatus_MissingAddrMark
	cp A,0x33
	jr nz, FDC_SetStatus_Return
	nop
	jr t, FDC_SetStatus_Return
FDC_SetStatus_MissingAddrMark:
	nop
	jr FDC_SetStatus_Return

FDC_SetStatus_DataFieldErr:
	nop
	jr FDC_SetStatus_Return

FDC_SetStatus_AlreadySet:
	nop

FDC_SetStatus_Return:
	ld	l, (FDC_ERROR_CODE:16)
	ret
; --- FDC_ClearStatus_InitTimer: Clear FDC status and start timeout ---
; Clears FDC status byte (35208) to 0, initializes result buffer (35268)
; to 0xff, saves prevbank state, starts timer-based timeout loop.
; Polls with cps bc, 0 for completion signal.
; Uses prevbank (D7 FA) for timer state management.
FDC_ClearStatus_InitTimer:	.include "includes/generated/cc900/FDC_ClearStatus_InitTimer.s"	; C: cc900/fdc_routines_m270.c
FDC_TIMING_DELAY:	.include "includes/generated/cc900/FDC_TIMING_DELAY.s"	; C: cc900/fdc_routines_m270.c
FDC_POST_OP:
	push XIZ
	ldw QIZ, 0x01f4
	ld iz, (SYSTEM_TIMESTAMP:16)
	ld bc, 0:i3
.Lc_f971e1:
	cp	(FDC_RESULT:16), 0xff
	jr z, .Lc_f971eb
	ldw BC, 0xffff
.Lc_f971eb:
FDC_POST_OP_Skip:
	ld wa, (SYSTEM_TIMESTAMP:16)
	sub WA,IZ
	cp WA,QIZ
	jr ule, .Lc_f971ff
	ldw WA, 0x0009
	calr FDC_Set_Status
	ldw BC, 0xffff
.Lc_f971ff:
FDC_POST_OP_Skip2:
	cp bc, 0:i3
	jr z, .Lc_f971e1
	pop XIZ
	ret
SOME_DELAY:	.include "includes/generated/cc900/SOME_DELAY.s"	; C: cc900/fdc_routines_m270_xr.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SOME_DELAY_Loop, SOME_DELAY + 15


FDC_InitSequence_Short:
	ldw	wa, 40
	jr	SOME_DELAY

FDC_InitSequence_Full:
	calr	FDC_Init_Sequence_1
	calr	FDC_Pulse_PH0
	ld	(FDC_DISK_CHANGED:16), 0
	ld	(35400:16), 0
	calr	FDC_HardwareSetup
	calr	FDC_INIT
	jrl	FDC_CONFIG_VERIFY
FDC_CmdRecalibrate:	.include "includes/generated/cc900/FDC_CmdRecalibrate.s"	; C: cc900/fdc_routines_m270.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	FDC_CmdRecalibrate_Skip, FDC_CmdRecalibrate + 51
FDC_CmdSeek:	.include "includes/generated/cc900/FDC_CmdSeek.s"	; C: cc900/fdc_routines_m270_xr.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	FDC_CmdSeek_Skip, FDC_CmdSeek + 45
FDC_CMD_EXEC_Helper6:
	ld	(FDC_CMD_OPCODE:16), 198
	calr	FDC_Setup_DMA_Mode
	calr	FDC_TIMING_DELAY
	ldw	wa, 198
	calr	FDC_CMD_SEND
	cp	(FDC_ERROR_CODE:16), 0
	ret	nz
	jrl	FDC_POST_OP
; --- FDC_CMD_EXEC: Main FDC command execution engine ---
; Two nearly identical halves: READ path (command type 1) and
; WRITE path (command type 8), set in state variable 35276.
; Each path:
;   1. Clears status, waits for FDC ready
;   2. Sets up DMA: clear byte counter (35200), compute sector size
;      (1024 or 512 based on format), configure DMA direction
;   3. Sector loop: decrement sector count, advance track/head,
;      check against max sectors (35440)
;   4. Accumulates transferred sector count at 35246
;   5. Error handling: sets error flag (35432=255) on failure
; Tail calls format-specific routines and status verification.
; Uses (R+d16) addressing for all FDC state variable access. 672 bytes.
FDC_CMD_EXEC:
; [v10] --- FDC_CMD_EXEC: Main FDC command execution engine ---
; [v10] Two nearly identical halves: READ path (command type 1) and
; [v10] WRITE path (command type 8), set in state variable 35432.
; [v10] Each path:
; [v10] 1. Clears status, waits for FDC ready
; [v10] 2. Sets up DMA: clear byte counter (35356), compute sector size
; [v10] (1024 or 512 based on format), configure DMA direction
; [v10] 3. Sector loop: decrement sector count, advance track/head,
; [v10] check against max sectors (35596)
; [v10] 4. Accumulates transferred sector count at 35402
; [v10] 5. Error handling: sets error flag (35588=255) on failure
; [v10] Tail calls format-specific routines and status verification.
; [v10] Uses (R+d16) addressing for all FDC state variable access. 672 bytes.
	pushw	iz
	calr	FDC_DETECT_CHECK
	cp	hl, 0:i3
	jr	z, FDC_CMD_EXEC_Skip
	ld	(FDC_RETRY_COUNT:16), 1
	jrl	FDC_CE_DISPATCH
FDC_CMD_EXEC_Skip:
	calr	FDC_DRIVE_DETECT
	cp	hl, 0:i3
	jr	nz, FDC_CMD_EXEC_Skip2
	ld	(FDC_RETRY_COUNT:16), 8
	jrl	FDC_CE_DISPATCH
FDC_CMD_EXEC_Skip2:
	ld	(FDC_RETRY_COUNT:16), 1
	jrl	FDC_CE_DISPATCH
FDC_CMD_EXEC_Loop:
	ld	(FDC_ERROR_CODE:16), 0
	calr	FDC_CmdSeek
	cp	(FDC_ERROR_CODE:16), 0
	jr	z, FDC_CMD_EXEC_Skip3
	ld	a, (FDC_ERROR_CODE:16)
	ldfr_berp	a, 248
	exts	iz
	calr	FDC_CONFIG_VERIFY
	ldto_berp	a, 248
	stb_d8	(FDC_ERROR_CODE), a
	jrl	FDC_CE_EXIT
FDC_CMD_EXEC_Skip3:
	ldw_d16	wa, (FDC_REQ_SECTOR)
	cp	wa, (FDC_SECTOR_LIMIT:16)
	jr	ule, FDC_CMD_EXEC_Join
	ldw	(FDC_REQ_SECTOR:16), 1
FDC_CMD_EXEC_Join:
	ldmm16	0x8a58, FDC_REQ_SECTOR
	ldw	(FDC_SECTOR_COUNT:16), 0
	cp	(FDC_DRIVE_MODE:16), 2
	jr	nz, FDC_CMD_EXEC_Skip5
	ldw	(FDC_SECTOR_SIZE:16), 1024
	jr	FDC_CMD_EXEC_Join7
FDC_CMD_EXEC_Skip5:
	ldw	(FDC_SECTOR_SIZE:16), 512
FDC_CMD_EXEC_Join7:
	ldmm16	0x8a5a, FDC_REQ_COUNT
	ld	iz, 1:i3
FDC_CMD_EXEC_Join2:
	ld	wa, (FDC_SECTOR_SIZE:16)
	add	(FDC_SECTOR_COUNT:16), wa
	lda	xwa, (FDC_REQ_COUNT:16)
	decm	1, (xwa)
	ld	wa, (xwa)
	cp	wa, 0:i3
	jr	z, FDC_CMD_EXEC_Skip6
	lda	xwa, (FDC_REQ_SECTOR:16)
	incw	1, (xwa)
	ld	wa, (xwa)
	cp	wa, (FDC_SECTOR_LIMIT:16)
	jr	ugt, FDC_CMD_EXEC_Skip6
	inc	1, iz
	jr	FDC_CMD_EXEC_Join2
FDC_CMD_EXEC_Skip6:
	ld	(FDC_REQ_COUNT:16), iz
	ldmm16	FDC_REQ_SECTOR, 0x8a58
	calr	FDC_CMD_EXEC_Helper6
	cp	(FDC_ERROR_CODE:16), 0
	jr	z, FDC_CMD_EXEC_Skip8
	cp	(FDC_ERROR_CODE:16), 9
	jr	nz, FDC_CMD_EXEC_Skip7
	calr	FDC_INIT
	jrl	FDC_CE_EXIT
FDC_CMD_EXEC_Skip7:
	calr	FDC_DRIVE_DETECT
	cp	hl, 0xffff
	jr	z, FDC_CMD_EXEC_Join3
	calr	FDC_CONFIG_VERIFY
	ld	(FDC_CURRENT_CYLINDER:16), 255
	calr	FDC_CmdSeek
FDC_CMD_EXEC_Join3:
	ldmm16	FDC_REQ_COUNT, 0x8a5a
	dec	1, (FDC_RETRY_COUNT:16)
	ldb_d8	a, (FDC_RETRY_COUNT)
	cp	a, 0:i3
	jr	nz, FDC_CE_DISPATCH
	ld	(FDC_ERROR_CODE:16), 16
	jr	FDC_CE_EXIT
FDC_CMD_EXEC_Skip8:
	ld	wa, (0x8a5a:16)
	sub	wa, iz
	ld	(FDC_REQ_COUNT:16), wa
	cpw	(FDC_REQ_COUNT:16), 0
	jr	z, FDC_CE_DISPATCH
	lda	xbc, (FDC_REQ_BUFFER:16)
	ld	wa, (FDC_SECTOR_COUNT:16)
	extz	xwa
	add	xwa, (xbc)
	ld	(xbc), xwa
	ldw	(FDC_REQ_SECTOR:16), 1
	ld	(FDC_PARAM_R:16), 1
	ld	a, (FDC_HEAD:16)
	xor	a, 1
	ld	(FDC_HEAD:16), a
	ld	(FDC_PARAM_H:16), a
	cp	(FDC_PARAM_H:16), 0
	jr	nz, FDC_CE_DISPATCH
	lda	xwa, (FDC_PARAM_C:16)
	incm8	1, (xwa)
	ld	a, (xwa)
	ld	(FDC_TARGET_TRACK:16), a
FDC_CE_DISPATCH:
	cpw	(FDC_REQ_COUNT:16), 0
	jrl	nz, FDC_CMD_EXEC_Loop
FDC_CE_EXIT:
	popw	iz
	ret
FDC_SECTOR_XFER:
	pushw	iz
	ld	(FDC_RETRY_COUNT:16), 8
	jrl	FDC_CMD_EXEC_Join5
FDC_CMD_EXEC_Loop2:
	ld	(FDC_ERROR_CODE:16), 0
	calr	FDC_CmdSeek
	cp	(FDC_ERROR_CODE:16), 0
	jr	z, FDC_CMD_EXEC_Skip9
	ld	a, (FDC_ERROR_CODE:16)
	ldfr_berp	a, 248
	exts	iz
	calr	FDC_CONFIG_VERIFY
	ldto_berp	a, 248
	stb_d8	(FDC_ERROR_CODE), a
	jrl	FDC_CMD_EXEC_Epilogue2
FDC_CMD_EXEC_Skip9:
	ldw_d16	wa, (FDC_REQ_SECTOR)
	cp	wa, (FDC_SECTOR_LIMIT:16)
	jr	ule, FDC_SECTOR_XFER_Join
	ldw	(FDC_REQ_SECTOR:16), 1
FDC_SECTOR_XFER_Join:
	ldmm16	0x8a58, FDC_REQ_SECTOR
	ldw	(FDC_SECTOR_COUNT:16), 0
	cp	(FDC_DRIVE_MODE:16), 2
	jr	nz, FDC_CMD_EXEC_Skip11
	ldw	(FDC_SECTOR_SIZE:16), 1024
	jr	FDC_SECTOR_XFER_Join2
FDC_CMD_EXEC_Skip11:
	ldw	(FDC_SECTOR_SIZE:16), 512
FDC_SECTOR_XFER_Join2:
	ldmm16	0x8a5a, FDC_REQ_COUNT
	ld	iz, 1:i3
FDC_CMD_EXEC_Join4:
	ld	wa, (FDC_SECTOR_SIZE:16)
	add	(FDC_SECTOR_COUNT:16), wa
	lda	xwa, (FDC_REQ_COUNT:16)
	decm	1, (xwa)
	ld	wa, (xwa)
	cp	wa, 0:i3
	jr	z, FDC_CMD_EXEC_Skip12
	lda	xwa, (FDC_REQ_SECTOR:16)
	incw	1, (xwa)
	ld	wa, (xwa)
	cp	wa, (FDC_SECTOR_LIMIT:16)
	jr	ugt, FDC_CMD_EXEC_Skip12
	inc	1, iz
	jr	FDC_CMD_EXEC_Join4
FDC_CMD_EXEC_Skip12:
	ld	(FDC_REQ_COUNT:16), iz
	ldmm16	FDC_REQ_SECTOR, 0x8a58
	calr	FDC_CMD_EXEC_Helper7
	cp	(FDC_ERROR_CODE:16), 0
	jr	z, FDC_CMD_EXEC_Skip14
	cp	(FDC_ERROR_CODE:16), 9
	jr	nz, FDC_CMD_EXEC_Skip13
	calr	FDC_INIT
	calr	FDC_CONFIG_VERIFY
	jrl	FDC_CMD_EXEC_Epilogue2
FDC_CMD_EXEC_Skip13:
	cp	(FDC_ERROR_CODE:16), 47
	jr	z, FDC_CMD_EXEC_Epilogue2
	calr	FDC_CONFIG_VERIFY
	ld	(FDC_CURRENT_CYLINDER:16), 255
	calr	FDC_CmdSeek
	ldmm16	FDC_REQ_COUNT, 0x8a5a
	dec	1, (FDC_RETRY_COUNT:16)
	ldb_d8	a, (FDC_RETRY_COUNT)
	cp	a, 0:i3
	jr	nz, FDC_CMD_EXEC_Join5
	ld	(FDC_ERROR_CODE:16), 32
	jr	FDC_CMD_EXEC_Epilogue2
FDC_CMD_EXEC_Skip14:
	ld	wa, (0x8a5a:16)
	sub	wa, iz
	ld	(FDC_REQ_COUNT:16), wa
	cpw	(FDC_REQ_COUNT:16), 0
	jr	z, FDC_CMD_EXEC_Join5
	lda	xbc, (FDC_REQ_BUFFER:16)
	ld	wa, (FDC_SECTOR_COUNT:16)
	extz	xwa
	add	xwa, (xbc)
	ld	(xbc), xwa
	ldw	(FDC_REQ_SECTOR:16), 1
	ld	(FDC_PARAM_R:16), 1
	ld	a, (FDC_HEAD:16)
	xor	a, 1
	ld	(FDC_HEAD:16), a
	ld	(FDC_PARAM_H:16), a
	cp	(FDC_PARAM_H:16), 0
	jr	nz, FDC_CMD_EXEC_Join5
	lda	xwa, (FDC_PARAM_C:16)
	incm8	1, (xwa)
	ld	a, (xwa)
	ld	(FDC_TARGET_TRACK:16), a
FDC_CMD_EXEC_Join5:
	cpw	(FDC_REQ_COUNT:16), 0
	jrl	nz, FDC_CMD_EXEC_Loop2
FDC_CMD_EXEC_Epilogue2:
	popw	iz
	ret
FDC_CMD_EXEC_Helper7:
	ld	(FDC_CMD_OPCODE:16), 197
	calr	FDC_Setup_DMA_Mode
	calr	FDC_TIMING_DELAY
	ldw	wa, 197
	calr	FDC_CMD_SEND
	cp	(FDC_ERROR_CODE:16), 0
	ret	nz
	jrl	FDC_POST_OP
; --- FDC_MODE_CONFIG: Configure FDC format parameters by disk type ---
; Reads format type from state variable 35436.
; Dispatch by type: 0=default, 2=MFM, 3/4/5 = other formats.
; Sets per-format parameters:
;   35218: sectors per track (2 or 3)
;   35223: bytes per sector code (80/108/116 = 128/256/512 bytes)
;   35226: head number, 35215: track number, 35224: gap length (0xe5)
;   35216: side number, 35213: drive number
; Then enters sector counting/validation loop.
; Uses (R+d16) addressing for all state variables. 184 bytes.
FDC_MODE_CONFIG:
; [v10] --- FDC_MODE_CONFIG: Configure FDC format parameters by disk type ---
; [v10] Reads format type from state variable 35436.
; [v10] Dispatch by type: 0=default, 2=MFM, 3/4/5 = other formats.
; [v10] Sets per-format parameters:
; [v10] 35374: sectors per track (2 or 3)
; [v10] 35379: bytes per sector code (80/108/116 = 128/256/512 bytes)
; [v10] 35382: head number, 35371: track number, 35380: gap length (0xe5)
; [v10] 35372: side number, 35369: drive number
; [v10] Then enters sector counting/validation loop.
; [v10] Uses (R+d16) addressing for all state variables. 184 bytes.
	calr	FDC_PRE_OP_CHECK
	cp	(FDC_ERROR_CODE:16), 0
	jrl	nz, FDC_MC_EXIT
	calr	FDC_CmdSenseDriveStatus
	cp	(FDC_ERROR_CODE:16), 0
	jrl	nz, FDC_MC_EXIT
	calr	FDC_CmdRecalibrate
	cp	(FDC_ERROR_CODE:16), 0
	jrl	nz, FDC_MC_EXIT
	ld	a, (FDC_DRIVE_MODE:16)
	cp	a, 2:i3
	jr	z, FDC_MODE_CONFIG_Skip3
	cp	a, 3:i3
	jr	z, FDC_MODE_CONFIG_Skip2
	cp	a, 5:i3
	jr	z, FDC_MODE_CONFIG_Skip
	cp	a, 4:i3
	jr	z, FDC_MODE_CONFIG_Skip
	cp	a, 0:i3
	jr	nz, FDC_MODE_CONFIG_Join
FDC_MODE_CONFIG_Skip:
	ld	(FDC_PARAM_N:16), 2
	ld	(FDC_FORMAT_GPL:16), 80
	jr	FDC_MODE_CONFIG_Join
FDC_MODE_CONFIG_Skip2:
	ld	(FDC_PARAM_N:16), 2
	ld	(FDC_FORMAT_GPL:16), 108
	jr	FDC_MODE_CONFIG_Join
FDC_MODE_CONFIG_Skip3:
	ld	(FDC_PARAM_N:16), 3
	ld	(FDC_FORMAT_GPL:16), 116
FDC_MODE_CONFIG_Join:
	ld	(FDC_TARGET_TRACK:16), 0
	ld	(FDC_PARAM_C:16), 0
	ld	(FDC_FORMAT_FILL:16), 229
	ld	(FDC_PARAM_H:16), 0
	ld	(FDC_HEAD:16), 0
	jr	FDC_MODE_CONFIG_Join2
FDC_MODE_CONFIG_Loop:
	ldmm8	0x895a, FDC_TARGET_TRACK
	calr	FDC_FormatOneTrack
	cp	(FDC_ERROR_CODE:16), 0
	jr	nz, FDC_MC_EXIT
	ld	a, (FDC_HEAD:16)
	xor	a, 1
	ld	(FDC_HEAD:16), a
	ld	(FDC_PARAM_H:16), a
	cp	(FDC_PARAM_H:16), 0
	jr	nz, FDC_MODE_CONFIG_Join2
	lda	xwa, (FDC_PARAM_C:16)
	incm8	1, (xwa)
	ld	a, (xwa)
	ld	(FDC_TARGET_TRACK:16), a
	ld	(0x895a:16), a
FDC_MODE_CONFIG_Join2:
	ld	a, (FDC_TARGET_TRACK:16)
	extz	wa
	cp	wa, (0x8a50:16)
	jr	ule, FDC_MODE_CONFIG_Loop
; (was .incbin "includes/romslices/v7_transplant_FDC_MC_EXIT.bin")
FDC_MC_EXIT:
; [v10] --- FDC_MC_EXIT: FORMAT command execution and sector fill ---
; [v10] Calls cleanup, sets up FORMAT command (command byte 0x4d).
; [v10] Loads format buffer address from 35440, stores to DMA source (35404).
; [v10] Main loop fills format buffer with [track, head, sector, size] tuples:
; [v10] For each sector: load index, compute buffer[index] address,
; [v10] store track/head/sector/size bytes, increment byte count (35356).
; [v10] Handles odd sector counts separately.
; [v10] Tail: DMA transfer initiation and multi-sector retry logic.
; [v10] Uses (R+d16) addressing for buffer and state access. 536 bytes.
	cp	(FDC_ERROR_CODE:16), 0
	call	nz, (FDC_CONFIG_VERIFY:24)
	calr	FDC_CmdRecalibrate
	ld	(FDC_CURRENT_CYLINDER:16), 255
	ret
; FDC_FormatOneTrack: Formats one side of the current track: seeks (FDC_CmdSeek; on an error leaves through
;   FDC_CONFIG_VERIFY), builds the C/H/R/N ID-field list in the buffer at (0x8A70) (FDC_MC_EXIT_Code_Helper2), sets
;   command 0x4D (MF FORMAT TRACK) in 0x8A28, points the DMA address 0x8A4C at the list and runs the transfer and
;   command (FDC_Setup_DMA_Mode, FDC_MC_EXIT_Code_Helper, FDC_MC_EXIT_Code_Join2). Basis: callers + body --
;   FDC_MODE_CONFIG (handler 5, the format command in technics-docs fdc-subsystem.md) calls it once per track and
;   head; the bootloader's copy of the same code is FDC_FormatOneTrack in table_data/boot_fdc_driver.s.
FDC_FormatOneTrack:
	calr	FDC_CmdSeek
	cp	(FDC_ERROR_CODE:16), 0
	jrl	nz, FDC_CONFIG_VERIFY
	calr	FDC_MC_EXIT_Code_Helper2
	ld	(FDC_CMD_OPCODE:16), 77
	lda	xwa, (FDC_FORMAT_IDS:16)
	ld	(FDC_REQ_BUFFER:16), xwa
	calr	FDC_Setup_DMA_Mode
	calr	FDC_MC_EXIT_Code_Helper
	jrl	FDC_MC_EXIT_Code_Join2
FDC_MC_EXIT_Code_Helper2:
	ld	(FDC_PARAM_R:16), 1
	ldw	(FDC_SECTOR_COUNT:16), 0
	ld	ix, (0x8a52:16)
	srl	ix, 1
	ld	e, 0:opc
	ld	iy, 0:i3
	cp	iy, ix
	jrl	nc, FDC_MC_EXIT_Code_Skip2
FDC_MC_EXIT_Code_Loop:
	ld	a, e
	inc	1, e
	extz	wa
	lda	xbc, (FDC_FORMAT_IDS:16)
	ld	hl, wa
	extz	xhl
	add	xhl, xbc
	ld	a, (FDC_PARAM_C:16)
	ld	(xhl), a
	incw	1, (FDC_SECTOR_COUNT:16)
	ld	a, e
	inc	1, e
	extz	wa
	lda	xbc, (FDC_FORMAT_IDS:16)
	ld	hl, wa
	extz	xhl
	add	xhl, xbc
	ld	a, (FDC_PARAM_H:16)
	ld	(xhl), a
	incw	1, (FDC_SECTOR_COUNT:16)
	ld	a, e
	inc	1, e
	extz	wa
	lda	xbc, (FDC_FORMAT_IDS:16)
	ld	hl, wa
	extz	xhl
	add	xhl, xbc
	ld	a, (FDC_PARAM_R:16)
	ld	(xhl), a
	incw	1, (FDC_SECTOR_COUNT:16)
	ld	a, e
	inc	1, e
	extz	wa
	lda	xbc, (FDC_FORMAT_IDS:16)
	ld	hl, wa
	extz	xhl
	add	xhl, xbc
	ld	a, (FDC_PARAM_N:16)
	ld	(xhl), a
	incw	1, (FDC_SECTOR_COUNT:16)
	ld	a, e
	inc	1, e
	extz	wa
	lda	xbc, (FDC_FORMAT_IDS:16)
	ld	hl, wa
	extz	xhl
	add	xhl, xbc
	ld	a, (FDC_PARAM_C:16)
	ld	(xhl), a
	incw	1, (FDC_SECTOR_COUNT:16)
	ld	a, e
	inc	1, e
	extz	wa
	lda	xbc, (FDC_FORMAT_IDS:16)
	ld	hl, wa
	extz	xhl
	add	xhl, xbc
	ld	a, (FDC_PARAM_H:16)
	ld	(xhl), a
	incw	1, (FDC_SECTOR_COUNT:16)
	cpw	(FDC_REQ_TRACK:16), 0
	jr	nz, FDC_MC_EXIT_Code_Skip
	inc	1, (FDC_PARAM_R:16)
	ld	a, e
	inc	1, e
	extz	wa
	lda	xbc, (FDC_FORMAT_IDS:16)
	ld	hl, wa
	extz	xhl
	add	xhl, xbc
	ld	a, (FDC_PARAM_R:16)
	ld	(xhl), a
	jr	FDC_MC_EXIT_Code_Join
FDC_MC_EXIT_Code_Skip:
	ld	wa, (0x8a52:16)
	srl	wa, 1
	add	a, (FDC_PARAM_R:16)
	ld	l, a
	ld	a, e
	inc	1, e
	extz	wa
	lda	xbc, (FDC_FORMAT_IDS:16)
	extz	xwa
	add	xwa, xbc
	ld	(xwa), l
FDC_MC_EXIT_Code_Join:
	incw	1, (FDC_SECTOR_COUNT:16)
	ld	a, e
	inc	1, e
	extz	wa
	lda	xbc, (FDC_FORMAT_IDS:16)
	ld	hl, wa
	extz	xhl
	add	xhl, xbc
	ld	a, (FDC_PARAM_N:16)
	ld	(xhl), a
	incw	1, (FDC_SECTOR_COUNT:16)
	inc	1, (FDC_PARAM_R:16)
	inc	1, iy
	cp	iy, ix
	jrl	c, FDC_MC_EXIT_Code_Loop
FDC_MC_EXIT_Code_Skip2:
	ld	wa, (0x8a52:16)
	bit	0, wa
	ret	z
	ld	a, e
	inc	1, e
	extz	wa
	lda	xbc, (FDC_FORMAT_IDS:16)
	ld	hl, wa
	extz	xhl
	add	xhl, xbc
	ld	a, (FDC_PARAM_C:16)
	ld	(xhl), a
	incw	1, (FDC_SECTOR_COUNT:16)
	ld	a, e
	inc	1, e
	extz	wa
	lda	xbc, (FDC_FORMAT_IDS:16)
	ld	hl, wa
	extz	xhl
	add	xhl, xbc
	ld	a, (FDC_PARAM_H:16)
	ld	(xhl), a
	incw	1, (FDC_SECTOR_COUNT:16)
	ld	a, e
	inc	1, e
	extz	wa
	lda	xbc, (FDC_FORMAT_IDS:16)
	ld	hl, wa
	extz	xhl
	add	xhl, xbc
	ld	wa, (0x8a52:16)
	ld	(xhl), a
	incw	1, (FDC_SECTOR_COUNT:16)
	ld	a, e
	inc	1, e
	extz	wa
	lda	xbc, (FDC_FORMAT_IDS:16)
	ld	de, wa
	extz	xde
	add	xde, xbc
	ld	a, (FDC_PARAM_N:16)
	ld	(xde), a
	incw	1, (FDC_SECTOR_COUNT:16)
	ret
FDC_MC_EXIT_Code_Join2:
	ld	(FDC_CMD_OPCODE:16), 77
	calr	FDC_Setup_DMA_Mode
	calr	FDC_TIMING_DELAY
	ldw	wa, 77
	calr	FDC_CMD_SEND
	cp	(FDC_ERROR_CODE:16), 0
	ret	nz
	jrl	FDC_POST_OP
FDC_CMD_ENABLE:
	pushw	iz
	set	3, (PA:8)
	ldw	wa, 254
	calr	FDC_CMD_SEND
	cp	(FDC_ERROR_CODE:16), 0
	jr	z, FDC_MC_EXIT_Code_Skip3
	ldw	wa, 49
	calr	FDC_Set_Status
	jr	FDC_MC_EXIT_Code_Epilogue
FDC_MC_EXIT_Code_Skip3:
	ld	iz, 1:i3
	cp	iz, 0:i3
	jr	z, FDC_MC_EXIT_Code_Epilogue
FDC_MC_EXIT_Code_Loop2:
	ldw	wa, 10
	calr	SOME_DELAY
	djnz16	iz, FDC_MC_EXIT_Code_Loop2
FDC_MC_EXIT_Code_Epilogue:
	popw	iz
	ret
FDC_CMD_DISABLE:	.include "includes/generated/cc900/FDC_CMD_DISABLE.s"	; C: cc900/fdc_routines_m270.c
FDC_STATUS_COPY:
	ldmm8	FDC_ERROR_CODE, 0x896e
FDC_STATUS_COPY_Code:
	ret	
FDC_OUTPUT_CTRL:
	ld	wa, (FDC_REQ_HEAD:16)
	cp	wa, 1:i3
	jr	z, FDC_STATUS_COPY_Code_Skip2
	cp	wa, 0:i3
	jr	nz, FDC_STATUS_COPY_Code_Skip
	jr	FDC_STATUS_COPY_Code_Join
FDC_STATUS_COPY_Code_Skip:
	ldw	wa, 254
	calr	FDC_Set_Status
	ret	
FDC_STATUS_COPY_Code_Skip2:
	ld	(FDC_DISK_CHANGED:16), 255
	ret	
FDC_STATUS_COPY_Code_Join:
	ld	(FDC_DISK_CHANGED:16), 0
	ret	
; --- FDC_CmdSenseDriveStatus: FDC command 11, SENSE DRIVE STATUS ---
; Sends the uPD72068 command byte 0x04 (FDC_CMD_SEND), waits for the result phase
; (FDC_Wait_Ready_Timeout) and reads ST3 (FDC_ReadDataRegister) into QIZH (previous
; bank register 0xfb), then raises FDC_Set_Status for each condition, the first one sticking:
;   ST3 bit 7 (fault)            -> 0x32 equipment check / fault,
;   ST3 bit 5 (ready) clear      -> 0x31 drive not ready,
;   ST3 bit 6 (write-protected)  -> 0x2f write-protected.
; Returns at once if FDC_ERROR_CODE is already set.  No ei / di: QIZ is saved with push qiz.
; Callers: FDC_MODE_CONFIG (before recalibrating) and FDC_HANDLER_11 (command 11).
; Twin: table_data FDC_CmdSenseDriveStatus (boot_fdc_driver.s).
FDC_CmdSenseDriveStatus:
	push	qiz
	cp	(FDC_ERROR_CODE:16), 0
	jr	nz, FDC_CmdSenseDriveStatus_Done
	ld	wa, 4:i3
	calr	FDC_CMD_SEND
	cp	(FDC_ERROR_CODE:16), 0
	jr	nz, FDC_CmdSenseDriveStatus_Done
	calr	FDC_Wait_Ready_Timeout
	cp	(FDC_ERROR_CODE:16), 0
	jr	nz, FDC_CmdSenseDriveStatus_Done
	calr	FDC_ReadDataRegister
	ldfr_berp	l, 251
	bit_erpb	251, 7
	jr	z, FDC_CmdSenseDriveStatus_CheckReady
	ldw	wa, 50
	calr	FDC_Set_Status
FDC_CmdSenseDriveStatus_CheckReady:
	bit_erpb	251, 5
	jr	nz, FDC_CmdSenseDriveStatus_CheckWP
	ldw	wa, 49
	calr	FDC_Set_Status
FDC_CmdSenseDriveStatus_CheckWP:
	bit_erpb	251, 6
	jr	z, FDC_CmdSenseDriveStatus_Done
	ldw	wa, 47
	calr	FDC_Set_Status
FDC_CmdSenseDriveStatus_Done:
	pop	qiz
	ret	
FDC_CommandEntry:
	push XIZ
	ld XIZ,(XSP+0x08)
	cpw (XIZ), 0x0000
	jr nz, .Lc_f978cc
	ld	(FDC_BUSY_LATCH:16), 0x00
FDC_CommandEntry_EnableIRQ:
.Lc_f978cc:
	ei 0x06
	cp	(FDC_BUSY_LATCH:16), 0xa5
	jr nz, .Lc_f978e2
	ei 0x00
	ldw WA, 0x00fb
	calr FDC_Set_Status
	extz HL
	jrl t, FDC_Handler_Return
FDC_CommandEntry_CopyParams:
.Lc_f978e2:
	ld	(FDC_BUSY_LATCH:16), 0xa5
	ei 0x00
	ld WA,(XIZ)
	ld (FDC_COMMAND_INDEX:16), wa
	ld WA,(XIZ+0x02)
	ld	(FDC_REQ_DRIVE:16), wa
	ld WA,(XIZ+0x04)
	ld	(FDC_REQ_HEAD:16), wa
	ld WA,(XIZ+0x06)
	ld	(FDC_REQ_TRACK:16), wa
	ld WA,(XIZ+0x08)
	ld	(FDC_REQ_SECTOR:16), wa
	ld WA,(XIZ+0x0a)
	ld	(FDC_REQ_COUNT:16), wa
	ld XWA,(XIZ+0x0c)
	ld	(FDC_REQ_BUFFER:16), xwa
	ld	wa, (xiz)
	ld	(0x8998:16), wa
	ld	wa, (xiz + 2)
	ld	(0x899a:16), wa
	ld	wa, (xiz + 4)
	ld	(0x899c:16), wa
	ld	wa, (xiz + 6)
	ld	(0x899e:16), wa
	ld	wa, (xiz + 8)
	ld	(0x89a0:16), wa
	ld	wa, (xiz + 10)
	ld	(0x89a2:16), wa
	ld	xwa, (xiz + 12)
	ld	(0x89a4:16), xwa
	ld	(FDC_INIT_FLAG:16), 0
	ldmm8	0x896e, FDC_ERROR_CODE
	ld	(FDC_ERROR_CODE:16), 0
	calr	FDC_COMMAND_DISPATCHER
	cp	l, 0:i3
	jr	nz, FDC_Handler_ExitStatus
	ld	wa, (FDC_COMMAND_INDEX:16)
	cp	wa, 0xb
	jr	ugt, FDC_Handler_InvalidCommand
	add	wa, wa
	lda	xix, (FDC_CommandEntry_CopyParams_CaseTable:24)
	ld	wa, (xix+wa)
	lda	xix, (FDC_HANDLER_DISPATCH_BASE:24)
	jp	t, (xix+wa)
FDC_HANDLER_DISPATCH_BASE:
	calr FDC_InitSequence_Full
	jr FDC_Handler_ExitStatus

FDC_HANDLER_01:
	calr FDC_CMD_ENABLE
	calr FDC_CmdRecalibrate
	jr FDC_Handler_ExitStatus

FDC_HANDLER_02:
	calr FDC_CMD_ENABLE
	calr FDC_CmdSeek
	jr FDC_Handler_ExitStatus

FDC_HANDLER_03:
	calr FDC_CMD_ENABLE
	calr FDC_CMD_EXEC
	jr FDC_Handler_ExitStatus

FDC_HANDLER_04:
	calr FDC_CMD_ENABLE
	calr FDC_SECTOR_XFER
	jr FDC_Handler_ExitStatus

FDC_HANDLER_05:
	calr FDC_CMD_ENABLE
	calr FDC_MODE_CONFIG
	jr FDC_Handler_ExitStatus

FDC_HANDLER_06:
	calr FDC_CMD_ENABLE
	jr FDC_Handler_ExitStatus

FDC_HANDLER_07:
	calr FDC_CMD_DISABLE
	jr FDC_Handler_ExitStatus

FDC_HANDLER_08:
	calr FDC_STATUS_COPY
	jr FDC_Handler_ExitStatus

FDC_HANDLER_09:
	calr FDC_OUTPUT_CTRL
	jr FDC_Handler_ExitStatus

FDC_HANDLER_10:
	calr FDC_CMD_DISPATCH_SUB
	jr FDC_Handler_ExitStatus

FDC_HANDLER_11:
	calr FDC_CMD_ENABLE
	calr FDC_CmdSenseDriveStatus
	jr FDC_Handler_ExitStatus

FDC_Handler_InvalidCommand:
	ldw wa, 0xff
	calr FDC_Set_Status

FDC_Handler_ExitStatus:
	ld	(FDC_BUSY_LATCH:16), 90
	ld	l, (FDC_ERROR_CODE:16)
	exts	hl
FDC_Handler_Return:
	pop xiz
	ret


; --- FDC_ByteTransfer_PIO: Byte-at-a-time PIO data transfer ---
; Checks if byte count (35356) is zero; returns immediately if so.
; Dispatches by command type (35392):
;   Command 3 (READ):  read from I/O port 0x120000 -> buffer at 35406
;   Command 4 (WRITE): read from buffer at 35406 -> I/O port 0x120000
; Increments buffer pointer (35406) after each byte.
; Falls through to transfer completion handlers.
FDC_ByteTransfer_PIO:
; (was .incbin "includes/romslices/v7_transplant_FDC_ByteTransfer_PIO.bin")
; [v10] --- FDC_ByteTransfer_PIO: Byte-at-a-time PIO data transfer ---
; [v10] Checks if byte count (35356) is zero; returns immediately if so.
; [v10] Dispatches by command type (35392):
; [v10] Command 3 (READ):  read from I/O port 0x120000 -> buffer at 35406
; [v10] Command 4 (WRITE): read from buffer at 35406 -> I/O port 0x120000
; [v10] Increments buffer pointer (35406) after each byte.
; [v10] Falls through to transfer completion handlers.
	cpw	(FDC_SECTOR_COUNT:16), 0
	ret	z
	ld	wa, (FDC_COMMAND_INDEX:16)
	cp	wa, 4:i3
	jr	z, FDC_CommandEntry_Skip
	cp	wa, 3:i3
	ret	nz
	ld	c, (0x120000:24)
	ld	xhl, (0x8996:16)
	ld	(xhl), c
	inc	1, xhl
	ld	(0x8996:16), xhl
FDC_CommandEntry_Join:
	subw	(FDC_SECTOR_COUNT:16), 1
	ret	nz
	calr	FDC_Pulse_PH0
	calr	FDC_Port_Reset_Or_Noop
	ret
FDC_CommandEntry_Skip:
	ld	xhl, (0x8996:16)
	ld	c, (xhl)
	ld	(0x120000:24), c
	inc	1, xhl
	ld	(0x8996:16), xhl
	jr	FDC_CommandEntry_Join
INTTC3_HANDLER:
	push xiz
	push xiy
	push xix
	push xhl
	push xde
	push xbc
	push xwa
	calr FDC_Pulse_PH0
	calr FDC_Port_Reset_Or_Noop
	pop xwa
	pop xbc
	pop xde
	pop xhl
	pop xix
	pop xiy
	pop xiz
	reti


INT5_HANDLER:	; F97E4A	"FDCIRQ"
	ld (265:16), 8
	reti


INT4_HANDLER:	; F97E50	"FDCINT"
	push xiz
	push xiy
	push xix
	push xhl
	push xde
	push xbc
	push xwa
	ld iz, 0:i3

INT4_PollStatusLoop:
	ld wa, iz
	inc 1, iz
	cp wa, 0x64
	jr gt, INT4_ExitRestore
	calr FDC_Read_Status
	bit 7, l
	jr z, INT4_PollStatusLoop

INT4_WaitDataReady:
	calr FDC_Read_Status
	bit 7, l
	jr z, INT4_WaitDataReady
	calr FDC_Read_Status
	bit 6, l
	jr nz, INT4_StoreResultBase
	ld l, 0x0:opc
	cp l, 0x80
	jr z, INT4_SendSpecifyCmd

INT4_WaitNonDMAMode:
	calr FDC_Read_Status
	and l, 0xf0
	cp l, 0x80
	jr nz, INT4_WaitNonDMAMode

INT4_SendSpecifyCmd:
	ldw wa, 0x8
	calr FDC_WriteDataRegister

INT4_StoreResultBase:
	lda	xiz, (FDC_RESULT:16)
	inc	1, xiz
INT4_ReadResultLoop:
	calr FDC_Wait_Status_Timeout
	calr FDC_ReadDataRegister
	ld (xiz+), l

INT4_WaitResultReady:
	calr	FDC_Read_Status
	bit	7, l
	jr	z, INT4_WaitResultReady
	calr	FDC_Read_Status
	bit	6, l
	jr	nz, INT4_ReadResultLoop
	calr	FDC_Exception_Status_Decoder
	cp	(35241:16), 128
	jr	nz, INT4_WaitDataReady
INT4_ExitRestore:
	ld	(FDC_RESULT:16), 0
	pop	xwa
	pop	xbc
	pop	xde
	pop	xhl
	pop	xix
	pop	xiy
	pop	xiz
	reti
; FDC_PulseResetLine: holds the floppy controller in hardware reset for 10 ticks: Port D bit 0 is the
;   FDCRST line (service manual p. 32, CPU SECTION (A): IC5 TMP94C241F pin 12 PD0 -> FDCRST to the FDC;
;   notes/kn5000-a-2026-10-31/probes/sm_pd0_net.py renders the crop), set, SOME_DELAY 10, cleared, SOME_DELAY 10.
;   Twin of the boot loader's FDC_PulseResetLine (table_data/boot_disk_probe.s).
FDC_PulseResetLine:	.include "includes/generated/cc900/FDC_PulseResetLine.s"	; C: cc900/fdc_routines_m270.c
TestTitleFunc_OnTbiosTest_Helper:
	ld	(PHFC:8), 30:io
	bit	6, (PD:8)
	ret	nz
	ld	a, 0:opc
	ldw	(35436:16), 0
	ldw	(35438:16), 0
	ldw	(35440:16), 0
	cp	a, 0:i3
	jr	nz, FDC_Reset_SetDD_SectorCount
	ldw	(35442:16), 224
	jr	FDC_Reset_BuildParams
FDC_Reset_SetDD_SectorCount:
	ldw	(35442:16), 211
FDC_Reset_BuildParams:
	ldw	(35444:16), 0
	ldw	(35446:16), 0
	ld	xwa, 0:i3
	ld	(35448:16), xwa
	lda	xwa, (35436:16)
	push	xwa
	calr	FDC_CommandEntry
	ldw	(35436:16), 3
	ldw	(35438:16), 0
	ldw	(35440:16), 0
	ldw	(35442:16), 0
	ldw	(35444:16), 1
	ldw	(35446:16), 1
	lda	xwa, (35452:16)
	ld	(35448:16), xwa
	lda	xwa, (35436:16)
	push	xwa
	calr	FDC_CommandEntry
	ldw	(35436:16), 3
	ldw	(35438:16), 0
	ldw	(35440:16), 0
	ldw	(35442:16), 78
	ldw	(35444:16), 1
	ldw	(35446:16), 1
	lda	xwa, (35452:16)
	ld	(35448:16), xwa
	lda	xwa, (35436:16)
	push	xwa
	calr	FDC_CommandEntry
	ldw	(35436:16), 3
	ldw	(35438:16), 0
	ldw	(35440:16), 0
	ldw	(35442:16), 10
	ldw	(35444:16), 1
	ldw	(35446:16), 1
	lda	xwa, (35452:16)
	ld	(35448:16), xwa
	lda	xwa, (35436:16)
	push	xwa
	calr	FDC_CommandEntry
	ldw	(35436:16), 3
	ldw	(35438:16), 0
	ldw	(35440:16), 0
	ldw	(35442:16), 40
	ldw	(35444:16), 1
	ldw	(35446:16), 1
	lda	xwa, (35452:16)
	ld	(35448:16), xwa
	lda	xwa, (35436:16)
	push	xwa
	calr	FDC_CommandEntry
	lda	xsp, (xsp+20)
	ldw	wa, 200
	calr	SOME_DELAY
	incw	1, (58096:16)
	ret
Check_for_Floppy_Disk_Change:	.include "includes/generated/cc900/Check_for_Floppy_Disk_Change.s"	; C: cc900/fdc_routines_m270_xr.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Detected_Floppy_Disk_Change, Check_for_Floppy_Disk_Change + 8

; End of FDC routines
