/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/note_voice_mapping_xr.c (2026-11-16-30-p6-r1)
   sha256 b05e0d67ff49a5cd5dd5d45cc8998cc0d864285ce5ee41c9b935883776bd2c15 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
struct pair { unsigned char a, b; };
int LinkVoiceSlots_LoadReg(struct pair *p, unsigned char c) { if (p[c].b == c) return 0; return 1; }
