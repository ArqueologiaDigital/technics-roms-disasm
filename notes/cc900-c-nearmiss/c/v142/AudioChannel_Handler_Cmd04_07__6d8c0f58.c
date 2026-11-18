/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_envelopes_and_channels_ad_20a.c (2026-11-18-8-sub-r20b-staged)
   sha256 6d8c0f588d5956c5df47105a9ba4d9a5a97e6f94f3b08a10b5cd64b96724d26a (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct b4 { unsigned char b0, b1, b2, b3; };
extern unsigned char ram_41368[];
extern unsigned char ram_4308e[][0x47];
extern unsigned int ram_451cc[];
extern unsigned int ram_4520c;
extern unsigned char *Voice_Query_PartVoices(int part);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void AlgoFlag_Write(int, int, int);
extern void EFF_RoutingInit(int, int, int);
extern void ExtVoice_Build_SlotRegisters(unsigned char *v);
extern void Voice_OpSlot_WriteParams(int part, unsigned char *rec, int slot, int k, int voice);
extern unsigned int EGEnv_Compute_A(int n);
extern void ToneGen_WriteVoice_Reg11(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_Reg18(int ch, unsigned int *p);
void AudioMod_Apply_Slot_Field2A(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot, unsigned char k);
void AudioChannel_Handler_Cmd04_07(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if (((struct b4 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(slot) * 4 + 39])->b3 == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 0);
        AlgoFlag_Write(part, 0, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 0);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
        base = ram_4308e;
        for (q = list + 5; *q < 0x40; q++) {
            ExtVoice_Build_SlotRegisters(base[*q]);
            ToneGen_WriteVoice_Reg11(*q, ram_451cc);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 0);
        AlgoFlag_Write(part, 0, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 0);
        olist = Voice_BuildOutputList(part, (unsigned char)(unsigned int)slot, 32);
        for (j = 0; (olist[j] & 0xff) < 0x80; j++) {
            i = olist[j];
            i &= 0xff;
            Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 0, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
                ram_4520c = 0;
            } else {
                ram_4520c = EGEnv_Compute_A((unsigned char)i);
            }
            ToneGen_WriteVoice_Reg18((unsigned char)i, ram_451cc);
        }
    }
}
