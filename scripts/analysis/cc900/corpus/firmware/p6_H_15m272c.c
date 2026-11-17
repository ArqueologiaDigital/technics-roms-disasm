/* lane_p6 helper H, round 15, module 272 (ui/ui_widget_defs.s), form c: RegisterObjectTable (new), as form a but the
   destination a pointer converted from the registry base plus the scaled slot (`(struct objreg *)(OBJECT_REGISTRY +
   n)` through a char pointer), the other converted-pointer spelling. */

struct objreg { long cls; void *proc; int count; void *base; };
extern struct objreg OBJECT_REGISTRY[];

void RegisterObjectTable(unsigned int n, struct objreg *r)
{
    if (n > 0x45f)
        return;
    *(struct objreg *)((char *)OBJECT_REGISTRY + (unsigned long)n * 14) = *r;
}
