/* Phase 6, probe m17 (bitfields): does V4.23 accept unsigned char bitfields, and how does it copy one field?  The
   firmware's VoiceParam_CopyBitfields_* / DataBuf_Copy*Block* routines (midi/midi_dispatch_handlers.s) move fields
   byte by byte. */
struct bc { unsigned char lo : 4, hi : 3, top : 1; };
struct bi { unsigned int lo : 4, hi : 3, top : 1; };
void cp_c(struct bc *d, struct bc *s) { d->hi = s->hi; }
void cp_i(struct bi *d, struct bi *s) { d->hi = s->hi; }
unsigned char get_c(struct bc *s) { return s->top; }
void set_c(struct bc *d, unsigned char v) { d->lo = v; }
