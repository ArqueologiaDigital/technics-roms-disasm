/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/bmdredit_routines_m232.c (2026-11-16-111-p6-r22-staged)
   sha256 9139d51173de3c6df4cc43483d82892599c6a3174583b673d17d218a3a04154d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_2728;
extern void BmDrEdit_InitCommon(void);
extern unsigned int __near ram_2778;
extern unsigned int __near ram_277a;
extern unsigned int __near ram_2774;
extern unsigned int __near ram_2776;
extern unsigned char __near ram_275a;
extern unsigned char __near ram_2788;
void BmDrEdit_InitMelodicMode(void)
{
	ram_2778 = ram_277a;
	ram_2774 = ram_2776;
	ram_2728 &= ~1;
	ram_275a = 10;
	ram_2788 = 11;
	BmDrEdit_InitCommon();
}
