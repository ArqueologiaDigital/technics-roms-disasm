/* Functions of audio/tonegen_fileio_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PanelTlv_ApplyFieldRule PanelTlv_ValidateBlock0 PanelTlv_WriteBlock0Headers */   /* scripts/analysis/cc900/module_calls.py v10 */

struct tlvlay { unsigned long off; unsigned char *rules; };
extern unsigned int PanelTlv_ApplyFieldRule(unsigned char *base, unsigned char *rule);
extern void PanelTlv_ValidateRecord(unsigned char *base, struct tlvlay *l);
extern int PanelTlv_Rule_ClearBits(unsigned char *rec, unsigned char *r);
extern void PanelTlv_WriteRecordHeader(unsigned char *buf, unsigned char *rec);
extern void FlashWrite(int, unsigned char *, unsigned int, long);
extern unsigned char *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern void *__cdecl Memset(void *, int, unsigned int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void Gfx_ClearFrameBuffers(void);
extern unsigned char SndParamBank_OptionDefault_00[], SndParamBank_OptionDefault_10[], SndParamBank_OptionDefault_20[];
extern unsigned char SndParamBank_OptionDefault_30[], SndParamBank_OptionDefault_40[];
extern void SndParamBank_RestoreOptionBlock(void);

void PanelTlv_ValidateRecord(unsigned char *base, struct tlvlay *l)
{
    unsigned char *r;
    base += l->off + 2;
    r = l->rules;
    while (*r != 0xff)
        r += PanelTlv_ApplyFieldRule(base, r);
}

int PanelTlv_Rule_ClearBits(unsigned char *rec, unsigned char *r)
{
	rec[r[1]] &= ~r[2];
	return 3;
}

void PanelTlv_WriteRecordHeader(unsigned char *buf, unsigned char *rec)
{
	buf += *(long *)rec;
	buf[0] = rec[8];
	buf[1] = rec[9];
}

void SndParamBank_RestoreOptionBlock(void)
{
	unsigned char *b;

	b = Malloc(0x50);
	if (b == 0) return;
	Memset(b, 0x50, 0);
	Mem_Copy(b, (void *)0x3d3400L, 2);
	Mem_Copy(b + 16, SndParamBank_OptionDefault_10, 12);
	Mem_Copy(b + 32, SndParamBank_OptionDefault_20, 4);
	Mem_Copy(b + 48, SndParamBank_OptionDefault_30, 4);
	Mem_Copy(b + 64, SndParamBank_OptionDefault_40, 6);
	FlashWrite(1, b, 0x50, 0x3d3400L);
	Free(b);
	Gfx_ClearFrameBuffers();
}

extern unsigned char ram_1ed400[];
extern void PanelTlv_ValidateBlock0(unsigned char *mem);
extern void PanelTlv_ValidatePanelMemory(unsigned int n);
extern void PanelTlv_ValidatePanelMemories(void);
extern void PanelTlv_WriteBlock0Headers(unsigned char *mem);
extern void PanelTlv_WritePanelMemoryHeaders(void);

void PanelTlv_ValidatePanelMemory(unsigned int n)
{
    unsigned char *p;
    if (n < 80) {
        p = ram_1ed400 + (unsigned long)n * 960;
        PanelTlv_ValidateBlock0(p);
    }
}
void PanelTlv_ValidatePanelMemories(void)
{
    unsigned int i;
    unsigned char *p;
    for (i = 0, p = ram_1ed400; i < 80; i++, p += 960)
        PanelTlv_ValidateBlock0(p);
}
void PanelTlv_WritePanelMemoryHeaders(void)
{
    unsigned int i;
    unsigned char *p;
    for (i = 0, p = ram_1ed400; i < 80; i++, p += 960)
        PanelTlv_WriteBlock0Headers(p);
}

/* cc900-module: SndParamBank_WriteFlashDefaults */
extern void SndParamBank_WriteFlashDefaults(void);
extern unsigned char SndParamBank_DefaultHeader[];
extern void SndParamBank_CheckFlash(void);

void SndParamBank_CheckFlash(void)
{
	unsigned char *s, *d;
	unsigned int i;

	s = SndParamBank_DefaultHeader;
	d = (unsigned char *)0x3d3000L;
	for (i = 0; i < 3; i++)
		if (*d++ != *s++) {
			SndParamBank_WriteFlashDefaults();
			return;
		}
}

/* cc900-module: ToneGen_DiffScanAndUpdate */
extern unsigned char __near ram_8e6c;
extern unsigned char __near ram_8e6e;
extern unsigned char __near ram_8e70;
extern void SoundParam_NotifyChange(long, int, int);
extern void BitMapOut_DetectChanges(void);
extern void ToneGen_DiffScanAndUpdate(void);
extern void SoundParam_NotifyMultipleChanges(void);

void SoundParam_NotifyMultipleChanges(void)
{
	SoundParam_NotifyChange(0, ram_8e6c, 0);
	SoundParam_NotifyChange(0x102, ram_8e6e, 0);
	SoundParam_NotifyChange(0x103, ram_8e70, 0);
	BitMapOut_DetectChanges();
	ToneGen_DiffScanAndUpdate();
}

/* cc900-module: PanelButton_DispatchChange PanelButton_FetchChange PanelInput_QueueChange VoiceEntry_FindMasterVolume */
struct pevt { unsigned char code, a, b, c; };
extern unsigned char __near ram_8e8c;
extern unsigned char __near ram_8e8e;
extern unsigned char __near ram_8e90;
extern struct pevt __near PANEL_EVENT_QUEUE[];
extern unsigned char *PanelInput_ChangeQueue(void);
extern void PanelButton_FetchChange(void);
extern void PanelButton_DispatchChange(void);
extern void PanelInput_ClearChangeQueue(void);
extern void VoiceEntry_FindMasterVolume(void);
extern void PanelButton_ProcessChanges(void);

void PanelButton_ProcessChanges(void)
{
	ram_8e8c = 0;
	ram_8e8e = 0;
	while ((ram_8e90 = PanelInput_ChangeQueue()[(int)ram_8e8c * 3]) != 0xff) {
		PanelButton_FetchChange();
		PanelButton_DispatchChange();
	}
	PANEL_EVENT_QUEUE[ram_8e8e].code = 0xff;
	PanelInput_ClearChangeQueue();
	VoiceEntry_FindMasterVolume();
}
