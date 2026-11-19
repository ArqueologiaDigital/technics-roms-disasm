/* lane_sub helper AS, round 39, form b: form a with these changes --
   ExtVoice_Build_SlotRegisters: the block locals e and x declared `register` (in case V4.23 gives XIZ to the
   function-level slot, as the ROM does not); the else branch's third Alloc argument `(unsigned char)((int)ty | 0)`;
   the long as `x = ram_4520e; x &= 0x1fff;`.
   Voice_SubVoice_ComputeAndTrigger: `register unsigned int slot` (still declared first); the alt path's slot as
   `slot = w; slot &= 0xff;` and a separate test.
   Form a's notes follow.
   Round 39, form a (KN5000 sub-CPU payload v1.42, core/05).  Never compiled before.
   Both functions are siblings of Voice2_UpdatePitch (sub_AP_26a.c, DIFF at +210 only at `e[6] = v[12]`), whose
   spelling they follow: the slot record `&base[(unsigned long)slot * 27]` (Math_Multiply32), the slot
   `w & 0xff`, the type byte through a temporary t, the struct b4 test of bit 7, OpSlot / Freq calls.
   Both are one function each (span_refs.py: every inner label inner-only).  The ROM's direct jumps to the common
   tail (Stereo / SecondaryPitch) are written as gotos, so nothing depends on jump threading.
   - Voice_SubVoice_ComputeAndTrigger (744 B; = Voice1_UpdatePitch): the ROM's frame is q +2, r +6, e +10, w +14,
     sw +16, part +18, ty +20 (ascending in declaration order, as plain locals got in sub_AP_23c), the slot in IZ
     and v[3] in register C (only used on the alt path, before any call).  Form a: all plain locals, the slot
     declared FIRST (in 23c, declared last, it lost XIZ to e); on the alt path the ROM has `and iz,0xff` where the
     main path has `ld izh,0`: form a assigns inside the test, `if ((slot = w & 0xff) >= 0x40)`.
     The test of q+10 (`extz xwa; bit 15,wa`) is a long AND, `& 0x8000L`.
   - ExtVoice_Build_SlotRegisters (862 B): the ROM keeps the record pointer e in XIZ and the slot on the stack
     (as V4.23 did with sub_AP_23c's plain locals), and +20 holds a byte (the type ty) on the main path and an int
     (DSP_AlgoType_Dispatch3's result) on the other two: block-scoped locals sharing one slot.  XIZ is e on the
     main path and a long (the masked 0x4520e word) on the secondary path, so e and that long are block locals
     too.  Function-level q +4, r +8, w +12, slot +14, part +16, v[3] +18 (ascending).  The AlgoType_AB_Checker
     result stays in L until EnvDepth_Cap's third argument: a byte local k.  The Mute writer is called with no
     reload of the slot: `ToneGen_WriteExtParam_600_Mute(slot = w & 0xff)`.  The else branch's third Alloc
     argument is `extz wa` with nothing ORed: `(unsigned char)(int)ty`.  The long: `ram_4520e & 0x1fffL`.
   cc900-options: -Xr
*/

struct b4 { unsigned char b0, b1, b2, b3; };

extern unsigned char ram_4138e[];
extern unsigned char ram_4424e[];
extern unsigned char ram_44257[];
extern unsigned int ram_451cc[];
extern unsigned int ram_451d8;
extern unsigned int ram_451dc;
extern unsigned int ram_451de;
extern unsigned int ram_45204;
extern unsigned int ram_45206;
extern unsigned int ram_45208;
extern unsigned int ram_4520a;
extern unsigned int ram_4520c;
extern unsigned int ram_4520e;

unsigned int ExtVoice_Alloc_StreamSlot(unsigned char a, unsigned char c, unsigned char e);
unsigned int DSP_AlgoType_Dispatch3(unsigned char part, unsigned char ch, unsigned char e);
unsigned int Algo67_LUTOffset_Check(unsigned char part, unsigned char k);
unsigned int AlgoType_AB_Checker(unsigned char part);
unsigned long EGEnv_Compute_A_Simple(unsigned char n);
unsigned long EGEnv_Compute_B_Simple(unsigned char n);
unsigned int EGEnv_Compute_A(unsigned char n);
unsigned int EGEnv_Compute_B(unsigned char n);
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
void NoteState_ClearRecord(unsigned char i, unsigned char j);
void Voice_OpSlot_WriteParams(int part, unsigned char *rec, int slot, int k, int voice);
void ToneGen_WriteExtParam_540_Mute(unsigned int reg);
void ToneGen_WriteExtParam_600_Mute(unsigned int reg);
void ToneGen_WriteExtParams_15(int ch, unsigned int *p);
void ToneGen_WriteExtParams_15_Alt(int ch, unsigned int *p);
void ToneGen_WriteExtParam_1C0_Sgl(int ch, unsigned int *p);
void ToneGen_WriteExtParams_56(int ch, unsigned int *p);
void ToneGen_WriteExtParams_56_Alt(int ch, unsigned int *p);
void ToneGen_WriteExtParams_56b(int ch, unsigned int *p);
void ToneGen_WriteExtParam_600(int ch, unsigned int *p);
void ExtVoice_Build_SlotRegisters(unsigned char *v);
void Voice_SubVoice_ComputeAndTrig(unsigned char *v);

