/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_18m273b.c (2026-11-16-118-p6-r23)
   sha256 3ae157cd74ad1c569cc6e845daa973804ea82f686969c6f3f0a3ab8ba345d94d (tar-sha256); compiled at -O3 -Xr */
struct rect { int x0, y0, x1, y1; };
extern int ram_3ef92;
extern int ram_30462;
extern int DISPLAY_UPDATE_FLAG;
extern int PALETTE_UPDATE_FLAG;
extern int PALETTE_INDEX_CACHED;
extern int PALETTE_INDEX_PREVIOUS;
extern struct rect DIRTY_BBOX;
extern void LcdOn_Return(void);
extern void InitGraphics_SetupVRAM_Loop(void);
extern unsigned long Table_LookupDword(int i);
extern void VGA_WritePaletteEntry(unsigned char i, unsigned long *rgb);
extern void AllBOut(void);
extern void DisplayBuffer_Process(void);
void Gfx_BlitDirtyRegions(void)
{
    unsigned long *pe;
    unsigned long ent;
    unsigned int i;
    struct rect *r;
    if (ram_3ef92 == 0 || DISPLAY_UPDATE_FLAG == 0)
        return;
    if (PALETTE_UPDATE_FLAG != 0) {
        if (PALETTE_INDEX_CACHED != 4 || PALETTE_INDEX_PREVIOUS != 4 && PALETTE_INDEX_CACHED == 4) {
            LcdOn_Return();
            pe = &ent;
            for (i = 0; i < 0x100; i++) {
                *pe = Table_LookupDword(i);
                VGA_WritePaletteEntry(i, pe);
            }
        }
    } else if (ram_30462 != 0) {
        pe = &ent;
        for (i = 0xe0; i < 0xf0; i++) {
            *pe = Table_LookupDword(i);
            VGA_WritePaletteEntry(i, pe);
        }
    }
    r = &DIRTY_BBOX;
    if (r->y1 - r->y0 == 0xef && r->x1 - r->x0 == 0x13f)
        AllBOut();
    else
        DisplayBuffer_Process();
    if (PALETTE_UPDATE_FLAG != 0) {
        InitGraphics_SetupVRAM_Loop();
        PALETTE_INDEX_PREVIOUS = PALETTE_INDEX_CACHED;
        PALETTE_UPDATE_FLAG = 0;
        ram_30462 = 0;
    } else if (ram_30462 != 0)
        ram_30462 = 0;
    DISPLAY_UPDATE_FLAG = 0;
    r = &DIRTY_BBOX;
    r->y0 = 0xf0;
    r->x0 = 0x140;
    r->x1 = -1;
    r->y1 = -1;
}
