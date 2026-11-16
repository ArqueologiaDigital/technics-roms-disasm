/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5a.c (2026-11-16-45-p6-r9)
   sha256 6f3782173ed786acb5b8f0b9571ad10fbd5c29c845f28fb8a50c793a4f9e1a23 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_90ea[];
extern unsigned char __near ram_90ee[];
extern void SndParam_ComputeVoiceIndex(unsigned char *);
void RegBitManip_Handler_4_Helper(void)
{
  unsigned char b[6];
  unsigned char *s = ram_90ea;
  b[3] = s[0]; b[4] = s[1]; b[5] = s[2];
  SndParam_ComputeVoiceIndex(b);
  s = ram_90ee;
  s[0] = b[0]; s[1] = b[1]; s[2] = b[2];
}
