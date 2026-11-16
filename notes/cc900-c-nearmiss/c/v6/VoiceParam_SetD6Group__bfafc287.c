/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m235.c (2026-11-16-68-p6-r12)
   sha256 bfafc2875fa1d1fd79576b9677c9d023a72104b07c71ec3b3f8fc124f5de14a1 (tar-sha256); compiled at -O3 -Xr
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
