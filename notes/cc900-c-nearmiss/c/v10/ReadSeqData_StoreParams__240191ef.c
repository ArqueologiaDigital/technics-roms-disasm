/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_15m232.c (2026-11-16-107-p6-r21)
   sha256 240191ef3be2e449886b358a2a734bde597b96c0f0a089bbc370d36c3c959ef3 (tar-sha256); compiled at -O3 -Xr */
extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern void BmDrEdit_ClearAndScanToEnd(void);
extern void BmDrEdit_CopyEventDataBetweenParts(unsigned int);
extern void BmDrEdit_SeekForwardToEvent(void);
extern void BmDrEdit_SaveSongPosition(void);
extern void BmDrEdit_ApplyVelocityChange(unsigned int, unsigned char *, unsigned int);
extern void BmDrEdit_CountMeasuresInit(void);
extern void BmDrEdit_RefreshDisplayState(void);
extern unsigned char __near ram_2969;
extern unsigned char __near ram_296a;
extern unsigned char __near ram_296b;
extern unsigned char __near ram_296c;
extern unsigned char __near ram_2967;
extern unsigned char __near ram_2968;
extern unsigned char __near ram_2784;
extern unsigned char __near BMDREDIT_CHANNEL;
extern unsigned char __near SEQ_ERROR_CODE;
void ReadSeqData_StoreParams(void)
{
	SeqData_AdvancePosition();
	SeqData_AdvancePosition();
	ram_2969 = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	ram_296a = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	ram_296b = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	ram_296c = SeqData_ReadNextByte();
	BmDrEdit_ClearAndScanToEnd();
	BmDrEdit_CopyEventDataBetweenParts((unsigned char)(BMDREDIT_CHANNEL + 1));
	BmDrEdit_SeekForwardToEvent();
	if (SEQ_ERROR_CODE == 0) {
		ram_2967 = 144;
		ram_2968 = ram_2784;
		BmDrEdit_SaveSongPosition();
		BmDrEdit_ApplyVelocityChange((unsigned char)(BMDREDIT_CHANNEL + 1), (unsigned char *)0x2967, 6);
		BmDrEdit_CountMeasuresInit();
		if (SEQ_ERROR_CODE == 0) return;
	}
	if (SEQ_ERROR_CODE != 0) BmDrEdit_RefreshDisplayState();
}
