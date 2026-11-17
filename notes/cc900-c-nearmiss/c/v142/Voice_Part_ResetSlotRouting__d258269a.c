/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_11c.c (2026-11-16-94-sub-r11)
   sha256 d258269aa950011b51ef3adeeec84d2896b595c4ed0a11aa7290611a3714545f (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_451a7;
extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
extern void EFF_RoutingInit(int, int, int);
void Voice_Part_ResetSlotRouting(unsigned char part)
{
    unsigned int k;

    if (ram_451a7 != 0xf5) {
        for (k = 0; k < 4; k++) {
            (*(unsigned char **)((ram_41368 + (long)((int)part * 0x11f)) + ((unsigned long)k * 37 + 110)))[6] &= 7;
            (*(unsigned char **)((ram_41368 + (long)((int)part * 0x11f)) + ((unsigned long)k * 37 + 110)))[6] |= 0x20;
        }
        AlgoFlag_Write_Bit3(part, 0, 0);
        AlgoFlag_Write(part, 0, 0);
    } else {
        for (k = 0; k < 4; k++)
            (*(unsigned char **)((ram_41368 + (long)((int)part * 0x11f)) + ((unsigned long)k * 37 + 110)))[6] &= 7;
        AlgoFlag_Write_Bit3(part, 0, 0);
        AlgoFlag_Write(part, 0, 0);
    }
    for (k = 0; k < 4; k++)
        EFF_RoutingInit(part, (unsigned char)k, 0);
}
