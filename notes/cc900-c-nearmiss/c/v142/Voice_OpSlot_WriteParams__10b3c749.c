/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AH_20a.c (2026-11-18-18-sub-r21a)
   sha256 10b3c749d6f16af1459c1b1cb990f1b3d6b5060e4fbd7f40a3bce8193e36ef5d (tar-sha256); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char ram_451a7;
extern unsigned char ram_4424e[][27];
int ClampS16_WA_Short(int a, int hi, int lo);
void Voice_OpSlot_WriteParams(unsigned char part, unsigned char *v, unsigned char op, unsigned char s1, unsigned char s2)
{
    unsigned char *p1;
    unsigned char *p2;
    unsigned char *w;

    p1 = *(unsigned char **)&ram_4136e[part * 0x11f] + ((int)s1 * 16 + (int)op * 4);
    p1 += 0x2b;
    w = (unsigned char *)(ram_4424e + s2) + (int)s1 * 9;
    p2 = ram_41368 + part * 0x11f + ((int)s1 * 16 + (int)op * 4);
    p2 += 0x27;
    if (s1 != 2 && op == 0 && ram_451a7 != 0xf5) {
        w[1] = ClampS16_WA_Short(p1[0] + (char)v[104], 0x7f, 0);
        w[3] = ClampS16_WA_Short(p1[1] + (char)v[105], 0x7f, 0);
        w[7] = ClampS16_WA_Short((p1[3] & 0x3f) + (char)v[106], 0x1e, 0);
    } else {
        w[1] = p1[0];
        w[3] = p1[1];
        w[7] = p1[3] & 0x3f;
    }
    if (p2[0] & 2) {
        w[2] = p2[3];
        w[7] = 0;
    } else w[2] = 0x80;
    if (p2[0] & 8) {
        w[4] = p2[2];
        w[7] = 0;
    } else w[4] = 0x80;
    if (p1[2] & 0x80) w[0] |= 0x20;
    else w[0] &= ~0x20;
    w[0] = (w[0] & 0xfc) | ((p1[3] & 0xc0) >> 6);
    w[5] = p1[2] & 0x7f;
}
