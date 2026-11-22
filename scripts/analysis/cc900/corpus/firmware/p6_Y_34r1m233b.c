/* Probe round 34r1, helper Y, form b: sequencer/sequencer_engine.s (module 233).
   SeqChanAssign_InitLoop as form a (8-byte frame, pointer byte copy, three assign call sites), with one spot
   changed: the step loop is a plain while (form a: goto to its bottom test). */
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
    unsigned char e[8];
    unsigned int i;
    unsigned char *p;
    unsigned char *d;
    unsigned char *s;
    unsigned char *end;
    int r;
    unsigned int len;

    if (ram_2326 < ram_23c0) {
        e[0] = 0x81;
        i = 0;
        while (i < ram_23c0 - ram_2326) {
            ToneVoice_AssignChannel(0x12, e, 1);
            i++;
        }
    }
    while (ram_2338[17].ev.b[0] != 0x82) {
        p = e;
        s = ram_2338[17].ev.b;
        d = p;
        end = p + 6;
        do
            *d++ = *s++;
        while (d < end);
        r = SeqEvent_GetParamLength(*p);
        if (r < 0) {
            SeqData_SetErrorCode(6);
            break;
        }
        len = (unsigned char)r;
        if (ram_2338[17].ev.b[0] == 0x81)
            ToneVoice_AssignChannel(0x12, e, len);
        else if (ram_1d62 != 1)
            ToneVoice_AssignChannel(0x12, e, len);
        else if (ram_1d64 <= ram_2338[17].count) {
            if (ram_1d64 != ram_2338[17].count || ram_1d66 < ram_2338[17].ev.b[1])
                ToneVoice_AssignChannel(0x12, e, len);
        }
        SeqPart_ReadEventStream(0x13, 0);
    }
    e[0] = 0x82;
    ToneVoice_AssignChannel(0x12, e, 1);
}
