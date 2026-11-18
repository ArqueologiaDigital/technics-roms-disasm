/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/voice_params_and_tvf_ah_21a.c (2026-11-18-32-sub-r21g-staged)
   sha256 3a0df380df456a482e00c3dd555aec5e877379c245f449a5bbcd77f1ad05b354 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41350[];
extern unsigned char ram_41356[];
extern unsigned char ram_4518f;
extern unsigned char ram_44236[][27];
int ClampS16_WA_Short(int a, int hi, int lo);
void Voice_OpSlot_WriteParams(unsigned char part, unsigned char *v, unsigned char op, unsigned char s1, unsigned char s2)
{
    unsigned char *p1;
    unsigned char *p2;
    unsigned char *w;
    unsigned char t;
    p1 = &(*(unsigned char **)&ram_41356[part * 0x11f])[(int)s1 * 16 + (int)op * 4];
    p1 += 0x2b;
    w = (unsigned char *)(ram_44236 + s2) + (int)s1 * 9;
    p2 = &((unsigned char *)(unsigned long)(ram_41350 + part * 0x11f))[(int)s1 * 16 + (int)op * 4];
    p2 += 0x27;
    if (s1 != 2 && op == 0 && ram_4518f != 0xf5) {
        w[1] = ClampS16_WA_Short((int)p1[0] + (int)(char)v[104], 0x7f, 0);
        w[3] = ClampS16_WA_Short((int)p1[1] + (int)(char)v[105], 0x7f, 0);
        w[7] = ClampS16_WA_Short((int)(p1[3] & 0x3f) + (int)(char)v[106], 0x1e, 0);
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
    t = (unsigned int)(p1[3] & 0xc0) >> 6;
    w[0] &= 0xfc;
    w[0] |= t;
    w[5] = p1[2] & 0x7f;
}
