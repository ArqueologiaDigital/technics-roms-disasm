/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_7i.c (2026-11-16-79-sub-r7)
   sha256 ed4c32b67d8afcfcd0a0afb2f77769d767fe2372388d7bb8c8946cc7486679db (name+funcs); compiled at -Xr */
extern unsigned char ram_4308e[][0x47];
extern void Voice_UpdateAllLFO(void);
extern unsigned char *Voice_Query_AllChannels(void);
extern void Voice_Step_DelayTimers(unsigned char *);
extern void Voice_Clear_HoldBit(int);
extern void Voice_Reload_Levels(int);
void Audio_Tick_ServiceVoices_A(void)
{
    unsigned char *q;
    unsigned char *v;
    Voice_UpdateAllLFO();
    for (q = Voice_Query_AllChannels() + 5; *q < 0x40; q++) {
        v = &ram_4308e[*q][0];
        if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 32768) {
            if (*(unsigned int *)(v + 47) & 0x8080L) Voice_Step_DelayTimers(v);
        } else if (*(unsigned int *)(v + 47) & 0x8080L) {
            Voice_Clear_HoldBit(*v);
            Voice_Reload_Levels(*v);
            *(unsigned int *)(v + 47) = 0;
        }
    }
}
