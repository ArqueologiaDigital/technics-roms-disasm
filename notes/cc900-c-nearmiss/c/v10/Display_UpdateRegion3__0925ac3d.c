/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_5b.c (2026-11-16-40-p6-r8)
   sha256 0925ac3d7624e564a79643524eac0977811cc2828328dc740296e5ffc2f35240 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char DISPLAY_ENABLE_FLAG;
extern unsigned char DISPLAY_DIRTY_FLAGS;
extern void Display_RedrawMainContent();
void Display_UpdateRegion3(void)
{
    if (!(DISPLAY_ENABLE_FLAG & 1)) {
        DISPLAY_DIRTY_FLAGS |= 8;
        return;
    }
    if (DISPLAY_DIRTY_FLAGS & 8) Display_RedrawMainContent();
}
