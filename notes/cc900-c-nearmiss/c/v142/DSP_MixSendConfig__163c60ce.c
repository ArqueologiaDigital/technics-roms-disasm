/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_L_16d.c (2026-11-16-112-sub-r16)
   sha256 163c60ce1cb43181a7c913564c5d9b641485f39233021b3a5b5ffd194ba1da59 (name+funcs); compiled at -Xr */
extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);
void DSP_MixSendConfig(unsigned int a, long c, unsigned char *d)
{
    unsigned int n;
    unsigned int i;

    c = (long)ToneDB_Find_ToneRecord(a, (unsigned int)c);
    n = 0x11;
    for (i = 0; i < n; i++) {
        *d++ = *(unsigned char *)c;
        c++;
    }
}
