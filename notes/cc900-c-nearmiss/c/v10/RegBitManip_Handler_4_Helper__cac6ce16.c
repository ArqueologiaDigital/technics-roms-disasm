/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/audio_control_engine_m280.c (2026-11-16-68-p6-r12)
   sha256 cac6ce163bd10a2091fefbe9dbae7dd8970e6a2d2b407c41bfb43a1b292be237 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_90ea[];
extern unsigned char __near ram_90ee[];
extern void SndParam_ComputeVoiceIndex(unsigned char *);
void RegBitManip_Handler_4_Helper(void)
{
  unsigned char b[6];
  b[3] = ram_90ea[0]; b[4] = ram_90ea[1]; b[5] = ram_90ea[2];
  SndParam_ComputeVoiceIndex(b);
  ram_90ee[0] = b[0]; ram_90ee[1] = b[1]; ram_90ee[2] = b[2];
}
