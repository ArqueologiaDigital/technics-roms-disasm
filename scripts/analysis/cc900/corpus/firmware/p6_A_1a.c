/* Phase 6, lane_p6 helper A, round 1, form a: leaf functions of v10's sequencer/accompaniment_engine.s, each under
   its firmware name.  Guesses for V4.23; form b (p6_A_1b.c) has the same functions written another way. */
/* Widths: RAM cells the ROM reaches with 16-bit absolute operands are __near; SEQ_CURRENT_SONG (24-bit in the ROM),
   PANEL_SW_HELD_*, the ROM tables and the arrays the ROM indexes from a 32-bit base register are plain (large). */
extern char __near RHYTHM_LOAD_PROGRAM;
extern char __near RHYTHM_LOAD_BANK;
extern char __near ram_327f;
extern unsigned char __near RHYTHM_LOAD_PART;
extern unsigned char __near STYLE_SECTION;
extern unsigned char __near ram_34cd;
extern unsigned char __near ram_32b3;
extern unsigned char __near ram_3280;
extern unsigned char __near STYLE_SECTION_BEATS;
extern unsigned char __near STYLE_SECTION_LAST_MEASURE;
extern unsigned char __near ACC_EVENT[];
extern unsigned char __near ram_34cf;
extern unsigned char __near ACTIVE_TITLE;
extern unsigned char __near CMP_RECORD_PART;
extern unsigned char __near ram_37c9;
extern unsigned char __near ACC_PART_BIT;
extern unsigned char __near ram_33e0;
extern unsigned char __near ACC_LANES_ENDING1;
extern unsigned char __near ACC_LANES_ENDING2;
extern unsigned char __near ACC_LANES_PARKED;
extern unsigned char __near ACC_LANES_ENDED;
extern unsigned char __near ACC_LANES_FILLIN1;
extern unsigned char __near ACC_LANES_FILLIN2;
extern unsigned char __near ACC_LANES_INTRO1;
extern unsigned char __near ACC_LANES_COUNTIN;
extern unsigned char __near ACC_LANES_INTRO2;
extern unsigned char __near ram_335d;
extern unsigned char __near ram_3329;
extern unsigned char __near ACC_CUR_MEASURE;
extern unsigned char __near ram_3490;
extern unsigned char __near ACC_LANES_RESYNC;
extern unsigned char __near ram_3246[];
extern unsigned char ACC_BASS_NOTES[], ACC_ACCOMP1_NOTES[], ACC_ACCOMP2_NOTES[], ACC_ACCOMP3_NOTES[];
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near PREVIOUS_TITLE;
extern unsigned char __near ram_3989;
extern unsigned char __near ram_398e;
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned char __near ram_398f;
extern unsigned char __near ram_3990;
extern unsigned char __near ram_3991;
extern unsigned char __near ram_3992;
extern unsigned char __near ram_3993;
extern unsigned char __near ram_3994;
extern unsigned char __near ram_3995;
extern unsigned char __near ram_3950;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern unsigned char __near ACC_PENDING_FILLIN;
extern unsigned char __near ACC_PART_FLAGS;
extern unsigned char __near ACC_BAD_EVENT_COUNT;
extern unsigned char __near ACC_LANE_BAR[];
extern unsigned char __near ACC_LANE_BEAT_POS[];
extern unsigned char __near ACC_LANE_SECTION[];
extern unsigned char __near ACC_LANE_MEASURE[];
extern unsigned char __near ACC_CUR_BAR;
extern unsigned char __near ACC_CUR_BEAT_POS;
extern unsigned char __near ACC_CUR_SECTION;
extern unsigned char __near ACC_SYNCHRO_STATE;
extern char __near PANEL_STYLE[];
extern unsigned char *AccTone_LookupByProgram_Table_2[], AccTone_LookupByProgram_Table[];
extern unsigned long RhythmTiming_OffsetTable[];
extern unsigned char __near ram_34d3;
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned char __near ram_3996;
extern unsigned char RHYTHM_PATTERN_BUF_A[], ram_366a[];
extern unsigned char __near CURRENT_MODE;
extern unsigned char __near ram_3525;
extern unsigned char __near ram_3510;
extern unsigned char __near ram_3601;
extern unsigned char __near ACC_RUN_FLAGS;
extern unsigned int __near ram_343d;
extern unsigned int __near ram_398a;
extern unsigned int __near ram_398c;
extern unsigned int __near ACC_CUR_BLOCK;
extern unsigned int __near ACC_CUR_READ_POS;
extern unsigned int __near ram_360a;
extern unsigned int __near SYSTEM_TIMESTAMP;
extern unsigned int __near TAP_TEMPO_LAST_TAP_TIME;
extern unsigned int __near ram_3492;
extern unsigned int __near ram_3494;
extern unsigned int __near ram_3496;
extern unsigned int __near ACC_LANE_BLOCK[];
extern unsigned int __near ACC_LANE_READ_POS[];
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned int *AccPatch_SeqBaseAddrTable[], *AccPatch_SeqPosition_Store_Data[];
extern unsigned long __near ram_11d0;
extern unsigned long __near ram_39e0;
extern unsigned long PANEL_SW_HELD_UP, PANEL_SW_HELD_DOWN;

