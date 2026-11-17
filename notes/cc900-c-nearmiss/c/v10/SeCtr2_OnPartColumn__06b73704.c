/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_18m129c.c (2026-11-16-118-p6-r23)
   sha256 06b73704d0a6ee2b8d0f07d65b5afea068f667cea68d85ddbb07e2cd878a69bd (tar-sha256); compiled at -O3 -Xr */
extern void SeCtr2_StepPartField(unsigned char part, unsigned char up);
extern void SeMenu_BindDialToColumn(unsigned char col);
void SeCtr2_OnPartColumn(unsigned char part, unsigned char bank)
{
    unsigned char f;
    f = (bank & 0x7f) ? 1 : 0;
    SeCtr2_StepPartField(part, f);
    SeMenu_BindDialToColumn(part + 4);
}
