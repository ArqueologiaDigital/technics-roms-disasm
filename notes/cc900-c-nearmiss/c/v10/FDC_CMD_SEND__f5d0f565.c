/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_C_12m270b.c (2026-11-16-92-p6-r18)
   sha256 f5d0f56570c157c33efe566fd50ad73cf094fa0f67d3b4cd89567ae4b3895e1b (tar-sha256); compiled at -Xr */
/* Phase 6, lane_p6 helper C, round 12, module 270 (modules_v10.tsv) of v10 storage/fdc_routines.s, form b.
   The callees that matched in round 10 (p6_C_10m270.c) are only declared here: their byte parameter arrives
   zero-extended to a word, so an int prototype gives the callers' `extz wa`.
   - FDC_MC_EXIT_Code_Helper2: the FORMAT sector-ID table (C, H, R, N per sector, two sectors per pass).
   - FDC_SendParams_Specify / FDC_CMD_SEND: the ROM builds each two-field byte in E and C and ors them in A, so the
     fields are named locals here; FDC_CMD_SEND stores the opcode through a local (V4.23 made a memory-to-memory move).
   Form a (p6_C_12m270a.c) differs in the locals' spelling. */
/* cc900-module: FDC_WaitReady FDC_ValidateOpcode FDC_SendAuxCmd FDC_SendAuxCmdReadResult FDC_SendCommandByte FDC_SendParameterByte FDC_SendParams_Specify FDC_SendParams_Format FDC_SendParam_SeekTrack FDC_SendParams_ReadWrite */

/* __near: the ROM reaches the cell with a 16-bit absolute operand. */
extern unsigned char __near FDC_ERROR_CODE;
extern unsigned char __near FDC_CMD_OPCODE;
extern unsigned char __near FDC_HEAD;
extern unsigned char __near FDC_DRIVE;
extern unsigned char __near FDC_SPECIFY_SRT;
extern unsigned char __near FDC_SPECIFY_HUT;
extern unsigned char __near FDC_SPECIFY_HLT;
extern unsigned char __near FDC_SPECIFY_ND;
extern unsigned char __near FDC_PARAM_C;
extern unsigned char __near FDC_PARAM_H;
extern unsigned char __near FDC_PARAM_R;
extern unsigned char __near FDC_PARAM_N;
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
extern void FDC_SendParams_Format(void);
extern void FDC_SendParam_SeekTrack(void);
extern void FDC_SendParams_ReadWrite(void);

void FDC_MC_EXIT_Code_Helper2(void)
{
    unsigned int k, half;
    unsigned char i;
    FDC_PARAM_R = 1;
    FDC_SECTOR_COUNT = 0;
    half = ram_8b0a >> 1;
    i = 0;
    for (k = 0; k < half; k++) {
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
            unsigned char v = (unsigned char)(ram_8b0a >> 1) + FDC_PARAM_R;
            FDC_FORMAT_IDS[i++] = v;
        }
        FDC_SECTOR_COUNT++;
        FDC_FORMAT_IDS[i++] = FDC_PARAM_N;
        FDC_SECTOR_COUNT++;
        FDC_PARAM_R++;
    }
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

void FDC_SendParams_Specify(void)
{
    unsigned char hi;
    hi = FDC_SPECIFY_SRT << 4;
    FDC_SendParameterByte(hi | (FDC_SPECIFY_HUT & 15));
    hi = FDC_SPECIFY_HLT << 1;
    FDC_SendParameterByte(hi | (FDC_SPECIFY_ND & 1));
}

void FDC_CMD_SEND(unsigned char c)
{
    unsigned char hi, lo, t;
    FDC_WaitReady();
    if (FDC_ERROR_CODE != 0) return;
    FDC_CMD_OPCODE = (unsigned char)(c + 0);
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
