/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_D_20m277b.c (2026-11-17-2-p6-r29)
   sha256 bc366c3f1191897c3cfe0d9d6a42c5399b67554bceb93f4fb12c1e5f1f094a2f (tar-sha256); compiled at -O3 -Xr */
/* Phase 6, lane_p6 helper D, round 20, module 277, form b (see p6_D_20m277.c): PanelEvent_Post with a char count
   local and an unsigned int index; PanelButton_PanelMemorySet with separate tests; PanelButton_ModeKey taking each
   table's address through an integer (the ROM loads it with ld xwa,imm, lane_hd's converted-pointer idiom);
   Encoder_AfterTouch_ApplyThresholdCurve subtracting the threshold in place. */
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
	unsigned char n;
	unsigned int i;

	if (e->b0 == 0xff) return;
	n = ram_8e8e;
	if (n <= 15) {
		i = n++;
		ram_8e8e = n;
		PANEL_EVENT_QUEUE[i] = *e;
	}
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
	if (m == 14 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
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
			t = (unsigned char *)(unsigned long)PanelButton_ModeKeyCodes;
			break;
		case 3:
			t = (unsigned char *)(unsigned long)MKC_LeftSeg3;
			break;
		case 10:
			t = (unsigned char *)(unsigned long)MKC_LeftSeg10;
			break;
		case 15:
			t = (unsigned char *)(unsigned long)MKC_RightSeg4;
			break;
		case 16:
			t = (unsigned char *)(unsigned long)MKC_RightSeg5;
			break;
		case 21:
			t = (unsigned char *)(unsigned long)MKC_RightSeg10;
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
	v -= c;
	r = ((unsigned long)v << 8) / 0xec;
	r = r * ENCODER_LUT_AFTERTOUCH_CURVE_MULT[ENCODER_AFTERTOUCH_CURVE] / 20;
	if (r <= 0x7f) return r;
	return 0x7f;
}
