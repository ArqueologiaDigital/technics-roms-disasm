/* lane_p6 helper H, round 15, module 272 (ui/ui_widget_defs.s), form b: RegisterObjectTable (new), as form a but the
   destination written as an integer address (lane_hd's idiom: a converted pointer loads its base as an immediate,
   the ROM's `ld xix, OBJECT_REGISTRY` / `add xix, xde`). */

struct objreg { long cls; void *proc; int count; void *base; };
extern struct objreg OBJECT_REGISTRY[];

void RegisterObjectTable(unsigned int n, struct objreg *r)
{
    if (n > 0x45f)
        return;
    *(struct objreg *)((unsigned long)OBJECT_REGISTRY + (unsigned long)n * 14) = *r;
}
