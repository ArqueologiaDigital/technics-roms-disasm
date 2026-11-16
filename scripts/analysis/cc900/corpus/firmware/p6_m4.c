/* Phase 6, probe m4: the -O question.  GetNamingWindowID loads the 32-bit constant 10 with ld, which V4.23 writes only
   without -O (with -O: lda).  Is that per-file options, or a firmware compiler without the lda rule?  These leaf
   loops load an address below 0x10000 into a 32-bit register.  StyleConv_ClearWorkBuffer (accompaniment_engine.s,
   lda XBC,(0x488c:16)) and VoiceAlloc_InitBitMap (sequencer_engine.s, lda XBC,(0x29f8:16)) look -O-shaped: the end
   pointer is computed from the start register and the loop has no entry test.  FloppyIO_ClearTrackParseBuffer
   (smf_tonegen_core.s) uses ld XIX,0x106e and djnz.  sc_*: StyleConv_ClearWorkBuffer (32 bytes at 0x488c);
   va_*: VoiceAlloc_InitBitMap (155 bytes at 0x29f8); fl_*: FloppyIO_ClearTrackParseBuffer (two words at 0x106e). */

extern unsigned char sc_buf[32];
extern unsigned char va_buf[155];

void sc_a(void) { unsigned char *p = (unsigned char *)0x488c; unsigned char *e = p + 32; do *p++ = 0; while (p < e); }
void sc_b(void) { unsigned char *p; for (p = (unsigned char *)0x488c; p < (unsigned char *)0x488c + 32; p++) *p = 0; }
void sc_c(void) { unsigned char *p = (unsigned char *)0x488c; unsigned char *e = p + 32; while (p < e) *p++ = 0; }
void sc_d(void) { unsigned char *p; for (p = sc_buf; p < sc_buf + 32; p++) *p = 0; }
void sc_e(void) { unsigned char *p, *e; for (p = sc_buf, e = p + sizeof sc_buf; p < e; p++) *p = 0; }

void va_a(void) { unsigned char *p = (unsigned char *)0x29f8; unsigned char *e = p + 155; while (p < e) *p++ = 0; }
void va_b(void) { unsigned char *p; for (p = (unsigned char *)0x29f8; p < (unsigned char *)0x29f8 + 155; p++) *p = 0; }
void va_d(void) { unsigned char *p; for (p = va_buf; p < va_buf + 155; p++) *p = 0; }

void fl_a(void) { unsigned int *p = (unsigned int *)0x106e; unsigned int n; for (n = 2; n != 0; n--) *p++ = 0; }
void fl_b(void) { unsigned int *p = (unsigned int *)0x106e; int n = 2; do *p++ = 0; while (--n); }
