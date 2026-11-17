/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_17m129a.c (2026-11-16-107-p6-r21)
   sha256 698f64f0f1ea99498d87379fdf4d3cc047b1f0daa825dc1ac0fab1e8f0e65b0e (tar-sha256); compiled at -O3 -Xr */
extern void SeCtr2_StepPartField(unsigned char part, unsigned char up);
extern void SeMenu_BindDialToColumn(unsigned char col);
void SeCtr2_OnPartColumn(unsigned char part, unsigned char bank)
{
    unsigned char f;
    f = (bank & 0x7f) != 0;
    SeCtr2_StepPartField(part, f);
    SeMenu_BindDialToColumn(part + 4);
}
