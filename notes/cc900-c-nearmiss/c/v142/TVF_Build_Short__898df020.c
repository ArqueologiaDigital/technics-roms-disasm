/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_ia10.c (2026-11-16-99-sub-r13-idioms)
   sha256 898df020da9f9bc09d23bbb070d4dda29c0f8862d0afd0625b0bcdc1965af5a7 (name+funcs); compiled at -Xr */
#define SW(p, o) (*(int *)((p) + (o)))
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c);
int TVF_Bias_Clamp_Amount(int a);
unsigned int TVF_Lookup_Depth_Amount(int a);
struct trec { unsigned char pad[17]; unsigned char b17, b18, b19, b20; };
void TVF_Build_Short(unsigned char *v)
{
    struct trec *t;
    int r;
    unsigned int x;
    t = *(struct trec **)(v + 23);
    r = TVF_Calc_Cutoff_NoKeyFollow(v, t->b17);
    x = ((unsigned int)t->b18 << 13) | 0x400;
    SW(v, 66) = r | x;
    r = TVF_Bias_Clamp_Amount(t->b19);
    SW(v, 68) = r | TVF_Lookup_Depth_Amount(t->b20);
}
