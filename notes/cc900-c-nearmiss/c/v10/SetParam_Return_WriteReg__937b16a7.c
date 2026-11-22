/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_36r1m299b.c (2026-11-22-25-p6-r92)
   sha256 937b16a78e7c173906e66e26ba8767de2fd7f9655e63b6bc1632bd179de6b4fb (tar-sha256); compiled at -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern unsigned char __near AUDIO_STATE_SENT[];
extern unsigned char NoteMap_LookupVoice(struct nrec *, void *, unsigned int, unsigned int);
extern void Voice_ScanAndEmitMidiEvents(struct nrec *, unsigned int);
void SetParam_Return_WriteReg(unsigned char a, unsigned char c, unsigned char e)
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
