/* FORM B of p6_I_3m283a.c: the key compare as the inline `(key != k ? -1 : 0) != -1` (no int c).
   Form a's notes follow.
   Phase 6, lane_p6 helper I, round 3, module 283 (audio/sndparam_routines.s), form a.  Refines round 1
   (p6_I_1m283a/b.c; run 2026-11-18-12-p6-r35: LookupReadOnly +4, LookupByKey +10, InsertEntry +14, HeapAlloc +26
   at O3Xr).  What the listings showed against the ROM, and what this round changes:
   - V4.23 gave XIZ to the found record e and spilled the key to the frame; the ROM keeps the key in XIZ and e in the
     frame (+6, above r at +4).  Here e is pinned to the frame with a no-code `&e;`.
   - The hash step: V4.23 evaluated ((key >> 8) & 0xff) first and added (h << 9) into h's register; the ROM builds
     h + (h << 9) in a fresh register first, then loads the byte into h's register and adds.  Here the step is
     c + (h + (h << 9)) (V4.23 evaluates the right operand first).
   - The key compare: V4.23 kept the 0 / -1 in A (byte) and loaded -1 first; the ROM keeps it in BC / WA (16-bit)
     and loads 0 first.  Here it is an int variable set by `key != k ? -1 : 0` (form b: the inline expression).
   - The slot address: the ROM computes the index first and adds the table base as an immediate (lane_hd's
     converted pointer): `p = (void *)(SNDPARAM_HASH_TABLE + i)`, the key read into its own variable.
   - SndParam_HeapAlloc: one spot, the ROM widens the used count to 32 bits before adding the data offset 2 (extz
     xde; inc 2,xde; ld + add): the index cast to unsigned long.
   Form c: as form a with round 1's hash order ((h << 9) + h + c). */
/* cc900-module: SndParam_WidgetNotifyType0 SndParam_WidgetNotifyType1 */

#define EMPTY 0xffffffL

struct sp { unsigned char f0[12]; unsigned char rtype; unsigned char f13; unsigned char wtype; unsigned char f15; };
struct hent { unsigned long key; struct sp *val; };
struct wres { int a; int kind; };
struct sheap { unsigned int used; unsigned char data[0x4000]; };

extern struct hent SNDPARAM_HASH_TABLE[];
extern struct wres *(*SndParam_Register2Handlers[])(struct sp *, int, int);
extern int (*SndParam_ReadHandlers[])(struct sp *);
extern struct sheap ram_380f8;
extern void SndParam_WidgetNotifyType0(int, struct wres *);
extern void SndParam_WidgetNotifyType1(int, struct wres *);
extern int SndParam_LookupByKey(unsigned long key, int a, int b);
extern int SndParam_LookupReadOnly(unsigned long key);
extern int SndParam_InsertEntry(unsigned long key, struct sp *rec);
extern unsigned char *SndParam_HeapAlloc(unsigned int n);

int SndParam_LookupByKey(unsigned long key, int a, int b)
{
    int r;
    struct sp *e;
    unsigned long h;
    unsigned int i;
    unsigned int n;
    struct hent *p;
    unsigned long k;
    struct wres *w;

    r = 0;
    &e;
    e = 0;
    h = key & 0xff;
    h = ((key >> 8) & 0xff) + (h + (h << 9));
    h = ((key >> 16) & 0x1f) + (h + (h << 9));
    i = n = h % 0x7ff;
    goto test;
loop:
    if ((key != k ? -1 : 0) != -1)
        e = p->val;
    if (++n > 0x7ff)
        goto done;
    i = (i + 3) % 0x7ff;
test:
    p = (void *)(SNDPARAM_HASH_TABLE + i);
    k = p->key;
    if (k != EMPTY)
        goto loop;
done:
    if (e != 0 && e->wtype < 8 && (w = (*SndParam_Register2Handlers[e->wtype])(e, a, b))->a != -1) {
        switch (w->kind) {
        case 0:
            SndParam_WidgetNotifyType0(b, w);
            break;
        case 1:
            SndParam_WidgetNotifyType1(b, w);
            break;
        }
    } else
        r = -1;
    return r;
}

int SndParam_LookupReadOnly(unsigned long key)
{
    int r;
    struct sp *e;
    unsigned long h;
    unsigned int i;
    unsigned int n;
    struct hent *p;
    unsigned long k;

    r = -1;
    &e;
    e = 0;
    h = key & 0xff;
    h = ((key >> 8) & 0xff) + (h + (h << 9));
    h = ((key >> 16) & 0x1f) + (h + (h << 9));
    i = n = h % 0x7ff;
    goto test;
loop:
    if ((key != k ? -1 : 0) != -1)
        e = p->val;
    if (++n > 0x7ff)
        goto done;
    i = (i + 3) % 0x7ff;
test:
    p = (void *)(SNDPARAM_HASH_TABLE + i);
    k = p->key;
    if (k != EMPTY)
        goto loop;
done:
    if (e != 0 && e->rtype < 7)
        r = (*SndParam_ReadHandlers[e->rtype])(e);
    return r;
}

int SndParam_InsertEntry(unsigned long key, struct sp *rec)
{
    unsigned int n;
    unsigned long h;
    unsigned int i;
    struct hent *p;
    unsigned long k;

    n = 0;
    h = key & 0xff;
    h = ((key >> 8) & 0xff) + (h + (h << 9));
    h = ((key >> 16) & 0x1f) + (h + (h << 9));
    i = h % 0x7ff;
    do {
        p = (void *)(SNDPARAM_HASH_TABLE + i);
        k = p->key;
        if (k == EMPTY) {
            p->key = key;
            p->val = rec;
            return 0;
        }
        if ((key != k ? -1 : 0) != -1)
            break;
        if (++n > 0x7ff)
            break;
        i = (i + 3) % 0x7ff;
    } while (i < 0x7ff);
    return -1;
}

unsigned char *SndParam_HeapAlloc(unsigned int n)
{
    unsigned char *p;

    if (n == 0 || ram_380f8.used + n >= 0x4000)
        return 0;
    p = &ram_380f8.data[(unsigned long)ram_380f8.used];
    ram_380f8.used += n;
    return p;
}
