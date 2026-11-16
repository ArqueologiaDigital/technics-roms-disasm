/* Phase 6, lane_p6 helper G, round 3, form b (form a: p6_G_3a.c): refinements of run-68 misses (CaptureLcd, VwUserBitmapProc of
   ui/ui_window_procs.s; SndParamBank_CheckFlash of audio/tonegen_fileio_handlers.s, whose jr nz into
   SndParamBank_WriteFlashDefaults is a module-local jump; WriteFlashDefaults is defined here too, run 68's match).
   Form b (p6_G_3b.c) has the same names with other shapes.
   CaptureLcd and VwUserBitmapProc differed only where the ROM computes a first argument `&local` before the other
   arguments; V4.23 does that for `sym + offset`, so form a writes the address of the local's first member, form b
   `&(&local)[0]`.  Event codes are their .equ values from v10/maincpu/shared/event_codes.s. */
/* cc900-module: SndParamBank_WriteFlashDefaults */

#define EVT_DRAW              0x1c0000dL
#define EVT_GET_BITMAP_DATA   0x1e000a1L
#define EVT_GET_BITMAP_WIDTH  0x1e000a2L
#define EVT_GET_BITMAP_HEIGHT 0x1e000a3L

struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };
struct vinst { unsigned char pad[14]; struct rect r; long l22; long l26; int i30; };

/* BMP file and info headers as CaptureLcd writes them */
struct bmfh { unsigned int type; unsigned long size; unsigned int res1, res2; unsigned long off; };
struct bmih {
	unsigned long size; long w, h; unsigned int planes, bits;
	unsigned long comp, imgsize; long xppm, yppm; unsigned long used, important;
};

extern long ViewableProc(long, long, long);
extern void *GetViewInstance(long);
extern void DrawBitmap(struct pt *, unsigned char *);
extern void DrawBitmapSPFast(struct pt *, unsigned char *, int, int);
extern long ApFuncCall(long, long, long);
extern char *__cdecl Strcpy(char *, char *);
extern int __cdecl Sprintf_Locked(char *, char *, ...);
extern void GetDiskSizeInfo(void);
extern void GetEncodedFileSizeData(void);
extern int FileIO_OpenWithMode(char *, char *);
extern long FileIO_WriteByte_Impl(void *, long);
extern void FileIO_CloseHandle(void);
extern unsigned long Table_LookupDword(int);
extern void SndParamBank_WriteFlashDefaults(void);
extern void FlashWrite(int, unsigned char *, unsigned int, long);
extern unsigned char *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern void *__cdecl Memset(void *, int, unsigned int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);

extern unsigned char SndParamBank_DefaultHeader[];
extern unsigned char SndParamBank_OptionDefault_00[], SndParamBank_OptionDefault_10[], SndParamBank_OptionDefault_20[];
extern unsigned char SndParamBank_OptionDefault_30[], SndParamBank_OptionDefault_40[];
extern char CaptureLcd_Str_BM[], CaptureLcd_Str_HKLCD_Fmt3d_BMP[], CaptureLcd_Str_wb[];
extern long ram_3044a;
extern unsigned char *PALETTE_DATA_PTR_CACHED;
extern unsigned char OFFSCREEN_BUFFER_1[];

long VwUserBitmapProc(long obj, long evt, long p)
{
	int w;
	unsigned char *data;
	struct pt pt;
	struct vinst *h;

	if (evt != EVT_DRAW) return ViewableProc(obj, evt, p);
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	pt.x = h->r.x1;
	pt.y = h->r.y1;
	data = (unsigned char *)ApFuncCall(h->l22, EVT_GET_BITMAP_DATA, 0);
	if (data != 0) {
		w = ApFuncCall(h->l22, EVT_GET_BITMAP_WIDTH, 0);
		DrawBitmapSPFast(&(&pt)[0], data, w, (int)ApFuncCall(h->l22, EVT_GET_BITMAP_HEIGHT, 0));
	} else
		DrawBitmap(&pt, 0);
	return 0;
}

/* ROM: writes a 320 x 240 8-bit BMP of the primary offscreen buffer to a new file HKLCDnnn.BMP; 1 = written */
int CaptureLcd(void)
{
	struct bmfh fh;
	struct bmih ih;
	unsigned char pal[1024];
	char fname[16];
	int i;
	unsigned long v;

	Strcpy((char *)&(&fh)[0], CaptureLcd_Str_BM);
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
	if (PALETTE_DATA_PTR_CACHED != 0) {
		for (i = 0; i < 256; i++) {
			v = Table_LookupDword(i);
			pal[i * 4] = (v & 0xff0000L) >> 16;
			pal[i * 4 + 1] = (v & 0xff00) >> 8;
			pal[i * 4 + 2] = v & 0xff;
			pal[i * 4 + 3] = 0;
		}
	} else {
		for (i = 0; i < 256; i++) {
			v = Table_LookupDword(i);
			pal[i * 4] = (v & 0xff0000L) >> 16;
			pal[i * 4 + 1] = (v & 0xff00) >> 8;
			pal[i * 4 + 2] = v & 0xff;
			pal[i * 4 + 3] = 0;
		}
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

/* the ROM jumps (jr nz) from the loop into SndParamBank_WriteFlashDefaults: V4.23's tail call */
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

/* run 68's matching form, here so that module_calls.py sees SndParamBank_CheckFlash end where it starts */
void SndParamBank_WriteFlashDefaults(void)
{
	unsigned char *b;

	FlashWrite(1, SndParamBank_DefaultHeader, 0xfa, 0x3d3000L);
	FlashWrite(1, SndParamBank_DefaultHeader + 0xfa, 0xea, 0x3d3110L);
	FlashWrite(1, SndParamBank_DefaultHeader + 0xfa + 0xea, 0xea, 0x3d3210L);
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
