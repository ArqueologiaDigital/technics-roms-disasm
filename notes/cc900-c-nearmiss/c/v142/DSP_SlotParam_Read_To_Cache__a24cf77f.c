/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_4a.c (2026-11-16-62-sub-r4)
   sha256 a24cf77f8f049afccae4323475659f7526d8e2c4b8ca651c8900655a87adb798 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_44fce[];
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
void DSP_SlotParam_Read_To_Cache(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = *(unsigned char **)((struct partrec *)(ram_41368 + part * 0x11f))->partial[slot];
    q = ram_44fce + ((int)slot * 5 + 480);
    if ((rec[54] & 7) != *q) return;
    for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 77];
}
