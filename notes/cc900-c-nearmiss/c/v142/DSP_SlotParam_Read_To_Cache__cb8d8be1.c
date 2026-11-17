/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17c.c (2026-11-16-126-sub-r17)
   sha256 cb8d8be11508728097d9e78ae3bf4fbe5f7b1c76f6a92dd24928a8442d7e7268 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_44fce[];
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
void DSP_SlotParam_Read_To_Cache(unsigned char part, unsigned char slot)
{
    unsigned char *rec;
    unsigned char *q;
    unsigned int i;
    rec = *(unsigned char **)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[slot];
    q = (((int)slot * 5 + 480) + ram_44fce);
    if ((rec[54] & 7) != *q) return;
    for (i = 0; i < 4; i++) q[(unsigned long)i + 1] = rec[(unsigned long)i + 77];
}
