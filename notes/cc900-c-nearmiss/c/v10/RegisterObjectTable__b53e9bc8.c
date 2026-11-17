/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_15m272b.c (2026-11-17-16-p6-r31)
   sha256 b53e9bc8deb409e2199f11dc634ca60530f504b75c8be64d89a7d5fbd4d9a4b0 (tar-sha256); compiled at -O3 -Xr */
struct objreg { long cls; void *proc; int count; void *base; };
extern struct objreg OBJECT_REGISTRY[];
void RegisterObjectTable(unsigned int n, struct objreg *r)
{
    if (n > 0x45f)
        return;
    *(struct objreg *)((unsigned long)OBJECT_REGISTRY + (unsigned long)n * 14) = *r;
}
