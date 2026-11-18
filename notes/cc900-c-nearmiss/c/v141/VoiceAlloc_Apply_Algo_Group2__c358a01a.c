/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/voice_noteon_and_tonegen_ai_22a.c (2026-11-18-32-sub-r21g-staged)
   sha256 c358a01a115f01900e2f03ca7587bb46259b847e370218b608fd7ee0a968005f (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: ToneGen_WriteExtParams_15_Bank=ToneGen_WriteExtParams_15_Banked */
extern unsigned char ram_41350[];
extern unsigned int ram_451b4[];
extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
void EFF_RoutingInit(unsigned char part, unsigned char slot, unsigned char grp);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void Voice_OpSlot_WriteParams(int part, unsigned char *rec, int slot, int k, int voice);
extern void Voice_Freq_WriteLeft(int n);
extern void Voice_Freq_WriteRight(int n);
extern void ToneGen_WriteExtParams_15_Bank(int, unsigned int *);
void VoiceAlloc_Apply_Algo_Group2(unsigned char part, unsigned char slot)
{
    unsigned int *list;
    unsigned int j;
    unsigned char k;
    unsigned int i;
    AlgoFlag_Write(part, 2, slot);
    AlgoFlag_Write_Bit3(part, 2, slot);
    for (k = 0; k < 4; k++) EFF_RoutingInit(part, k, 2);
    list = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 8), 0);
    for (j = 0; (list[j] & 0xff) < 0x80; j++) {
        i = list[j];
        i &= 0xff;
        Voice_OpSlot_WriteParams(part, ram_41350 + part * 287, slot, 2, (unsigned char)i);
        Voice_Freq_WriteLeft((unsigned char)i);
        Voice_Freq_WriteRight((unsigned char)i);
        ToneGen_WriteExtParams_15_Bank(i, ram_451b4);
    }
}
