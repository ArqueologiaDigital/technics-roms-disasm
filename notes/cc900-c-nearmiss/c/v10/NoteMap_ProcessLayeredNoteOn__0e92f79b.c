/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_X_34r1m299a.c (2026-11-22-21-p6-r88)
   sha256 0e92f79b4e8efbfce2b3335dc3e5d317cfdb3bf524f6fe4829f1c816791de1f1 (tar-sha256); compiled at -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern unsigned char __near AUDIO_STATE_SENT[];
extern unsigned char NoteMap_LookupVoice(struct nrec *, void *, unsigned int, unsigned int);
extern void Voice_ScanAndEmitMidiEvents(struct nrec *, unsigned int);
void NoteMap_ProcessLayeredNoteOn(unsigned char a, unsigned char c, unsigned char e)
{
    struct nrec s;
    struct nrec r;
    struct nrec *rp;

    if (c != 0xff && e != 0xff) {
        s.b2 = 2;
        s.b3 = a;
        rp = &r;
        if (NoteMap_LookupVoice(rp, &s, 0, (AUDIO_STATE_SENT + 132)[a]) != 0) {
            rp = &r;
            Voice_ScanAndEmitMidiEvents(rp, e);
        }
        s.b2 = 3;
        s.b3 = a;
        rp = &r;
        if (NoteMap_LookupVoice(rp, &s, 0, (AUDIO_STATE_SENT + 132)[a]) != 0) {
            rp = &r;
            Voice_ScanAndEmitMidiEvents(rp, e);
        }
    } else if (c == 0xff && e != 0xff) {
        s.b2 = 2;
        s.b3 = a;
        rp = &r;
        if (NoteMap_LookupVoice(rp, &s, 0, (AUDIO_STATE_SENT + 132)[a]) != 0) {
            rp = &r;
            Voice_ScanAndEmitMidiEvents(rp, e);
        }
        s.b2 = 3;
        s.b3 = a;
        rp = &r;
        if (NoteMap_LookupVoice(rp, &s, 0, (AUDIO_STATE_SENT + 132)[a]) != 0) {
            rp = &r;
            Voice_ScanAndEmitMidiEvents(rp, e);
        }
    }
}
