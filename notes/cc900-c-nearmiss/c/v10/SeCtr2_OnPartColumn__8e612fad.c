/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_18m129a.c (2026-11-16-118-p6-r23)
   sha256 8e612fad7397452076ffefb24a11a402ad464cbd728734a396b11791849b42f5 (tar-sha256); compiled at -O3 -Xr */
extern void SeCtr2_StepPartField(unsigned char part, unsigned char up);
extern void SeMenu_BindDialToColumn(unsigned char col);
void SeCtr2_OnPartColumn(unsigned char part, unsigned char bank)
{
    bank &= 0x7f;
    bank = bank != 0;
    SeCtr2_StepPartField(part, bank);
    SeMenu_BindDialToColumn(part + 4);
}
