/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/accompaniment_engine.c (2026-11-16-55-p6-r10)
   sha256 bc1b9c5f81977c1c3e3ca3aa0451f79a0f8e53b470427b60dbbb68bb1a654c94 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: AccTone_InlBcData_H3_Helper3=AccTone_InlineBytecodeData_Code_Helper3_Helper3 */
extern unsigned char __near ACC_REQ_INTRO;
extern unsigned char __near PANEL_STYLE[];
void AccTone_InlBcData_H3_Helper3(void)
{
    ACC_REQ_INTRO &= ~0x4;
    PANEL_STYLE[6] &= ~0x4;
    AddswbWr(72, 6, 0, 0);
}
