/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/accompaniment_engine_xr.c (2026-11-16-36-p6-staged-r4)
   sha256 16d7977e7a520f161126d4f00a0f0d864eee5ef9226207966b696a1c3d40adf1 (tar-sha256); compiled at -O3 -XS -Xr
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
