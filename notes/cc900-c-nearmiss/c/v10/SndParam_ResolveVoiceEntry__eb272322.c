/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/audio_control_engine.c (2026-11-16-55-p6-r10)
   sha256 eb272322a9ca5cd5672dea3f898fbc1c871c8ab00549b22bdff756d69d49a438 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_90ea[];
extern unsigned char __near ram_90ee[];
void SndParam_ResolveVoiceEntry(unsigned char *r)
{
  unsigned char *t = r + 2;
  unsigned char *b;
  if (*t <= 0x1f) SndParam_FetchOscTableEntry(r);
  else if (*t == 0x48) {
    b = ram_90ea;
    b[0] = r[3]; b[1] = r[4]; b[2] = *t;
    Rhythm_DispatchNote_Finalize();
    b = ram_90ee;
    r[0] = b[0]; r[1] = b[1];
  }
}
