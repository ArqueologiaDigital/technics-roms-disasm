/* Functions of sequencer/seq_step_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near ram_2722;
extern unsigned int __near ram_2724;
extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern void PartCtrl_WriteByte_Indexed(int);
extern void SeqStep_EventAdvance(void);

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
