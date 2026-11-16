/* Phase 6, probe m14 (form b): larger leaf functions of v10's audio/note_voice_mapping.s (an -O file), each under its
   firmware name.  FileIO_InitTrackSlots / SysexRingBuf_Init: a 2048-byte ring buffer at a constant address (two
   indexes, the size, then the bytes). */
extern unsigned char SndParam_LogCurve128[], CHORD_DECAY_TIMER;
extern unsigned int AUDIO_CONFIG_FLAGS;
struct rb { unsigned int head, tail, size; unsigned char data[2048]; };
struct pair { unsigned char a, b; };
void FileIO_InitTrackSlots(void) { unsigned int i; struct rb *r = (struct rb *)0xd0a8; r->head = 0; r->tail = 0; r->size = 2047; for (i = 0; i < r->size; i++) r->data[i] = 0; }
void SysexRingBuf_Init(void) { unsigned int i; struct rb *r = (struct rb *)0xd8ae; r->head = 0; r->tail = 0; r->size = 2047; for (i = 0; i < r->size; i++) r->data[i] = 0; }
void Voice_SetDecayTimer(int a, unsigned int n) { if (!(AUDIO_CONFIG_FLAGS & 2) || n > 2) CHORD_DECAY_TIMER = 6; else CHORD_DECAY_TIMER = 22; }
int SndParam_CompactLookupStub(unsigned char i) { unsigned char v = SndParam_LogCurve128[i]; return v; }
int LinkVoiceSlots_LoadReg(struct pair *p, unsigned char c) { return p[c].b != c; }
