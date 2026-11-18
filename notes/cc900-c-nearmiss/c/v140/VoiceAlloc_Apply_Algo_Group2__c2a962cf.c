/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/voice_noteon_and_tonegen_ai_22a.c (2026-11-18-32-sub-r21g-staged)
   sha256 c2a962cf115d11f73fccb6335a8de054d94fbfdd65bb8941d3e76947c9e4e122 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: ToneGen_WriteExtParams_15_Bank=ToneGen_WriteExtParams_15_Banked */
extern unsigned char ram_4131c[];
extern unsigned int ram_45180[];
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
        Voice_OpSlot_WriteParams(part, ram_4131c + part * 287, slot, 2, (unsigned char)i);
        Voice_Freq_WriteLeft((unsigned char)i);
        Voice_Freq_WriteRight((unsigned char)i);
        ToneGen_WriteExtParams_15_Bank(i, ram_45180);
    }
}
