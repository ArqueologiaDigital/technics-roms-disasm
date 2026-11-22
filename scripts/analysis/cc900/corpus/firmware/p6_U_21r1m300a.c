/* helper U, round 21r1, module 300, form a: one-spot retries of run r59.
   DSPCfg_LookupMidiMap: the ROM passes the table byte in A with no extz: the callee's parameter plain char.
   PostTmSave_ByteBlock: the ROM places `return 0` first, so the condition is the in-range test. */
/* cc900-module: SoundRam_IdentifyImage */

extern unsigned char DspBlock_ObjectCode_Table[];
extern unsigned char *PanelTlv_PayloadOfTag(char);
extern unsigned char SoundRam_IdentifyImage(unsigned char *);

unsigned char *DSPCfg_LookupMidiMap(unsigned int a)
{
  return PanelTlv_PayloadOfTag(*(unsigned char *)((unsigned long)DspBlock_ObjectCode_Table + a));
}

int PostTmSave_ByteBlock(unsigned char *p)
{
  unsigned char k = SoundRam_IdentifyImage(p);
  if (k <= 6 && k >= 1) return 0;
  return -0x66;
}
