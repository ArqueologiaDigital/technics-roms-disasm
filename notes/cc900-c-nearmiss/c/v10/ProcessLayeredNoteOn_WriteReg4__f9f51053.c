/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_X_34r1m299c.c (2026-11-22-21-p6-r88)
   sha256 f9f5105362fc8dcc3a6d4a942171aec89207950679899c70c03311e2e65d911d (tar-sha256); compiled at -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern unsigned char __near AUDIO_STATE_SENT[];
extern unsigned char __near AUDIO_STATE[];
extern unsigned int __near ram_ce68;
extern unsigned char NoteMap_LookupVoice(struct nrec *, void *, unsigned int, unsigned int);
extern unsigned char NoteMap_ClaimVoiceSlot(struct nrec *, void *, unsigned int, unsigned int);
extern void NoteMap_AssignVoiceParams(unsigned char *, unsigned int);
extern void NoteMap_FindEntry(struct nrec *, unsigned int);
extern unsigned char NoteMap_FindBestFreeVoice(struct nrec *);
extern unsigned char NoteMap_FindBestMatch(void);
extern void NoteMap_InitVoiceSlots(unsigned char *, unsigned int);
extern void SndParam_ComputeVoiceTuning();
void ProcessLayeredNoteOn_WriteReg4(unsigned char p1, unsigned char p2)
{
    register unsigned int i;
    struct nrec *rp;
    struct nrec s;
    struct nrec r;

    if (p1 != 0xff && p2 != 0xff) {
        if (ram_ce68 == 2 && ram_ce68 == 3)
            NoteMap_AssignVoiceParams(AUDIO_STATE_SENT, 2);
        for (i = 0; i < 16; i++) {
            if ((AUDIO_STATE_SENT + 132)[i] == p2) {
                s.b2 = 3;
                s.b3 = i;
                rp = &r;
                if (NoteMap_LookupVoice(rp, &s, 4, 2) != 0) {
                    NoteMap_FindEntry(&r, 2);
                    NoteMap_FindBestFreeVoice(&r);
                    NoteMap_FindBestMatch();
                }
                s.b2 = 2;
                s.b3 = i;
                rp = &r;
                if (NoteMap_LookupVoice(rp, &s, 4, 2) != 0) {
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
                if (NoteMap_ClaimVoiceSlot(rp, &s, 0, p1) != 0) {
                    rp = &r;
                    SndParam_ComputeVoiceTuning(rp, AUDIO_STATE, p1);
                    NoteMap_FindEntry(&r, 2);
                    if (NoteMap_FindBestFreeVoice(&r) == 3 && NoteMap_FindBestMatch() != 0xff)
                        NoteMap_InitVoiceSlots(AUDIO_STATE, 2);
                }
                s.b2 = 2;
                s.b3 = i;
                rp = &r;
                if (NoteMap_ClaimVoiceSlot(rp, &s, 0, p1) != 0) {
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
                if (NoteMap_LookupVoice(rp, &s, 4, 2) != 0) {
                    NoteMap_FindEntry(&r, 2);
                    NoteMap_FindBestFreeVoice(&r);
                    NoteMap_FindBestMatch();
                }
                s.b2 = 2;
                s.b3 = i;
                rp = &r;
                if (NoteMap_LookupVoice(rp, &s, 4, 2) != 0) {
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
                if (NoteMap_ClaimVoiceSlot(rp, &s, 0, p1) != 0) {
                    rp = &r;
                    SndParam_ComputeVoiceTuning(rp, AUDIO_STATE, p1);
                    NoteMap_FindEntry(&r, 2);
                    if (NoteMap_FindBestFreeVoice(&r) == 3 && NoteMap_FindBestMatch() != 0xff)
                        NoteMap_InitVoiceSlots(AUDIO_STATE, 2);
                }
                s.b2 = 2;
                s.b3 = i;
                rp = &r;
                if (NoteMap_ClaimVoiceSlot(rp, &s, 0, p1) != 0) {
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
