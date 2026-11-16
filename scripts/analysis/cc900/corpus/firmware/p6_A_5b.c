/* Phase 6, lane_p6 helper A, round 5, form b: routines WITH calls of v10 sequencer/accompaniment_engine.s, under
   their firmware names (or a short C name mapped by cc900-name).  One declaration per __near name. */
extern unsigned char __near ACC_REQ_ENDING;
extern unsigned char __near ACC_REQ_FILLIN;
extern unsigned char __near ACC_REQ_INTRO;
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near ACTIVE_TITLE;
extern unsigned char __near ACC_CLOCK;
extern unsigned char __near ACC_BEAT;
extern unsigned char __near ram_327f;
extern unsigned char __near ram_3280;
extern unsigned int __near ram_327d;
extern unsigned char __near ACC_LANES_ENDED;
extern unsigned char __near ACC_LANE_BEAT_POS[];
extern unsigned char __near ram_32b1;
extern unsigned char __near ACC_BAR_COUNT;
extern unsigned char __near ACC_SECTION_BAR;
extern unsigned char __near ram_32b4;
extern unsigned char __near ACC_LANE_BAR[];
extern unsigned char __near ram_32bb;
extern unsigned char __near ram_334d;
extern unsigned char __near ram_32bd;
extern unsigned char __near ram_32be;
extern unsigned char __near ram_32bf;
extern unsigned char __near ram_32c0;
extern unsigned char __near ram_32c1;
extern unsigned char __near ram_32c2;
extern unsigned char __near ram_3385;
extern unsigned char __near ram_3386;
extern unsigned char __near ram_3387;
extern unsigned char __near ram_3388;
extern unsigned char __near ram_3389;
extern unsigned char __near ram_338a;
extern unsigned int __near STYLE_FREE_BLOCKS;
extern unsigned char __near ram_39ab;
extern unsigned char __near ram_3284;
extern unsigned char __near ACC_LANES_RESYNC;
extern unsigned char __near ram_32ec;
extern unsigned char __near CMP_SOLO;
extern unsigned char __near CMP_RECORD_PART;
extern unsigned char __near STYLE_SECTION_BEATS;
extern char __near SWBTWR_PAYLOAD_1;
extern char __near CURRENT_TITLE;
extern unsigned char __near SWBTWR_PAYLOAD_2;
extern unsigned char __near SWBTWR_PAYLOAD_3;
extern unsigned char __near ram_3540;
extern unsigned char RHYTHM_PATTERN_BUF_A[];
extern void AddswbWr(int, int, int, int);
extern void ApDeliveryEvent(unsigned long, unsigned long, unsigned long);
extern void AccTone_CallWithSaveAll(void);
extern unsigned long Math_Multiply32(unsigned long, unsigned long);
extern unsigned long Math_DivideU32(unsigned long, unsigned long);
extern void SeqEvt_CallTimingHelper(void);
extern void Voice_UpdatePlayModeState(void);
extern void AccChord_ReadAndStoreKeys(void);
extern void AccChord_CompareAndSetDirty(void);
extern void Rhythm_CompareAndTrigger(void);
extern void RhythmPart_CopyData(void);
extern void RhythmPart1_ProcessAccentData(void);
extern void RhythmPart2_ProcessAccentData(void);
extern void RhythmPart3_ProcessAccentData(void);
extern void RhythmPart4_ProcessAccentData(void);
extern void RhythmPart5_ProcessAccentData(void);
extern void RhythmConfig_ReturnStub(void);
extern void Rhythm_LoadCurrentTimeSig(void);
extern void CmpNcp_LatchPanelRhythmAsSource(void);

/* cc900-name: AccVoice_BarCntBcData_Helper9=AccVoice_BarCounterBytecodeData_Helper9 */
void AccVoice_BarCntBcData_Helper9(void)
{
    ACC_REQ_ENDING &= 0xfd;
    PANEL_STYLE[5] &= 0xdf;
    AddswbWr(0x48, 5, 0, 0);
}

/* cc900-name: AccVoice_BarCntBcData_Helper8=AccVoice_BarCounterBytecodeData_Helper8 */
void AccVoice_BarCntBcData_Helper8(void)
{
    ACC_REQ_ENDING &= 0xfe;
    PANEL_STYLE[5] &= 0xef;
    AddswbWr(0x48, 5, 0, 0);
}

/* cc900-name: AccVoice_BarCntBcData_Helper3=AccVoice_BarCounterBytecodeData_Helper3 */
void AccVoice_BarCntBcData_Helper3(void)
{
    ACC_REQ_FILLIN &= 0xfe;
    PANEL_STYLE[5] &= 0xbf;
    AddswbWr(0x48, 5, 0, 0);
}

/* cc900-name: AccVoice_BarCntBcData_Helper10=AccVoice_BarCounterBytecodeData_Helper10 */
void AccVoice_BarCntBcData_Helper10(void)
{
    ACC_REQ_FILLIN &= 0xfd;
    PANEL_STYLE[5] &= 0x7f;
    AddswbWr(0x48, 5, 0, 0);
}

/* cc900-name: AccTone_InlBcData_H3_Helper=AccTone_InlineBytecodeData_Code_Helper3_Helper */
void AccTone_InlBcData_H3_Helper(void)
{
    ACC_REQ_INTRO &= 0xfd;
    PANEL_STYLE[5] &= 0xf7;
    AddswbWr(0x48, 5, 0, 0);
}

