/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_4b.c (2026-11-16-62-sub-r4)
   sha256 f89fddaf3be0b8e16077861bf8cd0ad246fe92612aa0c7bcc7e50604383f7dad (name+funcs); compiled at -Xr */
extern unsigned int ram_41343;
extern int ram_4135a;
extern unsigned int ram_4135c;
extern char Voice_KeyShiftRamp_Steps[];
void Pitch_Bend_Ramp_Tick(void)
{
    int t;
    if (ram_41343 & 0x800) {
        ram_4135c++;
        t = Voice_KeyShiftRamp_Steps[0];
        ram_4135a = t + t;
        ram_41343 &= ~0x800;
        ram_41343 |= 0x1400;
    } else if (ram_41343 & 0x1000) {
        ram_4135c++;
        ram_41343 &= ~0x400;
    } else if (ram_41343 & 0x2000) {
        if (ram_41343 & 0x4000) {
            ram_4135c += 2;
            t = Voice_KeyShiftRamp_Steps[ram_4135c];
            ram_4135a = t + t;
            ram_41343 |= 0x400;
        } else if (ram_41343 & 32768) {
            ram_4135c++;
            t = Voice_KeyShiftRamp_Steps[ram_4135c];
            ram_4135a = t + t;
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
