/* helper U, round 21r1, module 300, form b: the callee's parameter signed char and the byte read as plain char;
   PostTmSave_ByteBlock through a result local. */
/* cc900-module: SoundRam_IdentifyImage */

extern unsigned char DspBlock_ObjectCode_Table[];
extern unsigned char *PanelTlv_PayloadOfTag(signed char);
extern unsigned char SoundRam_IdentifyImage(unsigned char *);

unsigned char *DSPCfg_LookupMidiMap(unsigned int a)
{
  return PanelTlv_PayloadOfTag(*(char *)((unsigned long)DspBlock_ObjectCode_Table + a));
}

int PostTmSave_ByteBlock(unsigned char *p)
{
  int r;
  unsigned char k = SoundRam_IdentifyImage(p);
  if (k <= 6 && k >= 1) r = 0;
  else r = -0x66;
  return r;
}
