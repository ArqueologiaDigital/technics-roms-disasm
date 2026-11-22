/* lane_p6 helper U, round 32r1: roots of sequencer/sequencer_engine.s, module 235 (-O3 -Xr). */

extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned char __near SEQ_SONG_RECORD[];
extern void Part_WriteWordBlock_OffsetAF(unsigned int);
extern void Part_SetAllVoicePos(unsigned int);
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern unsigned char *__near SEQ_BLOCK_POOL;
extern unsigned char *__near ram_29ee;
extern unsigned int __near ram_29f2;
extern unsigned int __near ram_29f4;
extern unsigned int __near ram_29f6;
extern void FileIO_WriteByte_Impl(void *, long);

void FileIO_WriteBlockToStream(unsigned int a, unsigned int c)
{
	unsigned char *s;
	unsigned char *r;
	unsigned char *d;
	unsigned int i;
	unsigned int w;

	s = SEQ_BLOCK_POOL + (((unsigned long)a - 1) << 8);
	r = ram_29ee + ((unsigned long)ram_29f6 << 8);
	d = r;
	for (i = 0; i < 0x100; i++) d[i] = s[i];
	w = ram_29f2 + ram_29f4;
	*(unsigned int *)(r + 1) = w - 1;
	*(unsigned int *)(r + 3) = w + 1;
	if (ram_29f4 == 0) *(unsigned int *)(d + 1) = 0;
	if (c == 0xffff) *(unsigned int *)(r + 3) = 0xffff;
	if (++ram_29f6 >= 0x20) {
		FileIO_WriteByte_Impl(ram_29ee, 0x2000);
		ram_29f6 = 0;
	}
}

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
