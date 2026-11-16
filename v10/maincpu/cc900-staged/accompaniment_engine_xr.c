/* Functions of sequencer/accompaniment_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

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

void AccVoice_ClearChannelStates(void)
{
    ACC_LANE_MEASURE[0] = 0;
    ACC_LANE_MEASURE[1] = 0;
    ACC_LANE_MEASURE[2] = 0;
    ACC_LANE_MEASURE[3] = 0;
    ACC_LANE_MEASURE[4] = 0;
    ACC_LANE_MEASURE[5] = 0;
}

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
