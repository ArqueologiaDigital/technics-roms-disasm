/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sequencer_engine_m235.c (2026-11-16-68-p6-r12)
   sha256 4e6fb15a9dcef11c657d923eaf017b50a32c6776dde159610f29f481be75a22a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void SetVisible(long, unsigned int);
void VoiceParam_SetD6Group(unsigned char a)
{
  unsigned int v = a != 0;
  SetVisible(0xd60003L, v);
  SetVisible(0xd60004L, v);
  SetVisible(0xd60005L, v);
  SetVisible(0xd60006L, v);
}
