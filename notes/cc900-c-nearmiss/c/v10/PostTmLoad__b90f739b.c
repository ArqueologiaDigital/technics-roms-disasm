/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_6m306a.c (2026-11-19-49-p6-r49)
   sha256 b90f739b7af7a410fdb5759f7d896f7bd53910984d33d785ad77674a2802c7d9 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void SoundRam_ConvertSounds(unsigned int, unsigned int);
extern void SoundRam_ConvertUserKit(unsigned int, unsigned int);
extern void SoundRam_WriteIdAndChecksum(void);
extern void InterCPU_E1_Bulk_Transfer(void *, unsigned int, long);
extern void SubCPU_SendSoundMemUpdated(unsigned int, unsigned int);
extern void COMM_BuildAndSendPacket(unsigned int, unsigned int);
extern void FDemoText_RefreshFullDisplay(void);
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
