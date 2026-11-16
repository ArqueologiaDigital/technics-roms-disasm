/* Phase 6, lane_p6 helper C, round 7, form b: big routines whose only blocker is a calr to a routine of the same
   hand source (callees declared extern here), from v10 sequencer/accompaniment_engine.s and storage/fdc_routines.s.
   Form a (p6_C_7a.c) has the same names. */

/* __near: the ROM reaches the cell with a 16-bit absolute operand. */
extern unsigned char __near ram_330c;
extern unsigned char __near ACC_PENDING_ENDING;
extern unsigned char __near ACC_DEFER_ENDING_LANES;
extern unsigned char __near ACC_PENDING_INTRO;
extern unsigned char __near ACC_PENDING_FILLIN;
extern unsigned char __near ACC_DEFER_SECTION_LANES;
extern unsigned char __near FDC_ERROR_CODE;
extern unsigned char __near FDC_CMD_OPCODE;
extern unsigned char __near FDC_HEAD;
extern unsigned char __near FDC_DRIVE;
extern unsigned char __near ram_8d88;
extern unsigned char __near ram_3988;
extern unsigned char __near ram_34cd;
extern unsigned int __near ram_398a;
extern unsigned int __near ram_398c;
extern unsigned char __near ram_e3e0;
extern unsigned char __near ram_33e0;
extern unsigned char __near ram_3421;
extern unsigned char __near ACC_LANE_MEASURE[];
extern unsigned int __near ACC_LANE_BLOCK[];
extern unsigned int __near ACC_LANE_READ_POS[];

extern void AccSection_SwitchNow(void);
extern void FDC_WaitReady(void);
extern unsigned char FDC_ValidateOpcode(void);
extern void FDC_SendAuxCmd(int);
extern void FDC_SendAuxCmdReadResult(int);
extern void FDC_SendCommandByte(int);
extern void FDC_SendParams_Specify(void);
extern void FDC_SendParameterByte(int);
extern void FDC_SendParams_Format(void);
extern void FDC_SendParam_SeekTrack(void);
extern void FDC_SendParams_ReadWrite(void);
extern unsigned char Tempo_DisplayParamReturn(void);
extern void Tempo_DisplayParamSkipClear(int);
extern void Tempo_DisplayParamCommon(int, int);
extern void MIDI_SendSysExCmd(int);
extern unsigned int AccVoice_GetMeasureStartBlock(int, int, int);
/* cc900-name: AccVoice_BCBD_Helper2=AccVoice_BarCounterBytecodeData_Helper2 */
extern unsigned int AccVoice_BCBD_Helper2(int, int, int);

/* cc900-name: AccSection_SwitchNowUnlessDefer=AccSection_SwitchNowUnlessDeferred */
void AccSection_SwitchNowUnlessDefer(void)
{
    if ((ram_330c & 1) || (ACC_PENDING_ENDING & 3)) {
        if (!(ACC_DEFER_ENDING_LANES & 0x3f)) goto sw;
    }
    if (!(ACC_PENDING_INTRO & 0xd) && !(ACC_PENDING_FILLIN & 3)) return;
    if (ACC_DEFER_SECTION_LANES & 0x3f) return;
sw:
    AccSection_SwitchNow();
}

void FDC_CMD_SEND(unsigned char c)
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

void Tempo_EditBPM(unsigned char a)
{
    unsigned char r;
    if (a != 0) return;
    ram_8d88 |= 1;
    r = Tempo_DisplayParamReturn();
    ram_3988 = r;
    if (r == 1) {
        Tempo_DisplayParamSkipClear(0xf);
        MIDI_SendSysExCmd(8);
    } else if (r == 0) Tempo_DisplayParamSkipClear(0x23);
    ram_34cd |= 0x80;
    ram_34cd |= 0x80;
}

void Tempo_EditParam92(unsigned char dir)
{
    unsigned int v, w, m;
    Tempo_DisplayParamCommon(146, 18);
    v = ram_398a;
    if (dir == 0) {
        if (v >= 999) return;
        if (v >= 989) ram_398a = 999;
        else ram_398a = v + 10;
    } else {
        if (v <= 1) return;
        if (v <= 10) ram_398a = 1;
        else ram_398a = v - 10;
    }
    m = ram_398c;
    w = ram_398a;
    if (w > m) ram_398c = w;
    else if ((w += 7) < m) ram_398c = w;
    ram_e3e0 |= 0x10;
}

void Tempo_EditParam93(unsigned char dir)
{
    unsigned int v, b;
    Tempo_DisplayParamCommon(147, 19);
    v = ram_398c;
    if (dir == 0) {
        if (v >= 999) return;
        if (v >= 989) ram_398c = 999;
        else ram_398c = v + 10;
    } else {
        if (v <= 1) return;
        if (v <= 10) ram_398c = 1;
        else ram_398c = v - 10;
    }
    v = ram_398c;
    b = ram_398a;
    if (b > v) ram_398a = v;
    else if ((b += 7) < v) ram_398a = v - 7;
    ram_e3e0 |= 0x10;
}

void AccVoice_BarCounterBytecodeData(void)
{
    ram_33e0 = 0;
    ACC_LANE_BLOCK[0] = AccVoice_GetMeasureStartBlock(ram_3421, 0, ACC_LANE_MEASURE[0]);
    if (ACC_LANE_BLOCK[0] == 0xfffe) ram_33e0 |= 1;
    ACC_LANE_READ_POS[0] = AccVoice_BCBD_Helper2(ram_3421, 0, ACC_LANE_MEASURE[0]);
    ACC_LANE_BLOCK[2] = AccVoice_GetMeasureStartBlock(ram_3421, 1, ACC_LANE_MEASURE[2]);
    if (ACC_LANE_BLOCK[2] == 0xfffe) ram_33e0 |= 4;
    ACC_LANE_READ_POS[2] = AccVoice_BCBD_Helper2(ram_3421, 1, ACC_LANE_MEASURE[2]);
    ACC_LANE_BLOCK[3] = AccVoice_GetMeasureStartBlock(ram_3421, 2, ACC_LANE_MEASURE[3]);
    if (ACC_LANE_BLOCK[3] == 0xfffe) ram_33e0 |= 8;
    ACC_LANE_READ_POS[3] = AccVoice_BCBD_Helper2(ram_3421, 2, ACC_LANE_MEASURE[3]);
    ACC_LANE_BLOCK[4] = AccVoice_GetMeasureStartBlock(ram_3421, 3, ACC_LANE_MEASURE[4]);
    if (ACC_LANE_BLOCK[4] == 0xfffe) ram_33e0 |= 0x10;
    ACC_LANE_READ_POS[4] = AccVoice_BCBD_Helper2(ram_3421, 3, ACC_LANE_MEASURE[4]);
    ACC_LANE_BLOCK[5] = AccVoice_GetMeasureStartBlock(ram_3421, 4, ACC_LANE_MEASURE[5]);
    if (ACC_LANE_BLOCK[5] == 0xfffe) ram_33e0 |= 0x20;
    ACC_LANE_READ_POS[5] = AccVoice_BCBD_Helper2(ram_3421, 4, ACC_LANE_MEASURE[5]);
    ACC_LANE_BLOCK[1] = 0xfffe;
    ACC_LANE_READ_POS[1] = 6;
    ram_33e0 |= 2;
}
