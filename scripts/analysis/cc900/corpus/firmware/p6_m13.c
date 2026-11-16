/* Phase 6, probe m13: larger leaf functions of v10's sequencer/bmdredit_routines.s, each under its firmware name.
   BmDrEdit_LoadAlternateState copies globals to globals: the ROM uses memory-to-memory moves (ldmm16 / ldmm8). */
extern unsigned char ram_295c, ram_295e, ram_2760, ram_276c, ram_2770, BMDREDIT_CHANNEL;
extern unsigned int ram_279a, ram_2792, ram_275e, ram_276a, ram_276e, SEQ_DATA_BLOCK, SEQ_DATA_OFFSET;
struct bmdr_pos { unsigned int block, offset; };

void BmDrEdit_DecrementDelayA(void) { unsigned char a = ram_295c; if (!(a & 0x80)) return; if (a == 0x80) return; ram_295c = a - 1; }
void BmDrEdit_DecrementDelayB(void) { unsigned char a = ram_295e; if (!(a & 0x80)) return; if (a == 0x80) return; ram_295e = a - 1; }
void BmDrEdit_AlignDisplayGrid(void) { unsigned int d = 0; unsigned int w = ram_279a; if (!(w < 0)) { unsigned int s = ram_2792; do d += s; while (d <= w); } ram_279a = d; }
void BmDrEdit_AlignGridBackward(void) { unsigned int w = ram_279a, d; if (w == 0) return; d = 0; if (w > 0) { unsigned int s = ram_2792; do d += s; while (d < w); } ram_279a = d - ram_2792; }
unsigned int BmDrEdit_CheckSlotsAvailable(void) { unsigned int i; unsigned char *b = (unsigned char *)0x2746; for (i = 0; i < 8; i++) if (b[i * 3] & 0x80) return 0xff; return 0; }
void BmDrEdit_SaveSongPosition(void) { unsigned char n = BMDREDIT_CHANNEL + 1; unsigned int b = SEQ_DATA_BLOCK, o = SEQ_DATA_OFFSET; struct bmdr_pos *p = (struct bmdr_pos *)0x23e0 + (n - 1); p->block = b; p->offset = o; }
void BmDrEdit_LoadAlternateState(void) { ram_275e = ram_276a; ram_2760 = ram_276c; SEQ_DATA_BLOCK = ram_276e; SEQ_DATA_OFFSET = ram_2770; }
