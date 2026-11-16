/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_4a.c (2026-11-16-62-sub-r4)
   sha256 a24cf77f8f049afccae4323475659f7526d8e2c4b8ca651c8900655a87adb798 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_413d4[];
extern unsigned char ram_451a4;
extern char ram_451ac;
void DSP_SlotParam_Write_Slot4(unsigned char part)
{
    if ((*(unsigned int *)(ram_41368 + part * 0x11f) & 1) && ram_451a4 == part) ram_413d4[part * 0x11f] = ram_451ac << 2;
    else ram_413d4[part * 0x11f] = 0;
}
