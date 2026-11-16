/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_6a.c (2026-11-16-73-sub-r6)
   sha256 1249326f8ca11987596854d16d2a694ae8f2a5dc0418eaae612666ec2f2e7448 (name+funcs); compiled at -Xr */
extern unsigned char __tiny ram_1c;
extern unsigned char __tiny ram_38;
extern void DSP_Nop();
void DSP_Deselect_Chip(int chip)
{
    DSP_Nop(chip);
    switch (chip) {
    case 0:
        ram_1c |= 0x20;
        break;
    case 1:
        ram_38 |= 0x40;
        break;
    }
}
