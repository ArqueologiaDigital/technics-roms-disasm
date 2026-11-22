/* Probe round 32r1, helper T, form a: sequencer/sequencer_engine.s (module 233).
   SeqPlay_ProcessTempoVoiceEvent: for a part whose voice byte is 0x0e, scan its events (saving and restoring the
   read position) for up to three note-ons (0x9n, note <= 0x10) and a controller 48 value; clear bit 0 of ram_45b
   when no controller value or fewer than three notes were found.  Status tests as if chains. */
/* cc900-module: SeqPlay_TempoVoice_ParseCtrl48 */

struct bo { unsigned int block; unsigned int offset; };

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned char __near ram_45b;
extern unsigned char Part_ReadVoiceByte(unsigned int, unsigned int);
extern void Part_ValidateVoiceChannel(unsigned int);
extern unsigned char SeqData_ReadNextByte(void);
extern void SeqData_AdvancePosition(void);
extern int SeqPlay_TempoVoice_ParseCtrl48(int *);
extern void SeqPlay_ProcessTempoVoiceEvent(unsigned char);

void SeqPlay_ProcessTempoVoiceEvent(unsigned char part)
{
    struct bo save;
    int v = -1;
    unsigned int cnt = 0;
    int ctl;
    unsigned char b;

    if (Part_ReadVoiceByte(0, part) != 0x0e)
        return;
    save.block = SEQ_DATA_BLOCK;
    save.offset = SEQ_DATA_OFFSET;
    Part_ValidateVoiceChannel(part);
    if (SEQ_ERROR_CODE != 0)
        goto restore;
    do {
        b = SeqData_ReadNextByte();
        if (b & 0x80) {
            if (b == 0x82 || b == 0x84 || b == 0x81)
                break;
            b &= 0xf0;
            if (b == 0x90) {
                SeqData_AdvancePosition();
                if (SEQ_ERROR_CODE != 0)
                    goto restore;
                if (SeqData_ReadNextByte() > 0x10)
                    break;
                SeqData_AdvancePosition();
                if (SEQ_ERROR_CODE != 0)
                    goto restore;
                cnt++;
            } else if (b == 0xb0) {
                if (SeqPlay_TempoVoice_ParseCtrl48(&ctl) < 0)
                    goto restore;
                if (ctl >= 0) {
                    if (ctl != 3)
                        goto restore;
                    v = ctl;
                }
            }
        }
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0)
            goto restore;
    } while (cnt < 3);
    if (v < 0)
        ram_45b &= ~0x01;
    if (cnt < 3)
        ram_45b &= ~0x01;
restore:
    SEQ_DATA_BLOCK = save.block;
    SEQ_DATA_OFFSET = save.offset;
}
