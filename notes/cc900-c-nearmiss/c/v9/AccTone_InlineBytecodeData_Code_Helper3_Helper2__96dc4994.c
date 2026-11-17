/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/accompaniment_engine_m249.c (2026-11-16-68-p6-r12)
   sha256 96dc499468bb1f48a02876b0a47d42f67bcad87762b2bae64aef9419c6df1475 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: AccTone_InlBcData_H3_Helper2=AccTone_InlineBytecodeData_Code_Helper3_Helper2 */
extern unsigned char __near ACC_REQ_INTRO;
extern unsigned char __near PANEL_STYLE[];
extern void AddswbWr(int, int, int, int);
void AccTone_InlBcData_H3_Helper2(void)
{
    ACC_REQ_INTRO &= ~0x1;
    PANEL_STYLE[5] &= ~0x4;
    AddswbWr(72, 5, 0, 0);
}
