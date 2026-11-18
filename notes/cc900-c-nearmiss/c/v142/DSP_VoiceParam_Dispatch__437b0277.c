/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AI_21b.c (2026-11-18-19-sub-r21b-staged)
   sha256 437b0277b604534e4eb01e5e25460ffc90f4a907064a53fd5e2fa9768fec0eca (tar-sha256); compiled at -Xr */
extern unsigned char *ram_45310;
struct tdbr { char pad[76]; unsigned long o76; char p2[44]; unsigned long o124; unsigned long o128; char p3[8];
              unsigned long o140; char p4[32]; unsigned long o176; };
extern struct tdbr *ram_45314;
extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);
unsigned int DSP_VoiceParam_Dispatch(unsigned int a, unsigned int b, unsigned char *d)
{
    unsigned char *s;
    unsigned int h;
    unsigned int row;
    unsigned long off;
    unsigned int n, i;

    switch (b & 0x20) {
    case 0:
        a &= 0x7f;
        h = b & 0x1f;
        switch (b & 0xc0) {
        case 0:
        case 0x40:
        case 0x80:
        case 0xc0:
            off = ram_45314->o124;
            break;
        }
        row = *(unsigned long *)(((h << 7) + a) * 2 + off + ram_45310);
        off = ram_45314->o128;
        s = ((unsigned char (*)[16])(ram_45310 + off))[row];
        break;
    case 0x20:
        s = ToneDB_Find_ToneRecord(a, b);
        break;
    }
    n = 13;
    for (i = 0; i < n; i++) *d++ = s[i];
    return n;
}
