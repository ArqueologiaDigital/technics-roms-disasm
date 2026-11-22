/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_X_21r2m269a.c (2026-11-21-9-p6-r64)
   sha256 25b489076992c02acb6fc3708468e3a9e0f41d2f1533c38495a430a83b8b9578 (tar-sha256); compiled at -O3 -Xr */
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
#define TT_DPDOC                     0x70
#define TT_DPMDLYDOC                 0x74
#define TT_MESAGE                    0xee
extern long __near ram_84f4;
extern long __near ram_84f8;
extern unsigned int __near ram_84fc;
extern unsigned char __near MEDLEY_PLAY_FLAG;
extern int __near ram_8504;
extern int __near ram_8508;
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
extern int FileIO_InitFileNavigation(void);
extern void SignalProgressUpdate(void);
extern void CDlike_InitModeAndLoadBank(void);
extern void CDlike_ExitModeAndRestore(void);
extern void CancelOperationCleanup(void);
extern long FmmDocFileNameFunc(long, long, long);
extern void DocMed_FormatSlotList(long, unsigned int);
long FmmDocMedleyFunc(long obj, long ev, long p)
{
	unsigned int i;
	unsigned int k;
	unsigned int n;
	unsigned char c;
	unsigned char v;
	unsigned char s;

	switch (ev) {
	case EVT_ACTIVATE_STATE:
		switch (p) {
		case 2:
			InitializeOperationState(0);
			if (PREVIOUS_TITLE == TT_DPDOC) {
				MEDLEY_PLAY_FLAG = 0;
				if (Medley_GetPlaybackStatus() >= 2) {
					GLOBAL_ERROR_CODE = 1;
					UI_InterruptTitleByIndex(TT_MESAGE);
				}
			} else if (PREVIOUS_TITLE == TT_DPMDLYDOC) {
				if (Medley_GetPlaybackStatus() == 1) {
					MEDLEY_PLAY_FLAG = 1;
					c = ram_8922;
					if (c < ram_8920) {
						for (i = 0; i < ram_84fc; i++) {
							if (ram_88a0[i] == c) {
								FmmDocFileNameFunc(obj, EVT_SET_SELECTED_FILE_NUMBER, i);
								DocMed_FormatSlotList(ram_84f4, ram_84fc);
								ram_8922++;
								if (ram_84f8 != 0)
									ApPostEvent(ram_84f8, EVT_WAKE_UP_TIME, 30);
								break;
							}
						}
					} else if (ram_8924 != 0) {
						ram_8922 = 0;
						for (i = 0; i < ram_84fc; i++) {
							if (ram_88a0[i] == 0) {
								FmmDocFileNameFunc(obj, EVT_SET_SELECTED_FILE_NUMBER, i);
								DocMed_FormatSlotList(ram_84f4, ram_84fc);
								ram_8922++;
								if (ram_84f8 != 0)
									ApPostEvent(ram_84f8, EVT_WAKE_UP_TIME, 30);
								break;
							}
						}
					} else {
						MEDLEY_PLAY_FLAG = 0;
					}
				} else {
					s = Medley_GetPlaybackStatus();
					MEDLEY_PLAY_FLAG = 0;
					if (s != 0) {
						GLOBAL_ERROR_CODE = 1;
						UI_InterruptTitleByIndex(TT_MESAGE);
					}
				}
			} else {
				if (ram_8508 < 0 || ram_8504 == 0) {
					ram_8504 = -1;
					ApPostEvent(0x600026L, EVT_SHOW, 5);
					ram_8508 = FileIO_InitFileNavigation();
					ApPostEvent(0x600026L, EVT_HIDE, 0);
					ApPostEvent(-1L, EVT_ALL_PAINT, 0);
					SignalProgressUpdate();
				}
				MEDLEY_PLAY_FLAG = 0;
				ram_8922 = 0;
				ram_8920 = 0;
				n = 0x80;
				if ((unsigned int)ram_8508 <= 0x80)
					n = ram_8508;
				ram_84fc = n;
				for (i = 0; i < ram_84fc; i++)
					ram_88a0[i] = 0xff;
				CDlike_InitModeAndLoadBank();
				ram_84f8 = 0;
			}
			break;
		case 3:
			if (CURRENT_TITLE != TT_DPDOC && CURRENT_TITLE != TT_DPMDLYDOC) {
				CDlike_ExitModeAndRestore();
				CancelOperationCleanup();
				MEDLEY_PLAY_FLAG = 0;
			}
			break;
		}
		break;
	case EVT_PS_FILE_NAME_BOX_ID:
		ram_84f4 = p;
		break;
	case EVT_PAINT:
		DocMed_FormatSlotList(ram_84f4, ram_84fc);
		break;
	case EVT_INDEXSW_UP:
	case EVT_INDEXSW_DOWN:
		if (p == 10 && MEDLEY_PLAY_FLAG == 0) {
			for (i = 0; i < ram_84fc; i++)
				if (ram_88a0[i] == 0xff)
					break;
			if (i < ram_84fc) {
				for (i = 0; i < ram_84fc; i++) {
					if (ram_88a0[i] == 0xff) {
						ram_88a0[i] = ram_8920;
						ram_8920++;
					}
				}
			} else {
				for (i = 0; i < ram_84fc; i++) {
					if (ram_88a0[i] <= 0xfd) {
						ram_88a0[i] = 0xff;
						ram_8920--;
					}
				}
			}
			DocMed_FormatSlotList(ram_84f4, ram_84fc);
		} else if (p == 11 && MEDLEY_PLAY_FLAG == 0) {
			i = FmmDocFileNameFunc(obj, EVT_GET_SELECTED_FILE_NUMBER, 0);
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
			DocMed_FormatSlotList(ram_84f4, ram_84fc);
		} else if (p == 12) {
			if (ev == EVT_INDEXSW_UP)
				ram_8924 = 1;
			else
				ram_8924 = 0;
		} else if (p == 13 && MEDLEY_PLAY_FLAG == 0) {
			ram_8922 = 0;
			for (i = 0; i < ram_84fc; i++) {
				if (ram_88a0[i] == 0) {
					MEDLEY_PLAY_FLAG = 1;
					FmmDocFileNameFunc(obj, EVT_SET_SELECTED_FILE_NUMBER, i);
					ram_8922++;
					ApPostEvent(-1L, EVT_SET_HOLD, 0);
					UI_ChangeTitleByIndex(TT_DPMDLYDOC);
					break;
				}
			}
			if (MEDLEY_PLAY_FLAG == 0) {
				FmmDocFileNameFunc(obj, EVT_GET_SELECTED_FILE_NUMBER, 0);
				ApPostEvent(-1L, EVT_SET_HOLD, 0);
				UI_ChangeTitleByIndex(TT_DPDOC);
			}
		}
		break;
	case EVT_I_WILL_WAKE_UP:
		ram_84f8 = p;
		break;
	case EVT_WAKE_UP_NOW:
		if (MEDLEY_PLAY_FLAG != 0) {
			ApPostEvent(-1L, EVT_SET_HOLD, 0);
			UI_ChangeTitleByIndex(TT_DPMDLYDOC);
		}
		break;
	}
	return 0;
}