/* cc900-name: ToneGen_WriteExtParam_1C0_Sgl=ToneGen_WriteExtParam_1C0_Single */

/* cc900-module: EGEnv_Compute_A EGEnv_Compute_A_Simple EnvDepth_Cap ExtVoice_Build_SlotRegisters NoteState_ClearRecord Voice_OpSlot_WriteParams */
void ExtVoice_Build_SlotRegisters(unsigned char *v)
{
    unsigned char *q;
    unsigned char *r;
    unsigned int w;
    unsigned int slot;
    unsigned char part;
    unsigned char c3;
    ram_451dc = 0;
    ram_451de = 0;
    q = *(unsigned char **)(v + 35);
    r = *(unsigned char **)(v + 39);
    part = v[4];
    c3 = v[3];
    if (*(unsigned int *)(r + 26) == 0) goto fallback;
    {
        register unsigned char *e;
        unsigned char ty;
        unsigned char t;
        t = (unsigned char)*(unsigned int *)(r + 26) & 3;
        ty = t;
        if (((struct b4 *)&(*(unsigned char **)(v + 19))[((int)t << 2) + 0x2b])->b2 & 0x80) {
            w = ExtVoice_Alloc_StreamSlot(part, v[0], (unsigned char)((int)ty | 0x20));
            ToneGen_WriteExtParam_600_Mute(slot = w & 0xff);
        } else {
            w = ExtVoice_Alloc_StreamSlot(part, v[0], (unsigned char)((int)ty | 0));
            slot = w & 0xff;
        }
        e = ram_4424e + (unsigned long)slot * 27;
        e[6] = v[12] & 0x7f;
        if (slot >= 0x80) goto secondary;
        ram_451dc = (*(unsigned int *)(r + 26) & 0xc0) | slot;
        if (!(w & 0x8000) || (*(unsigned int *)q & 0xc)) {
            Voice_OpSlot_WriteParams(part, q, ty, 0, (unsigned char)slot);
            ram_45208 = EGEnv_Compute_A_Simple((unsigned char)slot);
            ToneGen_WriteExtParams_56_Alt(slot, ram_451cc);
        }
        if ((e[7] != 0 && (*(unsigned int *)(q + 2) & 0x2000)) || (e[0] & 0x20)) {
            e[8] = 0;
            e[0] &= 0xf3;
            e[0] |= 0x10;
            ram_4520c = 0;
            ToneGen_WriteExtParam_600(slot, ram_451cc);
            goto secondary;
        }
        if ((e[5] != 0 || !(w & 0x8000)) && !(e[0] & 0x38)) {
            ram_4520c = EGEnv_Compute_A((unsigned char)slot);
            ToneGen_WriteExtParam_600(slot, ram_451cc);
            goto secondary;
        }
        if (!(*(unsigned int *)q & 0xc)) goto secondary;
        ram_4520c = EGEnv_Compute_A((unsigned char)slot);
        ToneGen_WriteExtParam_600(slot, ram_451cc);
        goto secondary;
    }
fallback:
    if (*(unsigned int *)(q + 10) & 0x8000L) {
        int d;
        d = DSP_AlgoType_Dispatch3(part, c3, 1);
        if (d != 0) {
            w = ExtVoice_Alloc_StreamSlot(part, v[0], 0xd);
            slot = w & 0xff;
            if (slot < 0x80) {
                NoteState_ClearRecord(0, (unsigned char)slot);
                ram_451dc = (w & 0x7f) | d;
                if (!(w & 0x8000) || (*(unsigned int *)q & 4)) {
                    ram_4520c = *(unsigned int *)(q + 91);
                    ram_45208 = *(unsigned int *)(q + 93);
                    ToneGen_WriteExtParams_56(slot, ram_451cc);
                }
            }
        }
    }
secondary:
    if (*(unsigned int *)(q + 10) & 0x8000L) {
        int d2;
        register unsigned long x;
        unsigned char k;
        d2 = DSP_AlgoType_Dispatch3(part, c3, 0);
        if (d2 != 0) {
            w = ExtVoice_Alloc_StreamSlot(part, v[0], 0xc);
            slot = w & 0xff;
            if (slot < 0x80) {
                ram_451de = slot | d2;
                k = AlgoType_AB_Checker(part);
                if (k != 0 || !(w & 0x8000) || (*(unsigned int *)q & 4)) {
                    ram_4520e = *(unsigned int *)(q + 87);
                    x = ram_4520e;
                    x &= 0x1fff;
                    x -= EnvDepth_Cap(x, v[12], k);
                    ram_4520e &= 0xe000;
                    ram_4520e |= (unsigned int)x;
                    ram_4520a = *(unsigned int *)(q + 89);
                    ToneGen_WriteExtParams_56b(slot, ram_451cc);
                }
            }
        }
    }
}

