/* Phase 6, lane_p6 helper D, round 19, module 277 (v10 audio/audio_control_engine.s), form b (see p6_D_19m277.c):
   both pointers assigned inside the test (byte 2 first), and DispatchPedalFunction with a plain int code. */
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

void PanelAction_DispatchPedalFunction(unsigned char *e, int code)
{
	unsigned char i;

	i = PanelAction_PedalAssignHandlerIndex[(unsigned char)code];
	if (i <= 22) PanelAction_PedalFunctionHandlers[i](e);
}

void ExtDev_SndParam_Block14_Dual(unsigned char *e)
{
	unsigned char *q, *p;

	if (*(p = e + 2) & *(q = e + 3)) {
		ram_90f9 |= 2;
		e[0] = PART_SELECT;
		e[1] = 4;
		*p = 64;
		*q = 64;
		PanelEvent_Post(e);
	}
}

void ExtDev_SndParam_DispWriteA8(unsigned char *e)
{
	unsigned char m, *q, *p;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	ram_90f9 |= 2;
	e[0] = 168;
	e[1] = 4;
	if (*(p = e + 2) & *(q = e + 3)) {
		*p = 2;
		*q = 2;
		PanelEvent_Post(e);
	}
}

void ExtDev_SndParam_DispWriteA8Alt(unsigned char *e)
{
	unsigned char m, *q, *p;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	ram_90f9 |= 2;
	e[0] = 168;
	e[1] = 4;
	if (*(p = e + 2) & *(q = e + 3)) {
		*p = 1;
		*q = 1;
		PanelEvent_Post(e);
	}
}
