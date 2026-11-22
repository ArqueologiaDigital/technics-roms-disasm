/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_31r1m300a.c (2026-11-22-15-p6-r82)
   sha256 36152464574b76e2940ee3257a7df2a5f0e95d928af16d5d74bb41e1831b0b4c (tar-sha256); compiled at -Xr */
struct hent { unsigned char b; unsigned char n; };
struct hlist { unsigned int count; unsigned int r2; struct hent e[16]; };
extern unsigned char __near HARMONY_REF_NOTE;
extern unsigned char __near HARMONY_REF_BYTE;
extern unsigned char __near HARMONY_PREV_REF_NOTE;
extern unsigned char __near HARMONY_PREV_REF_BYTE;
unsigned char Harmony_FindReferenceNote(struct hlist *p)
{
    unsigned char n;
    unsigned char b;
    unsigned int i;

    HARMONY_PREV_REF_NOTE = HARMONY_REF_NOTE;
    HARMONY_PREV_REF_BYTE = HARMONY_REF_BYTE;
    if (p->count != 0) {
        n = p->e[0].n;
        b = p->e[0].b;
        for (i = 1; i < p->count; i++) {
            if (n > p->e[i].n) {
                n = p->e[i].n;
                b = p->e[i].b;
            }
        }
        if (n > 0x18 && n < 0x67) {
            HARMONY_REF_NOTE = n;
            HARMONY_REF_BYTE = b;
        } else {
            HARMONY_REF_NOTE = 255;
            HARMONY_REF_BYTE = 255;
        }
    } else {
        HARMONY_REF_NOTE = 255;
        HARMONY_REF_BYTE = 255;
    }
    return HARMONY_REF_NOTE;
}
