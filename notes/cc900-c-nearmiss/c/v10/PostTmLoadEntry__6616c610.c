/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_35r1m306a.c (2026-11-22-23-p6-r90)
   sha256 6616c6101d720907e469efa1f2391cddac1235be0f4439c0b226b6c0172b2ac1 (tar-sha256); compiled at -O3 -Xr */
extern void SoundRam_ConvertSounds(unsigned int, unsigned int);
extern void SoundRam_ConvertUserKit(unsigned int, unsigned int);
extern void SoundRam_WriteIdAndChecksum(void);
extern void InterCPU_E1_Bulk_Transfer(void *, unsigned int, long);
extern void SubCPU_SendSoundMemUpdated(unsigned int, unsigned int);
extern void COMM_BuildAndSendPacket(unsigned int, unsigned int);
extern void FDemoText_RefreshFullDisplay(void);
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
