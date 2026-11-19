/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AL_26a.c (2026-11-19-30-sub-r26a)
   sha256 053890dd60837e738fe353af1697989105b37f380ad816b39b57b6455beaa9c1 (name+funcs); compiled at -Xr
   cc900-options: -Xr
   cc900-name: AudioChannel_AllVoices_UpdVar3=AudioChannel_AllVoices_Update_Variant3 */
extern unsigned char ram_4136e[];
extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern void InterCPU_E1_DMA_Transfer(unsigned char *d, unsigned int n, unsigned char *s);
extern unsigned char *Voice_Query_PartVoices(int part);
extern unsigned char *Voice_AllocateForSustain(int part);
extern void Voice_AllNotes_SustainRetrigger(unsigned char *list, unsigned char flag);
extern void AudioChannel_AllVoices_UpdVar3(unsigned char *list);
void DSP_SlotParam_Write_From_Cache_B(unsigned char slot);
void DSP_SlotParam_Read_To_Cache_B(unsigned char part, unsigned char slot);
#define DMA_DEST(off)   ((off) + (unsigned char *)0x1e0000)
void Audio_Cmd_ToneEdit_Write_And_Reply(register unsigned char *m)
{
    unsigned char *buf;

    buf = ToneDB_Find_SubToneRecord((unsigned char *)*(unsigned long *)(ram_4136e + (int)m[1] * 287),
                                    ram_4531c[29351], m[1]);
    buf[(unsigned long)(unsigned int)m[2]] = m[4];
    switch (m[2]) {
    case 0x19: case 0x1b: case 0x2e: case 0x30:
        AudioChannel_AllVoices_UpdVar3(Voice_Query_PartVoices(m[1]));
        break;
    case 0x1d: case 0x32:
        Voice_AllNotes_SustainRetrigger(Voice_AllocateForSustain(m[1]), 1);
        break;
    case 0x1f:
        if (m[5] == 7)
            DSP_SlotParam_Write_From_Cache_B(0);
        break;
    case 0x34:
        if (m[5] == 7)
            DSP_SlotParam_Write_From_Cache_B(1);
        break;
    case 0x21: case 0x22: case 0x23: case 0x24:
        DSP_SlotParam_Read_To_Cache_B(m[1], 0);
    case 0x36: case 0x37: case 0x38: case 0x39:
        DSP_SlotParam_Read_To_Cache_B(m[1], 1);
        break;
    }
    InterCPU_E1_DMA_Transfer(buf, 58, DMA_DEST((int)ram_4531c[29351] * 80 + 19111));
}
