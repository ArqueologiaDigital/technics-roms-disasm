/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_24r1m232b.c (2026-11-22-1-p6-r69)
   sha256 9790e9c280cede21e111695a082d827bdbaad344f8507c0ea7ac9cce3fa1faa7 (tar-sha256); compiled at -O3 -Xr */
#define EVT_SHOW                0x1c00001L
#define EVT_SW_IN               0x1c00007L
#define EVT_PAINT               0x1c0000bL
#define EVT_SELE_DRAW           0x1c0000eL
#define EVT_INDEXSW_UP          0x1c00017L
#define EVT_INDEXSW_DOWN        0x1c00018L
#define EVT_INDEXSW_UP_AIC      0x1c00019L
#define EVT_INDEXSW_DOWN_AIC    0x1c0001aL
#define EVT_LSW_DATA            0x1c0001cL
#define EVT_RAM_DATA            0x1c0001dL
#define EVT_CHECK_INDEX         0x1e00050L
#define EVT_GET_FIXED_COL_STR   0x1e0008aL
#define EVT_GET_FIXED_ROW_STR   0x1e0008bL
#define EVT_REQUEST_GRID_DRAW   0x1e0008dL
#define EVT_SET_SELECTED_CEL    0x1e0008eL
#define EVT_GET_SELECTED_CEL    0x1e0008fL
#define EVT_CHECK_GRID_INDEX    0x1e00091L
#define EVT_TR_AS_TRACK_INC     0x1e70004L
#define EVT_TR_AS_TRACK_DEC     0x1e70005L
#define EVT_TR_AS_PAGE_INC      0x1e70008L
#define EVT_TR_AS_PAGE_DEC      0x1e70009L
#define NAKA_MAINFUNC_MiddleFuncCall 0x147001cL
struct gview {
	unsigned char pad0[26];
	unsigned int index;
	unsigned char pad28[34];
	char *label;
	unsigned char pad66[4];
	long func;
};
extern unsigned char __near ram_ce0;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned char ram_21082;
extern char TrAsGrid_GetDirectionLabel_Str[];
extern char TrAsGrid_DirectionLabel2_Str[];
extern int SndParam_LookupReadOnly(long);
extern void SetVisible(long, unsigned int);
extern long InheritedProc(long, long, long);
extern struct gview *GetViewInstance(long);
extern long SendEvent(long, long, long);
extern long GetFocusObject(void);
extern void SetDialUp(long, long, long);
extern void SetDialDown(long, long, long);
extern void SetDialEnable(unsigned int);
extern void SetAutoInc(long, long, long);
extern void SleepMainTask(void);
extern void WakeUpMainTask(void);
extern void FuncCall(long, long, long);
extern long ApFuncCall(long, long, long);
extern char *__cdecl Strcpy(char *, char *);
extern unsigned char TrAsGrid_LookupByteTable(int);
long AcTrAsGridBoxProc(long obj, long evt, long p)
{
	switch (evt) {
	case EVT_SHOW: {
		long cell;
		struct gview *h;

		if (SndParam_LookupReadOnly(0xc0) != 0)
			SetVisible(0x8b0009L, 0);
		else
			SetVisible(0x8b0009L, 1);
		InheritedProc(obj, evt, p);
		h = GetViewInstance(obj);
		cell = SendEvent(obj, EVT_GET_SELECTED_CEL, 0);
		SetDialUp(obj, EVT_INDEXSW_UP, (unsigned int)((cell >> 16) & 0xffff) + h->index);
		SetDialDown(obj, EVT_INDEXSW_DOWN, (unsigned int)((cell >> 16) & 0xffff) + h->index);
		SetDialEnable(1);
		return 0;
	}
	case EVT_INDEXSW_UP:
	case EVT_INDEXSW_UP_AIC: {
		unsigned int sel;
		unsigned char f;

		if (SendEvent(obj, EVT_CHECK_INDEX, p) != 0) {
			ram_21082 = TrAsGrid_LookupByteTable((ram_ce0 & 1) == 0
				? (unsigned char)(SendEvent(GetFocusObject(), EVT_GET_SELECTED_CEL, 0) - 3)
				: (unsigned char)(SendEvent(GetFocusObject(), EVT_GET_SELECTED_CEL, 0) + 5));
			sel = SendEvent(obj, EVT_GET_SELECTED_CEL, 0);
			f = ram_ce0;
			if (((f & 1) != 0) & (sel - 2 == 0)) {
				ram_ce0 = f & ~1;
				SendEvent(obj, EVT_SET_SELECTED_CEL, 0xffff0009L);
				SendEvent(obj, EVT_PAINT, 0);
			} else {
				if (((f & 1) == 0) & (sel - 2 == 0)) return 0;
				InheritedProc(obj, evt, p);
				SendEvent(obj, EVT_SELE_DRAW, (sel - 1) + 0xffff0000L);
			}
			SetAutoInc(obj, evt, p);
			SleepMainTask();
			FuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_TR_AS_TRACK_DEC, p);
			WakeUpMainTask();
			return 0;
		}
		if (SendEvent(obj, EVT_CHECK_GRID_INDEX, p) == 0) return 0;
		if (SEQ_TRANSPORT_STATE & 0x04) return 0;
		InheritedProc(obj, evt, p);
		ApFuncCall(GetViewInstance(obj)->func, evt, p);
		SetAutoInc(obj, evt, p);
		SetDialUp(obj, EVT_INDEXSW_UP, p);
		SetDialDown(obj, EVT_INDEXSW_DOWN, p);
		SetDialEnable(1);
		return 0;
	}
	case EVT_INDEXSW_DOWN:
	case EVT_INDEXSW_DOWN_AIC: {
		unsigned int sel;
		unsigned char f;

		if (SendEvent(obj, EVT_CHECK_INDEX, p) != 0) {
			ram_21082 = TrAsGrid_LookupByteTable((ram_ce0 & 1) == 0
				? (unsigned char)(SendEvent(GetFocusObject(), EVT_GET_SELECTED_CEL, 0) - 1)
				: (unsigned char)(SendEvent(GetFocusObject(), EVT_GET_SELECTED_CEL, 0) + 7));
			sel = SendEvent(obj, EVT_GET_SELECTED_CEL, 0);
			f = ram_ce0;
			if (((f & 1) == 0) & (sel - 2 == 7)) {
				ram_ce0 = f | 1;
				SendEvent(obj, EVT_SET_SELECTED_CEL, 0xffff0002L);
				SendEvent(obj, EVT_PAINT, 0);
			} else {
				if (((f & 1) != 0) & (sel - 2 == 7)) return 0;
				InheritedProc(obj, evt, p);
				SendEvent(obj, EVT_SELE_DRAW, (sel + 1) + 0xffff0000L);
			}
			SetAutoInc(obj, evt, p);
			SleepMainTask();
			FuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_TR_AS_TRACK_INC, p);
			WakeUpMainTask();
			return 0;
		}
		if (SendEvent(obj, EVT_CHECK_GRID_INDEX, p) == 0) return 0;
		if (SEQ_TRANSPORT_STATE & 0x04) return 0;
		InheritedProc(obj, evt, p);
		ApFuncCall(GetViewInstance(obj)->func, evt, p);
		SetAutoInc(obj, evt, p);
		SetDialUp(obj, EVT_INDEXSW_UP, p);
		SetDialDown(obj, EVT_INDEXSW_DOWN, p);
		SetDialEnable(1);
		return 0;
	}
	case EVT_GET_FIXED_COL_STR:
		Strcpy((char *)p, GetViewInstance(obj)->label);
		return 0;
	case EVT_GET_FIXED_ROW_STR:
		Strcpy((char *)p, (ram_ce0 & 1) == 0 ? TrAsGrid_GetDirectionLabel_Str : TrAsGrid_DirectionLabel2_Str);
		return 0;
	case EVT_SW_IN:
	case EVT_LSW_DATA:
	case EVT_RAM_DATA:
		InheritedProc(obj, evt, p);
		if (p != 0x8f) return 0;
		if ((ram_ce0 & 1) == 0) {
			ram_21082 = TrAsGrid_LookupByteTable(8);
			ram_ce0 |= 1;
			SendEvent(obj, EVT_SET_SELECTED_CEL, 0xffff0002L);
			SendEvent(obj, EVT_PAINT, 0);
			SetAutoInc(obj, evt, p);
			SleepMainTask();
			FuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_TR_AS_PAGE_INC, p);
			WakeUpMainTask();
		} else {
			ram_21082 = TrAsGrid_LookupByteTable(0);
			ram_ce0 &= ~1;
			SendEvent(obj, EVT_SET_SELECTED_CEL, 0xffff0002L);
			SendEvent(obj, EVT_PAINT, 0);
			SetAutoInc(obj, evt, p);
			SleepMainTask();
			FuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_TR_AS_PAGE_DEC, p);
			WakeUpMainTask();
		}
		return 0;
	case EVT_REQUEST_GRID_DRAW:
		ApFuncCall(GetViewInstance(obj)->func, evt, p);
		return 0;
	default:
		return InheritedProc(obj, evt, p);
	}
}
