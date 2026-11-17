/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/dsp_control_routines_kernel.c (2026-11-16-80-sub-staged2)
   sha256 b93f6a5abd483612c91c834d22cc1e7250c57130435f1ec5955c67217baf4379 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
struct dspstate { int w[0x90]; int busy; };
extern void DSP_State_ApplyAll(struct dspstate *s);
extern void MsgQueue_Send(int q, void *m);
extern void *MsgQueue_ReceiveBlocking(int q);
void DSP_State_ApplyTask(void)
{
    struct dspstate *p;

    while (1) {
        p = MsgQueue_ReceiveBlocking(2);
        DSP_State_ApplyAll(p);
        p->busy = 0;
        MsgQueue_Send(1, p);
    }
}
