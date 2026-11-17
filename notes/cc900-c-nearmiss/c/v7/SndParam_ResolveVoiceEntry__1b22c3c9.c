/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/audio_control_engine.c (2026-11-16-45-p6-r9)
   sha256 1b22c3c9a2d93af16d82e1859959131bb364078aca3e1a6aaba79242ff16b8f1 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_904e[];
extern unsigned char __near ram_9052[];
void SndParam_ResolveVoiceEntry(unsigned char *r)
{
  unsigned char *t = r + 2;
  unsigned char *b;
  if (*t <= 0x1f) SndParam_FetchOscTableEntry(r);
  else if (*t == 0x48) {
    b = ram_904e;
    b[0] = r[3]; b[1] = r[4]; b[2] = *t;
    Rhythm_DispatchNote_Finalize();
    b = ram_9052;
    r[0] = b[0]; r[1] = b[1];
  }
}
