/* lane_p6 helper N, round 7, form b: module 280 (audio/audio_control_engine.s), retry of p6_N_6m280a.
   ExtData_ToneParam_CheckMode, form b against a: an if chain testing 1 first (jump to the case-1 body), then
   `!= 0` returns, the case-0 body reached by a goto placed after the case-1 body.
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
	unsigned char o;

	SndParam_WriteLookupAndStore();
	o = EXTDATA_TLV_OFFSET;
	if (o == 1)
		goto one;
	if (o != 0)
		return;
	goto zero;
one:
	ExtData_Tag43_SetByte1Fields();
	return;
zero:
	ExtData_SetTlvField(128);
	SwbtWr_FlushAndAppendParams();
}
