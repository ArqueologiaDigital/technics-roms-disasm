/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/scoop_display_xr.c (2026-11-16-55-p6-r10)
   sha256 90c7a025cd4ac8377bfe8488998b0d69ccd735c31844298afb0eca5cd9ca9440 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned char DISPLAY_ENABLE_FLAG;
extern unsigned int DISPLAY_DIRTY_FLAGS;
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
