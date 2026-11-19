/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SoundRam_ConvertSounds SoundRam_ConvertUserKit SoundRam_WriteIdAndChecksum */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SoundRam_ConvertSounds(unsigned int, unsigned int);
extern void SoundRam_ConvertUserKit(unsigned int, unsigned int);
extern void SoundRam_WriteIdAndChecksum(void);
extern void InterCPU_E1_Bulk_Transfer(void *, unsigned int, long);
extern void SubCPU_SendSoundMemUpdated(unsigned int, unsigned int);
extern void COMM_BuildAndSendPacket(unsigned int, unsigned int);
extern void FDemoText_RefreshFullDisplay(void);
extern void PostTmLoad(int r);

void PostTmLoad(int r)
{
	if (r >= 0) {
		SoundRam_ConvertSounds(0xff, 0xff);
		SoundRam_ConvertUserKit(0xff, 0xff);
		SoundRam_WriteIdAndChecksum();
		InterCPU_E1_Bulk_Transfer((void *)0x1e0000L, 0x72aa, 0x7800);
		SubCPU_SendSoundMemUpdated(0xff, 0xff);
	} else
		COMM_BuildAndSendPacket(0xff, 0xff);
	FDemoText_RefreshFullDisplay();
}
