/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_mode_handlers_m276.c (2026-11-16-68-p6-r12)
   sha256 7fa4a383980277171f2ffb7d967f5538db6963db46e511ee90ac68cdf720389e (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
unsigned char SelfTest_PopCount(unsigned char a)
{
	unsigned char n, i;

	n = 0;
	for (i = 0; i < 8; i++) {
		if (a & 1) n++;
		a >>= 1;
	}
	return n;
}
