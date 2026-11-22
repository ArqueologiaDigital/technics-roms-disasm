/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_31r1m300b.c (2026-11-22-15-p6-r82)
   sha256 7dcaaf853acedf5e9241f2ec470d8b44cfa7436cb04a64c3e1800a6716f39032 (tar-sha256); compiled at -Xr */
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
        i = 1;
        if (i < p->count) do {
            if (n > p->e[i].n) {
                n = p->e[i].n;
                b = p->e[i].b;
            }
            i++;
        } while (i < p->count);
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
