/* Probe round 33r1, helper V, form a: audio/note_voice_mapping.s (module 296), -Xr code (register variables only
   where the C says `register`: XIZ / IZ in the ROM's pushes, HL for the last value read).
   MidiEvent_ProcessNoteEntry(ev, out): gather a run of note-on / note-off / control events of one channel from the
   sequencer stream (SeqMain_ReadData: status, data 1, data 2; 0xffff = end) into out's five-byte entries (at out + 4,
   the record layout of note_voice_mapping_m298_xr_b.c).  ev is the pending event (status, channel, -, note,
   velocity) carried between calls; 0xff = stream ended.  The velocity takes AUDIO_STATE's fixed velocity (byte 357,
   0xff = off) or offset (signed byte 356, clamped to 1..127).  Returns the entry count (0 and Voice_InitializeAll
   when more than 32 were read).
   RhythmBuf_ParseEventLoop(ev, out): its twin for the rhythm buffer (RhythmBuf_ReadAlternate): 0x90 with data 0x7f
   is a control group, 0x94..0x98 note events (channel = low nibble - 4), 0x98 with data 0x7d..0x7f a CC command. */

struct nent5 { unsigned char e0, e1, e2, e3, e4; };
#define NM_E(r, i) ((struct nent5 *)((unsigned char *)(r) + ((unsigned long)(i) * 5 + 4)))

struct NoteGroup {
    unsigned char status;
    unsigned char count;
    unsigned char one;
    unsigned char chan;
};

extern unsigned char __near AUDIO_STATE[];
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
    if (ev[0] != 0xff) {
        if (ev[0] != 0) {
            out->status = ev[0];
            out->one = 1;
            out->chan = ev[1];
            NM_E(out, 0)->e4 = 0;
            NM_E(out, 0)->e0 = ev[3];
            NM_E(out, 0)->e1 = ev[4];
            n++;
        }
        if (ev[0] != 0xff) do {
            st = SeqMain_ReadData();
            if (st == 0xffff) {
                ev[0] = 0xff;
                break;
            }
            d1 = SeqMain_ReadData();
            if (d1 == 0xffff) {
                ev[0] = 0xff;
                break;
            }
            v = SeqMain_ReadData();
            if (v == 0xffff) {
                ev[0] = 0xff;
                break;
            }
            if (v != 0) {
                if (AUDIO_STATE[357] != 255) {
                    v = AUDIO_STATE[357];
                } else if ((signed char)AUDIO_STATE[356] > 0) {
                    if ((unsigned char)((signed char)AUDIO_STATE[356] + v) > 0x7f)
                        v = 0x7f;
                    else
                        v += (signed char)AUDIO_STATE[356];
                } else {
                    if ((signed char)((signed char)AUDIO_STATE[356] + v) < 0)
                        v = 1;
                    else
                        v += (signed char)AUDIO_STATE[356];
                }
            }
            if ((st & 0xf0) == 0xb0) {
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
                NM_E(out, n)->e4 = 0;
                NM_E(out, n)->e0 = d1;
                if ((st & 0xf0) == 0x80)
                    NM_E(out, n)->e1 = 0;
                else
                    NM_E(out, n)->e1 = v;
                n++;
            } else if ((st & 0xf) == ev[1] && ev[0] != 0xb0) {
                if (n < 0x20) {
                    NM_E(out, n)->e4 = 0;
                    NM_E(out, n)->e0 = d1;
                    if ((st & 0xf0) == 0x80)
                        NM_E(out, n)->e1 = 0;
                    else
                        NM_E(out, n)->e1 = v;
                }
                n++;
            } else {
                ev[0] = 0x90;
                ev[1] = st & 0xf;
                ev[3] = d1;
                if ((st & 0xf0) == 0x80)
                    ev[4] = 0;
                else
                    ev[4] = v;
                break;
            }
        } while (ev[0] != 0xff);
    }
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
    if (ev[0] != 0xff) {
        if (ev[0] != 0) {
            out->status = ev[0];
            out->one = 4;
            out->chan = ev[1];
            NM_E(out, 0)->e4 = 0;
            NM_E(out, 0)->e0 = ev[3];
            NM_E(out, 0)->e1 = ev[4];
            n++;
        }
        if (ev[0] != 0xff) do {
            a = RhythmBuf_ReadAlternate();
            if (a == 0xffff) {
                ev[0] = 0xff;
                break;
            }
            b = RhythmBuf_ReadAlternate();
            if (b == 0xffff) {
                ev[0] = 0xff;
                break;
            }
            c = RhythmBuf_ReadAlternate();
            if (c == 0xffff) {
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
                    NM_E(out, n)->e4 = 0;
                    NM_E(out, n)->e0 = b;
                    NM_E(out, n)->e1 = c;
                    n++;
                } else if ((unsigned char)(((unsigned char)a & 0xf) - 4) == ev[1] && ev[0] != 0xb0) {
                    if (n < 0x20) {
                        NM_E(out, n)->e4 = 0;
                        NM_E(out, n)->e0 = b;
                        NM_E(out, n)->e1 = c;
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
    }
    if (n <= 0x20)
        return out->count = n;
    Voice_InitTableGroup();
    out->count = 0;
    return 0;
}
