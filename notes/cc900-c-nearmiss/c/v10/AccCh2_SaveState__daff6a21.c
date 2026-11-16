/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_2a.c (2026-11-16-33-p6-r2)
   sha256 daff6a210ae1d585590cbca49a5d49ac10efb93aef3c1766c7663df3000edf26 (tar-sha256); compiled at -O3 -Xr */
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
