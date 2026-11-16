/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_CalcSongPosition */   /* staged module names, repair_module_lines.py */

extern unsigned char SeqData_ReadNextByte(void);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern void SeqData_SetErrorCode(unsigned int);
extern unsigned int PartCtrl_ReadWord(unsigned int);
extern unsigned int __near ram_2758;
extern void SeqData_SkipToNextEvent(void);

void BmDrEdit_ClearAndScanToEnd(void)
{
	unsigned int o, b;

	SEQ_ERROR_CODE = 0;
	do {
		o = SEQ_DATA_OFFSET;
		if (o > 5) {
			SEQ_DATA_OFFSET = o - 1;
		} else {
			b = PartCtrl_ReadWord_Off1(SEQ_DATA_BLOCK);
			if (b == 0) {
				SEQ_ERROR_CODE = 255;
				return;
			}
			SEQ_DATA_BLOCK = b;
			SEQ_DATA_OFFSET = 255;
		}
	} while (!(SeqData_ReadNextByte() & 0x80));
}

/* cc900-name: BmDrEdit_DecrValidateCounter=BmDrEdit_DecrementAndValidateCounter (36 characters) */
int BmDrEdit_DecrValidateCounter(unsigned int *blk, unsigned int *off)
{
	(*off)--;
	if (*off >= 5) return 0;
	*blk = PartCtrl_ReadWord_Off1(*blk);
	if (*blk > 0x4d8) {
		SeqData_SetErrorCode(0xa0);
		return -1;
	}
	*off = 0xff;
	return 0;
}

/* cc900-name: PartCtrl_ReadWordWithBoundsChk=PartCtrl_ReadWordWithBoundsCheck (32 characters) */
int PartCtrl_ReadWordWithBoundsChk(unsigned int *blk, unsigned int *off)
{
	(*off)++;
	if (*off <= 0xff) return 0;
	*blk = PartCtrl_ReadWord(*blk);
	if (*blk > 0x4d8) {
		SeqData_SetErrorCode(0xa1);
		return -1;
	}
	*off = 5;
	return 0;
}

void BmDrEdit_CountMeasuresAndValidate(void)
{
	unsigned char c;

	if (SEQ_ERROR_CODE != 0) SeqData_SetErrorCode(0xd1);
	ram_2758 = 0;
	for (;;) {
		c = SeqData_ReadNextByte();
		if (c == 0x82 || c == 0x84) break;
		if (c == 0x81) ram_2758++;
		SeqData_SkipToNextEvent();
	}
	if (SEQ_ERROR_CODE != 0) SeqData_SetErrorCode(0xce);
}

extern unsigned char __near ram_25be;
extern unsigned char __near ram_276a;
extern unsigned char __near ram_278a[];
extern unsigned int __near ram_2780;
extern unsigned int __near ram_2768;
extern void BmDrEdit_CalcSongPosition(void);
void BmDrEdit_CalcBeatMeasure(void);
extern void BmDrEdit_CalcSongPosition(void);

void BmDrEdit_CalcSongPosition(void);

void BmDrEdit_CalcBeatMeasure(void)
{
	unsigned int n, i;
	unsigned char *t;

	n = ram_2780 / 96;
	ram_25be = 0;
	ram_2758 = n;
	if (n != 0) {
		i = 1;
		ram_25be = 1;
		t = ram_278a;
		for (;;) {
			if (t[i] != 0) ram_25be = 0;
			i++;
			if ((ram_2758 = ram_2758 - 1) == 0) break;
			ram_25be++;
		}
	}
	ram_2768 = ram_25be;
	ram_276a = ram_2780 % 96;
	BmDrEdit_CalcSongPosition();
}

