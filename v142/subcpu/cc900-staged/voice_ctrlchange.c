/* Functions of core/07_voice_ctrlchange.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function at -Xr (notes/cc900-c-subcpu-2026-11-16/);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   cc900-options: -Xr */
int Voice_Pitch_ClampRange(int a, int hi, int lo)
{
    if (a < lo) a = lo;
    else if (a > hi) a = hi;
    return a;
}

#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern unsigned char ram_4136e[];
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];
struct pkt { unsigned char op; unsigned char key[2]; unsigned char mask[2]; };
extern struct pkt __near ram_2a5e;
void WaveSel_Rebuild_PartCaches(int n, int a, int b);
void ToneGen_WriteLevelBurst(int n, unsigned char *blk);
void ToneGen_WriteVoiceParams(int n, unsigned char *blk);
void Voice_WriteChPanShift2(unsigned char *v, int s);
void Voice_WriteChPanShift(unsigned char *v, int s);
#define PKW(q, o) (*(unsigned int *)((unsigned char *)(q) + (o)))

struct pkt *Voice_Allocate(unsigned char part, unsigned char key)
{
    struct pkt *q = &ram_2a5e;
    q->op = 0x80;
    PKW(q, 1) = ((unsigned int)part << 8 | key) | 0x80;
    PKW(q, 3) = 0;
    NoteOn_RoutePacket(q);
    return q;
}

struct pkt *Voice_AllocateForRelease(unsigned char part)
{
    struct pkt *q = &ram_2a5e;
    q->op = 0x80;
    PKW(q, 1) = (unsigned int)part << 8 | 0x80;
    PKW(q, 3) = 0x7f;
    NoteOn_RoutePacket(q);
    return q;
}

struct pkt *Voice_AllocateForSustain(unsigned char part)
{
    struct pkt *q = &ram_2a5e;
    q->op = 0x40;
    PKW(q, 1) = (unsigned int)part << 8;
    PKW(q, 3) = 0x7f;
    NoteOn_RoutePacket(q);
    return q;
}

void Voice_PerVoice_PortamentoPitchUpdate(unsigned char n)
{
    Voice_NoteState_Clear(n);
    Voice_SetLFO_ActiveFlag(n);
    WaveSel_Rebuild_PartCaches(n, ram_41381[n * 287], ram_41382[n * 287]);
    switch ((*(unsigned char **)&ram_4136e[n * 287])[16] & 0xc0) {
    case 0:
    case 0xc0:
        VoiceSlot_FullInit(n);
        break;
    case 0x40:
        Voice_PortamentoTargets_SetAll(n);
        VoiceSlot_AltInit(n);
        break;
    case 0x80:
        break;
    }
}

struct pkt *Voice_Query_AllChannels(void)
{
    struct pkt *q = &ram_2a5e;
    q->op = 0;
    PKW(q, 1) = 0;
    PKW(q, 3) = 0x1fff;
    NoteOn_RoutePacket(q);
    return q;
}

struct pkt *Voice_Query_PartVoices(unsigned char part)
{
    struct pkt *q = &ram_2a5e;
    q->op = 0;
    PKW(q, 1) = (unsigned int)part << 8;
    PKW(q, 3) = 0xff;
    NoteOn_RoutePacket(q);
    return q;
}

struct pkt *Voice_Query_PartVoices_Mask7F(unsigned char part)
{
    struct pkt *q = &ram_2a5e;
    q->op = 0;
    PKW(q, 1) = (unsigned int)part << 8 | 0x80;
    PKW(q, 3) = 0x7f;
    NoteOn_RoutePacket(q);
    return q;
}

void Voice_Slot_LoadPitchOffset_A(unsigned char *v) { SW(v, 13) += SW(P(v, 35), 270); }

void Voice_Slot_LoadPitchOffset_B(unsigned char *v) { SW(v, 13) += SW(P(v, 35), 272); }
