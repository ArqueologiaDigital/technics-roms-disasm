/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/seq_step_routines_m236.c (2026-11-16-68-p6-r12)
   sha256 aea8feac7119f4af4b5ff169aa1a5552ef2bfa643ec0896adcb74e772169e7bc (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
