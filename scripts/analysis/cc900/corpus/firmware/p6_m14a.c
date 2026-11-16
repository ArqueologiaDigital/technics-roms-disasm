/* Phase 6, probe m14 (form a): larger leaf functions of v10's audio/note_voice_mapping.s (an -O file), each under its
   firmware name.  FileIO_InitTrackSlots / SysexRingBuf_Init: a 2048-byte ring buffer at a constant address (two
   indexes, the size, then the bytes). */
extern unsigned char SndParam_LogCurve128[], CHORD_DECAY_TIMER;
extern unsigned int AUDIO_CONFIG_FLAGS;
struct rb { unsigned int head, tail, size; unsigned char data[2048]; };
struct pair { unsigned char a, b; };
void FileIO_InitTrackSlots(void) { unsigned int i; ((struct rb *)0xd0a8)->head = 0; ((struct rb *)0xd0a8)->tail = 0; ((struct rb *)0xd0a8)->size = 2047; for (i = 0; i < ((struct rb *)0xd0a8)->size; i++) ((struct rb *)0xd0a8)->data[i] = 0; }
void SysexRingBuf_Init(void) { unsigned int i; ((struct rb *)0xd8ae)->head = 0; ((struct rb *)0xd8ae)->tail = 0; ((struct rb *)0xd8ae)->size = 2047; for (i = 0; i < ((struct rb *)0xd8ae)->size; i++) ((struct rb *)0xd8ae)->data[i] = 0; }
void Voice_SetDecayTimer(int a, unsigned int n) { if ((AUDIO_CONFIG_FLAGS & 2) && n <= 2) CHORD_DECAY_TIMER = 22; else CHORD_DECAY_TIMER = 6; }
unsigned char SndParam_CompactLookupStub(unsigned char i) { return SndParam_LogCurve128[i]; }
int LinkVoiceSlots_LoadReg(struct pair *p, unsigned char c) { if (p[c].b == c) return 0; return 1; }
