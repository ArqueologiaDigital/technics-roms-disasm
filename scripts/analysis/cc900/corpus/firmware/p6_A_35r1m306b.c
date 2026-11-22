/* Probe round 35r1, helper A, form b: audio/note_voice_mapping.s (module 306), xr_screen family.
   PostTmLoadEntry as form a, with the record offset an unsigned long product of unsigned operands
   ((unsigned long)(a * 20U + c) * 470U, (unsigned long)c * 80U). */
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
            off = (unsigned long)(a * 20U + c) * 470U + 16;
            InterCPU_E1_Bulk_Transfer((void *)(0x1e0000L + off), 470, off + 0x7800);
        } else {
            SoundRam_ConvertUserKit(a, c);
            SoundRam_WriteIdAndChecksum();
            off = (unsigned long)c * 80U + 0x4aa7;
            InterCPU_E1_Bulk_Transfer((void *)(0x1e0000L + off), 80, off + 0x7800);
        }
        SubCPU_SendSoundMemUpdated(a, c);
    } else
        COMM_BuildAndSendPacket(a, c);
    FDemoText_RefreshFullDisplay();
}
