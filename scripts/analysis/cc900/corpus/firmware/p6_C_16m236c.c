/* Phase 6, lane_p6 helper C, round 16, module 236 (modules_v10.tsv) of v10 sequencer/seq_step_routines.s: two new
   routines from the memory-to-memory pool.  Moved cells are __near (or a field of the __near song record); the
   cells the ROM reaches with 24-bit operands (SEQ_CURRENT_SONG, SEQ_TRACK_MASK_COPY) are plain.
   - SeqStep_SkipToHighBit: from the saved position, skip to the next status byte; remember an event's position.
   - SeqStep_ByteBlockEA5F: copy the song back and compact it, keeping three song-record words across the reload
     (two in IZ / QIZ, one on the stack). */
/* cc900-module: SeqStep_FindAndCompact */

struct songrec {
    unsigned char p0[78];
    unsigned int blocks78;
    unsigned char p80[119];
    unsigned char song199;
    unsigned int mask200;
};

extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near ram_2644;
extern unsigned int __near ram_2646;
extern unsigned char __near ram_264c;
extern struct songrec __near SEQ_SONG_RECORD;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned int SEQ_TRACK_MASK_COPY;

extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern void SeqData_CopyBlockToBuffer(int);
extern void SeqStep_FindAndCompact(void);
extern void VoicePreset_LoadAndInitPan(int);

void SeqStep_SkipToHighBit(void)
{
    unsigned char b;
    SEQ_DATA_OFFSET = ram_2644;
    SEQ_DATA_BLOCK = ram_2646;
    SeqData_AdvancePosition();
    if (SEQ_ERROR_CODE != 0) return;
    for (;;) {
        if (SeqData_ReadNextByte() & 0x80) break;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) return;
    }
    b = SeqData_ReadNextByte();
    if (b == 0x82) return;
    if (b == 0x81) return;
    else {
        ram_2644 = SEQ_DATA_OFFSET;
        ram_2646 = SEQ_DATA_BLOCK;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) return;
        ram_264c = SeqData_ReadNextByte();
    }
}

void SeqStep_ByteBlockEA5F(void)
{
    unsigned int b, a, c;
    SEQ_SONG_RECORD.song199 = SEQ_CURRENT_SONG;
    SEQ_SONG_RECORD.mask200 = SEQ_TRACK_MASK_COPY;
    SeqData_CopyBlockToBuffer(SEQ_CURRENT_SONG);
    SeqStep_FindAndCompact();
    a = SEQ_SONG_RECORD.blocks78;
    b = SEQ_FREE_BLOCKS;
    c = SEQ_FREE_LIST_HEAD;
    VoicePreset_LoadAndInitPan(SEQ_CURRENT_SONG);
    SEQ_SONG_RECORD.blocks78 = a;
    SEQ_FREE_BLOCKS = b;
    SEQ_FREE_LIST_HEAD = c;
}
