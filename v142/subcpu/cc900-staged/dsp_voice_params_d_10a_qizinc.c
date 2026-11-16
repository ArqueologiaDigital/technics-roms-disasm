/* Functions of core/10_dsp_voice_params.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
   Held back from subcpu/cc900/ (2026-11-16): V4.23 increments a byte of QIZ (inc 0x1,QIZH / QIZL), which the build's translation does not write as llvm-mc's inc1b_erp yet.
*/

extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];
extern void AlgoType_StateWrite(int, int);
extern void Voice_ActiveFlag_CheckAndLoad(int);
extern void DSP_SlotParam_Write_Slot0(int);
extern void DSP_SlotParam_Write_Slot1(int);
extern void DSP_SlotParam_Write_Slot2(int);
extern void DSP_SlotParam_Write_Slot3(int);
extern void DSP_SlotParam_Write_Slot4(int);
extern void Partial_Build_Present_Word(int);
extern void Voice_InitFromSlot(int);
extern void EnvTranspose_UpdateLoop(int);
extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
extern void EFF_RoutingInit(int, int, int);
extern void VoiceNoteParam_UpdateLoop(int);
extern void Voice_ActiveFlag_Set(int);
extern void Voice_NoteState_Clear(int);
extern void Voice_SetLFO_ActiveFlag(int);
extern void Voice_PortamentoTargets_SetAll(int);
extern void VoiceParam_Update(int, int, int);
extern void WaveSel_Cache_VelSplitPtr(int, int);
extern void WaveSel_Cache_SetDescPtr(int, int, int);
extern void Voice_PortamentoTarget_SetSlot(int, int);
extern void Voice_PortaTgt_ComputePitch(int, int);
extern void WaveSel_StageA2_FindSetDesc(int, int);
extern unsigned char *ToneDB_Resolve_NamedToneRecord(int, int, int, int);
unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
void VoiceSlot_AltInit(unsigned char part);
void VoiceSlot_FullInit(unsigned char part);
void Voice_ProgChange(char *m);
void WaveSel_Rebuild_PartCaches(unsigned char part, unsigned char b, unsigned char c);
void WaveSel_StageA2_FromVelZone(unsigned char z, unsigned char *p);

/* cc900-name: Voice_PortaTgt_ComputePitch=Voice_PortamentoTarget_ComputePitch */
/* cc900-module: AlgoFlag_Write AlgoFlag_Write_Bit3 AlgoType_StateWrite DSP_SlotParam_Write_Slot0 DSP_SlotParam_Write_Slot1 DSP_SlotParam_Write_Slot2 DSP_SlotParam_Write_Slot3 DSP_SlotParam_Write_Slot4 EFF_RoutingInit EnvTranspose_UpdateLoop Partial_Build_Present_Word ToneDB_Resolve_NamedToneRecord VoiceNoteParam_UpdateLoop VoiceParam_Update VoiceSlot_AltInit VoiceSlot_FullInit Voice_ActiveFlag_CheckAndLoad Voice_ActiveFlag_Set Voice_NoteState_Clear WaveSel_Cache_SetDescPtr WaveSel_Cache_VelSplitPtr WaveSel_Rebuild_PartCaches WaveSel_StageA2_FindSetDesc */


void VoiceSlot_AltInit(unsigned char part)
{
    unsigned char g;
    unsigned char k;

    AlgoType_StateWrite(part, 0);
    Voice_ActiveFlag_CheckAndLoad(part);
    DSP_SlotParam_Write_Slot0(part);
    DSP_SlotParam_Write_Slot1(part);
    DSP_SlotParam_Write_Slot2(part);
    DSP_SlotParam_Write_Slot3(part);
    DSP_SlotParam_Write_Slot4(part);
    Voice_InitFromSlot(part);
    EnvTranspose_UpdateLoop(part);
    for (g = 0; g < 3; g++) {
        for (k = 0; k < 4; k++) {
            AlgoFlag_Write_Bit3(part, g, k);
            AlgoFlag_Write(part, g, k);
        }
        for (k = 0; k < 4; k++)
            EFF_RoutingInit(part, k, g);
    }
    VoiceNoteParam_UpdateLoop(part);
}