void CmpRecSet_OnRhythmBank_Code_Helper2(void)
{
    unsigned char p;
    unsigned char c;
    p = RHYTHM_LOAD_PROGRAM & 0xff;
    if (p >= 240) {
        p = 128;
        RHYTHM_LOAD_PROGRAM = p;
        RHYTHM_LOAD_BANK = 0;
    }
    if (p >= 128 && (RHYTHM_LOAD_BANK & 0x7f) != 0)
        RHYTHM_LOAD_BANK = 0;
    if (p >= 128) {
        if (RHYTHM_LOAD_PART < 16)
            RHYTHM_LOAD_PART = 26;
    } else {
        if (RHYTHM_LOAD_PART >= 16)
            RHYTHM_LOAD_PART = 26;
    }
    if (RHYTHM_LOAD_PART == 26) {
        c = ram_34cd & 0x30;
        switch (c) {
        case 0: STYLE_SECTION = 30; break;
        case 0x20: STYLE_SECTION = 31; break;
        default: STYLE_SECTION = 32; break;
        }
    } else if (STYLE_SECTION >= 30) {
        c = ram_34cd & 0x30;
        switch (c) {
        case 0: STYLE_SECTION = 0; break;
        case 0x20: STYLE_SECTION = 4; break;
        default: STYLE_SECTION = 8; break;
        }
    }
}

void AccPatch_ComputeSeqPosition(void)
{
    unsigned char pos;
    char t;
    pos = ram_32b3 * STYLE_SECTION_BEATS + ram_3280;
    t = ram_327f + 0x18;
    if (t >= 0x60) {
        pos++;
        if ((unsigned char)(STYLE_SECTION_BEATS * (STYLE_SECTION_LAST_MEASURE + 1)) == pos)
            pos = 0;
    }
    **(unsigned int **)((char *)AccPatch_SeqBaseAddrTable + (unsigned char)(ACC_EVENT[1] << 1)) = pos + 6;
    **(unsigned int **)((char *)AccPatch_SeqPosition_Store_Data + (unsigned char)(ACC_EVENT[1] << 1)) = ram_343d;
}

void AccPatch_ReadModeFlags(void)
{
    ram_34cf &= 0xf3;
    if (ACTIVE_TITLE == 181) {
        ram_11d0 = PANEL_SW_HELD_UP | PANEL_SW_HELD_DOWN;
        ram_39e0 = PANEL_SW_HELD_DOWN;
        if ((ram_11d0 & 0x200) != 0 && (ram_39e0 & 0x200) == 0)
            ram_34cf |= 4;
        if ((ram_11d0 & 0x400) != 0 && (ram_39e0 & 0x400) == 0)
            ram_34cf |= 8;
    }
}

