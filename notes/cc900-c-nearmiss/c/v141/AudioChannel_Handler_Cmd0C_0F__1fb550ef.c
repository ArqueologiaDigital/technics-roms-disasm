/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/voice_envelopes_and_channels_ad_20a.c (2026-11-18-8-sub-r20b-staged)
   sha256 1fb550efc485db3ca7fb82303c33f749e02116fba23327808b56244cf323d7a9 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: ToneGen_WrVoice_Reg07_Or_Reg18=ToneGen_WriteVoice_Reg07_Or_Reg18 */
struct b4 { unsigned char b0, b1, b2, b3; };
extern unsigned char ram_41350[];
extern unsigned char ram_43076[][0x47];
extern unsigned int ram_451b4[];
extern unsigned int ram_451ec;
extern unsigned int ram_451f6;
extern unsigned char *Voice_Query_PartVoices(int part);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void AlgoFlag_Write(int, int, int);
extern void EFF_RoutingInit(int, int, int);
extern void Voice2_UpdatePitch(unsigned char *v);
extern void Voice_OpSlot_WriteParams(int part, unsigned char *rec, int slot, int k, int voice);
extern void Voice_Freq_WriteLeft(int n);
extern void ToneGen_WriteVoice_Reg13(int ch, unsigned int *p);
extern void ToneGen_WrVoice_Reg07_Or_Reg18(int ch, unsigned int *p);
void AudioMod_Apply_Slot_Field2A(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot, unsigned char k);
void AudioChannel_Handler_Cmd0C_0F(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if (((struct b4 *)&((unsigned char *)(unsigned long)(ram_41350 + (int)(part) * 287))[(int)(slot) * 4 + 71])->b3 == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 2);
        AlgoFlag_Write(part, 2, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 2);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41350[part * 0x11f] |= 8;
        base = ram_43076;
        for (q = list + 5; *q < 0x40; q++) {
            Voice2_UpdatePitch(base[*q]);
            ToneGen_WriteVoice_Reg13(*q, ram_451b4);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 2);
        AlgoFlag_Write(part, 2, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 2);
        olist = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 8), 32);
        for (j = 0; (olist[j] & 0xff) < 0x80; j++) {
            i = olist[j];
            i &= 0xff;
            Voice_OpSlot_WriteParams(part, ram_41350 + part * 287, slot, 2, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41350[part * 0x11f] |= 8;
                ram_451ec = 0;
                ram_451f6 = 0;
            } else {
                Voice_Freq_WriteLeft((unsigned char)i);
            }
            ToneGen_WrVoice_Reg07_Or_Reg18((unsigned char)i, ram_451b4);
        }
    }
}
