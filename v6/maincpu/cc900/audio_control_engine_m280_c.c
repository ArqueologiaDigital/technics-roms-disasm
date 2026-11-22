/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Audio_FlushPendingBankSelects */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char *PanelTlv_PayloadByTag[];
extern unsigned char *PanelTlv_PayloadOfTag(unsigned char t);
extern unsigned char __near ANALOG_MAIN_VOLUME_VALUE;
extern unsigned char __near ANALOG_MAIN_VOLUME_PENDING;
extern void Audio_FlushPendingBankSelects(void);
extern unsigned char __near ram_90be;
extern unsigned char __near ram_90bf;
extern unsigned char __near ram_90c0;
extern unsigned char __near ram_90c1;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_MASK;
extern void MIDI_LoadParamsAndDispatchCC(void);
extern void ExtData_VoiceCmpDisp_Helper(void);

unsigned char *PanelTlv_PayloadOfTag(unsigned char t)
{
  return PanelTlv_PayloadByTag[t];
}

/* cc900-name: ExtData_VoiceCmpDisp_Helper=ExtData_Voice_CompareAndDispatch_Helper */
void ExtData_VoiceCmpDisp_Helper(void)
{
  ANALOG_MAIN_VOLUME_PENDING = ANALOG_MAIN_VOLUME_VALUE | 0x80;
  Audio_FlushPendingBankSelects();
  ram_90be = 176;
  ram_90bf = 0;
  ram_90c0 = EXTDATA_VALUE;
  ram_90c1 = EXTDATA_MASK;
  MIDI_LoadParamsAndDispatchCC();
}
