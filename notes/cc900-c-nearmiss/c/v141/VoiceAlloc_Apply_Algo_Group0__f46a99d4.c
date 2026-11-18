/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/voice_noteon_and_tonegen_ai_21a.c (2026-11-18-21-sub-r21c-staged)
   sha256 f46a99d4a9c7cf7bdd516b265d0c44a4654ba5ea6dc978fe85363dc820e0c2d9 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41350[];
extern unsigned int ram_451b4[];
extern unsigned int ram_451f0;
extern unsigned int ram_451f4;
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
        Voice_OpSlot_WriteParams(part, ram_41350 + part * 287, slot, 0, (unsigned char)i);
        ram_451f4 = EGEnv_Compute_A((unsigned char)i);
        ram_451f0 = EGEnv_Compute_A_Simple((unsigned char)i);
        ToneGen_WriteExtParams_56(i, ram_451b4);
    }
}
