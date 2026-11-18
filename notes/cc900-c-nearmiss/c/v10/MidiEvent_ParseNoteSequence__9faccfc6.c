/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_4m296b.c (2026-11-18-33-p6-r37)
   sha256 9faccfc6e2a866f03c40578df5f70a02176260be73f50424772d9e9c4e05d2ee (tar-sha256); compiled at -Xr */
struct noteseq { unsigned char status; unsigned char count; unsigned char b2; unsigned char b3;
                 unsigned char e[32][5]; };
extern unsigned int SeqBuf_NoteEvent_ReadByte(void);
extern void NoteMap_ProcessAndMerge(void);
unsigned char MidiEvent_ParseNoteSequence(unsigned char *end, struct noteseq *seq)
{
    unsigned int n;
    unsigned int a;
    unsigned int b;

    n = 0;
    seq->status = 0x90;
    seq->b2 = 0;
    seq->b3 = 0;
    if (*end != 0xff)
        do {
            a = SeqBuf_NoteEvent_ReadByte();
            if (a == 0xffff) {
                *end = 0xff;
                break;
            }
            b = SeqBuf_NoteEvent_ReadByte();
            if (b == 0xffff) {
                *end = 0xff;
                break;
            }
            if (n < 32) {
                seq->e[n][4] = 0;
                seq->e[n][0] = a;
                seq->e[n][1] = b;
            }
            n++;
        } while (*end != 0xff);
    if (n <= 32)
        return seq->count = n;
    NoteMap_ProcessAndMerge();
    seq->count = 0;
    return 0;
}
