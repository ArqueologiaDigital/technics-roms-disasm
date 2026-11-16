/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/note_voice_mapping_xr.c (2026-11-16-28-p6-m15)
   sha256 5480cc133040c5be09c11fd1a3ff04ec47cd8c06033a90912fa7b7d526683db7 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
struct pair { unsigned char a, b; };
int LinkVoiceSlots_LoadReg(struct pair *p, unsigned char c) { if (p[c].b == c) return 0; return 1; }
