/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_4308e[][0x47];
extern void Voice_UpdateAllLFO(void);
extern unsigned char *Voice_Query_AllChannels(void);
extern void Voice_Step_DelayTimers(unsigned char *v);
extern void Voice_Clear_HoldBit(int ch);
extern void Voice_Reload_Levels(int ch);

/* cc900-module: Voice_Step_DelayTimers Voice_UpdateAllLFO */
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