void TimeSig_DisplayStrings_Code_Helper4(void)
{
    CMP_RECORD_PART = 1;
    if (ram_37c9 & 0x10) return;
    CMP_RECORD_PART = 2;
    if (ram_37c9 & 0x20) return;
    CMP_RECORD_PART = 4;
    if (ram_37c9 & 0x40) return;
    CMP_RECORD_PART = 8;
    if (ram_37c9 & 0x08) return;
    CMP_RECORD_PART = 16;
}

void AccPart_Reactivate(void)
{
    unsigned char b;
    if ((ACC_PART_BIT & ram_33e0) == 0)
        return;
    b = ACC_PART_BIT;
    if (((ACC_LANES_ENDING1 | ACC_LANES_ENDING2) & b) != 0) {
        ACC_LANES_PARKED |= b;
        ACC_LANES_ENDED |= b;
        *(unsigned char *)&ACC_CUR_BLOCK = 254;
        *(unsigned char *)&ACC_CUR_READ_POS = 6;
    } else {
        b = ACC_PART_BIT ^ 0xff;
        ACC_LANES_FILLIN1 &= b;
        ACC_LANES_FILLIN2 &= b;
        ACC_LANES_INTRO1 &= b;
        ACC_LANES_COUNTIN &= b;
        ACC_LANES_INTRO2 &= b;
        ram_335d &= b;
        ram_3329 &= b;
        ACC_CUR_MEASURE = 0;
        *(unsigned char *)&ACC_CUR_BLOCK = 254;
        *(unsigned char *)&ACC_CUR_READ_POS = 6;
    }
}

void AccProcess_TimerCompare(void)
{
    unsigned int now, last;
    if (ram_3490 & 1) {
        now = SYSTEM_TIMESTAMP;
        last = TAP_TEMPO_LAST_TAP_TIME;
        if (now >= last) {
            if ((unsigned int)(now - last) >= 0x400) {
                ram_3490 &= 0xfe;
                ram_3496 = ram_3494 = ram_3492 = 0;
            }
        } else {
            if ((unsigned int)((unsigned long)now + 0x10000L - (unsigned long)last) >= 0x400) {
                ram_3490 &= 0xfe;
                ram_3496 = ram_3494 = ram_3492 = 0;
            }
        }
    }
}

void AccPedal_DirectionA_Wrap_Helper2(unsigned char bit)
{
    unsigned char *s;
    unsigned char *d;
    int i;
    s = *(unsigned char **)0x3426;   /* the record pointer at 0x3426 */
    i = ((unsigned char *)0xe4a01a)[bit];   /* AccTone_InlineBytecodeData_Data_2: 33-char name */
    d = ram_3246 + i * 7;
    s = s + (i * 8 + 24);
    d[0] = s[0];
    d[1] = s[1];
    d[2] = s[2];
    d[3] = s[3];
    d[4] = s[4];
    d[5] = s[5];
    d[6] = s[6];
    ACC_LANES_RESYNC |= bit;
}

void AccBuf_ResetByteData(void)
{
    unsigned int i;
    for (i = 0; i < 72; i += 9) ACC_BASS_NOTES[i] = 0;
    for (i = 0; i < 72; i += 9) ACC_ACCOMP1_NOTES[i] = 0;
    for (i = 0; i < 72; i += 9) ACC_ACCOMP2_NOTES[i] = 0;
    for (i = 0; i < 72; i += 9) ACC_ACCOMP3_NOTES[i] = 0;
}

void S2cTtl_InitOnTitleChange(void)
{
    if (CURRENT_TITLE == PREVIOUS_TITLE)
        return;
    ram_3989 = SEQ_CURRENT_SONG + 1;
    if (ram_398a != 0)
        return;
    ram_398a = 1;
    ram_398c = 1;
    ram_398e = 25;
    ram_398f = 0;
    ram_3990 = 0;
    ram_3991 = 0;
    ram_3992 = 0;
    ram_3993 = 0;
    ram_3994 = 0;
    ram_3995 = 0;
}

