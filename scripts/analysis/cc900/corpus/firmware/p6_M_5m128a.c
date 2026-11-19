/* Phase 6, lane_p6 helper M, round 5, module 128 (display/scoop_editor_data.s), form a: SeMenu_EditFilterCutoff.
   Load the part's parameter block 2, set its range fields (255, 0, 127, 0), switch the dial to value steps, then
   step and send the field: id 77 for the panel object, else an id computed as the offset of byte 17 of the part's
   21-byte record after a 16-byte header (the ROM: muls 21, extz, lda +16, lda +17 -- no constant folding, so an
   address computed from a null-based struct), with the part reset to 0.  The family: about 20 SeAmp* / SeFil*
   column handlers in this file use the same id computation (most also keep a flag in QIZ).
   Frame: buf +0 (12), obj +12, part +14, parameters +16 / +18 / +20. */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

struct seprm { unsigned char hdr[16]; unsigned char rec[8][21]; };
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern void SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(unsigned char col);
extern void SeMenu_EditFilterCutoff(unsigned char a, unsigned char c, unsigned char e);

void SeMenu_EditFilterCutoff(unsigned char a, unsigned char c, unsigned char e)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char v;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	SeMenu_LoadPartParam(2, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 127;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (obj == 0)
		v = 77;
	else {
		v = (unsigned char)(unsigned long)&((struct seprm *)0)->rec[(unsigned char)(part - 1)][17];
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(e, 2, part, v, buf);
	SeMenu_BindDialToColumn(c);
}

/* SeMenu_EditFilterResonance: the twin for parameter block 3 (range 127, 0, 5, 0; id 78 or byte 18). */
extern void SeMenu_EditFilterResonance(unsigned char a, unsigned char c, unsigned char e);

void SeMenu_EditFilterResonance(unsigned char a, unsigned char c, unsigned char e)
{
	unsigned char part;
	unsigned char obj;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char v;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	SeMenu_LoadPartParam(3, buf);
	p = buf;
	p[6] = 127;
	p[7] = 0;
	p[8] = 5;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (obj == 0)
		v = 78;
	else {
		v = (unsigned char)(unsigned long)&((struct seprm *)0)->rec[(unsigned char)(part - 1)][18];
		part = 0;
	}
	SeMenu_StepParamFieldAndSend(e, 3, part, v, buf);
	SeMenu_BindDialToColumn(c);
}
