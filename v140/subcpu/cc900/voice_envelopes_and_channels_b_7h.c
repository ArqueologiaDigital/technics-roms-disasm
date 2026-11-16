/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_43042[][0x47];
extern unsigned int ram_45180[];
extern void Pitch_Emit_Reg400(unsigned char *);
extern void Voice_Pitch_WrOutReg_Secondary(unsigned char *);
extern void TVF_Emit_Registers(unsigned char *);
extern void TVF_Emit_Registers_Type2(unsigned char *);
extern void Voice_WriteChPanShift(unsigned char *, int);
extern void Voice_WriteChPanShift2(unsigned char *, int);
int Voice_ApplyPortamento(unsigned char *v);
int Voice_ApplyPortamento2(unsigned char *v);
void ToneGen_WriteVoice_Long(unsigned int ch, unsigned int *p);
void ToneGen_WriteVoice_Short(unsigned int ch, unsigned int *p);
void ToneGen_WriteVoice_TvfPair(unsigned int ch, unsigned int *p);
void ToneGen_WriteVoice_Reg21_Reg22(unsigned int ch, unsigned int *p);

/* cc900-name: Voice_Pitch_WrOutReg_Secondary=Voice_Pitch_WriteOutputReg_Secondary */
/* cc900-name: AudioChannel_AllVoices_UpdPan=AudioChannel_AllVoices_Update_PanShift */
/* cc900-module: ToneGen_WriteVoice_Long ToneGen_WriteVoice_Reg21_Reg22 ToneGen_WriteVoice_Short ToneGen_WriteVoice_TvfPair */
void AudioChannel_AllVoices_UpdPan(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    base = ram_43042;
    for (q = list + 5; *q < 0x40; q++) {
        v = base[*q];
        switch (*(unsigned int *)(v + 1) & 0x3c) {
        case 4:
        case 0x20:
            if (v[5] & 0x80) {
                Voice_WriteChPanShift(v, 1);
                ToneGen_WriteVoice_Reg21_Reg22(*q, ram_45180);
            }
            break;
        case 0x10:
            if (!((*(unsigned char **)(v + 19))[13] & 0x20) || (v[5] & 0x80)) {
                Voice_WriteChPanShift2(v, 1);
                ToneGen_WriteVoice_Reg21_Reg22(*q, ram_45180);
            }
            break;
        case 8:
            break;
        }
    }
}

void Pitch_Refresh_Sounding_Voices(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    base = ram_43042;
    for (q = list + 5; *q < 0x40; q++) {
        v = base[*q];
        switch (*(unsigned int *)(v + 1) & 0x3c) {
        case 4:
        case 8:
        case 0x20:
            Pitch_Emit_Reg400(v);
            ToneGen_WriteVoice_Long(*q, ram_45180);
            break;
        case 0x10:
            Voice_Pitch_WrOutReg_Secondary(v);
            ToneGen_WriteVoice_Long(*q, ram_45180);
            break;
        }
    }
}

void TVF_Refresh_Sounding_Voices(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    base = ram_43042;
    for (q = list + 5; *q < 0x40; q++) {
        v = base[*q];
        switch (*(unsigned int *)(v + 1) & 0x3c) {
        case 4:
        case 0x20:
            TVF_Emit_Registers(v);
            ToneGen_WriteVoice_TvfPair(*q, ram_45180);
            break;
        case 0x10:
            TVF_Emit_Registers_Type2(v);
            ToneGen_WriteVoice_TvfPair(*q, ram_45180);
            break;
        case 8:
            break;
        }
    }
}

void Voice_AllVoices_WriteAmplitude(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    base = ram_43042;
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
        ToneGen_WriteVoice_Short(*q, ram_45180);
    }
}
