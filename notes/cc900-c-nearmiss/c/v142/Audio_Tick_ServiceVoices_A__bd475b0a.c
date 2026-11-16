/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_8b.c (2026-11-16-82-sub-r8)
   sha256 bd475b0a234905c6efb6c6e86ec9471fb95bc7b36e30ff14fef91b19d3700a28 (name+funcs); compiled at -Xr */
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
    Voice_UpdateAllLFO();
    if (*(q = Voice_Query_AllChannels() + 5) < 0x40) {
        do {
            v = &ram_4308e[*q][0];
            if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 32768) {
                if (*(unsigned int *)(v + 47) & 0x8080L) Voice_Step_DelayTimers(v);
            } else if (*(unsigned int *)(v + 47) & 0x8080L) {
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                *(unsigned int *)(v + 47) = 0;
            }
        } while (*++q < 0x40);
    }
}
