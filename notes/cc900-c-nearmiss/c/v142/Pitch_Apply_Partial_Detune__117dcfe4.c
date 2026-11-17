/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_3a.c (2026-11-16-58-sub-r3)
   sha256 117dcfe4c69ab73765948417bed771add93ad5e8a4aacafd170500b351b44157 (name+funcs); compiled at -Xr */
#define B(p, o) (*(unsigned char *)((p) + (o)))
#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern int __near ram_293e;
void Pitch_Apply_Partial_Detune(unsigned char *v)
{
    SW(v, 10) = SW(v, 6) + ram_293e + (int)(char)B(P(v, 23), 5) * 2 + (char)B(P(v, 39), 33) + SW(P(v, 35), 20);
    if ((W(P(v, 35), 10) & 4) && (B(P(v, 19), 16) & 0x20)) W(v, 1) |= 0x400;
    else W(v, 1) &= ~0x400;
}
