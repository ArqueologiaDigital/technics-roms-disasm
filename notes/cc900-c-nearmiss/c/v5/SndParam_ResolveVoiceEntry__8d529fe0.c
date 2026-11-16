/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/audio_control_engine_m280.c (2026-11-16-68-p6-r12)
   sha256 8d529fe092298a6a4d785732e8c53cdd60c87538f977c98b542b50379e4c9b95 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_902a[];
extern unsigned char __near ram_902e[];
extern void SndParam_FetchOscTableEntry(unsigned char *);
extern void Rhythm_DispatchNote_Finalize(void);
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
