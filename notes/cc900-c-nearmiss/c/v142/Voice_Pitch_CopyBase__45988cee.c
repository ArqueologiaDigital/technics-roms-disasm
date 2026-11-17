/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_8a.c (2026-11-16-82-sub-r8)
   sha256 45988cee248268643a64a4f7c2c639e4eeefbcdc285480358c8ff1adf1d94b44 (name+funcs); compiled at -Xr */
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
int Pitch_Fold_Octaves_Into_Range(int a, int lo, int hi);
void Voice_Pitch_CopyBase(unsigned char *v)
{
    unsigned char *t;
    int p;
    t = P(v, 23);
    p = SW(P(v, 31), 12);
    SW(v, 8) = p;
    p += (int)(char)t[3] << 8;
    p += (int)(char)t[4] * 2;
    SW(v, 6) = Pitch_Fold_Octaves_Into_Range(p, P(v, 31)[9], P(v, 31)[10]);
}
