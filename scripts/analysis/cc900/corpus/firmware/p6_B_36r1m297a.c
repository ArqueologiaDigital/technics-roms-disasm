/* Probe round 36r1, helper B, form a: audio/note_voice_mapping.s (module 297), unoptimised -Xr shape.
   PopRetFA_StoreAE3_Prologue(r, x, e): the pointer-record twin of NoteMap_ProcessNoteEvent (helper C's
   p6_C_36r1m297*.c): the looked-up record r arrives as a pointer (frame +6), the voice block x is a `register`
   parameter (XIZ), the key e is on the frame (+4).  For e == 0x15: tune, find entry 0, allocate voices 0 / 1 (and
   2 when the harmony list has a best match) on slot 2 / 3, then emit note-on 1 when x[3] is 0.  Otherwise, for
   e == x[182]: tune, find entry 2, claim a slot and assign / init voice 2 on slot 2 / 3, else assign voice 2 and
   clear the two allocator cells; then the common tail: tune, add the entry, set the channel parameter when the
   channel map says so, emit MIDI for the mapped voice (a `register` char: C, not live across a call) when its
   pair flag 0x20 is set, and emit note-on 0 when e == x[2]. */
/* cc900-module: NoteMap_AllocateVoice NoteMap_AssignVoiceParams NoteMap_InitVoiceSlots */

struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
struct xpair { unsigned char f0, f1; };
struct vx { unsigned char pad[0x124]; struct xpair pr[128]; };
extern unsigned int __near HARMONY_NOTE_LIST;
extern unsigned int __near ram_ce66;
extern unsigned char __near ram_ceb2;
extern void SndParam_ComputeVoiceTuning(struct nrec *, struct vx *, unsigned char);
extern void NoteMap_FindEntry(struct nrec *, unsigned int);
extern unsigned char NoteMap_FindBestVoiceSlot(struct nrec *);
extern unsigned char NoteMap_FindBestFreeVoice(struct nrec *);
extern unsigned char NoteMap_FindBestMatch(void);
extern unsigned char VoiceMap_AllocateSlot(void);
extern void NoteMap_AllocateVoice(struct vx *, unsigned int);
extern void NoteMap_AssignVoiceParams(struct vx *, unsigned int);
extern void NoteMap_InitVoiceSlots(struct vx *, unsigned int);
extern void NoteMap_EmitNoteOnEvents(struct nrec *, unsigned int);
extern void NoteMap_AllocNewVoiceEntry(struct nrec *, unsigned int);
extern void NoteMap_SetChannelParam(struct nrec *, unsigned int);
extern void Voice_ScanAndEmitMidiEvents(struct nrec *, unsigned int);
extern void PopRetFA_StoreAE3_Prologue(struct nrec *r, struct vx *x, unsigned char e);

void PopRetFA_StoreAE3_Prologue(struct nrec *r, register struct vx *x, unsigned char e)
{
    register unsigned char v;

    if (e == 0x15) {
        SndParam_ComputeVoiceTuning(r, x, e);
        NoteMap_FindEntry(r, 0);
        switch (NoteMap_FindBestVoiceSlot(r)) {
        case 2:
        case 3:
            NoteMap_AllocateVoice(x, 0);
            NoteMap_AllocateVoice(x, 1);
            if (HARMONY_NOTE_LIST != 0 && NoteMap_FindBestMatch() != 0xff)
                NoteMap_AllocateVoice(x, 2);
            break;
        }
        if (x->pad[3] == 0)
            NoteMap_EmitNoteOnEvents(r, 1);
        return;
    }
    if (e == x->pad[182]) {
        SndParam_ComputeVoiceTuning(r, x, e);
        NoteMap_FindEntry(r, 2);
        switch (NoteMap_FindBestFreeVoice(r)) {
        case 2:
        case 3:
            if (VoiceMap_AllocateSlot() != 0xff) {
                NoteMap_AssignVoiceParams(x, 2);
                NoteMap_InitVoiceSlots(x, 2);
            }
            break;
        default:
            NoteMap_AssignVoiceParams(x, 2);
            ram_ce66 = 0;
            ram_ceb2 = 0;
            break;
        }
    }
    SndParam_ComputeVoiceTuning(r, x, e);
    NoteMap_AllocNewVoiceEntry(r, e);
    if (x->pad[(unsigned long)((unsigned int)r->b3 + 0x94)] == e)
        NoteMap_SetChannelParam(r, e);
    v = x->pad[(unsigned long)((unsigned int)r->b3 + 0xa4)];
    if (v != 0xff && (x->pr[e].f0 & 0x20))
        Voice_ScanAndEmitMidiEvents(r, v);
    if (e == x->pad[2])
        NoteMap_EmitNoteOnEvents(r, 0);
}
