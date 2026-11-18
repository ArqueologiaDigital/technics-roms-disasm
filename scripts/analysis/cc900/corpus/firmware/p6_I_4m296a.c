/* Phase 6, lane_p6 helper I, round 4, module 296 (audio/note_voice_mapping.s), form a.  New.
   MidiEvent_ParseNoteSequence(end, seq): builds a note-on record {0x90, count, 0, 0, then up to 32 five-byte
   entries {note, velocity, ., ., 0}} from byte pairs read with SeqBuf_NoteEvent_ReadByte until *end is 0xff (set
   to 0xff when a read returns 0xffff); more than 32 pairs merge through NoteMap_ProcessAndMerge and give 0.
   Returns the count as a byte.
   Read from the hand assembly: the count (+4), the first byte (+6, stored and reloaded) and end (+8) in the frame,
   seq in XIZ, the second byte in HL; each entry address recomputed (n * 5 + 4 + seq, no CSE: -Xr); the loop tests
   *end at entry and at the bottom (if + do-while).  The entries are a byte array (V4.23 pads structs to even
   sizes).  Form b: the count returned through the record's byte. */

struct noteseq { unsigned char status; unsigned char count; unsigned char b2; unsigned char b3;
                 unsigned char e[32][5]; };

extern unsigned int SeqBuf_NoteEvent_ReadByte(void);
extern void NoteMap_ProcessAndMerge(void);
extern unsigned char MidiEvent_ParseNoteSequence(unsigned char *end, struct noteseq *seq);

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
    if (n <= 32) {
        seq->count = n;
        return n;
    }
    NoteMap_ProcessAndMerge();
    seq->count = 0;
    return 0;
}
