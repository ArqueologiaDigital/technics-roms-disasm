/* Functions of kn5000_v10_program.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char SubCPU_SendPayloadEnableFlag;
extern unsigned char SubCPU_FlashPayloadEnableFlag;
extern unsigned int __near ram_404;
extern void InterCPU_E1_Bulk_Transfer();
extern int SLIDE_Parse_Header(long, long);
extern void SubCPU_Send_Payload(void);

void SubCPU_Send_Payload(void)
{
    unsigned long a;
    if (SubCPU_SendPayloadEnableFlag != 0xff) return;
    for (a = 0; a < 0x2000; a++)
        ;
    InterCPU_E1_Bulk_Transfer(0x830000L, 0x10000L, 0x50000L);
    InterCPU_E1_Bulk_Transfer(0x840000L, 0x10000L, 0x60000L);
    InterCPU_E1_Bulk_Transfer(0x850000L, 0x10000L, 0x70000L);
    InterCPU_E1_Bulk_Transfer(0x860000L, 0x10000L, 0x80000L);
    InterCPU_E1_Bulk_Transfer(0x870000L, 0x10000L, 0x90000L);
    a = 0x800000L;
    if (SubCPU_FlashPayloadEnableFlag == 0xff) {
        a = 0x50000L;
        if (SLIDE_Parse_Header(0x3e0000L, 0x50000L) == -1) a = 0x800000L;
    }
    ram_404 = *(unsigned int *)(a + 0x100);
    InterCPU_E1_Bulk_Transfer(a + 0x100, 0x10000L, 0xf000L);
    InterCPU_E1_Bulk_Transfer(a + 0x10100L, 0x10000L, 0x1f000L);
    InterCPU_E1_Bulk_Transfer(a + 0x20100L, 0xff00, 0x2f000L);
    InterCPU_E1_Bulk_Transfer(a, 0x100, 0x400L);
    for (a = 0; a < 0x100000L; a++)
        ;
}

/* cc900-module: DrawBox DrawFunc_Return DrawQueue_Alloc DrawRing_Post DrawString IS_XSP_INSIDE_4K_REGION_AT_1C032 TextRender_BeginDraw */
struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
struct dq { void *fn; struct rect r; struct pt p; char *s; long font; int a; int b; unsigned char mode; };
extern unsigned char COLORBLIT_MODE_ACTIVE;
extern int DRAW_ENABLED;
extern void DrawFunc_Return(void *p);
extern void TextRender_BeginDraw(struct rect *, struct pt *, char *, long, int, int);
extern void DrawText_PopAndReturn_Code(struct dq *q);

void DrawText_PopAndReturn_Code(struct dq *q)
{
    struct rect *r;
    struct pt *p;
    long font;
    int a;
    int b;

    r = &q->r;
    p = &q->p;
    font = q->font;
    a = q->a;
    b = q->b;
    COLORBLIT_MODE_ACTIVE = q->mode;
    if (DRAW_ENABLED != 0)
        TextRender_BeginDraw(r, p, q->s, font, a, b);
    DrawFunc_Return(q->s);
}

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

extern int __cdecl ParseInt16(char *);
extern int Boot_ParseSubCPUTimestamp(void);
extern int Boot_ParseTableDataTimestamp(void);

int Boot_ParseSubCPUTimestamp(void)
{
	return ParseInt16((char *)0x87fff5L);
}
int Boot_ParseTableDataTimestamp(void)
{
	return ParseInt16((char *)0x9fffc4L);
}
