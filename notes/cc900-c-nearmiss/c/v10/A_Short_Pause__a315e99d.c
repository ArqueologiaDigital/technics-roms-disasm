/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_4a.c (2026-11-16-40-p6-r8)
   sha256 a315e99d2abe85580e38dfba3d46d23a20ad559e556e2bf7a471551863fb0ae9 (tar-sha256); compiled at -Xr */
void A_Short_Pause(void)
{
	unsigned int i, j;

	for (i = 0; i < 0x1000; i++)
		for (j = 0; j < 0x100; j++)
			;
}
