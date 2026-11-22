/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_36r1m232a.c (2026-11-22-25-p6-r92)
   sha256 02e672a8f1c90beeed939b136e57d65c6abf1190b433714831cc9e5d194f458d (tar-sha256); compiled at -O3 -Xr
   cc900-name: BmDrEdit_DecrValidateCounter=BmDrEdit_DecrementAndValidateCounter */
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
