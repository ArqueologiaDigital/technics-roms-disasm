/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/voice_envelopes_and_channels_ad_20a.c (2026-11-18-8-sub-r20b-staged)
   sha256 44d11c0931993b8687ec9bfff318084f81ef064202063721ba85c4bb3c1e0d10 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: Voice_SubVoice_ComputeAndTrig=Voice_SubVoice_ComputeAndTrigger */
struct b4 { unsigned char b0, b1, b2, b3; };
extern unsigned char ram_4131c[];
extern unsigned char ram_43042[][0x47];
extern unsigned int ram_45180[];
extern unsigned int ram_451b8;
extern unsigned int ram_451ba;
extern unsigned char *Voice_Query_PartVoices(int part);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
extern void EFF_RoutingInit(int, int, int);
extern void Voice_SubVoice_ComputeAndTrig(unsigned char *v);
extern void Voice_OpSlot_WriteParams(int part, unsigned char *rec, int slot, int k, int voice);
extern unsigned int EGEnv_Compute_B_Simple(int n);
extern void ToneGen_WriteVoice_Reg07(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_Reg15(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_EnvLevel(int ch, unsigned int *p);
void AudioMod_Apply_Slot_Field29(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot, unsigned char k);
void AudioChannel_Handler_Cmd14_17(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if (((struct b4 *)&((unsigned char *)(unsigned long)(ram_4131c + (int)(part) * 287))[(int)(slot) * 4 + 55])->b2 == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 1);
        AlgoFlag_Write_Bit3(part, 1, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 1);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_4131c[part * 0x11f] |= 8;
        base = ram_43042;
        for (q = list + 5; *q < 0x40; q++) {
            Voice_SubVoice_ComputeAndTrig(base[*q]);
            ToneGen_WriteVoice_EnvLevel(*q, ram_45180);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 1);
        AlgoFlag_Write_Bit3(part, 1, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 1);
        olist = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 4), 32);
        for (j = 0; (olist[j] & 0xff) < 0x40; j++) {
            i = olist[j];
            i &= 0xff;
            Voice_OpSlot_WriteParams(part, ram_4131c + part * 287, slot, 1, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_4131c[part * 0x11f] |= 8;
                ram_451b8 = 0;
                ToneGen_WriteVoice_Reg07((unsigned char)i, ram_45180);
            } else {
                ram_451ba = EGEnv_Compute_B_Simple((unsigned char)i);
                ToneGen_WriteVoice_Reg15((unsigned char)i, ram_45180);
            }
        }
    }
}
