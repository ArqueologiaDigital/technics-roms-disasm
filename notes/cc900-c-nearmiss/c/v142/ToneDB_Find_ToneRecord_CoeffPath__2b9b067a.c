/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_W_18b.c (2026-11-17-7-sub-r18)
   sha256 2b9b067aa3f5d6c5692fafb23e49ef5089f738ea67d405a1f19b2166fe4e7881 (name+funcs); compiled at -Xr */
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
unsigned char *ToneDB_Find_ToneRecord_CoeffPath(unsigned int a, unsigned int b)
{
    unsigned long p;

    b = *((unsigned char *)ToneDB_RootPtr[27] + b + ToneDB_RelBase);
    p = ToneDB_RootPtr[27] + 0x80;
    b = (b << 7) + a;
    b += b;
    b = *(unsigned int *)((unsigned long)b + p + ToneDB_RelBase);
    p = ToneDB_RootPtr[2];
    p = *(unsigned long *)((unsigned long)(b * 4) + p + ToneDB_RelBase);
    p = ToneDB_RelBase + p;
    return (unsigned char *)p;
}
