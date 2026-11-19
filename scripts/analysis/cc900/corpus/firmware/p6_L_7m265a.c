/* Phase 6, lane_p6 helper L, round 7, form a: module 265 (demo/fdemotext_routines.s).
   - FDemoText_SendVoiceParams (new): the twin of the matched FDemoText_SendExtVoiceParams
     (cc900/fdemotext_routines_m265.c) with the voice-type check first and the two parameter runs read from the
     LookupTableEntry(0x44) + 1 and LookupTableEntry(0x44 + ch) + 3 entries.  The pointer is advanced as a separate
     statement after the lookup (the ROM adds 1 / 3 to the frame slot).
   - FDemoText_UpdateVoiceDisplay (retry, r49 O3Xr +87): everything matched up to the drawbar / effect compare; the
     ROM compares the effect byte in memory with the drawbar byte in C (`cp (mem),c`), so the operands are
     swapped: drawbar != effect.
   - Seq_LoadDisplayResource (retry): its string labels ..._Str_PRE and ..._Str_PRESENTATION share their first
     31 characters (V4.23 could not resolve the cut name), so both get short C names. */
/* cc900-module: FDemoText_LookupTableEntry FDemoText_NotifyUIChange FDemoText_ProbeVoiceType FDemoText_ReadTaggedBlock */   /* scripts/analysis/cc900/module_calls.py v10 */

/* cc900-name: SldrStrPre=Seq_LoadResource_Proceed_Str_PRE */
/* cc900-name: SldrStrPres=Seq_LoadResource_Proceed_Str_PRESENTATION */
extern void sendCOMM(int, int, unsigned char *);
extern unsigned char *FDemoText_LookupTableEntry(unsigned int);
extern unsigned char FDemoText_ProbeVoiceType(unsigned int);
extern void VoiceEvent_FlushAndReturn(int, int);
extern void AddswbWr(int, int, int, int);
extern unsigned char ram_247ee;
extern unsigned char __near PANEL_DSP_EFFECT[];
extern unsigned char __near PANEL_DRAWBAR_RIGHT1[];
extern void FDemoText_NotifyUIChange(int a, unsigned char v);
extern void FDemoText_SendVoiceParams(unsigned char part);
extern void FDemoText_UpdateVoiceDisplay(unsigned char ch);

void FDemoText_SendVoiceParams(unsigned char part)
{
	unsigned char msg[6];
	unsigned char *p;
	unsigned char k;

	if (FDemoText_ProbeVoiceType(part) != 12)
		return;
	msg[0] = 0xb0;
	msg[1] = part;
	msg[2] = 0x78;
	msg[3] = 0;
	sendCOMM(0, 4, msg);
	msg[0] = 0x88;
	msg[1] = part;
	msg[3] = 0;
	msg[5] = 0;
	p = FDemoText_LookupTableEntry(0x44);
	p += 1;
	for (k = 11; k <= 12; k++) {
		msg[2] = k;
		msg[4] = *p;
		sendCOMM(0, 6, msg);
		p++;
	}
	p = FDemoText_LookupTableEntry((unsigned char)(part + 0x44));
	p += 3;
	for (k = 4; k <= 8; k++) {
		msg[2] = k;
		msg[4] = *p;
		sendCOMM(0, 6, msg);
		p++;
	}
	VoiceEvent_FlushAndReturn(0xff, part);
}

void FDemoText_UpdateVoiceDisplay(unsigned char ch)
{
	unsigned char *e;
	unsigned char *f;

	e = FDemoText_LookupTableEntry(ch);
	e += 5;
	if (*e != 0) {
		*e = 0;
		AddswbWr(ch, 5, 0, 0x7f);
		f = e + 2;
		if (*f == 0) {
			*f = 0x5a;
			AddswbWr(ch, 7, 0x5a, 0x7f);
		}
	}
	if ((ram_247ee & 0x38) == 0 && PANEL_DRAWBAR_RIGHT1[0] != PANEL_DSP_EFFECT[0])
		FDemoText_NotifyUIChange(0x61, PANEL_DRAWBAR_RIGHT1[0]);
}

struct nb16 { char s[16]; };
extern struct nb16 Seq_LoadDisplayResource_NameBufInit;
extern char SldrStrPre[];
extern char Seq_LoadResource_Proceed_Str_rt[];
extern char SldrStrPres[];
extern char Presentation_TagStrTable[];
extern unsigned char GetDiskSizeInfo(void);
extern int GetEncodedFileSizeData(void);
extern char *__cdecl Strcat(char *, char *);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern void FDemoText_ReadTaggedBlock(void *dst, long n, char *tbl, char *tag);
extern int FileIO_CloseHandle(void);
extern int Seq_LoadDisplayResource(char *name);

int Seq_LoadDisplayResource(char *name)
{
	struct nb16 b;
	int r;

	b = Seq_LoadDisplayResource_NameBufInit;
	switch (GetDiskSizeInfo()) {
	case 0:
	case 5:
		return -7;
	case 1:
		return -8;
	default:
		if ((r = GetEncodedFileSizeData()) < 0)
			return r;
	}
	Strcat(b.s, name);
	Strcat(b.s, SldrStrPre);
	if ((r = FileIO_OpenWithMode(b.s, Seq_LoadResource_Proceed_Str_rt)) < 0)
		return r;
	FDemoText_ReadTaggedBlock((void *)0x248c8L, 0x100, Presentation_TagStrTable, SldrStrPres);
	return FileIO_CloseHandle();
}
