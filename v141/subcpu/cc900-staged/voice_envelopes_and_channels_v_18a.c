/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_413a7[];
extern unsigned char ram_413a9[];
extern unsigned char ram_413ab[];
extern unsigned char ram_413ad[];
extern unsigned char ram_413b1[];
extern unsigned int ram_451b4[];
extern unsigned int ram_451ee;
extern unsigned int ram_451f0;
extern unsigned int ram_451f2;
extern unsigned int ram_451f4;
extern unsigned int ram_451f6;
extern unsigned char Voice_PitchDepth_Scale[];
extern unsigned char Voice_FilterDepth_Scale[];
extern unsigned int DSP_AlgoType_Dispatch1(int, int);
extern unsigned int DSP_AlgoType_Dispatch2(int, int);
extern unsigned int DSP_ChanFreq_WritePacket2(int);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void ToneGen_WriteExtParams_56(int, unsigned int *);
extern void ToneGen_WriteExtParams_56b(int, unsigned int *);
extern void ToneGen_WriteExtParams_15_Alt(int, unsigned int *);
void Voice_LoadFilterTable_Ch(unsigned char ch, unsigned char depth);
void Voice_LoadPitchTable_Ch(unsigned char ch, unsigned char depth);
void Voice_LoadToneTable_Ch(unsigned char ch, unsigned char depth);

void Voice_LoadFilterTable_Ch(unsigned char ch, unsigned char depth)
{
    unsigned long v;
    unsigned int *list;
    unsigned int i;
    unsigned int r;
    v = DSP_AlgoType_Dispatch2(ch, 0);
    v = v * (unsigned long)depth;
    v >>= 8;
    if (v < 0x1c) {
        ram_451f2 = 0x1c;
        *(unsigned int *)&ram_413a9[ch * 0x11f] = 0x1c;
    } else {
        r = v;
        ram_451f2 = r;
        *(unsigned int *)&ram_413a9[ch * 0x11f] = v;
    }
    v = DSP_AlgoType_Dispatch1(ch, 0);
    v = v * (unsigned long)Voice_FilterDepth_Scale[depth];
    v >>= 8;
    r = v;
    ram_451f6 = r;
    *(unsigned int *)&ram_413a7[ch * 0x11f] = v;
    list = Voice_BuildOutputList(ch, 12, 0);
    for (i = 0; (list[i] & 0xff) < 0x80; i++)
        ToneGen_WriteExtParams_56b(list[i] & 0xff, ram_451b4);
}

void Voice_LoadPitchTable_Ch(unsigned char ch, unsigned char depth)
{
    unsigned long v;
    unsigned int *list;
    unsigned int i;
    unsigned int r;
    v = DSP_AlgoType_Dispatch2(ch, 1);
    v = v * (unsigned long)depth;
    v >>= 8;
    if (v < 0x2c) {
        ram_451f0 = 0x2c;
        *(unsigned int *)&ram_413ad[ch * 0x11f] = 0x2c;
    } else {
        r = v;
        ram_451f0 = r;
        *(unsigned int *)&ram_413ad[ch * 0x11f] = v;
    }
    v = DSP_AlgoType_Dispatch1(ch, 1);
    v = v * (unsigned long)Voice_PitchDepth_Scale[depth];
    v >>= 8;
    r = v;
    ram_451f4 = r;
    *(unsigned int *)&ram_413ab[ch * 0x11f] = v;
    list = Voice_BuildOutputList(ch, 13, 0);
    for (i = 0; (list[i] & 0xff) < 0x80; i++)
        ToneGen_WriteExtParams_56(list[i] & 0xff, ram_451b4);
}

void Voice_LoadToneTable_Ch(unsigned char ch, unsigned char depth)
{
    unsigned long v;
    unsigned int *list;
    unsigned int i;
    unsigned int r;
    v = DSP_ChanFreq_WritePacket2(ch);
    v = v * (unsigned long)depth;
    v >>= 8;
    if (v < 0x1c) {
        ram_451ee = 0x1c;
        *(unsigned int *)&ram_413b1[ch * 0x11f] = 0x1c;
    } else {
        r = v;
        ram_451ee = r;
        *(unsigned int *)&ram_413b1[ch * 0x11f] = v;
    }
    list = Voice_BuildOutputList(ch, 16, 0);
    for (i = 0; (list[i] & 0xff) < 0x40; i++)
        ToneGen_WriteExtParams_15_Alt(list[i] & 0xff, ram_451b4);
}
