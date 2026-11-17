/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_2b.c (2026-11-16-47-sub-r2)
   sha256 162de819f54cf9ec9603635f20562168dba6600f421b81838c9e376a9705aded (name+funcs); compiled at -O3 -Xr */
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
