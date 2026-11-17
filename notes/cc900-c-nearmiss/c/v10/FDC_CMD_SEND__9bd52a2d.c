/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/fdc_routines_m270_xr.c (2026-11-16-122-p6-r24-staged)
   sha256 9bd52a2db165585ca76682c4c23fca8aa6c9d3162f381618411066aff6aef096 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
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
