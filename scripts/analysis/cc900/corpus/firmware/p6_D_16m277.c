/* Phase 6, lane_p6 helper D, round 16, module 277 (v10 audio/audio_control_engine.s), form a: the foot-pedal
   function handlers after PanelAction_DispatchPedalFunction (poolmm_D).  Each takes the 4-byte panel event in XWA,
   rewrites it and posts it (PanelEvent_Post, module-local: calr / jrl).  Form a reads the event bytes as e[2] / e[3]
   with `e[3] & e[2]` everywhere and the mode test as a switch (cases written in reverse of the ROM's compare
   order: AudioInit_DrumRoutingCheck's switch shows V4.23 compares cases last-first); form b (p6_D_16m277b.c) uses pointer locals for
   bytes 2 and 3, `*p & *q` in the two handlers whose ROM loads byte 2 first, and an || chain for the mode test.
   0x90f9 bit 1 is the "pedal event pending" flag; 0x90fb is the 0xff-terminated part-tag list. */
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
	unsigned char i;

	i = PanelAction_PedalAssignHandlerIndex[code];
	if (i > 22) return;
	PanelAction_PedalFunctionHandlers[i](e);
}

void PanelAction_PedalFn_Code40(unsigned char *e)
{
	unsigned int i;
	unsigned char v;

	if (CURRENT_MODE == 17) return;
	if (ram_34cd & 8) return;
	ram_90f9 |= 2;
	v = 0;
	if (e[3] & e[2]) v = 8;
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
	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 5;
	if (e[3] & e[2]) e[2] = 1;
	else e[2] = 0;
	e[3] = 1;
	PanelEvent_Post(e);
}

void FileIO_BytecodeData_Code_Loop3(unsigned char *e)
{
	unsigned char v;

	switch (CURRENT_MODE) {
	case 19: case 3: case 17: case 14: case 15: case 16:
		return;
	}
	if (SndParam_LookupReadOnly(192) == 1) return;
	if (!(e[3] & e[2])) return;
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
	unsigned char v;

	switch (CURRENT_MODE) {
	case 19: case 3: case 17: case 14: case 15: case 16:
		return;
	}
	if (SndParam_LookupReadOnly(192) == 1) return;
	if (!(e[3] & e[2])) return;
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
	if (e[3] & e[2]) e[2] = 64;
	else e[2] = 0;
	e[3] = 64;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block48_Var80(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 5;
	if (e[3] & e[2]) e[2] = 128;
	else e[2] = 0;
	e[3] = 128;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block48_Var04(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 5;
	if (e[3] & e[2]) e[2] = 4;
	else e[2] = 0;
	e[3] = 4;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block48_Var04_B(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 6;
	if (e[3] & e[2]) e[2] = 4;
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
	if (e[3] & e[2]) e[2] = 128;
	else e[2] = 0;
	e[3] = 128;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block98_Var40(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 2;
	if (e[3] & e[2]) e[2] = 64;
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
		if (e[3] & e[2]) e[2] = 2;
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
	if (e[3] & e[2]) e[2] = 128;
	else e[2] = 0;
	e[3] = 128;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block98_Var40_B(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 11;
	if (e[3] & e[2]) e[2] = 64;
	else e[2] = 0;
	e[3] = 64;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_ConfigAndWrite(unsigned char *e)
{
	if (!(e[3] & e[2])) return;
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
	if (e[3] & e[2]) {
		ram_90f9 |= 2;
		e[0] = PART_SELECT;
		e[1] = 4;
		e[2] = 64;
		e[3] = 64;
		PanelEvent_Post(e);
	}
}

void ExtDev_SndParam_Write48_Block(unsigned char *e)
{
	if (SndParam_LookupReadOnly(192) != 0) return;
	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 4;
	if (e[3] & e[2]) e[2] = 64;
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
	if (e[3] & e[2]) e[2] = 2;
	else e[2] = 0;
	e[3] = 2;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_Block70_Var04(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 112;
	e[1] = 0;
	if (e[3] & e[2]) e[2] = 4;
	else e[2] = 0;
	e[3] = 4;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_DispWriteA8(unsigned char *e)
{
	switch (CURRENT_MODE) {
	case 19: case 3: case 17: case 14: case 15: case 16:
		return;
	}
	if (SndParam_LookupReadOnly(192) == 1) return;
	ram_90f9 |= 2;
	e[0] = 168;
	e[1] = 4;
	if (!(e[3] & e[2])) return;
	e[2] = 2;
	e[3] = 2;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_DispWriteA8Alt(unsigned char *e)
{
	switch (CURRENT_MODE) {
	case 19: case 3: case 17: case 14: case 15: case 16:
		return;
	}
	if (SndParam_LookupReadOnly(192) == 1) return;
	ram_90f9 |= 2;
	e[0] = 168;
	e[1] = 4;
	if (!(e[3] & e[2])) return;
	e[2] = 1;
	e[3] = 1;
	PanelEvent_Post(e);
}

void ExtDev_SndParam_DispatchComplex(unsigned char *e, unsigned char c)
{
	switch (CURRENT_MODE) {
	case 19: case 3: case 17: case 14: case 15: case 16:
		return;
	}
	if (SndParam_LookupReadOnly(192) == 1) return;
	if (!(e[3] & e[2])) return;
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 1;
	e[2] = c - 191 + (BitMapOut_PrepRender_CheckBit1() << 3);
	e[3] = 127;
	PanelEvent_Post(e);
}
