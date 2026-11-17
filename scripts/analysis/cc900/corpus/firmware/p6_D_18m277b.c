/* Phase 6, lane_p6 helper D, round 18, module 277 (v10 audio/audio_control_engine.s), form b (see p6_D_18m277.c):
   byte 3 as the pointer local and byte 2 plain in Block14_Dual and DispatchAndWriteA8 / _Alt; Loop3 / Join18 with
   the byte-2 pointer declared register; DispatchPedalFunction through a handler-pointer local. */
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
	unsigned char i;
	void (*f)(unsigned char *);

	i = PanelAction_PedalAssignHandlerIndex[code];
	if (i > 22) return;
	f = PanelAction_PedalFunctionHandlers[i];
	f(e);
	return;
}

void FileIO_BytecodeData_Code_Loop3(unsigned char *e)
{
	unsigned char m, v;
	register unsigned char *p;

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
	unsigned char m, v;
	register unsigned char *p;

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
	unsigned char *q;

	q = e + 3;
	if (e[2] & *q) {
		ram_90f9 |= 2;
		e[0] = PART_SELECT;
		e[1] = 4;
		e[2] = 64;
		*q = 64;
		PanelEvent_Post(e);
	}
}

void ExtDev_SndParam_DispWriteA8(unsigned char *e)
{
	unsigned char m, *q;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	ram_90f9 |= 2;
	e[0] = 168;
	e[1] = 4;
	q = e + 3;
	if (e[2] & *q) {
		e[2] = 2;
		*q = 2;
		PanelEvent_Post(e);
	}
}

void ExtDev_SndParam_DispWriteA8Alt(unsigned char *e)
{
	unsigned char m, *q;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	ram_90f9 |= 2;
	e[0] = 168;
	e[1] = 4;
	q = e + 3;
	if (e[2] & *q) {
		e[2] = 1;
		*q = 1;
		PanelEvent_Post(e);
	}
}
