/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_V_21r1m285a.c (2026-11-21-7-p6-r62)
   sha256 07bf0b6ade28cbe13826358dbac787cc5830d19c381d222baed695d4ef03677e (tar-sha256); compiled at -O3 -Xr */
extern int SndParam_LookupReadOnly(long);
extern void *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void __cdecl SeqOut_WriteTimedBytes(int n, unsigned char *p);
extern void sendCOMM(int, int, unsigned char *);
extern unsigned char GET_COMPUTER_INTERFACE_SELECTION(void);
extern unsigned char AccPlay_GetCurrentPart(void);
extern void TaskSched_DelayTicks(int);
extern unsigned char Vocalist_SysExTemplate[];
extern unsigned char Vocalist_ProgramChangeTemplate[];
extern unsigned char Vocalist_ControlChangeTemplate[];
extern unsigned char __near ram_b7f2;
void MidiSysEx_SendAllParams(void)
{
	unsigned char *p;
	unsigned char com;
	int h;

	if (SndParam_LookupReadOnly(0x2203) != 0)
		return;
	p = Malloc(14);
	if (p == 0)
		return;
	com = GET_COMPUTER_INTERFACE_SELECTION();

	if (SndParam_LookupReadOnly(0x2d03) != 0) {
		Mem_Copy(p, Vocalist_SysExTemplate, 14);
		p[4] = SndParam_LookupReadOnly(0x2d00);
		p[9] = 0x20;
		p[12] = 3;
		if (com == 0)
			SeqOut_WriteTimedBytes(14, p);
		else
			sendCOMM(4, 14, p);
	}

	if (SndParam_LookupReadOnly(0x2d01) != 0) {
		Mem_Copy(p, Vocalist_SysExTemplate, 14);
		p[4] = ram_b7f2;
		p[9] = 0x11;
		p[12] = SndParam_LookupReadOnly(0x2d00);
		if (com == 0)
			SeqOut_WriteTimedBytes(14, p);
		else
			sendCOMM(4, 14, p);
		p[9] = 0x12;
		if (com == 0)
			SeqOut_WriteTimedBytes(14, p);
		else
			sendCOMM(4, 14, p);
		ram_b7f2 = p[12];
	}

	if (SndParam_LookupReadOnly(0x2d03) != 0) {
		Mem_Copy(p, Vocalist_ProgramChangeTemplate, 2);
		h = SndParam_LookupReadOnly(0x2d00);
		if (h <= 15)
			p[0] |= h;
		p[1] = SndParam_LookupReadOnly(0x2d02);
		if (com == 0)
			SeqOut_WriteTimedBytes(2, p);
		else
			sendCOMM(4, 2, p);
	}

	if (SndParam_LookupReadOnly(0x2d05) != 0) {
		Mem_Copy(p, Vocalist_ControlChangeTemplate, 3);
		h = SndParam_LookupReadOnly(0x2d00);
		if (h <= 15)
			p[0] |= h;
		p[2] = SndParam_LookupReadOnly(0x2d04);
		if (com == 0)
			SeqOut_WriteTimedBytes(3, p);
		else
			sendCOMM(4, 3, p);
	}

	if (SndParam_LookupReadOnly(0x2d07) != 0) {
		Mem_Copy(p, Vocalist_ControlChangeTemplate, 3);
		h = SndParam_LookupReadOnly(0x2d00);
		if (h <= 15)
			p[0] |= h;
		p[2] = SndParam_LookupReadOnly(0x2d06) + 0x3c;
		if (com == 0)
			SeqOut_WriteTimedBytes(3, p);
		else
			sendCOMM(4, 3, p);
	}

	if (AccPlay_GetCurrentPart() == 1)
		TaskSched_DelayTicks(0x32);

	if (SndParam_LookupReadOnly(0x2d09) != 0) {
		Mem_Copy(p, Vocalist_SysExTemplate, 14);
		p[4] = SndParam_LookupReadOnly(0x2d00);
		p[9] = 0x20;
		p[12] = SndParam_LookupReadOnly(0x2d08);
		if (com == 0)
			SeqOut_WriteTimedBytes(14, p);
		else
			sendCOMM(4, 14, p);
	}

	if (SndParam_LookupReadOnly(0x2d0b) != 0) {
		Mem_Copy(p, Vocalist_SysExTemplate, 14);
		p[4] = SndParam_LookupReadOnly(0x2d00);
		p[9] = 0x16;
		p[12] = 0;
		if (com == 0)
			SeqOut_WriteTimedBytes(14, p);
		else
			sendCOMM(4, 14, p);
		p[9] = 0x17;
		p[12] = SndParam_LookupReadOnly(0x2d0a);
		if (com == 0)
			SeqOut_WriteTimedBytes(14, p);
		else
			sendCOMM(4, 14, p);
	}

	if (SndParam_LookupReadOnly(0x2d0f) != 0) {
		Mem_Copy(p, Vocalist_SysExTemplate, 14);
		p[4] = SndParam_LookupReadOnly(0x2d00);
		p[9] = 0x28;
		p[12] = SndParam_LookupReadOnly(0x2d0e);
		if (com == 0)
			SeqOut_WriteTimedBytes(14, p);
		else
			sendCOMM(4, 14, p);
		p[9] = 0x29;
		p[12] = SndParam_LookupReadOnly(0x2d0d);
		if (com == 0)
			SeqOut_WriteTimedBytes(14, p);
		else
			sendCOMM(4, 14, p);
	}

	if (SndParam_LookupReadOnly(0x2d13) != 0) {
		Mem_Copy(p, Vocalist_SysExTemplate, 14);
		p[4] = SndParam_LookupReadOnly(0x2d00);
		p[9] = 0x1b;
		p[12] = SndParam_LookupReadOnly(0x2d12);
		if (com == 0)
			SeqOut_WriteTimedBytes(14, p);
		else
			sendCOMM(4, 14, p);
		p[9] = 0x1c;
		p[12] = SndParam_LookupReadOnly(0x2d11);
		if (com == 0)
			SeqOut_WriteTimedBytes(14, p);
		else
			sendCOMM(4, 14, p);
	}

	Free(p);
}
