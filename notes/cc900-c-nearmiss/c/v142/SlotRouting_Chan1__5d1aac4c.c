/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w4b.c (2026-11-19-10-sub-r23w-asm)
   sha256 5d1aac4ca50940854bfb44a81274aaa78db57d9047b0a9a61a4c26ae9575110a (name+funcs); compiled at -Xr
   cc900-options: -Xr */
struct slotrt { unsigned char pad[26]; unsigned int w[8]; };
void SlotRouting_Chan1(struct slotrt *p, unsigned char slot, unsigned char ch, unsigned char f)
{
    if ((f & 0x20) && ((f & 0xc0) >> 6) == ch) {
        if (f & 0x10) p->w[slot] = (unsigned int)ch | 0xc000;
        else p->w[slot] = (unsigned int)ch | 0x4000;
    }
}
