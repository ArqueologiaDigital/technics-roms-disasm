/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_14m232.c (2026-11-16-100-p6-r19)
   sha256 b5c38cb9e43a3631f9fd76c608f47f2f41b66081cae679390eebe9933612b9ff (tar-sha256); compiled at -O3 -XS -Xr */
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
