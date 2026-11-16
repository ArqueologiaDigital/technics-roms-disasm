/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_C_9m270a.c (2026-11-16-72-p6-r13)
   sha256 1b318ec28fc3d83528c5df921a5bc106b9349cd7f915c69815f3d4a965d6d1e7 (tar-sha256); compiled at -O3 -XS -Xr */
/* Phase 6, lane_p6 helper C, round 9, module 270 (modules_v10.tsv) of v10 storage/fdc_routines.s, form a:
   FDC_CMD_SEND with the module routines it calls by calr, written here.  Form b (p6_C_9m270b.c) differs only
   in the two wait loops. */

/* cc900-module: FDC_Read_Status FDC_ReadDataRegister FDC_Send_Command FDC_WriteDataRegister FDC_WaitReady FDC_WaitParamByteReady FDC_SendCommandByte FDC_SendParameterByte FDC_WriteAuxCmdByte FDC_SendAuxCmd FDC_SendAuxCmdReadResult FDC_SendParams_Specify FDC_SendParams_Format FDC_SendParam_SeekTrack FDC_SendParams_ReadWrite FDC_ValidateOpcode FDC_Set_Status FDC_ResultPhase_Read FDC_Wait_Ready_Timeout */

/* __near: the ROM reaches the cell with a 16-bit absolute operand. */
extern unsigned int __near SYSTEM_TIMESTAMP;
extern unsigned char __near FDC_ERROR_CODE;
extern unsigned char __near FDC_CMD_OPCODE;
extern unsigned char __near FDC_HEAD;
extern unsigned char __near FDC_DRIVE;
extern unsigned char __near FDC_RESULT[];
extern unsigned char __near FDC_SPECIFY_SRT;
extern unsigned char __near FDC_SPECIFY_HUT;
extern unsigned char __near FDC_SPECIFY_HLT;
extern unsigned char __near FDC_SPECIFY_ND;
extern unsigned char __near FDC_PARAM_N;
extern unsigned char __near FDC_FORMAT_SC;
extern unsigned char __near FDC_FORMAT_GPL;
extern unsigned char __near FDC_FORMAT_FILL;
extern unsigned char __near FDC_TARGET_TRACK;
extern unsigned char __near FDC_PARAM_C;
extern unsigned char __near FDC_PARAM_H;
extern unsigned char __near FDC_PARAM_R;
extern unsigned char __near FDC_PARAM_EOT;
extern unsigned char __near FDC_PARAM_GPL;
extern unsigned char __near FDC_PARAM_DTL;
extern unsigned char __near FDC_PARAM_STP;

/* module-local callees not written here yet */
extern void FDC_Set_Status(int);
extern void FDC_ResultPhase_Read(void);
extern void FDC_Wait_Ready_Timeout(void);

/* The routines below take a byte but are called with it zero-extended to a word (`extz wa`): old-style
   definitions, called without a prototype, give exactly that.  Forward declarations keep the return types. */
unsigned char FDC_Read_Status();
unsigned char FDC_ReadDataRegister();
void FDC_Send_Command();
void FDC_WriteDataRegister();
void FDC_SendParameterByte();
void FDC_WriteAuxCmdByte();

unsigned char FDC_Read_Status()
{
    return *(unsigned char *)0x110008;
}

unsigned char FDC_ReadDataRegister()
{
    return *(unsigned char *)0x11000a;
}

void FDC_Send_Command(c)
unsigned char c;
{
    *(unsigned char *)0x110008 = c;
}

void FDC_WriteDataRegister(c)
unsigned char c;
{
    *(unsigned char *)0x11000a = c;
}

void FDC_WaitReady()
{
    unsigned int t, s;
    t = SYSTEM_TIMESTAMP;
    s = 128;
    while (s == 128) {
        if ((FDC_Read_Status() & 31) == 0) s = 0;
        if (SYSTEM_TIMESTAMP - t > 500) s = 0xffff;
    }
    if (s != 0) FDC_Set_Status(1);
}

void FDC_WaitParamByteReady()
{
    unsigned int t, s;
    t = SYSTEM_TIMESTAMP;
    s = 128;
    while (s == 128) {
        if ((FDC_Read_Status() & 0x90) == 0x90) s = 0;
        if (SYSTEM_TIMESTAMP - t > 500) s = 0xffff;
    }
    if (s != 0) FDC_Set_Status(1);
}

