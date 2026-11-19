/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ExtData_SetTlvField ExtData_Tag43_SetByte1Fields ExtData_ToggleTlvBits SndParam_WriteLookupAndStore SwbtWr_FlushAndAppendParams */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void ExtData_SetTlvField(unsigned int);
extern void ExtData_ToggleTlvBits(unsigned int);
extern void SwbtWr_FlushAndAppendParams(void);
extern void ExtData_Drawbar_SetByte7Fields(void);
extern void ExtData_Tag43_SetByte1Fields(void);

void ExtData_Drawbar_SetByte7Fields(void)
{
	ExtData_SetTlvField(15);
	ExtData_ToggleTlvBits(48);
	SwbtWr_FlushAndAppendParams();
}

void ExtData_Tag43_SetByte1Fields(void)
{
	ExtData_SetTlvField(128);
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}
