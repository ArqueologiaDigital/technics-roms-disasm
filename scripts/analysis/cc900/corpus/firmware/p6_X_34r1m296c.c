/* Probe round 34r1, helper X, form c (form a, but AUDIO_STATE is a struct with a signed char field at 356 and an
   unsigned one at 357, instead of a cast lvalue): audio/note_voice_mapping.s (module 296), -Xr / unoptimised code; retry of
   p6_V_33r1m296b.c (run r86, Xr: +20 / +24).  Spots changed from V's form b:
   - out's five-byte entries are a struct array at out + 4 (the ROM stores entry 0's fields at out + 8 / 4 / 5
     directly, no `inc 4`);
   - each read is an assignment inside the condition, `(x = f()) == 0xffff` (the ROM reloads the assigned value
     into WA and compares WA, not the cell);
   - the status tests use the byte, `((unsigned char)st & 0xf0)` (the ROM ANDs and compares A, not WA);
   - the signed velocity offset is read through a signed char lvalue (the ROM compares the cell with 0 directly).
   MidiEvent_ProcessNoteEntry(ev, out): gather a run of note / control events of one channel from the sequencer
   stream (SeqMain_ReadData: status, data 1, data 2; 0xffff = end) into out's entries; ev is the pending event
   (status, channel, -, note, velocity) carried between calls, 0xff = stream ended.  AUDIO_STATE byte 357 = fixed
   velocity (0xff = off), byte 356 = signed velocity offset (result clamped to 1..127).  Returns the entry count
   (0 and Voice_InitializeAll when more than 32 were read).
   RhythmBuf_ParseEventLoop(ev, out): its twin for the rhythm buffer (RhythmBuf_ReadAlternate): 0x90 with data
   0x7f is a control group, 0x94..0x98 note events (channel = low nibble - 4), 0x98 with data 0x7d..0x7f a CC
   command (Rhythm_DispatchCCCommand). */

struct nent5 { unsigned char e0, e1, e2, e3, e4; };

struct NoteGroup {
    unsigned char status;
    unsigned char count;
    unsigned char one;
    unsigned char chan;
    struct nent5 ent[32];
};

struct AudioState { unsigned char pad[356]; signed char veloff; unsigned char velfix; };
extern struct AudioState __near AUDIO_STATE;
extern unsigned int SeqMain_ReadData(void);
extern unsigned int RhythmBuf_ReadAlternate(void);
extern void Voice_InitializeAll(void);
extern void Voice_InitTableGroup(void);
extern void Rhythm_DispatchCCCommand();

unsigned char MidiEvent_ProcessNoteEntry(register unsigned char *ev, struct NoteGroup *out)
{
    unsigned int n;
    unsigned int st;
    unsigned int d1;
    register unsigned int v;

    n = 0;
    switch (ev[0]) {
    case 0:
        break;
    case 0xff:
        goto done;
    default:
        out->status = ev[0];
        out->one = 1;
        out->chan = ev[1];
        out->ent[0].e4 = 0;
        out->ent[0].e0 = ev[3];
        out->ent[0].e1 = ev[4];
        n++;
        break;
    }
    if (ev[0] != 0xff) do {
        if ((st = SeqMain_ReadData()) == 0xffff) {
            ev[0] = 0xff;
            break;
        }
        if ((d1 = SeqMain_ReadData()) == 0xffff) {
            ev[0] = 0xff;
            break;
        }
        if ((v = SeqMain_ReadData()) == 0xffff) {
            ev[0] = 0xff;
            break;
        }
        if (v != 0) {
            if (AUDIO_STATE.velfix != 255) {
                v = AUDIO_STATE.velfix;
            } else if (AUDIO_STATE.veloff > 0) {
                if ((unsigned char)(AUDIO_STATE.veloff + v) > 0x7f)
                    v = 0x7f;
                else
                    v += AUDIO_STATE.veloff;
            } else {
                if ((signed char)(AUDIO_STATE.veloff + v) < 0)
                    v = 1;
                else
                    v += AUDIO_STATE.veloff;
            }
        }
        if (((unsigned char)st & 0xf0) == 0xb0) {
            if (n == 0) {
                ev[0] = 0xb0;
                ev[1] = st & 0xf;
                out->status = ev[0];
                out->one = 1;
                out->chan = ev[1];
                n++;
            } else {
                ev[0] = 0xb0;
                ev[1] = st & 0xf;
                ev[3] = d1;
                ev[4] = v;
                break;
            }
        } else if (n == 0) {
            ev[0] = 0x90;
            ev[1] = st & 0xf;
            out->status = ev[0];
            out->one = 1;
            out->chan = ev[1];
            out->ent[n].e4 = 0;
            out->ent[n].e0 = d1;
            if (((unsigned char)st & 0xf0) == 0x80)
                out->ent[n].e1 = 0;
            else
                out->ent[n].e1 = v;
            n++;
        } else if (((unsigned char)st & 0xf) == ev[1] && ev[0] != 0xb0) {
            if (n < 0x20) {
                out->ent[n].e4 = 0;
                out->ent[n].e0 = d1;
                if (((unsigned char)st & 0xf0) == 0x80)
                    out->ent[n].e1 = 0;
                else
                    out->ent[n].e1 = v;
            }
            n++;
        } else {
            ev[0] = 0x90;
            ev[1] = st & 0xf;
            ev[3] = d1;
            if (((unsigned char)st & 0xf0) == 0x80)
                ev[4] = 0;
            else
                ev[4] = v;
            break;
        }
    } while (ev[0] != 0xff);
done:
    if (n <= 0x20)
        return out->count = n;
    Voice_InitializeAll();
    out->count = 0;
    return 0;
}

