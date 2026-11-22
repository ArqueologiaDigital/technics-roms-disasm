/* lane_p6 helper D, round 23r1, form a: module 232 (sequencer/sequencer_ui.s), TrAsGridCheck (f2c477, 1,350 B with
   its case bodies), the track-assign grid's message handler that helper B left (case bodies shared between cases).
   switch on the event: INDEXSW_UP / _UP_AIC and INDEXSW_DOWN / _DOWN_AIC through TrAsGridCheck_CaseTable (7 slots,
   RAM_DATA the empty top case), REQUEST_GRID_DRAW compared first (last in source).  Each case reads the grid cell
   {column, row} from the event parameter or MT_GetSelectedCel, then switches on the column (1 = part, 2 = AMD bit
   mask at song record +80, 3 = MIDI bit mask at +272; compares in reverse source order).
   Frame: struct cell {col, row, str} at +14 above char buf[10] at +4 (address-taken: reverse declaration order).
   The cell from MT_GetSelectedCel goes back into p (the ROM keeps both in XIZ).
   Form b (= form a with the two spellings swapped): part 2's label through a pointer variable, part 3's as a
   ternary argument; column word = (x >> 16) & 0xffff (the ROM's ld qbc, 0).
   cc900-options: -O3 -Xr
*/
/* cc900-module: TrAsGrid_CheckTrackType TrAsGrid_LookupByteTable TrAsGrid_LookupTable TrAsGrid_StepListValue */
/* cc900-data: TrAsGridCheck 1 = TrAsGridCheck_CaseTable */
/* cc900-name: T1PtrTab=TrAsGridChk_Part1_SendAudio_PtrTable */
/* cc900-name: T2UpCt0Str=TrAsGridChk_Part2_UpCheckType0_Str */
/* cc900-name: T3UpCt0Str=TrAsGridChk_Part3_UpCheckType0_Str */

#define EVT_INDEXSW_UP          0x1c00017L
#define EVT_INDEXSW_DOWN        0x1c00018L
#define EVT_INDEXSW_UP_AIC      0x1c00019L
#define EVT_INDEXSW_DOWN_AIC    0x1c0001aL
#define EVT_RAM_DATA            0x1c0001dL
#define EVT_GRID_DRAW           0x1e0008cL
#define EVT_REQUEST_GRID_DRAW   0x1e0008dL
#define EVT_GET_SELECTED_CEL    0x1e0008fL
#define EVT_TR_AS_PART_INC      0x1e70006L
#define EVT_TR_AS_PART_DEC      0x1e70007L
#define EVT_AMD_CALL            0x1e7000aL
#define EVT_TRACK_MIDI_CALL     0x1e7000cL
#define NAKA_MAINFUNC_MiddleFuncCall 0x147001cL

struct cell {
	unsigned int col;
	unsigned int row;
	char *str;
};
struct songrec {
	unsigned char pad0[80];
	unsigned int amd;
	unsigned char pad82[190];
	unsigned int midi;
};

extern unsigned char __near TRACK_ASSIGN_EDIT_VALUE;
extern unsigned char __near ram_ce0;
extern unsigned char ram_21082;
extern struct songrec __near SEQ_SONG_RECORD;
extern char *T1PtrTab[];
extern char TrAsGridChk_Part2_Start_Str[];
extern char TrAsGridChk_Part2_Start_Str_2[];
extern char TrAsGridChk_Part2_PushCmd_Str[];
extern char TrAsGridChk_Part2_PushCmd_Str_2[];
extern char TrAsGridChk_Part2_UpDir_Str[];
extern char TrAsGridChk_Part2_UpDir_Str_2[];
extern char TrAsGridChk_Part2_UpPushCmd_Str[];
extern char T2UpCt0Str[];
extern char TrAsGridChk_Part3_Start_Str[];
extern char TrAsGridChk_Part3_Start_Str_2[];
extern char TrAsGridChk_Part3_PushCmd_Str[];
extern char TrAsGridChk_Part3_PushCmd_Str_2[];
extern char TrAsGridChk_Part3_UpDir_Str[];
extern char TrAsGridChk_Part3_UpDir_Str_2[];
extern char TrAsGridChk_Part3_UpPushCmd_Str[];
extern char T3UpCt0Str[];

