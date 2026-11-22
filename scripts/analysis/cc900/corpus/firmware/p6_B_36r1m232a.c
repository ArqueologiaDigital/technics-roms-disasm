/* Probe round 36r1, helper B, form a: sequencer/bmdredit_routines.s (module 232), the xr_screen.py shape at -O3 -Xr.
   BmDrEdit_ApplyVelocityChange(part, data, count): open a gap of count bytes in a part's song data and write data
   into it.  0 bytes: nothing (0); more than 255: -1.  The song-data cursor (SEQ_DATA_BLOCK / OFFSET) is saved;
   the part's end position (block, offset) is read, the new end is count bytes on (into the next block, linked
   with Part_LinkVoiceToChain when there is none: error 0xbb, -1, on failure) and written back; then the bytes
   from the old end down to the cursor are copied backward to the new end, and the data bytes written at the
   cursor.  The cursor is restored; 0.
   Frame (after the IZ push): saved block +2, saved offset +4, new offset +6, new block +8, old offset +10, old
   block +12 (declared first, so highest), then the parameters count +14, data +16, part +20.  The data index is
   the `register` local (IZ).  The link result is tested in the assignment (the ROM compares HL, signed); the
   PartCtrl_ReadWord result is tested from the frame. */
/* cc900-module: BmDrEdit_DecrementAndValidateCounter PartCtrl_ReadByteExtended PartCtrl_WriteByte_ZeroExtended */
/* cc900-name: BmDrEdit_DecrValidateCounter=BmDrEdit_DecrementAndValidateCounter */

extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int Part_ReadWord_Indexed(unsigned int, unsigned int);
extern unsigned int Part_ReadByte_Indexed(unsigned int, unsigned int);
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);
extern unsigned int PartCtrl_ReadWord(unsigned int);
extern unsigned int Part_LinkVoiceToChain(unsigned int);
extern void SeqData_SetErrorCode(unsigned int);
extern unsigned char PartCtrl_ReadByteExtended(unsigned int, unsigned int);
extern void PartCtrl_WriteByte_ZeroExtended(unsigned int, unsigned int, unsigned int);
extern int BmDrEdit_DecrValidateCounter(unsigned int *, unsigned int *);
extern void PartCtrl_WriteByte_Indexed(unsigned int);
extern void SeqData_AdvancePosition(void);
extern int BmDrEdit_ApplyVelocityChange(unsigned char, unsigned char *, unsigned int);

int BmDrEdit_ApplyVelocityChange(unsigned char part, unsigned char *data, unsigned int count)
{
    unsigned int sblk;
    unsigned int soff;
    unsigned int dblk;
    unsigned int doff;
    unsigned int saveoff;
    unsigned int saveblk;
    register unsigned int i;

    if (count == 0)
        return 0;
    if (count > 0xff)
        return -1;
    saveblk = SEQ_DATA_BLOCK;
    saveoff = SEQ_DATA_OFFSET;
    sblk = Part_ReadWord_Indexed(0, part);
    soff = Part_ReadByte_Indexed(0, part);
    dblk = sblk;
    doff = soff + count;
    if (doff > 0xff) {
        dblk = PartCtrl_ReadWord(sblk);
        if (dblk == 0xffff) {
            if ((int)(dblk = Part_LinkVoiceToChain(sblk)) < 0) {
                SeqData_SetErrorCode(0xbb);
                return -1;
            }
        }
        doff -= 0xff;
        doff += 4;
    }
    Part_WriteWord_Indexed(0, part, dblk);
    Part_WriteByte_Indexed(0, part, (unsigned char)doff);
    for (;;) {
        PartCtrl_WriteByte_ZeroExtended(dblk, doff, PartCtrl_ReadByteExtended(sblk, soff));
        if (SEQ_DATA_BLOCK == sblk && SEQ_DATA_OFFSET == soff)
            break;
        BmDrEdit_DecrValidateCounter(&sblk, &soff);
        BmDrEdit_DecrValidateCounter(&dblk, &doff);
    }
    for (i = 0; i < count; i++) {
        PartCtrl_WriteByte_Indexed(data[i]);
        SeqData_AdvancePosition();
    }
    SEQ_DATA_BLOCK = saveblk;
    SEQ_DATA_OFFSET = saveoff;
    return 0;
}
