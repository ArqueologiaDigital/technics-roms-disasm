/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void SubCPU_SendSystemRecord();
extern void MIDI_PostSendStub(void);

void MIDI_SendAllVoicesPitchUpdate(void)
{
  SubCPU_SendSystemRecord(80, 146, 0);
  MIDI_PostSendStub();
}

extern unsigned int __near ram_ce66;
extern unsigned char __near ram_ceb2;
extern unsigned char CHORD_NOTE_COUNT;
extern unsigned int ram_cf5f;
extern unsigned int ram_cf77;
extern unsigned char ram_cef1;
extern unsigned int __near ram_d8b2;
extern void ApplyProgramChangeAs_LoadDRAM2(unsigned char *, long, unsigned int);
extern void FetchOscTableEntry_Prologue(unsigned char *, long);
extern void ApplyProgramChange_LoadDRAM(unsigned char *, long, unsigned int);
extern void COMM_BuildAndSendPacket(unsigned int, unsigned int);
extern unsigned char ram_300000[];
extern void InterCPU_E1_Bulk_Transfer(void *, unsigned int, long);
extern void TmFlash_Return(void);

void ApplyProgramChangeAs_LoadReg2(unsigned char *p)
{
  ApplyProgramChangeAs_LoadDRAM2(p, 0x20L, 0x200);
}

void FetchOscTableEntry_LoadReg2(unsigned char *p)
{
  FetchOscTableEntry_Prologue(p, 0x24L);
}

void InitPartAllocState_Block4(void)
{
  CHORD_NOTE_COUNT = 0;
  ram_cf5f = 0;
  ram_cf77 = 0;
  ram_cef1 = 0;
}

void PostTmSave(int r)
{
  if (r < 0) COMM_BuildAndSendPacket(0xff, 0xff);
}

void SndParam_InitBufferConverge(unsigned char *p)
{
  ApplyProgramChange_LoadDRAM(p, 0x28L, 0x200);
}

unsigned int SysexRingBuf_GetFreeSpace(void)
{
  return 0x7ff - ram_d8b2;
}

void TmFlash_CopyToExtMem(void)
{
  InterCPU_E1_Bulk_Transfer((void *)((long)ram_300000 + 0xb0400L), 0xee1f, 0xa0000L);
  TmFlash_Return();
}

void Voice_ResetSearchState(void)
{
  ram_ce66 = 0;
  ram_ceb2 = 0;
}
