/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_L_6m265c.c (2026-11-19-49-p6-r49)
   sha256 2399a9b2a26279502284c989f66dc0a41697d8deee47d827c31f561560199c7a (tar-sha256); compiled at -O3 -Xr */
/* Phase 6, lane_p6 helper L, round 6, file c of module 265 -- NOT an alternative of 6m265a / b (those are
   file_demo_proc.s): this one is demo/fdemotext_routines.s, new, neighbours of the matched
   FDemoText_ByteData_DisplayRefresh.
   - FDemoText_DeactivateVoice_RetOnly: an empty function (a lone ret).
   - FDemoText_UpdateVoiceDisplay (-Xr: the channel byte stored and reloaded): clear the entry's flag at +5 and send
     AddswbWr 5; if its byte at +7 is 0 set it to 0x5a and send AddswbWr 7; then, unless 0x247ee & 0x38, notify the
     DSP effect change when the drawbar record's first byte differs from the effect record's.
   - FDemoText_NotifyUIChange: write DSP parameter 0x4900, AddswbWr 0x61, then copy parameters 0x4910 + i for
     i < DSPCfg_ReadParam_Map0(0x4904) (count and counter in QIZ / IZ in the ROM: two word locals). */
/* cc900-module: FDemoText_LookupTableEntry FDemoText_NotifyUIChange */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char *FDemoText_LookupTableEntry(unsigned int);
extern void AddswbWr(int, int, int, int);
extern unsigned char ram_247ee;
extern unsigned char __near PANEL_DSP_EFFECT[];
extern unsigned char __near PANEL_DRAWBAR_RIGHT1[];
extern void DSPCfg_WriteParamFull(long id, int v);
extern int DSPCfg_ReadParam_Map0(long id);
extern int DSPCfg_ReadParam_Map1(long id);
extern void FDemoText_NotifyUIChange(int a, unsigned char v);
extern void FDemoText_DeactivateVoice_RetOnly(void);
extern void FDemoText_UpdateVoiceDisplay(unsigned char ch);

void FDemoText_DeactivateVoice_RetOnly(void)
{
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
	if ((ram_247ee & 0x38) == 0 && PANEL_DSP_EFFECT[0] != PANEL_DRAWBAR_RIGHT1[0])
		FDemoText_NotifyUIChange(0x61, PANEL_DRAWBAR_RIGHT1[0]);
}

void FDemoText_NotifyUIChange(int a, unsigned char v)
{
	unsigned int n;
	unsigned int i;

	DSPCfg_WriteParamFull(0x4900, v);
	AddswbWr(0x61, 0, PANEL_DSP_EFFECT[0], 0xff);
	n = DSPCfg_ReadParam_Map0(0x4904);
	for (i = 0; i < n; i++)
		DSPCfg_WriteParamFull(0x4910 + i, DSPCfg_ReadParam_Map1(0x4910 + i));
}
