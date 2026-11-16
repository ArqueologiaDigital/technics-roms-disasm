/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_12m277a.c (2026-11-16-88-p6-r16)
   sha256 8f668761df2dac71bc8603e30c9c6602adaad0cb85660699c0b6e0b0386f66f5 (tar-sha256); compiled at -O3 -Xr */
extern void PanelTlv_ValidateBlock0(unsigned char *mem);
void PanelTlv_ValidatePanelMemory(unsigned int n)
{
    if (n < 80)
        PanelTlv_ValidateBlock0((unsigned char *)0x1ed400 + (unsigned long)n * 960);
}
