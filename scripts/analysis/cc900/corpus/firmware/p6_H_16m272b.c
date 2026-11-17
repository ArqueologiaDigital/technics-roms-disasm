/* lane_p6 helper H, round 16, module 272 (ui/ui_widget_defs.s), form b: UnRegisterObject (new), as form a but every
   access spelt through the registry and the class index (no record pointer local; V4.23's CSE is left to find the
   record address for the count). */

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
