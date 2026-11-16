/* Phase 6, probe m4 split: one function of p6_m4.c per file, to find which one crashes V4.23's
   code generator (run 2026-11-16-12-p6-m4: a page fault reading 0x4890, at every option set). */
extern unsigned char sc_buf[32];
extern unsigned char va_buf[155];

void sc_e(void) { unsigned char *p, *e; for (p = sc_buf, e = p + sizeof sc_buf; p < e; p++) *p = 0; }