unsigned char RhythmBuf_ParseEventLoop(unsigned char *ev, struct NoteGroup *out)
{
    unsigned int n;
    unsigned int b;
    register unsigned int a;
    register unsigned int c;

    n = 0;
    switch (ev[0]) {
    case 0:
        break;
    case 0xff:
        goto done;
    default:
        out->status = ev[0];
        out->one = 4;
        out->chan = ev[1];
        out->ent[0].e4 = 0;
        out->ent[0].e0 = ev[3];
        out->ent[0].e1 = ev[4];
        n++;
        break;
    }
    if (ev[0] != 0xff) do {
        if ((a = RhythmBuf_ReadAlternate()) == 0xffff) {
            ev[0] = 0xff;
            break;
        }
        if ((b = RhythmBuf_ReadAlternate()) == 0xffff) {
            ev[0] = 0xff;
            break;
        }
        if ((c = RhythmBuf_ReadAlternate()) == 0xffff) {
            ev[0] = 0xff;
            break;
        }
        if ((unsigned char)a == 0x90) {
            if ((unsigned char)b == 0x7f) {
                if (n == 0) {
                    ev[0] = 0xb0;
                    ev[1] = (unsigned char)c - 4;
                    out->status = 0xb0;
                    out->one = 4;
                    out->chan = (unsigned char)c - 4;
                    n++;
                } else {
                    ev[0] = 0xb0;
                    ev[1] = (unsigned char)c - 4;
                    ev[3] = b;
                    ev[4] = c;
                    break;
                }
            }
        } else if ((unsigned char)a >= 0x94 && (unsigned char)a <= 0x98 && (unsigned char)b != 0) {
            if ((unsigned char)a == 0x98 && (unsigned char)b >= 0x7d && (unsigned char)b <= 0x7f) {
                Rhythm_DispatchCCCommand((unsigned char)b, (unsigned char)c);
            } else if (n == 0) {
                ev[0] = 0x90;
                ev[1] = ((unsigned char)a & 0xf) - 4;
                out->status = 0x90;
                out->one = 4;
                out->chan = ((unsigned char)a & 0xf) - 4;
                out->ent[n].e4 = 0;
                out->ent[n].e0 = b;
                out->ent[n].e1 = c;
                n++;
            } else if ((unsigned char)(((unsigned char)a & 0xf) - 4) == ev[1] && ev[0] != 0xb0) {
                if (n < 0x20) {
                    out->ent[n].e4 = 0;
                    out->ent[n].e0 = b;
                    out->ent[n].e1 = c;
                }
                n++;
            } else {
                ev[0] = 0x90;
                ev[1] = ((unsigned char)a & 0xf) - 4;
                ev[3] = b;
                ev[4] = c;
                break;
            }
        }
    } while (ev[0] != 0xff);
done:
    if (n <= 0x20)
        return out->count = n;
    Voice_InitTableGroup();
    out->count = 0;
    return 0;
}
