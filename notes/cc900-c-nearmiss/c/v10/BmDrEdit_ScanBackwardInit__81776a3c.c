/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_19m232b.c (2026-11-17-2-p6-r29)
   sha256 81776a3caae673c3b033d9b33ae0bf2c0f46b63b75a374140ad9aa502fc342a5 (tar-sha256); compiled at -O3 -Xr */
#define SEQ_BYTE (s[((unsigned long)(ram_210a4 - 1) << 8) + ram_210a6])
extern void BmDrEdit_AdvanceStreamPos(void);
extern void BmDrEdit_RenderNoteBlock(void);
extern unsigned int __near ram_27f6;
extern unsigned int __near ram_27f8;
extern unsigned int __near ram_27fa;
extern unsigned int __near ram_27fc;
extern unsigned int __near ram_27fe;
extern unsigned int __near ram_2800;
extern unsigned int __near ram_2802;
extern unsigned int __near ram_2804;
extern unsigned char __near ram_2806;
extern unsigned char __near ram_2822;
extern unsigned char __near ram_2824;
extern unsigned int __near ram_2766;
extern unsigned int __near ram_2768;
extern unsigned char __near ram_2774;
extern unsigned int ram_210a0;
extern unsigned int ram_210a2;
extern unsigned int ram_210a4;
extern unsigned int ram_210a6;
extern unsigned char ram_210a8;
extern unsigned char ram_210aa;
void BmDrEdit_ScanBackwardInit(void)
{
	unsigned int i;
	unsigned char c;
	unsigned char *s;

	s = (unsigned char *)0xb0000L;
	ram_27f6 = ram_27fe;
	ram_27f8 = ram_2800;
	ram_27fa = ram_2802;
	ram_27fc = ram_2804;
	ram_210a0 = ram_27fe;
	ram_210a2 = ram_2800;
	ram_210a4 = ram_2802;
	ram_210a6 = ram_2804;
	ram_210a8 = ram_2822;
	ram_210aa = ram_2824;
	i = 0;
	while (i < ram_2774) {
		c = SEQ_BYTE;
		if (c == 0x82 || c == 0x84) break;
		if (c == 0x81) {
			i++;
			ram_27fe++;
		} else if ((c & 0xf0) == 0x90) {
			if (ram_2802 != ram_2766 || ram_2804 != ram_2768) {
				BmDrEdit_AdvanceStreamPos();
				ram_2800 = SEQ_BYTE;
				BmDrEdit_AdvanceStreamPos();
				c = SEQ_BYTE;
				ram_2806 = c;
				if (c >= ram_210a8 && c <= ram_210aa) BmDrEdit_RenderNoteBlock();
			}
		}
		do
			BmDrEdit_AdvanceStreamPos();
		while (!(SEQ_BYTE & 0x80));
	}
}
