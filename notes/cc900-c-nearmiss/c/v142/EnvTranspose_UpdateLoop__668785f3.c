/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AL_24b.c (2026-11-19-24-sub-r24a)
   sha256 668785f365c008f97b4a8d93bd02cafd3cbea26d69fa23b22da67fe8e0ffbb7e (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char ram_41376[];
unsigned int Partial_GetBaseKey(unsigned char part, unsigned char partial);
int SignedClamp_Zero(int a);
void EnvTranspose_UpdateLoop(unsigned char part)
{
    unsigned char *rec;
    int t;
    int k[4];
    unsigned char p;
    unsigned char f;
    int lo;
    int hi;

    rec = (unsigned char *)(unsigned long)(ram_41368 + part * 0x11f);
    t = (signed char)(ram_41376[part * 0x11f] - 0x40);
    for (p = 0; p < 4; p++) {
        if ((k[p] = Partial_GetBaseKey(part, p)) != 0x80)
            k[p] = SignedClamp_Zero(k[p] + t);
        ((unsigned char *)(unsigned long)(rec + ((int)p * 37 + 0x6e)))[35] = k[p];
        ((unsigned char *)(unsigned long)(rec + ((int)p * 37 + 0x6e)))[36] = k[p];
    }
    f = (*(unsigned char **)(ram_4136e + part * 0x11f))[93];
    if ((*(unsigned int *)(rec + 10) & 0x8000L) && (f & 0x40) && k[1] == k[0] && k[0] != 0x80) {
        lo = k[0];
        if (lo < 0x40) {
            lo = SignedClamp_Zero(lo - 0x10);
            hi = SignedClamp_Zero(lo + 0x28);
        } else {
            lo = SignedClamp_Zero(lo + 0x10);
            hi = SignedClamp_Zero(lo - 0x28);
        }
        if ((f & 0xf) == 9) {
            rec[145] = lo;
            rec[182] = lo;
            rec[146] = hi;
            rec[183] = hi;
        } else if ((f & 0xf) < 10) {
            rec[145] = lo;
            rec[182] = hi;
        }
    }
}
