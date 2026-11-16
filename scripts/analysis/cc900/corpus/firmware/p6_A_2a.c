/* Phase 6, lane_p6 helper A, round 2, form a: leaf functions of v10's sequencer/accompaniment_engine.s under their
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

/* V4.23 allocates bit fields from the top bit down (probe bitf), so bank (bits 0..6 of byte 1) is declared after top. */
struct pstyle { unsigned char prog : 8; unsigned char top : 1; unsigned char bank : 7; unsigned char b2, b3, b4, b5; };
extern struct pstyle __near PANEL_STYLE;

/* Round-1 forms gave memory-to-memory moves at -Xr; the ROM copies through WA / A: locals, reused. */
void AccVoice_SavePartState1(void)
{
    unsigned char c;
    unsigned int w;
    ACC_PART_FLAGS &= 0xfc;
    ACC_BAD_EVENT_COUNT = 0;
    c = 1;
    ACC_PART_BIT = c;
    w = ACC_LANE_BLOCK[0];
    ACC_CUR_BLOCK = w;
    w = ACC_LANE_READ_POS[0];
    ACC_CUR_READ_POS = w;
    c = ACC_LANE_BAR[0];
    ACC_CUR_BAR = c;
    c = ACC_LANE_BEAT_POS[0];
    ACC_CUR_BEAT_POS = c;
    c = ACC_LANE_SECTION[0];
    ACC_CUR_SECTION = c;
    c = ACC_LANE_MEASURE[0];
    ACC_CUR_MEASURE = c;
}

void AccCh1_SaveState(void)
{
    unsigned char c;
    unsigned int w;
    ACC_PART_FLAGS &= 0xfc;
    ACC_BAD_EVENT_COUNT = 0;
    c = 4;
    ACC_PART_BIT = c;
    w = ACC_LANE_BLOCK[2];
    ACC_CUR_BLOCK = w;
    w = ACC_LANE_READ_POS[2];
    ACC_CUR_READ_POS = w;
    c = ACC_LANE_BAR[2];
    ACC_CUR_BAR = c;
    c = ACC_LANE_BEAT_POS[2];
    ACC_CUR_BEAT_POS = c;
    c = ACC_LANE_SECTION[2];
    ACC_CUR_SECTION = c;
    c = ACC_LANE_MEASURE[2];
    ACC_CUR_MEASURE = c;
}

void AccCh2_SaveState(void)
{
    unsigned char c;
    unsigned int w;
    ACC_PART_FLAGS &= 0xfc;
    ACC_BAD_EVENT_COUNT = 0;
    c = 8;
    ACC_PART_BIT = c;
    w = ACC_LANE_BLOCK[3];
    ACC_CUR_BLOCK = w;
    w = ACC_LANE_READ_POS[3];
    ACC_CUR_READ_POS = w;
    c = ACC_LANE_BAR[3];
    ACC_CUR_BAR = c;
    c = ACC_LANE_BEAT_POS[3];
    ACC_CUR_BEAT_POS = c;
    c = ACC_LANE_SECTION[3];
    ACC_CUR_SECTION = c;
    c = ACC_LANE_MEASURE[3];
    ACC_CUR_MEASURE = c;
}

void AccCh3_SaveState(void)
{
    unsigned char c;
    unsigned int w;
    ACC_PART_FLAGS &= 0xfc;
    ACC_BAD_EVENT_COUNT = 0;
    c = 16;
    ACC_PART_BIT = c;
    w = ACC_LANE_BLOCK[4];
    ACC_CUR_BLOCK = w;
    w = ACC_LANE_READ_POS[4];
    ACC_CUR_READ_POS = w;
    c = ACC_LANE_BAR[4];
    ACC_CUR_BAR = c;
    c = ACC_LANE_BEAT_POS[4];
    ACC_CUR_BEAT_POS = c;
    c = ACC_LANE_SECTION[4];
    ACC_CUR_SECTION = c;
    c = ACC_LANE_MEASURE[4];
    ACC_CUR_MEASURE = c;
}

