/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_18m236a.c (2026-11-16-123-p6-r25)
   sha256 7ba6e473026ab6bfb7ea46b81abc6ac996b61d62257e6bc289cdb0a48a2b5a1f (tar-sha256); compiled at -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near ram_273c;
extern unsigned int __near ram_273e;
extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern void PartCtrl_WriteByte_Indexed(int);
void SeqStep_EventAdvance(void)
{
    unsigned char c, d;
    unsigned int blk, off;
    blk = SEQ_DATA_BLOCK;
    off = SEQ_DATA_OFFSET;
    if (!(SEQ_EDIT_FLAGS & 1)) return;
    SEQ_DATA_BLOCK = ram_273c;
    SEQ_DATA_OFFSET = ram_273e;
    for (;;) {
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) {
restore:
            SEQ_DATA_BLOCK = blk;
            SEQ_DATA_OFFSET = off;
            return;
        }
        if (SeqData_ReadNextByte() == 0x7f) break;
        do {
            SeqData_AdvancePosition();
            if (SEQ_ERROR_CODE != 0) goto restore;
        } while (!(SeqData_ReadNextByte() & 0x80));
        ram_273c = SEQ_DATA_BLOCK;
        ram_273e = SEQ_DATA_OFFSET;
    }
    SEQ_DATA_OFFSET = ram_273e;
    SEQ_DATA_BLOCK = ram_273c;
    c = SeqData_ReadNextByte();
    PartCtrl_WriteByte_Indexed(0x81);
    for (;;) {
        if (c == 0x81) goto restore;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) goto restore;
        d = c;
        c = SeqData_ReadNextByte();
        PartCtrl_WriteByte_Indexed(d);
        if (d & 0x80) c = 0;
    }
}
