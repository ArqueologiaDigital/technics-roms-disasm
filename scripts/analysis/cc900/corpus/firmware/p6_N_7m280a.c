/* lane_p6 helper N, round 7, form a: module 280 (audio/audio_control_engine.s), retry of p6_N_6m280a.
   ExtData_ToneParam_CheckMode (p6-r49 Xr: +10): -O3 keeps the case-1 call as `cal; ret` like the ROM but puts
   the case-0 body right after the compare chain, where the ROM jumps over the case-1 body to it.  Form a: an
   explicit `default: return;` written between the two cases.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ExtData_SetTlvField ExtData_Tag43_SetByte1Fields SndParam_WriteLookupAndStore SwbtWr_FlushAndAppendParams */

extern void ExtData_SetTlvField(unsigned int);
extern void SwbtWr_FlushAndAppendParams(void);
extern void SndParam_WriteLookupAndStore(void);
extern void ExtData_Tag43_SetByte1Fields(void);
extern unsigned char __near EXTDATA_TLV_OFFSET;

void ExtData_ToneParam_CheckMode(void)
{
	SndParam_WriteLookupAndStore();
	switch (EXTDATA_TLV_OFFSET) {
	case 1:
		ExtData_Tag43_SetByte1Fields();
		break;
	default:
		return;
	case 0:
		ExtData_SetTlvField(128);
		SwbtWr_FlushAndAppendParams();
		break;
	}
}
