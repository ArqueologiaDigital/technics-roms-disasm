/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_4a.c (2026-11-16-62-sub-r4)
   sha256 8761cd5b09c02ab4a3dcf319bf8f33d0a140160a7f99178b636c4330cd768909 (name+funcs); compiled at -Xr */
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
        default: d = (unsigned int)B(P(v, 35), 15); break;
        }
    } else d = (unsigned int)B(P(v, 35), 15);
    if (d != 0) {
        d += (int)B(P(v, 19), 92) - 0x40;
        d += (char)B(P(v, 35), 102);
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
