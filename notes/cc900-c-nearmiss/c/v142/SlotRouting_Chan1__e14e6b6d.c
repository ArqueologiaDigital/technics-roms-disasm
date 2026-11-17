/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_3b.c (2026-11-16-58-sub-r3)
   sha256 e14e6b6d5c368715cf8ab076373270904387a8c8c479bba7f55ed229322f8ab3 (name+funcs); compiled at -Xr */
struct slotrt { unsigned char pad[26]; unsigned int w[8]; };
void SlotRouting_Chan1(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f)
{
    if ((f & 0x20) && ((f & 0xc0) >> 6) == ch) {
        if (f & 0x10) p->w[slot] = (unsigned int)ch | 0xc000;
        else p->w[slot] = (unsigned int)ch | 0x4000;
    }
}
