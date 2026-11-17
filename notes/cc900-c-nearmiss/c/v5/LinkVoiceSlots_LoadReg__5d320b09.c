/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/note_voice_mapping_xr.c (2026-11-16-33-p6-r2)
   sha256 5d320b09cdd857405e7b2d509455e56976c2e2f21a7597d9adaa1d6654d375d4 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
struct pair { unsigned char a, b; };
int LinkVoiceSlots_LoadReg(struct pair *p, unsigned char c) { if (p[c].b == c) return 0; return 1; }
