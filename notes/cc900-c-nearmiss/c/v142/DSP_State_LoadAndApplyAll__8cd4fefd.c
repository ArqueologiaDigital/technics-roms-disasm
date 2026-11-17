/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_2c.c (2026-11-16-47-sub-r2)
   sha256 8cd4fefd68ad70b9dc67bfe3d8b0d3cdfce1efdc96fb5e437917f1f9fb3aad0e (name+funcs); compiled at -Xr */
struct dspstate { int w[0x90]; int busy; };
extern struct dspstate *__near ram_4a3e;
extern struct dspstate ram_45324;
extern void DSP_State_ApplyAll(struct dspstate *s);
void DSP_State_LoadAndApplyAll(struct dspstate *src)
{
    *(ram_4a3e = &ram_45324) = *src;
    ram_4a3e->busy = 1;
    DSP_State_ApplyAll(ram_4a3e);
    ram_4a3e->busy = 0;
}
