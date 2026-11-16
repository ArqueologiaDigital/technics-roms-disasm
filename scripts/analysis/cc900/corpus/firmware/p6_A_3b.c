/* Phase 6, lane_p6 helper A, round 3, form b: refined misses of rounds 1-2, v10 sequencer/accompaniment_engine.s,
   under their firmware names.  One declaration per __near name. */
extern char __near RHYTHM_LOAD_PROGRAM;
extern unsigned char __near RHYTHM_LOAD_BANK;
extern unsigned char __near RHYTHM_LOAD_PART;
extern unsigned char __near STYLE_SECTION;
extern unsigned char __near ram_34cd;
extern char __near PANEL_STYLE[];
extern unsigned char __near ACC_CUR_MEASURE;
extern unsigned char __near STYLE_SECTION_TIME_SIG;
extern unsigned char __near STYLE_SECTION_BEATS;
extern unsigned char AccTone_LookupByProgram_Table[];
extern unsigned char __near ram_398f;
extern unsigned int __near ram_3980;
extern unsigned int __near ram_3984;
extern int __near ram_360a;
extern unsigned char ram_366a[];
extern unsigned char __near ram_3f88[];
extern unsigned long __near ram_4788[];
extern unsigned long __near ram_555c[];
extern unsigned char __near ram_48dc[];

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
    if (p >= 128 && RHYTHM_LOAD_BANK % 128 != 0)
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

void CmpNcp_LatchPanelRhythmAsSource(void)
{
    char p;
    unsigned char b;
    p = PANEL_STYLE[0] & 0xff;
    b = PANEL_STYLE[1];
    b %= 128;
    RHYTHM_LOAD_PROGRAM = p;
    RHYTHM_LOAD_BANK = b;
}

void AccVoice_IncrementBarCounter(void)
{
    unsigned char *r;
    ACC_CUR_MEASURE = ACC_CUR_MEASURE + 1;
    r = *(unsigned char **)0x3426;
    if (ACC_CUR_MEASURE > r[13])
        ACC_CUR_MEASURE = 0;
}

void AccPatch_ReadVoiceStride(void)
{
    unsigned long i;
    unsigned char *t;
    i = STYLE_SECTION_TIME_SIG;
    t = AccTone_LookupByProgram_Table;
    t += i;
    STYLE_SECTION_BEATS = *t;
}

void Part_StoreVoiceTableIndex(unsigned char a)
{
    unsigned int x, y;
    x = a;
    y = ram_398f;
    y *= 5;
    y += x;
    ram_3980 = y;
    ram_3984 = 6;
}

unsigned char *Voice_ResolveTableAddr(void)
{
    unsigned long o, r;
    o = ram_3984;
    r = ram_3980;
    r <<= 8;
    r += 0x95c00;
    r += o;
    return (unsigned char *)r;
}

unsigned int AccVoice_GetMeasureStartBlock(unsigned char a, unsigned char b, unsigned char c)
{
    int i, j;
    j = c * 4;
    i = b * 32;
    return *(unsigned int *)((unsigned char *)0x95440 + (unsigned long)a * 160 + (i + j));
}

unsigned int AccVoice_BarCounterBytecodeData_Helper2(unsigned char a, unsigned char b, unsigned char c)
{
    int i, j;
    unsigned char *r;
    j = c * 4;
    i = b * 32;
    r = (unsigned char *)0x95440 + (unsigned long)a * 160 + (i + j);
    return *(unsigned int *)(r + 2);
}

void AccPatch_FetchStepEntry(unsigned char a)
{
    int i;
    i = ram_360a;
    ram_366a[i] = a;
    i++;
    ram_360a = i;
}

void StyleBuf_ClearAllEntries(void)
{
    unsigned char *p, *e, *q, *qe;
    e = ram_3f88;
    p = e;
    e += 2048;
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
    le = ram_4788;
    l = le;
    p = ram_3f88;
    le += 64;
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
    le = ram_555c;
    l = le;
    p = ram_48dc;
    le += 32;
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
