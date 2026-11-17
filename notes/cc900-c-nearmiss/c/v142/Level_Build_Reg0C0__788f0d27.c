/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_3b.c (2026-11-16-58-sub-r3)
   sha256 788f0d271359aef4ace536ce58c994c054403ce241712b29d2f7e0b99f5470cf (name+funcs); compiled at -Xr */
#define B(p, o) (*(unsigned char *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern int ram_451d2;
extern unsigned char ram_4134c;
void Level_Build_Reg0C0(unsigned char *v)
{
    int d;
    if (B(P(v, 35), 15) != 0 && B(P(v, 35), 18) != 0) {
        switch (ram_4134c) {
        case 6: d = 0; break;
        default: d = B(P(v, 35), 15); break;
        }
    } else d = B(P(v, 35), 15);
    if (d != 0) {
        d = d + ((int)B(P(v, 19), 92) - 0x40) + (char)B(P(v, 35), 102);
        if (d < 0) d = 0;
        else if (d > 0x7f) d = 0x7f;
        d <<= 8;
    }
    if (B(P(v, 35), 18) != 0) {
        switch (ram_4134c) {
        case 5:
        case 6: d |= 0x7f; break;
        default: d |= B(P(v, 35), 18); break;
        }
    } else d |= B(P(v, 35), 18);
    ram_451d2 = d;
}
