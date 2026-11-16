/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/bmdredit_routines_m232.c (2026-11-16-111-p6-r22-staged)
   sha256 2c442fbe559902db6d1bb616a5f0a05ab1d09ee762bbda8ebc02d696d6663aa6 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near ram_275e;
extern unsigned int __near ram_276a;
extern unsigned char __near ram_2760;
extern unsigned char __near ram_276c;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near ram_276e;
extern unsigned char __near ram_2770;
extern unsigned int __near SEQ_DATA_OFFSET;
void BmDrEdit_LoadAlternateState(void)
{
	ram_275e = ram_276a;
	ram_2760 = ram_276c;
	SEQ_DATA_BLOCK = ram_276e;
	SEQ_DATA_OFFSET = ram_2770;
}
