/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AS_39c.c (2026-11-19-89-sub-r39as)
   sha256 9e00ec3e7eb292b57475e4aee0714b9372da3066b6c2a3ca5a34ca0fcf74bb22 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
struct b4 { unsigned char b0, b1, b2, b3; };
extern unsigned char ram_4424e[];
extern unsigned int ram_451cc[];
extern unsigned int ram_451dc;
extern unsigned int ram_451de;
extern unsigned int ram_45208;
extern unsigned int ram_4520a;
extern unsigned int ram_4520c;
extern unsigned int ram_4520e;
unsigned int ExtVoice_Alloc_StreamSlot(unsigned char a, unsigned char c, unsigned char e);
unsigned int DSP_AlgoType_Dispatch3(unsigned char part, unsigned char ch, unsigned char e);
unsigned int AlgoType_AB_Checker(unsigned char part);
unsigned long EGEnv_Compute_A_Simple(unsigned char n);
unsigned int EGEnv_Compute_A(unsigned char n);
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
void NoteState_ClearRecord(unsigned char i, unsigned char j);
void Voice_OpSlot_WriteParams(int part, unsigned char *rec, int slot, int k, int voice);
void ToneGen_WriteExtParam_600_Mute(unsigned int reg);
void ToneGen_WriteExtParams_56(int ch, unsigned int *p);
void ToneGen_WriteExtParams_56_Alt(int ch, unsigned int *p);
void ToneGen_WriteExtParams_56b(int ch, unsigned int *p);
void ToneGen_WriteExtParam_600(int ch, unsigned int *p);
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
        unsigned char *e;
        unsigned char ty;
        unsigned char t;
        t = (unsigned char)*(unsigned int *)(r + 26) & 3;
        ty = t;
        if (((struct b4 *)&(*(unsigned char **)(v + 19))[((int)t << 2) + 0x2b])->b2 & 0x80) {
            w = ExtVoice_Alloc_StreamSlot(part, v[0], (unsigned char)((int)ty | 0x20));
            ToneGen_WriteExtParam_600_Mute(slot = w & 0xff);
        } else {
            w = ExtVoice_Alloc_StreamSlot(part, v[0], (int)ty);
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
    if (*(unsigned int *)(q + 10) & 32768) {
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
    if (*(unsigned int *)(q + 10) & 32768) {
        int d2;
        unsigned long x;
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
                    x = (unsigned long)ram_4520e & 0x1fff;
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
