/* Phase 6, lane_p6 helper M, round 11, module 129 (audio/semenu_routines.s), form a: the shared column bodies the
   filter / pitch / LFO pages jump to (SeMenu_ApplyPartEdit_AltStore_Join*; their names share 31 characters, so each
   has a cc900-name alias).  Shapes of the matched module-128 handlers:
   Join .. Join4: LFO field: selected LFO and its entry element, block 4 / 4 / 2 / 1, id = element + 3 / 3 / 1 / 0,
     popup 42, part 0; for the first LFO of the panel object the block's byte 3 also goes to effect parameter 2 / 2 /
     1 / 0.  Join5 / Join6: the same without the effect store (block 3, id element + 2).
   Join7: switch part parameter 0 to 0 / 1 (side row 4 / 5 of the filter ENV page) and redraw title field 40.
   Join8 / 9 / 11 / 13: filter ENV columns, only when part parameter 0 is set (popup 55, id = the stub's c).
   Join10 / 12 / 14: the same with two blocks chosen by part parameter 0 (two byte locals; the ROM keeps them in
     QIZ's halves).
   Join15 / 16 / 17: the matched SeAmpEnv2_OnColumn1-3 shape (popup 41, id = c, DrawKeyScaleGraph(2, 1)).
   Join19 / 20: blocks 0 / 1, popup 41, id = c.
   Frames: buf (12) lowest, then the address-taken bytes in reverse declaration order, then the parameters. */