void AccCh4_SaveState(void)
{
    unsigned char c;
    unsigned int w;
    ACC_PART_FLAGS &= 0xfc;
    ACC_BAD_EVENT_COUNT = 0;
    c = 32;
    ACC_PART_BIT = c;
    w = ACC_LANE_BLOCK[5];
    ACC_CUR_BLOCK = w;
    w = ACC_LANE_READ_POS[5];
    ACC_CUR_READ_POS = w;
    c = ACC_LANE_BAR[5];
    ACC_CUR_BAR = c;
    c = ACC_LANE_BEAT_POS[5];
    ACC_CUR_BEAT_POS = c;
    c = ACC_LANE_SECTION[5];
    ACC_CUR_SECTION = c;
    c = ACC_LANE_MEASURE[5];
    ACC_CUR_MEASURE = c;
}

void AccVoice_RestorePartState1(void)
{
    unsigned char c;
    unsigned int w;
    w = ACC_CUR_BLOCK;
    ACC_LANE_BLOCK[0] = w;
    w = ACC_CUR_READ_POS;
    ACC_LANE_READ_POS[0] = w;
    c = ACC_CUR_BAR;
    ACC_LANE_BAR[0] = c;
    c = ACC_CUR_BEAT_POS;
    ACC_LANE_BEAT_POS[0] = c;
    c = ACC_CUR_SECTION;
    ACC_LANE_SECTION[0] = c;
    c = ACC_CUR_MEASURE;
    ACC_LANE_MEASURE[0] = c;
}

void AccKbd2_RestoreState(void)
{
    unsigned char c;
    unsigned int w;
    w = ACC_CUR_BLOCK;
    ACC_LANE_BLOCK[1] = w;
    w = ACC_CUR_READ_POS;
    ACC_LANE_READ_POS[1] = w;
    c = ACC_CUR_BAR;
    ACC_LANE_BAR[1] = c;
    c = ACC_CUR_BEAT_POS;
    ACC_LANE_BEAT_POS[1] = c;
    c = ACC_CUR_SECTION;
    ACC_LANE_SECTION[1] = c;
    c = ACC_CUR_MEASURE;
    ACC_LANE_MEASURE[1] = c;
}

void AccCh1_RestoreState(void)
{
    unsigned char c;
    unsigned int w;
    w = ACC_CUR_BLOCK;
    ACC_LANE_BLOCK[2] = w;
    w = ACC_CUR_READ_POS;
    ACC_LANE_READ_POS[2] = w;
    c = ACC_CUR_BAR;
    ACC_LANE_BAR[2] = c;
    c = ACC_CUR_BEAT_POS;
    ACC_LANE_BEAT_POS[2] = c;
    c = ACC_CUR_SECTION;
    ACC_LANE_SECTION[2] = c;
    c = ACC_CUR_MEASURE;
    ACC_LANE_MEASURE[2] = c;
}

void AccCh2_RestoreState(void)
{
    unsigned char c;
    unsigned int w;
    w = ACC_CUR_BLOCK;
    ACC_LANE_BLOCK[3] = w;
    w = ACC_CUR_READ_POS;
    ACC_LANE_READ_POS[3] = w;
    c = ACC_CUR_BAR;
    ACC_LANE_BAR[3] = c;
    c = ACC_CUR_BEAT_POS;
    ACC_LANE_BEAT_POS[3] = c;
    c = ACC_CUR_SECTION;
    ACC_LANE_SECTION[3] = c;
    c = ACC_CUR_MEASURE;
    ACC_LANE_MEASURE[3] = c;
}

void AccCh3_RestoreState(void)
{
    unsigned char c;
    unsigned int w;
    w = ACC_CUR_BLOCK;
    ACC_LANE_BLOCK[4] = w;
    w = ACC_CUR_READ_POS;
    ACC_LANE_READ_POS[4] = w;
    c = ACC_CUR_BAR;
    ACC_LANE_BAR[4] = c;
    c = ACC_CUR_BEAT_POS;
    ACC_LANE_BEAT_POS[4] = c;
    c = ACC_CUR_SECTION;
    ACC_LANE_SECTION[4] = c;
    c = ACC_CUR_MEASURE;
    ACC_LANE_MEASURE[4] = c;
}

