/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_8b.c (2026-11-16-82-sub-r8)
   sha256 bd475b0a234905c6efb6c6e86ec9471fb95bc7b36e30ff14fef91b19d3700a28 (name+funcs); compiled at -Xr */
extern unsigned int ram_41343;
extern int Voice_Build_OutputLevel(unsigned char *v, int t);
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
        if (*(int *)(*(unsigned char **)(v + 35) + 12) != 0xfe00) u = (int)*(unsigned int *)(*(unsigned char **)(v + 35) + 12) >> 2;
        t += u;
    }
    return Voice_Build_OutputLevel(v, t);
}
