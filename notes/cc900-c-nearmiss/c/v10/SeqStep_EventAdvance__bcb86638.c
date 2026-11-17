/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_18m236b.c (2026-11-16-123-p6-r25)
   sha256 bcb86638b119451c83c8bfa3fdb83a742624daa7bdff100bb305a8a8f3c1d41b (tar-sha256); compiled at -O3 -Xr */
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
    while (c != 0x81) {
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) break;
        d = c;
        c = SeqData_ReadNextByte();
        PartCtrl_WriteByte_Indexed(d);
        if (d & 0x80) c = 0;
    }
    goto restore;
}
