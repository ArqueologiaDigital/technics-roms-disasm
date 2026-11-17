/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_17m236b.c (2026-11-16-118-p6-r23)
   sha256 f1ea83ec20e8c44a2de5a0f6c3be7c330b41c15f78f837d98d74f707d6166fde (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near ram_2644;
extern unsigned int __near ram_2646;
extern unsigned char __near ram_264c;
extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
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
        break;
    default:
        ram_2644 = SEQ_DATA_OFFSET;
        ram_2646 = SEQ_DATA_BLOCK;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) return;
        ram_264c = SeqData_ReadNextByte();
    }
}
