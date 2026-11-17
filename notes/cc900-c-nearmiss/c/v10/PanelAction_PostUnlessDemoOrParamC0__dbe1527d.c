/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_D_20m277.c (2026-11-17-2-p6-r29)
   sha256 dbe1527d24742a811359627590549ff2364cf92df3a6840607a1743db7e1e142 (tar-sha256); compiled at -O3 -XS -Xr */
/* Phase 6, lane_p6 helper D, round 20, module 277, form a (poolnew_D): the panel-event poster and the panel-button
   handlers after it in v10 audio/audio_control_engine.s (PanelEvent_Post's 331-byte label distance covers them),
   plus Encoder_AfterTouch_ApplyThresholdCurve (v10 midi/midi_encoder_routines.s, same module: called with calr).
   - PanelEvent_Post: a 4-byte event is appended to PANEL_EVENT_QUEUE (count in 0x8e8e, 16 deep) by a struct copy
     (V4.23 copies an even struct with ldiw) and its id is then set to 0xff.  Form a post-increments the count
     cell as an unsigned int index; form b (p6_D_20m277b.c) uses a char local.
   - PanelAction_PostUnlessDemo / ..OrParamC0, PanelButton_PanelMemorySet, PanelButton_AcousticIllusion: post the
     two-event frame (the pointer steps by one event, inc 4,xiz) under mode tests; the || chain as in round 17.
   - PanelButton_ModeKey: byte 2 (a one-hot key mask) becomes its bit number (Util_FindLowestSetBit, a uchar
     argument widened to long) mapped through one of six code tables chosen by 0x8e90; cases in the order that
     makes V4.23's last-first compares match the ROM's.
   - Encoder_AfterTouch_ApplyThresholdCurve: (max(v, threshold) - threshold) * 256 / 236 * mult[curve] / 20,
     at most 127; unsigned long arithmetic through the runtime (C9H_divlu / C9H_mullu = Math_DivideU32 /
     Math_Multiply32). */
/* cc900-module: PanelButton_ModeKey_FilterTarget PanelEvent_FillSelectedPart PanelEvent_Post */   /* from scripts/analysis/cc900/module_calls.py v10 */

/* cc900-name: PaPostUnlessDemoOrParamC0=PanelAction_PostUnlessDemoOrParamC0 */
/* cc900-name: PanelButton_ModeKey_FilterTgt=PanelButton_ModeKey_FilterTarget */
/* cc900-name: Encoder_AfterTouch_ApplyThresh=Encoder_AfterTouch_ApplyThresholdCurve */
/* cc900-name: MKC_LeftSeg3=PanelButton_ModeKeyCodes_LeftSeg3 */
/* cc900-name: MKC_LeftSeg10=PanelButton_ModeKeyCodes_LeftSeg10 */
/* cc900-name: MKC_RightSeg4=PanelButton_ModeKeyCodes_RightSeg4 */
/* cc900-name: MKC_RightSeg5=PanelButton_ModeKeyCodes_RightSeg5 */
/* cc900-name: MKC_RightSeg10=PanelButton_ModeKeyCodes_RightSeg10 */

struct pevt {
	unsigned char b0, b1, b2, b3;
};

extern void PanelEvent_FillSelectedPart(struct pevt *);
extern void PanelButton_ModeKey_FilterTgt(struct pevt *);
extern int SndParam_LookupReadOnly(long);
extern unsigned char Util_FindLowestSetBit(unsigned long);

extern struct pevt __near PANEL_EVENT_QUEUE[];
extern unsigned char __near ram_8e8e;
extern unsigned char __near ram_8e90;
extern unsigned char __near CURRENT_MODE;
extern unsigned char __near ENCODER_AFTERTOUCH_THRESHOLD;
extern unsigned char __near ENCODER_AFTERTOUCH_CURVE;
extern unsigned int ENCODER_LUT_AFTERTOUCH_CURVE_MULT[];
extern unsigned char PanelButton_ModeKeyCodes[];
extern unsigned char MKC_LeftSeg3[];
extern unsigned char MKC_LeftSeg10[];
extern unsigned char MKC_RightSeg4[];
extern unsigned char MKC_RightSeg5[];
extern unsigned char MKC_RightSeg10[];

void PanelEvent_Post(struct pevt *e)
{
	if (e->b0 == 0xff) return;
	if (ram_8e8e <= 15) PANEL_EVENT_QUEUE[(unsigned int)ram_8e8e++] = *e;
	e->b0 = 255;
}

void PanelAction_PostUnlessDemo(struct pevt *e)
{
	if (CURRENT_MODE == 19) return;
	PanelEvent_FillSelectedPart(e);
	PanelEvent_Post(e);
	e++;
	PanelEvent_Post(e);
}

void PaPostUnlessDemoOrParamC0(struct pevt *e)
{
	if (CURRENT_MODE == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	PanelEvent_FillSelectedPart(e);
	PanelEvent_Post(e);
	e++;
	PanelEvent_Post(e);
}

void PanelButton_PanelMemorySet(struct pevt *e)
{
	unsigned char m;

	m = CURRENT_MODE;
	if (m == 14 || m == 19 || SndParam_LookupReadOnly(192) == 1) return;
	PanelEvent_FillSelectedPart(e);
	PanelEvent_Post(e);
	e++;
	PanelEvent_Post(e);
}

void PanelButton_AcousticIllusion(struct pevt *e)
{
	PanelEvent_Post(e);
	e++;
	PanelEvent_Post(e);
}

void PanelButton_ModeKey(struct pevt *e)
{
	unsigned char r;
	unsigned char *t;

	if (e->b2 == 0)
		e->b2 = 0;
	else {
		r = Util_FindLowestSetBit(e->b2);
		e->b2 = r;
		switch (ram_8e90) {
		case 1:
			t = PanelButton_ModeKeyCodes;
			break;
		case 3:
			t = MKC_LeftSeg3;
			break;
		case 10:
			t = MKC_LeftSeg10;
			break;
		case 15:
			t = MKC_RightSeg4;
			break;
		case 16:
			t = MKC_RightSeg5;
			break;
		case 21:
			t = MKC_RightSeg10;
			break;
		default:
			return;
		}
		e->b2 = t[r];
	}
	e->b3 = 255;
	PanelButton_ModeKey_FilterTgt(e);
	if (e->b0 == 255) {
		PanelEvent_Post(e);
		return;
	}
	PanelEvent_Post(e);
	e++;
	PanelEvent_Post(e);
}

unsigned long Encoder_AfterTouch_ApplyThresh(unsigned char v)
{
	unsigned char c;
	unsigned long r;

	c = ENCODER_AFTERTOUCH_THRESHOLD;
	if (v < c) v = c;
	r = ((unsigned long)(unsigned char)(v - c) << 8) / 0xec;
	r = r * ENCODER_LUT_AFTERTOUCH_CURVE_MULT[ENCODER_AFTERTOUCH_CURVE] / 20;
	if (r <= 0x7f) return r;
	return 0x7f;
}
