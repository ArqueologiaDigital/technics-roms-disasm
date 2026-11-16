/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_2b.c (2026-11-16-33-p6-r2)
   sha256 6466b0db5cc304449e230b5c4768605e1ab3bae7d08d95327934985fddd8f094 (tar-sha256); compiled at -O3 -Xr */
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
