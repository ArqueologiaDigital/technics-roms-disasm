/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
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

/* cc900-module: ApplyProgramChangeAs_LoadDRAM2 ApplyProgramChange_LoadDRAM FetchOscTableEntry_Prologue SoundRam_IdentifyImage */
extern void PostTmSave(int r);
extern unsigned char ram_300000[];
extern void TmFlash_Return(void);
extern void TmFlash_CopyToExtMem(void);

void PostTmSave(int r)
{
  if (r < 0) COMM_BuildAndSendPacket(0xff, 0xff);
}
void TmFlash_CopyToExtMem(void)
{
  InterCPU_E1_Bulk_Transfer((void *)((long)ram_300000 + 0xb0400L), 0xee1f, 0xa0000L);
  TmFlash_Return();
}

extern unsigned char SoundRam_IdentifyImage(unsigned char *);
extern int PostTmSave_ByteBlock(unsigned char *p);

int PostTmSave_ByteBlock(unsigned char *p)
{
  unsigned char k = SoundRam_IdentifyImage(p);
  if (k <= 6 && k >= 1) return 0;
  return -0x66;
}

extern unsigned int ram_1e0010[];
extern unsigned int SoundRam_ComputeChecksum(void);
extern unsigned char ram_1e0000[];
extern void SoundRam_WriteChecksum(void);

unsigned int SoundRam_ComputeChecksum(void)
{
    unsigned int s;
    unsigned int *p;
    unsigned int n;

    n = 0x24b8;
    p = ram_1e0010;
    s = 0;
    do
        s += *p++;
    while (--n != 0);
    return ~s;
}
void SoundRam_WriteChecksum(void)
{
    unsigned int s;
    unsigned int *p;
    unsigned char *b;
    unsigned int n;

    n = 0x24b8;
    b = ram_1e0000;
    p = (unsigned int *)(b + 16);
    s = 0;
    do
        s += *p++;
    while (--n != 0);
    *(unsigned int *)(b + 29352) = ~s;
}
