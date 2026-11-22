/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_21r1m300b.c (2026-11-21-7-p6-r62)
   sha256 ced4017a57d1ddad89eef99e595a23884f7017abd62755f068a979070a8a8085 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char DspBlock_ObjectCode_Table[];
extern unsigned char *PanelTlv_PayloadOfTag(signed char);
unsigned char *DSPCfg_LookupMidiMap(unsigned int a)
{
  return PanelTlv_PayloadOfTag(*(char *)((unsigned long)DspBlock_ObjectCode_Table + a));
}
