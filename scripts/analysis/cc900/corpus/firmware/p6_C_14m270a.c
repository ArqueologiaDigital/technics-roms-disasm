/* Phase 6, lane_p6 helper C, round 14, module 270 (modules_v10.tsv) of v10 storage/fdc_routines.s, form a.
   Run 92 at -Xr: V4.23 copied FDC_PARAM_C into FDC_FORMAT_IDS[i] and the opcode parameter into FDC_CMD_OPCODE with
   memory-to-memory moves (a __near operand on one side); the ROM loads A and stores it.  The cells read or written
   that way are declared volatile here, to see whether that keeps V4.23 to load + store.  FDC_MC_EXIT_Code_Helper2's
   loop is written with its test copied to the entry (the ROM compares k with half there, unfolded: -Xr).
   Form b (p6_C_14m270b.c) declares the three counters in another order. */
/* cc900-module: FDC_WaitReady FDC_ValidateOpcode FDC_SendAuxCmd FDC_SendAuxCmdReadResult FDC_SendCommandByte FDC_SendParameterByte FDC_SendParams_Specify FDC_SendParams_Format FDC_SendParam_SeekTrack FDC_SendParams_ReadWrite */

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
    unsigned int half;
    unsigned int k;
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
            FDC_FORMAT_IDS[i++] = (unsigned char)(ram_8b0a >> 1) + FDC_PARAM_R;
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
