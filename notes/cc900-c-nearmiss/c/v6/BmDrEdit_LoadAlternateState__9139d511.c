/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/bmdredit_routines_m232.c (2026-11-16-111-p6-r22-staged)
   sha256 9139d51173de3c6df4cc43483d82892599c6a3174583b673d17d218a3a04154d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near ram_2744;
extern unsigned int __near ram_2750;
extern unsigned char __near ram_2746;
extern unsigned char __near ram_2752;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near ram_2754;
extern unsigned char __near ram_2756;
extern unsigned int __near SEQ_DATA_OFFSET;
void BmDrEdit_LoadAlternateState(void)
{
	ram_2744 = ram_2750;
	ram_2746 = ram_2752;
	SEQ_DATA_BLOCK = ram_2754;
	SEQ_DATA_OFFSET = ram_2756;
}
