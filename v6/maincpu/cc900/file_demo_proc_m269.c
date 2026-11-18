/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near SEQ_RTMCFG;
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

void InitializeOperationState(unsigned char a)
{
    SeqBuf_Init();
    NoteMap_SendAllNotesOff();
    Part_ReinitAllActive();
    AccWrap_PlayModeDispatch();
    if (a != 0) SEQ_RTMCFG |= 4;
    AccompSeq_StopSequence();
    AudioInit_RefreshToneBank();
    NoteMap_ProcessAndMerge();
    Voice_InitializeAll();
    Voice_InitTablePair();
    Voice_InitTableGroup();
    MIDI_SendAllSoundOff();
    MidiIn_IgnoreClockTransport();
}

/* cc900-module: ResetProgressIndication */
#define TT_MESAGE   0xee
#define TT_DKUTFRMT 0x7d
extern unsigned char GetDiskSizeInfo(void);
extern void UI_ChangeTitleByIndex(unsigned int);
extern void UI_InterruptTitleByIndex(unsigned int);
extern void ResetProgressIndication(void);
extern int __near DISK_MEDIA_TYPE;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern unsigned char ram_340f4;
extern void FileIO_DiskEventDispatch(unsigned char a, unsigned char c);

void FileIO_DiskEventDispatch(unsigned char a, unsigned char c)
{
	if (DISK_MEDIA_TYPE < 0) DISK_MEDIA_TYPE = GetDiskSizeInfo();
	switch (DISK_MEDIA_TYPE) {
	case 3:
	case 2:
		if (ram_340f4 & 1) UI_ChangeTitleByIndex(c);
		else UI_ChangeTitleByIndex(a);
		break;
	case 5:
		GLOBAL_ERROR_CODE = 0;
		UI_InterruptTitleByIndex(TT_MESAGE);
		break;
	case 0:
		UI_ChangeTitleByIndex(TT_DKUTFRMT);
		break;
	case 1:
		ResetProgressIndication();
		GLOBAL_ERROR_CODE = 2;
		UI_InterruptTitleByIndex(TT_MESAGE);
		break;
	}
}

extern void FileIO_GetDiskCapacity(unsigned char a);

void FileIO_GetDiskCapacity(unsigned char a)
{
	if (DISK_MEDIA_TYPE < 0) DISK_MEDIA_TYPE = GetDiskSizeInfo();
	switch (DISK_MEDIA_TYPE) {
	case 5:
		GLOBAL_ERROR_CODE = 0;
		UI_InterruptTitleByIndex(TT_MESAGE);
		break;
	case 0:
		UI_ChangeTitleByIndex(TT_DKUTFRMT);
		break;
	case 1:
		ResetProgressIndication();
		GLOBAL_ERROR_CODE = 2;
		UI_InterruptTitleByIndex(TT_MESAGE);
		break;
	case 2:
	case 3:
		UI_ChangeTitleByIndex(a);
		break;
	}
}
