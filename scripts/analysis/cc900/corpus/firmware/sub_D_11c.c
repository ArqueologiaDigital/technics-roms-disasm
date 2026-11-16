/* lane_sub probe round 11, helper D, form c: KN5000 sub-CPU payload v1.42, core/10_dsp_voice_params.s.
   Names are the tree's labels and .equ names; ram_<hex> is a RAM cell the tree has not named.
   Row pointers into the 287-byte part records (and the 39-byte algorithm descriptors) are formed as
   base + (long)row-offset so that V4.23 does not merge row and column into one 16-bit index (round 10). */
/* cc900-module: WaveSel_StageA1_FindVelSplit WaveSel_StageA2_FindSetDesc DSP_ParamWrite_BlockCopy */
/* cc900-module: Algo_SubTable_DispatchA Algo_SubTable_DispatchB Algo_SubTable_DispatchC AlgoFlag_Write AlgoFlag_Write_Bit3 EFF_RoutingInit */

extern unsigned char ram_4136e[];
extern unsigned char ram_41368[];
extern unsigned char ram_41372[];
extern unsigned char ram_41381[];
extern unsigned char ram_41399[];
extern unsigned char ram_451a7;
extern unsigned char DSP_AlgoDescriptor_Records[];
extern unsigned char DSP_AlgoChannel_SelectorByte5[];
extern unsigned char DSP_ChanFreq_CurvePool[];

extern void WaveSel_StageA1_FindVelSplit(int, int, int, int, int);
extern void WaveSel_StageA2_FindSetDesc(int, int);
extern void DSP_ParamWrite_BlockCopy(unsigned int, unsigned char *, unsigned char *);
extern unsigned char Algo_SubTable_DispatchB(unsigned char, unsigned char);
extern unsigned char Algo_SubTable_DispatchC(unsigned char, unsigned char);
extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
extern void EFF_RoutingInit(int, int, int);

void WaveSel_StageA1_FromPatchBlock(unsigned char part, unsigned char slot)
{
    int x;
    int y;

    x = (*(unsigned char **)&(ram_41368 + (long)((int)part * 0x11f))[(int)slot * 37 + 0x6e])[2];
    y = (*(unsigned char **)&(ram_41368 + (long)((int)part * 0x11f))[(int)slot * 37 + 0x6e])[3];
    WaveSel_StageA1_FindVelSplit(slot, (unsigned char)x, (unsigned char)y, ram_41381[part * 0x11f], part);
}

void WaveSel_StageA2_FromToneRec(unsigned char part, unsigned char slot, unsigned char z)
{
    int lo;
    int hi;

    lo = (*(unsigned char **)((unsigned long)&(ram_41368 + (long)((int)part * 0x11f))[(int)slot * 37 + 0x6e] + 4))[(int)z * 2 + 3];
    hi = *(unsigned char *)((unsigned long)&(*(unsigned char **)((unsigned long)&(ram_41368 + (long)((int)part * 0x11f))[(int)slot * 37 + 0x6e] + 4))[(int)z * 2 + 3] + 1);
    WaveSel_StageA2_FindSetDesc((unsigned char)lo, (unsigned char)hi);
}

unsigned char Algo_SubTable_DispatchA(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;

    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    r = *(unsigned char *)((unsigned long)&(DSP_AlgoDescriptor_Records + (long)((int)t * 39))[(int)k * 5 + 0x13] + 1);
    switch (t) {
    case 8:
        if (k == 1)
            r = (*(unsigned char **)&ram_4136e[part * 0x11f])[96];
        break;
    }
    return r;
}

