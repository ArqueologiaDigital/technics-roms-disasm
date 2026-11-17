/* lane_p6 helper H, round 15, module 272 (ui/ui_widget_defs.s), form a: RegisterObjectTable (new): copies a 14-byte
   registration record {class, proc, count, table} into object registry slot n (n <= 0x45f; the registry has 1120
   slots, cleared by InitializeObjectTable).  The ROM scales n by 14 in 32 bits (sll 3 / sub / add), loads the
   registry base as an immediate (`ld xix, OBJECT_REGISTRY`, the converted-pointer form) and copies 7 words with
   ldirw.  Form a: plain struct-array assignment. */

struct objreg { long cls; void *proc; int count; void *base; };
extern struct objreg OBJECT_REGISTRY[];

void RegisterObjectTable(unsigned int n, struct objreg *r)
{
    if (n > 0x45f)
        return;
    OBJECT_REGISTRY[n] = *r;
}
