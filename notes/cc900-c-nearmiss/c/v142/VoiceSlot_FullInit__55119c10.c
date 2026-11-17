/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_10a.c (2026-11-16-90-sub-r10)
   sha256 55119c10bf70d64332a47b3a6a60f61ec60204f1153235ca93ccacfebfb2acff (name+funcs); compiled at -O3 -Xr */
extern void AlgoType_StateWrite(int, int);
extern void Voice_ActiveFlag_CheckAndLoad(int);
extern void DSP_SlotParam_Write_Slot0(int);
extern void DSP_SlotParam_Write_Slot1(int);
extern void DSP_SlotParam_Write_Slot2(int);
extern void DSP_SlotParam_Write_Slot3(int);
extern void DSP_SlotParam_Write_Slot4(int);
extern void Partial_Build_Present_Word(int);
extern void EnvTranspose_UpdateLoop(int);
extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
extern void EFF_RoutingInit(int, int, int);
extern void VoiceNoteParam_UpdateLoop(int);
void VoiceSlot_FullInit(unsigned char part)
{
    unsigned int g;
    unsigned int k;

    AlgoType_StateWrite(part, 0);
    Voice_ActiveFlag_CheckAndLoad(part);
    DSP_SlotParam_Write_Slot0(part);
    DSP_SlotParam_Write_Slot1(part);
    DSP_SlotParam_Write_Slot2(part);
    DSP_SlotParam_Write_Slot3(part);
    DSP_SlotParam_Write_Slot4(part);
    Partial_Build_Present_Word(part);
    EnvTranspose_UpdateLoop(part);
    for (g = 0; g < 3; g++) {
        for (k = 0; k < 4; k++) {
            AlgoFlag_Write_Bit3(part, (unsigned char)g, (unsigned char)k);
            AlgoFlag_Write(part, (unsigned char)g, (unsigned char)k);
        }
        for (k = 0; k < 4; k++)
            EFF_RoutingInit(part, (unsigned char)k, (unsigned char)g);
    }
    VoiceNoteParam_UpdateLoop(part);
}