unsigned int Algo67_LUTOffset_Check(unsigned char part, unsigned char k)
{
    unsigned int r;
    unsigned char t;

    r = 0;
    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    switch (t) {
    case 6: case 7:
        if ((DSP_AlgoDescriptor_Records + (long)((int)t * 39))[(int)k * 5 + 0x13] & 0x20) {
            if ((*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0x40) {
                if ((DSP_AlgoDescriptor_Records + (long)((int)t * 39))[(int)k * 5 + 0x13] & 2)
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

void DSP_ChanFreq_WritePacket2(unsigned char part)
{
    unsigned char t;
    unsigned char s;
    int r;

    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    switch (t) {
    case 6: case 7:
        s = DSP_AlgoChannel_SelectorByte5[(int)t * 6];
        r = ((int *)(DSP_ChanFreq_CurvePool + (long)((int)s * 0x66)))[(*(unsigned char **)&ram_4136e[part * 0x11f])[95]];
        break;
    default:
        r = 0;
        break;
    }
    *(int *)&ram_41399[part * 0x11f] = r;
}

int DSP_WriteVoiceParam(unsigned int part, unsigned int off, unsigned int n, unsigned char *src)
{
    switch ((*(unsigned char **)((unsigned long)&ram_4136e[0] + (unsigned long)part * 0x11f))[16] & 0xc0) {
    case 0x00:
        DSP_ParamWrite_BlockCopy(n, off + (*(unsigned char **)((unsigned long)&ram_4136e[0] + (unsigned long)part * 0x11f)), src);
        return n;
    case 0x40:
        return 0;
    case 0x80:
        DSP_ParamWrite_BlockCopy(n, off + (*(unsigned char **)((unsigned long)&ram_4136e[0] + (unsigned long)part * 0x11f)), src);
        return n;
    case 0xc0:
        return 0;
    }
}

void VoiceNoteParam_UpdateLoop(unsigned char part)
{
    unsigned char s;

    if (*(unsigned int *)&ram_41372[part * 0x11f] & 0x8000L) {
        for (s = 0; s < 4; s++) {
            *(unsigned char *)((unsigned long)&(ram_41368 + (long)((int)part * 0x11f))[(int)s * 37 + 0x6e] + 32) = Algo_SubTable_DispatchA(part, s);
            *(unsigned char *)((unsigned long)&(ram_41368 + (long)((int)part * 0x11f))[(int)s * 37 + 0x6e] + 33) = Algo_SubTable_DispatchB(part, s);
            *(unsigned char *)((unsigned long)&(ram_41368 + (long)((int)part * 0x11f))[(int)s * 37 + 0x6e] + 34) = Algo_SubTable_DispatchC(part, s);
        }
    } else {
        for (s = 0; s < 4; s++) {
            *(unsigned char *)((unsigned long)&(ram_41368 + (long)((int)part * 0x11f))[(int)s * 37 + 0x6e] + 32) = 0;
            *(unsigned char *)((unsigned long)&(ram_41368 + (long)((int)part * 0x11f))[(int)s * 37 + 0x6e] + 33) = 0;
            *(unsigned char *)((unsigned long)&(ram_41368 + (long)((int)part * 0x11f))[(int)s * 37 + 0x6e] + 34) = 0;
        }
    }
}

void Voice_Part_ResetSlotRouting(unsigned char part)
{
    unsigned int k;

    if (ram_451a7 != 0xf5) {
        for (k = 0; k < 4; k++) {
            (*(unsigned char **)((ram_41368 + (long)((int)part * 0x11f)) + ((unsigned long)k * 37 + 110)))[6] &= 7;
            (*(unsigned char **)((ram_41368 + (long)((int)part * 0x11f)) + ((unsigned long)k * 37 + 110)))[6] |= 0x20;
        }
        AlgoFlag_Write_Bit3(part, 0, 0);
        AlgoFlag_Write(part, 0, 0);
    } else {
        for (k = 0; k < 4; k++)
            (*(unsigned char **)((ram_41368 + (long)((int)part * 0x11f)) + ((unsigned long)k * 37 + 110)))[6] &= 7;
        AlgoFlag_Write_Bit3(part, 0, 0);
        AlgoFlag_Write(part, 0, 0);
    }
    for (k = 0; k < 4; k++)
        EFF_RoutingInit(part, (unsigned char)k, 0);
}
