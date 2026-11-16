/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned int ram_45180[];
extern unsigned int ram_451ac;
extern unsigned int ram_451ae;
extern unsigned int ram_451b0;
extern unsigned int ram_451b2;
extern unsigned int ram_451b4;
extern unsigned int ram_451b6;
extern int ram_451bc;
extern int ram_451be;
extern int ram_451c0;
extern int ram_451c2;
extern int DSP_AlgoType_Dispatch1(int, int);
extern int DSP_AlgoType_Dispatch2(int, int);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void ToneGen_WriteExtParams_56(int, unsigned int *);
extern void ToneGen_WriteExtParams_56b(int, unsigned int *);
struct lvl70 { char pad[70]; unsigned char v; };

void Voice_Calc_LevelPair_Silence(struct lvl70 *p)
{
    ram_451b0 = 0;
    ram_451b2 = 0;
    ram_451ac = (unsigned int)p->v << 8 | 0x80;
    ram_451ae = (unsigned int)p->v << 8;
    ram_451b4 = 0;
    ram_451b6 = 0;
}

void Voice_LoadFilterTable_All(unsigned char ch)
{
    unsigned int *list;
    unsigned int i;
    ram_451be = DSP_AlgoType_Dispatch2(ch, 0);
    ram_451c2 = DSP_AlgoType_Dispatch1(ch, 0);
    list = Voice_BuildOutputList(ch, 12, 0);
    for (i = 0; (list[i] & 0xff) < 0x80; i++)
        ToneGen_WriteExtParams_56b(list[i] & 0xff, ram_45180);
}

void Voice_LoadPitchTable_All(unsigned char ch)
{
    unsigned int *list;
    unsigned int i;
    ram_451bc = DSP_AlgoType_Dispatch2(ch, 1);
    ram_451c0 = DSP_AlgoType_Dispatch1(ch, 1);
    list = Voice_BuildOutputList(ch, 13, 0);
    for (i = 0; (list[i] & 0xff) < 0x80; i++)
        ToneGen_WriteExtParams_56(list[i] & 0xff, ram_45180);
}
