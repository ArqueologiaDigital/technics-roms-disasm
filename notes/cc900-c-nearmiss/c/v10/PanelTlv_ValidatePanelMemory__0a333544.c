/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_14m277b.c (2026-11-16-100-p6-r19)
   sha256 0a333544e91a7f7f070ee88aa3c67951ad4605456aab956bcff59b454f4dac86 (tar-sha256); compiled at -O3 -Xr */
struct pmem { unsigned char b[960]; };
extern struct pmem ram_1ed400[];
extern void PanelTlv_ValidateBlock0(unsigned char *mem);
void PanelTlv_ValidatePanelMemory(unsigned int n)
{
    if (n < 80)
        PanelTlv_ValidateBlock0(ram_1ed400[n].b);
}
