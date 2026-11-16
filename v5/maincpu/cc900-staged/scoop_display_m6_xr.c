/* Functions of display/scoop_display.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char DISPLAY_ENABLE_FLAG;
extern unsigned int DISPLAY_DIRTY_FLAGS;
extern void Display_UpdateRegion0(void);
extern void Display_UpdateRegion1(void);
extern void Display_UpdateRegion2(void);
extern void Display_UpdateRegion3(void);
extern void Display_UpdateRegion4(void);
extern void Display_UpdateRegion5(void);
extern void Display_UpdateRegion6(void);
extern void Display_UpdateRegion7(void);
extern void Display_UpdateRegion8(void);
extern void Display_UpdateRegion9(void);
extern void Display_UpdateRegion10(void);

void Display_UpdateDirtyRegions(void)
{
    DISPLAY_ENABLE_FLAG = 1;
    if (DISPLAY_DIRTY_FLAGS != 0) {
        Display_UpdateRegion0();
        Display_UpdateRegion5();
        Display_UpdateRegion7();
        Display_UpdateRegion8();
        Display_UpdateRegion9();
        Display_UpdateRegion1();
        Display_UpdateRegion10();
        Display_UpdateRegion6();
        Display_UpdateRegion3();
        Display_UpdateRegion4();
        Display_UpdateRegion2();
    }
    DISPLAY_DIRTY_FLAGS = 0xffff;
}
