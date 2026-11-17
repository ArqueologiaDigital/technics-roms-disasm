/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_14m232.c (2026-11-16-100-p6-r19)
   sha256 b5c38cb9e43a3631f9fd76c608f47f2f41b66081cae679390eebe9933612b9ff (tar-sha256); compiled at -O3 -XS -Xr */
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
