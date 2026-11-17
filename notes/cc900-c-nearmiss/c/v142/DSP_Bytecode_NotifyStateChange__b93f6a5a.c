/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/dsp_control_routines_kernel.c (2026-11-16-80-sub-staged2)
   sha256 b93f6a5abd483612c91c834d22cc1e7250c57130435f1ec5955c67217baf4379 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern void Kernel_SemaSignal(int n);
void DSP_Bytecode_NotifyStateChange(void) { Kernel_SemaSignal(1); }
