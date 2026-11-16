/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_2a.c (2026-11-16-35-p6-r3)
   sha256 d3b51256cb6766ba5ee356b2f9ad6f2a91b76a80223fa8ae1385d53c17b0fdaa (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_27a4[];
extern unsigned char __near ram_25d8;
extern unsigned int __near ram_279a;
extern unsigned int __near ram_2772;
extern unsigned int __near ram_27b2;
extern unsigned int __near ram_2744;
void BmDrEdit_CalcSongPosition(void)
{
	unsigned int i, n;
	unsigned char *t;
	unsigned int p;

	n = ram_279a / 96;
	ram_25d8 = 0;
	ram_2772 = n;
	if (n != 0) {
		i = 1;
		ram_25d8 = 0;
		t = ram_27a4;
		do {
			if (t[i] != 0) ram_25d8++;
			i++;
		} while ((ram_2772 = ram_2772 - 1) != 0);
	}
	p = ram_27b2;
	ram_2744 = p + ram_25d8;
}
