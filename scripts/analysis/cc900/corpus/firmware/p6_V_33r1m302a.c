/* Probe round 33r1, helper V, form a: audio/note_voice_mapping.s (module 302), -Xr code.
   MidiRealtime_ReadAndProcess(st): one system / realtime event of the song file.  Bit 4 of ram_e9e5 = stopped
   (returns -3); 0xfc sets it; 0xf0 collects a SysEx message up to 0xf7 into a 128-byte buffer and sends it
   (MIDI_SendSinglePacket) when it fits; every other status goes to VoiceReset_Return_Prologue.  Then the delta time
   follows (an optional 0xff prefix outside SysEx; 0xfe = two-byte little-endian value), added to the long at
   ram_e9e7.  Returns 0, -1 at the end of the data (FileIO_ReadNextRecord < 0). */
/* cc900-module: FileIO_ReadNextRecord MIDI_SendSinglePacket VoiceReset_Return_Prologue */

extern unsigned int __near ram_e9e5;
extern unsigned long __near ram_e9e7;
extern int FileIO_ReadNextRecord(void);
extern void MIDI_SendSinglePacket(unsigned int len, unsigned char *buf);
extern int VoiceReset_Return_Prologue(unsigned int st);

int MidiRealtime_ReadAndProcess(register unsigned char st)
{
    unsigned char buf[128];
    register int i = 0;
    register int c;

    i = 0;
    if (ram_e9e5 & 0x10)
        return -3;
    switch (st) {
    case 0xfc:
        ram_e9e5 |= 0x10;
        break;
    case 0xf0:
        i = 1;
        buf[i - 1] = st;
        do {
            if ((c = FileIO_ReadNextRecord()) < 0)
                return -1;
            i++;
            if (i < 0x80)
                buf[i - 1] = c;
        } while (c != 0xf7);
        if (i <= 0x80)
            MIDI_SendSinglePacket(i, buf);
        if ((c = FileIO_ReadNextRecord()) < 0)
            return -1;
        switch ((unsigned char)c) {
        case 0xfe:
            if ((c = FileIO_ReadNextRecord()) < 0)
                return -1;
            i = c;
            if ((c = FileIO_ReadNextRecord()) < 0)
                return -1;
            i += c << 8;
            break;
        default:
            i = c;
            break;
        }
        ram_e9e7 += (unsigned int)i;
        break;
    default:
        if ((c = VoiceReset_Return_Prologue(st)) < 0)
            return c;
        if ((c = FileIO_ReadNextRecord()) < 0)
            return -1;
        if ((unsigned char)c == 0xff) {
            if ((c = FileIO_ReadNextRecord()) < 0)
                return -1;
        }
        switch ((unsigned char)c) {
        case 0xfe:
            if ((c = FileIO_ReadNextRecord()) < 0)
                return -1;
            i = c;
            if ((c = FileIO_ReadNextRecord()) < 0)
                return -1;
            i += c << 8;
            break;
        default:
            i = c;
            break;
        }
        ram_e9e7 += (unsigned int)i;
        break;
    }
    return 0;
}
