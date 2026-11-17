/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_7h.c (2026-11-16-79-sub-r7)
   sha256 ff45951e7915dae97b36ca1a3213944f254e8b3ca615340945203e71eb372448 (name+funcs); compiled at -Xr */
extern unsigned char ram_4308e[][0x47];
extern unsigned int ram_451cc[];
extern void TVF_Emit_Registers(unsigned char *);
extern void TVF_Emit_Registers_Type2(unsigned char *);
void ToneGen_WriteVoice_TvfPair(unsigned int ch, unsigned int *p);
void TVF_Refresh_Sounding_Voices(unsigned char *list)
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
            TVF_Emit_Registers(v);
            ToneGen_WriteVoice_TvfPair(*q, ram_451cc);
            break;
        case 0x10:
            TVF_Emit_Registers_Type2(v);
            ToneGen_WriteVoice_TvfPair(*q, ram_451cc);
            break;
        case 8:
            break;
        }
    }
}
