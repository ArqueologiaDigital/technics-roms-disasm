/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_10c.c (2026-11-16-90-sub-r10)
   sha256 b764a2d4f2a686ba767b16d3e964743b67ea75bd744e3f4404b12656041742eb (name+funcs); compiled at -Xr */
#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern int __near ram_2940;
int TVF_Calc_Cutoff(unsigned char *v, int c, int d, char s);
void Voice_PitchPack_Mode5_Dual(unsigned char *v)
{
    unsigned char *z;
    int c1, c2;
    z = P(v, 23);
    if (W(P(v, 35), 2) & 0x200) {
        c1 = z[77];
        c2 = z[79];
    } else {
        c1 = (int)z[77] + (char)P(v, 35)[103];
        c2 = (int)z[79] + (char)P(v, 35)[103];
    }
    c1 = TVF_Calc_Cutoff(v, c1, (char)z[55], (char)z[60]);
    c2 = TVF_Calc_Cutoff(v, c2, (char)z[55], (char)z[60]);
    SW(v, 66) = (c1 | (((unsigned int)z[78] << 13) | ((unsigned int)z[80] << 10))) | 0x80;
    SW(v, 68) = c2;
    ram_2940 = 0;
}
