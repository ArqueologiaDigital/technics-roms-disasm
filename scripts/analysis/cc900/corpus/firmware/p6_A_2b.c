/* Phase 6, lane_p6 helper A, round 2, form b: leaf functions of v10's sequencer/accompaniment_engine.s under their
   firmware names (refined misses of round 1 and new ones).  One declaration per __near name. */
extern unsigned char __near ACC_PART_FLAGS;
extern unsigned char __near ACC_BAD_EVENT_COUNT;
extern unsigned char __near ACC_PART_BIT;
extern unsigned int __near ACC_CUR_BLOCK;
extern unsigned int __near ACC_CUR_READ_POS;
extern unsigned char __near ACC_CUR_BAR;
extern unsigned char __near ACC_CUR_BEAT_POS;
extern unsigned char __near ACC_CUR_SECTION;
extern unsigned char __near ACC_CUR_MEASURE;
extern unsigned int __near ACC_LANE_BLOCK[];
extern unsigned int __near ACC_LANE_READ_POS[];
extern unsigned char __near ACC_LANE_BAR[];
extern unsigned char __near ACC_LANE_BEAT_POS[];
extern unsigned char __near ACC_LANE_SECTION[];
extern unsigned char __near ACC_LANE_MEASURE[];
extern char __near RHYTHM_LOAD_PROGRAM;
extern char __near RHYTHM_LOAD_BANK;
extern unsigned char __near RHYTHM_LOAD_PART;
extern unsigned char __near STYLE_SECTION;
extern unsigned char __near ram_34cd;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern unsigned char __near ram_3950;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near CMP_RECORD_PART;
extern unsigned char __near ACC_SYNCHRO_STATE;
extern unsigned char *AccTone_LookupByProgram_Table_2[];
extern unsigned long RhythmTiming_OffsetTable[];
extern unsigned char AccTone_LookupByProgram_Table[];
extern int __near ram_360a;
extern unsigned char __near ram_3996;
extern unsigned char __near STYLE_SECTION_TIME_SIG;
extern unsigned char __near STYLE_SECTION_BEATS;
extern unsigned char __near ram_398f;
extern unsigned int __near ram_3980;
extern unsigned int __near ram_3984;
extern unsigned int __near ram_3982;
extern unsigned int __near ram_397e;
extern unsigned char __near SQSTEP_CURSOR_STEP;
extern unsigned char __near ram_39b9;

extern char __near PANEL_STYLE[];

void AccVoice_SavePartState1(void)
{
    unsigned char b, bar, beat, sec, mea;
    unsigned int blk, pos;
    ACC_PART_FLAGS &= 0xfc;
    ACC_BAD_EVENT_COUNT = 0;
    b = 1;
    ACC_PART_BIT = b;
    blk = ACC_LANE_BLOCK[0];
    ACC_CUR_BLOCK = blk;
    pos = ACC_LANE_READ_POS[0];
    ACC_CUR_READ_POS = pos;
    bar = ACC_LANE_BAR[0];
    ACC_CUR_BAR = bar;
    beat = ACC_LANE_BEAT_POS[0];
    ACC_CUR_BEAT_POS = beat;
    sec = ACC_LANE_SECTION[0];
    ACC_CUR_SECTION = sec;
    mea = ACC_LANE_MEASURE[0];
    ACC_CUR_MEASURE = mea;
}

void AccCh1_SaveState(void)
{
    unsigned char b, bar, beat, sec, mea;
    unsigned int blk, pos;
    ACC_PART_FLAGS &= 0xfc;
    ACC_BAD_EVENT_COUNT = 0;
    b = 4;
    ACC_PART_BIT = b;
    blk = ACC_LANE_BLOCK[2];
    ACC_CUR_BLOCK = blk;
    pos = ACC_LANE_READ_POS[2];
    ACC_CUR_READ_POS = pos;
    bar = ACC_LANE_BAR[2];
    ACC_CUR_BAR = bar;
    beat = ACC_LANE_BEAT_POS[2];
    ACC_CUR_BEAT_POS = beat;
    sec = ACC_LANE_SECTION[2];
    ACC_CUR_SECTION = sec;
    mea = ACC_LANE_MEASURE[2];
    ACC_CUR_MEASURE = mea;
}

