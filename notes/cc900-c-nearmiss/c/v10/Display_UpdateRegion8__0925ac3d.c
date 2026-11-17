/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_5b.c (2026-11-16-40-p6-r8)
   sha256 0925ac3d7624e564a79643524eac0977811cc2828328dc740296e5ffc2f35240 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char DISPLAY_ENABLE_FLAG;
extern unsigned char ram_205e5;
extern void Display_RedrawValues();
void Display_UpdateRegion8(void)
{
    if (!(DISPLAY_ENABLE_FLAG & 1)) ram_205e5 |= 2;
    if (ram_205e5 & 2) Display_RedrawValues();
}
