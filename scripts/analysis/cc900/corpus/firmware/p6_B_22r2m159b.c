/* lane_p6 helper B, round 22r2, form a: module 159 (kn5000_v10_program.s, between VoiceSynth_CmdCase0 and
   setwall_routines.s), from roots23_B's pooled stretch at f1ea20.
   GetResouceInfo: a 10-case switch through RESOURCE_INFO_HANDLER_OFFSETS based at its first case body
   (RESOURCE_INFO_HANDLERS); case bodies in ROM block order 0, 1, 2, 6, 9, 3, 4, 5, 7, 8; each fills {address, size}.
   SetSepaOutMode: five 4-byte control-change templates copied into the frame (struct assignment = ldiw ldiw), then
   a compare chain on the mode (bodies 0, 1, 2, 3; compares in reverse source order) of six sendCOMM calls each.
   PlayHalt, PlayStandBy, EditSwRefresh, putc_mtx_bf_X, putc_mrx_bf_X, GetAdr_sqbtof / _sq_beadt / _sqsrtc /
   _rtmcfg, SetGlobalError, malloc_X, free_X: the small roots of the same stretch.
   Skipped: the one-instruction `jp` thunks (fopen_ext ... pdly_tim_X, rcm_*_XAPR_j, midi_out_en_X).
   Form b (= form a except): templates as struct { int w0, w1; } with the part byte written through a byte pointer
   to the copy; GetResouceInfo's case 0 end address as a byte pointer + 2.
   cc900-options: -O3 -Xr
*/
/* cc900-data: GetResouceInfo 1 = RESOURCE_INFO_HANDLER_OFFSETS */
/* cc900-name: ResInfo_Str_TEST=ResInfo_GetResourceListPtr_Str_TEST */

struct resinfo { long addr; long size; };
struct cc4 { int w0, w1; };
#define SEND(m, p) ((unsigned char *)&(m))[1] = (p); sendCOMM(0, 4, (unsigned char *)&(m))

extern unsigned char __near LIVE_PANEL_BLOCK[];
extern unsigned int __near ram_ffbe;
extern unsigned char ram_1e7800[];
extern unsigned char ram_1e8000[];
extern unsigned char ram_1ed350[];
extern unsigned char ram_200000[];
extern unsigned char ram_1e0000[];
extern unsigned char SEQ_SONG_SLOTS[];
extern unsigned char ram_b0000[];
extern unsigned char ram_fd800[];
extern unsigned char RHYTHM_PATTERN_BUF_A[];
extern unsigned char ram_1e8800[];
extern unsigned char ram_1ec400[];
extern char ResInfo_Str_TEST[];

extern const struct cc4 SepaOut_Config_0;
extern const struct cc4 SepaOut_Msg_CC9B_Value32;
extern const struct cc4 SepaOut_Msg_CC9D_Value0;
extern const struct cc4 SepaOut_Msg_CC9D_Value1;
extern const struct cc4 SepaOut_Msg_CC9D_Value2;
extern void sendCOMM(int, int, unsigned char *);

extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near SEQ_BEAT_COUNT;
extern unsigned char __near SEQ_BEAT_TICK;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned char __near GLOBAL_ERROR_CODE;

extern void SeqBuf_Init(void);
extern void NoteMap_SendAllNotesOff(void);
extern void Part_ReinitAllActive(void);
extern void AccWrap_PlayModeDispatch(void);
extern void AccompSeq_StopSequence(void);
extern void AudioInit_RefreshToneBank(void);
extern void NoteMap_ProcessAndMerge(void);
extern void Voice_InitializeAll(void);
extern void Voice_InitTablePair(void);
extern void Voice_InitTableGroup(void);
extern void MIDI_SendAllSoundOff(void);
extern void MidiIn_IgnoreClockTransport(void);
extern void SeqAcc_InitPlaybackState(void);
extern void MidiIn_AcceptClockTransport(void);
extern void CPanel_InitButtonState_SaveRegs(void);
extern void RefreshSwEvent(void);
extern void RefreshApTask(void);
extern void __cdecl SeqBuf_MidiOut_WriteByte(int);
extern void __cdecl SeqMain_WriteByte(int);
extern void *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);

void GetResouceInfo(unsigned int type, struct resinfo *r);
void SetSepaOutMode(unsigned int mode);
void PlayHalt(unsigned char f);
void PlayStandBy(void);
void EditSwRefresh(void);
void putc_mtx_bf_X(unsigned char c);
void putc_mrx_bf_X(unsigned char c);
unsigned char *GetAdr_sqbtof(void);
unsigned char *GetAdr_sq_beadt(void);
unsigned char *GetAdr_sqsrtc(void);
unsigned char *GetAdr_rtmcfg(void);
void SetGlobalError(unsigned char e);
void *malloc_X(unsigned int n);
void free_X(void *p);

