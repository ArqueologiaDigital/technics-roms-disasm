/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_2b.c (2026-11-16-47-sub-r2)
   sha256 fd571eb4a11710ee3f94b685837fcd101aa3642b5af3b15ed9bdb7a9eba8f3f4 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_413d4[];
extern unsigned char ram_451a4;
extern unsigned char ram_451ac;
#define PART_FLAGS(p)   (((unsigned int *)(ram_41368 + (p) * 0x11f))[0])
void DSP_SlotParam_Write_Slot4(unsigned char part)
{
    if ((PART_FLAGS(part) & 1) && part == ram_451a4) ram_413d4[part * 0x11f] = ram_451ac * 2;
    else ram_413d4[part * 0x11f] = 0;
}
