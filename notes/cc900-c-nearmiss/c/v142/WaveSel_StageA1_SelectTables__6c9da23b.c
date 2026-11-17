/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17a.c (2026-11-16-126-sub-r17)
   sha256 6c9da23be1740b125262337d35d6419d9e17f20c3d4204d47661ba77eaf9761b (name+funcs); compiled at -Xr */
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
unsigned char *WaveSel_StageA1_SelectTables(unsigned int a, unsigned int b, unsigned int sel)
{
    unsigned long base;
    unsigned int m;
    unsigned long off;
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
    b = (b << 7) + a;
    b += b;
    return (unsigned char *)((unsigned long)m * (unsigned int)*(unsigned long *)((unsigned long)b + base + ToneDB_RelBase)
                             + off) + ToneDB_RelBase;
}
