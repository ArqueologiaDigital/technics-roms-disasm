/* Probe round 36r1, helper C, form b (r declared before k): audio/note_voice_mapping.s (module 299), unoptimised -Xr shape (no `register`).
   PopIzStoreRet_WriteReg(a, c, e): when c == 0xff and e != 0xff, look the voice up three times (key bytes 2 / 3 =
   00 00, 04 ff, 06 ff) and set channel e's parameter on each hit; then when c != 0xff, c != e and a is 0x15 or 2,
   claim a voice slot (key 06 ff) and set channel c's parameter.  Two 164-byte records in the frame (as the built
   NoteMap_LookupAllocAndStoreResult's struct nrec): r at +0, the key k at +164 (declared first: the local declared
   last gets the lowest slot).
   PopIzStoreRet_Prologue(a, c, e): assign voice params from AUDIO_STATE_SENT and / or allocate a voice from
   AUDIO_STATE, by which of c / e are 0xff (callees in another module: absolute calls). */

struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern unsigned char __near AUDIO_STATE[];
extern unsigned char __near AUDIO_STATE_SENT[];
extern void NoteMap_SetChannelParam(struct nrec *, unsigned int);
extern unsigned char NoteMap_LookupVoice(struct nrec *, void *, unsigned int, unsigned int);
extern unsigned char NoteMap_ClaimVoiceSlot(struct nrec *, void *, unsigned int, unsigned int);
extern void NoteMap_AssignVoiceParams();
extern void NoteMap_AllocateVoice();
extern void PopIzStoreRet_WriteReg(unsigned char a, unsigned char c, unsigned char e);
extern void PopIzStoreRet_Prologue(unsigned char a, unsigned char c, unsigned char e);

void PopIzStoreRet_Prologue(unsigned char a, unsigned char c, unsigned char e)
{
  if (c == 0xff && e != 0xff)
    NoteMap_AssignVoiceParams(AUDIO_STATE_SENT, a);
  else if (c != 0xff && e != 0xff) {
    NoteMap_AssignVoiceParams(AUDIO_STATE_SENT, a);
    NoteMap_AllocateVoice(AUDIO_STATE, a);
  } else
    NoteMap_AllocateVoice(AUDIO_STATE, a);
}

void PopIzStoreRet_WriteReg(unsigned char a, unsigned char c, unsigned char e)
{
  struct nrec r;
  struct nrec k;

  if (c == 0xff && e != 0xff) {
    k.b2 = 0;
    k.b3 = 0;
    if (NoteMap_LookupVoice(&r, &k, 0, a) != 0)
      NoteMap_SetChannelParam(&r, e);
    k.b2 = 4;
    k.b3 = 0xff;
    if (NoteMap_LookupVoice(&r, &k, 0, a) != 0)
      NoteMap_SetChannelParam(&r, e);
    k.b2 = 6;
    k.b3 = 0xff;
    if (NoteMap_LookupVoice(&r, &k, 0, a) != 0)
      NoteMap_SetChannelParam(&r, e);
  }
  if (c != 0xff && c != e && (a == 0x15 || a == 2)) {
    k.b2 = 6;
    k.b3 = 0xff;
    if (NoteMap_ClaimVoiceSlot(&r, &k, 0, a) != 0)
      NoteMap_SetChannelParam(&r, c);
  }
}
