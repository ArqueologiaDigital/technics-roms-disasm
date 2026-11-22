/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m234a.c (2026-11-21-3-p6-r59)
   sha256 b86808166a06d60625b10f675d0d7cd1a33d597b82e5099a43dcbbaebf33208e (tar-sha256); compiled at -O3 -Xr */
struct song { unsigned char b[0x800]; };
extern struct song SEQ_SONG_SLOTS[];
extern struct song SEQ_SONG_RECORD;
extern void VoiceChannels_InitPanFromPreset(void);
void VoicePreset_LoadAndInitPan(unsigned char a)
{
  SEQ_SONG_RECORD = SEQ_SONG_SLOTS[a];
  VoiceChannels_InitPanFromPreset();
}
