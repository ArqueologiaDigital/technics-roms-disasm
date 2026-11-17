/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/seq_step_routines_m236.c (2026-11-16-125-p6-r26-staged)
   sha256 d11050dfeadfd21b0ce26f5699b64a6cecb85b4a38fb55b9073d50adb044d3ab (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near ram_2722;
extern unsigned int __near ram_2724;
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
    SEQ_DATA_BLOCK = ram_2722;
    SEQ_DATA_OFFSET = ram_2724;
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
        ram_2722 = SEQ_DATA_BLOCK;
        ram_2724 = SEQ_DATA_OFFSET;
    }
    SEQ_DATA_OFFSET = ram_2724;
    SEQ_DATA_BLOCK = ram_2722;
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
