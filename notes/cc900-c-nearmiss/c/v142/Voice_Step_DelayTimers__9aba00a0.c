/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_2b.c (2026-11-16-47-sub-r2)
   sha256 9aba00a0c3e557e6d713bd84f64750019cb84970fa0099d1aa9e45ad5763c846 (name+funcs); compiled at -Xr */
extern void ToneGen_WriteSingleReg(int, int);
extern void Voice_Clear_HoldBit(int);
extern void Voice_Reload_Levels(int);
void Voice_Step_DelayTimers(unsigned char *p)
{
    unsigned int t;
    t = *(unsigned int *)&p[47];
    if (t & 0x8000) {
        t -= 0x100;
        if (!(t & 0x7f00)) {
            ToneGen_WriteSingleReg(p[0], *(unsigned int *)&p[45]);
            Voice_Clear_HoldBit(p[0]);
            t &= 0x7fff;
        }
    }
    if (t & 0x80) {
        t--;
        if (!(t & 0x7f)) {
            Voice_Reload_Levels(p[0]);
            t &= 0x7f;
        }
    }
    *(unsigned int *)&p[47] = t;
}
