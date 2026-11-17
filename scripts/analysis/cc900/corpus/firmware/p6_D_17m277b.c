/* Phase 6, lane_p6 helper D, round 17, module 277 (v10 audio/audio_control_engine.s), form b (see p6_D_17m277.c):
   pointer locals for event bytes 2 and 3, declared q before p, with `*p & *q` (the ROM loads byte 3 and ANDs byte 2
   from memory); Block14_Dual and DispatchAndWriteA8 / _Alt declare p first but assign q first; Loop3 / Join18 store
   byte 2 from a conditional expression; DispatchPedalFunction keeps the handler index in an unsigned int. */
/* cc900-module: PanelEvent_Post */   /* from scripts/analysis/cc900/module_calls.py v10 */

/* cc900-name: BitMapOut_PrepRender_CheckBit1=BitMapOut_PrepareRender_CheckBit1 */
/* cc900-name: ExtDev_SndParam_DispWriteA8=ExtDev_SndParam_DispatchAndWriteA8 */
/* cc900-name: ExtDev_SndParam_DispWriteA8Alt=ExtDev_SndParam_DispatchAndWriteA8_Alt */

extern void PanelEvent_Post(unsigned char *);
extern int SndParam_LookupReadOnly(long);
extern int SndParam_LookupViaEncode(unsigned int, unsigned int);
extern unsigned char BitMapOut_PrepRender_CheckBit1(void);

extern unsigned char __near ram_90f9;
extern unsigned char __near ram_34cd;
extern unsigned char __near ram_90fb[];
extern unsigned char __near ram_918d[];
extern unsigned char __near CURRENT_MODE;
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near PART_SELECT;
extern unsigned char PanelAction_PedalAssignHandlerIndex[];
extern void (*PanelAction_PedalFunctionHandlers[])(unsigned char *);

void PanelAction_DispatchPedalFunction(unsigned char *e, unsigned char code)
{
	unsigned int i = PanelAction_PedalAssignHandlerIndex[code];

	if (i <= 22) PanelAction_PedalFunctionHandlers[i](e);
}

void PanelAction_PedalFn_Code40(unsigned char *e)
{
	unsigned char v;
	unsigned int i;

	if (CURRENT_MODE == 17) return;
	if (ram_34cd & 8) return;
	ram_90f9 |= 2;
	v = 0;
	if (e[2] & e[3]) v = 8;
	for (i = 0; i < 16; i++) {
		if (ram_90fb[i] == 255) return;
		if (SndParam_LookupViaEncode(ram_90fb[i], 0x601) == 1) {
			e[0] = ram_90fb[i];
			e[1] = 4;
			e[2] = v;
			e[3] = 8;
			PanelEvent_Post(e);
		}
	}
}

void NakaData_WidgetInit1(unsigned char *e)
{
	unsigned char *q, *p;

	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 5;
	p = e + 2;
	q = e + 3;
	if (*p & *q) *p = 1;
	else *p = 0;
	*q = 1;
	PanelEvent_Post(e);
}

void FileIO_BytecodeData_Code_Loop3(unsigned char *e)
{
	unsigned char m, v;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	if (!(e[2] & e[3])) return;
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 1;
	v = SndParam_LookupReadOnly(768);
	e[2] = v >= 80 ? 1 : v + 1;
	e[3] = 127;
	PanelEvent_Post(e);
}

