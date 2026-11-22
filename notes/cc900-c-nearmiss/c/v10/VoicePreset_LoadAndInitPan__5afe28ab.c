/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_21r1m234b.c (2026-11-21-7-p6-r62)
   sha256 5afe28ab150c2a0066f966bbe7968e81fb1844ab29b8862275eec33b6fdf1cee (tar-sha256); compiled at -O3 -Xr */
struct song { unsigned char b[0x800]; };
extern struct song SEQ_SONG_RECORD;
extern struct song SEQ_SONG_SLOTS[];
extern void VoiceChannels_InitPanFromPreset(void);
void VoicePreset_LoadAndInitPan(unsigned char a)
{
  struct song *p;
  p = SEQ_SONG_SLOTS;
  p += a;
  SEQ_SONG_RECORD = *p;
  VoiceChannels_InitPanFromPreset();
}
