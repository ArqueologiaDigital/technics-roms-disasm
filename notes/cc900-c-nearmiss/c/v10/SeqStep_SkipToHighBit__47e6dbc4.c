/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_16m236c.c (2026-11-16-107-p6-r21)
   sha256 47e6dbc416b79d2bb1ccc13f0cabcd33b099e9dfb3d5683022b0fd31d27e3602 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near ram_2644;
extern unsigned int __near ram_2646;
extern unsigned char __near ram_264c;
extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
void SeqStep_SkipToHighBit(void)
{
    unsigned char b;
    SEQ_DATA_OFFSET = ram_2644;
    SEQ_DATA_BLOCK = ram_2646;
    SeqData_AdvancePosition();
    if (SEQ_ERROR_CODE != 0) return;
    for (;;) {
        if (SeqData_ReadNextByte() & 0x80) break;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) return;
    }
    b = SeqData_ReadNextByte();
    if (b == 0x82) return;
    if (b == 0x81) return;
    else {
        ram_2644 = SEQ_DATA_OFFSET;
        ram_2646 = SEQ_DATA_BLOCK;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) return;
        ram_264c = SeqData_ReadNextByte();
    }
}
