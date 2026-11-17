/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_3a.c (2026-11-16-58-sub-r3)
   sha256 528c9ccfc8cfe66716d81cade2bea6c2e8912fd14acd603daeff550ed19b8639 (name+funcs); compiled at -Xr */
extern unsigned int ram_41343;
extern unsigned char ram_41368[];
extern unsigned char ram_41383[];
extern unsigned char ram_41384[];
extern unsigned char ram_41385[];
extern unsigned char ram_41387[];
extern unsigned char ram_41388[];
void Voice_NoteState_Clear(unsigned char part)
{
    unsigned int i;
    unsigned int j;
    if (ram_41343 & 1) return;
    *(unsigned int *)(ram_41385 + part * 0x11f) = 0;
    ram_41387[part * 0x11f] = 0;
    ram_41388[part * 0x11f] = 0;
    ram_41383[part * 0x11f] = 0x40;
    ram_41384[part * 0x11f] = 0x40;
    for (i = 0; i < 4; i++) {
        for (j = 0; j < 3; j++) {
            (ram_41368 + part * 0x11f + (((unsigned long)j << 4) + ((unsigned long)i << 2)))[41] = 0;
            (ram_41368 + part * 0x11f + (((unsigned long)j << 4) + ((unsigned long)i << 2)))[42] = 0;
        }
    }
}
