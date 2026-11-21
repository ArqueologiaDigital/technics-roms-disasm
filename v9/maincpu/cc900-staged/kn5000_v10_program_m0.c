/* Functions of kn5000_v9_program.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void CPanel_InitButtonState_SaveRegs(void);
extern void RefreshSwEvent(void);
extern void RefreshApTask(void);
extern void EditSwRefresh(void);
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char *GetAdr_rtmcfg(void);
extern unsigned char __near SEQ_BEAT_TICK;
extern unsigned char *GetAdr_sq_beadt(void);
extern unsigned char __near SEQ_BEAT_COUNT;
unsigned char *GetAdr_sqbtof(void);
unsigned char *GetAdr_sq_beadt(void);
extern unsigned char *GetAdr_sqbtof(void);
extern unsigned char __near SEQ_TRANSPORT_STATE;
unsigned char *GetAdr_sqsrtc(void);
unsigned char *GetAdr_rtmcfg(void);
extern unsigned char *GetAdr_sqsrtc(void);
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
void PlayHalt(unsigned char f);
extern void PlayHalt(unsigned char f);
extern unsigned char __near GLOBAL_ERROR_CODE;
void SetGlobalError(unsigned char e);
extern void SetGlobalError(unsigned char e);
extern void __cdecl Free(void *);
void free_X(void *p);
extern void free_X(void *p);
extern void *__cdecl Malloc(unsigned int);
void *malloc_X(unsigned int n);
extern void *malloc_X(unsigned int n);
extern void __cdecl SeqMain_WriteByte(int);
void putc_mrx_bf_X(unsigned char c);
extern void putc_mrx_bf_X(unsigned char c);
extern void __cdecl SeqBuf_MidiOut_WriteByte(int);
void putc_mtx_bf_X(unsigned char c);
extern void putc_mtx_bf_X(unsigned char c);

void EditSwRefresh(void)
{
	CPanel_InitButtonState_SaveRegs();
	RefreshSwEvent();
	RefreshApTask();
}

unsigned char *GetAdr_rtmcfg(void)
{
	return &SEQ_RTMCFG;
}

unsigned char *GetAdr_sq_beadt(void)
{
	return &SEQ_BEAT_TICK;
}

unsigned char *GetAdr_sqbtof(void)
{
	return &SEQ_BEAT_COUNT;
}

unsigned char *GetAdr_sqsrtc(void)
{
	return &SEQ_TRANSPORT_STATE;
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

void SetGlobalError(unsigned char e)
{
	GLOBAL_ERROR_CODE = e;
}

void free_X(void *p)
{
	Free(p);
}

void *malloc_X(unsigned int n)
{
	return Malloc(n);
}

void putc_mrx_bf_X(unsigned char c)
{
	SeqMain_WriteByte(c);
}

void putc_mtx_bf_X(unsigned char c)
{
	SeqBuf_MidiOut_WriteByte(c);
}
