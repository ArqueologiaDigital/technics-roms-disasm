/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_16m272b.c (2026-11-18-1-p6-r33)
   sha256 a6f4d51896f06f8c2c542ad9000e22d8581f12bb08c22f98155ba454a4f205c6 (tar-sha256); compiled at -O3 -Xr */
struct objreg { long cls; void *proc; int count; void **base; };
extern struct objreg OBJECT_REGISTRY[];
extern char UnRegisterObject_EmptyName[];
void UnRegisterObject(unsigned long id, long obj, unsigned int idx)
{
    unsigned int c;

    c = (unsigned int)((id >> 16) & 0xfff);
    OBJECT_REGISTRY[c].base[idx] = 0;
    OBJECT_REGISTRY[c + 0x300].base[idx] = UnRegisterObject_EmptyName;
    OBJECT_REGISTRY[c].count--;
}
