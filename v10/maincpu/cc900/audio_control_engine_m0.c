/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ExtData_SetTlvField ExtData_ToggleTlvBits SwbtWr_FlushAndAppendParams */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void ExtData_SetTlvField(unsigned int);
extern void SwbtWr_FlushAndAppendParams(void);
extern void ExtData_ToneParam_DispHnd_Join5(void);
extern void ExtData_ToggleTlvBits(unsigned int);
extern void ExtData_VoiceCM3_Join2(void);
extern void ExtData_VoiceCM3_Join3(void);
extern void ExtData_VoiceCM3_Join4(void);
extern void ExtData_VoiceCM3_Join5(void);
extern void ExtData_VoiceCM3_Join6(void);
extern void ExtData_VoiceCM3_Join7(void);

/* cc900-name: ExtData_ToneParam_DispHnd_Join5=ExtData_ToneParam_DispatchHandler_Join5 */
void ExtData_ToneParam_DispHnd_Join5(void)
{
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-name: ExtData_VoiceCM3_Join2=ExtData_Voice_CheckMode3_Helper_Join2 */
void ExtData_VoiceCM3_Join2(void)
{
	ExtData_SetTlvField(127);
	ExtData_ToggleTlvBits(128);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-name: ExtData_VoiceCM3_Join3=ExtData_Voice_CheckMode3_Helper_Join3 */
void ExtData_VoiceCM3_Join3(void)
{
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-name: ExtData_VoiceCM3_Join4=ExtData_Voice_CheckMode3_Helper_Join4 */
void ExtData_VoiceCM3_Join4(void)
{
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-name: ExtData_VoiceCM3_Join5=ExtData_Voice_CheckMode3_Helper_Join5 */
void ExtData_VoiceCM3_Join5(void)
{
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-name: ExtData_VoiceCM3_Join6=ExtData_Voice_CheckMode3_Helper_Join6 */
void ExtData_VoiceCM3_Join6(void)
{
	ExtData_SetTlvField(255);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-name: ExtData_VoiceCM3_Join7=ExtData_Voice_CheckMode3_Helper_Join7 */
void ExtData_VoiceCM3_Join7(void)
{
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}
