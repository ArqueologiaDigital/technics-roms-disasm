/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/dsp_control_routines_kernel.c (2026-11-16-80-sub-staged2)
   sha256 b93f6a5abd483612c91c834d22cc1e7250c57130435f1ec5955c67217baf4379 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
struct dspstate { int w[0x90]; int busy; };
extern struct dspstate ram_45324;
extern struct dspstate ram_45446;
extern void Kernel_StartTask(int n);
extern void MsgQueue_Send(int q, void *m);
void DSP_State_DmaLoadPresets(void)
{
    Kernel_StartTask(3);
    MsgQueue_Send(1, &ram_45324);
    MsgQueue_Send(1, &ram_45446);
}
