/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17b.c (2026-11-16-126-sub-r17)
   sha256 103952cb479afdc1c60db40fc3853c5ae181d89a51e462c0596d12a2a476ff39 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_451a7;
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
extern void EFF_RoutingInit(int, int, int);
void Voice_Part_ResetSlotRouting(unsigned char part)
{
    unsigned int k;
    if (ram_451a7 != 0xf5) {
        for (k = 0; k < 4; k++) {
            (*(unsigned char **)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[k])[6] &= 7;
            (*(unsigned char **)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[k])[6] |= 0x20;
        }
        AlgoFlag_Write_Bit3(part, 0, 0);
        AlgoFlag_Write(part, 0, 0);
    } else {
        for (k = 0; k < 4; k++)
            (*(unsigned char **)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[k])[6] &= 7;
        AlgoFlag_Write_Bit3(part, 0, 0);
        AlgoFlag_Write(part, 0, 0);
    }
    for (k = 0; k < 4; k++)
        EFF_RoutingInit(part, (unsigned char)k, 0);
}
