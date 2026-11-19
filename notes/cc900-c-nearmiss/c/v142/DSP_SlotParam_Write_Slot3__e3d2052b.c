/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w4a.c (2026-11-19-10-sub-r23w-asm)
   sha256 e3d2052b28570ae8bfe935ea9dda629d0d26b499fe425733ed49ee3544609745 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_413d3[];
extern unsigned char ram_451a4;
extern char ram_451ab;
#define PART_FLAGS(p)   (*(unsigned int *)(ram_41368 + (p) * 0x11f))
void DSP_SlotParam_Write_Slot3(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && ram_451a4 == part) ram_413d3[part * 0x11f] = ram_451ab * 2;
    else ram_413d3[part * 0x11f] = 0;
}
