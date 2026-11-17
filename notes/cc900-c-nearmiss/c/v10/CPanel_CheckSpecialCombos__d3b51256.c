/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_2a.c (2026-11-16-35-p6-r3)
   sha256 d3b51256cb6766ba5ee356b2f9ad6f2a91b76a80223fa8ae1385d53c17b0fdaa (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_8e5e;
extern unsigned char __near ram_8e4b;
extern unsigned char __near ram_8e60;
extern unsigned char __near ram_8e50;
int CPanel_CheckSpecialCombos(void)
{
	int r;

	if (ram_8e5e == 108) r = 3;
	else if (ram_8e4b == 112) r = 2;
	else if (ram_8e60 == 56) r = 1;
	else if (ram_8e50 == 15) r = 4;
	else r = 0;
	return r;
}
