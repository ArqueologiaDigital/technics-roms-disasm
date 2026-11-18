/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AF_20a.c (2026-11-18-8-sub-r20b-staged)
   sha256 4c71bfc153aa3f5c7eecd686fa34b80bcc6d759f588a4a2527d8051eea475a43 (tar-sha256); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char DSP_AlgoDescriptor_Records[];
extern unsigned char DSP_AlgoChannel_SelectorRecords[];
extern unsigned char DSP_ChanFreq_Dispatch1_Curves[];
extern int EGEnv_ModeBits_Table[];
struct sel2 { unsigned char a; unsigned char b; };
struct algorec { unsigned char b[40]; };
struct b3 { unsigned char f0; unsigned char f1; unsigned char f2; };
struct coef { unsigned int c1; unsigned int c2; };
struct prc { unsigned char pad[0x57]; unsigned char m[2][4]; };
unsigned int DSP_AlgoType_Dispatch1(unsigned char part, unsigned char ch)
{
    unsigned int r;
    unsigned char t;
    unsigned char s;
    r = 0;
    t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
    switch (t) {
    case 0: case 1: case 2: case 3:
        s = ((struct sel2 *)(DSP_AlgoChannel_SelectorRecords + (int)t * 6))[ch].a;
        r = ((unsigned int *)(DSP_ChanFreq_Dispatch1_Curves + (int)s * 102))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[94]];
        break;
    case 4: case 5: case 7:
        s = ((struct sel2 *)(DSP_AlgoChannel_SelectorRecords + (int)t * 6))[ch].a;
        if (ch == 0)
            r = ((unsigned int *)(DSP_ChanFreq_Dispatch1_Curves + (int)s * 102))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[94]];
        else if (ch == 1)
            r = ((unsigned int *)(DSP_ChanFreq_Dispatch1_Curves + (int)s * 102))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[96]];
        break;
    case 10: case 11:
        s = ((struct sel2 *)(DSP_AlgoChannel_SelectorRecords + (int)t * 6))[ch].a;
        if (s != 0xff)
            r = ((unsigned int *)(DSP_ChanFreq_Dispatch1_Curves + (int)s * 102))[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[96]];
        r |= EGEnv_ModeBits_Table[(((struct b3 *)((unsigned long)&((struct algorec *)(DSP_AlgoDescriptor_Records + (int)t * 39))->b[(int)ch * 3]))->f2 & 0xc0) >> 6];
        break;
    }
    ((struct coef *)((struct prc *)(ram_41368 + (int)part * 0x11f))->m[ch])->c1 = r;
    return r;
}
