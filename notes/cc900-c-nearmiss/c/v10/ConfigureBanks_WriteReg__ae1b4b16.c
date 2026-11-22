/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_36r1m302b.c (2026-11-22-25-p6-r92)
   sha256 ae1b4b1662aac3728fde2a96c0f7b8a3d6554377d47a31a49c148700ae7bdefb (tar-sha256); compiled at -Xr */
extern long __near ram_e9e7;
extern long __near ram_e9eb;
extern unsigned int __near ram_11f5;
extern int FileIO_ReadNextRecord(void);
extern long FileIO_ReadMultiByteRecord(void);
extern int MidiRingBuf_WriteByte(int);
extern int StoreAndAdvance_Prologue2(unsigned int, unsigned char *);
extern void SeqFile_ParseHeader(void);
extern void Audio_ExternalCallback(void);
extern unsigned long Math_DivideU32(unsigned long, unsigned long);
extern void SoundParam_NotifyChange(long, int, int);
extern void SeqTimer_UpdateTempoReg(void);
int ConfigureBanks_WriteReg(void)
{
    unsigned char buf[256];
    long len;
    register long i;
    register int c;

    if ((c = FileIO_ReadNextRecord()) < 0)
        return -1;
    switch ((unsigned char)c) {
    case 5:
        if ((len = FileIO_ReadNextRecord()) < 0)
            return -1;
        for (i = 0; i < len; i++) {
            if ((c = FileIO_ReadNextRecord()) < 0)
                return -1;
            buf[i] = c;
        }
        buf[i] = 0;
        if (ram_e9e7 != 0) {
            MidiRingBuf_WriteByte((unsigned char)len);
            StoreAndAdvance_Prologue2(len, buf);
            SeqFile_ParseHeader();
            Audio_ExternalCallback();
        }
        break;
    case 0x2f:
        if (FileIO_ReadNextRecord() < 0)
            return -1;
        return -3;
    case 0x51:
        if ((len = FileIO_ReadNextRecord()) < 0)
            return -1;
        for (i = 0; i < len; i++) {
            if ((c = FileIO_ReadNextRecord()) < 0)
                return -1;
            buf[i] = c;
        }
        i = Math_DivideU32(0x39387, buf[1] + ((unsigned int)buf[0] << 8));
        i = (unsigned long)i > 0x28 ? i : 0x28;
        i = (unsigned long)i < 0x12c ? i : 0x12c;
        ram_11f5 = i | 0x8000;
        SoundParam_NotifyChange(4, i, 3);
        SeqTimer_UpdateTempoReg();
        ram_e9eb = i;
        break;
    default:
        if ((len = FileIO_ReadMultiByteRecord()) < 0)
            return -1;
        for (i = 0; i < len; i++)
            if (FileIO_ReadNextRecord() < 0)
                return -1;
        break;
    }
    return 0;
}
