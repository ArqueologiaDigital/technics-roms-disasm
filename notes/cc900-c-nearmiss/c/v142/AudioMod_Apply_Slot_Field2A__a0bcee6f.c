/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AD_20c.c (2026-11-18-6-sub-r20a)
   sha256 a0bcee6f13b350ee7df36c3b3a10e509099b990fb67f18aeb07615d7a160fd5c (tar-sha256); compiled at -Xr */
struct f40 { unsigned char pad[40]; unsigned char f40, f41, f42; };
extern unsigned char ram_41368[];
void AudioMod_Apply_Slot_Field2A(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot, unsigned char k)
{
    unsigned char x, y;
    unsigned int d, t;
    if (m[1] & 0x80) {
        if (val > 64) {
            val = val - 64;
            val *= 2;
        } else val = 0;
    }
    if (val != 0) {
        x = ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f40 & 0x55;
        y = m[0] & 0x55;
        x = x | y;
        y = m[0] & 0xaa;
        ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f40 = x | y;
    } else ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f40 = 0;
    t = val;
    d = m[2];
    t = t * d;
    t >>= 6;
    if (t == 0 && val != 0) t = 1;
    ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f42 = t;
}
