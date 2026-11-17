/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/seq_step_routines_m236.c (2026-11-16-122-p6-r24-staged)
   sha256 31fdc3c356af02b573e844fcff55985a7695a42f9941a0d45c90346f3a1e3dda (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern unsigned int __near ram_262a;
extern unsigned int __near ram_262c;
extern unsigned char __near ram_2632;
void SeqStep_SkipToHighBit(void)
{
    SEQ_DATA_OFFSET = ram_262a;
    SEQ_DATA_BLOCK = ram_262c;
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
        ram_262a = SEQ_DATA_OFFSET;
        ram_262c = SEQ_DATA_BLOCK;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) return;
        ram_2632 = SeqData_ReadNextByte();
    }
}
