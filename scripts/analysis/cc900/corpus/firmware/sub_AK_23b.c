/* lane_sub helper AK, round 23, form b: form a changed only in these spellings --
   Voice_ChanPressure: idiom (a), a second local takes m[1] (u = m[1]; part = u;) and the switch reads u; the record
     address as &pr[(int)i * 3 + 0x23];
   Voice_SetPitch / Voice_NoteOff: the callees declared without prototypes (default promotions); the slot test as an
     early `if (s >= 0x40) return;`;
   Voice_Allocate_Nodes: idiom (a) for the class pointer (c2 = ...; cls = c2; Find(list, *c2)); cls an unsigned char
     pointer and its byte +4 passed as (char)cls[4]; the pool argument as (unsigned char *)(void *)ram_130d;
   ExtVoice_Alloc_StreamSlot: lim declared before s; lim + 8 without the int cast; the second Lookup_SlotFallback
     result assigned in a statement before its test; the packed result written r | (unsigned int)e << 8.
   Form a's notes follow.
   lane_sub helper AK, round 23, form a (KN5000 sub-CPU payload v1.42).  Pool A functions never compiled before,
   written from the hand source (core/05, core/07) and the ROM bytes:
   - Voice_ChanPressure: Voice_ModWheel_Apply's switch shape; part = m[1] assigned inside the switch expression (the
     ROM stores it and goes on with A, no reload); the loop counter a byte (the ROM keeps it in QIZH); the record
     offset as a 16-bit int, pr + ((int)i * 3 + 0x23);
   - Voice_SetPitch / Voice_NoteOff: the 14-byte request record on the stack for Voice_NoteOn_Rhythm, the slot it
     returns (record +10 / +11) a byte local (QIZH in the ROM), the two tone-generator writes as in
     ToneGen_SilenceChannel (inline nop / jr $+2), callees with unsigned char parameters (V4.23 extends them);
   - Voice_Allocate_Nodes: part a byte local (QIZH), the node pointer n (XIZ), the class pointer cls assigned inside
     Voice_Find_Candidate's argument (no reload in the ROM), cls a plain-char pointer so its byte +4 goes to
     Voice_List_MoveToPool's unsigned char parameter unextended while n[33] is extended; u / q as in
     Voice_Retire_ToFreePool for the quota test;
   - ExtVoice_Alloc_StreamSlot: s, lim byte locals (QIZH / QIZL), idx on the stack, the result byte r (L in the
     ROM), q the 5-byte row pointer; ram_24e6 / ram_2126 as 2-D arrays; the note-source table read with an
     unsigned index on a (unsigned long)-cast row (offset first, widened, 32-bit add).
   All inline nop / jr $+2 are written with the lower-case __asm keyword (lane_sub's run 2026-11-19-8 finding:
   V4.23 then treats the block as clobbering the scratch registers, as the ROM's tone-generator writers need).
   Skipped: Voice2_UpdatePitch, Voice_StereoLevel_Compute, Voice_Pitch_Compute keep an int in IZ (pushw iz):
   they need the IZ pseudo-register (bug candidate 12).
   cc900-options: -Xr
*/

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
extern unsigned char ram_4136a[];
extern unsigned char ram_4136e[];
extern unsigned char ram_430bb[];
extern unsigned char * __near ram_1129;
extern unsigned char __near ram_1349[];
extern unsigned char __near ram_130d[];
extern unsigned int __near ram_2936[];
extern unsigned int __near ram_292e[];
extern unsigned char __near ram_24e6[][12];
extern unsigned char __near ram_2126[][5];
extern unsigned char __near ram_1e4d[];
extern unsigned char Voice_LayerClassTable[];
extern unsigned char Voice_PolyphonyLimits_Table[];
extern unsigned char Voice_IndexMapping_Table[];

int AudioChannel_Dispatch(int a, unsigned int b, unsigned char *d);
void Voice_ChanPressure(unsigned char *m);

void Voice_Env_ApplyVelocity_Type0();
void Voice_Env_UpdVelCounters();
void Voice_NoteOn_Rhythm();
void Voice_Init_Type1();
void ToneGen_WriteSingleReg();
void VoiceSlot_NoteOff();
void Voice_SetPitch(unsigned char part, unsigned char key, unsigned char vel, unsigned char w);
void Voice_NoteOff(unsigned char part, unsigned char key, unsigned char vel, unsigned char w);

void RingBuf_CheckOffset_ClearFlags(unsigned char *p);
unsigned char *Voice_Find_Candidate(unsigned char *list, unsigned char *s);
unsigned char *Voice_FindStealCandidate(unsigned char *p);
void Voice_List_MoveToPool(unsigned char *n, unsigned char *list, unsigned char k);
void Voice_List_MoveToPartList(unsigned char *n, unsigned char *list, unsigned char k);
void DList_Relink_Adjacent_Offsets16(unsigned char *p, unsigned char *q);
void DList_Unlink_SelfLink_Offsets16(unsigned char *p);
void Voice_ScanSlots_ReassignSources(unsigned char a);
void Voice_Allocate_Nodes(unsigned char *v);

