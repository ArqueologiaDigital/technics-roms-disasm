/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_W_18b.c (2026-11-17-7-sub-r18)
   sha256 2b9b067aa3f5d6c5692fafb23e49ef5089f738ea67d405a1f19b2166fe4e7881 (name+funcs); compiled at -Xr */
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
unsigned char *WaveSel_StageA1_SelectTables(unsigned int a, unsigned int b, unsigned int sel)
{
    unsigned int m;
    unsigned long off;
    unsigned long base;

    switch (sel) {
    case 0x00:
        base = ToneDB_RootPtr[3];
        off = ToneDB_RootPtr[6];
        m = ((unsigned int *)ToneDB_RootPtr)[117];
        break;
    case 0x40:
        base = ToneDB_RootPtr[5];
        off = ToneDB_RootPtr[8];
        m = ((unsigned int *)ToneDB_RootPtr)[120];
        break;
    case 0x80:
        base = ToneDB_RootPtr[4];
        off = ToneDB_RootPtr[7];
        m = ((unsigned int *)ToneDB_RootPtr)[117];
        break;
    case 0xc0:
        base = ToneDB_RootPtr[3];
        off = ToneDB_RootPtr[6];
        m = ((unsigned int *)ToneDB_RootPtr)[117];
        break;
    }
    b = ((b << 7) + a) * 2;
    return (unsigned char *)(m * (unsigned long)(unsigned int)*(unsigned long *)((unsigned long)b + base + ToneDB_RelBase)
                             + off) + ToneDB_RelBase;
}
