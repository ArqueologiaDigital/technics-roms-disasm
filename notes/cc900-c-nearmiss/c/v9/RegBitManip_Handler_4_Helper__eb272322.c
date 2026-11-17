/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/audio_control_engine.c (2026-11-16-55-p6-r10)
   sha256 eb272322a9ca5cd5672dea3f898fbc1c871c8ab00549b22bdff756d69d49a438 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_90ea[];
extern unsigned char __near ram_90ee[];
void RegBitManip_Handler_4_Helper(void)
{
  unsigned char b[6];
  b[3] = ram_90ea[0]; b[4] = ram_90ea[1]; b[5] = ram_90ea[2];
  SndParam_ComputeVoiceIndex(b);
  ram_90ee[0] = b[0]; ram_90ee[1] = b[1]; ram_90ee[2] = b[2];
}
