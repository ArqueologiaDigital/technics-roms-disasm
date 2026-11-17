/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_14m270a.c (2026-11-16-100-p6-r19)
   sha256 6c3516c0efbb2789f143e2893e5a8c5b49201c6553cd44da1bd337cec8c77bdc (tar-sha256); compiled at -Xr */
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
        hi = (FDC_HEAD & 1) << 2;
        lo = FDC_DRIVE & 3;
        t = hi | lo;
        FDC_SendParameterByte(hi | 1);
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
