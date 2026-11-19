/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AR_41c.c (2026-11-19-95-sub-r41r)
   sha256 ff727547f1a611bd0c20c3a970636b76e667cab61d501a927a202746ad8de4fc (name+funcs); compiled at -Xr
   cc900-options: -Xr */
struct slot { unsigned int type; unsigned int a[1]; int param[17]; unsigned int idx; int q[1]; int r42[6]; int on; };
extern unsigned char ram_4135e;
extern volatile unsigned char ram_4135f;
extern unsigned char ram_4308e[][0x47];
extern unsigned int ram_451cc[];
extern void Voice_SetPanning(unsigned char *v);
extern void Voice_InitVoiceState(unsigned char slot);
extern void ToneGen_WriteVoiceParams(int ch, unsigned int *p);
extern void ToneGen_WriteSingleReg(int ch, unsigned int w);
void Voice_TickNoteDecay(void)
{
    unsigned char i;
    unsigned char buf[14];
    if (ram_4135e != 0) {
        ram_4135f -= 1;
        if (ram_4135f == 0) {
            Voice_SetPanning(buf);
            if (buf[10] < 0x40) {
                Voice_InitVoiceState(i = buf[10]);
                ToneGen_WriteVoiceParams(i, ram_451cc);
                ToneGen_WriteSingleReg(i, *(unsigned int *)(ram_4308e[i] + 45));
            }
            ram_4135e--;
            ram_4135f = 4;
        }
    }
}
