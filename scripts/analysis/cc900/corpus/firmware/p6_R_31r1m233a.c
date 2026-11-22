/* Probe round 31r1, helper R, form a: sequencer/sequencer_engine.s, module 233:
   Part_ReadAndProcessVoiceData: count a part's 0x81 events up to max, stopping before 0x82 / 0x84;
   SeqCh_CountEventsAndCalcPos: sum channel 0x12's parameter lengths in units of 0xfb bytes. */

struct bo { unsigned int block; unsigned int offset; };
struct cnt { unsigned int whole; unsigned int rest; };
extern struct bo __near ram_24fc;
extern struct bo __near ram_2424;
extern unsigned char __near ram_23c2;
extern unsigned char Part_ReadVoiceBit7(unsigned int, unsigned int);
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern void SeqPart_ReadNextEventByte(struct bo *, unsigned char *);
extern void SeqCh_LoadChannelConfig(unsigned int);
extern int SeqEvent_GetParamLength(unsigned int);
extern void SeqData_SetErrorCode(unsigned int);
extern int Part_ReadAndProcessVoiceData(unsigned char part, unsigned int max, struct bo *pos);
extern void SeqCh_CountEventsAndCalcPos(struct cnt *r);

int Part_ReadAndProcessVoiceData(unsigned char part, unsigned int max, struct bo *pos)
{
    unsigned int n;
    struct bo save;
    unsigned char ev[10];

    n = 0;
    if (Part_ReadVoiceBit7(0, part) == 0) return -1;
    pos->block = Part_ReadVoiceWord(0, part);
    pos->offset = 5;
    while (n < max) {
        save.block = pos->block;
        save.offset = pos->offset;
        SeqPart_ReadNextEventByte(pos, ev);
        if (ev[0] == 0x81)
            n++;
        else if (ev[0] == 0x82 || ev[0] == 0x84) {
            pos->block = save.block;
            pos->offset = save.offset;
            break;
        }
    }
    return n;
}

void SeqCh_CountEventsAndCalcPos(struct cnt *r)
{
    struct bo t;
    unsigned int sum;
    int len;

    r->whole = 0;
    sum = 0;
    t = ram_24fc;
    ram_2424 = t;
    for (;;) {
        SeqCh_LoadChannelConfig(0x12);
        if (ram_23c2 == 0x82) break;
        len = SeqEvent_GetParamLength(ram_23c2);
        if (len < 0) {
            SeqData_SetErrorCode(7);
            continue;
        }
        sum += len;
        if (sum >= 0xfb) {
            sum -= 0xfb;
            r->whole++;
        }
    }
    r->rest = (unsigned char)(sum & 0xff);
}