void FileIO_BytecodeData_Code_Join18(unsigned char *e)
{
	unsigned char m, v;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	if (!(e[2] & e[3])) return;
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 1;
	v = SndParam_LookupReadOnly(768);
	e[2] = v <= 1 ? 80 : v - 1;
	e[3] = 127;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block48_Var40(unsigned char *e)
{
	unsigned char *q, *p;

	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 5;
	p = e + 2;
	q = e + 3;
	if (*p & *q) *p = 64;
	else *p = 0;
	*q = 64;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block48_Var80(unsigned char *e)
{
	unsigned char *q, *p;

	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 5;
	p = e + 2;
	q = e + 3;
	if (*p & *q) *p = 128;
	else *p = 0;
	*q = 128;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block48_Var04(unsigned char *e)
{
	unsigned char *q, *p;

	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 5;
	p = e + 2;
	q = e + 3;
	if (*p & *q) *p = 4;
	else *p = 0;
	*q = 4;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block48_Var04_B(unsigned char *e)
{
	unsigned char *q, *p;

	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 6;
	p = e + 2;
	q = e + 3;
	if (*p & *q) *p = 4;
	else *p = 0;
	*q = 4;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Write98_Block(unsigned char *e)
{
	unsigned char *q, *p;

	if (SndParam_LookupViaEncode(PART_SELECT, 1539) == 1) {
		ram_90f9 |= 2;
		e[0] = 152;
		e[1] = 2;
		p = e + 2;
		q = e + 3;
		if (*p & *q) *p = 128;
		else *p = 0;
		*q = 128;
		PanelEvent_Post(e);
	}
}

void ExtDev_SndParam_Block98_Var40(unsigned char *e)
{
	unsigned char *q, *p;

	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 2;
	p = e + 2;
	q = e + 3;
	if (*p & *q) *p = 64;
	else *p = 0;
	*q = 64;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_BlockA9_Var02(unsigned char *e)
{
	unsigned char *q, *p;

	if (CURRENT_TITLE != 135) return;
	ram_90f9 |= 2;
	e[0] = 0xa9;
	e[1] = 10;
	p = e + 2;
	q = e + 3;
	if (*p & *q) *p = 2;
	else *p = 0;
	*q = 2;
	PanelEvent_Post(e);
	return;
}

void ExtDev_SndParam_Block98_Var80(unsigned char *e)
{
	unsigned char *q, *p;

	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 11;
	p = e + 2;
	q = e + 3;
	if (*p & *q) *p = 128;
	else *p = 0;
	*q = 128;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block98_Var40_B(unsigned char *e)
{
	unsigned char *q, *p;

	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 11;
	p = e + 2;
	q = e + 3;
	if (*p & *q) *p = 64;
	else *p = 0;
	*q = 64;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_ConfigAndWrite(unsigned char *e)
{
	if (!(e[2] & e[3])) return;
	ram_90f9 |= 2;
	e[0] = PART_SELECT;
	e[1] = 5;
	if (SndParam_LookupViaEncode(PART_SELECT, 93) == 0) e[2] = ram_918d[PART_SELECT];
	else e[2] = 0;
	e[3] = 127;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block14_Dual(unsigned char *e)
{
	unsigned char *p, *q;

	q = e + 3;
	p = e + 2;
	if (*p & *q) {
		ram_90f9 |= 2;
		e[0] = PART_SELECT;
		e[1] = 4;
		*p = 64;
		*q = 64;
		PanelEvent_Post(e);
	}
}

void ExtDev_SndParam_Write48_Block(unsigned char *e)
{
	unsigned char *q, *p;

	if (SndParam_LookupReadOnly(192) == 0) {
		ram_90f9 |= 2;
		e[0] = 72;
		e[1] = 4;
		p = e + 2;
		q = e + 3;
		if (*p & *q) *p = 64;
		else *p = 0;
		*q = 64;
		PanelEvent_Post(e);
	}
}

void ExtDev_SndParam_Block48_Var02(unsigned char *e)
{
	unsigned char *q, *p;

	if (CURRENT_MODE == 16) return;
	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 5;
	p = e + 2;
	q = e + 3;
	if (*p & *q) *p = 2;
	else *p = 0;
	*q = 2;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block70_Var04(unsigned char *e)
{
	unsigned char *q, *p;

	ram_90f9 |= 2;
	e[0] = 112;
	e[1] = 0;
	p = e + 2;
	q = e + 3;
	if (*p & *q) *p = 4;
	else *p = 0;
	*q = 4;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_DispWriteA8(unsigned char *e)
{
	unsigned char m, *p, *q;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	ram_90f9 |= 2;
	e[0] = 168;
	e[1] = 4;
	q = e + 3;
	p = e + 2;
	if (*p & *q) {
		*p = 2;
		*q = 2;
		PanelEvent_Post(e);
	}
}

void ExtDev_SndParam_DispWriteA8Alt(unsigned char *e)
{
	unsigned char m, *p, *q;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	ram_90f9 |= 2;
	e[0] = 168;
	e[1] = 4;
	q = e + 3;
	p = e + 2;
	if (*p & *q) {
		*p = 1;
		*q = 1;
		PanelEvent_Post(e);
	}
}

void ExtDev_SndParam_DispatchComplex(unsigned char *e, unsigned char c)
{
	unsigned char m, r;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	if (!(e[2] & e[3])) return;
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 1;
	r = BitMapOut_PrepRender_CheckBit1();
	r <<= 3;
	e[2] = c - 191 + r;
	e[3] = 127;
	PanelEvent_Post(e);
}
