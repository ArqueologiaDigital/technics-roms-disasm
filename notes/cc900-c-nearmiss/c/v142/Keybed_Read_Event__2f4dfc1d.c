/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_X_18a.c (2026-11-17-7-sub-r18)
   sha256 2f4dfc1d8ac8c3544bcd465502dc201e2b0fa76d164bd67b38a298482bf828df (name+funcs); compiled at -Xr */
extern unsigned char __tiny ram_18;
extern unsigned int ram_110000;
extern unsigned int ram_110002;
extern void Keybed_Decode_Event(unsigned char *ev, char d);
unsigned int Keybed_Read_Event(unsigned char *ev)
{
    unsigned char lo;
    unsigned char hi;
    int st;
    unsigned int d;

    ram_18 |= 0x80;
    __ASM(" nop");
    st = ram_110002;
    if (st & 1) {
        ram_18 &= ~0x80;
        __ASM(" nop");
        d = ram_110000;
        lo = d & 0xff;
        hi = (d >> 8) & 0xff;
        if (hi == 0xff || (st & 2)) {
            if (lo & 0x80)
                return 0xffff;
            Keybed_Decode_Event(ev, lo);
            ev[1] = 0;
            return 0;
        } else {
            Keybed_Decode_Event(ev, lo);
            return 0;
        }
    }
    return 0xffff;
}