void AccCh4_RestoreState(void)
{
    unsigned char c;
    unsigned int w;
    w = ACC_CUR_BLOCK;
    ACC_LANE_BLOCK[5] = w;
    w = ACC_CUR_READ_POS;
    ACC_LANE_READ_POS[5] = w;
    c = ACC_CUR_BAR;
    ACC_LANE_BAR[5] = c;
    c = ACC_CUR_BEAT_POS;
    ACC_LANE_BEAT_POS[5] = c;
    c = ACC_CUR_SECTION;
    ACC_LANE_SECTION[5] = c;
    c = ACC_CUR_MEASURE;
    ACC_LANE_MEASURE[5] = c;
}

/* The ROM keeps the program in L all through: return it, so that it lives in L. */
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
    if (p >= 128) {
        if (RHYTHM_LOAD_PART < 16)
            RHYTHM_LOAD_PART = 26;
    } else {
        if (RHYTHM_LOAD_PART >= 16)
            RHYTHM_LOAD_PART = 26;
    }
    if (RHYTHM_LOAD_PART == 26) {
        c = ram_34cd & 0x30;
        if (c == 0) STYLE_SECTION = 30;
        else if (c == 0x20) STYLE_SECTION = 31;
        else STYLE_SECTION = 32;
    } else if (STYLE_SECTION >= 30) {
        c = ram_34cd & 0x30;
        if (c == 0) STYLE_SECTION = 0;
        else if (c == 0x20) STYLE_SECTION = 4;
        else STYLE_SECTION = 8;
    }
    return p;
}

void AccPatch_VoiceAssignDataBlock_Helper21(void)
{
    switch (ram_3950) {
    case 129: GLOBAL_ERROR_CODE = 1; break;
    case 131: GLOBAL_ERROR_CODE = 23; break;
    case 130: GLOBAL_ERROR_CODE = 0; break;
    case 132: GLOBAL_ERROR_CODE = 3; break;
    case 0: GLOBAL_ERROR_CODE = 35; break;
    default: GLOBAL_ERROR_CODE = 1; break;
    }
}

void AccSynchro_UpdateArmed(void)
{
    unsigned char a;
    if (SEQ_REC_TRACKS != 0 || SEQ_TRACK_MASK != 0 || CMP_RECORD_PART != 0)
        goto off;
    a = PANEL_STYLE.b3;
    if (a & 8)
        goto off;
    a &= 7;
    if (a == 0)
        goto off;
    if ((PANEL_STYLE.b5 & 2) == 0)
        goto off;
    ACC_SYNCHRO_STATE |= 0x80;
    return;
off:
    ACC_SYNCHRO_STATE = 0;
}

/* One pointer variable for both steps, so that it stays in one register (the ROM's XDE). */
unsigned char AccTone_LookupByProgram(unsigned char a)
{
    unsigned char *p;
    p = AccTone_LookupByProgram_Table_2[(unsigned char)(a - 0xf0)];
    p = (unsigned char *)0x94860 + RhythmTiming_OffsetTable[*p];
    return AccTone_LookupByProgram_Table[p[12]];
}

struct mcell { unsigned int blk, off; };

unsigned int AccVoice_BarCounterBytecodeData_Helper2(unsigned char a, unsigned char b, unsigned char c)
{
    int o;
    o = b * 32 + c * 4;
    return ((struct mcell *)((unsigned char *)0x95440 + (unsigned long)a * 160 + o))->off;
}

unsigned int AccVoice_GetMeasureStartBlock(unsigned char a, unsigned char b, unsigned char c)
{
    int o;
    o = b * 32 + c * 4;
    return *(unsigned int *)((unsigned char *)0x95440 + (unsigned long)a * 160 + o);
}

void AccPatch_FetchStepEntry(unsigned char a)
{
    unsigned char *p;
    int i;
    p = (unsigned char *)0x366a;
    i = ram_360a;
    p[i] = a;
    i++;
    ram_360a = i;
}

