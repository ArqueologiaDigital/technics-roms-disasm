/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/bmdredit_routines_m232.c (2026-11-16-122-p6-r24-staged)
   sha256 caa842da0a49ca6251067b9b9a0d1b370620ba7c554bbe7135868e7b4488a908 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void BmDrEdit_CountMeasuresInit(void);
extern void BmDrEdit_RefreshDisplayState(void);
extern unsigned char __near SEQ_ERROR_CODE;
extern void BmDrEdit_SaveSongPosition(void);
extern void BmDrEdit_ApplyVelocityChange(unsigned int, unsigned char *, unsigned int);
extern unsigned char __near ram_294d;
extern unsigned char __near ram_294e;
extern unsigned char __near ram_294f;
extern unsigned char __near ram_2950;
extern unsigned char __near ram_294b;
extern unsigned char __near ram_294c;
extern unsigned char __near BMDREDIT_CHANNEL;
extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern void BmDrEdit_ClearAndScanToEnd(void);
extern void BmDrEdit_CopyEventDataBetweenParts(unsigned int);
extern void BmDrEdit_SeekForwardToEvent(void);
extern unsigned char __near ram_276a;
void ReadSeqData_StoreParams(void)
{
	SeqData_AdvancePosition();
	SeqData_AdvancePosition();
	ram_294d = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	ram_294e = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	ram_294f = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	ram_2950 = SeqData_ReadNextByte();
	BmDrEdit_ClearAndScanToEnd();
	BmDrEdit_CopyEventDataBetweenParts((unsigned char)(BMDREDIT_CHANNEL + 1));
	BmDrEdit_SeekForwardToEvent();
	if (SEQ_ERROR_CODE != 0) goto err;
	ram_294b = 144;
	ram_294c = ram_276a;
	BmDrEdit_SaveSongPosition();
	BmDrEdit_ApplyVelocityChange((unsigned char)(BMDREDIT_CHANNEL + 1), (unsigned char *)0x294b, 6);
	BmDrEdit_CountMeasuresInit();
	if (SEQ_ERROR_CODE != 0) {
err:
		BmDrEdit_RefreshDisplayState();
	}
}
