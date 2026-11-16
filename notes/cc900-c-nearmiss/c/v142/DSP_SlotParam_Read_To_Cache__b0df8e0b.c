/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_4b.c (2026-11-16-62-sub-r4)
   sha256 b0df8e0b49e3477310bfbc8eb1db4d0a27fc8cbcb08ab817f13c8569d38158d2 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_44fce[];
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
void DSP_SlotParam_Read_To_Cache(unsigned char part, unsigned char slot)
{
    unsigned char *q;
    unsigned char *rec;
    unsigned int i;
    rec = *(unsigned char **)((struct partrec *)(ram_41368 + part * 0x11f))->partial[slot];
    q = ram_44fce + ((int)slot * 5 + 480);
    if ((rec[54] & 7) != *q) return;
    for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 77];
}
