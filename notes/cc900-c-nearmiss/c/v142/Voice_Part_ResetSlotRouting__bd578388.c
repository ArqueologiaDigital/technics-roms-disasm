/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_11b.c (2026-11-16-94-sub-r11)
   sha256 bd5783887b95ef5eafc767a653a0a38f9363723a2758927b050ad92af2b06c6f (name+funcs); compiled at -Xr */
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
            (*(unsigned char **)(((unsigned char *)((unsigned long)ram_41368 + (long)((int)part * 0x11f))) + ((unsigned long)k * 37 + 110)))[6] &= 7;
            (*(unsigned char **)(((unsigned char *)((unsigned long)ram_41368 + (long)((int)part * 0x11f))) + ((unsigned long)k * 37 + 110)))[6] |= 0x20;
        }
        AlgoFlag_Write_Bit3(part, 0, 0);
        AlgoFlag_Write(part, 0, 0);
    } else {
        for (k = 0; k < 4; k++)
            (*(unsigned char **)(((unsigned char *)((unsigned long)ram_41368 + (long)((int)part * 0x11f))) + ((unsigned long)k * 37 + 110)))[6] &= 7;
        AlgoFlag_Write_Bit3(part, 0, 0);
        AlgoFlag_Write(part, 0, 0);
    }
    for (k = 0; k < 4; k++)
        EFF_RoutingInit(part, (unsigned char)k, 0);
}
