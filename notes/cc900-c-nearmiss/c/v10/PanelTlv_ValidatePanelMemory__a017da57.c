/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_12m277b.c (2026-11-16-88-p6-r16)
   sha256 a017da5797229584c2fa0130b191e092b30b6d78a506cb95279089ecadbd193f (tar-sha256); compiled at -O3 -Xr */
extern void PanelTlv_ValidateBlock0(unsigned char *mem);
void PanelTlv_ValidatePanelMemory(unsigned int n)
{
    if (n >= 80)
        return;
    PanelTlv_ValidateBlock0((unsigned char *)0x1ed400 + (unsigned long)n * 960);
}
