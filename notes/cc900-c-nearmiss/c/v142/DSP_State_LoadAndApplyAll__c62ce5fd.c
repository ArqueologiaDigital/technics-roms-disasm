/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_3a.c (2026-11-16-58-sub-r3)
   sha256 c62ce5fddcf8b613845ab6dee451222d9696446cb538d0e863a5815dd894a1aa (name+funcs); compiled at -Xr */
struct dspstate { int w[0x90]; int busy; };
extern struct dspstate *__near ram_4a3e;
extern int ram_45324[];
extern void DSP_State_ApplyAll(struct dspstate *s);
void DSP_State_LoadAndApplyAll(struct dspstate *src)
{
    *(ram_4a3e = (struct dspstate *)ram_45324) = *src;
    ram_4a3e->busy = 1;
    DSP_State_ApplyAll(ram_4a3e);
    ram_4a3e->busy = 0;
}
