/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_5b.c (2026-11-16-45-p6-r9)
   sha256 02668fddc4a7ae9f0dcae741aab0cb2afb9cebcd20d58654e0aa4bfa1965ed0a (tar-sha256); compiled at -Xr */
extern void PartCtrl_AdvanceReadPos(void);
extern unsigned char SeqPart_ReadByte_Secondary(void);
extern unsigned char __near SEQ_ERROR_CODE;
int SeqStep_SkipThreeEvents(void)
{
	PartCtrl_AdvanceReadPos();
	if (SEQ_ERROR_CODE != 0) return -1;
	PartCtrl_AdvanceReadPos();
	if (SEQ_ERROR_CODE != 0) return -1;
	PartCtrl_AdvanceReadPos();
	if (SEQ_ERROR_CODE != 0) return -1;
	if (SeqPart_ReadByte_Secondary() != 0) return -1;
	return 0;
}
