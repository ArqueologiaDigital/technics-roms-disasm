/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/seq_step_routines_m236.c (2026-11-16-122-p6-r24-staged)
   sha256 5eab8d749dbcf17b6ce7f9b5233568a4ce2967e047353a98628935d8a1b6ad3b (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern unsigned int __near ram_2644;
extern unsigned int __near ram_2646;
extern unsigned char __near ram_264c;
void SeqStep_SkipToHighBit(void)
{
    SEQ_DATA_OFFSET = ram_2644;
    SEQ_DATA_BLOCK = ram_2646;
    SeqData_AdvancePosition();
    if (SEQ_ERROR_CODE != 0) return;
    for (;;) {
        if (SeqData_ReadNextByte() & 0x80) break;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) return;
    }
    switch (SeqData_ReadNextByte()) {
    case 0x81:
    case 0x82:
        return;
    default:
        ram_2644 = SEQ_DATA_OFFSET;
        ram_2646 = SEQ_DATA_BLOCK;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) return;
        ram_264c = SeqData_ReadNextByte();
    }
}
