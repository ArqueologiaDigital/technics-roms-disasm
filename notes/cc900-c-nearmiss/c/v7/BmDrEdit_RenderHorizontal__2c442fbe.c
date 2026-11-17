/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/bmdredit_routines_m232.c (2026-11-16-111-p6-r22-staged)
   sha256 2c442fbe559902db6d1bb616a5f0a05ab1d09ee762bbda8ebc02d696d6663aa6 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near ram_2808;
extern unsigned int __near ram_280a;
extern unsigned int __near ram_27ba;
extern unsigned int __near ram_27bc;
extern unsigned char __near ram_2806;
extern unsigned int __near ram_27be;
extern unsigned int __near ram_27c0;
extern unsigned int BmDrEdit_RenderVertical_Table[], BmDrEdit_RenderHorizontal_Table[];
void BmDrEdit_RenderHorizontal(void)
{
	ram_27ba = (ram_2808 >> 2) + 0x16;
	ram_27bc = (ram_280a >> 2) + ram_27ba;
	ram_27be = BmDrEdit_RenderHorizontal_Table[ram_2806];
	ram_27c0 = ram_27be + 3;
}
