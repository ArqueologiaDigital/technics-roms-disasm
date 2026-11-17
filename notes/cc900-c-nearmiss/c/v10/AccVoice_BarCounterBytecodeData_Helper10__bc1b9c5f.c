/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/accompaniment_engine.c (2026-11-16-55-p6-r10)
   sha256 bc1b9c5f81977c1c3e3ca3aa0451f79a0f8e53b470427b60dbbb68bb1a654c94 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: AccVoice_BarCntBcData_Helper10=AccVoice_BarCounterBytecodeData_Helper10 */
extern unsigned char __near ACC_REQ_FILLIN;
extern unsigned char __near PANEL_STYLE[];
void AccVoice_BarCntBcData_Helper10(void)
{
    ACC_REQ_FILLIN &= ~0x2;
    PANEL_STYLE[5] &= ~0x80;
    AddswbWr(72, 5, 0, 0);
}
