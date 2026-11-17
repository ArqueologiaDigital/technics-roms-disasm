/* cc900-module: InitGraphics_SetupVRAM_Loop LcdOn_Return */
/* Phase 6, lane_p6 helper A, round 20, form a: module 273 (ui/ui_widget_defs.s), Gfx_BlitDirtyRegions: round 19a, the palette index passed as (unsigned char)i to an int parameter. */
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
extern void VGA_WritePaletteEntry(int i, unsigned long *rgb);
extern void AllBOut(void);
extern void DisplayBuffer_Process(void);

void Gfx_BlitDirtyRegions(void)
{
    unsigned long *pe;
    unsigned long ent;
    unsigned int i;
    if (ram_3ef92 != 0 && DISPLAY_UPDATE_FLAG != 0) {
        if (PALETTE_UPDATE_FLAG != 0) {
            if (PALETTE_INDEX_CACHED != 4 || (PALETTE_INDEX_PREVIOUS != 4 && PALETTE_INDEX_CACHED == 4)) {
                LcdOn_Return();
                pe = &ent;
                for (i = 0; i < 0x100; i++) {
                    ent = Table_LookupDword(i);
                    VGA_WritePaletteEntry((unsigned char)i, pe);
                }
            }
        } else if (ram_30462 != 0) {
            pe = &ent;
            for (i = 0xe0; i < 0xf0; i++) {
                ent = Table_LookupDword(i);
                VGA_WritePaletteEntry((unsigned char)i, pe);
            }
        }
        if (DIRTY_BBOX.y1 - DIRTY_BBOX.y0 == 0xef && DIRTY_BBOX.x1 - DIRTY_BBOX.x0 == 0x13f)
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
        DIRTY_BBOX.y0 = 0xf0;
        DIRTY_BBOX.x0 = 0x140;
        DIRTY_BBOX.x1 = -1;
        DIRTY_BBOX.y1 = -1;
    }
}
