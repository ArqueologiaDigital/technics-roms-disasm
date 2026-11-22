/* Probe round 36r1, helper B, form a: audio/note_voice_mapping.s (module 299), unoptimised -Xr shape.
   SetParam_Return_WriteReg(a, c, e): a sibling of PopIzStoreRet_WriteReg (helper C's p6_C_36r1m299*.c): when
   e != 0xff (and c either != 0xff or == 0xff: the two tests are separate in the ROM, with the same body), look
   the voice up three times (key bytes 2 / 3 = 00 00, 04 ff, 06 ff; before the third, a key of 0x19 is replaced
   by AUDIO_STATE_SENT[190]) and emit MIDI for channel e on each hit.  Two 164-byte records (struct nrec): the
   key k at +164 (declared first), r at +0.  c is never stored in the ROM (compared in C at entry and again
   after the first test): a `register` parameter here (form b: a plain one). */

struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern unsigned char __near AUDIO_STATE_SENT[];
extern unsigned char NoteMap_LookupVoice(struct nrec *, void *, unsigned int, unsigned int);
extern void Voice_ScanAndEmitMidiEvents(struct nrec *, unsigned int);
extern void SetParam_Return_WriteReg(unsigned char a, unsigned char c, unsigned char e);

void SetParam_Return_WriteReg(unsigned char a, register unsigned char c, unsigned char e)
{
    struct nrec k;
    struct nrec r;

    if (c != 0xff && e != 0xff) {
        k.b2 = 0;
        k.b3 = 0;
        if (NoteMap_LookupVoice(&r, &k, 0, a) != 0)
            Voice_ScanAndEmitMidiEvents(&r, e);
        k.b2 = 4;
        k.b3 = 0xff;
        if (NoteMap_LookupVoice(&r, &k, 0, a) != 0)
            Voice_ScanAndEmitMidiEvents(&r, e);
        k.b2 = 6;
        k.b3 = 0xff;
        if (a == 0x19)
            a = AUDIO_STATE_SENT[190];
        if (NoteMap_LookupVoice(&r, &k, 0, a) != 0)
            Voice_ScanAndEmitMidiEvents(&r, e);
    } else if (c == 0xff && e != 0xff) {
        k.b2 = 0;
        k.b3 = 0;
        if (NoteMap_LookupVoice(&r, &k, 0, a) != 0)
            Voice_ScanAndEmitMidiEvents(&r, e);
        k.b2 = 4;
        k.b3 = 0xff;
        if (NoteMap_LookupVoice(&r, &k, 0, a) != 0)
            Voice_ScanAndEmitMidiEvents(&r, e);
        k.b2 = 6;
        k.b3 = 0xff;
        if (a == 0x19)
            a = AUDIO_STATE_SENT[190];
        if (NoteMap_LookupVoice(&r, &k, 0, a) != 0)
            Voice_ScanAndEmitMidiEvents(&r, e);
    }
}
