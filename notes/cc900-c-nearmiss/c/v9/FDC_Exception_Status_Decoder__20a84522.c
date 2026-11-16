/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/fdc_routines_m270_xr.c (2026-11-16-92-p6-r18)
   sha256 20a845227c0f7c205bf2b2f397476c90919543988b8f86cff62b083f0fcca5b5 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __near FDC_RESULT[];
extern unsigned char __near ram_8b00;
extern unsigned char FDC_Set_Status(int);
unsigned char FDC_Exception_Status_Decoder(void)
{
	unsigned char *r = FDC_RESULT;
	unsigned char c = r[1];

	switch (c & 0xc0) {
	case 0:
		return 0;
	case 0xc0:
		ram_8b00 = 255;
		return 0;
	case 0x80:
		return 0;
	case 0x40:
		if (c & 8) return 0x31;
		if (c & 0x10) return 0x32;
		c = r[2];
		if (c & 1) return FDC_Set_Status(0x35);
		if (c & 2) return FDC_Set_Status(0x2f);
		if (c & 4) return FDC_Set_Status(0x33);
		if (c & 0x10) return FDC_Set_Status(0x34);
		if (c & 0x20) return FDC_Set_Status(0x36);
		if (c & 0x80) return FDC_Set_Status(0x37);
		return FDC_Set_Status(8);
	default:
		return 8;
	}
}
