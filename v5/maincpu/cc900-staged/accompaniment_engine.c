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
extern unsigned int __near ram_38ca;
extern unsigned int __near ram_38c6;







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



unsigned char *VoiceTable_ResolveReadAddr(void)
{
    unsigned long o;
    unsigned long r;
    o = ram_38ca;
    r = (unsigned long)(ram_38c6 - 1) << 8;
    r += 0xb0000;
    r += o;
    return (unsigned char *)r;
}

