/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_3a.c (2026-11-16-58-sub-r3)
   sha256 528c9ccfc8cfe66716d81cade2bea6c2e8912fd14acd603daeff550ed19b8639 (name+funcs); compiled at -Xr */
struct slotrt { unsigned char pad[26]; unsigned int w[8]; };
void SlotRouting_Chan3(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f)
{
    if ((f & 0x20) && ((f & 0xc0) >> 6) == ch) {
        if (f & 0x10) p->w[slot] = ch | 0x3300;
        else p->w[slot] = ch | 0x1100;
    }
}
