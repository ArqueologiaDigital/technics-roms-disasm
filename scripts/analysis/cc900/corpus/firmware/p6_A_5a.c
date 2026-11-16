/* Phase 6, lane_p6 helper A, round 5, form a: routines WITH calls of v10 sequencer/accompaniment_engine.s, under
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
extern unsigned char __near SWBTWR_PAYLOAD_1;
extern unsigned char __near CURRENT_TITLE;
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
    ACC_REQ_ENDING &= ~0x2;
    PANEL_STYLE[5] &= ~0x20;
    AddswbWr(72, 5, 0, 0);
}

/* cc900-name: AccVoice_BarCntBcData_Helper8=AccVoice_BarCounterBytecodeData_Helper8 */
void AccVoice_BarCntBcData_Helper8(void)
{
    ACC_REQ_ENDING &= ~0x1;
    PANEL_STYLE[5] &= ~0x10;
    AddswbWr(72, 5, 0, 0);
}

/* cc900-name: AccVoice_BarCntBcData_Helper3=AccVoice_BarCounterBytecodeData_Helper3 */
void AccVoice_BarCntBcData_Helper3(void)
{
    ACC_REQ_FILLIN &= ~0x1;
    PANEL_STYLE[5] &= ~0x40;
    AddswbWr(72, 5, 0, 0);
}

/* cc900-name: AccVoice_BarCntBcData_Helper10=AccVoice_BarCounterBytecodeData_Helper10 */
void AccVoice_BarCntBcData_Helper10(void)
{
    ACC_REQ_FILLIN &= ~0x2;
    PANEL_STYLE[5] &= ~0x80;
    AddswbWr(72, 5, 0, 0);
}

/* cc900-name: AccTone_InlBcData_H3_Helper=AccTone_InlineBytecodeData_Code_Helper3_Helper */
void AccTone_InlBcData_H3_Helper(void)
{
    ACC_REQ_INTRO &= ~0x2;
    PANEL_STYLE[5] &= ~0x8;
    AddswbWr(72, 5, 0, 0);
}

/* cc900-name: AccTone_InlBcData_H3_Helper2=AccTone_InlineBytecodeData_Code_Helper3_Helper2 */
void AccTone_InlBcData_H3_Helper2(void)
{
    ACC_REQ_INTRO &= ~0x1;
    PANEL_STYLE[5] &= ~0x4;
    AddswbWr(72, 5, 0, 0);
}

/* cc900-name: AccTone_InlBcData_H3_Helper3=AccTone_InlineBytecodeData_Code_Helper3_Helper3 */
void AccTone_InlBcData_H3_Helper3(void)
{
    ACC_REQ_INTRO &= ~0x4;
    PANEL_STYLE[6] &= ~0x4;
    AddswbWr(72, 6, 0, 0);
}

void AccStyle_ResetAllVoiceState(void)
{
    unsigned int z;
    z = 0;
    ACC_CLOCK = z;
    ACC_BEAT = z;
    ram_327f = z;
    ram_3280 = z;
    ram_327d = z;
    ACC_LANES_ENDED = z;
    ACC_LANE_BEAT_POS[0] = z;
    ACC_LANE_BEAT_POS[1] = z;
    ram_32b1 = z;
    ACC_LANE_BEAT_POS[2] = z;
    ACC_LANE_BEAT_POS[3] = z;
    ACC_LANE_BEAT_POS[4] = z;
    ACC_LANE_BEAT_POS[5] = z;
    ACC_BAR_COUNT = z;
    ACC_SECTION_BAR = z;
    ram_32b4 = z;
    ACC_LANE_BAR[0] = z;
    ACC_LANE_BAR[1] = z;
    ram_32bb = z;
    ACC_LANE_BAR[2] = z;
    ACC_LANE_BAR[3] = z;
    ACC_LANE_BAR[4] = z;
    ACC_LANE_BAR[5] = z;
    ram_334d = z;
    ram_32bd = z;
    ram_32be = z;
    ram_32bf = z;
    ram_32c0 = z;
    ram_32c1 = z;
    ram_32c2 = z;
    ram_3385 = z;
    ram_3386 = z;
    ram_3387 = z;
    ram_3388 = z;
    ram_3389 = z;
    ram_338a = z;
    AccTone_CallWithSaveAll();
}

void SoundCtrl_SendAccTempo(void)
{
    if (ACTIVE_TITLE != 181)
        return;
    ApDeliveryEvent(0xb5001eL, 0x1c0000bL, 0L);
}

void AccSeq_DeliverC9_0009(void)
{
    if (ACTIVE_TITLE != 201)
        return;
    ApDeliveryEvent(0xc90009L, 0x1c0000bL, 0L);
}

void SoundCtrl_CalcScaledTempo(void)
{
    unsigned long r;
    r = 100L * STYLE_FREE_BLOCKS / 190;
    if (r > 99)
        r = 99;
    ram_39ab = (unsigned char)r;
}

void AccTiming_CallHelper(void)
{
    if (ram_3284 & 2) {
        SeqEvt_CallTimingHelper();
        Voice_UpdatePlayModeState();
        AccChord_ReadAndStoreKeys();
        AccChord_CompareAndSetDirty();
        Rhythm_CompareAndTrigger();
    }
}

void AccNote_FlushAll(void)
{
    unsigned char a;
    if ((ACC_LANES_RESYNC & 0x3f) == 0)
        return;
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

void DrumKit_UpdateStatusFlags(void)
{
    unsigned char w, a;
    w = CMP_SOLO & 0xc2;
    if (w & 0x80) {
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
    if (STYLE_SECTION_BEATS == 6 || STYLE_SECTION_BEATS == 8 || STYLE_SECTION_BEATS == 4 || STYLE_SECTION_BEATS == 3)
        RhythmConfig_ReturnStub();
}

void AccPatch_CallParamLookup_Helper(void)
{
    unsigned char *p;
    if (SWBTWR_PAYLOAD_1 == 0 && SWBTWR_PAYLOAD_2 < 128 && SWBTWR_PAYLOAD_3 != 0 && CURRENT_TITLE == 180) {
        p = RHYTHM_PATTERN_BUF_A + 0;
        if ((p[16] & 1) == 0) {
            Rhythm_LoadCurrentTimeSig();
            ram_3540 = 7;
        }
    }
    if (SWBTWR_PAYLOAD_1 == 0 && SWBTWR_PAYLOAD_3 != 0 && CURRENT_TITLE == 184) {
        CmpNcp_LatchPanelRhythmAsSource();
        ((void (*)(void))0xf65bf7)();   /* AccPatch_ComplexDataBlock_Helper2: its 33-char name cannot be looked up */
        Rhythm_LoadCurrentTimeSig();
    }
}
