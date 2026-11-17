/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_4a.c (2026-11-16-40-p6-r8)
   sha256 a315e99d2abe85580e38dfba3d46d23a20ad559e556e2bf7a471551863fb0ae9 (tar-sha256); compiled at -Xr */
extern unsigned char __tiny INTE45;
extern unsigned char __tiny INTETC23;
extern unsigned char __tiny INTCLR;
void FDC_HardwareSetup(void)
{
	unsigned char *p;

	INTCLR = 11;
	p = &INTE45;
	*p = (*p & 0xf8) | 4;
	INTCLR = 40;
	p = &INTETC23;
	*p = (*p & 0x8f) | 0x50;
	INTCLR = 12;
	p = &INTE45;
	*p = (*p & 0x8f) | 0x60;
}
