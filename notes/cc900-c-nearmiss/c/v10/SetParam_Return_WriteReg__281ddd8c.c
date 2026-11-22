/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_36r1m299a.c (2026-11-22-25-p6-r92)
   sha256 281ddd8c978857d5c3e259574fcbdd5104df10bb0906b897a2c43d03613367d9 (tar-sha256); compiled at -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern unsigned char __near AUDIO_STATE_SENT[];
extern unsigned char NoteMap_LookupVoice(struct nrec *, void *, unsigned int, unsigned int);
extern void Voice_ScanAndEmitMidiEvents(struct nrec *, unsigned int);
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
