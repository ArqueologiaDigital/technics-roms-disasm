/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_3c.c (2026-11-16-58-sub-r3)
   sha256 c4be0377121c92aaf4310ff02e0d53aa962b80a276e1426001d4bcb998399cbf (name+funcs); compiled at -Xr */
#define B(p, o) (*(unsigned char *)((p) + (o)))
#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern volatile int __near ram_293e;
void Pitch_Apply_Partial_Detune(unsigned char *v)
{
    SW(v, 10) = SW(v, 6) + ram_293e + (int)(char)B(P(v, 23), 5) * 2 + (char)B(P(v, 39), 33) + SW(P(v, 35), 20);
    if ((W(P(v, 35), 10) & 4) && (B(P(v, 19), 16) & 0x20)) W(v, 1) |= 0x400;
    else W(v, 1) &= ~0x400;
}
