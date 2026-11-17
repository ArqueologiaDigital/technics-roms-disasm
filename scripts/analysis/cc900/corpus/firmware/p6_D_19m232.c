/* Phase 6, lane_p6 helper D, round 19, module 232 (v10 sequencer/bmdredit_routines.s), form a, after run 128.
   - BmDrEdit_ScanBackwardInit: the song byte's offset already matched; the ROM loads the base 0xb0000 into a
     register and adds the offset (V4.23 added the constant to the offset): the address is an integer sum converted
     to a pointer, base first (form b, p6_D_19m232b.c: a base pointer local indexed by the offset).
   - BmDrEdit_SetupAndWalkToNote: the char in QIZH translates.  V4.23 summed the two masked chars in 8 bits; the ROM
     widens both and adds in 16: explicit unsigned int casts (form b: the sum built in an unsigned int local). */
/* cc900-module: BmDrEdit_AdjustScrollToView BmDrEdit_AdvanceStreamPos BmDrEdit_ClearAndScanToEnd BmDrEdit_CompareVelocity BmDrEdit_SetupCoordinates */   /* from scripts/analysis/cc900/module_calls.py v10 */

#define SEQ_BYTE (*(unsigned char *)(0xb0000L + (((unsigned long)(ram_210a4 - 1) << 8) + ram_210a6)))

extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern void BmDrEdit_AdvanceStreamPos(void);
extern void BmDrEdit_RenderNoteBlock(void);
extern unsigned char BmDrEdit_CompareVelocity(void);
extern void BmDrEdit_SetupCoordinates(unsigned int *, unsigned int *);
extern void BmDrEdit_ClearAndScanToEnd(void);
extern void BmDrEdit_AdjustScrollToView(void);

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

extern unsigned char __near ram_295f;
extern unsigned int __near ram_279a;
extern unsigned char __near ram_2786;
extern unsigned char __near ram_2788;
extern unsigned int __near ram_278c;
extern unsigned char __near ram_2962;

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

void BmDrEdit_SetupAndWalkToNote(void)
{
	unsigned int a, b;
	unsigned char v, w;

	ram_295f &= ~1;
	BmDrEdit_SetupCoordinates(&a, &b);
	a -= b;
	if (a != ram_279a) return;
	if ((SeqData_ReadNextByte() & 0xf0) != 0x90) return;
	if (BmDrEdit_CompareVelocity() != 0) return;
	ram_295f |= 1;
	SeqData_AdvancePosition();
	SeqData_AdvancePosition();
	ram_2786 = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	ram_2788 = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	v = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	w = SeqData_ReadNextByte();
	w &= 0x7f;
	v &= 0x7f;
	ram_278c = (unsigned int)w * 0x60 + (unsigned int)v;
	BmDrEdit_ClearAndScanToEnd();
	ram_2962 = ram_2786;
	BmDrEdit_AdjustScrollToView();
}
