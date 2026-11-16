/* Phase 6, lane_p6 helper A, round 16, form a: routines of sequencer/accompaniment_engine.s with memory-to-memory
   moves (poolmm_A).  V4.23 writes the move itself when one side is a __near cell. */
extern unsigned char __near ACC_CHORD_TYPE;
extern unsigned char __near ram_342a;
extern unsigned char __near ram_342b;
extern unsigned int __near ACC_CUR_BLOCK;
extern unsigned int __near ACC_CUR_READ_POS;
extern unsigned char Chord_TypeFamilyTable[];
extern unsigned char AccPart_BitToIndexTable[];
extern unsigned char *__near ACC_STYLE_RECORD;

/* cc900-name: AccTone_IBDC_Helper=AccTone_InlineBytecodeData_Code_Helper */
void AccTone_IBDC_Helper(void)
{
    unsigned char a;
    unsigned char *p;
    a = Chord_TypeFamilyTable[ACC_CHORD_TYPE];
    ram_342b = a;
    p = ACC_STYLE_RECORD;
    a = p[a];
    ram_342a = a;
    if (a != 255)
        return;
    ram_342a = *p;
    ram_342b = 0;
}

void AccPedal_DirectionA_Wrap_Helper(unsigned char bit)
{
    if (bit == 2)
        ACC_CUR_BLOCK = 0xfffe;
    else
        ACC_CUR_BLOCK = (*(unsigned int **)0x3426)[AccPart_BitToIndexTable[bit]];
    ACC_CUR_READ_POS = 6;
}
