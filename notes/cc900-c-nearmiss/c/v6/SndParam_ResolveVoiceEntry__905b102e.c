/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/audio_control_engine.c (2026-11-16-55-p6-r10)
   sha256 905b102ec67db05241a7bb46d72e45cb08dfa79fb3ce724d46d401b5490c3eb7 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_902a[];
extern unsigned char __near ram_902e[];
void SndParam_ResolveVoiceEntry(unsigned char *r)
{
  unsigned char *t = r + 2;
  unsigned char *b;
  if (*t <= 0x1f) SndParam_FetchOscTableEntry(r);
  else if (*t == 0x48) {
    b = ram_902a;
    b[0] = r[3]; b[1] = r[4]; b[2] = *t;
    Rhythm_DispatchNote_Finalize();
    b = ram_902e;
    r[0] = b[0]; r[1] = b[1];
  }
}
