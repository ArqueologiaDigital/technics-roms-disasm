/* Functions of storage/fdc_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: FDC_ReadDataRegister FDC_Read_Status FDC_ResultPhase_Read FDC_SendAuxCmd FDC_SendAuxCmdReadResult FDC_SendCommandByte FDC_SendParam_SeekTrack FDC_SendParameterByte FDC_SendParams_Format FDC_SendParams_ReadWrite FDC_SendParams_Specify FDC_Send_Command FDC_Set_Status FDC_ValidateOpcode FDC_WaitParamByteReady FDC_WaitReady FDC_Wait_Ready_Timeout FDC_WriteAuxCmdByte FDC_WriteDataRegister */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near SYSTEM_TIMESTAMP;
extern void FDC_Set_Status(int);
unsigned char FDC_Read_Status();
extern unsigned char FDC_Read_Status();
extern void FDC_WaitParamByteReady();

void FDC_WaitParamByteReady()
{
    unsigned int t, s;
    t = SYSTEM_TIMESTAMP;
    s = 128;
    if (s == 128) do {
        if ((FDC_Read_Status() & 0x90) == 0x90) s = 0;
        if (SYSTEM_TIMESTAMP - t > 500) s = 0xffff;
    } while (s == 128);
    if (s != 0) FDC_Set_Status(1);
}

extern unsigned char __near FDC_ERROR_CODE;
extern volatile unsigned char __near FDC_CMD_OPCODE;
extern unsigned char __near FDC_HEAD;
extern unsigned char __near FDC_DRIVE;
extern void FDC_WaitReady(void);
extern unsigned char FDC_ValidateOpcode(void);
extern void FDC_SendAuxCmd(int);
extern void FDC_SendAuxCmdReadResult(int);
extern void FDC_SendCommandByte(int);
extern void FDC_SendParameterByte(int);
extern void FDC_SendParams_Specify(void);
extern void FDC_SendParams_Format(void);
extern void FDC_SendParam_SeekTrack(void);
extern void FDC_SendParams_ReadWrite(void);
extern void FDC_CMD_SEND(unsigned char c);

void FDC_CMD_SEND(unsigned char c)
{
    unsigned char hi, lo, t;
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
        break;
    }
    if ((unsigned char)(c & 0xef) == 79) {
        FDC_SendAuxCmdReadResult(c);
        return;
    }
    if ((c & 15) == 14 || (c & 15) == 11) {
        FDC_SendAuxCmdReadResult(c);
        return;
    }
    FDC_SendCommandByte(c);
    if (FDC_ERROR_CODE != 0) return;
    if (c == 8) return;
    if (c == 3) {
        FDC_SendParams_Specify();
        return;
    }
    hi = (FDC_HEAD & 1) << 2;
    lo = FDC_DRIVE & 3;
    t = hi | lo;
    FDC_SendParameterByte(hi | 1);
    switch (c) {
    case 74:
    case 4:
    case 7:
        return;
    case 77:
        FDC_SendParams_Format();
        return;
    case 15:
        FDC_SendParam_SeekTrack();
        return;
    default:
        FDC_SendParams_ReadWrite();
    }
}
