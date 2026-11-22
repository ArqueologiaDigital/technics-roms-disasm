/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_X_34r1m296b.c (2026-11-22-21-p6-r88)
   sha256 186de314c7b6e2073b3f5a82f070411c7157c9ddbe5483d0a2540f49a8eebe5f (tar-sha256); compiled at -Xr */
struct nent5 { unsigned char e0, e1, e2, e3, e4; };
struct NoteGroup {
    unsigned char status;
    unsigned char count;
    unsigned char one;
    unsigned char chan;
    struct nent5 ent[32];
};
#define NM_E(r, i) ((struct nent5 *)(((unsigned long)(i) * 5 + 4) + (unsigned char *)(r)))
extern unsigned char __near AUDIO_STATE[];
extern unsigned int SeqMain_ReadData(void);
extern void Voice_InitializeAll(void);
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
            if (AUDIO_STATE[357] != 255) {
                v = AUDIO_STATE[357];
            } else if (((signed char *)AUDIO_STATE)[356] > 0) {
                if ((unsigned char)(((signed char *)AUDIO_STATE)[356] + v) > 0x7f)
                    v = 0x7f;
                else
                    v += ((signed char *)AUDIO_STATE)[356];
            } else {
                if ((signed char)(((signed char *)AUDIO_STATE)[356] + v) < 0)
                    v = 1;
                else
                    v += ((signed char *)AUDIO_STATE)[356];
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
            NM_E(out, n)->e4 = 0;
            NM_E(out, n)->e0 = d1;
            if (((unsigned char)st & 0xf0) == 0x80)
                NM_E(out, n)->e1 = 0;
            else
                NM_E(out, n)->e1 = v;
            n++;
        } else if (((unsigned char)st & 0xf) == ev[1] && ev[0] != 0xb0) {
            if (n < 0x20) {
                NM_E(out, n)->e4 = 0;
                NM_E(out, n)->e0 = d1;
                if (((unsigned char)st & 0xf0) == 0x80)
                    NM_E(out, n)->e1 = 0;
                else
                    NM_E(out, n)->e1 = v;
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
