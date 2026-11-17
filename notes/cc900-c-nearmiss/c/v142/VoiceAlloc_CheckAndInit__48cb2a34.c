/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_6a.c (2026-11-16-73-sub-r6)
   sha256 48cb2a34c932b610dc7a2362e4cb075b87eb421455fb87b353b9fb0553972087 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];
extern unsigned char ram_451a4;
extern void VoiceParam_FullSetup();
extern void WaveSel_Rebuild_PartCaches();
void VoiceAlloc_CheckAndInit(unsigned char part)
{
    if (ram_451a4 == part) {
        if (part <= 2 || (*(unsigned int *)(ram_41368 + part * 0x11f) & 3) == 3) {
            if (*(unsigned int *)(ram_41368 + part * 0x11f) & 1) {
                *(unsigned int *)(ram_41368 + part * 0x11f) |= 1;
            } else {
                *(unsigned int *)(ram_41368 + part * 0x11f) |= 1;
                VoiceParam_FullSetup(part);
                WaveSel_Rebuild_PartCaches(part, ram_41381[part * 0x11f], ram_41382[part * 0x11f]);
            }
        }
    }
}