void AccCh2_SaveState(void)
{
    unsigned char b, bar, beat, sec, mea;
    unsigned int blk, pos;
    ACC_PART_FLAGS &= 0xfc;
    ACC_BAD_EVENT_COUNT = 0;
    b = 8;
    ACC_PART_BIT = b;
    blk = ACC_LANE_BLOCK[3];
    ACC_CUR_BLOCK = blk;
    pos = ACC_LANE_READ_POS[3];
    ACC_CUR_READ_POS = pos;
    bar = ACC_LANE_BAR[3];
    ACC_CUR_BAR = bar;
    beat = ACC_LANE_BEAT_POS[3];
    ACC_CUR_BEAT_POS = beat;
    sec = ACC_LANE_SECTION[3];
    ACC_CUR_SECTION = sec;
    mea = ACC_LANE_MEASURE[3];
    ACC_CUR_MEASURE = mea;
}

void AccCh3_SaveState(void)
{
    unsigned char b, bar, beat, sec, mea;
    unsigned int blk, pos;
    ACC_PART_FLAGS &= 0xfc;
    ACC_BAD_EVENT_COUNT = 0;
    b = 16;
    ACC_PART_BIT = b;
    blk = ACC_LANE_BLOCK[4];
    ACC_CUR_BLOCK = blk;
    pos = ACC_LANE_READ_POS[4];
    ACC_CUR_READ_POS = pos;
    bar = ACC_LANE_BAR[4];
    ACC_CUR_BAR = bar;
    beat = ACC_LANE_BEAT_POS[4];
    ACC_CUR_BEAT_POS = beat;
    sec = ACC_LANE_SECTION[4];
    ACC_CUR_SECTION = sec;
    mea = ACC_LANE_MEASURE[4];
    ACC_CUR_MEASURE = mea;
}

void AccCh4_SaveState(void)
{
    unsigned char b, bar, beat, sec, mea;
    unsigned int blk, pos;
    ACC_PART_FLAGS &= 0xfc;
    ACC_BAD_EVENT_COUNT = 0;
    b = 32;
    ACC_PART_BIT = b;
    blk = ACC_LANE_BLOCK[5];
    ACC_CUR_BLOCK = blk;
    pos = ACC_LANE_READ_POS[5];
    ACC_CUR_READ_POS = pos;
    bar = ACC_LANE_BAR[5];
    ACC_CUR_BAR = bar;
    beat = ACC_LANE_BEAT_POS[5];
    ACC_CUR_BEAT_POS = beat;
    sec = ACC_LANE_SECTION[5];
    ACC_CUR_SECTION = sec;
    mea = ACC_LANE_MEASURE[5];
    ACC_CUR_MEASURE = mea;
}

void AccVoice_RestorePartState1(void)
{
    unsigned char bar, beat, sec, mea;
    unsigned int blk, pos;
    blk = ACC_CUR_BLOCK;
    ACC_LANE_BLOCK[0] = blk;
    pos = ACC_CUR_READ_POS;
    ACC_LANE_READ_POS[0] = pos;
    bar = ACC_CUR_BAR;
    ACC_LANE_BAR[0] = bar;
    beat = ACC_CUR_BEAT_POS;
    ACC_LANE_BEAT_POS[0] = beat;
    sec = ACC_CUR_SECTION;
    ACC_LANE_SECTION[0] = sec;
    mea = ACC_CUR_MEASURE;
    ACC_LANE_MEASURE[0] = mea;
}

void AccKbd2_RestoreState(void)
{
    unsigned char bar, beat, sec, mea;
    unsigned int blk, pos;
    blk = ACC_CUR_BLOCK;
    ACC_LANE_BLOCK[1] = blk;
    pos = ACC_CUR_READ_POS;
    ACC_LANE_READ_POS[1] = pos;
    bar = ACC_CUR_BAR;
    ACC_LANE_BAR[1] = bar;
    beat = ACC_CUR_BEAT_POS;
    ACC_LANE_BEAT_POS[1] = beat;
    sec = ACC_CUR_SECTION;
    ACC_LANE_SECTION[1] = sec;
    mea = ACC_CUR_MEASURE;
    ACC_LANE_MEASURE[1] = mea;
}

void AccCh1_RestoreState(void)
{
    unsigned char bar, beat, sec, mea;
    unsigned int blk, pos;
    blk = ACC_CUR_BLOCK;
    ACC_LANE_BLOCK[2] = blk;
    pos = ACC_CUR_READ_POS;
    ACC_LANE_READ_POS[2] = pos;
    bar = ACC_CUR_BAR;
    ACC_LANE_BAR[2] = bar;
    beat = ACC_CUR_BEAT_POS;
    ACC_LANE_BEAT_POS[2] = beat;
    sec = ACC_CUR_SECTION;
    ACC_LANE_SECTION[2] = sec;
    mea = ACC_CUR_MEASURE;
    ACC_LANE_MEASURE[2] = mea;
}

