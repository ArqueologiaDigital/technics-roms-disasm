/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_V_33r1m296a.c (2026-11-22-19-p6-r86)
   sha256 073312417ab6dc5745f4527723f4c61ad67008524de3806363c70e7b327f6824 (tar-sha256); compiled at -Xr */
struct nent5 { unsigned char e0, e1, e2, e3, e4; };
#define NM_E(r, i) ((struct nent5 *)((unsigned char *)(r) + ((unsigned long)(i) * 5 + 4)))
struct NoteGroup {
    unsigned char status;
    unsigned char count;
    unsigned char one;
    unsigned char chan;
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
