/* Phase 6, lane_p6 helper A, round 16, form b: routines of sequencer/accompaniment_engine.s with memory-to-memory
   moves (poolmm_A); no locals, the record pointer at 0x3426 a __near extern. */
extern unsigned char __near ACC_CHORD_TYPE;
extern unsigned char __near ram_342a;
extern unsigned char __near ram_342b;
extern unsigned int __near ACC_CUR_BLOCK;
extern unsigned int __near ACC_CUR_READ_POS;
extern unsigned char Chord_TypeFamilyTable[];
extern unsigned char AccPart_BitToIndexTable[];
extern unsigned char *__near ACC_STYLE_RECORD;
extern unsigned int *__near ram_3426;

/* cc900-name: AccTone_IBDC_Helper=AccTone_InlineBytecodeData_Code_Helper */
void AccTone_IBDC_Helper(void)
{
    ram_342b = Chord_TypeFamilyTable[ACC_CHORD_TYPE];
    if ((ram_342a = ACC_STYLE_RECORD[ram_342b]) != 255)
        return;
    ram_342a = ACC_STYLE_RECORD[0];
    ram_342b = 0;
}

void AccPedal_DirectionA_Wrap_Helper(unsigned char bit)
{
    if (bit != 2)
        ACC_CUR_BLOCK = ram_3426[AccPart_BitToIndexTable[bit]];
    else
        ACC_CUR_BLOCK = 0xfffe;
    ACC_CUR_READ_POS = 6;
}
