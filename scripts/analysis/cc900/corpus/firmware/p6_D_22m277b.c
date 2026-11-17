/* Phase 6, lane_p6 helper D, round 22, module 277 (v10 audio/audio_control_engine.s), form b of p6_D_22m277.c:
   PanelButton_ModeKey in the ROM's block order (gotos), with byte 2's address in a pointer local after the call
   and the table index widened into an unsigned int before the switch (the ROM's extz hl). */
/* cc900-module: PanelButton_ModeKey_FilterTarget PanelEvent_Post */   /* from scripts/analysis/cc900/module_calls.py v10 */

/* cc900-name: PanelButton_ModeKey_FilterTgt=PanelButton_ModeKey_FilterTarget */
/* cc900-name: MKC_LeftSeg3=PanelButton_ModeKeyCodes_LeftSeg3 */
/* cc900-name: MKC_LeftSeg10=PanelButton_ModeKeyCodes_LeftSeg10 */
/* cc900-name: MKC_RightSeg4=PanelButton_ModeKeyCodes_RightSeg4 */
/* cc900-name: MKC_RightSeg5=PanelButton_ModeKeyCodes_RightSeg5 */
/* cc900-name: MKC_RightSeg10=PanelButton_ModeKeyCodes_RightSeg10 */

struct pevt {
	unsigned char b0, b1, b2, b3;
};

extern void PanelEvent_Post(struct pevt *);
extern void PanelButton_ModeKey_FilterTgt(struct pevt *);
extern unsigned char Util_FindLowestSetBit(unsigned long);

extern unsigned char __near ram_8e90;
extern unsigned char PanelButton_ModeKeyCodes[];
extern unsigned char MKC_LeftSeg3[];
extern unsigned char MKC_LeftSeg10[];
extern unsigned char MKC_RightSeg4[];
extern unsigned char MKC_RightSeg5[];
extern unsigned char MKC_RightSeg10[];

void PanelButton_ModeKey(struct pevt *e)
{
	unsigned char *p, *t;
	unsigned int i;

	if (e->b2 != 0) goto lookup;
	e->b2 = 0;
join:
	e->b3 = 255;
	PanelButton_ModeKey_FilterTgt(e);
	if (e->b0 != 255) goto two;
	goto last;
lookup:
	i = Util_FindLowestSetBit(e->b2);
	p = &e->b2;
	*p = i;
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
	*p = t[i];
	goto join;
two:
	PanelEvent_Post(e);
	e++;
last:
	PanelEvent_Post(e);
}
