/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_9c.c (2026-11-16-86-sub-r9)
   sha256 78ecbab13a5dc7797897ffde8967cd943b6b5f2f2195ecc3768976b9be2e7cb2 (name+funcs); compiled at -Xr */
#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
int TVF_Clamp_Cutoff(int a);
void TVF_Emit_Offset_Reg100(unsigned char *v)
{
    if (W(P(v, 39), 24) & 0x40)
        ram_451d4 = (SW(v, 66) & 0xff80) | TVF_Clamp_Cutoff((W(P(v, 39), 24) & 0x80) ?
                                                             (SW(v, 66) & 0x7f) - (char)P(v, 35)[31] :
                                                             (SW(v, 66) & 0x7f) + (char)P(v, 35)[31]);
    else ram_451d4 = SW(v, 66);
    ram_451d6 = SW(v, 68);
}
