/* Functions of storage/fdc_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: FDC_CMD_SEND FDC_NOP_Delay FDC_POST_OP FDC_ReadDataRegister FDC_Read_Status FDC_ResultPhase_Read FDC_SendAuxCmd FDC_SendAuxCmdReadResult FDC_SendCommandByte FDC_SendParam_SeekTrack FDC_SendParameterByte FDC_SendParams_Format FDC_SendParams_ReadWrite FDC_SendParams_Specify FDC_Send_Command FDC_Set_Status FDC_TIMING_DELAY FDC_ValidateOpcode FDC_WaitParamByteReady FDC_WaitReady FDC_Wait_Ready_Timeout FDC_WriteAuxCmdByte FDC_WriteDataRegister SOME_DELAY */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near FDC_CMD_OPCODE;
extern unsigned char FDC_ValidateOpcode();
extern unsigned char __near FDC_RESULT[];
extern unsigned char __near ram_8b00;
extern unsigned char FDC_Set_Status(int);
extern unsigned char FDC_Exception_Status_Decoder(void);
extern unsigned int __near FDC_REQ_HEAD;
extern unsigned char __near FDC_PARAM_H;
extern unsigned char __near FDC_HEAD;
extern void FDC_CheckHead(void);
extern void FDC_Validate_Drive_Head(void);
extern unsigned char __near FDC_TARGET_TRACK;
extern unsigned char __near FDC_CURRENT_CYLINDER;
extern unsigned char __near FDC_ERROR_CODE;
extern void SOME_DELAY(int);
extern void FDC_TIMING_DELAY(void);
extern void FDC_CMD_SEND(int);
extern void FDC_POST_OP(void);
extern void FDC_CmdSeek(void);
extern unsigned char __near FDC_SPECIFY_SRT;
extern unsigned char __near FDC_SPECIFY_HUT;
extern unsigned char __near FDC_SPECIFY_HLT;
extern unsigned char __near FDC_SPECIFY_ND;
extern void FDC_SendParameterByte(int);
extern void FDC_SendParams_Specify(void);

unsigned char FDC_ValidateOpcode()
{
    unsigned char t;
    switch (FDC_CMD_OPCODE) {
    case 53:
    case 71:
    case 52:
    case 51:
    case 79:
        return 0;
    default:
        t = FDC_CMD_OPCODE & 31;
        if (t == 30 || t == 29 || t == 25 || (t != 16 && (t == 17 || (t <= 15 && t >= 2)))) return 0;
        return 1;
    }
}

unsigned char FDC_Exception_Status_Decoder(void)
{
	unsigned char *r = FDC_RESULT;
	unsigned char c = r[1];

	switch (c & 0xc0) {
	case 0:
		return 0;
	case 0xc0:
		ram_8b00 = 255;
		return 0;
	case 0x80:
		return 0;
	case 0x40:
		if (c & 8) return 0x31;
		if (c & 0x10) return 0x32;
		c = r[2];
		if (c & 1) return FDC_Set_Status(0x35);
		if (c & 2) return FDC_Set_Status(0x2f);
		if (c & 4) return FDC_Set_Status(0x33);
		if (c & 0x10) return FDC_Set_Status(0x34);
		if (c & 0x20) return FDC_Set_Status(0x36);
		if (c & 0x80) return FDC_Set_Status(0x37);
		return FDC_Set_Status(8);
	default:
		return 8;
	}
}

void FDC_CheckHead(void)
{
    FDC_HEAD = FDC_PARAM_H = FDC_REQ_HEAD;
    if (FDC_HEAD != 0 && FDC_HEAD != 1) FDC_Set_Status(0xfe);
}

void FDC_Validate_Drive_Head(void)
{
    if (FDC_REQ_HEAD != 0 && FDC_REQ_HEAD != 1) FDC_Set_Status(0xfe);
}

void FDC_CmdSeek(void)
{
    if (FDC_TARGET_TRACK == FDC_CURRENT_CYLINDER) return;
    FDC_CURRENT_CYLINDER = FDC_TARGET_TRACK;
    SOME_DELAY(2);
    FDC_TIMING_DELAY();
    FDC_CMD_SEND(15);
    FDC_POST_OP();
    if (FDC_ERROR_CODE != 0) FDC_CURRENT_CYLINDER = 255;
    SOME_DELAY(16);
}

void FDC_SendParams_Specify(void)
{
    unsigned char hi, lo;
    hi = FDC_SPECIFY_SRT << 4;
    lo = FDC_SPECIFY_HUT & 15;
    FDC_SendParameterByte(hi | lo);
    hi = FDC_SPECIFY_HLT << 1;
    lo = FDC_SPECIFY_ND & 1;
    FDC_SendParameterByte(hi | lo);
}
