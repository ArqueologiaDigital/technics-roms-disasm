/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_32r1m235a.c (2026-11-22-17-p6-r84)
   sha256 e9525356d8d2005c9e2f16506ea93e8f9a370fa72f3af2f2189de58c5a1fbbb2 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned char __near SEQ_SONG_RECORD[];
extern void Part_WriteWordBlock_OffsetAF(unsigned int);
extern void Part_SetAllVoicePos(unsigned int);
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
void SeqBar_ComputeAndSetPositions(void)
{
	unsigned int h;
	unsigned int i;

	h = SEQ_FREE_LIST_HEAD + (*(unsigned int *)(SEQ_SONG_RECORD + 78) >> 4);
	if (h >= 0x4d8) h = 0xffff;
	Part_WriteWordBlock_OffsetAF(h);
	h = SEQ_FREE_LIST_HEAD;
	if (h == 0xffff) SEQ_FREE_BLOCKS = 0;
	else Part_SetAllVoicePos(0x4d8 - h + 1);
	if (SEQ_FREE_BLOCKS == 0) return;
	for (i = SEQ_FREE_LIST_HEAD; i <= SEQ_FREE_BLOCKS; i++) {
		PartCtrl_SetClearBit7(i, 0);
		PartCtrl_WriteByteToBuf(i, 5, 0x82);
		if (i != 0) PartCtrl_WriteWord_Off1(i, i - 1);
		PartCtrl_WriteWord(i, i + 1);
	}
	PartCtrl_WriteWord_Off1(SEQ_FREE_LIST_HEAD, 0);
	PartCtrl_WriteWord(0x4d8, 0xffff);
}
