/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_2b.c (2026-11-16-47-sub-r2)
   sha256 9aba00a0c3e557e6d713bd84f64750019cb84970fa0099d1aa9e45ad5763c846 (name+funcs); compiled at -Xr */
extern unsigned int ram_41343;
extern int ram_4135a;
extern unsigned int ram_4135c;
extern char Voice_KeyShiftRamp_Steps[];
void Pitch_Bend_Ramp_Tick(void)
{
    if (ram_41343 & 0x800) {
        ram_4135c++;
        ram_4135a = Voice_KeyShiftRamp_Steps[0] << 1;
        ram_41343 &= ~0x800;
        ram_41343 |= 0x1400;
        return;
    }
    if (ram_41343 & 0x1000) {
        ram_4135c++;
        ram_41343 &= ~0x400;
        return;
    }
    if (ram_41343 & 0x2000) {
        if (ram_41343 & 0x4000) {
            ram_4135c += 2;
            ram_4135a = Voice_KeyShiftRamp_Steps[ram_4135c] << 1;
            ram_41343 |= 0x400;
        } else if (ram_41343 & 0x8000L) {
            ram_4135c++;
            ram_4135a = Voice_KeyShiftRamp_Steps[ram_4135c] << 1;
            ram_41343 |= 0x400;
        } else {
            ram_4135a = 0;
            ram_41343 |= 0x400;
        }
        if (ram_4135a) return;
        ram_41343 &= ~0xe000;
        ram_4135c = 0;
        ram_41343 |= 0x400;
        return;
    }
    ram_41343 &= ~0x400;
}
