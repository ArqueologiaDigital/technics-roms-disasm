/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/note_voice_mapping_xr.c (2026-11-16-36-p6-staged-r4)
   sha256 955cbe1627af30617c1f507fc2f42dc5b2280ca93c06074d26bd38c8f31ca931 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
struct pair { unsigned char a, b; };
int LinkVoiceSlots_LoadReg(struct pair *p, unsigned char c) { if (p[c].b == c) return 0; return 1; }