extern long GetFocusObject(void);
extern long SendEvent(long, long, long);
extern long MainFuncCall(long, long, long);
extern int __cdecl Sprintf_Locked(char *, char *, ...);
extern unsigned char TrAsGrid_StepListValue(unsigned char, unsigned char);
extern unsigned int TrAsGrid_LookupTable(unsigned char);
extern unsigned char TrAsGrid_LookupByteTable(unsigned char);
extern unsigned char TrAsGrid_CheckTrackType(unsigned char, unsigned char);

long TrAsGridCheck(long obj, long evt, unsigned long p)
{
	struct cell g;
	char buf[10];
	unsigned char v;
	char *s;

	switch (evt) {
	case EVT_INDEXSW_UP:
	case EVT_INDEXSW_UP_AIC:
		p = SendEvent(GetFocusObject(), EVT_GET_SELECTED_CEL, 0);
		g.col = (p >> 16) & 0xffff;
		g.row = p;
		switch (g.col) {
		case 1:
			TRACK_ASSIGN_EDIT_VALUE = TrAsGrid_StepListValue(TRACK_ASSIGN_EDIT_VALUE, 0);
			ram_21082 = TRACK_ASSIGN_EDIT_VALUE;
			MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_TR_AS_PART_INC, p);
			SendEvent(GetFocusObject(), EVT_REQUEST_GRID_DRAW, p);
			SendEvent(GetFocusObject(), EVT_REQUEST_GRID_DRAW, g.row + 0x20000L);
			SendEvent(GetFocusObject(), EVT_REQUEST_GRID_DRAW, g.row + 0x30000L);
			break;
		case 2:
			SEQ_SONG_RECORD.amd |= TrAsGrid_LookupTable((ram_ce0 & 1) == 0 ? g.row - 2 : g.row + 6);
			SendEvent(GetFocusObject(), EVT_REQUEST_GRID_DRAW, p);
			MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_AMD_CALL, p);
			break;
		case 3:
			if ((ram_ce0 & 1) == 0) {
				SEQ_SONG_RECORD.midi |= TrAsGrid_LookupTable(g.row - 2);
				MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_TRACK_MIDI_CALL, p);
			} else {
				SEQ_SONG_RECORD.midi |= TrAsGrid_LookupTable(g.row + 6);
				MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_TRACK_MIDI_CALL, p);
			}
			SendEvent(GetFocusObject(), EVT_REQUEST_GRID_DRAW, p);
			MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_AMD_CALL, p);
			break;
		}
		break;
	case EVT_INDEXSW_DOWN:
	case EVT_INDEXSW_DOWN_AIC:
		p = SendEvent(GetFocusObject(), EVT_GET_SELECTED_CEL, 0);
		g.col = (p >> 16) & 0xffff;
		g.row = p;
		switch (g.col) {
		case 1:
			TRACK_ASSIGN_EDIT_VALUE = TrAsGrid_StepListValue(TRACK_ASSIGN_EDIT_VALUE, 1);
			ram_21082 = TRACK_ASSIGN_EDIT_VALUE;
			MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_TR_AS_PART_DEC, p);
			SendEvent(GetFocusObject(), EVT_REQUEST_GRID_DRAW, p);
			SendEvent(GetFocusObject(), EVT_REQUEST_GRID_DRAW, g.row + 0x20000L);
			SendEvent(GetFocusObject(), EVT_REQUEST_GRID_DRAW, g.row + 0x30000L);
			break;
		case 2:
			SEQ_SONG_RECORD.amd &= ~TrAsGrid_LookupTable((ram_ce0 & 1) == 0 ? g.row - 2 : g.row + 6);
			SendEvent(GetFocusObject(), EVT_REQUEST_GRID_DRAW, p);
			MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_AMD_CALL, p);
			break;
		case 3:
			if ((ram_ce0 & 1) == 0) {
				SEQ_SONG_RECORD.midi &= ~TrAsGrid_LookupTable(g.row - 2);
				MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_TRACK_MIDI_CALL, p);
			} else {
				SEQ_SONG_RECORD.midi &= ~TrAsGrid_LookupTable(g.row + 6);
				MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_TRACK_MIDI_CALL, p);
			}
			SendEvent(GetFocusObject(), EVT_REQUEST_GRID_DRAW, p);
			MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_AMD_CALL, p);
			break;
		}
		break;
	case EVT_REQUEST_GRID_DRAW:
		g.col = (p >> 16) & 0xffff;
		g.row = p;
		g.str = buf;
		switch (g.col) {
		case 1:
			if (g.row == (unsigned int)SendEvent(GetFocusObject(), EVT_GET_SELECTED_CEL, 0))
				v = ram_21082;
			else if ((ram_ce0 & 1) == 0)
				v = TrAsGrid_LookupByteTable(g.row - 2);
			else
				v = TrAsGrid_LookupByteTable(g.row + 6);
			Sprintf_Locked(buf, T1PtrTab[v]);
			SendEvent(GetFocusObject(), EVT_GRID_DRAW, (long)&g);
			break;
		case 2:
			if ((ram_ce0 & 1) == 0) {
				s = (TrAsGrid_LookupTable(g.row - 2) & SEQ_SONG_RECORD.amd) != 0
					? TrAsGridChk_Part2_Start_Str : TrAsGridChk_Part2_Start_Str_2;
				Sprintf_Locked(buf, s);
				if (g.row == (unsigned int)SendEvent(GetFocusObject(), EVT_GET_SELECTED_CEL, 0)) {
					if (TrAsGrid_CheckTrackType(1, g.row - 2) == 1)
						Sprintf_Locked(buf, TrAsGridChk_Part2_PushCmd_Str);
				} else {
					if (TrAsGrid_CheckTrackType(0, g.row - 2) == 1)
						Sprintf_Locked(buf, TrAsGridChk_Part2_PushCmd_Str_2);
				}
			} else {
				s = (TrAsGrid_LookupTable(g.row + 6) & SEQ_SONG_RECORD.amd) != 0
					? TrAsGridChk_Part2_UpDir_Str : TrAsGridChk_Part2_UpDir_Str_2;
				Sprintf_Locked(buf, s);
				if (g.row == (unsigned int)SendEvent(GetFocusObject(), EVT_GET_SELECTED_CEL, 0)) {
					if (TrAsGrid_CheckTrackType(1, g.row + 6) == 1)
						Sprintf_Locked(buf, TrAsGridChk_Part2_UpPushCmd_Str);
				} else {
					if (TrAsGrid_CheckTrackType(0, g.row + 6) == 1)
						Sprintf_Locked(buf, T2UpCt0Str);
				}
			}
			SendEvent(GetFocusObject(), EVT_GRID_DRAW, (long)&g);
			break;
		case 3:
			if ((ram_ce0 & 1) == 0) {
				Sprintf_Locked(buf, (TrAsGrid_LookupTable(g.row - 2) & SEQ_SONG_RECORD.midi) != 0
					? TrAsGridChk_Part3_Start_Str : TrAsGridChk_Part3_Start_Str_2);
				if (g.row == (unsigned int)SendEvent(GetFocusObject(), EVT_GET_SELECTED_CEL, 0)) {
					if (TrAsGrid_CheckTrackType(1, g.row - 2) == 1)
						Sprintf_Locked(buf, TrAsGridChk_Part3_PushCmd_Str);
				} else {
					if (TrAsGrid_CheckTrackType(0, g.row - 2) == 1)
						Sprintf_Locked(buf, TrAsGridChk_Part3_PushCmd_Str_2);
				}
			} else {
				Sprintf_Locked(buf, (TrAsGrid_LookupTable(g.row + 6) & SEQ_SONG_RECORD.midi) != 0
					? TrAsGridChk_Part3_UpDir_Str : TrAsGridChk_Part3_UpDir_Str_2);
				if (g.row == (unsigned int)SendEvent(GetFocusObject(), EVT_GET_SELECTED_CEL, 0)) {
					if (TrAsGrid_CheckTrackType(1, g.row + 6) == 1)
						Sprintf_Locked(buf, TrAsGridChk_Part3_UpPushCmd_Str);
				} else {
					if (TrAsGrid_CheckTrackType(0, g.row + 6) == 1)
						Sprintf_Locked(buf, T3UpCt0Str);
				}
			}
			SendEvent(GetFocusObject(), EVT_GRID_DRAW, (long)&g);
			break;
		}
		break;
	case EVT_RAM_DATA:
		break;
	}
	return 0;
}
