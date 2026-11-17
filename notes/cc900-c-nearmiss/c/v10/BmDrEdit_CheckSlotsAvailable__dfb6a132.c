/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m13.c (2026-11-16-26-p6-m13)
   sha256 dfb6a13207f3ebb559050fb4a9c58a53545309b98a501a0f475b8e4826d2c345 (name+funcs); compiled at (no flags) */
unsigned int BmDrEdit_CheckSlotsAvailable(void) { unsigned int i; unsigned char *b = (unsigned char *)0x2746; for (i = 0; i < 8; i++) if (b[i * 3] & 0x80) return 0xff; return 0; }
