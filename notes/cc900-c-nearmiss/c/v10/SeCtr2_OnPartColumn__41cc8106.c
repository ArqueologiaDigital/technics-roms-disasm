/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_17m129b.c (2026-11-16-107-p6-r21)
   sha256 41cc8106ac2042a106a57c77c689c80099e3c1a76c55fe5a5fca2be6397f0f3d (tar-sha256); compiled at -O3 -Xr */
extern void SeCtr2_StepPartField(unsigned char part, unsigned char up);
extern void SeMenu_BindDialToColumn(unsigned char col);
void SeCtr2_OnPartColumn(unsigned char part, unsigned char bank)
{
    unsigned char f;
    f = (bank & 0x7f) != 0;
    SeCtr2_StepPartField(part, f);
    SeMenu_BindDialToColumn(part + 4);
}
