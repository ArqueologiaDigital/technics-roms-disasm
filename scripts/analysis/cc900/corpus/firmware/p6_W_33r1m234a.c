/* Probe round 33r1, helper W, form a: sequencer/sequencer_engine.s (module 234).
   SeqVoice_InitForRepeatMode: point the cursors of channels 16 / 18 (block 1) and 17 (block 2) at offset 5 in both
   cursor arrays (0x2474: 8-byte rows, 0x23e0: 4-byte rows), write one 0x81 step per measure of the repeat range
   (ram_2328 .. ram_232a) and an 0x82 end into block 1, set the step counts of records 16 / 17 of 0x2338, then load
   channel 0x11 and read the 0x13 stream.  The address-taken locals take the frame in reverse declaration order
   (cursor lowest).  Constant-indexed struct array rows are V4.23's lda base + displacement. */
/* cc900-module: Part_CopyBytesToVoiceBlock SeqCh_LoadChannelConfig SeqVoice_FindChannelSetup */

struct cur { unsigned int blk, off; };
struct cur8 { struct cur c; unsigned char pad[4]; };
struct pos6 { unsigned int count; unsigned char ev[6]; };

extern struct cur8 __near ram_2474[];
extern struct cur __near ram_23e0[];
extern struct pos6 __near ram_2338[];
extern unsigned int __near ram_2328;
extern unsigned int __near ram_232a;

extern void SeqVoice_FindChannelSetup(void);
extern void Part_CopyBytesToVoiceBlock(struct cur *, unsigned char *, unsigned int);
extern void SeqCh_LoadChannelConfig(unsigned int);
extern void SeqPart_ReadEventStream(unsigned int, unsigned int);
extern void SeqVoice_InitForRepeatMode(void);

void SeqVoice_InitForRepeatMode(void)
{
    unsigned char step;
    unsigned char end;
    struct cur c;
    unsigned int i;

    step = 0x81;
    end = 0x82;
    SeqVoice_FindChannelSetup();
    ram_2474[16].c.blk = 1;
    ram_2474[16].c.off = 5;
    ram_2474[18].c.blk = 1;
    ram_2474[18].c.off = 5;
    ram_2474[17].c.blk = 2;
    ram_2474[17].c.off = 5;
    ram_23e0[16].blk = 1;
    ram_23e0[16].off = 5;
    ram_23e0[18].blk = 1;
    ram_23e0[18].off = 5;
    ram_23e0[17].blk = 2;
    ram_23e0[17].off = 5;
    c.blk = 1;
    c.off = 5;
    for (i = 0; i <= ram_232a - ram_2328; i++)
        Part_CopyBytesToVoiceBlock(&c, &step, 1);
    Part_CopyBytesToVoiceBlock(&c, &end, 1);
    ram_2338[16].count = ram_2328;
    ram_2338[17].count = ram_2328;
    SeqCh_LoadChannelConfig(0x11);
    SeqPart_ReadEventStream(0x13, 1);
}
