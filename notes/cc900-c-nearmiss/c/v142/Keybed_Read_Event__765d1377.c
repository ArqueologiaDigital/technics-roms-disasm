/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_X_18c.c (2026-11-17-7-sub-r18)
   sha256 765d137710de7b401c4427e3d7f5a9fdcc18d6307c73bba0f901ebcfe5e4efee (name+funcs); compiled at -Xr */
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
        lo = (unsigned char)d & 0xff;
        hi = (unsigned char)(d >> 8) & 0xff;
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