void AccPatch_VoiceAssignDataBlock_Helper21(void)
{
    switch (ram_3950) {
    case 132: GLOBAL_ERROR_CODE = 3; break;
    case 131: GLOBAL_ERROR_CODE = 23; break;
    case 129: GLOBAL_ERROR_CODE = 1; break;
    case 130: GLOBAL_ERROR_CODE = 0; break;
    case 0: GLOBAL_ERROR_CODE = 35; break;
    default: GLOBAL_ERROR_CODE = 1; break;
    }
}

unsigned long AccVoice_ComputeParamAddr(unsigned char a)
{
    unsigned int r;
    if (a < 0xf) {
        r = 0x18;
        if (!(ACC_PENDING_FILLIN & 1)) r = 0x1a;
    } else if (a < 0x14) {
        r = 0x1c;
        if (!(ACC_PENDING_FILLIN & 1)) r = 0x1e;
    } else if (a < 0x23) {
        r = 0x418;
        if (!(ACC_PENDING_FILLIN & 1)) r = 0x41a;
    } else {
        r = 0x41c;
        if (!(ACC_PENDING_FILLIN & 1)) r = 0x41e;
    }
    return r;
}

char AccPatch_ResolveEntryAddr_Helper17(void)
{
    char i, j, x, y;
    char *p;
    i = 0;
    j = 0;
    p = (char *)ACC_EVENT;
    while (i <= 2 && j <= 2) {
        x = p[i];
        if (x & 0x80) {
            i++;
            continue;
        }
        y = p[j];
        if (y & 0x80) {
            j++;
            continue;
        }
        if (x > y) i++;
        else j++;
    }
    if (i > 2) i = 0;
    return i;
}

void AccVoice_SavePartState1(void)
{
    ACC_PART_FLAGS &= 0xfc;
    ACC_BAD_EVENT_COUNT = 0;
    ACC_PART_BIT = 1;
    ACC_CUR_BLOCK = ACC_LANE_BLOCK[0];
    ACC_CUR_READ_POS = ACC_LANE_READ_POS[0];
    ACC_CUR_BAR = ACC_LANE_BAR[0];
    ACC_CUR_BEAT_POS = ACC_LANE_BEAT_POS[0];
    ACC_CUR_SECTION = ACC_LANE_SECTION[0];
    ACC_CUR_MEASURE = ACC_LANE_MEASURE[0];
}

void AccCh1_SaveState(void)
{
    ACC_PART_FLAGS &= 0xfc;
    ACC_BAD_EVENT_COUNT = 0;
    ACC_PART_BIT = 4;
    ACC_CUR_BLOCK = ACC_LANE_BLOCK[2];
    ACC_CUR_READ_POS = ACC_LANE_READ_POS[2];
    ACC_CUR_BAR = ACC_LANE_BAR[2];
    ACC_CUR_BEAT_POS = ACC_LANE_BEAT_POS[2];
    ACC_CUR_SECTION = ACC_LANE_SECTION[2];
    ACC_CUR_MEASURE = ACC_LANE_MEASURE[2];
}

void AccCh2_SaveState(void)
{
    ACC_PART_FLAGS &= 0xfc;
    ACC_BAD_EVENT_COUNT = 0;
    ACC_PART_BIT = 8;
    ACC_CUR_BLOCK = ACC_LANE_BLOCK[3];
    ACC_CUR_READ_POS = ACC_LANE_READ_POS[3];
    ACC_CUR_BAR = ACC_LANE_BAR[3];
    ACC_CUR_BEAT_POS = ACC_LANE_BEAT_POS[3];
    ACC_CUR_SECTION = ACC_LANE_SECTION[3];
    ACC_CUR_MEASURE = ACC_LANE_MEASURE[3];
}

