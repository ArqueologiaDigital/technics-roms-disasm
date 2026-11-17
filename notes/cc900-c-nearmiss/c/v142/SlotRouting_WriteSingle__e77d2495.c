/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_2a.c (2026-11-16-47-sub-r2)
   sha256 e77d2495b549821b0ba06f8b78d5c1927c12696a39635b76364de81b0b34400e (name+funcs); compiled at -Xr */
void SlotRouting_WriteSingle(unsigned int *p, unsigned char slot, unsigned char ch, unsigned char f)
{
    if (f & 0x20) {
        if (((f & 0xc0) >> 6) == ch) {
            if (f & 0x10) p[slot + 13] = ch | 0xc0;
            else p[slot + 13] = ch | 0x40;
        }
    }
}
