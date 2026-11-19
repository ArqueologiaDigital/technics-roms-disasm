/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AS_39b.c (2026-11-19-89-sub-r39as)
   sha256 436ac3a2ad259b6f920427aa29e02cb3fbeb6b77c56a6a11cc58108ef6b916d3 (name+funcs); compiled at -Xr
   cc900-options: -Xr
   cc900-name: ToneGen_WriteExtParam_1C0_Sgl=ToneGen_WriteExtParam_1C0_Single
   cc900-name: Voice_SubVoice_ComputeAndTrig=Voice_SubVoice_ComputeAndTrigger */
struct b4 { unsigned char b0, b1, b2, b3; };
extern unsigned char ram_4138e[];
extern unsigned char ram_44257[];
extern unsigned int ram_451cc[];
extern unsigned int ram_451d8;
extern unsigned int ram_45204;
extern unsigned int ram_45206;
unsigned int ExtVoice_Alloc_StreamSlot(unsigned char a, unsigned char c, unsigned char e);
unsigned int Algo67_LUTOffset_Check(unsigned char part, unsigned char k);
unsigned long EGEnv_Compute_B_Simple(unsigned char n);
unsigned int EGEnv_Compute_B(unsigned char n);
void NoteState_ClearRecord(unsigned char i, unsigned char j);
void Voice_OpSlot_WriteParams(int part, unsigned char *rec, int slot, int k, int voice);
void ToneGen_WriteExtParam_540_Mute(unsigned int reg);
void ToneGen_WriteExtParams_15(int ch, unsigned int *p);
void ToneGen_WriteExtParams_15_Alt(int ch, unsigned int *p);
void ToneGen_WriteExtParam_1C0_Sgl(int ch, unsigned int *p);
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
