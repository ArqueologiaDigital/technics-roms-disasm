/* lane_p6 helper H, round 16, module 272 (ui/ui_widget_defs.s), form a: UnRegisterObject (new, inside
   RegisterObjectTable's pool range): for the object id's class (bits 16..27), clears entry idx of the class's table,
   sets entry idx of the class + 0x300 table to the empty name, and counts the class's entries down.  The ROM: class
   in HL (16-bit), class * 14 in 32 bits, the registry base held in XIX for both records, idx * 4 shared by both
   stores, the count decremented in memory through the class record (XBC).  The second parameter is not used (DE
   holds idx).  Form a: the class record through a pointer local. */

struct objreg { long cls; void *proc; int count; void **base; };
extern struct objreg OBJECT_REGISTRY[];
extern char UnRegisterObject_EmptyName[];

void UnRegisterObject(unsigned long id, long obj, unsigned int idx)
{
    unsigned int c;
    struct objreg *e;

    c = (unsigned int)((id >> 16) & 0xfff);
    e = &OBJECT_REGISTRY[c];
    e->base[idx] = 0;
    OBJECT_REGISTRY[c + 0x300].base[idx] = UnRegisterObject_EmptyName;
    e->count--;
}
