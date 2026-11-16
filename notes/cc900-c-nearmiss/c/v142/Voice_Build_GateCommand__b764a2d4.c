/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_10c.c (2026-11-16-90-sub-r10)
   sha256 b764a2d4f2a686ba767b16d3e964743b67ea75bd744e3f4404b12656041742eb (name+funcs); compiled at -Xr */
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern unsigned char ram_4134c;
unsigned int Voice_Apply_GateRouting(int part, unsigned int g);
void Voice_Build_GateCommand(unsigned char *v)
{
    unsigned int g;
    g = 0xff;
    g -= ((unsigned int)P(v, 23)[0] & 0x3f) << 2;
    if (P(v, 23)[0] != 0) g |= 0x100;
    if (P(v, 35)[18] != 0) {
        switch (ram_4134c) {
        case 0:
        case 5:
        case 6:
            SW(v, 45) = g | 0xfe00;
            break;
        default:
            SW(v, 45) = g | 0xf000;
            break;
        }
    } else SW(v, 45) = g | 0xf000;
    SW(v, 45) = Voice_Apply_GateRouting(v[4], SW(v, 45));
}
