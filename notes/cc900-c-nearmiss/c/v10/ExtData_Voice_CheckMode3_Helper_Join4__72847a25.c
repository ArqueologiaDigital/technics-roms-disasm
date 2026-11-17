/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/audio_control_engine_m0.c (2026-11-16-92-p6-r18)
   sha256 72847a25a8239e00d122a73cc47b671516e042fe06fcbeb362fd421c0c8ba094 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr
   cc900-name: ExtData_VoiceCM3_Join4=ExtData_Voice_CheckMode3_Helper_Join4 */
extern void ExtData_SetTlvField(unsigned int);
extern void SwbtWr_FlushAndAppendParams(void);
void ExtData_VoiceCM3_Join4(void)
{
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}
