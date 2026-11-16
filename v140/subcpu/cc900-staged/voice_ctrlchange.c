/* Functions of core/07_voice_ctrlchange.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

int Voice_Pitch_ClampRange(int a, int hi, int lo)
{
    if (a < lo) a = lo;
    else if (a > hi) a = hi;
    return a;
}

#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern unsigned char ram_41322[];
extern unsigned char ram_41335[];
extern unsigned char ram_41336[];
struct pkt { unsigned char op; unsigned char key[2]; unsigned char mask[2]; };
extern struct pkt __near ram_2a5e;
void NoteOn_RoutePacket(struct pkt *q);
void Voice_NoteState_Clear(int n);
void Voice_SetLFO_ActiveFlag(int n);
void WaveSel_Rebuild_PartCaches(int n, int a, int b);
void VoiceSlot_FullInit(int n);
void VoiceSlot_AltInit(int n);
void Voice_PortamentoTargets_SetAll(int n);
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
    WaveSel_Rebuild_PartCaches(n, ram_41335[n * 287], ram_41336[n * 287]);
    switch ((*(unsigned char **)&ram_41322[n * 287])[16] & 0xc0) {
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

unsigned int Voice_KeyIndex_Pack3Nibbles(unsigned int a)
{
    unsigned int r;
    r = ((a >> 8) & 0xf) * 81;
    r += ((a >> 4) & 0xf) * 9;
    r += a & 0xf;
    return r;
}