/* cc900-module: BmDrEdit_ApplyVelocityChange BmDrEdit_CheckAndSelectChannel BmDrEdit_ClearAndScanToEnd BmDrEdit_CopyEventDataBetweenParts BmDrEdit_CountMeasuresInit BmDrEdit_InitCommon BmDrEdit_RefreshDisplayState BmDrEdit_SaveSongPosition BmDrEdit_SeekForwardToEvent BmDrEdit_SyncChannelAndGetPos BmDrEdit_ValidateAndProcessVoice NoteEditSy_ScanAndSortEntries */
extern unsigned char __near ram_2728;
extern void BmDrEdit_InitCommon(void);
extern unsigned int __near ram_2778;
extern unsigned int __near ram_277a;
extern unsigned int __near ram_2774;
extern unsigned int __near ram_2776;
extern unsigned char __near ram_275a;
extern unsigned char __near ram_2788;
extern void BmDrEdit_InitMelodicMode(void);
extern unsigned int __near ram_2744;
extern unsigned int __near ram_2750;
extern unsigned char __near ram_2746;
extern unsigned char __near ram_2752;
extern unsigned int __near ram_2754;
extern unsigned char __near ram_2756;
extern void BmDrEdit_LoadAlternateState(void);
extern unsigned int __near ram_27ee;
extern unsigned int __near ram_27f0;
extern unsigned int __near ram_27a0;
extern unsigned int __near ram_27a2;
extern unsigned char __near ram_27ec;
extern unsigned int __near ram_27a4;
extern unsigned int __near ram_27a6;
extern unsigned int BmDrEdit_RenderVertical_Table[], BmDrEdit_RenderHorizontal_Table[];
extern void BmDrEdit_RenderHorizontal(void);
extern void BmDrEdit_RenderVertical(void);
extern unsigned int BmDrEdit_SyncChannelAndGetPos(void);
extern void BmDrEdit_SelectChannelAndLoadPos(void);
extern unsigned char BmDrEdit_CheckAndSelectChannel(void);
extern void BmDrEdit_ValidateAndProcessVoice(unsigned int, unsigned int, unsigned int *);
extern unsigned int __near ram_2863;
extern unsigned int __near ram_272a;
extern unsigned char __near BMDREDIT_CHANNEL;

void BmDrEdit_InitMelodicMode(void)
{
	ram_2778 = ram_277a;
	ram_2774 = ram_2776;
	ram_2728 &= ~1;
	ram_275a = 10;
	ram_2788 = 11;
	BmDrEdit_InitCommon();
}
void BmDrEdit_LoadAlternateState(void)
{
	ram_2744 = ram_2750;
	ram_2746 = ram_2752;
	SEQ_DATA_BLOCK = ram_2754;
	SEQ_DATA_OFFSET = ram_2756;
}
void BmDrEdit_RenderHorizontal(void)
{
	ram_27a0 = (ram_27ee >> 2) + 0x16;
	ram_27a2 = (ram_27f0 >> 2) + ram_27a0;
	ram_27a4 = BmDrEdit_RenderHorizontal_Table[ram_27ec];
	ram_27a6 = ram_27a4 + 3;
}
void BmDrEdit_RenderVertical(void)
{
	ram_27a0 = (ram_27ee >> 2) + 0x5b;
	ram_27a2 = (ram_27f0 >> 2) + ram_27a0;
	ram_27a4 = BmDrEdit_RenderVertical_Table[ram_27ec];
	ram_27a6 = ram_27a4 + 3;
}
void BmDrEdit_SelectChannelAndLoadPos(void)
{
	unsigned int h;

	SEQ_ERROR_CODE = 0;
	h = BmDrEdit_SyncChannelAndGetPos();
	if (SEQ_ERROR_CODE != 0) return;
	ram_2750 = h;
	ram_2752 = 0;
	ram_2754 = SEQ_DATA_BLOCK;
	ram_2756 = SEQ_DATA_OFFSET;
}
unsigned int BmDrEdit_SyncChannelAndGetPos(void)
{
	unsigned int r;
	unsigned char h;

	ram_2863 = ram_272a;
	h = BmDrEdit_CheckAndSelectChannel();
	BmDrEdit_ValidateAndProcessVoice((unsigned char)(BMDREDIT_CHANNEL + 1), h, &r);
	return r;
}
