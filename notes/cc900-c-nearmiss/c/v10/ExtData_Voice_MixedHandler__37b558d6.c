/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_17m280.c (2026-11-16-123-p6-r25)
   sha256 37b558d6d8245b91fe5010bbf90678e81e403dec9d2a5b67236026af1f88e111 (tar-sha256); compiled at -O3 -Xr */
extern void SwbtWr_FlushAndAppendParams(void);
extern void ExtData_ToggleTlvBits(unsigned int);
extern void ExtData_StepTlvField(unsigned int, unsigned int);
extern int ExtData_ApplyTransposeEvent(void);
extern void SndParam_WriteLookupAndStore(void);
extern void CtrlPanel_SetIndicatorBit(unsigned int);
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_MASK;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near ram_9153;
extern unsigned char __near ram_9154;
extern unsigned char __near ram_9155;
extern unsigned char __near ram_c5c8;
extern unsigned char __near ram_8f58;
extern unsigned char __near PANEL_PLAY_SETTINGS[];
extern unsigned char SplitPoint_LedMaskByPreset[];
void ExtData_Voice_MixedHandler(void)
{
	SndParam_WriteLookupAndStore();
	switch (EXTDATA_TLV_OFFSET) {
	case 0:
		ExtData_ToggleTlvBits(4);
		SwbtWr_FlushAndAppendParams();
		ram_9153 = 1;
		ram_9154 = 4;
		ram_9155 = 0;
		ExtData_StepTlvField(1, 3);
		SwbtWr_FlushAndAppendParams();
		if (ram_c5c8 != 255) break;
		if ((EXTDATA_VALUE & EXTDATA_MASK) & 1) ram_8f58 = SplitPoint_LedMaskByPreset[PANEL_PLAY_SETTINGS[0] & 3];
		else ram_8f58 = 0;
		CtrlPanel_SetIndicatorBit(69);
		break;
	case 2:
		ExtData_ApplyTransposeEvent();
		break;
	}
}
