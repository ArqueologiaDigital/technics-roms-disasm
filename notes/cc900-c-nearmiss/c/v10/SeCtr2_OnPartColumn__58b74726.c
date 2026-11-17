/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_18m129b.c (2026-11-16-118-p6-r23)
   sha256 58b7472602523e16bf72608ad52e7959eeb087cbe9749bc3c3639c63a7f82c25 (tar-sha256); compiled at -Xr */
extern void SeCtr2_StepPartField(unsigned char part, unsigned char up);
extern void SeMenu_BindDialToColumn(unsigned char col);
void SeCtr2_OnPartColumn(unsigned char part, unsigned char bank)
{
    unsigned char f;
    if (bank & 0x7f)
        f = 1;
    else
        f = 0;
    SeCtr2_StepPartField(part, f);
    SeMenu_BindDialToColumn(part + 4);
}
