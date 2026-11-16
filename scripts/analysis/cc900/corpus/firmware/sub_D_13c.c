/* lane_sub probe round 13, helper D, form c: KN5000 sub-CPU payload v1.42, core/09_dsp_algo_select.s and
   core/10_dsp_voice_params.s: the algorithm-type switches (jump tables placed at the ROM's case-offset tables) and
   DSP_VoiceCoeffRoute2.  Names are the tree's labels and .equ names; ram_<hex> is a RAM cell the tree has not named. */
/* cc900-module: Algo_SubTable_PanTrim_From_PartFlags */
/* cc900-module: AudioChannel_Handler_Cmd01 AudioChannel_Handler_Cmd02 AudioChannel_Handler_Cmd03 */
/* cc900-module: AudioChannel_Handler_Cmd04_07 AudioChannel_Handler_Cmd08_0B AudioChannel_Handler_Cmd0C_0F */
/* cc900-module: AudioChannel_Handler_Cmd10_13 AudioChannel_Handler_Cmd14_17 AudioChannel_Handler_Cmd18_1B */
/* cc900-data: AudioChannel_Dispatch 1 = AudioChannel_CaseOffsets */
/* cc900-data: Algo_SubTable_DispatchB 1 = Algo_SubTable_DispatchB_CaseOffsets */
/* cc900-data: Algo_SubTable_DispatchC 1 = Algo_SubTable_DispatchC_CaseOffsets */
/* cc900-data: Algo_SubTable_Bit15Dispatch 1 = Algo_SubTable_Bit15Dispatch_CaseOffsets */
/* cc900-data: DSP_AlgoType_Dispatch1 1 = DSP_AlgoType_Dispatch1_CaseOffsets */
/* cc900-data: DSP_AlgoType_Dispatch2 1 = DSP_AlgoType_Dispatch2_CaseOffsets */

extern unsigned char ram_4136e[];
extern unsigned char ram_41368[];
extern unsigned char ram_41372[];
extern unsigned char ram_45210[];
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char DSP_AlgoDescriptor_Records[];
extern unsigned char DSP_AlgoChannel_SelectorRecords[];
extern unsigned char DSP_ChanFreq_Dispatch1_Curves[];
extern unsigned char DSP_ChanFreq_CurvePool[];
extern unsigned char DSP_ChanFreq_IndexMap[];
extern int EGEnv_ModeBits_Table[];

/* cc900-name: Algo_PanTrim_From_PartFlags=Algo_SubTable_PanTrim_From_PartFlags */
extern char Algo_PanTrim_From_PartFlags(unsigned char, unsigned char);

unsigned char Algo_SubTable_DispatchB(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;
    register int o;

    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    o = (int)t * 39;
    r = *(unsigned char *)((unsigned long)&(DSP_AlgoDescriptor_Records + (long)o)[(int)k * 5 + 0x13] + 2);
    switch (t) {
    case 0: case 1: case 2: case 3:
        if (k == 1)
            {
            r = (*(unsigned char **)&ram_4136e[part * 0x11f])[96];
            r += r;
        }
        break;
    case 4: case 5:
        if (k == 1)
            {
            r = (*(unsigned char **)&ram_4136e[part * 0x11f])[98];
            r += r;
        }
        break;
    case 8:
        if (k == 1)
            {
            r = (*(unsigned char **)&ram_4136e[part * 0x11f])[95];
            r += r;
        }
        break;
    }
    return r;
}

unsigned char Algo_SubTable_DispatchC(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;
    register int o;

    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    o = (int)t * 39;
    r = *(unsigned char *)((unsigned long)&(DSP_AlgoDescriptor_Records + (long)o)[(int)k * 5 + 0x13] + 3);
    switch (t) {
    case 0: case 1: case 2: case 3:
        if (k == 1)
            r = (*(unsigned char **)&ram_4136e[part * 0x11f])[98] - 100;
        r += Algo_PanTrim_From_PartFlags(part, k);
        break;
    case 4: case 5:
        r = Algo_PanTrim_From_PartFlags(part, k);
        break;
    case 6: case 8:
        if (k == 1)
            r = (*(unsigned char **)&ram_4136e[part * 0x11f])[97] - 100;
        break;
    }
    return r;
}

unsigned char Algo_SubTable_Bit15Dispatch(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;
    register int o;

    if (*(unsigned int *)&ram_41372[part * 0x11f] & 0x8000L) {
        t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
        o = (int)t * 39;
        r = *(unsigned char *)((unsigned long)&(DSP_AlgoDescriptor_Records + (long)o)[(int)k * 5 + 0x13] + 4);
        switch (t) {
        case 0: case 1: case 2: case 3:
            if (k == 1)
                r = DSP_ChanFreq_IndexMap[(*(unsigned char **)&ram_4136e[part * 0x11f])[97]];
            break;
        case 4: case 5:
            if (k == 1)
                r = DSP_ChanFreq_IndexMap[(*(unsigned char **)&ram_4136e[part * 0x11f])[99]];
            break;
        case 8:
            if (k == 1)
                r = DSP_ChanFreq_IndexMap[(*(unsigned char **)&ram_4136e[part * 0x11f])[94]];
            break;
        }
    } else
        r = 0;
    return r;
}

