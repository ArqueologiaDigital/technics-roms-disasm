/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/scoop_display_m6_xr.c (2026-11-16-68-p6-r12)
   sha256 9b146377605be864291954beb4e67ebea01bc2bfb022923971bef92ae7c1bb6e (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
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
