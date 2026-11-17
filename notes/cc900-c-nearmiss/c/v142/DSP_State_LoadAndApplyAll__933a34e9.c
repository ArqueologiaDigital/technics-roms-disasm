/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_3b.c (2026-11-16-58-sub-r3)
   sha256 933a34e91b0361e4e33794d2b5f1b5268cc2fd5dd516e86c00b85fbd3333c303 (name+funcs); compiled at -Xr */
struct dspstate { int w[0x90]; int busy; };
extern void *__near ram_4a3e;
extern struct dspstate ram_45324;
extern void DSP_State_ApplyAll(struct dspstate *s);
void DSP_State_LoadAndApplyAll(struct dspstate *src)
{
    *(struct dspstate *)(ram_4a3e = &ram_45324) = *src;
    ((struct dspstate *)ram_4a3e)->busy = 1;
    DSP_State_ApplyAll(ram_4a3e);
    ((struct dspstate *)ram_4a3e)->busy = 0;
}
