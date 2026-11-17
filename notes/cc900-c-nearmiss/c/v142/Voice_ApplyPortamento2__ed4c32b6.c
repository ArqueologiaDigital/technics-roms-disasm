/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_7i.c (2026-11-16-79-sub-r7)
   sha256 ed4c32b67d8afcfcd0a0afb2f77769d767fe2372388d7bb8c8946cc7486679db (name+funcs); compiled at -Xr */
extern unsigned int ram_41343;
extern int Voice_Build_OutputLevel(unsigned char *, int);
int Voice_ApplyPortamento2(unsigned char *v)
{
    unsigned char *q;
    int t, u;
    q = *(unsigned char **)(v + 23);
    t = *(int *)(v + 13);
    if (q[5] != 0) t += (int)q[5] - 100;
    else t -= 0x200;
    if (ram_41343 & 2) {
        t -= *(int *)(*(unsigned char **)(v + 35) + 16);
        t -= *(int *)(*(unsigned char **)(v + 35) + 12);
        u = -512;
        if (*(int *)(*(unsigned char **)(v + 35) + 12) != -512) u = *(int *)(*(unsigned char **)(v + 35) + 12) >> 2;
        t += u;
    }
    return Voice_Build_OutputLevel(v, t);
}
