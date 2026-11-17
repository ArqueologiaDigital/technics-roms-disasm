/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_7i.c (2026-11-16-79-sub-r7)
   sha256 ed4c32b67d8afcfcd0a0afb2f77769d767fe2372388d7bb8c8946cc7486679db (name+funcs); compiled at -Xr */
extern unsigned int ram_41343;
extern int Voice_Build_OutputLevel(unsigned char *, int);
int Voice_ApplyPortamento(unsigned char *v)
{
    int t;
    t = *(int *)(v + 13);
    if ((*(unsigned char **)(v + 23))[23] != 0) t += (int)(*(unsigned char **)(v + 23))[23] - 100;
    else t -= 0x200;
    t += (*(char **)(v + 39))[34];
    if (ram_41343 & 2) {
        if (v[4] <= 1) {
            t -= *(int *)(*(unsigned char **)(v + 35) + 16);
            t -= 8;
        } else t -= 0x10;
    }
    return Voice_Build_OutputLevel(v, t);
}
