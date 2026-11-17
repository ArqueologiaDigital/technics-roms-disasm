/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_3b.c (2026-11-16-58-sub-r3)
   sha256 e14e6b6d5c368715cf8ab076373270904387a8c8c479bba7f55ed229322f8ab3 (name+funcs); compiled at -Xr */
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
