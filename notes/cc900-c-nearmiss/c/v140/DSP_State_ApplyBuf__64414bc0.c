/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/dsp_control_routines_b_kernel.c (2026-11-16-80-sub-staged2)
   sha256 64414bc0f2b706d952a84d68eee56094511c7d4b18f2d70db38c83a1d4f54ca3 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
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