void MIDIChan_ScanForFree(void)
{
    unsigned char *p;
    unsigned char i;
    p = (unsigned char *)0xf1a0;
    i = 1;
    do {
        if (*p == 0x10)
            break;
        p++;
        i++;
    } while (i <= 0x11);
    if (i > 0x10)
        ram_3996 = 0;
    else
        ram_3996 = i;
}

char Part_IsPercussionType(unsigned char a)
{
    unsigned char t;
    t = ((unsigned char *)0xf1a0)[(unsigned char)(a - 1)];
    if (t == 0xd || t == 0xe || t == 0xf || t == 0x10)
        return 1;
    return 0;
}

/* New in round 2. */
void SeqRec_CheckOverflow(unsigned char *p, unsigned char n, unsigned char b)
{
    unsigned char *q;
    q = p + 1;
    if (n >= 0xf0) {
        *p = n & 0xf;
        *q = b;
        return;
    }
    *p = 0;
    *q = 0;
}

void AccVoice_IncrementBarCounter(void)
{
    unsigned char m;
    m = ACC_CUR_MEASURE + 1;
    ACC_CUR_MEASURE = m;
    if (m <= (*(unsigned char **)0x3426)[13])
        return;
    ACC_CUR_MEASURE = 0;
}

void CmpNcp_ResetPatternToVari1(void)
{
    if (PANEL_STYLE.prog >= 128)
        RHYTHM_LOAD_PART = 16;
    else
        RHYTHM_LOAD_PART = 0;
}

void CmpNcp_LatchPanelRhythmAsSource(void)
{
    unsigned char p, b;
    p = PANEL_STYLE.prog;
    b = PANEL_STYLE.bank;
    RHYTHM_LOAD_PROGRAM = p;
    RHYTHM_LOAD_BANK = b;
}

void AccDraw_Secondary_Helper11(void)
{
    unsigned char s;
    unsigned char d;
    s = SQSTEP_CURSOR_STEP;
    if (s != 0)
        s--;
    d = 32;
    ram_39b9 = (unsigned int)(s & 127) / d;
}

void AccPatch_ReadVoiceStride(void)
{
    STYLE_SECTION_BEATS = *(AccTone_LookupByProgram_Table + (unsigned long)STYLE_SECTION_TIME_SIG);
}

void Part_StoreVoiceTableIndex(unsigned char a)
{
    ram_3980 = ram_398f * 5 + a;
    ram_3984 = 6;
}

unsigned char *VoiceTable_ResolveReadAddr(void)
{
    unsigned long o;
    unsigned long r;
    o = ram_3982;
    r = (unsigned long)(ram_397e - 1) << 8;
    r += 0xb0000;
    r += o;
    return (unsigned char *)r;
}

unsigned char *Voice_ResolveTableAddr(void)
{
    unsigned long o;
    unsigned long r;
    o = ram_3984;
    r = (unsigned long)ram_3980 << 8;
    r += 0x95c00;
    r += o;
    return (unsigned char *)r;
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

/* -O routines (lda constants); the end pointers are computed from the start pointer (V4.23 bug 11). */
void StyleBuf_ClearAllEntries(void)
{
    unsigned char *p, *e, *q, *qe;
    p = (unsigned char *)0x3f88;
    e = p + 2048;
    do {
        q = p;
        qe = p + 32;
        do {
            *q++ = 0;
        } while (q < qe);
        p += 32;
    } while (p < e);
}

void StyleConv_ClearEntryTables(void)
{
    unsigned long *l, *le;
    unsigned char *p, *q, *qe;
    l = (unsigned long *)0x4788;
    p = (unsigned char *)0x3f88;
    le = l + 64;
    do {
        q = p;
        qe = p + 32;
        do {
            *q++ = 0;
        } while (q < qe);
        *l++ = 0;
        p += 32;
    } while (l < le);
}

void StyleFile_ClearAllTables(void)
{
    unsigned long *l, *le;
    unsigned char *p, *q, *qe;
    l = (unsigned long *)0x555c;
    p = (unsigned char *)0x48dc;
    le = l + 32;
    do {
        q = p;
        qe = p + 100;
        do {
            *q++ = 0;
        } while (q < qe);
        *l++ = 0;
        p += 100;
    } while (l < le);
}
