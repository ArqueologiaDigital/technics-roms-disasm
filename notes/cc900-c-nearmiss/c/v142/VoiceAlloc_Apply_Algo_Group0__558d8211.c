/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_noteon_and_tonegen_ai_21a.c (2026-11-18-21-sub-r21c-staged)
   sha256 558d8211f529222834a1661dd528698e0f76c7c6a270f492ecd6fbe32bf8943b (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41368[];
extern unsigned int ram_451cc[];
extern unsigned int ram_45208;
extern unsigned int ram_4520c;
extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
void EFF_RoutingInit(unsigned char part, unsigned char slot, unsigned char grp);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void Voice_OpSlot_WriteParams(int part, unsigned char *rec, int slot, int k, int voice);
extern unsigned int EGEnv_Compute_A(int n);
extern unsigned int EGEnv_Compute_A_Simple(int n);
extern void ToneGen_WriteExtParams_56(int, unsigned int *);
void VoiceAlloc_Apply_Algo_Group0(unsigned char part, unsigned char slot)
{
    unsigned int *list;
    unsigned int j;
    unsigned char k;
    unsigned int i;
    AlgoFlag_Write(part, 0, slot);
    AlgoFlag_Write_Bit3(part, 0, slot);
    for (k = 0; k < 4; k++) EFF_RoutingInit(part, k, 0);
    list = Voice_BuildOutputList(part, (unsigned char)(unsigned int)slot, 0);
    for (j = 0; (list[j] & 0xff) < 0x80; j++) {
        i = list[j];
        i &= 0xff;
        Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 0, (unsigned char)i);
        ram_4520c = EGEnv_Compute_A((unsigned char)i);
        ram_45208 = EGEnv_Compute_A_Simple((unsigned char)i);
        ToneGen_WriteExtParams_56(i, ram_451cc);
    }
}
