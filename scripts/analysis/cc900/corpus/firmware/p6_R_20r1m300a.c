/* Helper R, round 1 of 2026-11-20: modules 292-306 (audio/dsp_config_sysex.s, audio/note_voice_mapping.s).  Form a. */
/* cc900-module: ApplyProgramChangeAs_LoadDRAM2 ApplyProgramChange_LoadDRAM FetchOscTableEntry_Prologue SoundRam_IdentifyImage */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void PanelTlv_ValidatePanelMemories(void);
extern void PanelTlv_WritePanelMemoryHeaders(void);
extern unsigned char DspBlock_ObjectCode_Table[];
extern unsigned char *PanelTlv_PayloadOfTag(unsigned char);
extern void AudioInit_SelectPriority(void);
extern void AudioInit_DispatchChanges(void);
extern unsigned int __near ram_ce66;
extern unsigned char __near ram_ceb2;
extern unsigned char CHORD_NOTE_COUNT;
extern unsigned int ram_cf5f;
extern unsigned int ram_cf77;
extern unsigned char ram_cef1;
extern volatile unsigned char __near ram_432;
extern unsigned int __near ram_d8b2;
extern void ApplyProgramChangeAs_LoadDRAM2(unsigned char *, long, unsigned int);
extern void FetchOscTableEntry_Prologue(unsigned char *, long);
extern void ApplyProgramChange_LoadDRAM(unsigned char *, long, unsigned int);
extern void COMM_BuildAndSendPacket(unsigned int, unsigned int);
extern unsigned char SoundRam_IdentifyImage(unsigned char *);
extern unsigned char ram_300000[];
extern void InterCPU_E1_Bulk_Transfer(void *, unsigned int, long);
extern void TmFlash_Return(void);

void PostPmLoad(int r)
{
  if (r >= 0) {
    PanelTlv_ValidatePanelMemories();
    PanelTlv_WritePanelMemoryHeaders();
  }
}

unsigned char *DSPCfg_LookupMidiMap(unsigned int a)
{
  return PanelTlv_PayloadOfTag(*(unsigned char *)((unsigned long)DspBlock_ObjectCode_Table + a));
}

void AudioInit_SelectAndDispatch(void)
{
  AudioInit_SelectPriority();
  AudioInit_DispatchChanges();
}

void Voice_ResetSearchState(void)
{
  ram_ce66 = 0;
  ram_ceb2 = 0;
}

void InitPartAllocState_Block4(void)
{
  CHORD_NOTE_COUNT = 0;
  ram_cf5f = 0;
  ram_cf77 = 0;
  ram_cef1 = 0;
}

void SeqPlay_BusyWaitLoop(void)
{
  while (ram_432 & 0x01)
    ;
}

unsigned int SysexRingBuf_GetFreeSpace(void)
{
  return 0x7ff - ram_d8b2;
}

void ApplyProgramChangeAs_LoadReg2(unsigned char *p)
{
  ApplyProgramChangeAs_LoadDRAM2(p, 0x20L, 0x200);
}

void FetchOscTableEntry_LoadReg2(unsigned char *p)
{
  FetchOscTableEntry_Prologue(p, 0x24L);
}

void SndParam_InitBufferConverge(unsigned char *p)
{
  ApplyProgramChange_LoadDRAM(p, 0x28L, 0x200);
}

void PostTmSave(int r)
{
  if (r < 0) COMM_BuildAndSendPacket(0xff, 0xff);
}

int PostTmSave_ByteBlock(unsigned char *p)
{
  unsigned char k = SoundRam_IdentifyImage(p);
  if (k > 6 || k < 1) return -0x66;
  return 0;
}

void TmFlash_CopyToExtMem(void)
{
  InterCPU_E1_Bulk_Transfer((void *)((long)ram_300000 + 0xb0400L), 0xee1f, 0xa0000L);
  TmFlash_Return();
}
