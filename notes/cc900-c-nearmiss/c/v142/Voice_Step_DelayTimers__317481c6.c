/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_2a.c (2026-11-16-47-sub-r2)
   sha256 317481c6cc0b0362eb3d69ef64a520bc9035dd3312d59f39df1c5ca8e5f184c4 (name+funcs); compiled at -Xr */
extern void ToneGen_WriteSingleReg(int, int);
extern void Voice_Clear_HoldBit(int);
extern void Voice_Reload_Levels(int);
void Voice_Step_DelayTimers(unsigned char *p)
{
    unsigned int t;
    t = *(unsigned int *)(p + 47);
    if (t & 32768) {
        t -= 0x100;
        if ((t & 0x7f00) == 0) {
            ToneGen_WriteSingleReg(*p, *(unsigned int *)(p + 45));
            Voice_Clear_HoldBit(*p);
            t &= ~0x8000;
        }
    }
    if (t & 0x80) {
        t--;
        if ((t & 0x7f) == 0) {
            Voice_Reload_Levels(*p);
            t &= 0x7f;
        }
    }
    *(unsigned int *)(p + 47) = t;
}
