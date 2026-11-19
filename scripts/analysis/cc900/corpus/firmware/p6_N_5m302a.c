/* lane_p6 helper N, round 5, form a: module 302 (audio/note_voice_mapping.s), new function.
   SongPlayer_ResetState: clears the song player's cells (bytes, words and longs at 0xe9c4 .. 0xec01) and
   re-initialises the track slots and the SysEx / MIDI ring buffers (tail jump).  The ROM loads the long zero
   into XWA anew for every store: no -O (the module's FileIO_ReadVariableLengthData matched at -Xr).
   cc900-options: -Xr
*/
/* cc900-module: FileIO_InitTrackSlots MidiRingBuf_Init SysexRingBuf_Init */

extern unsigned char __near ram_e9e4;
extern long __near ram_e9e7;
extern long __near ram_e9f5;
extern unsigned int __near ram_e9e5;
extern long __near ram_e9eb;
extern unsigned int __near ram_e9ef;
extern unsigned int __near ram_e9f1;
extern long __near ram_ebfd;
extern unsigned int __near ram_ec01;
extern unsigned char __near ram_e9c4;
extern void FileIO_InitTrackSlots(void);
extern void SysexRingBuf_Init(void);
extern void MidiRingBuf_Init(void);

void SongPlayer_ResetState(void)
{
	ram_e9e4 = 0;
	ram_e9e7 = 0;
	ram_e9f5 = 0;
	ram_e9e5 = 0;
	ram_e9eb = 0;
	ram_e9ef = 0;
	ram_e9f1 = 0;
	ram_ebfd = 0;
	ram_ec01 = 0;
	ram_e9c4 = 0;
	FileIO_InitTrackSlots();
	SysexRingBuf_Init();
	MidiRingBuf_Init();
}
