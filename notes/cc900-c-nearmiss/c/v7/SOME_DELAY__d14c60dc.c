/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/fdc_routines_xr.c (2026-11-16-55-p6-r10)
   sha256 d14c60dc63065cbea79ab82b671b556151e931c5680eb5adc1878b4c3394bf7d (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int __near SYSTEM_TIMESTAMP;
void SOME_DELAY(unsigned int n)
{
	unsigned int i, t;

	n >>= 1;
	t = SYSTEM_TIMESTAMP;
	i = 0;
	while (i < 0xffff) {
		if (SYSTEM_TIMESTAMP - t > n) return;
		i++;
	}
}
