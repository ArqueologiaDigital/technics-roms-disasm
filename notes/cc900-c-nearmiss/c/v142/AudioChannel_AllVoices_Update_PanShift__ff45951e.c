/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_7h.c (2026-11-16-79-sub-r7)
   sha256 ff45951e7915dae97b36ca1a3213944f254e8b3ca615340945203e71eb372448 (name+funcs); compiled at -Xr
   cc900-name: AudioChannel_AllVoices_UpdPan=AudioChannel_AllVoices_Update_PanShift */
extern unsigned char ram_4308e[][0x47];
extern unsigned int ram_451cc[];
extern void Voice_WriteChPanShift(unsigned char *, int);
extern void Voice_WriteChPanShift2(unsigned char *, int);
void ToneGen_WriteVoice_Reg21_Reg22(unsigned int ch, unsigned int *p);
void AudioChannel_AllVoices_UpdPan(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    base = ram_4308e;
    for (q = list + 5; *q < 0x40; q++) {
        v = base[*q];
        switch (*(unsigned int *)(v + 1) & 0x3c) {
        case 4:
        case 0x20:
            if (v[5] & 0x80) {
                Voice_WriteChPanShift(v, 1);
                ToneGen_WriteVoice_Reg21_Reg22(*q, ram_451cc);
            }
            break;
        case 0x10:
            if (!((*(unsigned char **)(v + 19))[13] & 0x20) || (v[5] & 0x80)) {
                Voice_WriteChPanShift2(v, 1);
                ToneGen_WriteVoice_Reg21_Reg22(*q, ram_451cc);
            }
            break;
        case 8:
            break;
        }
    }
}