void AccCh2_RestoreState(void)
{
    unsigned char bar, beat, sec, mea;
    unsigned int blk, pos;
    blk = ACC_CUR_BLOCK;
    ACC_LANE_BLOCK[3] = blk;
    pos = ACC_CUR_READ_POS;
    ACC_LANE_READ_POS[3] = pos;
    bar = ACC_CUR_BAR;
    ACC_LANE_BAR[3] = bar;
    beat = ACC_CUR_BEAT_POS;
    ACC_LANE_BEAT_POS[3] = beat;
    sec = ACC_CUR_SECTION;
    ACC_LANE_SECTION[3] = sec;
    mea = ACC_CUR_MEASURE;
    ACC_LANE_MEASURE[3] = mea;
}

void AccCh3_RestoreState(void)
{
    unsigned char bar, beat, sec, mea;
    unsigned int blk, pos;
    blk = ACC_CUR_BLOCK;
    ACC_LANE_BLOCK[4] = blk;
    pos = ACC_CUR_READ_POS;
    ACC_LANE_READ_POS[4] = pos;
    bar = ACC_CUR_BAR;
    ACC_LANE_BAR[4] = bar;
    beat = ACC_CUR_BEAT_POS;
    ACC_LANE_BEAT_POS[4] = beat;
    sec = ACC_CUR_SECTION;
    ACC_LANE_SECTION[4] = sec;
    mea = ACC_CUR_MEASURE;
    ACC_LANE_MEASURE[4] = mea;
}

void AccCh4_RestoreState(void)
{
    unsigned char bar, beat, sec, mea;
    unsigned int blk, pos;
    blk = ACC_CUR_BLOCK;
    ACC_LANE_BLOCK[5] = blk;
    pos = ACC_CUR_READ_POS;
    ACC_LANE_READ_POS[5] = pos;
    bar = ACC_CUR_BAR;
    ACC_LANE_BAR[5] = bar;
    beat = ACC_CUR_BEAT_POS;
    ACC_LANE_BEAT_POS[5] = beat;
    sec = ACC_CUR_SECTION;
    ACC_LANE_SECTION[5] = sec;
    mea = ACC_CUR_MEASURE;
    ACC_LANE_MEASURE[5] = mea;
}


unsigned char CmpRecSet_OnRhythmBank_Code_Helper2(void)
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
    if (p < 128)
        goto low;
    if (RHYTHM_LOAD_PART < 16)
        RHYTHM_LOAD_PART = 26;
join:
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
    return p;
low:
    if (RHYTHM_LOAD_PART >= 16)
        RHYTHM_LOAD_PART = 26;
    goto join;
}

void AccPatch_VoiceAssignDataBlock_Helper21(void)
{
    switch (ram_3950) {
    default: GLOBAL_ERROR_CODE = 1; break;
    case 132: GLOBAL_ERROR_CODE = 3; break;
    case 131: GLOBAL_ERROR_CODE = 23; break;
    case 129: GLOBAL_ERROR_CODE = 1; break;
    case 130: GLOBAL_ERROR_CODE = 0; break;
    case 0: GLOBAL_ERROR_CODE = 35; break;
    }
}

void AccSynchro_UpdateArmed(void)
{
    char a;
    if (SEQ_REC_TRACKS == 0 && SEQ_TRACK_MASK == 0 && CMP_RECORD_PART == 0) {
        a = PANEL_STYLE[3];
        if ((a & 8) == 0 && (a & 7) != 0 && (PANEL_STYLE[5] & 2) != 0) {
            ACC_SYNCHRO_STATE |= 0x80;
            return;
        }
    }
    ACC_SYNCHRO_STATE = 0;
}

unsigned char AccTone_LookupByProgram(unsigned char a)
{
    unsigned char *p;
    unsigned char *r;
    p = AccTone_LookupByProgram_Table_2[(unsigned char)(a - 0xf0)];
    r = (unsigned char *)0x94860 + RhythmTiming_OffsetTable[*p];
    return AccTone_LookupByProgram_Table[r[12]];
}

struct mcell { unsigned int blk, off; };

unsigned int AccVoice_BarCounterBytecodeData_Helper2(unsigned char a, unsigned char b, unsigned char c)
{
    unsigned int o;
    struct mcell *m;
    o = c * 4 + b * 32;
    m = (struct mcell *)((unsigned char *)0x95440 + (unsigned long)a * 160 + (int)o);
    return m->off;
}

unsigned int AccVoice_GetMeasureStartBlock(unsigned char a, unsigned char b, unsigned char c)
{
    unsigned int o;
    o = c * 4 + b * 32;
    return *(unsigned int *)((unsigned char *)0x95440 + (unsigned long)a * 160 + (int)o);
}

