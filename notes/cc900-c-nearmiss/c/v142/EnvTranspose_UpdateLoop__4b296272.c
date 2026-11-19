/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AL_24a.c (2026-11-19-24-sub-r24a)
   sha256 4b2962720e0a5f65c0396f178fd4dee7f88668f590335375be7d67d466542eb9 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char ram_41376[];
unsigned int Partial_GetBaseKey(unsigned char part, unsigned char partial);
int SignedClamp_Zero(int a);
void EnvTranspose_UpdateLoop(unsigned char part)
{
    int k[4];
    int t;
    unsigned char *rec;
    unsigned char p;
    int lo;
    int hi;

    rec = (unsigned char *)(unsigned long)(ram_41368 + part * 0x11f);
    t = (signed char)(ram_41376[part * 0x11f] - 0x40);
    for (p = 0; p < 4; p++) {
        if ((k[p] = Partial_GetBaseKey(part, p)) != 0x80)
            k[p] = SignedClamp_Zero(k[p] + t);
        ((unsigned char *)(unsigned long)(rec + ((int)p * 37 + 0x6e)))[35] = (unsigned char)k[p];
        ((unsigned char *)(unsigned long)(rec + ((int)p * 37 + 0x6e)))[36] = (unsigned char)k[p];
    }
    p = (*(unsigned char **)(ram_4136e + part * 0x11f))[93];
    if ((*(unsigned int *)(rec + 10) & 0x8000L) && (p & 0x40) && k[1] == k[0] && k[0] != 0x80) {
        lo = k[0];
        if (lo < 0x40) {
            lo = SignedClamp_Zero(lo - 0x10);
            hi = SignedClamp_Zero(lo + 0x28);
        } else {
            lo = SignedClamp_Zero(lo + 0x10);
            hi = SignedClamp_Zero(lo - 0x28);
        }
        if ((p & 0xf) == 9) {
            rec[145] = lo;
            rec[182] = lo;
            rec[146] = hi;
            rec[183] = hi;
        } else if ((p & 0xf) < 10) {
            rec[145] = lo;
            rec[182] = hi;
        }
    }
}
