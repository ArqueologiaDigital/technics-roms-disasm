/* Functions of core/14_dsp_control_routines.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct dspstate { int w[0x90]; int busy; };
extern struct dspstate *__near ram_4a3a;
extern void MsgQueue_Send(int q, struct dspstate *m);
extern struct dspstate *MsgQueue_ReceiveBlocking(int q);
extern struct dspstate *MsgQueue_Receive_NoBlock(int q);

void DSP_State_ApplyBuf(struct dspstate *src)
{
    if ((ram_4a3a = MsgQueue_Receive_NoBlock(2)) == 0)
        ram_4a3a = MsgQueue_ReceiveBlocking(1);
    *ram_4a3a = *src;
    ram_4a3a->busy = 1;
    MsgQueue_Send(2, ram_4a3a);
}

extern struct dspstate *__near ram_4a3e;
extern int ram_452d8[];
extern void DSP_State_ApplyAll(struct dspstate *s);

void DSP_State_LoadAndApplyAll(struct dspstate *src)
{
    ram_4a3e = (struct dspstate *)ram_452d8;
    *ram_4a3e = *src;
    ram_4a3e->busy = 1;
    DSP_State_ApplyAll(ram_4a3e);
    ram_4a3e->busy = 0;
}
