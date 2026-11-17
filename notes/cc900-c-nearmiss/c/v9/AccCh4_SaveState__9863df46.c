/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/accompaniment_engine_xr.c (2026-11-16-36-p6-staged-r4)
   sha256 9863df465a11376eb3a55862353715354aee922d40154501646696f5bf684a19 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
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
