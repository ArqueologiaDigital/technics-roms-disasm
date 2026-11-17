/* lane_p6 helper H, round 16, module 272 (ui/ui_widget_defs.s), form c: UnRegisterObject (new), as form a with the
   record addresses written as converted pointers (base + class * 14 as an integer sum: the ROM loads the base once
   into XIX and adds the scaled class to a copy of it, then again for class + 0x300). */

struct objreg { long cls; void *proc; int count; void **base; };
extern struct objreg OBJECT_REGISTRY[];
extern char UnRegisterObject_EmptyName[];

void UnRegisterObject(unsigned long id, long obj, unsigned int idx)
{
    unsigned int c;
    struct objreg *e;
    char *reg;

    c = (unsigned int)((id >> 16) & 0xfff);
    reg = (char *)OBJECT_REGISTRY;
    e = (struct objreg *)(reg + (unsigned long)c * 14);
    e->base[idx] = 0;
    ((struct objreg *)(reg + (unsigned long)(c + 0x300) * 14))->base[idx] = UnRegisterObject_EmptyName;
    e->count--;
}
