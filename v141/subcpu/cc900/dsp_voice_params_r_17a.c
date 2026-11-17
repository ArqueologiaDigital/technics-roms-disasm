/* Functions of core/10_dsp_voice_params.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41350[];
extern unsigned char ram_41356[];
extern unsigned char ram_4135a[];
extern unsigned char ram_41369[];
extern unsigned char DSP_AlgoDescriptor_Records[];
extern unsigned char DSP_ChanFreq_IndexMap[];
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
struct slotrec { unsigned char *p0; unsigned char *vel; };
struct slottail { unsigned char pad[32]; unsigned char f32; unsigned char f33; unsigned char f34; };
struct algorec { unsigned char b[40]; };
struct b5 { unsigned char f0; unsigned char f1; unsigned char f2; unsigned char f3; unsigned char f4; };
extern unsigned char *WaveSel_StageA1_FindVelSplit(int, int, int, int, int);
extern void WaveSel_StageA2_FindSetDesc(int, int);
extern char Algo_PanTrim_From_PartFlags(unsigned char, unsigned char);
unsigned char Algo_SubTable_DispatchB(unsigned char part, unsigned char k);
unsigned int Algo67_LUTOffset_Check(unsigned char part, unsigned char k);
unsigned char Algo_SubTable_Bit15Dispatch(unsigned char part, unsigned char k);
unsigned char Algo_SubTable_DispatchA(unsigned char part, unsigned char k);
unsigned char Algo_SubTable_DispatchC(unsigned char part, unsigned char k);
void VoiceNoteParam_UpdateLoop(unsigned char part);
unsigned char *WaveSel_StageA1_FromPatchBlock(unsigned char part, unsigned char slot);
void WaveSel_StageA2_FromToneRec(unsigned char part, unsigned char slot, unsigned char z);

/* cc900-name: Algo_PanTrim_From_PartFlags=Algo_SubTable_PanTrim_From_PartFlags */
/* cc900-module: Algo_SubTable_DispatchA Algo_SubTable_DispatchB Algo_SubTable_DispatchC Algo_SubTable_PanTrim_From_PartFlags WaveSel_StageA1_FindVelSplit WaveSel_StageA2_FindSetDesc */
/* cc900-data: Algo_SubTable_DispatchC 1 = Algo_SubTable_DispatchC_CaseOffsets */
/* cc900-data: Algo_SubTable_Bit15Dispatch 1 = Algo_SubTable_Bit15Dispatch_CaseOffsets */
unsigned int Algo67_LUTOffset_Check(unsigned char part, unsigned char k)
{
    unsigned int r;
    unsigned char t;
    r = 0;
    t = (*(unsigned char **)&ram_41356[(part) * 0x11f])[93] & 0xf;
    switch (t) {
    case 6: case 7:
        if (((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)k * 5 + 0x13] & 0x20) {
            if ((*(unsigned char **)&ram_41356[(part) * 0x11f])[93] & 0x40) {
                if (((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)k * 5 + 0x13] & 2)
                    r = 0xc000;
                else
                    r = 0x4000;
            } else
                r = 0x4000;
        }
        break;
    }
    return r;
}

unsigned char Algo_SubTable_Bit15Dispatch(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;
    if (*(unsigned int *)&ram_4135a[part * 0x11f] & 0x8000L) {
        t = (*(unsigned char **)&ram_41356[(part) * 0x11f])[93] & 0xf;
        r = ((struct b5 *)&((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)(k) * 5 + 0x13])->f4;
        switch (t) {
        case 0: case 1: case 2: case 3:
            if (k == 1)
                r = DSP_ChanFreq_IndexMap[(*(unsigned char **)&ram_41356[(part) * 0x11f])[97]];
            break;
        case 4: case 5:
            if (k == 1)
                r = DSP_ChanFreq_IndexMap[(*(unsigned char **)&ram_41356[(part) * 0x11f])[99]];
            break;
        case 8:
            if (k == 1)
                r = DSP_ChanFreq_IndexMap[(*(unsigned char **)&ram_41356[(part) * 0x11f])[94]];
            break;
        }
    } else
        r = 0;
    return r;
}

unsigned char Algo_SubTable_DispatchA(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;
    t = (*(unsigned char **)&ram_41356[(part) * 0x11f])[93] & 0xf;
    r = ((struct b5 *)&((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)(k) * 5 + 0x13])->f1;
    switch (t) {
    case 8:
        if (k == 1)
            r = (*(unsigned char **)&ram_41356[(part) * 0x11f])[96];
        break;
    }
    return r;
}

unsigned char Algo_SubTable_DispatchC(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;
    t = (*(unsigned char **)&ram_41356[(part) * 0x11f])[93] & 0xf;
    r = ((struct b5 *)&((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)(k) * 5 + 0x13])->f3;
    switch (t) {
    case 0: case 1: case 2: case 3:
        if (k == 1)
            r = (*(unsigned char **)&ram_41356[(part) * 0x11f])[98] - 100;
        r += Algo_PanTrim_From_PartFlags(part, k);
        break;
    case 4: case 5:
        r = Algo_PanTrim_From_PartFlags(part, k);
        break;
    case 6: case 8:
        if (k == 1)
            r = (*(unsigned char **)&ram_41356[(part) * 0x11f])[97] - 100;
        break;
    }
    return r;
}

void VoiceNoteParam_UpdateLoop(unsigned char part)
{
    unsigned char s;
    if (*(unsigned int *)&ram_4135a[part * 0x11f] & 0x8000L) {
        for (s = 0; s < 4; s++) {
            ((struct slottail *)((struct partrec *)(ram_41350 + (part) * 0x11f))->partial[s])->f32 = Algo_SubTable_DispatchA(part, s);
            ((struct slottail *)((struct partrec *)(ram_41350 + (part) * 0x11f))->partial[s])->f33 = Algo_SubTable_DispatchB(part, s);
            ((struct slottail *)((struct partrec *)(ram_41350 + (part) * 0x11f))->partial[s])->f34 = Algo_SubTable_DispatchC(part, s);
        }
    } else {
        for (s = 0; s < 4; s++) {
            ((struct slottail *)((struct partrec *)(ram_41350 + (part) * 0x11f))->partial[s])->f32 = 0;
            ((struct slottail *)((struct partrec *)(ram_41350 + (part) * 0x11f))->partial[s])->f33 = 0;
            ((struct slottail *)((struct partrec *)(ram_41350 + (part) * 0x11f))->partial[s])->f34 = 0;
        }
    }
}

unsigned char *WaveSel_StageA1_FromPatchBlock(unsigned char part, unsigned char slot)
{
    int x;
    int y;
    x = ((struct slotrec *)((struct partrec *)(ram_41350 + (part) * 0x11f))->partial[slot])->p0[2];
    y = ((struct slotrec *)((struct partrec *)(ram_41350 + (part) * 0x11f))->partial[slot])->p0[3];
    return WaveSel_StageA1_FindVelSplit(slot, (unsigned char)x, (unsigned char)y, ram_41369[part * 0x11f], part);
}

void WaveSel_StageA2_FromToneRec(unsigned char part, unsigned char slot, unsigned char z)
{
    int lo;
    int hi;
    lo = ((struct slotrec *)((struct partrec *)(ram_41350 + (part) * 0x11f))->partial[slot])->vel[(int)z * 2 + 3];
    hi = ((struct b5 *)&((struct slotrec *)((struct partrec *)(ram_41350 + (part) * 0x11f))->partial[slot])->vel[(int)z * 2 + 3])->f1;
    WaveSel_StageA2_FindSetDesc((unsigned char)lo, (unsigned char)hi);
}
