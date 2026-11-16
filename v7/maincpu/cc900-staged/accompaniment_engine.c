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
extern unsigned char __near ram_38ed;
extern unsigned char __near ram_38f2;
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned char __near ram_38f3;
extern unsigned char __near ram_38f4;
extern unsigned char __near ram_38f5;
extern unsigned char __near ram_38f6;
extern unsigned char __near ram_38f7;
extern unsigned char __near ram_38f8;
extern unsigned char __near ram_38f9;
extern unsigned char __near ACC_PENDING_FILLIN;
extern unsigned int __near ram_38ee;
extern unsigned int __near ram_38f0;

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
    ram_38ed = SEQ_CURRENT_SONG + 1;
    if (ram_38ee != 0)
        return;
    ram_38ee = 1;
    ram_38f0 = 1;
    ram_38f2 = 25;
    ram_38f3 = 0;
    ram_38f4 = 0;
    ram_38f5 = 0;
    ram_38f6 = 0;
    ram_38f7 = 0;
    ram_38f8 = 0;
    ram_38f9 = 0;
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
extern unsigned char __near ram_38fa;
extern unsigned int __near ram_38e6;
extern unsigned int __near ram_38e2;






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
        ram_38fa = 0;
    else
        ram_38fa = i;
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
    o = ram_38e6;
    r = (unsigned long)(ram_38e2 - 1) << 8;
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

extern unsigned int __near ram_38e4;
extern unsigned int __near ram_38e8;

void Part_StoreVoiceTableIndex(unsigned char a)
{
    unsigned int x, y;
    x = a;
    y = ram_38f3;
    ram_38e4 = y * 5 + x;
    ram_38e8 = 6;
}

void AccVoice_IncrementBarCounter(void)
{
    unsigned char *r;
    ACC_CUR_MEASURE = ACC_CUR_MEASURE + 1;
    r = *(unsigned char **)0x338a;
    if (ACC_CUR_MEASURE > r[13])
        ACC_CUR_MEASURE = 0;
}

/* The ROM's routine is a bare ret (the bytes after it are not reached from here).
   cc900-name: AccPatch_CmplxDataBlk_Helper2=AccPatch_ComplexDataBlock_Helper2 */
void AccPatch_CmplxDataBlk_Helper2(void)
{
}
