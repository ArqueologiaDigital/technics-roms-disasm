/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_Q_17a.c (2026-11-16-126-sub-r17)
   sha256 ac0e9204f80496a2a00e80ac0c4a0b41db26241507df15b2c4016b2c7863b004 (name+funcs); compiled at -Xr */
extern unsigned int ram_41343;
extern int Voice_Build_OutputLevel(unsigned char *v, int t);
int Voice_ApplyPortamento2(unsigned char *v)
{
    unsigned char *q;
    int t;
    unsigned int u;
    q = *(unsigned char **)(v + 23);
    t = *(int *)(v + 13);
    if (q[5] != 0) t += (int)q[5] - 100;
    else t -= 0x200;
    if (ram_41343 & 2) {
        t -= *(int *)(*(unsigned char **)(v + 35) + 16);
        t -= *(int *)(*(unsigned char **)(v + 35) + 12);
        u = 0xfe00;
        if (*(int *)(*(unsigned char **)(v + 35) + 12) != 0xfe00) u = *(int *)(*(unsigned char **)(v + 35) + 12) >> 2;
        t += u;
    }
    return Voice_Build_OutputLevel(v, t);
}
