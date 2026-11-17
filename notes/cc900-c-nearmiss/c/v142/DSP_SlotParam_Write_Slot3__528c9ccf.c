/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_3a.c (2026-11-16-58-sub-r3)
   sha256 528c9ccfc8cfe66716d81cade2bea6c2e8912fd14acd603daeff550ed19b8639 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_413d3[];
extern unsigned char ram_451a4;
extern char ram_451ab;
#define PART_FLAGS(p)   (*(unsigned int *)(ram_41368 + (p) * 0x11f))
void DSP_SlotParam_Write_Slot3(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && ram_451a4 == part) ram_413d3[part * 0x11f] = ram_451ab << 1;
    else ram_413d3[part * 0x11f] = 0;
}
