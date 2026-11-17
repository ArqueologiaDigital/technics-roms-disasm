/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/bmdredit_routines_m232.c (2026-11-16-111-p6-r22-staged)
   sha256 2c442fbe559902db6d1bb616a5f0a05ab1d09ee762bbda8ebc02d696d6663aa6 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_2742;
extern void BmDrEdit_InitCommon(void);
extern unsigned int __near ram_2792;
extern unsigned int __near ram_2794;
extern unsigned int __near ram_278e;
extern unsigned int __near ram_2790;
extern unsigned char __near ram_2774;
extern unsigned char __near ram_27a2;
void BmDrEdit_InitMelodicMode(void)
{
	ram_2792 = ram_2794;
	ram_278e = ram_2790;
	ram_2742 &= ~1;
	ram_2774 = 10;
	ram_27a2 = 11;
	BmDrEdit_InitCommon();
}
