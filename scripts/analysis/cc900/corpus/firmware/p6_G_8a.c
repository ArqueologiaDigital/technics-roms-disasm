/* Phase 6, lane_p6 helper G, round 8, form a: CaptureLcd (ui/ui_window_procs.s) again.  Form b (p6_G_8b.c) has the
   same function in another shape.  Run 2026-11-16-100-p6-r19: Strcpy's destination through a pointer variable
   (round 7 form a) gives the ROM's start; the first difference is now in the palette loops, where the ROM stores the
   first byte of an entry through (base + i*4) and the other three through the entry's address kept in XWA, with the
   base in XWA and the value in XBC (V4.23 had them the other way round, and indexed every byte).  Here the palette is
   an array of 4-byte entries written by member (form a), or by an explicit entry pointer after the first byte
   (form b). */

/* BMP file and info headers as CaptureLcd writes them */
struct bmfh { unsigned int type; unsigned long size; unsigned int res1, res2; unsigned long off; };
struct bmih {
	unsigned long size; long w, h; unsigned int planes, bits;
	unsigned long comp, imgsize; long xppm, yppm; unsigned long used, important;
};
/* a BMP palette entry */
struct rgbq { unsigned char b, g, r, x; };

extern char *__cdecl Strcpy(char *, char *);
extern int __cdecl Sprintf_Locked(char *, char *, ...);
extern void GetDiskSizeInfo(void);
extern void GetEncodedFileSizeData(void);
extern int FileIO_OpenWithMode(char *, char *);
extern long FileIO_WriteByte_Impl(void *, long);
extern void FileIO_CloseHandle(void);
extern unsigned long Table_LookupDword(int);

extern char CaptureLcd_Str_BM[], CaptureLcd_Str_HKLCD_Fmt3d_BMP[], CaptureLcd_Str_wb[];
extern long ram_3044a;
extern unsigned char *PALETTE_DATA_PTR_CACHED;
extern unsigned char OFFSCREEN_BUFFER_1[];

/* ROM: writes a 320 x 240 8-bit BMP of the primary offscreen buffer to a new file HKLCDnnn.BMP; 1 = written */
int CaptureLcd(void)
{
	struct bmfh fh;
	struct bmih ih;
	struct rgbq pal[256];
	char fname[16];
	int i;
	unsigned long v;
	char *q;

	q = (char *)&fh;
	Strcpy(q, CaptureLcd_Str_BM);
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
			pal[i].b = (v & 0xff0000L) >> 16;
			pal[i].g = (v & 0xff00) >> 8;
			pal[i].r = v & 0xff;
			pal[i].x = 0;
		}
	} else {
		for (i = 0; i < 256; i++) {
			v = Table_LookupDword(i);
			pal[i].b = (v & 0xff0000L) >> 16;
			pal[i].g = (v & 0xff00) >> 8;
			pal[i].r = v & 0xff;
			pal[i].x = 0;
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
