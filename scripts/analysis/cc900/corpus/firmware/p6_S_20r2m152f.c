/* Phase 6, lane_p6 helper S, round 2 of 2026-11-20, hand source audio/sound_editor_ui.s (m152), form f: first
   probes of two DIGITAL EFFECT columns, SeDigEff_OnColumn1 / 2 (no earlier attempt).
   Read from the hand assembly: the effect type (part parameter 0, low nibble, frame +12), the column's block
   (parameter 1 / 2) into buf (+0), range bytes 6 / 7 = 255 / 0, the dial step (SeMenu_SwitchToValueStep(a,
   p + 10)), then &buf[8] / &buf[9] taken BEFORE the compare chain (XWA / XBC) and a switch on the type:
   - Column1: 9 -> 30, 10 / 11 -> 1, 0..8 -> 50 into buf[8], then buf[9] = 0 for all; other types return;
   - Column2: 8 -> 50 / 206, 9 -> 30 / 0, 0..7 / 10 / 11 -> 50 / 0 (that arm re-takes buf from the frame);
   then SeMenu_StepParamFieldAndSend(58, col, 0, field, buf) and SeMenu_BindDialToColumn(col).  The field is the
   low byte of an address-of idiom (Column1: `ld xwa,94`; Column2: `ld xwa,1` + `lda xwa,(xwa+94)`).
   lane_p6's switch idiom: V4.23 compares the case labels in reverse source order and places the arm written first
   right after the compares.  Form f: form d's field; no pointer locals, every arm stores buf[8] / buf[9]
   directly.
*/
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

	SeMenu_LoadPartParam(0, &type);
	type &= 15;
	SeMenu_LoadPartParam(1, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	switch (type) {
	case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8:
		buf[8] = 50;
		break;
	case 11:
	case 10:
		buf[8] = 1;
		break;
	case 9:
		buf[8] = 30;
		break;
	default:
		return;
	}
	buf[9] = 0;
	SeMenu_StepParamFieldAndSend(58, 1, 0, (unsigned char)(unsigned long)((unsigned char *)0 + 94), buf);
	SeMenu_BindDialToColumn(1);
}

void SeDigEff_OnColumn2(unsigned char a)
{
	unsigned char type;
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_LoadPartParam(0, &type);
	type &= 15;
	SeMenu_LoadPartParam(2, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	switch (type) {
	case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7:
	case 11:
	case 10:
		buf[8] = 50;
		buf[9] = 0;
		break;
	case 9:
		buf[8] = 30;
		buf[9] = 0;
		break;
	case 8:
		buf[8] = 50;
		buf[9] = 206;
		break;
	default:
		return;
	}
	SeMenu_StepParamFieldAndSend(58, 2, 0, (unsigned char)(unsigned long)((unsigned char *)1 + 94), buf);
	SeMenu_BindDialToColumn(2);
}
