/* Probe round 34r1, helper X, form b (form a, but &s is also a local, `sp = &s;`, set after rp): audio/note_voice_mapping.s (module 299), -Xr / unoptimised code; retry of
   p6_V_33r1m299a.c (run r86, Xr: +19 / +23).  Spots changed from V's form a:
   - the two 164-byte records are declared s first, r second (V4.23 put V's r, declared first, above s; the ROM has
     r at the bottom of the frame, s at +164);
   - the record pointer passed to the calls that take other non-trivial arguments is a local, `rp = &r;` (the ROM
     computes &r first into a scratch register, XHL / XDE, and moves it to XWA last: the shape of the built
     NoteMap_LookupAllocAndStoreResult, note_voice_mapping_m297_xr.c); &s and the simple calls stay inline.
   NoteMap_ProcessLayeredNoteOn(a, c, e): for the two layers 2 and 3 of part a, look the voice up
   (key byte AUDIO_STATE_SENT[132 + a]) and emit its MIDI events with e, when c is a real note (both c / e != 0xff)
   or when only e is.
   ProcessLayeredNoteOn_WriteReg4(p1, p2): re-assign the voices of every part i (0..15) whose routing byte
   AUDIO_STATE_SENT[132 + i] is p2 (release: NoteMap_LookupVoice with mode 4) and claim new ones for those routed to
   p1 (NoteMap_ClaimVoiceSlot, SndParam_ComputeVoiceTuning, NoteMap_InitVoiceSlots when the best free voice is the
   layer's own), for layers 3 and 2. */

struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };

extern unsigned char __near AUDIO_STATE_SENT[];
extern unsigned char __near AUDIO_STATE[];
extern unsigned int __near ram_ce68;
extern unsigned char NoteMap_LookupVoice(struct nrec *, void *, unsigned int, unsigned int);
extern unsigned char NoteMap_ClaimVoiceSlot(struct nrec *, void *, unsigned int, unsigned int);
extern void Voice_ScanAndEmitMidiEvents(struct nrec *, unsigned int);
extern void NoteMap_AssignVoiceParams(unsigned char *, unsigned int);
extern void NoteMap_FindEntry(struct nrec *, unsigned int);
extern unsigned char NoteMap_FindBestFreeVoice(struct nrec *);
extern unsigned char NoteMap_FindBestMatch(void);
extern void NoteMap_InitVoiceSlots(unsigned char *, unsigned int);
extern void SndParam_ComputeVoiceTuning();

void NoteMap_ProcessLayeredNoteOn(unsigned char a, unsigned char c, unsigned char e)
{
    struct nrec s;
    struct nrec r;
    struct nrec *rp;
    void *sp;

    if (c != 0xff && e != 0xff) {
        s.b2 = 2;
        s.b3 = a;
        rp = &r;
        sp = &s;
        if (NoteMap_LookupVoice(rp, sp, 0,(AUDIO_STATE_SENT + 132)[a]) != 0) {
            rp = &r;
            Voice_ScanAndEmitMidiEvents(rp, e);
        }
        s.b2 = 3;
        s.b3 = a;
        rp = &r;
        sp = &s;
        if (NoteMap_LookupVoice(rp, sp, 0,(AUDIO_STATE_SENT + 132)[a]) != 0) {
            rp = &r;
            Voice_ScanAndEmitMidiEvents(rp, e);
        }
    } else if (c == 0xff && e != 0xff) {
        s.b2 = 2;
        s.b3 = a;
        rp = &r;
        sp = &s;
        if (NoteMap_LookupVoice(rp, sp, 0,(AUDIO_STATE_SENT + 132)[a]) != 0) {
            rp = &r;
            Voice_ScanAndEmitMidiEvents(rp, e);
        }
        s.b2 = 3;
        s.b3 = a;
        rp = &r;
        sp = &s;
        if (NoteMap_LookupVoice(rp, sp, 0,(AUDIO_STATE_SENT + 132)[a]) != 0) {
            rp = &r;
            Voice_ScanAndEmitMidiEvents(rp, e);
        }
    }
}

