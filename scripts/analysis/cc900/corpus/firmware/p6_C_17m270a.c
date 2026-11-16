/* Phase 6, lane_p6 helper C, round 17, module 270 (modules_v10.tsv) of v10 storage/fdc_routines.s, form a.
   From round 16 form b (run 107: FDC_CMD_SEND +13, FDC_MC_EXIT_Code_Helper2 +25):
   - FDC_MC_EXIT_Code_Helper2: the one difference was the else arm's sum.  V4.23 loaded the volatile FDC_PARAM_R
     into C before the shift and added C; the ROM adds the cell itself (add A,(mem)) after the shift.  Here that
     one read goes through a non-volatile pointer to the same cell.
   - FDC_CMD_SEND: V4.23 at -Xr placed both switches' compare chains after the case bodies, entered by a jump; the
     ROM has each chain first.  AudioInit_SelectPriority (built, -Xr) has its chain first and a default; so both
     switches get a default here (`default: break;` and the read/write call as the default).
   Form b (p6_C_17m270b.c) keeps the code after the first switch inside its default, and reads FDC_PARAM_R through
   a second, non-volatile name of the cell. */
/* cc900-module: FDC_SendAuxCmd FDC_SendAuxCmdReadResult FDC_SendCommandByte FDC_SendParam_SeekTrack FDC_SendParameterByte FDC_SendParams_Format FDC_SendParams_ReadWrite FDC_SendParams_Specify FDC_ValidateOpcode FDC_WaitReady */

/* __near: the ROM reaches the cell with a 16-bit absolute operand. */
extern unsigned char __near FDC_ERROR_CODE;
extern volatile unsigned char __near FDC_CMD_OPCODE;
extern unsigned char __near FDC_HEAD;
extern unsigned char __near FDC_DRIVE;
extern volatile unsigned char __near FDC_PARAM_C;
extern volatile unsigned char __near FDC_PARAM_H;
extern volatile unsigned char __near FDC_PARAM_R;
extern volatile unsigned char __near FDC_PARAM_N;
extern unsigned int __near FDC_SECTOR_COUNT;
extern unsigned int __near FDC_REQ_TRACK;
extern unsigned int __near ram_8b0a;
extern unsigned char __near FDC_FORMAT_IDS[];

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

void FDC_MC_EXIT_Code_Helper2(void)
{
    unsigned char i;
    unsigned int k, half;
    FDC_PARAM_R = 1;
    FDC_SECTOR_COUNT = 0;
    half = ram_8b0a >> 1;
    i = 0;
    k = 0;
    if (k < half) do {
        FDC_FORMAT_IDS[i++] = FDC_PARAM_C;
        FDC_SECTOR_COUNT++;
        FDC_FORMAT_IDS[i++] = FDC_PARAM_H;
        FDC_SECTOR_COUNT++;
        FDC_FORMAT_IDS[i++] = FDC_PARAM_R;
        FDC_SECTOR_COUNT++;
        FDC_FORMAT_IDS[i++] = FDC_PARAM_N;
        FDC_SECTOR_COUNT++;
        FDC_FORMAT_IDS[i++] = FDC_PARAM_C;
        FDC_SECTOR_COUNT++;
        FDC_FORMAT_IDS[i++] = FDC_PARAM_H;
        FDC_SECTOR_COUNT++;
        if (FDC_REQ_TRACK == 0) {
            FDC_PARAM_R++;
            FDC_FORMAT_IDS[i++] = FDC_PARAM_R;
        } else {
            FDC_FORMAT_IDS[i++] = (unsigned char)(ram_8b0a >> 1) + *(unsigned char *)&FDC_PARAM_R;
        }
        FDC_SECTOR_COUNT++;
        FDC_FORMAT_IDS[i++] = FDC_PARAM_N;
        FDC_SECTOR_COUNT++;
        FDC_PARAM_R++;
        k++;
    } while (k < half);
    if (!(ram_8b0a & 1)) return;
    FDC_FORMAT_IDS[i++] = FDC_PARAM_C;
    FDC_SECTOR_COUNT++;
    FDC_FORMAT_IDS[i++] = FDC_PARAM_H;
    FDC_SECTOR_COUNT++;
    FDC_FORMAT_IDS[i++] = ram_8b0a;
    FDC_SECTOR_COUNT++;
    FDC_FORMAT_IDS[i++] = FDC_PARAM_N;
    FDC_SECTOR_COUNT++;
}

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
