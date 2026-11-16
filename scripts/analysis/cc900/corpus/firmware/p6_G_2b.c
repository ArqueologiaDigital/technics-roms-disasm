/* Phase 6, lane_p6 helper G, round 2, form b: refinements of round-1 misses (run 2026-11-16-45-p6-r9) and
   CaptureLcd (ui/ui_window_procs.s), each under its firmware name.  Form a (p6_G_2a.c) has the same names with other
   shapes; p6_G_2m271.c holds EditSwProc with its calr callee LabelProc (module 271).
   Learned in run 45: struct / array locals take frame slots from the top down in declaration order (the first
   declared is highest), and the stack arguments of an adecl call are pushed from the 4th on, so the ROM's push order
   (last pushed = 4th argument) gives the prototype.
   Event codes are their .equ values from v10/maincpu/shared/event_codes.s. */

#define EVT_SHOW              0x1c00001L
#define EVT_HIDE              0x1c00002L
#define EVT_DRAW              0x1c0000dL
#define EVT_GET_BITMAP_DATA   0x1e000a1L
#define EVT_GET_BITMAP_WIDTH  0x1e000a2L
#define EVT_GET_BITMAP_HEIGHT 0x1e000a3L

struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };

/* view instance records as the procs read them */
struct vinst { unsigned char pad[14]; struct rect r; long l22; long l26; int i30; };
struct lineinst { unsigned char pad[14]; int x1, y1, x2, y2; int color; unsigned char dir; unsigned char pad2; };

/* BMP file and info headers as CaptureLcd writes them */
struct bmfh { unsigned int type; unsigned long size; unsigned int res1, res2; unsigned long off; };
struct bmih {
	unsigned long size; long w, h; unsigned int planes, bits;
	unsigned long comp, imgsize; long xppm, yppm; unsigned long used, important;
};

