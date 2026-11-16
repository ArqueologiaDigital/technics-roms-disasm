/* Phase 6, lane_p6 helper A, round 8, form b: big routines of v10 audio/note_voice_mapping.s under their firmware names. */
/* p: a part record, count at +1 and 5-byte entries from +4; q: the sound record, two-byte transpose pairs at +0x124. */
struct vpart { unsigned char f0, count, f2, f3; unsigned char ent[32][5]; };

void Voice_SetTransposeAndAlloc(struct vpart *p, unsigned char *q, unsigned char e)
{
    char h, l, s;
    unsigned int i;
    s = ((char *)q + (e * 2 + 0x124))[1] >> 4;
    l = (char)((char)(q[e * 2 + 0x124] << 4) >> 5) * 12 + s;
    for (i = 0; i < p->count; i++) {
        p->ent[i][4] = 0;
        if (p->ent[i][1] == 0)
            continue;
        {
            h = p->ent[i][0];
            p->ent[i][2] = h;
            if (l != 0) {
                h += l;
                if ((unsigned char)h <= 0x7f)
                    goto store;
                if (l > 0) {
                    while ((unsigned char)h > 0x7f)
                        h -= 12;
                } else {
                    while (h < 0)
                        h += 12;
                }
            }
        store:
            if ((unsigned char)h >= 0x78)
                h = -1;
            p->ent[i][3] = h;
        }
    }
}

struct vsent { unsigned char a, b; };
struct vslot { unsigned int count; unsigned int layer; struct vsent e[32]; };
extern struct vslot *NoteMap_VoiceSlotRamPtrs[];
extern void NoteMap_AllocNewVoiceEntry(struct vpart *, unsigned char);
extern void NoteMap_SetChannelParam(struct vpart *, unsigned char);
extern void Voice_ScanAndEmitMidiEvents(struct vpart *, unsigned char);

/* snd: the sound record; ch: the part.  The 164-byte working record is a local (frame of 172 bytes in the ROM). */
void NoteMap_InitVoiceSlots(unsigned char *snd, unsigned char ch)
{
    struct vslot *s;
    struct vpart v;
    unsigned char k;
    unsigned int i;
    unsigned char e;
    k = snd[ch + 0xbc];
    if (k == 0xff)
        return;
    s = NoteMap_VoiceSlotRamPtrs[ch];
    if (s->count == 0)
        return;
    v.count = s->count;
    v.f0 = 0x90;
    v.f2 = 6;
    v.f3 = ch;
    for (i = 0; i < s->count; i++) {
        v.ent[i][0] = s->e[i].b;
        v.ent[i][1] = s->e[i].a;
        v.ent[i][4] = 0;
    }
    Voice_SetTransposeAndAlloc(&v, snd, k);
    NoteMap_AllocNewVoiceEntry(&v, k);
    if (s->layer != 0 || snd[k + 4] != 0xff)
        NoteMap_SetChannelParam(&v, k);
    if (s->layer != 1) {
        e = snd[k + 0x24];
        if (e != 0xff && (snd[k * 2 + 0x124] & 0x20) != 0 && (ch != 2 || (snd[342] & 0x20) != 0))
            Voice_ScanAndEmitMidiEvents(&v, e);
    }
}

struct nvrec { unsigned char f0, f1, f2, f3, f4, f5, f6, f7; };
struct nvlnk { unsigned char next, prev; };
struct hnote { unsigned char y, x; };
struct harm { unsigned int count; unsigned int best; struct hnote note[16]; };
extern struct harm __near HARMONY_NOTE_LIST;

/* Voice records (8 bytes) at 0xca7a, their chain links at 0xe971 (list head 0x23), the harmony list at 0xce22. */
void NoteMap_FindBestFreeVoice(unsigned char *p)
{
    unsigned int n;
    unsigned char h, l, c;
    n = 0;
    h = 0x23;
    l = 0xff;
    while ((h = ((struct nvlnk *)0xe971)[h].next) != 0x23) {
        c = ((struct nvrec *)0xca7a)[h].f0;
        switch (c) {
        case 3:
            l = 2;
            break;
        case 2:
            if (l == 3)
                break;
            l = 2;
            break;
        case 1:
            if (l == 3 || l == 2)
                break;
            l = 1;
            break;
        case 0:
            if (l == 3 || l == 2 || l == 1)
                break;
            l = 0;
            break;
        }
    }
    if (l == 0xff) {
        l = p[2];
    } else {
        h = 0x23;
        while ((h = ((struct nvlnk *)0xe971)[h].next) != 0x23) {
            if (((struct nvrec *)0xca7a)[h].f0 == l) {
                HARMONY_NOTE_LIST.note[n].x = ((struct nvrec *)0xca7a)[h].f5 & 0x7f;
                HARMONY_NOTE_LIST.note[n].y = ((struct nvrec *)0xca7a)[h].f3;
                n++;
            }
        }
    }
    HARMONY_NOTE_LIST.count = n;
    HARMONY_NOTE_LIST.best = l;
}

extern unsigned char SoundRam_Id_KN5000[], SoundRam_Id_KN1500[], SoundRam_Id_KN3000[];
extern unsigned char SoundRam_Id_KN2000[], SoundRam_Id_MKA[], SoundRam_Id_MKB[];

unsigned char SoundRam_IdentifyImage(unsigned char *p)
{
    unsigned int i;
    unsigned char *q;
    q = SoundRam_Id_KN5000;
    i = 0;
    do {
        if (p[i] != q[i])
            break;
        i++;
    } while (i < 16);
    if (i == 16)
        return 6;
    q = SoundRam_Id_KN1500;
    i = 0;
    do {
        if (p[i] != q[i])
            break;
        i++;
    } while (i < 16);
    if (i == 16)
        return 5;
    q = SoundRam_Id_KN3000;
    i = 0;
    do {
        if (p[i] != q[i])
            break;
        i++;
    } while (i < 16);
    if (i == 16)
        return 4;
    q = SoundRam_Id_KN2000;
    for (i = 0; i < 6; i++)
        if (p[i + 5] != q[i])
            break;
    if (i == 6)
        return 1;
    q = SoundRam_Id_MKA;
    for (i = 0; i < 3; i++)
        if (p[i + 5] != q[i])
            break;
    if (i == 3)
        return 2;
    q = SoundRam_Id_MKB;
    for (i = 0; i < 3; i++)
        if (p[i + 5] != q[i])
            break;
    if (i == 3)
        return 3;
    return 0;
}

