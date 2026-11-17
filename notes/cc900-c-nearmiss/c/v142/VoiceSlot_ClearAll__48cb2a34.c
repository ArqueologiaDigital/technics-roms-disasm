/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_6a.c (2026-11-16-73-sub-r6)
   sha256 48cb2a34c932b610dc7a2362e4cb075b87eb421455fb87b353b9fb0553972087 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_451a4;
extern void Voice_NoteState_Clear();
extern void NoteState_ClearRecord();
void VoiceSlot_ClearAll(void)
{
    unsigned int i;
    unsigned int j;
    unsigned char p;
    for (p = 0; p < 26; p++) {
        for (i = 0; i < 4; i++) {
            for (j = 0; j < 3; j++) {
                ((unsigned char *)((unsigned long)(ram_41368 + p * 0x11f) + (((unsigned long)j << 4) + ((unsigned long)i << 2))))[39] = 0;
                ((unsigned int *)((unsigned long)(ram_41368 + p * 0x11f) + ((unsigned long)i * 37 + (unsigned long)j * 2)))[68] = 0;
            }
        }
        Voice_NoteState_Clear(p);
    }
    for (i = 0; i < 64; i++) {
        for (j = 0; j < 3; j++) NoteState_ClearRecord((unsigned char)i, (unsigned char)j);
    }
    ram_451a4 = 0xff;
}
