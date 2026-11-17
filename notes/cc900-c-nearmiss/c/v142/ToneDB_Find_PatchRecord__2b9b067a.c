/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_W_18b.c (2026-11-17-7-sub-r18)
   sha256 2b9b067aa3f5d6c5692fafb23e49ef5089f738ea67d405a1f19b2166fe4e7881 (name+funcs); compiled at -Xr */
extern unsigned char *ram_45318;
extern unsigned char *ram_4531c;
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
unsigned char *ToneDB_Find_PatchRecord(unsigned int a, unsigned int b)
{
    unsigned long p;

    if (b <= 7 || b == 0x40 || b == 0x41 || b == 0x70) {
        b = *((unsigned char *)ToneDB_RootPtr[1] + b + ToneDB_RelBase);
        p = ToneDB_RootPtr[1] + 0x80;
        b = (b << 7) + a;
        b += b;
        b = *(unsigned int *)((unsigned long)b + p + ToneDB_RelBase);
        p = ToneDB_RootPtr[2];
        p = *(unsigned long *)((unsigned long)(b * 4) + p + ToneDB_RelBase);
        p = ToneDB_RelBase + p;
    } else if (b == 0x10)
        p = (unsigned long)(((unsigned long)a * 0x1d6 + 0x10) + ram_4531c);
    else if (b == 0x15)
        p = (unsigned long)(((unsigned long)a * 0x1d6 + 0x10) + ram_45318);
    else if (b == 0x50)
        p = (unsigned long)&ram_4531c[18816];
    else if (b == 0x55)
        p = (unsigned long)(((unsigned long)(a & 3) * 0x2927 + 0x4980) + ram_45318);
    else {
        p = ToneDB_RootPtr[2];
        p = *(unsigned long *)(ToneDB_RelBase + p);
        p = ToneDB_RelBase + p;
    }
    return (unsigned char *)p;
}
