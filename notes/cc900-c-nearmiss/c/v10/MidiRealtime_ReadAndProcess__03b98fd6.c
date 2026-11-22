/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_V_33r1m302b.c (2026-11-22-19-p6-r86)
   sha256 03b98fd6a3aa7b8d29d07ed6087fc122a250788ddabf8f1bcd2a0bafea820a56 (tar-sha256); compiled at -Xr */
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
        if ((unsigned char)c == 0xfe) {
            if ((c = FileIO_ReadNextRecord()) < 0)
                return -1;
            i = c;
            if ((c = FileIO_ReadNextRecord()) < 0)
                return -1;
            i += c << 8;
        } else
            i = c;
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
        if ((unsigned char)c == 0xfe) {
            if ((c = FileIO_ReadNextRecord()) < 0)
                return -1;
            i = c;
            if ((c = FileIO_ReadNextRecord()) < 0)
                return -1;
            i += c << 8;
        } else
            i = c;
        ram_e9e7 += (unsigned int)i;
        break;
    }
    return 0;
}
