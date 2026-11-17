/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/note_voice_mapping_xr.c (2026-11-16-36-p6-staged-r4)
   sha256 27a3280d745ba1427bdf0bfe6dcf8f1b24b0d269860cf3a56b9999f3b43eebe6 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
struct pair { unsigned char a, b; };
int LinkVoiceSlots_LoadReg(struct pair *p, unsigned char c) { if (p[c].b == c) return 0; return 1; }
