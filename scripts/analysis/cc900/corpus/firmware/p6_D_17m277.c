/* Phase 6, lane_p6 helper D, round 17, module 277 (v10 audio/audio_control_engine.s), form a: the foot-pedal
   handlers after run 118 (p6-r23).  The listings show V4.23 loads the RIGHT operand of `x & y` into the register and
   uses the left one as the memory operand, so every `e[3] & e[2]` of round 16 is `e[2] & e[3]` here (the ROM loads
   byte 3).  Form a keeps the event bytes as plain e[2] / e[3] (common subexpressions at -O3); form b
   (p6_D_17m277b.c) uses pointer locals declared q before p, to flip the XHL / XDE (XIX) choice the listings showed.
   The mode test is the || chain (round 16 form b, whose compare sequence matched).  Code40 declares its flag before
   the loop index (the listing put the first-declared one at the lower slot). */
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
	if (PanelAction_PedalAssignHandlerIndex[code] <= 22)
		PanelAction_PedalFunctionHandlers[PanelAction_PedalAssignHandlerIndex[code]](e);
}

void PanelAction_PedalFn_Code40(unsigned char *e)
{
	unsigned char v, a;
	unsigned int i;

	if (CURRENT_MODE == 17) return;
	if (ram_34cd & 8) return;
	ram_90f9 |= 2;
	a = e[2] & e[3];
	v = 0;
	if (a != 0) v = 8;
	i = 0;
	do {
		if (ram_90fb[i] == 255) break;
		if (SndParam_LookupViaEncode(ram_90fb[i], 0x601) == 1) {
			e[0] = ram_90fb[i];
			e[1] = 4;
			e[2] = v;
			e[3] = 8;
			PanelEvent_Post(e);
		}
	} while (++i < 16);
}

void NakaData_WidgetInit1(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 5;
	if (e[2] & e[3]) e[2] = 1;
	else e[2] = 0;
	e[3] = 1;
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
	if (v >= 80) e[2] = 1;
	else e[2] = v + 1;
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
	if (v <= 1) e[2] = 80;
	else e[2] = v - 1;
	e[3] = 127;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block48_Var40(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 5;
	if (e[2] & e[3]) e[2] = 64;
	else e[2] = 0;
	e[3] = 64;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block48_Var80(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 5;
	if (e[2] & e[3]) e[2] = 128;
	else e[2] = 0;
	e[3] = 128;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block48_Var04(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 5;
	if (e[2] & e[3]) e[2] = 4;
	else e[2] = 0;
	e[3] = 4;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block48_Var04_B(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 6;
	if (e[2] & e[3]) e[2] = 4;
	else e[2] = 0;
	e[3] = 4;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Write98_Block(unsigned char *e)
{
	if (SndParam_LookupViaEncode(PART_SELECT, 1539) != 1) return;
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 2;
	if (e[2] & e[3]) e[2] = 128;
	else e[2] = 0;
	e[3] = 128;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block98_Var40(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 2;
	if (e[2] & e[3]) e[2] = 64;
	else e[2] = 0;
	e[3] = 64;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_BlockA9_Var02(unsigned char *e)
{
	if (CURRENT_TITLE == 135) {
		ram_90f9 |= 2;
		e[0] = 0xa9;
		e[1] = 10;
		if (e[2] & e[3]) e[2] = 2;
		else e[2] = 0;
		e[3] = 2;
		PanelEvent_Post(e);
	}
}

void ExtDev_SndParam_Block98_Var80(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 11;
	if (e[2] & e[3]) e[2] = 128;
	else e[2] = 0;
	e[3] = 128;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block98_Var40_B(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 11;
	if (e[2] & e[3]) e[2] = 64;
	else e[2] = 0;
	e[3] = 64;
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

/* Block14_Dual and the two DispatchAndWriteA8 handlers load both bytes into registers (round 16 form b had the
   ROM's shape with p and q in each other's registers): pointer locals, q declared first. */
void ExtDev_SndParam_Block14_Dual(unsigned char *e)
{
	unsigned char *q, *p;

	p = e + 2;
	q = e + 3;
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
	if (SndParam_LookupReadOnly(192) != 0) return;
	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 4;
	if (e[2] & e[3]) e[2] = 64;
	else e[2] = 0;
	e[3] = 64;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block48_Var02(unsigned char *e)
{
	if (CURRENT_MODE == 16) return;
	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 5;
	if (e[2] & e[3]) e[2] = 2;
	else e[2] = 0;
	e[3] = 2;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block70_Var04(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 112;
	e[1] = 0;
	if (e[2] & e[3]) e[2] = 4;
	else e[2] = 0;
	e[3] = 4;
	PanelEvent_Post(e);
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
	p = e + 2;
	q = e + 3;
	if (*p & *q) {
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
	p = e + 2;
	q = e + 3;
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
