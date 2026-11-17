/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/note_voice_mapping_xr.c (2026-11-16-36-p6-staged-r4)
   sha256 63da6ef5e8c0dae77bbaf2f1fbfeeddf25e250879ca89949abdef1b13525cf87 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
struct pair { unsigned char a, b; };
int LinkVoiceSlots_LoadReg(struct pair *p, unsigned char c) { if (p[c].b == c) return 0; return 1; }
