/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_X_34r1m296a.c (2026-11-22-21-p6-r88)
   sha256 d573aa32c397621b3ccd3b30af5acb6a5773caf2c4554b250f0487401e153a0f (tar-sha256); compiled at -Xr */
struct nent5 { unsigned char e0, e1, e2, e3, e4; };
struct NoteGroup {
    unsigned char status;
    unsigned char count;
    unsigned char one;
    unsigned char chan;
    struct nent5 ent[32];
};
extern unsigned int RhythmBuf_ReadAlternate(void);
extern void Voice_InitTableGroup(void);
extern void Rhythm_DispatchCCCommand();
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
