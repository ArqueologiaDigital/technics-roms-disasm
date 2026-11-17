/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_1b.c (2026-11-16-31-p6-r1b)
   sha256 f545fd217b726e00a01edbda07882c98420980af6c0fec92898ed4803639eb58 (tar-sha256); compiled at -Xr */
extern unsigned char __near FDC_RESULT[];
extern unsigned char __near ram_8b00;
extern unsigned char FDC_Set_Status(int);
unsigned char FDC_Exception_Status_Decoder(void)
{
	unsigned char c = FDC_RESULT[1];

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
		c = FDC_RESULT[2];
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
