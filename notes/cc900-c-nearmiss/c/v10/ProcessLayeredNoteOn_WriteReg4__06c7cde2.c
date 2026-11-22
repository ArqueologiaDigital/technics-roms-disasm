/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_V_33r1m299b.c (2026-11-22-19-p6-r86)
   sha256 06c7cde2e0d7bdb1b70de31d461e2d629caf63fb30e5951f8ffcd6b0c35f937e (tar-sha256); compiled at -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
struct asent { unsigned char pad[132]; unsigned char rt[16]; };
extern struct asent __near AUDIO_STATE_SENT;
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
    struct nrec r;
    struct nrec s;
    register unsigned int i;

    if (p1 != 0xff && p2 != 0xff) {
        if (ram_ce68 == 2 && ram_ce68 == 3)
            NoteMap_AssignVoiceParams((unsigned char *)&AUDIO_STATE_SENT, 2);
        for (i = 0; i < 16; i++) {
            if (AUDIO_STATE_SENT.rt[i] == p2) {
                s.b2 = 3;
                s.b3 = i;
                if (NoteMap_LookupVoice(&r, &s, 4, 2) != 0) {
                    NoteMap_FindEntry(&r, 2);
                    NoteMap_FindBestFreeVoice(&r);
                    NoteMap_FindBestMatch();
                }
                s.b2 = 2;
                s.b3 = i;
                if (NoteMap_LookupVoice(&r, &s, 4, 2) != 0) {
                    NoteMap_FindEntry(&r, 2);
                    NoteMap_FindBestFreeVoice(&r);
                    NoteMap_FindBestMatch();
                }
            }
        }
        for (i = 0; i < 16; i++) {
            if (AUDIO_STATE_SENT.rt[i] == p1) {
                s.b2 = 3;
                s.b3 = i;
                if (NoteMap_ClaimVoiceSlot(&r, &s, 0, p1) != 0) {
                    SndParam_ComputeVoiceTuning(&r, AUDIO_STATE, p1);
                    NoteMap_FindEntry(&r, 2);
                    if (NoteMap_FindBestFreeVoice(&r) == 3 && NoteMap_FindBestMatch() != 0xff)
                        NoteMap_InitVoiceSlots(AUDIO_STATE, 2);
                }
                s.b2 = 2;
                s.b3 = i;
                if (NoteMap_ClaimVoiceSlot(&r, &s, 0, p1) != 0) {
                    SndParam_ComputeVoiceTuning(&r, AUDIO_STATE, p1);
                    NoteMap_FindEntry(&r, 2);
                    if (NoteMap_FindBestFreeVoice(&r) == 2 && NoteMap_FindBestMatch() != 0xff)
                        NoteMap_InitVoiceSlots(AUDIO_STATE, 2);
                }
            }
        }
    } else if (p1 == 0xff && p2 != 0xff) {
        if (ram_ce68 == 2 && ram_ce68 == 3)
            NoteMap_AssignVoiceParams((unsigned char *)&AUDIO_STATE_SENT, 2);
        for (i = 0; i < 16; i++) {
            if (AUDIO_STATE_SENT.rt[i] == p2) {
                s.b2 = 3;
                s.b3 = i;
                if (NoteMap_LookupVoice(&r, &s, 4, 2) != 0) {
                    NoteMap_FindEntry(&r, 2);
                    NoteMap_FindBestFreeVoice(&r);
                    NoteMap_FindBestMatch();
                }
                s.b2 = 2;
                s.b3 = i;
                if (NoteMap_LookupVoice(&r, &s, 4, 2) != 0) {
                    NoteMap_FindEntry(&r, 2);
                    NoteMap_FindBestFreeVoice(&r);
                    NoteMap_FindBestMatch();
                }
            }
        }
    } else if (p1 != 0xff && p2 == 0xff) {
        for (i = 0; i < 16; i++) {
            if (AUDIO_STATE_SENT.rt[i] == p1) {
                s.b2 = 3;
                s.b3 = i;
                if (NoteMap_ClaimVoiceSlot(&r, &s, 0, p1) != 0) {
                    SndParam_ComputeVoiceTuning(&r, AUDIO_STATE, p1);
                    NoteMap_FindEntry(&r, 2);
                    if (NoteMap_FindBestFreeVoice(&r) == 3 && NoteMap_FindBestMatch() != 0xff)
                        NoteMap_InitVoiceSlots(AUDIO_STATE, 2);
                }
                s.b2 = 2;
                s.b3 = i;
                if (NoteMap_ClaimVoiceSlot(&r, &s, 0, p1) != 0) {
                    SndParam_ComputeVoiceTuning(&r, AUDIO_STATE, p1);
                    NoteMap_FindEntry(&r, 2);
                    if (NoteMap_FindBestFreeVoice(&r) == 2 && NoteMap_FindBestMatch() != 0xff)
                        NoteMap_InitVoiceSlots(AUDIO_STATE, 2);
                }
            }
        }
    }
}
