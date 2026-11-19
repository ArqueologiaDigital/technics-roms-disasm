/* lane_p6 helper N, round 6, form a: module 280 (audio/audio_control_engine.s), new functions of the ExtData
   family (siblings of the built ExtData_Voice_CheckMode3_Helper, cc900/audio_control_engine_m280.c).
   - ExtData_Tag43_SetByte1Fields: record 0x43 byte +1 as two fields (0x80, 0x7f), then post.
   - ExtData_ToneParam_CheckMode: after refreshing the old value, offset 0 is the 0x80 field, offset 1 the two
     fields above (a switch; the ROM compares 1 first, so case 0 is written first; the case-1 call is not a tail
     jump).
   - ExtData_Drawbar_SetByte7Fields: drawbar record byte +7: the low nibble set, bits 4-5 toggled, then post.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ExtData_SetTlvField ExtData_Tag43_SetByte1Fields ExtData_ToggleTlvBits SndParam_WriteLookupAndStore SwbtWr_FlushAndAppendParams */

extern void ExtData_SetTlvField(unsigned int);
extern void ExtData_ToggleTlvBits(unsigned int);
extern void SwbtWr_FlushAndAppendParams(void);
extern void SndParam_WriteLookupAndStore(void);
extern void ExtData_Tag43_SetByte1Fields(void);
extern unsigned char __near EXTDATA_TLV_OFFSET;

void ExtData_ToneParam_CheckMode(void)
{
	SndParam_WriteLookupAndStore();
	switch (EXTDATA_TLV_OFFSET) {
	case 0:
		ExtData_SetTlvField(128);
		SwbtWr_FlushAndAppendParams();
		break;
	case 1:
		ExtData_Tag43_SetByte1Fields();
		break;
	}
}

void ExtData_Tag43_SetByte1Fields(void)
{
	ExtData_SetTlvField(128);
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}

void ExtData_Drawbar_SetByte7Fields(void)
{
	ExtData_SetTlvField(15);
	ExtData_ToggleTlvBits(48);
	SwbtWr_FlushAndAppendParams();
}
