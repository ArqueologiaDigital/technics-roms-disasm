/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/bmdredit_routines_m232.c (2026-11-16-111-p6-r22-staged)
   sha256 08d180327d39612b36806070e17419d5ff27e6973cb45f2ed75fb40b17d07ac7 (tar-sha256); compiled at -O3 -Xr
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