void AccCh3_SaveState(void)
{
    ACC_PART_FLAGS &= 0xfc;
    ACC_BAD_EVENT_COUNT = 0;
    ACC_PART_BIT = 16;
    ACC_CUR_BLOCK = ACC_LANE_BLOCK[4];
    ACC_CUR_READ_POS = ACC_LANE_READ_POS[4];
    ACC_CUR_BAR = ACC_LANE_BAR[4];
    ACC_CUR_BEAT_POS = ACC_LANE_BEAT_POS[4];
    ACC_CUR_SECTION = ACC_LANE_SECTION[4];
    ACC_CUR_MEASURE = ACC_LANE_MEASURE[4];
}

void AccCh4_SaveState(void)
{
    ACC_PART_FLAGS &= 0xfc;
    ACC_BAD_EVENT_COUNT = 0;
    ACC_PART_BIT = 32;
    ACC_CUR_BLOCK = ACC_LANE_BLOCK[5];
    ACC_CUR_READ_POS = ACC_LANE_READ_POS[5];
    ACC_CUR_BAR = ACC_LANE_BAR[5];
    ACC_CUR_BEAT_POS = ACC_LANE_BEAT_POS[5];
    ACC_CUR_SECTION = ACC_LANE_SECTION[5];
    ACC_CUR_MEASURE = ACC_LANE_MEASURE[5];
}

void AccSynchro_UpdateArmed(void)
{
    char a;
    if (SEQ_REC_TRACKS == 0 && SEQ_TRACK_MASK == 0 && CMP_RECORD_PART == 0
        && ((a = PANEL_STYLE[3]) & 8) == 0 && (a & 7) != 0 && (PANEL_STYLE[5] & 2) != 0)
        ACC_SYNCHRO_STATE |= 0x80;
    else
        ACC_SYNCHRO_STATE = 0;
}

unsigned char AccTone_LookupByProgram(unsigned char a)
{
    return AccTone_LookupByProgram_Table[((unsigned char *)0x94860
        + RhythmTiming_OffsetTable[*AccTone_LookupByProgram_Table_2[(unsigned char)(a - 0xf0)]])[12]];
}

void RhythmProc_CheckRepeatFlag(void)
{
    unsigned char *p;
    unsigned char a;
    if (CURRENT_TITLE == 189 && (ram_34d3 & 2) != 0) {
        ram_34d3 &= 0xfd;
        p = RHYTHM_PATTERN_BUF_A + 0 + 0x10;
        a = *p & 0xfe;
        if (ram_34d3 & 1)
            a |= 1;
        *p = a;
    }
}

void AccVoice_RestorePartState1(void)
{
    ACC_LANE_BLOCK[0] = ACC_CUR_BLOCK;
    ACC_LANE_READ_POS[0] = ACC_CUR_READ_POS;
    ACC_LANE_BAR[0] = ACC_CUR_BAR;
    ACC_LANE_BEAT_POS[0] = ACC_CUR_BEAT_POS;
    ACC_LANE_SECTION[0] = ACC_CUR_SECTION;
    ACC_LANE_MEASURE[0] = ACC_CUR_MEASURE;
}

void AccKbd2_RestoreState(void)
{
    ACC_LANE_BLOCK[1] = ACC_CUR_BLOCK;
    ACC_LANE_READ_POS[1] = ACC_CUR_READ_POS;
    ACC_LANE_BAR[1] = ACC_CUR_BAR;
    ACC_LANE_BEAT_POS[1] = ACC_CUR_BEAT_POS;
    ACC_LANE_SECTION[1] = ACC_CUR_SECTION;
    ACC_LANE_MEASURE[1] = ACC_CUR_MEASURE;
}

void AccCh1_RestoreState(void)
{
    ACC_LANE_BLOCK[2] = ACC_CUR_BLOCK;
    ACC_LANE_READ_POS[2] = ACC_CUR_READ_POS;
    ACC_LANE_BAR[2] = ACC_CUR_BAR;
    ACC_LANE_BEAT_POS[2] = ACC_CUR_BEAT_POS;
    ACC_LANE_SECTION[2] = ACC_CUR_SECTION;
    ACC_LANE_MEASURE[2] = ACC_CUR_MEASURE;
}

