/* Phase 6, lane_p6 helper I, round 1, module 283 (audio/sndparam_routines.s, a -Xr file), form a.  All new.
   The sound-parameter hash table at 0x34100 (SNDPARAM_HASH_TABLE, 2047 slots of {key, record}, empty key 0xffffff,
   linear probing by 3):
   - SndParam_LookupByKey(key, a, b): finds the record, calls its write handler SndParam_Register2Handlers[rec[14]]
     (rec, a, b) and, by the result's kind, notifies the widget (SndParam_WidgetNotifyType0/1 (b, result): the
     result stays in XBC from the handler call).  Returns 0, or -1 when not found / refused.
   - SndParam_LookupReadOnly(key): calls the read handler SndParam_ReadHandlers[rec[12]](rec); -1 when absent.
   - SndParam_InsertEntry(key, rec): first empty slot gets {key, rec}; -1 when the key exists or the table is full.
   - SndParam_HeapAlloc(n): bump allocator over the 16 KB block at 0x380f8 (a used count, then the bytes).
   Read from the hand assembly: the hash is two multiply-by-513 steps written as (h << 9) + h (shift + add, no
   runtime call), the key in XIZ, the slot index in IX and the probe count in HL (both start at the hash: `i = n =`),
   the key compare `(key == k ? 0 : -1) != -1` (the ROM materialises 0 / -1 in BC and branches around the test on
   the -1 path).  The probe loop is entered at its test (goto); form b writes it as a plain while, and the
   not-found exits of LookupByKey with gotos. */
/* cc900-module: SndParam_WidgetNotifyType0 SndParam_WidgetNotifyType1 */

#define HASHTAB ((struct hent *)0x34100L)
#define EMPTY 0xffffffL

struct sp { unsigned char f0[12]; unsigned char rtype; unsigned char f13; unsigned char wtype; unsigned char f15; };
struct hent { unsigned long key; struct sp *val; };
struct wres { int a; int kind; };
struct sheap { unsigned int used; unsigned char data[0x4000]; };

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
    e = 0;
    h = key & 0xff;
    h = (h << 9) + h + ((key >> 8) & 0xff);
    h = (h << 9) + h + ((key >> 16) & 0x1f);
    i = n = h % 0x7ff;
    goto test;
    do {
        if ((key == k ? 0 : -1) != -1)
            e = p->val;
        if (++n > 0x7ff)
            break;
        i = (i + 3) % 0x7ff;
test:   ;
    } while ((k = (p = &HASHTAB[i])->key) != EMPTY);
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
    e = 0;
    h = key & 0xff;
    h = (h << 9) + h + ((key >> 8) & 0xff);
    h = (h << 9) + h + ((key >> 16) & 0x1f);
    i = n = h % 0x7ff;
    goto test;
    do {
        if ((key == k ? 0 : -1) != -1)
            e = p->val;
        if (++n > 0x7ff)
            break;
        i = (i + 3) % 0x7ff;
test:   ;
    } while ((k = (p = &HASHTAB[i])->key) != EMPTY);
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
    h = (h << 9) + h + ((key >> 8) & 0xff);
    h = (h << 9) + h + ((key >> 16) & 0x1f);
    i = h % 0x7ff;
    do {
        if ((k = (p = &HASHTAB[i])->key) == EMPTY) {
            p->key = key;
            p->val = rec;
            return 0;
        }
        if ((key == k ? 0 : -1) != -1)
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
    p = &ram_380f8.data[ram_380f8.used];
    ram_380f8.used += n;
    return p;
}
