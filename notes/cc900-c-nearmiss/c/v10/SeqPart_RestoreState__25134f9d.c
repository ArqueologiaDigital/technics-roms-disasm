/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_T_32r1m236a.c (2026-11-22-17-p6-r84)
   sha256 25134f9d686aebce966cfffd5a3e93730033a7733df5f468d0f30d8cba19b3b5 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned char __near ram_2652;
extern unsigned int __near ram_287d;
extern unsigned int __near ram_cef[];
extern unsigned int __near ram_d0f[];
extern unsigned int __near ram_265c;
extern unsigned int __near ram_265e;
extern void Part_WriteWordAndByte(unsigned int, unsigned int);
extern unsigned char Part_ReadVoiceBit7(unsigned int, unsigned int);
extern void PartCtrl_WriteByte_Indexed(int);
extern void Part_CheckAndReallocVoices(unsigned int);
void SeqPart_RestoreState(void)
{
    if (Part_ReadVoiceBit7(0, ram_2652) == 0)
        return;
    ram_265c = SEQ_DATA_BLOCK = ram_cef[(unsigned char)(ram_2652 - 1)];
    ram_265e = SEQ_DATA_OFFSET = ram_d0f[(unsigned char)(ram_2652 - 1)];
    PartCtrl_WriteByte_Indexed(0x82);
    ram_287d = ram_2652;
    Part_WriteWordAndByte(ram_265c, (unsigned char)ram_265e);
    Part_CheckAndReallocVoices(ram_265c);
}
