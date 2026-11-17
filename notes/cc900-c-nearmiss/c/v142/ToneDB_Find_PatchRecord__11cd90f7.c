/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_W_18c.c (2026-11-17-7-sub-r18)
   sha256 11cd90f719c686bf95df843efa1165d230f4ca93f1f4a74de11f60b2fcf7bbb8 (name+funcs); compiled at -Xr */
extern unsigned char *ram_45318;
extern unsigned char *ram_4531c;
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
unsigned char *ToneDB_Find_PatchRecord(unsigned int a, unsigned int b)
{
    unsigned char *p;
    unsigned long i;

    if (b <= 7 || b == 0x40 || b == 0x41 || b == 0x70) {
        i = b;
        b = *(unsigned char *)(ToneDB_RootPtr[1] + i + ToneDB_RelBase);
        p = (unsigned char *)ToneDB_RootPtr[1] + 0x80;
        b = (b << 7) + a;
        b += b;
        b = *(unsigned int *)(p + b + ToneDB_RelBase);
        p = (unsigned char *)ToneDB_RootPtr[2];
        p = *(unsigned char **)((unsigned char *)&((unsigned long *)p)[b] + ToneDB_RelBase);
        p = ToneDB_RelBase + p;
    } else if (b == 0x10)
        p = ((unsigned long)a * 0x1d6 + 0x10) + ram_4531c;
    else if (b == 0x15)
        p = ((unsigned long)a * 0x1d6 + 0x10) + ram_45318;
    else if (b == 0x50)
        p = &ram_4531c[18816];
    else if (b == 0x55)
        p = ((unsigned long)(a & 3) * 0x2927 + 0x4980) + ram_45318;
    else {
        p = (unsigned char *)ToneDB_RootPtr[2];
        p = *(unsigned char **)(ToneDB_RelBase + p);
        p = ToneDB_RelBase + p;
    }
    return p;
}
