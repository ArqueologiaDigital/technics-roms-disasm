/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_X_21r2m269d.c (2026-11-21-9-p6-r64)
   sha256 17d2a34dfeb53109e76a11f8a40822fe25ddd90d4ebcf5f7ecdeecb80a3fe9e1 (tar-sha256); compiled at -O3 -Xr */
#define EVT_SHOW                     0x1c00001L
#define EVT_HIDE                     0x1c00002L
#define EVT_ALL_PAINT                0x1c0000aL
#define EVT_PAINT                    0x1c0000bL
#define EVT_ACTIVATE_STATE           0x1c00013L
#define EVT_INDEXSW_UP               0x1c00017L
#define EVT_INDEXSW_DOWN             0x1c00018L
#define EVT_SET_HOLD                 0x1e0009aL
#define EVT_SET_SELECTED_FILE_NUMBER 0x1e50002L
#define EVT_GET_SELECTED_FILE_NUMBER 0x1e50003L
#define EVT_PS_FILE_NAME_BOX_ID      0x1e50004L
#define EVT_I_WILL_WAKE_UP           0x1e50008L
#define EVT_WAKE_UP_TIME             0x1e50009L
#define EVT_WAKE_UP_NOW              0x1e5000aL
#define TT_MESAGE                    0xee
extern unsigned char __near MEDLEY_PLAY_FLAG;
extern int __near ram_8504;
extern unsigned char __near ram_88a0[];
extern unsigned char __near ram_8920;
extern unsigned char __near ram_8922;
extern unsigned char __near ram_8924;
extern unsigned char __near PREVIOUS_TITLE;
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern long ApPostEvent(long, long, long);
extern void InitializeOperationState(int);
extern unsigned char Medley_GetPlaybackStatus(void);
extern void UI_InterruptTitleByIndex(unsigned int);
extern void UI_ChangeTitleByIndex(unsigned int);
extern void SignalProgressUpdate(void);
extern void CDlike_InitModeAndLoadBank(void);
extern void CDlike_ExitModeAndRestore(void);
extern void CancelOperationCleanup(void);
#define EVT_SET_PARAM                0x1e0003bL
#define TT_DPSMF                     0x6f
#define TT_DPMDLYSMF                 0x73
extern long __near ram_8430;
extern long __near ram_8434;
extern unsigned int __near ram_8438;
extern unsigned char __near ram_843a;
extern unsigned char __near ram_843c;
extern unsigned char __near SmfMidiOut_OnOff;
extern int GetFileCountEncoded(void);
extern unsigned char *FileIO_SearchAndLoadFile(void);
extern long GetEncodedFreeSpaceData(void);
extern void GetFileEntryByIndex(unsigned int);
extern long FmmSmfFileNameFunc(long, long, long);
extern void SmfMed_FormatSlotList(long, unsigned int);
long FmmSmfMedleyFunc(long obj, long ev, long p)
{
	unsigned int i;
	unsigned int k;
	unsigned int n;
	unsigned char c;
	unsigned char v;

	switch (ev) {
	case EVT_ACTIVATE_STATE:
		switch (p) {
		case 2:
			InitializeOperationState(0);
			ram_843a = PREVIOUS_TITLE;
			if (ram_843a == 0x6f || ram_843a == 0x72) {
				MEDLEY_PLAY_FLAG = 0;
				switch (Medley_GetPlaybackStatus()) {
				case 2:
					GLOBAL_ERROR_CODE = 1;
					UI_InterruptTitleByIndex(TT_MESAGE);
					break;
				case 3:
					GLOBAL_ERROR_CODE = 49;
					UI_InterruptTitleByIndex(TT_MESAGE);
					break;
				case 4:
					GLOBAL_ERROR_CODE = 63;
					UI_InterruptTitleByIndex(TT_MESAGE);
					break;
				}
			} else if (ram_843a == 0x73 || ram_843a == 0x76) {
				if (Medley_GetPlaybackStatus() >= 1) {
					switch (Medley_GetPlaybackStatus()) {
					case 2:
						GLOBAL_ERROR_CODE = 1;
						UI_InterruptTitleByIndex(TT_MESAGE);
						ram_843c++;
						break;
					case 3:
						GLOBAL_ERROR_CODE = 49;
						UI_InterruptTitleByIndex(TT_MESAGE);
						ram_843c++;
						break;
					case 4:
						GLOBAL_ERROR_CODE = 63;
						UI_InterruptTitleByIndex(TT_MESAGE);
						ram_843c++;
						break;
					}
					MEDLEY_PLAY_FLAG = 1;
					if (ram_8922 < ram_8920) {
						for (i = 0; i < ram_8438; i++) {
							if (ram_88a0[i] == ram_8922) {
								FmmSmfFileNameFunc(obj, EVT_SET_SELECTED_FILE_NUMBER, i);
								SmfMed_FormatSlotList(ram_8430, ram_8438);
								ram_8922++;
								GetFileEntryByIndex(i);
								if (ram_8434 != 0)
									ApPostEvent(ram_8434, EVT_WAKE_UP_TIME, 30);
								break;
							}
						}
					} else if (ram_8924 != 0 && ram_843c < ram_8922) {
						ram_8922 = 0;
						ram_843c = 0;
						for (i = 0; i < ram_8438; i++) {
							if (ram_88a0[i] == 0) {
								FmmSmfFileNameFunc(obj, EVT_SET_SELECTED_FILE_NUMBER, i);
								SmfMed_FormatSlotList(ram_8430, ram_8438);
								ram_8922++;
								GetFileEntryByIndex(i);
								if (ram_8434 != 0)
									ApPostEvent(ram_8434, EVT_WAKE_UP_TIME, 30);
								break;
							}
						}
					} else {
						ram_843c = 0;
						MEDLEY_PLAY_FLAG = 0;
					}
				} else if (Medley_GetPlaybackStatus() == 0) {
					MEDLEY_PLAY_FLAG = 0;
				}
			} else {
				ApPostEvent(0x6c0018L, EVT_SET_PARAM, SmfMidiOut_OnOff);
				if (ram_8504 < 0) {
					ApPostEvent(0x600026L, EVT_SHOW, 5);
					ram_8504 = GetFileCountEncoded();
					FileIO_SearchAndLoadFile();
					GetEncodedFreeSpaceData();
					ApPostEvent(0x600026L, EVT_HIDE, 0);
					ApPostEvent(-1L, EVT_ALL_PAINT, 0);
					SignalProgressUpdate();
				}
				MEDLEY_PLAY_FLAG = 0;
				ram_8922 = 0;
				ram_8920 = 0;
				n = 0x80;
				if ((unsigned int)ram_8504 <= 0x80)
					n = ram_8504;
				ram_8438 = n;
				for (i = 0; i < ram_8438; i++)
					ram_88a0[i] = 0xff;
				CDlike_InitModeAndLoadBank();
				ram_8434 = 0;
			}
			break;
		case 3:
			if (CURRENT_TITLE != 0x6f && CURRENT_TITLE != 0x72 && CURRENT_TITLE != 0x73 && CURRENT_TITLE != 0x76) {
				CDlike_ExitModeAndRestore();
				CancelOperationCleanup();
				MEDLEY_PLAY_FLAG = 0;
			}
			break;
		}
		break;
	case EVT_PS_FILE_NAME_BOX_ID:
		ram_8430 = p;
		break;
	case EVT_PAINT:
		SmfMed_FormatSlotList(ram_8430, ram_8438);
		break;
	case EVT_INDEXSW_UP:
	case EVT_INDEXSW_DOWN:
		if (p == 10 && MEDLEY_PLAY_FLAG == 0) {
			for (i = 0; i < ram_8438; i++)
				if (ram_88a0[i] == 0xff)
					break;
			if (i < ram_8438) {
				for (i = 0; i < ram_8438; i++) {
					if (ram_88a0[i] == 0xff) {
						ram_88a0[i] = ram_8920;
						ram_8920++;
					}
				}
			} else {
				for (i = 0; i < ram_8438; i++) {
					if (ram_88a0[i] <= 0xfd) {
						ram_88a0[i] = 0xff;
						ram_8920--;
					}
				}
			}
			SmfMed_FormatSlotList(ram_8430, ram_8438);
		} else if (p == 11 && MEDLEY_PLAY_FLAG == 0) {
			i = FmmSmfFileNameFunc(obj, EVT_GET_SELECTED_FILE_NUMBER, 0);
			c = ram_88a0[i];
			if (c == 0xff) {
				ram_88a0[i] = ram_8920;
				ram_8920++;
			} else if (c <= 0xfd) {
				ram_88a0[i] = 0xff;
				n = --ram_8920;
				k = 0;
				for (i = 0; k < n; i++) {
					v = ram_88a0[i];
					if (v <= 0xfd) {
						k++;
						if (v > c)
							ram_88a0[i] = v - 1;
					}
				}
			}
			SmfMed_FormatSlotList(ram_8430, ram_8438);
		} else if (p == 12) {
			if (ev == EVT_INDEXSW_UP)
				ram_8924 = 1;
			else
				ram_8924 = 0;
		} else if (p == 13 && MEDLEY_PLAY_FLAG == 0) {
			ram_8922 = 0;
			ram_843c = 0;
			for (i = 0; i < ram_8438; i++) {
				if (ram_88a0[i] == 0) {
					MEDLEY_PLAY_FLAG = 1;
					FmmSmfFileNameFunc(obj, EVT_SET_SELECTED_FILE_NUMBER, i);
					ram_8922++;
					GetFileEntryByIndex(i);
					ApPostEvent(-1L, EVT_SET_HOLD, 0);
					UI_ChangeTitleByIndex(TT_DPMDLYSMF);
					break;
				}
			}
			if (MEDLEY_PLAY_FLAG == 0) {
				i = FmmSmfFileNameFunc(obj, EVT_GET_SELECTED_FILE_NUMBER, 0);
				GetFileEntryByIndex(i);
				ApPostEvent(-1L, EVT_SET_HOLD, 0);
				UI_ChangeTitleByIndex(TT_DPSMF);
			}
		}
		break;
	case EVT_I_WILL_WAKE_UP:
		ram_8434 = p;
		break;
	case EVT_WAKE_UP_NOW:
		if (MEDLEY_PLAY_FLAG != 0) {
			ApPostEvent(-1L, EVT_SET_HOLD, 0);
			UI_ChangeTitleByIndex(ram_843a);
		}
		break;
	}
	return 0;
}
