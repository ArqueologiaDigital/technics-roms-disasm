/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PanelButton_ModeKey_FilterTarget PanelEvent_FillSelectedPart PanelEvent_Post */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pevt {
	unsigned char b0, b1, b2, b3;
};
extern void PanelEvent_FillSelectedPart(struct pevt *);
extern unsigned char __near CURRENT_MODE;
extern void PanelEvent_Post(struct pevt *e);
extern void PanelAction_PostUnlessDemo(struct pevt *e);
extern int SndParam_LookupReadOnly(long);
extern void PaPostUnlessDemoOrParamC0(struct pevt *e);
extern void PanelButton_AcousticIllusion(struct pevt *e);
extern void PanelButton_PanelMemorySet(struct pevt *e);

void PanelAction_PostUnlessDemo(struct pevt *e)
{
	if (CURRENT_MODE == 19) return;
	PanelEvent_FillSelectedPart(e);
	PanelEvent_Post(e);
	e++;
	PanelEvent_Post(e);
}

/* cc900-name: PaPostUnlessDemoOrParamC0=PanelAction_PostUnlessDemoOrParamC0 */
void PaPostUnlessDemoOrParamC0(struct pevt *e)
{
	if (CURRENT_MODE == 19) return;
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
