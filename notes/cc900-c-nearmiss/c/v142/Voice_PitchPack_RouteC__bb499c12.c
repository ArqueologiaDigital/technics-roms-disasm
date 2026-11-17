/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_10a.c (2026-11-16-90-sub-r10)
   sha256 bb499c121aaefa01b0c094dc81af9c38404b55775ff87425d47cbe4ef107bd5d (name+funcs); compiled at -O3 -Xr */
extern int __near ram_2940;
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c);
void Voice_PitchPack_RouteC(unsigned char *v)
{
    unsigned char *t;
    int r;
    unsigned int x;
    t = (*(unsigned char **)((v) + (23)));
    r = TVF_Calc_Cutoff_NoKeyFollow(v, t[17]);
    x = ((unsigned int)t[18] << 13) | ((unsigned int)t[18] << 10);
    (*(int *)((v) + (66))) = r | x;
    (*(int *)((v) + (68))) = r;
    ram_2940 = 0;
}
