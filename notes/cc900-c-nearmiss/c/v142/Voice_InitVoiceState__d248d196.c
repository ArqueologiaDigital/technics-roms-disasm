/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_M_16a.c (2026-11-16-112-sub-r16)
   sha256 d248d1966bd799fbc6c96ecea31be18938514e211569c0555c9c39fcfe2c0cf8 (name+funcs); compiled at -Xr */
extern unsigned int ram_451d0;
extern unsigned char Voice_OutputLevel_Table[];
extern int ram_41360;
extern int ram_41362;
extern int ram_41364;
extern unsigned char ram_4308e[][0x47];
extern unsigned int ram_451ce;
extern unsigned int ram_451d2;
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
extern unsigned int ram_451d8;
extern unsigned int ram_451da;
extern unsigned int ram_451dc;
extern unsigned int ram_451de;
extern unsigned int ram_451e0;
extern unsigned int ram_451e2;
extern unsigned int ram_451e4;
extern unsigned int ram_451e6;
extern unsigned int ram_451e8;
extern unsigned int ram_451ea;
extern unsigned int ram_451ec;
extern unsigned int ram_451ee;
extern unsigned int ram_451f0;
extern unsigned int ram_451f2;
extern unsigned int ram_451f4;
extern unsigned int ram_451f6;
void Voice_InitVoiceState(unsigned char slot)
{
    unsigned int t;
    ram_451ce = 0;
    ram_451da = ram_41360;
    ram_451ec = 0;
    ram_451ee = 0;
    ram_451f0 = 0;
    ram_451d4 = 0x17f;
    ram_451d6 = 0x7f7f;
    ram_451f2 = 0;
    ram_451f4 = 0;
    ram_451f6 = 0;
    ram_451e2 = 0;
    ram_451ea = 0;
    ram_451dc = 0;
    ram_451de = 0;
    ram_451d8 = 0x40;
    ram_451e0 = 0;
    ram_451d2 = 0;
    ram_451e4 = 0xff7f;
    ram_451e6 = ram_41362;
    ram_451e8 = ram_41362;
    t = *(unsigned int *)&Voice_OutputLevel_Table[(int)((unsigned int)ram_41364 << 1)];
    ram_451d0 = t + t;
    *(unsigned int *)&ram_4308e[slot][0x2d] = 0xf000;
}
