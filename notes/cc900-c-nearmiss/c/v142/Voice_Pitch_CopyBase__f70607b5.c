/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_7a.c (2026-11-16-79-sub-r7)
   sha256 f70607b5111b1b73ae470351c728e34d55ce40ce7a9d878e58e34960dca5e443 (name+funcs); compiled at -Xr */
int Pitch_Fold_Octaves_Into_Range(int a, int lo, int hi);
void Voice_Pitch_CopyBase(unsigned char *v)
{
    unsigned char *t;
    int p;
    t = (*(unsigned char **)((v) + (23)));
    p = (*(int *)(((*(unsigned char **)((v) + (31)))) + (12)));
    (*(int *)((v) + (8))) = p;
    p += (int)(char)t[3] << 8;
    p += (int)(char)t[4] * 2;
    (*(int *)((v) + (6))) = Pitch_Fold_Octaves_Into_Range(p, (*(unsigned char **)((v) + (31)))[9], (*(unsigned char **)((v) + (31)))[10]);
}
