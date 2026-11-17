/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_4b.c (2026-11-16-62-sub-r4)
   sha256 b0df8e0b49e3477310bfbc8eb1db4d0a27fc8cbcb08ab817f13c8569d38158d2 (name+funcs); compiled at -Xr */
extern unsigned char ram_44fce[];
extern unsigned char *ram_4531c;
void DSP_SlotParam_Read_To_Cache_B(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = (unsigned char *)((unsigned long)(ram_4531c + ((int)ram_4531c[29351] * 80 + (int)slot * 21)) + 19127);
    q = ram_44fce + ((int)slot * 5 + 500);
    if ((rec[15] & 7) == *q) {
        for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 17];
    }
}
