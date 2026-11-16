/* Functions of sequencer/accompaniment_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

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
extern unsigned char __near ACC_PENDING_FILLIN;
extern unsigned int __near ram_398a;
extern unsigned int __near ram_398c;

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
extern unsigned char *AccTone_LookupByProgram_Table_2[];
extern unsigned long RhythmTiming_OffsetTable[];
extern unsigned char AccTone_LookupByProgram_Table[];
extern unsigned char __near ram_3996;
extern unsigned int __near ram_3982;
extern unsigned int __near ram_397e;

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

unsigned char AccTone_LookupByProgram(unsigned char a)
{
    unsigned char *p;
    p = AccTone_LookupByProgram_Table_2[(unsigned char)(a - 0xf0)];
    p = (unsigned char *)0x94860 + RhythmTiming_OffsetTable[*p];
    return AccTone_LookupByProgram_Table[p[12]];
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