void DSP_AlgoType_Dispatch1(unsigned char part, unsigned char ch)
{
    register unsigned int r;
    unsigned char t;
    unsigned char s;

    r = 0;
    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    switch (t) {
    case 0: case 1: case 2: case 3:
        s = (DSP_AlgoChannel_SelectorRecords + (long)((int)t * 6))[(int)ch * 2];
        r = ((int *)(DSP_ChanFreq_Dispatch1_Curves + (long)((int)s * 102)))[(*(unsigned char **)&ram_4136e[part * 0x11f])[94]];
        break;
    case 4: case 5: case 7:
        s = (DSP_AlgoChannel_SelectorRecords + (long)((int)t * 6))[(int)ch * 2];
        if (ch == 0)
            r = ((int *)(DSP_ChanFreq_Dispatch1_Curves + (long)((int)s * 102)))[(*(unsigned char **)&ram_4136e[part * 0x11f])[94]];
        else if (ch == 1)
            r = ((int *)(DSP_ChanFreq_Dispatch1_Curves + (long)((int)s * 102)))[(*(unsigned char **)&ram_4136e[part * 0x11f])[96]];
        break;
    case 10: case 11:
        s = (DSP_AlgoChannel_SelectorRecords + (long)((int)t * 6))[(int)ch * 2];
        if (s != 0xff)
            r = ((int *)(DSP_ChanFreq_Dispatch1_Curves + (long)((int)s * 102)))[(*(unsigned char **)&ram_4136e[part * 0x11f])[96]];
        r |= EGEnv_ModeBits_Table[(*(unsigned char *)((unsigned long)&(DSP_AlgoDescriptor_Records + (long)((int)t * 39))[(int)ch * 3] + 2) & 0xc0) >> 6];
        break;
    }
    *(unsigned int *)&(ram_41368 + (long)((int)part * 0x11f))[((int)ch * 4) + 0x57] = r;
}

void DSP_AlgoType_Dispatch2(unsigned char part, unsigned char ch)
{
    register unsigned int r;
    unsigned char t;
    unsigned char s;

    r = 0;
    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    switch (t) {
    case 0: case 1: case 2: case 3:
        s = *(unsigned char *)((unsigned long)&(DSP_AlgoChannel_SelectorRecords + (long)((int)t * 6))[(int)ch * 2] + 1);
        r = ((int *)(DSP_ChanFreq_CurvePool + (long)((int)s * 102)))[(*(unsigned char **)&ram_4136e[part * 0x11f])[95]];
        break;
    case 4: case 5: case 7:
        s = *(unsigned char *)((unsigned long)&(DSP_AlgoChannel_SelectorRecords + (long)((int)t * 6))[(int)ch * 2] + 1);
        if (ch == 0)
            r = ((int *)(DSP_ChanFreq_CurvePool + (long)((int)s * 102)))[(*(unsigned char **)&ram_4136e[part * 0x11f])[95]];
        else if (ch == 1)
            r = ((int *)(DSP_ChanFreq_CurvePool + (long)((int)s * 102)))[(*(unsigned char **)&ram_4136e[part * 0x11f])[97]];
        break;
    case 10: case 11:
        s = *(unsigned char *)((unsigned long)&(DSP_AlgoChannel_SelectorRecords + (long)((int)t * 6))[(int)ch * 2] + 1);
        if (s != 0xff)
            r = ((int *)(DSP_ChanFreq_CurvePool + (long)((int)s * 102)))[*(unsigned char *)((unsigned long)&(DSP_AlgoDescriptor_Records + (long)((int)t * 39))[(int)ch * 3] + 1)];
        break;
    }
    *(unsigned int *)((unsigned long)&(ram_41368 + (long)((int)part * 0x11f))[((int)ch * 4) + 0x57] + 2) = r;
}

