/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_2b.c (2026-11-16-47-sub-r2)
   sha256 9aba00a0c3e557e6d713bd84f64750019cb84970fa0099d1aa9e45ad5763c846 (name+funcs); compiled at -Xr */
extern unsigned int ram_41343;
extern unsigned int ram_4135c;
void Voice_SetKeyShiftEnable(unsigned char on)
{
    unsigned int t;
    if (on) {
        if (ram_41343 & 0x1000) return;
        ram_41343 |= 0x800;
        ram_4135c = 0;
        return;
    }
    if ((ram_41343 & 0x1000) == 0) return;
    t = ram_41343 & 0xffff2fffL;
    t |= 0x2000;
    if (ram_4135c <= 20) t |= 0x4000;
    else t |= 0x8000;
    ram_41343 = t;
    ram_4135c = 0;
}