unsigned char ExtVoice_Fold_SlotNumber(unsigned char s, unsigned char lim);
unsigned char ExtVoice_Lookup_SlotFallback(unsigned char lim);
void VoiceSlot_UpdateNoteSource(unsigned char s, unsigned char a, unsigned char idx);
void VoiceState_SwapSlot_Guarded(unsigned char c, unsigned char lim, unsigned char s);
unsigned int ExtVoice_Alloc_StreamSlot(unsigned char a, unsigned char c, unsigned char e);

/* cc900-name: Voice_Env_UpdVelCounters=Voice_Env_UpdateVelocityCounters */
/* cc900-module: Voice_ChanPressure AudioChannel_Dispatch */
/* cc900-module: Voice_SetPitch Voice_NoteOff Voice_NoteOn_Rhythm Voice_Init_Type1 */
/* cc900-module: Voice_Allocate_Nodes RingBuf_CheckOffset_ClearFlags Voice_Find_Candidate Voice_FindStealCandidate */
/* cc900-module: Voice_List_MoveToPool Voice_List_MoveToPartList DList_Relink_Adjacent_Offsets16 */
/* cc900-module: DList_Unlink_SelfLink_Offsets16 Voice_ScanSlots_ReassignSources */
/* cc900-module: ExtVoice_Alloc_StreamSlot ExtVoice_Fold_SlotNumber ExtVoice_Lookup_SlotFallback */
/* cc900-module: VoiceSlot_UpdateNoteSource VoiceState_SwapSlot_Guarded */

void Voice_ChanPressure(unsigned char *m)
{
    unsigned char part;
    unsigned char *pr;
    unsigned char i;
    unsigned char u;

    if (m[1] >= 0x1a) return;
    u = m[1];
    part = u;
    switch ((*(unsigned char **)(ram_4136e + (int)u * 287))[16] & 0xc0) {
    case 0x00:
    case 0xc0:
    case 0x40:
        pr = *(unsigned char **)(ram_4136e + (int)part * 287);
        for (i = 0; i < 2; i++)
            AudioChannel_Dispatch(part, m[3], &pr[(int)i * 3 + 0x23]);
        break;
    case 0x80:
        pr = *(unsigned char **)(ram_4136e + (int)part * 287);
        for (i = 0; i < 2; i++)
            AudioChannel_Dispatch(part, m[3], &pr[(int)i * 3 + 0x21]);
        break;
    }
}

void Voice_SetPitch(unsigned char part, unsigned char key, unsigned char vel, unsigned char w)
{
    unsigned char req[14];
    unsigned char s;

    if (((*(unsigned char **)(ram_4136e + (int)part * 287))[16] & 0xc0) != 0x40) return;
    if (!(*(unsigned int *)(ram_4136a + (int)part * 287) & 7)) return;
    if (vel & 0x80) return;
    Voice_Env_ApplyVelocity_Type0(part, w);
    Voice_Env_UpdVelCounters(part);
    Voice_NoteOn_Rhythm(req, part, key, vel);
    s = req[10];
    if (s >= 0x40) return;
    ram_18 &= ~0x80;
    ram_100000 = s + 0x840;
    __asm("nop");
    ram_18 |= 0x80;
    ram_100002 = 0xff00;
    __asm("jr $+2");
    __asm("nop");
    __asm("nop");
    __asm("nop");
    ram_18 &= ~0x80;
    ram_100000 = s + 0x800;
    __asm("nop");
    ram_18 |= 0x80;
    ram_100002 = 0xff80;
    __asm("jr $+2");
    __asm("nop");
    __asm("nop");
    __asm("nop");
    Voice_Init_Type1(s);
    ToneGen_WriteSingleReg(s, *(unsigned int *)&ram_430bb[(int)s * 71]);
}

void Voice_NoteOff(unsigned char part, unsigned char key, unsigned char vel, unsigned char w)
{
    unsigned char req[14];
    unsigned char s;

    if (((*(unsigned char **)(ram_4136e + (int)part * 287))[16] & 0xc0) != 0x40) return;
    if (!(*(unsigned int *)(ram_4136a + (int)part * 287) & 7)) return;
    Voice_Env_ApplyVelocity_Type0(part, w);
    Voice_Env_UpdVelCounters(part);
    Voice_NoteOn_Rhythm(req, part, key, vel);
    s = req[11];
    if (s >= 0x40) return;
    ram_18 &= ~0x80;
    ram_100000 = s + 0x840;
    __asm("nop");
    ram_18 |= 0x80;
    ram_100002 = 0xff00;
    __asm("jr $+2");
    __asm("nop");
    __asm("nop");
    __asm("nop");
    ram_18 &= ~0x80;
    ram_100000 = s + 0x800;
    __asm("nop");
    ram_18 |= 0x80;
    ram_100002 = 0xff80;
    __asm("jr $+2");
    __asm("nop");
    __asm("nop");
    __asm("nop");
    Voice_Init_Type1(s);
    ToneGen_WriteSingleReg(s, *(unsigned int *)&ram_430bb[(int)s * 71]);
    VoiceSlot_NoteOff(s);
}

