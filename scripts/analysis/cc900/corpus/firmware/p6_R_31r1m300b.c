/* Probe round 31r1, helper R, form b (the loop's test copied to its entry by hand, for -Xr): audio/note_voice_mapping.s Harmony_FindReferenceNote (module 300, the caller
   VoiceMap_AllocateSlot is built in cc900/note_voice_mapping_m300_xr.c, -Xr).  The lowest note of a counted list of
   (byte, note) pairs becomes HARMONY_REF_NOTE if it lies in 25..102, else 0xff. */

struct hent { unsigned char b; unsigned char n; };
struct hlist { unsigned int count; unsigned int r2; struct hent e[16]; };
extern unsigned char __near HARMONY_REF_NOTE;
extern unsigned char __near HARMONY_REF_BYTE;
extern unsigned char __near HARMONY_PREV_REF_NOTE;
extern unsigned char __near HARMONY_PREV_REF_BYTE;
extern unsigned char Harmony_FindReferenceNote(struct hlist *p);

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
