/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_6a.c (2026-11-16-73-sub-r6)
   sha256 48cb2a34c932b610dc7a2362e4cb075b87eb421455fb87b353b9fb0553972087 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_41372[];
extern unsigned char ram_413cf[];
extern unsigned char ram_451a4;
extern char ram_451a6;
extern char Voice_SecondaryParam_Fetch2();
void Voice_ActiveFlag_CheckAndLoad(unsigned char part)
{
    char v;
    v = 0;
    if ((*(unsigned int *)(ram_41368 + part * 0x11f) & 1) && ram_451a4 == part) v = ram_451a6 << 2;
    if (*(unsigned int *)(ram_41372 + part * 0x11f) & 0x8000L) v += Voice_SecondaryParam_Fetch2(part);
    ram_413cf[part * 0x11f] = v;
}