void Voice_Allocate_Nodes(unsigned char *v)
{
    unsigned char s;
    unsigned char i;
    unsigned char *cls;
    unsigned char *list;
    unsigned char part;
    unsigned char *n;
    unsigned char *q;
    unsigned char *u;
    unsigned char *c2;

    if (!(v[6] & 0x40)) ram_1129 = 0;
    part = (*(unsigned int *)v & 0x1f00) >> 8;
    if (part < 0x1a) {
        RingBuf_CheckOffset_ClearFlags(v);
        list = ram_1349 + (int)part * 12;
        for (i = 0; i < 4; i++) {
            if (v[(int)i + 2] & 0x80) {
                c2 = Voice_LayerClassTable + (int)(v[(int)i + 2] & 0xf) * 6;
                cls = c2;
                n = Voice_Find_Candidate(list, *(unsigned char **)c2);
                if (n != 0) {
                    s = n[36];
                    if ((*(unsigned char **)(n + 29))[1] != 0) (*(unsigned char **)(n + 29))[1]--;
                    n[35] = *(unsigned int *)v & 0x7f;
                    n[37] = 0xff;
                    n[38] = cls[5];
                    if (v[(int)i + 6] & 0x80) {
                        n[34] = 0x88;
                        ram_2936[s >> 4] |= 1 << (s & 0xf);
                    } else {
                        n[34] = 0x08;
                        ram_2936[s >> 4] &= ~(1 << (s & 0xf));
                        ram_292e[s >> 4] |= 1 << (s & 0xf);
                    }
                    Voice_List_MoveToPool(n, *(unsigned char **)list, (char)cls[4]);
                    Voice_List_MoveToPartList(n, list, 0);
                    if (ram_1129 != 0) DList_Relink_Adjacent_Offsets16(n, ram_1129);
                    else {
                        ram_1129 = n;
                        DList_Unlink_SelfLink_Offsets16(n);
                    }
                    u = *(unsigned char **)(n + 29);
                    q = u;
                    if (u[1] < *q) (*(unsigned char **)(n + 29))[1]++;
                    else {
                        n = Voice_FindStealCandidate(*(unsigned char **)(n + 29));
                        if (n != 0) {
                            Voice_List_MoveToPool(n, (unsigned char *)(void *)ram_130d, n[33]);
                            (*(unsigned char **)(n + 29))[1]++;
                            n[34] |= 0x10;
                        }
                    }
                    Voice_ScanSlots_ReassignSources(s);
                    v[(int)i + 10] = s;
                } else v[(int)i + 10] = 0xff;
            } else v[(int)i + 10] = 0xff;
        }
    } else {
        for (i = 0; i < 4; i++) v[(int)i + 10] = 0xff;
    }
}

unsigned int ExtVoice_Alloc_StreamSlot(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char lim;
    unsigned char s;
    unsigned char idx;
    unsigned char r;
    unsigned char *q;

    e &= 0x3f;
    if (c >= 0x40 || a >= 0x1a) return (unsigned int)e << 8 | 0xff;
    lim = Voice_PolyphonyLimits_Table[e & 0x1f];
    idx = Voice_IndexMapping_Table[e];
    s = ram_24e6[c][lim + 8];
    if (s < 0xc0) {
        q = ram_2126[s];
        if (q[2] == a && q[3] == idx) {
            r = ExtVoice_Fold_SlotNumber(s, lim);
            return r | (unsigned int)(unsigned char)(e | 0x80) << 8;
        }
    }
    if (e & 0x20) {
        if ((s = ExtVoice_Lookup_SlotFallback(lim)) < 0xc0) {
            VoiceSlot_UpdateNoteSource(s, a, idx);
            VoiceState_SwapSlot_Guarded(c, lim, s);
            r = ExtVoice_Fold_SlotNumber(s, lim);
        } else r = 0xff;
    } else {
        s = ((unsigned char *)(unsigned long)(ram_1e4d + (int)a * 27))[(unsigned int)idx];
        if (s < 0xc0) {
            VoiceState_SwapSlot_Guarded(c, lim, s);
            r = ExtVoice_Fold_SlotNumber(s, lim);
            e |= 0x80;
        } else {
            s = ExtVoice_Lookup_SlotFallback(lim);
            if (s < 0xc0) {
                VoiceSlot_UpdateNoteSource(s, a, idx);
                VoiceState_SwapSlot_Guarded(c, lim, s);
                r = ExtVoice_Fold_SlotNumber(s, lim);
            } else r = 0xff;
        }
    }
    return r | (unsigned int)e << 8;
}
