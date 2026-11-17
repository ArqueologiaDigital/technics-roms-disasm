/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_10b.c (2026-11-16-90-sub-r10)
   sha256 3822e2cb2ce90751ba3b6e2d55140937eedf30d25aefbddf19d18781c7307d1b (name+funcs); compiled at -O3 -Xr */
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern int __near ram_2940;
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c);
void Voice_PitchPack_RouteC(unsigned char *v)
{
    unsigned char *t;
    unsigned int x;
    int r;
    t = P(v, 23);
    r = TVF_Calc_Cutoff_NoKeyFollow(v, t[17]);
    x = ((unsigned int)t[18] << 13) | ((unsigned int)t[18] << 10);
    SW(v, 66) = r | x;
    SW(v, 68) = r;
    ram_2940 = 0;
}
