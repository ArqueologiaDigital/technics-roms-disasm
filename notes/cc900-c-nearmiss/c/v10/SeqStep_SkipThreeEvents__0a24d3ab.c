/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_5a.c (2026-11-16-45-p6-r9)
   sha256 0a24d3abb3ad01135d3ba1544257bdeae1dc14fc21da9794d409ad64bba47312 (tar-sha256); compiled at -O3 -Xr */
extern void PartCtrl_AdvanceReadPos(void);
extern unsigned char SeqPart_ReadByte_Secondary(void);
extern unsigned char __near SEQ_ERROR_CODE;
int SeqStep_SkipThreeEvents(void)
{
	PartCtrl_AdvanceReadPos();
	if (SEQ_ERROR_CODE != 0) goto err;
	PartCtrl_AdvanceReadPos();
	if (SEQ_ERROR_CODE != 0) goto err;
	PartCtrl_AdvanceReadPos();
	if (SEQ_ERROR_CODE != 0) goto err;
	if (SeqPart_ReadByte_Secondary() == 0) goto ok;
err:
	return -1;
ok:
	return 0;
}
