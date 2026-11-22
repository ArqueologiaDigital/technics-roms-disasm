/* Probe round 36r1, helper B, form a: audio/note_voice_mapping.s (module 302), the unoptimised -Xr shape (the
   built note_voice_mapping_m302_xr.c's file; the run also compiles -O3 -Xr).
   ConfigureBanks_WriteReg(): one SMF meta event after its 0xff: the type byte, then
     0x05 (lyric): the length and the text into a 256-byte buffer (terminated); when the lyric hook ram_e9e7 is
          set, the length goes to the MIDI ring buffer, the text through StoreAndAdvance_Prologue2, then
          SeqFile_ParseHeader and Audio_ExternalCallback;
     0x2f (end of track): its length byte, then -3;
     0x51 (tempo): the length and the bytes; tempo = 234375 / (b0 << 8 | b1), clamped to 40..300, stored with
          bit 15 into ram_11f5, notified (SoundParam_NotifyChange 4 / 3) and kept in ram_e9eb;
     others: a variable length (FileIO_ReadMultiByteRecord) and that many bytes skipped.
   A read below 0 gives -1; otherwise 0.  `register` locals: the byte counter (XIZ, signed long: the loops compare
   it signed with the length) and the read value (int, WA: not live across a call; the ROM stores its low byte
   from L).  The clamp compares unsigned: the counter is cast there.  The default case
   stores the length and reloads it (two statements), the other cases test the assignment. */
/* cc900-module: FileIO_ReadMultiByteRecord FileIO_ReadNextRecord MidiRingBuf_WriteByte SeqFile_ParseHeader StoreAndAdvance_Prologue2 */

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
extern int ConfigureBanks_WriteReg(void);

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
        i = Math_DivideU32(0x39387, ((unsigned int)buf[0] << 8) + buf[1]);
        i = (unsigned long)i > 0x28 ? i : 0x28;
        i = (unsigned long)i < 0x12c ? i : 0x12c;
        ram_11f5 = i | 0x8000;
        SoundParam_NotifyChange(4, i, 3);
        SeqTimer_UpdateTempoReg();
        ram_e9eb = i;
        break;
    default:
        len = FileIO_ReadMultiByteRecord();
        if (len < 0)
            return -1;
        for (i = 0; i < len; i++)
            if (FileIO_ReadNextRecord() < 0)
                return -1;
        break;
    }
    return 0;
}
