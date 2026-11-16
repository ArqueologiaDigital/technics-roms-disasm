/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ExtData_SetTlvField ExtData_ToggleTlvBits MIDI_WriteResetSequence SwbtWr_FlushAndAppendParams */   /* staged module names, repair_module_lines.py */

extern unsigned char __near ram_904e[];
extern unsigned char __near ram_9052[];
extern void SndParam_FetchOscTableEntry(unsigned char *);
extern void Rhythm_DispatchNote_Finalize(void);
extern void SndParam_ComputeVoiceIndex(unsigned char *);
extern void SndParam_CheckAndApplyMode(unsigned char *);

void SndParam_ResolveVoiceEntry(unsigned char *r)
{
  unsigned char *t = r + 2;
  unsigned char *b;
  if (*t <= 0x1f) SndParam_FetchOscTableEntry(r);
  else if (*t == 0x48) {
    b = ram_904e;
    b[0] = r[3]; b[1] = r[4]; b[2] = *t;
    Rhythm_DispatchNote_Finalize();
    b = ram_9052;
    r[0] = b[0]; r[1] = b[1];
  }
}

void RegBitManip_Handler_4_Helper(void)
{
  unsigned char b[6];
  b[3] = ram_904e[0]; b[4] = ram_904e[1]; b[5] = ram_904e[2];
  SndParam_ComputeVoiceIndex(b);
  ram_9052[0] = b[0]; ram_9052[1] = b[1]; ram_9052[2] = b[2];
}

void SndBuf_WriteParamEntries(void)
{
  unsigned char b[6];
  b[0] = ram_904e[0]; b[1] = ram_904e[1]; b[2] = ram_904e[2]; b[5] = ram_904e[3];
  SndParam_CheckAndApplyMode(b);
  ram_9052[0] = b[3]; ram_9052[1] = b[4];
}

extern void ExtData_SetTlvField(unsigned int);
extern void SwbtWr_FlushAndAppendParams(void);
extern void MIDI_WriteResetSequence(void);
void ExtData_Voice_CheckMode3_Helper(void);
extern void MIDI_WriteResetSequence(void);

void MIDI_WriteResetSequence(void);

void ExtData_Voice_CheckMode3_Helper(void)
{
	ExtData_SetTlvField(128);
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-module: PanelTlv_PayloadOfTag */
extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_MASK;
extern void ExtData_PostRawValueAndMask(void);
extern unsigned char *PanelTlv_PayloadOfTag(unsigned int);
extern unsigned char __near MIDI_MSG_STATUS;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near EXTDATA_NEW_VALUE;
extern void SndParam_WriteLookupAndStore(void);

void ExtData_PostRawValueAndMask(void)
{
	MIDI_MSG_DATA2 = EXTDATA_VALUE;
	MIDI_MSG_DATA3 = EXTDATA_MASK;
	SwbtWr_FlushAndAppendParams();
}
void SndParam_WriteLookupAndStore(void)
{
	unsigned char *p = PanelTlv_PayloadOfTag(MIDI_MSG_STATUS);

	if (p == (unsigned char *)-1L) return;
	EXTDATA_NEW_VALUE = p[EXTDATA_TLV_OFFSET];
}

/* cc900-module: ExtData_ApplyTransposeEvent ExtData_StepTlvField SndParam_WriteLookupAndStore */
extern void ExtData_ToggleTlvBits(unsigned int);
extern void ExtData_ToggleReverbIllusionOnOff(void);

void ExtData_ToggleReverbIllusionOnOff(void)
{
	ExtData_ToggleTlvBits(192);
	SwbtWr_FlushAndAppendParams();
}