void DSP_VoiceCoeffRoute2(unsigned char part, unsigned char sel)
{
    register unsigned char s;
    unsigned char z;
    unsigned int x;
    unsigned int y;
    unsigned long tbl;
    unsigned int d;
    unsigned char *src;
    unsigned int n;
    unsigned int i;

    s = sel & 15;
    z = (sel & 0xf0) >> 4;
    x = (*(unsigned char **)((unsigned long)&(ram_41368 + (long)((int)part * 0x11f))[(int)s * 37 + 110] + 4))[(int)z * 2 + 3];
    x &= 127;
    y = *(unsigned char *)((unsigned long)&(*(unsigned char **)((unsigned long)&(ram_41368 + (long)((int)part * 0x11f))[(int)s * 37 + 110] + 4))[(int)z * 2 + 3] + 1);
    y &= 15;
    switch ((int)*(unsigned char *)((unsigned long)&(*(unsigned char **)((unsigned long)&(ram_41368 + (long)((int)part * 0x11f))[(int)s * 37 + 110] + 4))[(int)z * 2 + 3] + 1) & 192) {
    case 0x00:
        tbl = ToneDB_RootPtr[22];
        break;
    case 0x40:
        tbl = ToneDB_RootPtr[24];
        break;
    case 0x80:
        tbl = ToneDB_RootPtr[23];
        break;
    case 0xc0:
        tbl = ToneDB_RootPtr[22];
        break;
    }
    d = *(unsigned long *)((unsigned long)(((y << 7) + x) * 2) + tbl + ToneDB_RelBase);
    src = (unsigned char *)(ToneDB_RelBase + ToneDB_RootPtr[25]);
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = src[(unsigned long)d * 16 + i];
    ram_45210[n + 6] = src[(unsigned long)d * 16 + 13];
    n++;
    ram_45210[n + 6] = d & 0xff;
    n++;
    ram_45210[n + 6] = d >> 8;
    n++;
}

/* ---- AudioChannel_Dispatch: the command switch and its 27 case stubs (AudioChannel_DispatchTable).  The ROM keeps
   d in XDE for the stubs (it is the handlers' third argument), so its switch value goes to HL ---- */
extern int AudioChannel_Handler_Cmd01(int);
extern int AudioChannel_Handler_Cmd02(int);
extern int AudioChannel_Handler_Cmd03(int);
extern int AudioChannel_Handler_Cmd04_07(int, int, unsigned char *, int);
extern int AudioChannel_Handler_Cmd08_0B(int, int, unsigned char *, int);
extern int AudioChannel_Handler_Cmd0C_0F(int, int, unsigned char *, int);
extern int AudioChannel_Handler_Cmd10_13(int, int, unsigned char *, int);
extern int AudioChannel_Handler_Cmd14_17(int, int, unsigned char *, int);
extern int AudioChannel_Handler_Cmd18_1B(int, int, unsigned char *, int);

int AudioChannel_Dispatch(unsigned char a, unsigned char b, unsigned char *d)
{
    unsigned char c;

    c = d[1] & 0x3f;
    switch (c) {
    case 1: return AudioChannel_Handler_Cmd01(a);
    case 2: return AudioChannel_Handler_Cmd02(a);
    case 3: return AudioChannel_Handler_Cmd03(a);
    case 4: AudioChannel_Handler_Cmd04_07(a, b, d, 0); break;
    case 5: AudioChannel_Handler_Cmd04_07(a, b, d, 1); break;
    case 6: AudioChannel_Handler_Cmd04_07(a, b, d, 2); break;
    case 7: AudioChannel_Handler_Cmd04_07(a, b, d, 3); break;
    case 8: AudioChannel_Handler_Cmd08_0B(a, b, d, 0); break;
    case 9: AudioChannel_Handler_Cmd08_0B(a, b, d, 1); break;
    case 10: AudioChannel_Handler_Cmd08_0B(a, b, d, 2); break;
    case 11: AudioChannel_Handler_Cmd08_0B(a, b, d, 3); break;
    case 12: AudioChannel_Handler_Cmd0C_0F(a, b, d, 0); break;
    case 13: AudioChannel_Handler_Cmd0C_0F(a, b, d, 1); break;
    case 14: AudioChannel_Handler_Cmd0C_0F(a, b, d, 2); break;
    case 15: AudioChannel_Handler_Cmd0C_0F(a, b, d, 3); break;
    case 16: AudioChannel_Handler_Cmd10_13(a, b, d, 0); break;
    case 17: AudioChannel_Handler_Cmd10_13(a, b, d, 1); break;
    case 18: AudioChannel_Handler_Cmd10_13(a, b, d, 2); break;
    case 19: AudioChannel_Handler_Cmd10_13(a, b, d, 3); break;
    case 20: AudioChannel_Handler_Cmd14_17(a, b, d, 0); break;
    case 21: AudioChannel_Handler_Cmd14_17(a, b, d, 1); break;
    case 22: AudioChannel_Handler_Cmd14_17(a, b, d, 2); break;
    case 23: AudioChannel_Handler_Cmd14_17(a, b, d, 3); break;
    case 24: AudioChannel_Handler_Cmd18_1B(a, b, d, 0); break;
    case 25: AudioChannel_Handler_Cmd18_1B(a, b, d, 1); break;
    case 26: AudioChannel_Handler_Cmd18_1B(a, b, d, 2); break;
    case 27: AudioChannel_Handler_Cmd18_1B(a, b, d, 3); break;
    }
}
