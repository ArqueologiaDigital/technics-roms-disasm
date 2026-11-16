/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/bmdredit_routines_m232.c (2026-11-16-111-p6-r22-staged)
   sha256 08d180327d39612b36806070e17419d5ff27e6973cb45f2ed75fb40b17d07ac7 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near ram_27ee;
extern unsigned int __near ram_27f0;
extern unsigned int __near ram_27a0;
extern unsigned int __near ram_27a2;
extern unsigned char __near ram_27ec;
extern unsigned int __near ram_27a4;
extern unsigned int __near ram_27a6;
extern unsigned int BmDrEdit_RenderVertical_Table[], BmDrEdit_RenderHorizontal_Table[];
void BmDrEdit_RenderHorizontal(void)
{
	ram_27a0 = (ram_27ee >> 2) + 0x16;
	ram_27a2 = (ram_27f0 >> 2) + ram_27a0;
	ram_27a4 = BmDrEdit_RenderHorizontal_Table[ram_27ec];
	ram_27a6 = ram_27a4 + 3;
}
