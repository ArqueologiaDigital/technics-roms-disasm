/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17a.c (2026-11-16-126-sub-r17)
   sha256 6c9da23be1740b125262337d35d6419d9e17f20c3d4204d47661ba77eaf9761b (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char ram_41381[];
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
struct slotrec { unsigned char *p0; unsigned char *vel; };
extern unsigned char *WaveSel_StageA1_FindVelSplit(int, int, int, int, int);
unsigned char *WaveSel_StageA1_FromPatchBlock(unsigned char part, unsigned char slot)
{
    int x;
    int y;
    x = ((struct slotrec *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[slot])->p0[2];
    y = ((struct slotrec *)((struct partrec *)(ram_41368 + (part) * 0x11f))->partial[slot])->p0[3];
    return WaveSel_StageA1_FindVelSplit(slot, (unsigned char)x, (unsigned char)y, ram_41381[part * 0x11f], part);
}
