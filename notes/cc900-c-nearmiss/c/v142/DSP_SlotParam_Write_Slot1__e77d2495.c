/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_2a.c (2026-11-16-47-sub-r2)
   sha256 e77d2495b549821b0ba06f8b78d5c1927c12696a39635b76364de81b0b34400e (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_413d1[];
extern unsigned char ram_451a4;
extern unsigned char ram_451a8;
#define PART_FLAGS(p)   (*(unsigned int *)(ram_41368 + (p) * 0x11f))
void DSP_SlotParam_Write_Slot1(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && ram_451a4 == part) ram_413d1[part * 0x11f] = ram_451a8 << 1;
    else ram_413d1[part * 0x11f] = 0;
}
