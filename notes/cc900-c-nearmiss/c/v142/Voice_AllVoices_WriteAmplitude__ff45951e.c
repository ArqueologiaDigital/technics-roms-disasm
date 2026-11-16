/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_7h.c (2026-11-16-79-sub-r7)
   sha256 ff45951e7915dae97b36ca1a3213944f254e8b3ca615340945203e71eb372448 (name+funcs); compiled at -Xr */
extern unsigned char ram_4308e[][0x47];
extern unsigned int ram_451cc[];
int Voice_ApplyPortamento(unsigned char *v);
int Voice_ApplyPortamento2(unsigned char *v);
void ToneGen_WriteVoice_Short(unsigned int ch, unsigned int *p);
void Voice_AllVoices_WriteAmplitude(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    base = ram_4308e;
    for (q = list + 5; *q < 0x40; q++) {
        v = base[*q];
        switch (*(unsigned int *)(v + 1) & 0x3c) {
        case 4:
        case 8:
        case 0x20:
            Voice_ApplyPortamento(v);
            break;
        case 0x10:
            Voice_ApplyPortamento2(v);
            break;
        }
        ToneGen_WriteVoice_Short(*q, ram_451cc);
    }
}
