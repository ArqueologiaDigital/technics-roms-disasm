/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_2m234a.c (2026-11-18-28-p6-r36)
   sha256 83477e50cd0933877fb88b736eaf1dcf6580c0002faff776e10fb4cfda7665b0 (tar-sha256); compiled at -O3 -Xr */
extern unsigned long __near ram_25da;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern unsigned char PartCtrl_TestBit7(unsigned int);
void PartCtrl_FindActiveByLimit(unsigned int *blk, unsigned int *pos)
{
	unsigned long n;
	unsigned long k;
	unsigned int w;

	n = (unsigned long)*pos - 4;
	if (n > ram_25da)
		n = n - ram_25da + 4;
	else {
		k = ram_25da - n;
		for (;;) {
			w = PartCtrl_ReadWord_Off1(*blk);
			if (w > 0x4d8) {
				SEQ_ERROR_CODE = 10;
				return;
			}
			*blk = w;
			if (PartCtrl_TestBit7(w) == 0) {
				SEQ_ERROR_CODE = 11;
				return;
			}
			if (k <= 0xfb)
				break;
			k -= 0xfb;
		}
		n = 0xff - k;
	}
	*pos = n;
}
