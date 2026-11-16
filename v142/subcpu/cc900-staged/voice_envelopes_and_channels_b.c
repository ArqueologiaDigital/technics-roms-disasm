/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned int ram_451cc[];
extern unsigned int ram_451f8;
extern unsigned int ram_451fa;
extern unsigned int ram_451fc;
extern unsigned int ram_451fe;
extern unsigned int ram_45200;
extern unsigned int ram_45202;
extern int ram_45208;
extern int ram_4520a;
extern int ram_4520c;
extern int ram_4520e;
extern int DSP_AlgoType_Dispatch1(int, int);
extern int DSP_AlgoType_Dispatch2(int, int);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void ToneGen_WriteExtParams_56(int, unsigned int *);
extern void ToneGen_WriteExtParams_56b(int, unsigned int *);
struct lvl70 { char pad[70]; unsigned char v; };

void Voice_Calc_LevelPair_Silence(struct lvl70 *p)
{
    ram_451fc = 0;
    ram_451fe = 0;
    ram_451f8 = (unsigned int)p->v << 8 | 0x80;
    ram_451fa = (unsigned int)p->v << 8;
    ram_45200 = 0;
    ram_45202 = 0;
}

void Voice_LoadFilterTable_All(unsigned char ch)
{
    unsigned int *list;
    unsigned int i;
    ram_4520a = DSP_AlgoType_Dispatch2(ch, 0);
    ram_4520e = DSP_AlgoType_Dispatch1(ch, 0);
    list = Voice_BuildOutputList(ch, 12, 0);
    for (i = 0; (list[i] & 0xff) < 0x80; i++)
        ToneGen_WriteExtParams_56b(list[i] & 0xff, ram_451cc);
}

void Voice_LoadPitchTable_All(unsigned char ch)
{
    unsigned int *list;
    unsigned int i;
    ram_45208 = DSP_AlgoType_Dispatch2(ch, 1);
    ram_4520c = DSP_AlgoType_Dispatch1(ch, 1);
    list = Voice_BuildOutputList(ch, 13, 0);
    for (i = 0; (list[i] & 0xff) < 0x80; i++)
        ToneGen_WriteExtParams_56(list[i] & 0xff, ram_451cc);
}

extern unsigned int ram_41343;
extern unsigned char ram_41374[];
extern unsigned char ram_41378[];
extern int ram_45204;
extern int ram_45206;
extern unsigned int Voice_CC_VolumeCurve[];
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern int DSP_ChanFreq_WritePacket1(int);
extern int DSP_ChanFreq_WritePacket2(int);
extern void ToneGen_WriteExtParams_15_Alt(int, unsigned int *);
extern void ToneGen_WriteExtParam_1C0_Sgl(int, unsigned int *);
extern void ToneGen_WriteReg0640(int, unsigned int *);
extern void ToneGen_WriteExtParam_600(int, unsigned int *);
extern void ToneGen_Write_ExtParam_05C0_Stb(int, unsigned int *);
extern void ToneGen_WriteExtParams_56_Alt(int, unsigned int *);

unsigned int Voice_AdvanceLFOPhase(unsigned char *p)
{
    unsigned int r;
    switch (p[0] & 0x1c) {
    case 0x10:
        if (++p[8] >= p[7]) {
            p[8] = 0;
            p[0] &= ~0x10;
            p[0] |= 8;
        }
        r = 0;
        break;
    case 8:
        if (++p[8] < p[7]) {
            r = (unsigned int)p[8] << 8;
            r /= p[7];
        } else {
            p[8] = 0;
            p[0] &= ~8;
            p[0] |= 4;
            r = 0x100;
        }
        break;
    default:
        r = 0;
        break;
    }
    return r;
}

void Voice_CC_SetExpression(unsigned char part, unsigned char v)
{
    if (v != 0) {
        if (ram_41343 & 1) *(unsigned int *)&ram_41378[part * 0x11f] = Voice_CC_VolumeCurve[v];
        else if (ram_41343 & 2) *(unsigned int *)&ram_41378[part * 0x11f] = Voice_CC_VolumeCurve[v];
        else *(unsigned int *)&ram_41378[part * 0x11f] = (unsigned int)v - 0x7f;
    } else *(unsigned int *)&ram_41378[part * 0x11f] = 0xfe00;
}

