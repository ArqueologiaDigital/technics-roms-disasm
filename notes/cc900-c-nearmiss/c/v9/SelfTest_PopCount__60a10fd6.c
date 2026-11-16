/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_mode_handlers.c (2026-11-16-55-p6-r10)
   sha256 60a10fd657f38e3147b987886ac918ce0139df81b88a61ee998701ccab02e7f8 (tar-sha256); compiled at -Xr
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
