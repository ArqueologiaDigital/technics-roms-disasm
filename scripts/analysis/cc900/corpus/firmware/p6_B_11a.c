/* Phase 6, helper B, round 11, form a: v10 sequencer/sequencer_engine.s (-O3 -Xr) and audio/note_voice_mapping.s
   (-Xr).  VoiceType_CheckDrumOrControl: both "return 0" exits share one block, the firmware's layout;
   ToneVoice_AssignChannel: new; InitChannelState_Che_InitVal: the entry fields as struct members of a pointer made
   from the byte offset, so that V4.23 keeps the field offset as a displacement. */

/* ---- sequencer/sequencer_engine.s ---- */

int VoiceType_CheckDrumOrControl(unsigned char a, unsigned char *p)
{
  unsigned char f = 0;
  if (p[0] == 0x82) return 0;
  if ((p[0] & 0xf0) == 0xc0) { if (p[2] == 0x48 && p[3] == 0) f = 1; }
  else if ((p[0] & 0xf0) == 0xb0 && p[2] == 0x48 && p[3] == 7) f = 1;
  if (a == 0x15) { if (f == 1) return 0; }
  else if (f == 0) return 0;
  return -1;
}

/* A track's play cursor {block, offset}: tracks being recorded (bit set in SEQ_REC_TRACKS while bits 0 and 6 of
   SEQ_PLAY_FLAGS are set) keep it in the record tables 0x291e (word) / 0x293e (byte), the others in 0x23e0. */
struct cur { unsigned int blk, off; };
extern unsigned char __near SEQ_PLAY_FLAGS;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned int __near ram_291e[];
extern unsigned char __near ram_293e[];
extern struct cur __near ram_23e0[];
extern void Part_CopyBytesToVoiceBlock(struct cur *, unsigned char *, unsigned int);

void ToneVoice_AssignChannel(unsigned char a, unsigned char *buf, unsigned char n)
{
  struct cur c;
  unsigned char f, k;
  f = SEQ_PLAY_FLAGS & 0x41;
  k = a - 1;
  if (f == 0x41 && (SEQ_REC_TRACKS & (1 << (a - 1)))) {
    c.blk = ram_291e[k];
    c.off = ram_293e[k];
  } else c = ram_23e0[k];
  Part_CopyBytesToVoiceBlock(&c, buf, n);
  f = SEQ_PLAY_FLAGS & 0x41;
  k = a - 1;
  if (f == 0x41 && (SEQ_REC_TRACKS & (1 << (a - 1)))) {
    ram_291e[k] = c.blk;
    ram_293e[k] = c.off;
  } else ram_23e0[k] = c;
}

/* ---- audio/note_voice_mapping.s (-Xr) ---- */

struct nent5 { unsigned char e0, e1, e2, e3, e4; };
#define NM_E(r, i) ((struct nent5 *)((unsigned char *)(r) + ((unsigned long)(i) * 5 + 4)))

void InitChannelState_Che_InitVal(unsigned char *r)
{
  unsigned int i;
  for (i = 0; i < r[1]; i++) {
    NM_E(r, i)->e4 = 0;
    if (NM_E(r, i)->e1 != 0) {
      NM_E(r, i)->e2 = NM_E(r, i)->e0;
      NM_E(r, i)->e3 = NM_E(r, i)->e0;
    }
  }
}
