/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/note_voice_mapping_xr.c (2026-11-16-33-p6-r2)
   sha256 f41a4b5044b2c05a73c8ab8ef8f04f473743e1732af80e40d382f3d878b4deed (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
struct pair { unsigned char a, b; };
int LinkVoiceSlots_LoadReg(struct pair *p, unsigned char c) { if (p[c].b == c) return 0; return 1; }
