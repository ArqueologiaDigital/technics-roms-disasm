/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_15m272c.c (2026-11-17-16-p6-r31)
   sha256 03672a0831c4dcda6a8a26f7b13fb7f85fa3b66120fa50ef6adb84fb03e9e2af (tar-sha256); compiled at -O3 -Xr */
struct objreg { long cls; void *proc; int count; void *base; };
extern struct objreg OBJECT_REGISTRY[];
void RegisterObjectTable(unsigned int n, struct objreg *r)
{
    if (n > 0x45f)
        return;
    *(struct objreg *)((char *)OBJECT_REGISTRY + (unsigned long)n * 14) = *r;
}
