/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Audio_WaitForReady Banner_Loop_Check Demo_PreSetup Demo_ReleaseGlidePedal Voice_CopyPreset Voice_LoadVoiceTable */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near DEMO_DEBOUNCE;
extern unsigned char __near SWBTWR_PAYLOAD_1;
extern unsigned char __near SWBTWR_PAYLOAD_2;
extern unsigned char __near SWBTWR_PAYLOAD_3;
extern void SwbtB3_CodeA9_Listener0(void);

void SwbtB3_CodeA9_Listener0(void)
{
	if (SWBTWR_PAYLOAD_1 != 32)
		return;
	if ((SWBTWR_PAYLOAD_3 & 0x13) == 0)
		return;
	if (SWBTWR_PAYLOAD_2 & 0x13)
		DEMO_DEBOUNCE = 16;
	else
		DEMO_DEBOUNCE = 0;
}