void GetResouceInfo(unsigned int type, struct resinfo *r)
{
	switch (type) {
	case 0:
		r->addr = (long)LIVE_PANEL_BLOCK;
		r->size = (long)((unsigned char *)&ram_ffbe + 2) - (long)LIVE_PANEL_BLOCK;
		break;
	case 1:
		r->addr = (long)ram_1e7800;
		r->size = (long)ram_1e8000 - (long)ram_1e7800;
		break;
	case 2:
		r->addr = (long)ram_1ed350;
		r->size = (long)ram_200000 - (long)ram_1ed350;
		break;
	case 6:
		r->addr = (long)ram_1e0000;
		r->size = (long)ram_1e7800 - (long)ram_1e0000;
		break;
	case 9:
		r->addr = 0x3d3000L;
		r->size = 0x400L;
		break;
	case 3:
		r->addr = (long)SEQ_SONG_SLOTS;
		r->size = 0x5000L;
		break;
	case 4:
		r->addr = (long)ram_b0000;
		r->size = (long)ram_fd800 - (long)ram_b0000;
		break;
	case 5:
		r->addr = (long)RHYTHM_PATTERN_BUF_A;
		r->size = (long)SEQ_SONG_SLOTS - (long)RHYTHM_PATTERN_BUF_A;
		break;
	case 7:
		r->addr = (long)ram_1e8800;
		r->size = (long)ram_1ec400 - (long)ram_1e8800;
		break;
	case 8:
		r->addr = (long)ResInfo_Str_TEST;
		r->size = 0;
		break;
	}
}

void SetSepaOutMode(unsigned int mode)
{
	struct cc4 m0 = SepaOut_Config_0;
	struct cc4 m1 = SepaOut_Msg_CC9B_Value32;
	struct cc4 m2 = SepaOut_Msg_CC9D_Value0;
	struct cc4 m3 = SepaOut_Msg_CC9D_Value1;
	struct cc4 m4 = SepaOut_Msg_CC9D_Value2;

	switch (mode) {
	case 0:
		SEND(m0, 0x14);
		SEND(m2, 0x14);
		SEND(m0, 0x13);
		SEND(m2, 0x13);
		SEND(m0, 0x16);
		SEND(m2, 0x16);
		break;
	case 1:
		SEND(m1, 0x14);
		SEND(m2, 0x14);
		SEND(m0, 0x13);
		SEND(m2, 0x13);
		SEND(m0, 0x16);
		SEND(m2, 0x16);
		break;
	case 2:
		SEND(m1, 0x14);
		SEND(m2, 0x14);
		SEND(m1, 0x13);
		SEND(m2, 0x13);
		SEND(m1, 0x16);
		SEND(m2, 0x16);
		break;
	case 3:
		SEND(m1, 0x14);
		SEND(m4, 0x14);
		SEND(m1, 0x13);
		SEND(m3, 0x13);
		SEND(m1, 0x16);
		SEND(m3, 0x16);
		break;
	}
}

void PlayHalt(unsigned char f)
{
	SeqBuf_Init();
	NoteMap_SendAllNotesOff();
	Part_ReinitAllActive();
	AccWrap_PlayModeDispatch();
	if (f != 0) SEQ_RTMCFG |= 4;
	AccompSeq_StopSequence();
	AudioInit_RefreshToneBank();
	NoteMap_ProcessAndMerge();
	Voice_InitializeAll();
	Voice_InitTablePair();
	Voice_InitTableGroup();
	MIDI_SendAllSoundOff();
	MidiIn_IgnoreClockTransport();
}

void PlayStandBy(void)
{
	if (SEQ_RTMCFG & 4) SEQ_RTMCFG &= ~4;
	SEQ_RTMCFG &= ~8;
	SeqAcc_InitPlaybackState();
	MidiIn_AcceptClockTransport();
}

void EditSwRefresh(void)
{
	CPanel_InitButtonState_SaveRegs();
	RefreshSwEvent();
	RefreshApTask();
}

void putc_mtx_bf_X(unsigned char c)
{
	SeqBuf_MidiOut_WriteByte(c);
}

void putc_mrx_bf_X(unsigned char c)
{
	SeqMain_WriteByte(c);
}

unsigned char *GetAdr_sqbtof(void)
{
	return &SEQ_BEAT_COUNT;
}

unsigned char *GetAdr_sq_beadt(void)
{
	return &SEQ_BEAT_TICK;
}

unsigned char *GetAdr_sqsrtc(void)
{
	return &SEQ_TRANSPORT_STATE;
}

unsigned char *GetAdr_rtmcfg(void)
{
	return &SEQ_RTMCFG;
}

void SetGlobalError(unsigned char e)
{
	GLOBAL_ERROR_CODE = e;
}

void *malloc_X(unsigned int n)
{
	return Malloc(n);
}

void free_X(void *p)
{
	Free(p);
}
