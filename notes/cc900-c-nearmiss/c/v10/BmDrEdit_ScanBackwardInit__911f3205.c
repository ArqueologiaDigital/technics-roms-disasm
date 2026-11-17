/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_18m232.c (2026-11-16-128-p6-r27)
   sha256 911f3205e316b5cc38e0ebeb9a8ebc77908459b5627971b435ccb1efa159e9ef (tar-sha256); compiled at -O3 -Xr */
#define SEQ_BYTE (((unsigned char *)0xb0000)[((unsigned long)(ram_210a4 - 1) << 8) + ram_210a6])
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
