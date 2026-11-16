/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_3b.c (2026-11-16-37-p6-r5)
   sha256 87e701e28dc0ffe6e2c00b6fe7f01531d2c1c5e103ce52a0a7404b5d93a5dc63 (tar-sha256); compiled at -Xr */
extern unsigned int __near ram_281e;
extern unsigned int __near ram_27c2;
extern unsigned int __near ram_27c4;
extern unsigned int __near ram_27c6;
extern unsigned int __near ram_27c8;
extern unsigned int ram_210b2;
extern unsigned char ram_210b0;
extern unsigned int BmDrEdit_RenderVertical_Table[];
void BmDrEdit_RenderSecondaryVert(void)
{
	ram_27c2 = (ram_281e >> 2) + 0x5b;
	ram_27c4 = (ram_210b2 >> 2) + ram_27c2;
	ram_27c6 = BmDrEdit_RenderVertical_Table[ram_210b0];
	ram_27c8 = ram_27c6 + 3;
	ram_27c6 -= 2;
	ram_27c8 += 2;
}