void Voice_CC_SetVolume(unsigned char part, unsigned char v)
{
    if (v != 0) {
        if (ram_41343 & 1) *(unsigned int *)&ram_41374[part * 0x11f] = Voice_CC_VolumeCurve[v];
        else if (ram_41343 & 2) *(unsigned int *)&ram_41374[part * 0x11f] = Voice_CC_VolumeCurve[v];
        else *(unsigned int *)&ram_41374[part * 0x11f] = (unsigned int)v - 0x7f;
    } else *(unsigned int *)&ram_41374[part * 0x11f] = 0xfe00;
}

void Voice_DSP_OutputConfig(unsigned char ch, unsigned char mode)
{
    unsigned int *list;
    unsigned int i;
    if (mode == 0) {
        ram_4520e = DSP_AlgoType_Dispatch1(ch, mode);
        list = Voice_BuildOutputList(ch, (unsigned char)((unsigned int)mode | 12), 0);
        for (i = 0; (list[i] & 0xff) < 0x80; i++)
            ToneGen_WriteReg0640(list[i] & 0xff, ram_451cc);
    } else {
        ram_4520c = DSP_AlgoType_Dispatch1(ch, mode);
        list = Voice_BuildOutputList(ch, (unsigned char)((unsigned int)mode | 12), 0);
        for (i = 0; (list[i] & 0xff) < 0x80; i++)
            ToneGen_WriteExtParam_600(list[i] & 0xff, ram_451cc);
    }
}

void Voice_DSP_OutputConfig2(unsigned char ch, unsigned char mode)
{
    unsigned int *list;
    unsigned int i;
    if (mode == 0) {
        ram_4520a = DSP_AlgoType_Dispatch2(ch, mode);
        list = Voice_BuildOutputList(ch, (unsigned char)((unsigned int)mode | 12), 0);
        for (i = 0; (list[i] & 0xff) < 0x80; i++)
            ToneGen_Write_ExtParam_05C0_Stb(list[i] & 0xff, ram_451cc);
    } else {
        ram_45208 = DSP_AlgoType_Dispatch2(ch, mode);
        list = Voice_BuildOutputList(ch, (unsigned char)((unsigned int)mode | 12), 0);
        for (i = 0; (list[i] & 0xff) < 0x80; i++)
            ToneGen_WriteExtParams_56_Alt(list[i] & 0xff, ram_451cc);
    }
}

void Voice_DSP_SimpleCopy(unsigned char ch)
{
    unsigned int *list;
    unsigned int i;
    ram_45204 = DSP_ChanFreq_WritePacket1(ch);
    list = Voice_BuildOutputList(ch, 16, 0);
    for (i = 0; (list[i] & 0xff) < 0x40; i++)
        ToneGen_WriteExtParam_1C0_Sgl(list[i] & 0xff, ram_451cc);
}

void Voice_DSP_SimpleCopy2(unsigned char ch)
{
    unsigned int *list;
    unsigned int i;
    ram_45206 = DSP_ChanFreq_WritePacket2(ch);
    list = Voice_BuildOutputList(ch, 16, 0);
    for (i = 0; (list[i] & 0xff) < 0x40; i++)
        ToneGen_WriteExtParams_15_Alt(list[i] & 0xff, ram_451cc);
}

void Voice_LoadToneTable_All(unsigned char ch)
{
    unsigned int *list;
    unsigned int i;
    ram_45206 = DSP_ChanFreq_WritePacket2(ch);
    list = Voice_BuildOutputList(ch, 16, 0);
    for (i = 0; (list[i] & 0xff) < 0x40; i++)
        ToneGen_WriteExtParams_15_Alt(list[i] & 0xff, ram_451cc);
}

void Voice_WriteVolume_OrPan(unsigned char *v)
{
    unsigned char *f;
    unsigned char *l;
    unsigned int t;
    f = *(unsigned char **)(v + 19);
    l = *(unsigned char **)(v + 23);
    if (f[13] & 0x20) {
        t = (unsigned int)Voice_EnvelopeLevel_Curve[l[13]] << 8;
        ram_451fa = t;
        ram_451f8 = t | 0x80;
    } else {
        ram_451f8 = 0x80;
        ram_451fa = 0;
    }
}
