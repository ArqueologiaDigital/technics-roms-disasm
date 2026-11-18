/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/voice_noteon_and_tonegen_ai_21a.c (2026-11-18-21-sub-r21c-staged)
   sha256 6ddbd43b62ac8490240dc47dc0dc1f2c9fd95cb9d4fd2e1bfd7c62b7e5081977 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_4131c[];
extern unsigned int ram_45180[];
extern unsigned int ram_451b8;
extern unsigned int ram_451ba;
extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
void EFF_RoutingInit(unsigned char part, unsigned char slot, unsigned char grp);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void Voice_OpSlot_WriteParams(int part, unsigned char *rec, int slot, int k, int voice);
extern unsigned int EGEnv_Compute_B(int n);
extern unsigned int EGEnv_Compute_B_Simple(int n);
extern void ToneGen_WriteExtParams_15(int, unsigned int *);
void VoiceAlloc_Apply_Algo_Group1(unsigned char part, unsigned char slot)
{
    unsigned int *list;
    unsigned int j;
    unsigned char k;
    unsigned int i;
    AlgoFlag_Write(part, 1, slot);
    AlgoFlag_Write_Bit3(part, 1, slot);
    for (k = 0; k < 4; k++) EFF_RoutingInit(part, k, 1);
    list = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 4), 0);
    for (j = 0; (list[j] & 0xff) < 0x40; j++) {
        i = list[j];
        i &= 0xff;
        Voice_OpSlot_WriteParams(part, ram_4131c + part * 287, slot, 1, (unsigned char)i);
        ram_451b8 = EGEnv_Compute_B((unsigned char)i);
        ram_451ba = EGEnv_Compute_B_Simple((unsigned char)i);
        ToneGen_WriteExtParams_15(i, ram_45180);
    }
}
