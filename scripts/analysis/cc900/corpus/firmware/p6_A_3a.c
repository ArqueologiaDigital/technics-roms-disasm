/* Phase 6, lane_p6 helper A, round 3, form a: refined misses of rounds 1-2, v10 sequencer/accompaniment_engine.s,
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

/* `% 128` instead of `& 0x7f`: V4.23 writes `res 7` for the mask, the ROM `and 0x7f`. */
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
        case 0x20: STYLE_SECTION = 31; break;
        case 0: STYLE_SECTION = 30; break;
        default: STYLE_SECTION = 32; break;
        }
    } else if (STYLE_SECTION >= 30) {
        c = ram_34cd & 0x30;
        switch (c) {
        case 0x20: STYLE_SECTION = 4; break;
        case 0: STYLE_SECTION = 0; break;
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
    unsigned char p, b;
    p = PANEL_STYLE[0] & 0xff;
    b = (unsigned char)PANEL_STYLE[1] % 128;
    RHYTHM_LOAD_PROGRAM = p;
    RHYTHM_LOAD_BANK = b;
}

void AccVoice_IncrementBarCounter(void)
{
    if (++ACC_CUR_MEASURE > (*(unsigned char **)0x3426)[13])
        ACC_CUR_MEASURE = 0;
}

void AccPatch_ReadVoiceStride(void)
{
    unsigned char v;
    v = *(AccTone_LookupByProgram_Table + (unsigned long)STYLE_SECTION_TIME_SIG);
    STYLE_SECTION_BEATS = v;
}

void Part_StoreVoiceTableIndex(unsigned char a)
{
    unsigned int x, y;
    x = a;
    y = ram_398f;
    ram_3980 = y * 5 + x;
    ram_3984 = 6;
}

unsigned char *Voice_ResolveTableAddr(void)
{
    unsigned long o;
    o = ram_3984;
    return (unsigned char *)(((unsigned long)ram_3980 << 8) + 0x95c00 + o);
}

unsigned int AccVoice_GetMeasureStartBlock(unsigned char a, unsigned char b, unsigned char c)
{
    int i, j;
    j = c;
    j <<= 2;
    i = b;
    i <<= 5;
    i += j;
    return *(unsigned int *)((unsigned char *)0x95440 + (unsigned long)a * 160 + i);
}

unsigned int AccVoice_BarCounterBytecodeData_Helper2(unsigned char a, unsigned char b, unsigned char c)
{
    int i, j;
    j = c;
    j <<= 2;
    i = b;
    i <<= 5;
    i += j;
    return ((unsigned int *)((unsigned char *)0x95440 + (unsigned long)a * 160 + i))[1];
}

void AccPatch_FetchStepEntry(unsigned char a)
{
    ram_366a[ram_360a] = a;
    ram_360a++;
}

/* Declarations in reverse: V4.23 seemed to give the registers in the reverse order of the ROM's. */
void StyleBuf_ClearAllEntries(void)
{
    unsigned char *qe, *q, *e, *p;
    p = ram_3f88;
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
    unsigned char *qe, *q, *p;
    unsigned long *le, *l;
    l = ram_4788;
    p = ram_3f88;
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
    unsigned char *qe, *q, *p;
    unsigned long *le, *l;
    l = ram_555c;
    p = ram_48dc;
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
