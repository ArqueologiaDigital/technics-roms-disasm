/* Probe round 32r1, helper T, form b: sequencer/sequencer_engine.s (module 233), as form a with the status tests
   as switches (case labels in reverse compare order) and the read byte not kept in a local. */
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
            switch (b) {
            case 0x81:
            case 0x84:
            case 0x82:
                goto done;
            }
            switch (b & 0xf0) {
            case 0xb0:
                if (SeqPlay_TempoVoice_ParseCtrl48(&ctl) < 0)
                    goto restore;
                if (ctl >= 0) {
                    if (ctl != 3)
                        goto restore;
                    v = ctl;
                }
                break;
            case 0x90:
                SeqData_AdvancePosition();
                if (SEQ_ERROR_CODE != 0)
                    goto restore;
                if (SeqData_ReadNextByte() > 0x10)
                    goto done;
                SeqData_AdvancePosition();
                if (SEQ_ERROR_CODE != 0)
                    goto restore;
                cnt++;
                break;
            }
        }
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0)
            goto restore;
    } while (cnt < 3);
done:
    if (v < 0)
        ram_45b &= ~0x01;
    if (cnt < 3)
        ram_45b &= ~0x01;
restore:
    SEQ_DATA_BLOCK = save.block;
    SEQ_DATA_OFFSET = save.offset;
}
