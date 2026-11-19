/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w4a.c (2026-11-19-10-sub-r23w-asm)
   sha256 e3d2052b28570ae8bfe935ea9dda629d0d26b499fe425733ed49ee3544609745 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
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
            (*(unsigned char (*)[3][4][4])(ram_41368 + part * 0x11f + 41))[j][i][0] = 0;
            (*(unsigned char (*)[3][4][4])(ram_41368 + part * 0x11f + 41))[j][i][1] = 0;
        }
    }
}
