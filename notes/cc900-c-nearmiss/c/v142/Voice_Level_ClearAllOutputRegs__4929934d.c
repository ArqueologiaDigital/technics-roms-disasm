/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2b.c (2026-11-16-47-sub-r2)
   sha256 4929934d1be3b922f61146a30935689ade1baf0354878540871355a4884bb871 (name+funcs); compiled at -O3 -Xr */
#define B(p, o) (*(unsigned char *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern unsigned char ram_4138e[];
extern int ram_451d8;
extern int ram_451dc;
extern int ram_451de;
extern int ram_451e0;
extern int ram_451e2;
extern int ram_451ea;
extern int ram_451ec;
extern int ram_451ee;
extern int ram_451f0;
extern int ram_451f2;
extern int ram_451f4;
extern int ram_451f6;
void Voice_Level_ClearAllOutputRegs(unsigned char *v)
{
    unsigned char *t = P(v, 23);
    ram_451ea = 0;
    ram_451e2 = 0;
    ram_451ec = 0;
    ram_451ee = 0;
    ram_451f0 = 0;
    ram_451f2 = 0;
    ram_451f4 = 0;
    ram_451f6 = 0;
    ram_451dc = 0;
    ram_451de = 0;
    if (ram_4138e[B(v, 4) * 287] == 1) SW(v, 43) = 0;
    else if (ram_4138e[B(v, 4) * 287] == 2) SW(v, 43) = 0x7f;
    else SW(v, 43) = *t;
    ram_451d8 = SW(v, 43);
    ram_451e0 = 0;
}
