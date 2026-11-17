/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_19m273b.c (2026-11-16-123-p6-r25)
   sha256 ea05e8a70bca47fe6742e26036b0d36e2da780795680896d460e61aeec9b5e42 (tar-sha256); compiled at -O3 -Xr */
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
    if (ram_3ef92 != 0 && DISPLAY_UPDATE_FLAG != 0) {
        if (PALETTE_UPDATE_FLAG != 0) {
            if (PALETTE_INDEX_CACHED != 4 || PALETTE_INDEX_PREVIOUS != 4 && PALETTE_INDEX_CACHED == 4) {
                LcdOn_Return();
                pe = &ent;
                i = 0;
                do {
                    ent = Table_LookupDword(i);
                    VGA_WritePaletteEntry(i, pe);
                } while (++i < 0x100);
            }
        } else if (ram_30462 != 0) {
            pe = &ent;
            i = 0xe0;
            do {
                ent = Table_LookupDword(i);
                VGA_WritePaletteEntry(i, pe);
            } while (++i < 0xf0);
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
