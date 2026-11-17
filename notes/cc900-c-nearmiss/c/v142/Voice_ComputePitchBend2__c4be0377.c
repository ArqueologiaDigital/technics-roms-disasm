/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_3c.c (2026-11-16-58-sub-r3)
   sha256 c4be0377121c92aaf4310ff02e0d53aa962b80a276e1426001d4bcb998399cbf (name+funcs); compiled at -Xr */
#define B(p, o) (*(unsigned char *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern int ram_451d2;
extern unsigned char ram_4134c;
void Voice_ComputePitchBend2(unsigned char *v)
{
    unsigned char *q;
    int d;
    q = P(v, 19);
    if (B(P(v, 35), 15) != 0 && B(P(v, 35), 18) != 0) {
        switch (ram_4134c) {
        case 6: d = 0; break;
        default: d = (int)B(P(v, 35), 15); break;
        }
    } else d = (int)B(P(v, 35), 15);
    if (d != 0) {
        d += (int)B(q, 15) - 0x40;
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