void AccCh2_RestoreState(void)
{
    ACC_LANE_BLOCK[3] = ACC_CUR_BLOCK;
    ACC_LANE_READ_POS[3] = ACC_CUR_READ_POS;
    ACC_LANE_BAR[3] = ACC_CUR_BAR;
    ACC_LANE_BEAT_POS[3] = ACC_CUR_BEAT_POS;
    ACC_LANE_SECTION[3] = ACC_CUR_SECTION;
    ACC_LANE_MEASURE[3] = ACC_CUR_MEASURE;
}

void AccCh3_RestoreState(void)
{
    ACC_LANE_BLOCK[4] = ACC_CUR_BLOCK;
    ACC_LANE_READ_POS[4] = ACC_CUR_READ_POS;
    ACC_LANE_BAR[4] = ACC_CUR_BAR;
    ACC_LANE_BEAT_POS[4] = ACC_CUR_BEAT_POS;
    ACC_LANE_SECTION[4] = ACC_CUR_SECTION;
    ACC_LANE_MEASURE[4] = ACC_CUR_MEASURE;
}

void AccCh4_RestoreState(void)
{
    ACC_LANE_BLOCK[5] = ACC_CUR_BLOCK;
    ACC_LANE_READ_POS[5] = ACC_CUR_READ_POS;
    ACC_LANE_BAR[5] = ACC_CUR_BAR;
    ACC_LANE_BEAT_POS[5] = ACC_CUR_BEAT_POS;
    ACC_LANE_SECTION[5] = ACC_CUR_SECTION;
    ACC_LANE_MEASURE[5] = ACC_CUR_MEASURE;
}

unsigned int AccVoice_BarCounterBytecodeData_Helper2(unsigned char a, unsigned char b, unsigned char c)
{
    return *(unsigned int *)((unsigned char *)0x95440 + (unsigned long)a * 160 + (b * 32 + c * 4) + 2);
}

unsigned int AccVoice_GetMeasureStartBlock(unsigned char a, unsigned char b, unsigned char c)
{
    return *(unsigned int *)((unsigned char *)0x95440 + (unsigned long)a * 160 + (b * 32 + c * 4));
}

void SeqRec_OverflowCleanup(unsigned char *p, unsigned char n, unsigned char b)
{
    unsigned char *q;
    q = p + 1;
    if (n < 0xf0 && n >= 0x80 && b == 7) {
        n = 0x58;
    } else {
        if (n < 0xf0)
            goto keep;
        n = 0;
    }
    *p = n;
    *q = 0;
    return;
keep:
    *p = n;
    b &= ~0x80;
    *q = b;
}

void AccPatch_FetchStepEntry(unsigned char a)
{
    ram_366a[ram_360a] = a;
    ram_360a++;
}

char Part_IsPercussionType(unsigned char a)
{
    unsigned char t;
    t = SEQ_TRACK_ASSIGN[(unsigned char)(a - 1)];
    if (t == 0xd || t == 0xe || t == 0xf || t == 0x10)
        return 1;
    return 0;
}

void RhythmProc_SavePrevState(void)
{
    ram_3525 = CURRENT_TITLE;
    ram_3510 = CMP_RECORD_PART & 0x7f;
    ram_3601 = ACC_RUN_FLAGS;
    if (CURRENT_MODE != 14)
        CMP_RECORD_PART = 0;
}

void AccVoice_WriteEmptyPattern(unsigned char *p)
{
    unsigned int n;
    p += 6;
    n = (unsigned char)(STYLE_SECTION_LAST_MEASURE + 1) * STYLE_SECTION_BEATS;
    while (n != 0) {
        *p = 0x81;
        p++;
        n--;
    }
    *p = 0x83;
}

void MIDIChan_ScanForFree(void)
{
    unsigned char *p;
    unsigned char i;
    p = SEQ_TRACK_ASSIGN;
    for (i = 1; i <= 0x11; i++) {
        if (*p == 0x10)
            break;
        p++;
    }
    if (i > 0x10)
        ram_3996 = 0;
    else
        ram_3996 = i;
}
