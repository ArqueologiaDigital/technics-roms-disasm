/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w5b.c (2026-11-19-10-sub-r23w-asm)
   sha256 c4f58930b3bd612ce04c6acbf4749489c7f80f911867c569244db57c32d4251f (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int ram_45206;
extern unsigned int ram_4520a;
extern unsigned int EGEnv_ValueCurve_Simple[];
extern unsigned char ram_44260[];
void Voice_Freq_ComputeRight_Raw(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = ram_44260 + (int)n * 27;
    r = ((unsigned long)EGEnv_ValueCurve_Simple[p[3]] * p[4]) >> 7;
    if (n < 0x40) {
        if (r > 0x3fff) r = 0x3fff;
        ram_45206 = r;
    } else {
        if (r > 0x3fff) r = 0x3fff;
        ram_4520a = r;
    }
}
