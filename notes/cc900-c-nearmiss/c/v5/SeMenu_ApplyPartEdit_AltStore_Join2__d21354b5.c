/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/semenu_routines_m0.c (2026-11-19-92-p6-r57)
   sha256 d21354b54e3bb5171c3b07a984a8f81dd0ec305cdeb581ca6fd4d7378cbaaec2 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: SeAPE_J2=SeMenu_ApplyPartEdit_AltStore_Join2 */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_StoreEffectParam(int, int);
extern void SeLfo_GetSelectedLfo(int, unsigned char *);
extern void SeLfo_GetEntryElement(int, int, unsigned char *);
void SeAPE_J2(unsigned char a, unsigned char c)
{
	unsigned char lfo;
	unsigned char el;
	unsigned char buf[12];
	unsigned char *p;

	SeLfo_GetSelectedLfo(c, &lfo);
	SeLfo_GetEntryElement(c, lfo, &el);
	SeMenu_LoadPartParam(4, buf);
	p = buf;
	p[6] = 31;
	p[7] = 0;
	p[8] = 30;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(42, 4, 0, (unsigned char)(el + 3), buf);
	if (c == 0 && lfo == 1)
		SeMenu_StoreEffectParam(2, buf[3]);
	SeMenu_BindDialToColumn(4);
}
