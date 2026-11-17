/* Functions of core/13_audio_process_dsp_and_effects.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct slot { unsigned int type; unsigned int a[1]; int param[17]; unsigned int idx; int q[1]; int r42[6]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct rec { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; unsigned int g[5]; };
struct fxflags { unsigned int active[5]; unsigned int chip[2]; unsigned int algochg; struct rec r[5]; };
extern struct fxflags __near EFF_SlotActiveFlags;
extern unsigned char EFF_SlotSettleTime_Table[];
extern void EFF_Disconnect(unsigned int, unsigned int);
extern void DSP_ScheduleDelay(int);
extern unsigned int Unsigned_Max_Select(unsigned int, unsigned int);

/* cc900-module: Unsigned_Max_Select */
void EFF_SecondaryLinkPath(struct cfg *p)
{
    int m;
    int i;
    m = 0;
    for (i = 4; i > -1; i--)
        if (EFF_SlotActiveFlags.r[i].g[3] == 1 && p->s[i].on == 0)
            m = Unsigned_Max_Select(m, 20);
    if (m != 0)
        DSP_ScheduleDelay(m);
    m = 0;
    for (i = 4; i > -1; i--)
        if (EFF_SlotActiveFlags.r[i].g[3] == 1 && p->s[i].on == 0) {
            if (i != 3 && i != 2)
                EFF_Disconnect(i, p->f6);
            m = Unsigned_Max_Select(m, EFF_SlotSettleTime_Table[i]);
        }
    if (m != 0)
        DSP_ScheduleDelay(m);
}
