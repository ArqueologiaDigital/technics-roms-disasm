/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_2a.c (2026-11-16-47-sub-r2)
   sha256 441730cd34a51ded89e917ad1d8715eb068dfde21b11eb7ad3c950b0e876929a (name+funcs); compiled at -Xr */
struct dspstate { int w[0x90]; int busy; };
extern void DSP_State_ApplyAll(struct dspstate *s);
extern void MsgQueue_Send(int q, struct dspstate *m);
extern struct dspstate *MsgQueue_ReceiveBlocking(int q);
void DSP_State_ApplyTask(void)
{
    struct dspstate *p;

    for (;;) {
        p = MsgQueue_ReceiveBlocking(2);
        DSP_State_ApplyAll(p);
        p->busy = 0;
        MsgQueue_Send(1, p);
    }
}
