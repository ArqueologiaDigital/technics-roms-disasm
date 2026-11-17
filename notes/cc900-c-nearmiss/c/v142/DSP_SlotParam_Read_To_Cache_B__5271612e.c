/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_8a.c (2026-11-16-82-sub-r8)
   sha256 5271612e7d59e0ac0b599e48272e105137d32c9eb2c7c00051e3a30ef7dd2a4d (name+funcs); compiled at -Xr */
extern unsigned char ram_44fce[][5];
extern unsigned char *ram_4531c;
void DSP_SlotParam_Read_To_Cache_B(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = &((unsigned char *)(unsigned long)(ram_4531c + ((int)ram_4531c[29351] * 80 + (int)slot * 21)))[19127];
    q = &ram_44fce[slot][500];
    if ((rec[15] & 7) != *q) return;
    for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 17];
}
