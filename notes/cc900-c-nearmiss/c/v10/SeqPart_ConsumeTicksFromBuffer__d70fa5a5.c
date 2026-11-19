/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_2m234a.c (2026-11-19-15-p6-r42)
   sha256 d70fa5a5ba35bf8c4c456cb439547d1d97a9983a96c9173991583bbf5f861158 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int PartCtrl_ReadWord(unsigned int);
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned long __near ram_25da;
void SeqPart_ConsumeTicksFromBuffer(unsigned int *blk, unsigned int *pos)
{
	unsigned long room;
	unsigned long r;
	unsigned int b;

	room = (unsigned int)(0x100 - *pos);
	if (room > ram_25da) {
		*pos += ram_25da;
		return;
	}
	r = ram_25da - room;
	for (;;) {
		b = PartCtrl_ReadWord(*blk);
		if (b > 0x4d8) {
			SEQ_ERROR_CODE = 10;
			return;
		}
		*blk = b;
		if (PartCtrl_TestBit7(b) == 0) {
			SEQ_ERROR_CODE = 11;
			return;
		}
		if (r <= 0xfb) {
			*pos = r + 5;
			return;
		}
		r -= 0xfb;
	}
}
