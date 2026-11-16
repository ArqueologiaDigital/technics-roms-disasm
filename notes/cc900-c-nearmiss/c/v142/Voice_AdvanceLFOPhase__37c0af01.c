/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_3b.c (2026-11-16-58-sub-r3)
   sha256 37c0af016e565fee335c95be3cff7bb8f759446ff2d97b97f7bdcedab76f9756 (name+funcs); compiled at -Xr */
unsigned int Voice_AdvanceLFOPhase(unsigned char *p)
{
    unsigned int r;
    switch (p[0] & 0x1c) {
    case 0x10:
        if (++p[8] >= p[7]) {
            p[8] = 0;
            p[0] &= ~0x10;
            p[0] |= 8;
        }
        r = 0;
        break;
    case 8:
        if (++p[8] < p[7]) {
            r = ((unsigned int)p[8] << 8) / p[7];
        } else {
            p[8] = 0;
            p[0] &= ~8;
            p[0] |= 4;
            r = 0x100;
        }
        break;
    default:
        r = 0;
        break;
    }
    return r;
}
