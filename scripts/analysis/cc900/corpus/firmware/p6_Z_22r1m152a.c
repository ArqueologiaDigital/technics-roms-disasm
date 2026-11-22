/* helper Z, round 22r1, hand source audio/sound_editor_ui.s (m152), form a: SeDigEff_OnColumn1 / 2, one-spot retry
   of helper S's p6_S_20r2m152e.c (run r60: both +49 @O3Xr).  At +49 the ROM reads the effect type into E FIRST
   (`ld e, (xsp+12)`) and only then takes the buffer and &buf[8] / &buf[9] (XWA / XBC, the base in the second's
   register); V4.23 took the pointers first and loaded the type after them (into C / L), which also moved the
   pointers.  Here the type is copied to a byte local t before the pointers are taken and the switch is on t.
   Everything else is S's form e text. */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeDigEff_OnColumn1(unsigned char a);
extern void SeDigEff_OnColumn2(unsigned char a);

void SeDigEff_OnColumn1(unsigned char a)
{
	unsigned char type;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char *p8;
	unsigned char *p9;
	unsigned char t;
	long k;

	SeMenu_LoadPartParam(0, &type);
	type &= 15;
	k = 0;
	SeMenu_LoadPartParam(1, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	t = type;
	p = buf;
	p8 = &p[8];
	p9 = &p[9];
	switch (t) {
	case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8:
		*p8 = 50;
		break;
	case 11:
	case 10:
		*p8 = 1;
		break;
	case 9:
		*p8 = 30;
		break;
	default:
		return;
	}
	*p9 = 0;
	SeMenu_StepParamFieldAndSend(58, 1, 0, (unsigned char)(unsigned long)((unsigned char *)k + 94), buf);
	SeMenu_BindDialToColumn(1);
}

void SeDigEff_OnColumn2(unsigned char a)
{
	unsigned char type;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char *p8;
	unsigned char *p9;
	unsigned char t;
	long k;

	SeMenu_LoadPartParam(0, &type);
	type &= 15;
	k = 1;
	SeMenu_LoadPartParam(2, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	t = type;
	p = buf;
	p8 = &p[8];
	p9 = &p[9];
	switch (t) {
	case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7:
	case 11:
	case 10:
		p = buf;
		p[8] = 50;
		p[9] = 0;
		break;
	case 9:
		*p8 = 30;
		*p9 = 0;
		break;
	case 8:
		*p8 = 50;
		*p9 = 206;
		break;
	default:
		return;
	}
	SeMenu_StepParamFieldAndSend(58, 2, 0, (unsigned char)(unsigned long)((unsigned char *)k + 94), buf);
	SeMenu_BindDialToColumn(2);
}
