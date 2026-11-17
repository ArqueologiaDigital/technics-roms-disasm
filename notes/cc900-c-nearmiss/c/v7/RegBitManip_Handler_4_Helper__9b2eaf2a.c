/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/audio_control_engine_m280.c (2026-11-16-68-p6-r12)
   sha256 9b2eaf2a095c86cfda5d4373d31062e93930a94f1bcc12bce93661da6f7bc6ed (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_904e[];
extern unsigned char __near ram_9052[];
extern void SndParam_ComputeVoiceIndex(unsigned char *);
void RegBitManip_Handler_4_Helper(void)
{
  unsigned char b[6];
  b[3] = ram_904e[0]; b[4] = ram_904e[1]; b[5] = ram_904e[2];
  SndParam_ComputeVoiceIndex(b);
  ram_9052[0] = b[0]; ram_9052[1] = b[1]; ram_9052[2] = b[2];
}
