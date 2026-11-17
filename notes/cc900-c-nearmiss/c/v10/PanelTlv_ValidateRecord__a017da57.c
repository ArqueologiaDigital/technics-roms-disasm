/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_12m277b.c (2026-11-16-88-p6-r16)
   sha256 a017da5797229584c2fa0130b191e092b30b6d78a506cb95279089ecadbd193f (tar-sha256); compiled at -Xr */
struct tlvlay { unsigned long off; unsigned char *rules; };
extern unsigned int PanelTlv_ApplyFieldRule(unsigned char *base, unsigned char *rule);
void PanelTlv_ValidateRecord(unsigned char *base, struct tlvlay *l)
{
    unsigned char *r;
    base = base + (l->off + 2);
    for (r = l->rules; *r != 0xff; r += PanelTlv_ApplyFieldRule(base, r))
        ;
}
