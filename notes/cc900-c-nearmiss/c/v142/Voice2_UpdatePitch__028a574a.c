/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AP_27b.c (2026-11-19-35-sub-r27a)
   sha256 028a574a5bd730c29ceebfe3dd804b4a91a21f8119f5e8a0068ed835ce651903 (name+funcs); compiled at -Xr
   cc900-options: -Xr
   cc900-name: TG_WriteExtParam_Mute_TypeDisp=ToneGen_WriteExtParam_Mute_TypeDispatch
   cc900-name: TG_WriteExtParams_TypeDispatch=ToneGen_WriteExtParams_TypeDispatch
   cc900-name: ToneGen_WrExtParam_TypeDisp_Sgl=ToneGen_WriteExtParam_TypeDispatch_Single */
struct b4 { unsigned char b0, b1, b2, b3; };
extern unsigned char ram_44260[];
extern unsigned int ram_451cc[];
extern unsigned int ram_451e0;
extern unsigned int ram_45204;
extern unsigned int ram_4520e;
unsigned int ExtVoice_Alloc_StreamSlot(unsigned char a, unsigned char c, unsigned char e);
void TG_WriteExtParam_Mute_TypeDisp(unsigned int ch);
void TG_WriteExtParams_TypeDispatch(unsigned int ch, unsigned int *blk);
void ToneGen_WrExtParam_TypeDisp_Sgl(unsigned int ch, unsigned int *blk);
void Voice_OpSlot_WriteParams(int part, unsigned char *rec, int slot, int k, int voice);
void Voice_Freq_WriteRight(unsigned char n);
void Voice_Freq_WriteLeft(unsigned char n);
void Voice2_UpdatePitch(unsigned char *v)
{
    unsigned char ty;
    unsigned char part;
    unsigned int w;
    unsigned char *e;
    unsigned char *q;
    unsigned char *r;
    unsigned char t;
    unsigned int ch;
    (void *)&ty;
    (void *)&part;
    (void *)&w;
    (void *)&e;
    ram_451e0 = 0x4400;
    q = *(unsigned char **)(v + 35);
    r = *(unsigned char **)(v + 39);
    part = v[4];
    if (*(unsigned int *)(r + 30) == 0) return;
    t = (unsigned char)*(unsigned int *)(r + 30) & 3;
    ty = t;
    if (((struct b4 *)&(*(unsigned char **)(v + 19))[((int)t << 2) + 0x4b])->b2 & 0x80) {
        w = ExtVoice_Alloc_StreamSlot(part, v[0], (unsigned char)((int)ty | 0x28));
        ch = w & 0xff;
        TG_WriteExtParam_Mute_TypeDisp(ch);
    } else {
        w = ExtVoice_Alloc_StreamSlot(part, v[0], (unsigned char)((int)ty | 8));
        ch = w & 0xff;
    }
    e = &ram_44260[(unsigned long)ch * 27];
    e[6] = ((unsigned char *)v)[12];
    if (ch >= 0x80) return;
    ram_451e0 |= (*(unsigned int *)(r + 30) & 0x3300) | ch;
    if (!(w & 0x8000) || (*(unsigned int *)q & 0xc)) {
        Voice_OpSlot_WriteParams(part, q, ty, 2, (unsigned char)ch);
        Voice_Freq_WriteRight((unsigned char)ch);
        TG_WriteExtParams_TypeDispatch(ch, ram_451cc);
    }
    if ((e[7] != 0 && (*(unsigned int *)(q + 2) & 0x2000)) || (e[0] & 0x20)) {
        e[8] = 0;
        e[0] &= 0xf3;
        e[0] |= 0x10;
        ram_45204 = 0;
        ram_4520e = 0;
        ToneGen_WrExtParam_TypeDisp_Sgl(ch, ram_451cc);
        return;
    }
    if ((e[5] != 0 || !(w & 0x8000)) && !(e[0] & 0x38)) {
        Voice_Freq_WriteLeft((unsigned char)ch);
        ToneGen_WrExtParam_TypeDisp_Sgl(ch, ram_451cc);
    } else if (*(unsigned int *)q & 0xc) {
        Voice_Freq_WriteLeft((unsigned char)ch);
        ToneGen_WrExtParam_TypeDisp_Sgl(ch, ram_451cc);
    }
}