void FDC_SendCommandByte(c)
unsigned char c;
{
    FDC_ResultPhase_Read();
    FDC_WriteDataRegister(c);
}

void FDC_SendParameterByte(c)
unsigned char c;
{
    FDC_WaitParamByteReady();
    FDC_WriteDataRegister(c);
}

void FDC_WriteAuxCmdByte(c)
unsigned char c;
{
    FDC_ResultPhase_Read();
    FDC_Send_Command(c);
}

void FDC_SendAuxCmd(c)
unsigned char c;
{
    FDC_ResultPhase_Read();
    if (FDC_ERROR_CODE != 0) return;
    FDC_WriteAuxCmdByte(c);
}

void FDC_SendAuxCmdReadResult(c)
unsigned char c;
{
    FDC_ResultPhase_Read();
    if (FDC_ERROR_CODE != 0) return;
    FDC_WriteAuxCmdByte(c);
    FDC_Wait_Ready_Timeout();
    FDC_RESULT[1] = FDC_ReadDataRegister();
}

void FDC_SendParams_Specify()
{
    FDC_SendParameterByte((unsigned char)(FDC_SPECIFY_SRT << 4) | (FDC_SPECIFY_HUT & 15));
    FDC_SendParameterByte((unsigned char)(FDC_SPECIFY_HLT << 1) | (FDC_SPECIFY_ND & 1));
}

void FDC_SendParams_Format()
{
    FDC_SendParameterByte(FDC_PARAM_N & 7);
    FDC_SendParameterByte(FDC_FORMAT_SC);
    FDC_SendParameterByte(FDC_FORMAT_GPL);
    FDC_SendParameterByte(FDC_FORMAT_FILL);
}

void FDC_SendParam_SeekTrack()
{
    FDC_SendParameterByte(FDC_TARGET_TRACK);
}

void FDC_SendParams_ReadWrite()
{
    FDC_SendParameterByte(FDC_PARAM_C);
    FDC_SendParameterByte(FDC_PARAM_H & 1);
    FDC_SendParameterByte(FDC_PARAM_R);
    FDC_SendParameterByte(FDC_PARAM_N & 7);
    FDC_SendParameterByte(FDC_PARAM_EOT);
    FDC_SendParameterByte(FDC_PARAM_GPL);
    switch (FDC_CMD_OPCODE) {
    case 209:
    case 217:
    case 221:
        FDC_SendParameterByte(FDC_PARAM_STP & 3);
        return;
    }
    FDC_SendParameterByte(FDC_PARAM_DTL);
}

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
    }
    t = FDC_CMD_OPCODE & 31;
    if (t == 30 || t == 29 || t == 25) return 0;
    if (t == 16) return 1;
    if (t == 17) return 0;
    if (t > 15 || t < 2) return 1;
    return 0;
}

void FDC_CMD_SEND(c)
unsigned char c;
{
    FDC_WaitReady();
    if (FDC_ERROR_CODE != 0) return;
    FDC_CMD_OPCODE = c;
    if (FDC_ValidateOpcode() != 0) return;
    switch (c) {
    case 71:
    case 53:
    case 54:
        FDC_SendAuxCmd(c);
        return;
    case 52:
    case 51:
        FDC_SendAuxCmdReadResult(c);
        return;
    default:
        if ((unsigned char)(c & 0xef) == 79) {
            FDC_SendAuxCmdReadResult(c);
            break;
        }
        if ((c & 15) == 14 || (c & 15) == 11) {
            FDC_SendAuxCmdReadResult(c);
            break;
        }
        FDC_SendCommandByte(c);
        if (FDC_ERROR_CODE != 0) break;
        if (c == 8) break;
        if (c == 3) {
            FDC_SendParams_Specify();
            break;
        }
        FDC_SendParameterByte((unsigned char)(((FDC_HEAD & 1) << 2) | 1));
        switch (c) {
        case 74:
        case 4:
        case 7:
            break;
        case 77:
            FDC_SendParams_Format();
            break;
        case 15:
            FDC_SendParam_SeekTrack();
            break;
        default:
            FDC_SendParams_ReadWrite();
            break;
        }
        break;
    }
}