/* callees */
extern long ViewableProc(long, long, long);
extern void *GetViewInstance(long);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
extern void DrawBitmap(struct pt *, unsigned char *);
extern void DrawBitmapSPFast(struct pt *, unsigned char *, int, int);
extern long ApFuncCall(long, long, long);
extern void DrawDesignBox(struct rect *, int, int);
extern void DrawIcons(struct pt *, long);
extern void DrawLine(struct pt *, struct pt *, int);
extern char *__cdecl Strcpy(char *, char *);
extern char *__cdecl Strcat(char *, char *);
extern int __cdecl Sprintf_Locked(char *, char *, ...);
extern unsigned char *FDemo_LinkedListLookupField(char *);
extern void DrawBitmapFile(struct pt *, unsigned char *);
extern void ChangePalette(int);
extern void __cdecl SeqBuf_NoteEvent_WriteByte(int);
extern void FlashWrite(int, unsigned char *, unsigned int, long);
extern unsigned char *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern void *__cdecl Memset(void *, int, unsigned int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void SndParamBank_WriteFlashDefaults(void);
extern void GetDiskSizeInfo(void);
extern void GetEncodedFileSizeData(void);
extern int FileIO_OpenWithMode(char *, char *);
extern long FileIO_WriteByte_Impl(void *, long);
extern void FileIO_CloseHandle(void);
extern unsigned long Table_LookupDword(int);

/* data */
extern char VwUserBitmapByName_Str_BmpExt[];
extern unsigned char SndParamBank_DefaultHeader[];
extern unsigned char SndParamBank_OptionDefault_00[], SndParamBank_OptionDefault_10[], SndParamBank_OptionDefault_20[];
extern unsigned char SndParamBank_OptionDefault_30[], SndParamBank_OptionDefault_40[];
extern char CaptureLcd_Str_BM[], CaptureLcd_Str_HKLCD_Fmt3d_BMP[], CaptureLcd_Str_wb[];
extern long ram_3044a;
extern unsigned char *PALETTE_DATA_PTR_CACHED;
extern unsigned char OFFSCREEN_BUFFER_1[];

/* file_io/composer_filters.s: RenderFilterDisplay's strings (their labels agree in 31 characters: short C names) */
/* cc900-name: rf_dash0=RenderFilterDisplay_Str_Dash_Dash_Dash_Dash */
/* cc900-name: rf_yes1=RenderFilter_CheckType1_Str_YES */
/* cc900-name: rf_no1=RenderFilter_Type1_Restricted_Str_NO */
/* cc900-name: rf_dash1=RenderFilter_Type1_Unavail_Str_Dash_Dash_Dash_Dash */
/* cc900-name: rf_yesg=RenderFilter_CheckGeneric_Str_YES */
/* cc900-name: rf_nog=RenderFilter_Generic_Restricted_Str_NO */
/* cc900-name: rf_yes2=RenderFilter_CheckType2_Str_YES */
/* cc900-name: rf_no2=RenderFilter_Type2_Restricted_Str_NO */
/* cc900-name: rf_dash2=RenderFilter_Type2_Restricted_Str_Dash_Dash_Dash_Dash */
extern char rf_dash0[], rf_yes1[], rf_no1[], rf_dash1[], rf_yesg[], rf_nog[], rf_yes2[], rf_no2[], rf_dash2[];
extern char GetCurrentFileType(void);
extern char FileIO_CheckRecordValid(int);
extern char FileIO_WriteRecordName_Done(int);
/* FileIO_CopyString is strncpy (count in DE), but this caller sets only XWA and XBC: a two-argument prototype */
extern void FileIO_CopyString(char *, char *);

/* ---- ui/ui_window_procs.s: view procs (refined: local order, DrawString's stack arguments) ---- */

long LabelProc(long obj, long evt, long p)
{
	struct pt pt;
	struct rect r;
	struct vinst *h;

	switch (evt) {
	case EVT_DRAW:
		break;
	default:
		return ViewableProc(obj, evt, p);
	}
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	r = h->r;
	pt.x = h->r.x1 + 2;
	pt.y = h->r.y1 + 1;
	DrawString(&r, &pt, (char *)h->l22, h->l26, h->i30, 0xf7);
	return 0;
}

long VwUserBitmapProc(long obj, long evt, long p)
{
	int w;
	unsigned char *data;
	struct pt pt;
	struct vinst *h;
	int hg;

	if (evt != EVT_DRAW) return ViewableProc(obj, evt, p);
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	pt.x = h->r.x1;
	pt.y = h->r.y1;
	data = (unsigned char *)ApFuncCall(h->l22, EVT_GET_BITMAP_DATA, 0);
	if (data != 0) {
		w = ApFuncCall(h->l22, EVT_GET_BITMAP_WIDTH, 0);
		DrawBitmapSPFast(&pt, data, w, hg = ApFuncCall(h->l22, EVT_GET_BITMAP_HEIGHT, 0));
	} else
		DrawBitmap(&pt, 0);
	return 0;
}

long VwUserBitmapByNameProc(long obj, long evt, long p)
{
	struct pt pt;
	char name[16];
	struct vinst *h;
	unsigned char *f;

	switch (evt) {
	case EVT_SHOW:
		ViewableProc(obj, evt, p);
		return 0;
	case EVT_DRAW:
		ViewableProc(obj, evt, p);
		h = GetViewInstance(obj);
		pt.x = h->r.x1;
		pt.y = h->r.y1;
		Strcpy(name, (char *)h->l22);
		Strcat(name, VwUserBitmapByName_Str_BmpExt);
		f = FDemo_LinkedListLookupField(name);
		if (f != 0) DrawBitmapFile(&pt, f);
		else DrawBitmap(&pt, 0);
		return 0;
	case EVT_HIDE:
		ChangePalette(2);
		ViewableProc(obj, evt, p);
		return 0;
	}
	return ViewableProc(obj, evt, p);
}

long IconProc(long obj, long evt, long p)
{
	struct rect r;
	struct pt pt;
	struct vinst *h;

	if (evt != EVT_DRAW) return ViewableProc(obj, evt, p);
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	pt.x = h->r.x1 + 2;
	pt.y = h->r.y1 + 2;
	r.x1 = pt.x - 2;
	r.x2 = pt.x + 25;
	r.y1 = pt.y - 2;
	r.y2 = pt.y + 25;
	DrawDesignBox(&r, 0xc4, 0xf0);
	DrawIcons(&pt, h->l22);
	return 0;
}

long LineProc(long obj, long evt, long p)
{
	struct pt a, b;
	struct lineinst *h;

	if (evt != EVT_DRAW) return ViewableProc(obj, evt, p);
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	if (h->dir == 1) {
		a.x = h->x1;
		a.y = h->y1;
		b.x = h->x2;
		b.y = h->y2;
	} else {
		a.x = h->x1;
		a.y = h->y2;
		b.x = h->x2;
		b.y = h->y1;
	}
	DrawLine(&a, &b, h->color);
	return 0;
}

/* ROM: writes a 320 x 240 8-bit BMP of the primary offscreen buffer to a new file HKLCDnnn.BMP; 1 = written */
int CaptureLcd(void)
{
	struct bmfh fh;
	struct bmih ih;
	unsigned char pal[256][4];
	char fname[16];
	int i;
	unsigned long v;

	Strcpy((char *)&fh, CaptureLcd_Str_BM);
	fh.size = 0x13036L;
	fh.res1 = 0;
	fh.res2 = 0;
	fh.off = 0x436;
	ih.size = 0x28;
	ih.w = 0x140;
	ih.h = 0xf0;
	ih.planes = 1;
	ih.bits = 8;
	ih.comp = 0;
	ih.imgsize = 0x12c00L;
	ih.xppm = 0;
	ih.yppm = 0;
	ih.used = 0x100;
	ih.important = 0x100;
	Sprintf_Locked(fname, CaptureLcd_Str_HKLCD_Fmt3d_BMP, ram_3044a);
	ram_3044a += 1;
	GetDiskSizeInfo();
	GetEncodedFileSizeData();
	if (FileIO_OpenWithMode(fname, CaptureLcd_Str_wb) != 0) return 0;
	if (FileIO_WriteByte_Impl(&fh, 14) != 14) {
		FileIO_CloseHandle();
		return 0;
	}
	if (FileIO_WriteByte_Impl(&ih, 40) != 40) {
		FileIO_CloseHandle();
		return 0;
	}
	i = 0;
	if (PALETTE_DATA_PTR_CACHED != 0) {
		do {
			v = Table_LookupDword(i);
			pal[i][0] = (v & 0xff0000L) >> 16;
			pal[i][1] = (v & 0xff00) >> 8;
			pal[i][2] = v & 0xff;
			pal[i][3] = 0;
		} while (++i < 256);
	} else {
		do {
			v = Table_LookupDword(i);
			pal[i][0] = (v & 0xff0000L) >> 16;
			pal[i][1] = (v & 0xff00) >> 8;
			pal[i][2] = v & 0xff;
			pal[i][3] = 0;
		} while (++i < 256);
	}
	if (FileIO_WriteByte_Impl(pal, 0x400) != 0x400) {
		FileIO_CloseHandle();
		return 0;
	}
	for (i = 239; i >= 0; i--)
		if (FileIO_WriteByte_Impl(OFFSCREEN_BUFFER_1 + (long)i * 320, 320) != 320) {
			FileIO_CloseHandle();
			return 0;
		}
	FileIO_CloseHandle();
	return 1;
}

/* ---- boot/system_handlers.s ---- */

void SeqDMA_WriteMidi_NoteOn(unsigned char ch, unsigned char *p)
{
	switch (*p) {
	case 0x90:
		p++;
		SeqBuf_NoteEvent_WriteByte(*p);
		p++;
		SeqBuf_NoteEvent_WriteByte(*p);
	}
}

/* ---- audio/tonegen_fileio_handlers.s ---- */

/* the ROM jumps (jr nz) from the loop into SndParamBank_WriteFlashDefaults: V4.23's tail call */
void SndParamBank_CheckFlash(void)
{
	unsigned char *s, *d;
	unsigned int i;

	d = SndParamBank_DefaultHeader;
	s = (unsigned char *)0x3d3000L;
	for (i = 0; i < 3; i++)
		if (*s++ != *d++) {
			SndParamBank_WriteFlashDefaults();
			return;
		}
}

/* SndParamBank_Default1 / _Default2 are SndParamBank_DefaultHeader + 0xfa / + 0xfa + 0xea: the three records the
   three FlashWrite calls store back to back */
void SndParamBank_WriteFlashDefaults(void)
{
	unsigned char *b;

	FlashWrite(1, SndParamBank_DefaultHeader, 0xfa, 0x3d3000L);
	FlashWrite(1, &SndParamBank_DefaultHeader[0xfa], 0xea, 0x3d3110L);
	FlashWrite(1, &SndParamBank_DefaultHeader[0x1e4], 0xea, 0x3d3210L);
	b = Malloc(0x50);
	if (b != 0) {
		Memset(b, 0x50, 0);
		Mem_Copy(b, SndParamBank_OptionDefault_00, 2);
		Mem_Copy(b + 16, SndParamBank_OptionDefault_10, 12);
		Mem_Copy(b + 32, SndParamBank_OptionDefault_20, 4);
		Mem_Copy(b + 48, SndParamBank_OptionDefault_30, 4);
		Mem_Copy(b + 64, SndParamBank_OptionDefault_40, 6);
		FlashWrite(1, b, 0x50, 0x3d3400L);
		Free(b);
	}
}

/* ---- file_io/composer_filters.s ---- */

/* buf[0] = the filter type, then its state text: YES / NO, or dashes when it does not apply */
void RenderFilterDisplay(char *buf, unsigned char type)
{
	char *s;

	*buf++ = type;
	if (type == 0 && GetCurrentFileType() != 0)
		s = rf_dash0;
	else if (type == 1 && GetCurrentFileType() != 0) {
		if (FileIO_CheckRecordValid(0) == 0) s = rf_dash1;
		else if (FileIO_WriteRecordName_Done(0) == 0) s = rf_no1;
		else s = rf_yes1;
	} else if (FileIO_CheckRecordValid(type) != 0) {
		if (FileIO_WriteRecordName_Done(type) == 0) s = rf_nog;
		else s = rf_yesg;
	} else if (type == 2 && FileIO_CheckRecordValid(8) != 0 && FileIO_CheckRecordValid(9) != 0) {
		if (FileIO_WriteRecordName_Done(type) == 0) s = rf_no2;
		else s = rf_yes2;
	} else
		s = rf_dash2;
	FileIO_CopyString(buf, s);
}