/* cc900-name: AccTone_InlBcData_H3_Helper2=AccTone_InlineBytecodeData_Code_Helper3_Helper2 */
void AccTone_InlBcData_H3_Helper2(void)
{
    ACC_REQ_INTRO &= 0xfe;
    PANEL_STYLE[5] &= 0xfb;
    AddswbWr(0x48, 5, 0, 0);
}

/* cc900-name: AccTone_InlBcData_H3_Helper3=AccTone_InlineBytecodeData_Code_Helper3_Helper3 */
void AccTone_InlBcData_H3_Helper3(void)
{
    ACC_REQ_INTRO &= 0xfb;
    PANEL_STYLE[6] &= 0xfb;
    AddswbWr(0x48, 6, 0, 0);
}

void AccStyle_ResetAllVoiceState(void)
{
    ACC_CLOCK = 0;
    ACC_BEAT = 0;
    ram_327f = 0;
    ram_3280 = 0;
    ram_327d = 0;
    ACC_LANES_ENDED = 0;
    ACC_LANE_BEAT_POS[0] = 0;
    ACC_LANE_BEAT_POS[1] = 0;
    ram_32b1 = 0;
    ACC_LANE_BEAT_POS[2] = 0;
    ACC_LANE_BEAT_POS[3] = 0;
    ACC_LANE_BEAT_POS[4] = 0;
    ACC_LANE_BEAT_POS[5] = 0;
    ACC_BAR_COUNT = 0;
    ACC_SECTION_BAR = 0;
    ram_32b4 = 0;
    ACC_LANE_BAR[0] = 0;
    ACC_LANE_BAR[1] = 0;
    ram_32bb = 0;
    ACC_LANE_BAR[2] = 0;
    ACC_LANE_BAR[3] = 0;
    ACC_LANE_BAR[4] = 0;
    ACC_LANE_BAR[5] = 0;
    ram_334d = 0;
    ram_32bd = 0;
    ram_32be = 0;
    ram_32bf = 0;
    ram_32c0 = 0;
    ram_32c1 = 0;
    ram_32c2 = 0;
    ram_3385 = 0;
    ram_3386 = 0;
    ram_3387 = 0;
    ram_3388 = 0;
    ram_3389 = 0;
    ram_338a = 0;
    AccTone_CallWithSaveAll();
}

void SoundCtrl_SendAccTempo(void)
{
    if (ACTIVE_TITLE == 181)
        ApDeliveryEvent(0xb5001eL, 0x1c0000bL, 0L);
}

void AccSeq_DeliverC9_0009(void)
{
    if (ACTIVE_TITLE == 201)
        ApDeliveryEvent(0xc90009L, 0x1c0000bL, 0L);
}

/* The ROM calls the C runtime's 32-bit multiply / divide (Math_Multiply32, Math_DivideU32) by their tree names. */
void SoundCtrl_CalcScaledTempo(void)
{
    unsigned long r;
    r = 100;
    r = Math_Multiply32(r, (unsigned long)STYLE_FREE_BLOCKS);
    r = Math_DivideU32(r, 190L);
    if (r > 99)
        r = 99;
    ram_39ab = (unsigned char)r;
}

void AccTiming_CallHelper(void)
{
    if ((ram_3284 & 2) == 0)
        return;
    SeqEvt_CallTimingHelper();
    Voice_UpdatePlayModeState();
    AccChord_ReadAndStoreKeys();
    AccChord_CompareAndSetDirty();
    Rhythm_CompareAndTrigger();
}

void AccNote_FlushAll(void)
{
    unsigned char a;
    if (ACC_LANES_RESYNC & 0x3f) {
        RhythmPart_CopyData();
        RhythmPart1_ProcessAccentData();
        a = 1;
        ram_32ec = a;
        RhythmPart2_ProcessAccentData();
        RhythmPart3_ProcessAccentData();
        RhythmPart4_ProcessAccentData();
        RhythmPart5_ProcessAccentData();
        ACC_LANES_RESYNC &= 0xc0;
    }
}

void DrumKit_UpdateStatusFlags(void)
{
    unsigned char a, w;
    w = CMP_SOLO;
    w &= 0xc2;
    if ((signed char)w < 0) {
        a = CMP_RECORD_PART;
        if (a & 0x10) w |= 0x3c;
        if (a & 0x08) w |= 0x39;
        if (a & 0x01) w |= 0x35;
        if (a & 0x02) w |= 0x2d;
        if (a & 0x04) w |= 0x1d;
    }
    CMP_SOLO = w;
}

void AccPatch_CheckConfigType(void)
{
    switch (STYLE_SECTION_BEATS) {
    case 6: case 8: case 4: case 3:
        RhythmConfig_ReturnStub();
    }
}

void AccPatch_CallParamLookup_Helper(void)
{
    char t;
    if (SWBTWR_PAYLOAD_1 == 0 && SWBTWR_PAYLOAD_2 < 128 && SWBTWR_PAYLOAD_3 != 0) {
        t = CURRENT_TITLE;
        if (t == (char)180 && (RHYTHM_PATTERN_BUF_A[16] & 1) == 0) {
            Rhythm_LoadCurrentTimeSig();
            ram_3540 = 7;
        }
    }
    if (SWBTWR_PAYLOAD_1 == 0 && SWBTWR_PAYLOAD_3 != 0) {
        t = CURRENT_TITLE;
        if (t == (char)184) {
            CmpNcp_LatchPanelRhythmAsSource();
            ((void (*)(void))0xf65bf7)();
            Rhythm_LoadCurrentTimeSig();
        }
    }
}
