/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AR_41b.c (2026-11-19-95-sub-r41r)
   sha256 7294c4771cbaf6a2898d5aa773f481a1fb646d2b0f62a4beec63b24a781e052a (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned long ram_45318;
extern unsigned long ram_4531c;
unsigned char *ToneDB_Find_PatchRecord(unsigned int a, unsigned int b)
{
    unsigned char *p;
    unsigned long i;

    if (b <= 7 || b == 0x40 || b == 0x41 || b == 0x70) {
        i = b;
        b = *(unsigned char *)(ToneDB_RootPtr[1] + i + ToneDB_RelBase);
        p = (unsigned char *)ToneDB_RootPtr[1];
        p = p + 0x80;
        b = (b << 7) + a;
        b += b;
        b = *(unsigned int *)(b + (unsigned long)p + ToneDB_RelBase);
        p = (unsigned char *)ToneDB_RootPtr[2];
        p = *(unsigned char **)(4 * b + (unsigned long)p + ToneDB_RelBase);
        p = (unsigned char *)(ToneDB_RelBase + +(unsigned long)p);
    } else if (b == 0x10)
        p = (unsigned char *)(+((unsigned long)a * 0x1d6 + 0x10) + ram_4531c);
    else if (b == 0x15)
        p = (unsigned char *)(+((unsigned long)a * 0x1d6 + 0x10) + ram_45318);
    else if (b == 0x50)
        p = (unsigned char *)ram_4531c + 0x4980;
    else if (b == 0x55)
        p = (unsigned char *)(+((unsigned long)(a & 3) * 0x2927 + 0x4980) + ram_45318);
    else {
        p = *(unsigned char **)(ToneDB_RelBase + ToneDB_RootPtr[2]);
        p = (unsigned char *)(ToneDB_RelBase + +(unsigned long)p);
    }
    return p;
}
