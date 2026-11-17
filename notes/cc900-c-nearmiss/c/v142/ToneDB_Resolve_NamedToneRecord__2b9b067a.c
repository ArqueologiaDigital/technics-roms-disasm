/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_W_18b.c (2026-11-17-7-sub-r18)
   sha256 2b9b067aa3f5d6c5692fafb23e49ef5089f738ea67d405a1f19b2166fe4e7881 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_41381[];
extern unsigned char *ram_45318;
extern unsigned char *ram_4531c;
extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
#define PATCH(p) (*(unsigned char **)&ram_4136e[(p) * 0x11f])
unsigned char *ToneDB_Resolve_NamedToneRecord(unsigned int a, unsigned int b, unsigned char e, unsigned char part)
{
    unsigned char *r;
    unsigned int lo;
    unsigned int hi;
    unsigned long base;
    unsigned long off;
    unsigned int m;

    lo = a & 0x7f;
    hi = b & 0x1f;
    switch (b & 0x20) {
    case 0:
        base = ToneDB_RootPtr[29];
        off = ToneDB_RootPtr[30];
        m = ((unsigned int *)ToneDB_RootPtr)[119];
        r = (unsigned char *)((unsigned long)m
                              * (unsigned int)*(unsigned long *)((unsigned long)(((hi << 7) + lo) * 2) + base + ToneDB_RelBase)
                              + off + ToneDB_RelBase);
        break;
    case 0x20:
        if (PATCH(part) < (unsigned char *)&ram_45318 || part == 0xff) {
            r = ram_4531c + ((int)e * 80 + 19111);
        } else {
            r = (unsigned char *)((unsigned long)(unsigned int)ram_41381[part * 0x11f] * 0x2927) + (int)e * 80;
            r = (unsigned long)r + ram_45318;
            r += 19111;
        }
        break;
    }
    return r;
}
