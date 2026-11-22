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
extern unsigned char __near ram_8dac;
extern unsigned char __near ram_8dae;
extern unsigned char __near ram_8db0;
extern void SoundParam_NotifyChange(long, int, int);
extern void BitMapOut_DetectChanges(void);
extern void ToneGen_DiffScanAndUpdate(void);
extern void SoundParam_NotifyMultipleChanges(void);

void SoundParam_NotifyMultipleChanges(void)
{
	SoundParam_NotifyChange(0, ram_8dac, 0);
	SoundParam_NotifyChange(0x102, ram_8dae, 0);
	SoundParam_NotifyChange(0x103, ram_8db0, 0);
	BitMapOut_DetectChanges();
	ToneGen_DiffScanAndUpdate();
}

/* cc900-module: PanelButton_DispatchChange PanelButton_FetchChange PanelInput_QueueChange VoiceEntry_FindMasterVolume */
struct pevt { unsigned char code, a, b, c; };
extern unsigned char __near ram_8dcc;
extern unsigned char __near ram_8dce;
extern unsigned char __near ram_8dd0;
extern struct pevt __near PANEL_EVENT_QUEUE[];
extern unsigned char *PanelInput_ChangeQueue(void);
extern void PanelButton_FetchChange(void);
extern void PanelButton_DispatchChange(void);
extern void PanelInput_ClearChangeQueue(void);
extern void VoiceEntry_FindMasterVolume(void);
extern void PanelButton_ProcessChanges(void);

void PanelButton_ProcessChanges(void)
{
	ram_8dcc = 0;
	ram_8dce = 0;
	while ((ram_8dd0 = PanelInput_ChangeQueue()[(int)ram_8dcc * 3]) != 0xff) {
		PanelButton_FetchChange();
		PanelButton_DispatchChange();
	}
	PANEL_EVENT_QUEUE[ram_8dce].code = 0xff;
	PanelInput_ClearChangeQueue();
	VoiceEntry_FindMasterVolume();
}

extern unsigned char __near ram_8db2;
extern unsigned char __near ram_8db4;
extern unsigned char __near PANEL_RECORDS[];
extern unsigned char __near PANEL_PART_RT1[];
extern unsigned char __near PANEL_PART_RT2[];
extern unsigned char __near PANEL_PART_LEFT[];
extern unsigned char __near PANEL_PMEM_SETTINGS[];
extern unsigned char PANEL_RECALL_BACKUP[];
extern int SndParam_LookupReadOnly(long);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void SndParam_SyncDisplayBitmap(void);

void SndParam_SyncDisplayBitmap(void)
{
    ram_8dac = SndParam_LookupReadOnly(0);
    ram_8dae = SndParam_LookupReadOnly(0x102);
    ram_8db0 = SndParam_LookupReadOnly(0x103);
    ram_8db2 = SndParam_LookupReadOnly(0x300);
    ram_8db4 = SndParam_LookupReadOnly(0x4006);
    Mem_Copy(PANEL_RECALL_BACKUP, PANEL_RECORDS, 0x620);
    PANEL_RECALL_BACKUP[PANEL_PART_RT1 - PANEL_RECORDS] ^= 1;
    PANEL_RECALL_BACKUP[PANEL_PART_RT2 - PANEL_RECORDS] ^= 1;
    PANEL_RECALL_BACKUP[PANEL_PART_LEFT - PANEL_RECORDS] ^= 1;
    PANEL_RECALL_BACKUP[&PANEL_PMEM_SETTINGS[1] - PANEL_RECORDS] |= 0x7f;
}
