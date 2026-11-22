/* Probe round 33r1, helper W, form a: sequencer/sequencer_engine.s (module 233).
   SeqChanAssign_InitLoop: assign channel 0x12 an 0x81 event once per missing step (ram_23c0 - ram_2326), then
   walk the event stream of record 17 of the 8-byte {count, 6-byte event} array at 0x2338 until its 0x82 end mark:
   copy the event to the frame, get its parameter length, and assign it unless the saved position
   (ram_1d62 == 1: count ram_1d64, step ram_1d66) is not yet reached; end with an 0x82 event.
   A constant-indexed __near struct array element is V4.23's `lda base` + displacement (as the 43 other uses of
   0x2338, and SeqVoice_InitForRepeatMode's 0x2474 / 0x23e0 rows); the 6-byte event is a struct of bytes, whose
   struct copy is the ROM's byte loop (member address in two lda steps, as SeqPart_ReadEvent's copy into 0x23c2). */
/* cc900-module: SeqPart_ReadEventStream ToneVoice_AssignChannel */

struct ev6 { unsigned char b[6]; };
struct pos6 { unsigned int count; struct ev6 ev; };

extern struct pos6 __near ram_2338[];
extern unsigned int __near ram_2326;
extern unsigned int __near ram_23c0;
extern unsigned char __near ram_1d62;
extern unsigned int __near ram_1d64;
extern unsigned int __near ram_1d66;

extern void ToneVoice_AssignChannel(unsigned int, unsigned char *, unsigned int);
extern int SeqEvent_GetParamLength(unsigned int);
extern void SeqData_SetErrorCode(unsigned int);
extern void SeqPart_ReadEventStream(unsigned int, unsigned int);
extern void SeqChanAssign_InitLoop(void);

void SeqChanAssign_InitLoop(void)
{
    struct ev6 e;
    unsigned int i;
    int r;
    unsigned int len;

    if (ram_2326 < ram_23c0) {
        e.b[0] = 0x81;
        for (i = 0; i < ram_23c0 - ram_2326; i++)
            ToneVoice_AssignChannel(0x12, e.b, 1);
    }
    while (ram_2338[17].ev.b[0] != 0x82) {
        e = ram_2338[17].ev;
        r = SeqEvent_GetParamLength(e.b[0]);
        if (r < 0) {
            SeqData_SetErrorCode(6);
            break;
        }
        len = (unsigned char)r;
        if (ram_2338[17].ev.b[0] == 0x81 || ram_1d62 != 1
            || (ram_1d64 <= ram_2338[17].count && (ram_1d64 != ram_2338[17].count || ram_1d66 < ram_2338[17].ev.b[1])))
            ToneVoice_AssignChannel(0x12, e.b, len);
        SeqPart_ReadEventStream(0x13, 0);
    }
    e.b[0] = 0x82;
    ToneVoice_AssignChannel(0x12, e.b, 1);
}