void AccPatch_FetchStepEntry(unsigned char a)
{
    ((unsigned char *)0x366a)[ram_360a] = a;
    ram_360a++;
}

void MIDIChan_ScanForFree(void)
{
    unsigned char *p;
    unsigned char i;
    p = (unsigned char *)0xf1a0;
    for (i = 1; i <= 0x11; i++) {
        if (*p == 0x10)
            break;
        p++;
    }
    if (i <= 0x10)
        ram_3996 = i;
    else
        ram_3996 = 0;
}

char Part_IsPercussionType(unsigned char a)
{
    unsigned char t;
    char r;
    t = *((unsigned char *)0xf1a0 + (unsigned char)(a - 1));
    if (t == 0xd || t == 0xe || t == 0xf || t == 0x10)
        r = 1;
    else
        r = 0;
    return r;
}

void SeqRec_CheckOverflow(unsigned char *p, unsigned char n, unsigned char b)
{
    unsigned char *q;
    q = p + 1;
    if (n >= 0xf0) {
        *p = n & 0xf;
        *q = b;
    } else {
        *p = 0;
        *q = 0;
    }
}

void AccVoice_IncrementBarCounter(void)
{
    unsigned char m;
    unsigned char *r;
    m = ACC_CUR_MEASURE + 1;
    ACC_CUR_MEASURE = m;
    r = *(unsigned char **)0x3426;
    if (m > r[13])
        ACC_CUR_MEASURE = 0;
}

void CmpNcp_ResetPatternToVari1(void)
{
    if ((PANEL_STYLE[0] & 0xff) >= 128)
        RHYTHM_LOAD_PART = 16;
    else
        RHYTHM_LOAD_PART = 0;
}

void CmpNcp_LatchPanelRhythmAsSource(void)
{
    char p, b;
    p = PANEL_STYLE[0] & 0xff;
    b = PANEL_STYLE[1] & 0x7f;
    RHYTHM_LOAD_PROGRAM = p;
    RHYTHM_LOAD_BANK = b;
}

void AccDraw_Secondary_Helper11(void)
{
    unsigned int s;
    unsigned char d;
    s = SQSTEP_CURSOR_STEP;
    if (s != 0)
        s--;
    s &= 127;
    d = 32;
    ram_39b9 = s / d;
}

void AccPatch_ReadVoiceStride(void)
{
    STYLE_SECTION_BEATS = AccTone_LookupByProgram_Table[STYLE_SECTION_TIME_SIG];
}

void Part_StoreVoiceTableIndex(unsigned char a)
{
    unsigned int x;
    x = a;
    ram_3980 = ram_398f * 5 + x;
    ram_3984 = 6;
}

unsigned char *VoiceTable_ResolveReadAddr(void)
{
    return (unsigned char *)0xb0000 + ((unsigned long)(ram_397e - 1) << 8) + ram_3982;
}

unsigned char *Voice_ResolveTableAddr(void)
{
    return (unsigned char *)0x95c00 + ((unsigned long)ram_3980 << 8) + ram_3984;
}

void AccVoice_ClearChannelStates(void)
{
    ACC_LANE_MEASURE[0] = 0;
    ACC_LANE_MEASURE[1] = 0;
    ACC_LANE_MEASURE[2] = 0;
    ACC_LANE_MEASURE[3] = 0;
    ACC_LANE_MEASURE[4] = 0;
    ACC_LANE_MEASURE[5] = 0;
}

void StyleBuf_ClearAllEntries(void)
{
    unsigned char *p, *e, *q, *qe;
    p = (unsigned char *)0x3f88;
    e = p + 2048;
    while (p < e) {
        q = p;
        qe = p + 32;
        while (q < qe)
            *q++ = 0;
        p += 32;
    }
}

void StyleConv_ClearEntryTables(void)
{
    unsigned long *l, *le;
    unsigned char *p, *q, *qe;
    l = (unsigned long *)0x4788;
    p = (unsigned char *)0x3f88;
    le = l + 64;
    while (l < le) {
        q = p;
        qe = p + 32;
        while (q < qe)
            *q++ = 0;
        *l++ = 0;
        p += 32;
    }
}

void StyleFile_ClearAllTables(void)
{
    unsigned long *l, *le;
    unsigned char *p, *q, *qe;
    l = (unsigned long *)0x555c;
    p = (unsigned char *)0x48dc;
    le = l + 32;
    while (l < le) {
        q = p;
        qe = p + 100;
        while (q < qe)
            *q++ = 0;
        *l++ = 0;
        p += 100;
    }
}
