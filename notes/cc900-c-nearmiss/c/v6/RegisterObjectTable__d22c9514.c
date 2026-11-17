/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_widget_defs_m272_xr.c (2026-11-17-19-p6-r32-staged)
   sha256 d22c9514ce77376b52244303c0ddd048fe18cdf8e8060a7e54c0b3a8f249cca7 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
struct objreg { long cls; void *proc; int count; void *base; };
extern struct objreg OBJECT_REGISTRY[];
void RegisterObjectTable(unsigned int n, struct objreg *r)
{
    if (n > 0x45f)
        return;
    OBJECT_REGISTRY[n] = *r;
}
