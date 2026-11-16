/* Phase 6, lane_p6 helper D, round 18, module 277 (v10 audio/audio_control_engine.s), form a, after run 123:
   - Block14_Dual, DispatchAndWriteA8 / _Alt: with two pointer locals V4.23 gives the FIRST-ASSIGNED one the
     preferred register (XIX / XHL) whatever the declaration order; the ROM gives it to the second one while still
     computing byte 2's address first.  Here byte 2 is a pointer local and byte 3 a plain e[3] (a common
     subexpression); form b (p6_D_18m277b.c) the other way round.
   - Loop3 / Join18: matched except that the ROM computes byte 2's address after the call into XWA (V4.23: XBC);
     here it is a pointer local assigned after the call (form b: the same local declared register).
   - DispatchPedalFunction: matched at -O3 except that the ROM reads the handler index into E (the table base's
     register), V4.23 into C: here the index is a register local (form b: the handler pointer in a local). */
/* cc900-module: PanelEvent_Post */   /* from scripts/analysis/cc900/module_calls.py v10 */

/* cc900-name: ExtDev_SndParam_DispWriteA8=ExtDev_SndParam_DispatchAndWriteA8 */
/* cc900-name: ExtDev_SndParam_DispWriteA8Alt=ExtDev_SndParam_DispatchAndWriteA8_Alt */

extern void PanelEvent_Post(unsigned char *);
extern int SndParam_LookupReadOnly(long);

extern unsigned char __near ram_90f9;
extern unsigned char __near CURRENT_MODE;
extern unsigned char __near PART_SELECT;
extern unsigned char PanelAction_PedalAssignHandlerIndex[];
extern void (*PanelAction_PedalFunctionHandlers[])(unsigned char *);

void PanelAction_DispatchPedalFunction(unsigned char *e, unsigned char code)
{
	register unsigned char i;

	i = PanelAction_PedalAssignHandlerIndex[code];
	if (i <= 22) PanelAction_PedalFunctionHandlers[i](e);
}

void FileIO_BytecodeData_Code_Loop3(unsigned char *e)
{
	unsigned char m, v, *p;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	if (!(e[2] & e[3])) return;
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 1;
	v = SndParam_LookupReadOnly(768);
	p = e + 2;
	if (v >= 80) *p = 1;
	else *p = v + 1;
	e[3] = 127;
	PanelEvent_Post(e);
}

void FileIO_BytecodeData_Code_Join18(unsigned char *e)
{
	unsigned char m, v, *p;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	if (!(e[2] & e[3])) return;
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 1;
	v = SndParam_LookupReadOnly(768);
	p = e + 2;
	if (v <= 1) *p = 80;
	else *p = v - 1;
	e[3] = 127;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block14_Dual(unsigned char *e)
{
	unsigned char *p;

	p = e + 2;
	if (*p & e[3]) {
		ram_90f9 |= 2;
		e[0] = PART_SELECT;
		e[1] = 4;
		*p = 64;
		e[3] = 64;
		PanelEvent_Post(e);
	}
}

void ExtDev_SndParam_DispWriteA8(unsigned char *e)
{
	unsigned char m, *p;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	ram_90f9 |= 2;
	e[0] = 168;
	e[1] = 4;
	p = e + 2;
	if (*p & e[3]) {
		*p = 2;
		e[3] = 2;
		PanelEvent_Post(e);
	}
}

void ExtDev_SndParam_DispWriteA8Alt(unsigned char *e)
{
	unsigned char m, *p;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	ram_90f9 |= 2;
	e[0] = 168;
	e[1] = 4;
	p = e + 2;
	if (*p & e[3]) {
		*p = 1;
		e[3] = 1;
		PanelEvent_Post(e);
	}
}
