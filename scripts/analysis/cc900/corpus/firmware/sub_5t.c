/* lane_sub probe round 5: a tail call to a module-local callee (cc900-module:), the ROM's `jr` after an `lda`.
   cc900-module: RingBuf_ReadByte */
struct ring { unsigned int wr; unsigned int rd; unsigned int count; unsigned char data[4096]; };
extern struct ring __near MIDI_RingBuffer;
int RingBuf_ReadByte(struct ring *r);

int RingBuf_ReadByte_MidiRing(void) { return RingBuf_ReadByte(&MIDI_RingBuffer); }
