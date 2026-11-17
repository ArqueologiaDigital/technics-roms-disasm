/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/note_voice_mapping_xr.c (2026-11-16-33-p6-r2)
   sha256 8e172a1dddaf6bc5b1ac0690cf4beb7875edf834470c1c75451d8988e00266e5 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
struct pair { unsigned char a, b; };
int LinkVoiceSlots_LoadReg(struct pair *p, unsigned char c) { if (p[c].b == c) return 0; return 1; }