/* cc900-name: SeAPE_J=SeMenu_ApplyPartEdit_AltStore_Join */
/* cc900-name: SeAPE_J2=SeMenu_ApplyPartEdit_AltStore_Join2 */
/* cc900-name: SeAPE_J3=SeMenu_ApplyPartEdit_AltStore_Join3 */
/* cc900-name: SeAPE_J4=SeMenu_ApplyPartEdit_AltStore_Join4 */
/* cc900-name: SeAPE_J5=SeMenu_ApplyPartEdit_AltStore_Join5 */
/* cc900-name: SeAPE_J6=SeMenu_ApplyPartEdit_AltStore_Join6 */
/* cc900-name: SeAPE_J7=SeMenu_ApplyPartEdit_AltStore_Join7 */
/* cc900-name: SeAPE_J8=SeMenu_ApplyPartEdit_AltStore_Join8 */
/* cc900-name: SeAPE_J9=SeMenu_ApplyPartEdit_AltStore_Join9 */
/* cc900-name: SeAPE_J10=SeMenu_ApplyPartEdit_AltStore_Join10 */
/* cc900-name: SeAPE_J11=SeMenu_ApplyPartEdit_AltStore_Join11 */
/* cc900-name: SeAPE_J12=SeMenu_ApplyPartEdit_AltStore_Join12 */
/* cc900-name: SeAPE_J13=SeMenu_ApplyPartEdit_AltStore_Join13 */
/* cc900-name: SeAPE_J14=SeMenu_ApplyPartEdit_AltStore_Join14 */
/* cc900-name: SeAPE_J15=SeMenu_ApplyPartEdit_AltStore_Join15 */
/* cc900-name: SeAPE_J16=SeMenu_ApplyPartEdit_AltStore_Join16 */
/* cc900-name: SeAPE_J17=SeMenu_ApplyPartEdit_AltStore_Join17 */
/* cc900-name: SeAPE_J19=SeMenu_ApplyPartEdit_AltStore_Join19 */
/* cc900-name: SeAPE_J20=SeMenu_ApplyPartEdit_AltStore_Join20 */
/* cc900-module: SeLfo_GetEntryElement SeLfo_GetSelectedLfo SeMenu_BindDialToColumn SeMenu_DrawKeyScaleGraph SeMenu_DrawPitFilEnvGraph SeMenu_LoadPartParam SeMenu_StepParamFieldAndSend SeMenu_StoreEffectParam SeMenu_StorePartParam SeMenu_SwitchToValueStep SeMenu_ValidatePartNumber */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_StoreEffectParam(int, int);
extern void SeMenu_DrawPitFilEnvGraph(void);
extern void SeMenu_DrawKeyScaleGraph(int, int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeLfo_GetSelectedLfo(int, unsigned char *);
extern void SeLfo_GetEntryElement(int, int, unsigned char *);
extern void SeAPE_J(unsigned char a, unsigned char c);
extern void SeAPE_J2(unsigned char a, unsigned char c);
extern void SeAPE_J3(unsigned char a, unsigned char c);
extern void SeAPE_J4(unsigned char a, unsigned char c);
extern void SeAPE_J5(unsigned char a, unsigned char c);
extern void SeAPE_J6(unsigned char a, unsigned char c);
extern void SeAPE_J7(unsigned char a);
extern void SeAPE_J8(unsigned char a, unsigned char c);
extern void SeAPE_J9(unsigned char a, unsigned char c);
extern void SeAPE_J10(unsigned char a, unsigned char c, unsigned char e);
extern void SeAPE_J11(unsigned char a, unsigned char c);
extern void SeAPE_J12(unsigned char a, unsigned char c, unsigned char e);
extern void SeAPE_J13(unsigned char a, unsigned char c);
extern void SeAPE_J14(unsigned char a, unsigned char c, unsigned char e);
extern void SeAPE_J15(unsigned char a, unsigned char c);
extern void SeAPE_J16(unsigned char a, unsigned char c);
extern void SeAPE_J17(unsigned char a, unsigned char c);
extern void SeAPE_J19(unsigned char a, unsigned char c);
extern void SeAPE_J20(unsigned char a, unsigned char c);

/* ---- LFO fields ---- */
void SeAPE_J(unsigned char a, unsigned char c)
{
	unsigned char lfo;
	unsigned char el;
	unsigned char buf[12];
	unsigned char *p;

	SeLfo_GetSelectedLfo(c, &lfo);
	SeLfo_GetEntryElement(c, lfo, &el);
	SeMenu_LoadPartParam(4, buf);
	p = buf;
	p[6] = 3;
	p[7] = 6;
	p[8] = 3;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(42, 4, 0, (unsigned char)(el + 3), buf);
	if (c == 0 && lfo == 1)
		SeMenu_StoreEffectParam(2, buf[3]);
	SeMenu_BindDialToColumn(3);
}

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

void SeAPE_J3(unsigned char a, unsigned char c)
{
	unsigned char lfo;
	unsigned char el;
	unsigned char buf[12];
	unsigned char *p;

	SeLfo_GetSelectedLfo(c, &lfo);
	SeLfo_GetEntryElement(c, lfo, &el);
	SeMenu_LoadPartParam(2, buf);
	p = buf;
	p[6] = 127;
	p[7] = 0;
	p[8] = 127;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(42, 2, 0, (unsigned char)(el + 1), buf);
	if (c == 0 && lfo == 1)
		SeMenu_StoreEffectParam(1, buf[3]);
	SeMenu_BindDialToColumn(5);
}

void SeAPE_J4(unsigned char a, unsigned char c)
{
	unsigned char lfo;
	unsigned char el;
	unsigned char buf[12];
	unsigned char *p;

	SeLfo_GetSelectedLfo(c, &lfo);
	SeLfo_GetEntryElement(c, lfo, &el);
	SeMenu_LoadPartParam(1, buf);
	p = buf;
	p[6] = 127;
	p[7] = 0;
	p[8] = 127;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(42, 1, 0, el, buf);
	if (c == 0 && lfo == 1)
		SeMenu_StoreEffectParam(0, buf[3]);
	SeMenu_BindDialToColumn(6);
}

void SeAPE_J5(unsigned char a, unsigned char c)
{
	unsigned char lfo;
	unsigned char el;
	unsigned char buf[12];
	unsigned char *p;

	SeLfo_GetSelectedLfo(c, &lfo);
	SeLfo_GetEntryElement(c, lfo, &el);
	SeMenu_LoadPartParam(3, buf);
	p = buf;
	p[6] = 63;
	p[7] = 0;
	p[8] = 50;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(42, 3, 0, (unsigned char)(el + 2), buf);
	SeMenu_BindDialToColumn(7);
}

void SeAPE_J6(unsigned char a, unsigned char c)
{
	unsigned char lfo;
	unsigned char el;
	unsigned char buf[12];
	unsigned char *p;

	SeLfo_GetSelectedLfo(c, &lfo);
	SeLfo_GetEntryElement(c, lfo, &el);
	SeMenu_LoadPartParam(3, buf);
	p = buf;
	p[6] = 1;
	p[7] = 7;
	p[8] = 1;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(42, 3, 0, (unsigned char)(el + 2), buf);
	SeMenu_BindDialToColumn(8);
}

/* ---- filter ENV side rows 4 / 5 ---- */
void SeAPE_J7(unsigned char a)
{
	unsigned char v;

	SeMenu_LoadPartParam(0, &v);
	if (a == 0) {
		if (v == 0)
			return;
		SeMenu_StorePartParam(0, 0);
	} else {
		if (v == 1)
			return;
		SeMenu_StorePartParam(0, 1);
	}
	SeTitle_DrawField(40, 0);
}

/* ---- filter ENV columns ---- */
void SeAPE_J8(unsigned char a, unsigned char c)
{
	unsigned char v;
	unsigned char part;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_LoadPartParam(0, &v);
	if (v == 0)
		return;
	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(3, buf);
	p = buf;
	p[6] = 127;
	p[7] = 0;
	p[8] = 100;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(55, 3, part, c, buf);
	SeMenu_DrawPitFilEnvGraph();
	SeMenu_BindDialToColumn(1);
}

void SeAPE_J9(unsigned char a, unsigned char c)
{
	unsigned char v;
	unsigned char part;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_LoadPartParam(0, &v);
	if (v == 0)
		return;
	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(4, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(55, 4, part, c, buf);
	SeMenu_DrawPitFilEnvGraph();
	SeMenu_BindDialToColumn(2);
}

void SeAPE_J11(unsigned char a, unsigned char c)
{
	unsigned char v;
	unsigned char part;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_LoadPartParam(0, &v);
	if (v == 0)
		return;
	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(6, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(55, 6, part, c, buf);
	SeMenu_DrawPitFilEnvGraph();
	SeMenu_BindDialToColumn(4);
}

void SeAPE_J13(unsigned char a, unsigned char c)
{
	unsigned char v;
	unsigned char part;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_LoadPartParam(0, &v);
	if (v == 0)
		return;
	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(8, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(55, 8, part, c, buf);
	SeMenu_DrawPitFilEnvGraph();
	SeMenu_BindDialToColumn(6);
}

/* ---- filter ENV columns with two blocks (QIZ halves) ---- */
void SeAPE_J10(unsigned char a, unsigned char c, unsigned char e)
{
	unsigned char v;
	unsigned char part;
	unsigned char buf[12];
	unsigned char blk;
	unsigned char id;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(0, &v);
	if (v == 0) {
		blk = 2;
		SeMenu_LoadPartParam(2, buf);
		buf[6] = 255;
		buf[7] = 0;
		buf[8] = 50;
		buf[9] = 206;
		id = c;
	} else {
		blk = 5;
		SeMenu_LoadPartParam(5, buf);
		buf[6] = 127;
		buf[7] = 0;
		buf[8] = 100;
		buf[9] = 0;
		id = e;
	}
	SeMenu_SwitchToValueStep(a, &buf[10]);
	SeMenu_StepParamFieldAndSend(55, blk, part, id, buf);
	SeMenu_DrawPitFilEnvGraph();
	SeMenu_BindDialToColumn(3);
}

void SeAPE_J12(unsigned char a, unsigned char c, unsigned char e)
{
	unsigned char v;
	unsigned char part;
	unsigned char buf[12];
	unsigned char blk;
	unsigned char id;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(0, &v);
	if (v == 0) {
		blk = 10;
		SeMenu_LoadPartParam(10, buf);
		buf[6] = 255;
		buf[7] = 0;
		buf[8] = 50;
		buf[9] = 206;
		id = c;
	} else {
		blk = 7;
		SeMenu_LoadPartParam(7, buf);
		buf[6] = 127;
		buf[7] = 0;
		buf[8] = 100;
		buf[9] = 0;
		id = e;
	}
	SeMenu_SwitchToValueStep(a, &buf[10]);
	SeMenu_StepParamFieldAndSend(55, blk, part, id, buf);
	SeMenu_DrawPitFilEnvGraph();
	SeMenu_BindDialToColumn(5);
}

void SeAPE_J14(unsigned char a, unsigned char c, unsigned char e)
{
	unsigned char v;
	unsigned char part;
	unsigned char buf[12];
	unsigned char blk;
	unsigned char id;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(0, &v);
	if (v == 0) {
		blk = 1;
		SeMenu_LoadPartParam(1, buf);
		buf[6] = 255;
		buf[7] = 0;
		buf[8] = 50;
		buf[9] = 206;
		id = c;
	} else {
		blk = 9;
		SeMenu_LoadPartParam(9, buf);
		buf[6] = 127;
		buf[7] = 0;
		buf[8] = 100;
		buf[9] = 0;
		id = e;
	}
	SeMenu_SwitchToValueStep(a, &buf[10]);
	SeMenu_StepParamFieldAndSend(55, blk, part, id, buf);
	SeMenu_DrawPitFilEnvGraph();
	SeMenu_BindDialToColumn(7);
}

/* ---- filter ENV 2 key-scale columns ---- */
void SeAPE_J15(unsigned char a, unsigned char c)
{
	unsigned char part;
	unsigned char t;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(3, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(41, 3, part, c, buf);
	SeMenu_LoadPartParam(3, &t);
	SeMenu_StorePartParam(10, t);
	SeMenu_DrawKeyScaleGraph(2, 1);
	SeMenu_LoadPartParam(9, &t);
	if (t != 0) {
		SeMenu_StorePartParam(9, 0);
		SeTitle_DrawField(41, 9);
	}
	SeMenu_BindDialToColumn(2);
}

void SeAPE_J16(unsigned char a, unsigned char c)
{
	unsigned char part;
	unsigned char t;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(4, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(41, 4, part, c, buf);
	SeMenu_LoadPartParam(4, &t);
	SeMenu_StorePartParam(10, t);
	SeMenu_DrawKeyScaleGraph(2, 1);
	SeMenu_LoadPartParam(9, &t);
	if (t != 1) {
		SeMenu_StorePartParam(9, 1);
		SeTitle_DrawField(41, 9);
	}
	SeMenu_BindDialToColumn(3);
}

void SeAPE_J17(unsigned char a, unsigned char c)
{
	unsigned char part;
	unsigned char t;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(5, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(41, 5, part, c, buf);
	SeMenu_LoadPartParam(5, &t);
	SeMenu_StorePartParam(10, t);
	SeMenu_DrawKeyScaleGraph(2, 1);
	SeMenu_LoadPartParam(9, &t);
	if (t != 2) {
		SeMenu_StorePartParam(9, 2);
		SeTitle_DrawField(41, 9);
	}
	SeMenu_BindDialToColumn(4);
}

void SeAPE_J19(unsigned char a, unsigned char c)
{
	unsigned char part;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(0, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(41, 0, part, c, buf);
	SeMenu_BindDialToColumn(7);
}

void SeAPE_J20(unsigned char a, unsigned char c)
{
	unsigned char part;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(1, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(41, 1, part, c, buf);
	SeMenu_BindDialToColumn(8);
}