/* cc900-name: Voice_SubVoice_ComputeAndTrig=Voice_SubVoice_ComputeAndTrigger */
/* cc900-module: EGEnv_Compute_B EGEnv_Compute_B_Simple NoteState_ClearRecord Voice_OpSlot_WriteParams Voice_SubVoice_ComputeAndTrigger */
void Voice_SubVoice_ComputeAndTrig(unsigned char *v)
{
    register unsigned int slot;
    unsigned char *q;
    unsigned char *r;
    unsigned char *e;
    unsigned int w;
    unsigned int sw;
    unsigned char part;
    unsigned char ty;
    unsigned char t;
    unsigned char c3;
    q = *(unsigned char **)(v + 35);
    r = *(unsigned char **)(v + 39);
    part = v[4];
    c3 = v[3];
    sw = 0;
    if (*(unsigned int *)(r + 28) == 0) goto alt;
    t = (unsigned char)*(unsigned int *)(r + 28) & 3;
    ty = t;
    if (((struct b4 *)&(*(unsigned char **)(v + 19))[((int)t << 2) + 0x3b])->b2 & 0x80) {
        w = ExtVoice_Alloc_StreamSlot(part, v[0], (unsigned char)((int)ty | 0x24));
        slot = w & 0xff;
        ToneGen_WriteExtParam_540_Mute(slot);
    } else {
        w = ExtVoice_Alloc_StreamSlot(part, v[0], (unsigned char)((int)ty | 4));
        slot = w & 0xff;
    }
    e = &ram_44257[(unsigned long)slot * 27];
    e[6] = v[12];
    if (slot >= 0x40) goto stereo;
    sw = *(unsigned int *)(r + 28) & 0xc000;
    sw |= slot << 8;
    if (!(w & 0x8000) || (*(unsigned int *)q & 0xc)) {
        Voice_OpSlot_WriteParams(part, q, ty, 1, (unsigned char)slot);
        ram_45206 = EGEnv_Compute_B_Simple((unsigned char)slot);
        ToneGen_WriteExtParams_15_Alt(slot, ram_451cc);
    }
    if ((e[7] != 0 && (*(unsigned int *)(q + 2) & 0x2000)) || (e[0] & 0x20)) {
        e[8] = 0;
        e[0] &= 0xf3;
        e[0] |= 0x10;
        ram_45204 = 0;
        ToneGen_WriteExtParam_1C0_Sgl(slot, ram_451cc);
        goto stereo;
    }
    if ((e[5] != 0 || !(w & 0x8000)) && !(e[0] & 0x38)) {
        ram_45204 = EGEnv_Compute_B((unsigned char)slot);
        ToneGen_WriteExtParam_1C0_Sgl(slot, ram_451cc);
        goto stereo;
    }
    if (!(*(unsigned int *)q & 0xc)) goto stereo;
    ram_45204 = EGEnv_Compute_B((unsigned char)slot);
    ToneGen_WriteExtParam_1C0_Sgl(slot, ram_451cc);
    goto stereo;
alt:
    if (!(*(unsigned int *)(q + 10) & 0x8000L)) goto stereo;
    sw = Algo67_LUTOffset_Check(part, c3);
    if (sw == 0) goto stereo;
    w = ExtVoice_Alloc_StreamSlot(part, v[0], 0x10);
    slot = w;
    slot &= 0xff;
    if (slot >= 0x40) goto stereo;
    NoteState_ClearRecord(1, (unsigned char)slot);
    sw |= slot << 8;
    if (!(w & 0x8000) || (*(unsigned int *)q & 4)) {
        ram_45204 = *(unsigned int *)(q + 95);
        ram_45206 = *(unsigned int *)(q + 97);
        ToneGen_WriteExtParams_15(slot, ram_451cc);
    }
stereo:
    if (ram_4138e[v[4] * 287] == 1) *(unsigned int *)(v + 43) = sw;
    else if (ram_4138e[v[4] * 287] == 2) *(unsigned int *)(v + 43) = sw | 0x7f;
    else *(unsigned int *)(v + 43) = r[35] | sw;
    ram_451d8 = *(unsigned int *)(v + 43);
}
