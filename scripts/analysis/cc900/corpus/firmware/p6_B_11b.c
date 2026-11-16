/* Phase 6, helper B, round 11, form b: the functions of p6_B_11a.c with other C shapes (a result variable for
   VoiceType_CheckDrumOrControl; the record test as a macro and per-field copies in ToneVoice_AssignChannel; the
   entry address kept in a pointer temporary in InitChannelState_Che_InitVal). */

/* ---- sequencer/sequencer_engine.s ---- */

int VoiceType_CheckDrumOrControl(unsigned char a, unsigned char *p)
{
  unsigned char f = 0;
  if (p[0] == 0x82) return 0;
  if ((p[0] & 0xf0) == 0xc0) { if (p[2] == 0x48 && p[3] == 0) f = 1; }
  else if ((p[0] & 0xf0) == 0xb0 && p[2] == 0x48 && p[3] == 7) f = 1;
  if (a == 0x15) {
    if (f != 1) return -1;
  } else if (f != 0) return -1;
  return 0;
}

struct cur { unsigned int blk, off; };
extern unsigned char __near SEQ_PLAY_FLAGS;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned int __near ram_291e[];
extern unsigned char __near ram_293e[];
extern struct cur __near ram_23e0[];
extern void Part_CopyBytesToVoiceBlock(struct cur *, unsigned char *, unsigned int);
#define TRACK_RECORDING(a) ((SEQ_PLAY_FLAGS & 0x41) == 0x41 && (SEQ_REC_TRACKS & (1 << ((a) - 1))))

void ToneVoice_AssignChannel(unsigned char a, unsigned char *buf, unsigned char n)
{
  struct cur c;
  if (TRACK_RECORDING(a)) {
    c.blk = ram_291e[(unsigned char)(a - 1)];
    c.off = ram_293e[(unsigned char)(a - 1)];
  } else {
    c.blk = ram_23e0[(unsigned char)(a - 1)].blk;
    c.off = ram_23e0[(unsigned char)(a - 1)].off;
  }
  Part_CopyBytesToVoiceBlock(&c, buf, n);
  if (TRACK_RECORDING(a)) {
    ram_291e[(unsigned char)(a - 1)] = c.blk;
    ram_293e[(unsigned char)(a - 1)] = c.off;
  } else {
    ram_23e0[(unsigned char)(a - 1)].blk = c.blk;
    ram_23e0[(unsigned char)(a - 1)].off = c.off;
  }
}

/* ---- audio/note_voice_mapping.s (-Xr) ---- */

struct nent5 { unsigned char e0, e1, e2, e3, e4; };

void InitChannelState_Che_InitVal(unsigned char *r)
{
  unsigned int i;
  struct nent5 *e;
  for (i = 0; i < r[1]; i++) {
    e = (struct nent5 *)(r + ((unsigned long)i * 5 + 4));
    e->e4 = 0;
    if (e->e1 != 0) { e->e2 = e->e0; e->e3 = e->e0; }
  }
}
