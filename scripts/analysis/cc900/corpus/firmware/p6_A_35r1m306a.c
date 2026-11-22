/* Probe round 35r1, helper A, form a: audio/note_voice_mapping.s (module 306), xr_screen family.
   PostTmLoadEntry(a, c, r): the one-entry twin of the built PostTmLoad.  On success convert entry (a, c) (sounds
   below bank 0x40, else the user kit), bulk-copy its 470-byte / 80-byte record to the sub-CPU at 0x7800 + offset
   and report it; on failure send the error packet; then refresh the display.  a / c live on the frame. */
/* cc900-module: SoundRam_ConvertSounds SoundRam_ConvertUserKit SoundRam_WriteIdAndChecksum */

extern void SoundRam_ConvertSounds(unsigned int, unsigned int);
extern void SoundRam_ConvertUserKit(unsigned int, unsigned int);
extern void SoundRam_WriteIdAndChecksum(void);
extern void InterCPU_E1_Bulk_Transfer(void *, unsigned int, long);
extern void SubCPU_SendSoundMemUpdated(unsigned int, unsigned int);
extern void COMM_BuildAndSendPacket(unsigned int, unsigned int);
extern void FDemoText_RefreshFullDisplay(void);
extern void PostTmLoadEntry(unsigned char, unsigned char, int);

void PostTmLoadEntry(unsigned char a, unsigned char c, int r)
{
    unsigned long off;

    if (r >= 0) {
        if (a < 0x40) {
            SoundRam_ConvertSounds(a, c);
            SoundRam_WriteIdAndChecksum();
            off = ((unsigned int)a * 20 + c) * 470L + 16;
            InterCPU_E1_Bulk_Transfer((void *)(0x1e0000L + off), 470, off + 0x7800);
        } else {
            SoundRam_ConvertUserKit(a, c);
            SoundRam_WriteIdAndChecksum();
            off = c * 80L + 0x4aa7;
            InterCPU_E1_Bulk_Transfer((void *)(0x1e0000L + off), 80, off + 0x7800);
        }
        SubCPU_SendSoundMemUpdated(a, c);
    } else
        COMM_BuildAndSendPacket(a, c);
    FDemoText_RefreshFullDisplay();
}
