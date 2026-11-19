/* lane_p6 helper N, round 6, form a: module 306 (audio/note_voice_mapping.s), new function.
   PostTmLoad: after a tone-memory load (r >= 0) converts the sounds and the user kit, rewrites the ID and
   checksum, sends sound RAM 0x1e0000 (0x72aa bytes) to the sub CPU at 0x7800 and reports the update; on an error
   sends the error packet.  Then redraws the display (tail jump).  0x1e0000 is a numeric pointer (`ld xwa,imm`).
   cc900-options: -O3 -Xr
*/
/* cc900-module: SoundRam_ConvertSounds SoundRam_ConvertUserKit SoundRam_WriteIdAndChecksum */

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
