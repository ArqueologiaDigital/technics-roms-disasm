/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w3b.c (2026-11-19-10-sub-r23w-asm)
   sha256 d20e29023118a40f2a271ad82f83ef4675b92a35036e76a09e526311c9db51e7 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
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
