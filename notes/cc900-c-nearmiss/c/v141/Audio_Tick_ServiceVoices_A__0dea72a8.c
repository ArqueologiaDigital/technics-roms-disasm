/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/voice_envelopes_and_channels_b_11a.c (2026-11-16-101-sub-r14)
   sha256 0dea72a82f7d9d8f3d08537557551d528bd93dbbbee624f5f31c459d2d32e793 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_4308e[][0x47];
extern void Voice_UpdateAllLFO(void);
extern unsigned char *Voice_Query_AllChannels(void);
extern void Voice_Step_DelayTimers(unsigned char *v);
extern void Voice_Clear_HoldBit(int ch);
extern void Voice_Reload_Levels(int ch);
void Audio_Tick_ServiceVoices_A(void)
{
    unsigned char *q;
    unsigned char *v;
    unsigned char *p;
    Voice_UpdateAllLFO();
    p = Voice_Query_AllChannels() + 5;
    q = p;
    if (*p < 0x40) {
        do {
            v = &ram_4308e[*q][0];
            if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 32768) {
                if (*(unsigned int *)(v + 47) & 0x8080L) Voice_Step_DelayTimers(v);
            } else if (*(unsigned int *)(v + 47) & 0x8080L) {
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                *(unsigned int *)(v + 47) = 0;
            }
            q++;
        } while (*q < 0x40);
    }
}