void ProcessLayeredNoteOn_WriteReg4(unsigned char p1, unsigned char p2)
{
    struct nrec s;
    struct nrec r;
    struct nrec *rp;
    void *sp;
    register unsigned int i;

    if (p1 != 0xff && p2 != 0xff) {
        if (ram_ce68 == 2 && ram_ce68 == 3)
            NoteMap_AssignVoiceParams(AUDIO_STATE_SENT, 2);
        for (i = 0; i < 16; i++) {
            if ((AUDIO_STATE_SENT + 132)[i] == p2) {
                s.b2 = 3;
                s.b3 = i;
                rp = &r;
                sp = &s;
                if (NoteMap_LookupVoice(rp, sp, 4, 2) != 0) {
                    NoteMap_FindEntry(&r, 2);
                    NoteMap_FindBestFreeVoice(&r);
                    NoteMap_FindBestMatch();
                }
                s.b2 = 2;
                s.b3 = i;
                rp = &r;
                sp = &s;
                if (NoteMap_LookupVoice(rp, sp, 4, 2) != 0) {
                    NoteMap_FindEntry(&r, 2);
                    NoteMap_FindBestFreeVoice(&r);
                    NoteMap_FindBestMatch();
                }
            }
        }
        for (i = 0; i < 16; i++) {
            if ((AUDIO_STATE_SENT + 132)[i] == p1) {
                s.b2 = 3;
                s.b3 = i;
                rp = &r;
                sp = &s;
                if (NoteMap_ClaimVoiceSlot(rp, sp, 0, p1) != 0) {
                    rp = &r;
                    SndParam_ComputeVoiceTuning(rp, AUDIO_STATE, p1);
                    NoteMap_FindEntry(&r, 2);
                    if (NoteMap_FindBestFreeVoice(&r) == 3 && NoteMap_FindBestMatch() != 0xff)
                        NoteMap_InitVoiceSlots(AUDIO_STATE, 2);
                }
                s.b2 = 2;
                s.b3 = i;
                rp = &r;
                sp = &s;
                if (NoteMap_ClaimVoiceSlot(rp, sp, 0, p1) != 0) {
                    rp = &r;
                    SndParam_ComputeVoiceTuning(rp, AUDIO_STATE, p1);
                    NoteMap_FindEntry(&r, 2);
                    if (NoteMap_FindBestFreeVoice(&r) == 2 && NoteMap_FindBestMatch() != 0xff)
                        NoteMap_InitVoiceSlots(AUDIO_STATE, 2);
                }
            }
        }
    } else if (p1 == 0xff && p2 != 0xff) {
        if (ram_ce68 == 2 && ram_ce68 == 3)
            NoteMap_AssignVoiceParams(AUDIO_STATE_SENT, 2);
        for (i = 0; i < 16; i++) {
            if ((AUDIO_STATE_SENT + 132)[i] == p2) {
                s.b2 = 3;
                s.b3 = i;
                rp = &r;
                sp = &s;
                if (NoteMap_LookupVoice(rp, sp, 4, 2) != 0) {
                    NoteMap_FindEntry(&r, 2);
                    NoteMap_FindBestFreeVoice(&r);
                    NoteMap_FindBestMatch();
                }
                s.b2 = 2;
                s.b3 = i;
                rp = &r;
                sp = &s;
                if (NoteMap_LookupVoice(rp, sp, 4, 2) != 0) {
                    NoteMap_FindEntry(&r, 2);
                    NoteMap_FindBestFreeVoice(&r);
                    NoteMap_FindBestMatch();
                }
            }
        }
    } else if (p1 != 0xff && p2 == 0xff) {
        for (i = 0; i < 16; i++) {
            if ((AUDIO_STATE_SENT + 132)[i] == p1) {
                s.b2 = 3;
                s.b3 = i;
                rp = &r;
                sp = &s;
                if (NoteMap_ClaimVoiceSlot(rp, sp, 0, p1) != 0) {
                    rp = &r;
                    SndParam_ComputeVoiceTuning(rp, AUDIO_STATE, p1);
                    NoteMap_FindEntry(&r, 2);
                    if (NoteMap_FindBestFreeVoice(&r) == 3 && NoteMap_FindBestMatch() != 0xff)
                        NoteMap_InitVoiceSlots(AUDIO_STATE, 2);
                }
                s.b2 = 2;
                s.b3 = i;
                rp = &r;
                sp = &s;
                if (NoteMap_ClaimVoiceSlot(rp, sp, 0, p1) != 0) {
                    rp = &r;
                    SndParam_ComputeVoiceTuning(rp, AUDIO_STATE, p1);
                    NoteMap_FindEntry(&r, 2);
                    if (NoteMap_FindBestFreeVoice(&r) == 2 && NoteMap_FindBestMatch() != 0xff)
                        NoteMap_InitVoiceSlots(AUDIO_STATE, 2);
                }
            }
        }
    }
}
