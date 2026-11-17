/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_3b.c (2026-11-16-58-sub-r3)
   sha256 37c0af016e565fee335c95be3cff7bb8f759446ff2d97b97f7bdcedab76f9756 (name+funcs); compiled at -Xr */
extern unsigned int ram_41343;
extern int ram_4135a;
extern unsigned int ram_4135c;
extern char Voice_KeyShiftRamp_Steps[];
void Pitch_Bend_Ramp_Tick(void)
{
    if (ram_41343 & 0x800) {
        ram_4135c++;
        ram_4135a = (int)Voice_KeyShiftRamp_Steps[0] << 1;
        ram_41343 &= ~0x800;
        ram_41343 |= 0x1400;
    } else if (ram_41343 & 0x1000) {
        ram_4135c++;
        ram_41343 &= ~0x400;
    } else if (ram_41343 & 0x2000) {
        if (ram_41343 & 0x4000) {
            ram_4135c += 2;
            ram_4135a = (int)Voice_KeyShiftRamp_Steps[ram_4135c] << 1;
            ram_41343 |= 0x400;
        } else if (ram_41343 & 32768) {
            ram_4135c++;
            ram_4135a = (int)Voice_KeyShiftRamp_Steps[ram_4135c] << 1;
            ram_41343 |= 0x400;
        } else {
            ram_4135a = 0;
            ram_41343 |= 0x400;
        }
        if (ram_4135a != 0) return;
        ram_41343 &= 0x1fff;
        ram_4135c = 0;
        ram_41343 |= 0x400;
    } else {
        ram_41343 &= ~0x400;
    }
}
