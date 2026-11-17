/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_ui_display.c (2026-11-16-63-hd-r9s-staged)
   sha256 2610f2d47235e6bafa77af76c8ae213654c07fa497cb63b72f0218c0808b5785 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_FlsAutoLoadPending;
unsigned char HDAE5000_Fls_GetAutoLoadPending(void)
{
    return HDAE5000_RAM_FlsAutoLoadPending;
}
