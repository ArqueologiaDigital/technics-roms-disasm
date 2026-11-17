/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_7m265a.c (2026-11-16-100-p6-r19)
   sha256 6635aad8f8b5d142e3e884cb9d5361fb7eb6c0b1768f4c1e677eb539c459c83f (tar-sha256); compiled at -O3 -Xr */
extern void sendCOMM(int, int, unsigned char *);
extern int SeqBuf_NoteEvent_CheckSongEnd(void);
extern void SeqBuf_NoteEvent_CopyPointers(void);
extern int Seq_RingBuf_ReadSmall(void);
extern unsigned char ram_247f4[];
extern unsigned char ram_247f0;
extern unsigned char FDemoText_VoiceActiveBit[];
void FDemoText_ScanMIDIChannels(void)
{
    unsigned char msg[6];
    unsigned char resp[16];
    unsigned char ch;
    unsigned int timeout;
    unsigned char st;
    unsigned char v;
    unsigned int n;
    int c;
    unsigned char *p;

    msg[0] = 0x80;
    msg[1] = 0;
    msg[2] = 0x17;
    msg[3] = 2;
    msg[4] = 1;
    msg[5] = 0xea;
    sendCOMM(0, 6, msg);
    msg[1] = 1;
    sendCOMM(0, 6, msg);
    msg[1] = 2;
    sendCOMM(0, 6, msg);
    timeout = 0;
    while (SeqBuf_NoteEvent_CheckSongEnd() == 0) {
        if (++timeout > 10000)
            break;
    }
    SeqBuf_NoteEvent_CopyPointers();
    for (ch = 0; ch <= 2; ch++) {
        st = 0xff;
        while (timeout < 10000) {
            timeout++;
            while ((c = Seq_RingBuf_ReadSmall()) >= 0) {
                n = 1;
                resp[0] = c;
                while (n < 6 && (c = Seq_RingBuf_ReadSmall()) >= 0) {
                    resp[n] = c;
                    n++;
                }
                if (resp[0] == 0x80)
                    resp[3] = 2;
                while (n < (unsigned char)(resp[3] + 6) && (c = Seq_RingBuf_ReadSmall()) >= 0) {
                    resp[n] = c;
                    if (n >= 16)
                        break;
                    n++;
                }
                if ((unsigned char)(resp[3] + 6) == n && resp[5] == 0xea) {
                    v = resp[7];
                    if (v == 0xf || v == 0x35)
                        st = 1;
                    else
                        st = 0;
                    ram_247f4[ch] = v;
                }
                if (st != 0xff)
                    break;
            }
            if (st != 0xff)
                break;
        }
        p = &FDemoText_VoiceActiveBit[ch];
        if (st == 1)
            ram_247f0 |= *p;
        else
            ram_247f0 &= ~*p;
    }
}
