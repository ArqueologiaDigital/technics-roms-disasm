/* lane_p6 helper F, round 24r1, form a: module 273 (ui/drawing_primitives.s), DrawBitmapFile_Impl (fac6f3, 983 B),
   the Windows BMP drawer behind DrawBitmapFile / DrawBitmapFile_QueuedExec: checks "BM", a 40-byte info header,
   1 plane, <= 8 bits per pixel, <= 256 colours and <= 1,024 palette bytes; builds the palette at
   OFFSCREEN_BUFFER_4 (0xff000000 for unused entries, then B G R -> 0xBBGGRR), decodes the rows bottom-up into
   OFFSCREEN_BUFFER_2 (320 wide, at most 240 rows, narrow pictures tiled), fills the rows below a short picture
   from the top ones, then copies the picture's own width x height to OFFSCREEN_BUFFER_1 at p and marks the
   rectangle changed.
   The frame (params at +1076 / +1080, the 1,024-byte palette at +52, every scalar reloaded) is V4.23 without -O:
   the module's -Xr.  Its slots are shared by variables whose lives do not overlap (the info-header pointer
   copy at +36 later holds the source row pointer; the Malloc result at +40 later the width / height words), and
   XIZ / XBC hold the call-free or callee-saved temporaries: plain locals here, V4.23 allocating them.
   Form a: plain locals, all at function scope.
   cc900-options: -Xr
*/
/* cc900-module: ChangePalette_Impl Gfx_DecodeImageToBuffer Gfx_ProcessSplashData IsPointOnScreen SetChangeRect */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
struct bih {
	long size;
	long width;
	long height;
	int planes;
	unsigned int bitcount;
	long compression;
	long sizeimage;
	long xppm;
	long yppm;
	unsigned long clrused;
};

extern unsigned char OFFSCREEN_BUFFER_1[];
extern unsigned char OFFSCREEN_BUFFER_2[];
extern unsigned long OFFSCREEN_BUFFER_4[];
extern char DrawBitmapFile_Str_BM[];

extern int __cdecl String_Compare(void *, void *, int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern unsigned char *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern void Gfx_ProcessSplashData(unsigned char *, long, unsigned int);
extern void Gfx_DecodeImageToBuffer(void);
extern int IsPointOnScreen(struct pt *);
extern void SetChangeRect(struct rect *);
extern void ChangePalette_Impl(int);
extern void DrawBitmapFile_Impl(struct pt *p, unsigned char *b);

void DrawBitmapFile_Impl(struct pt *p, unsigned char *b)
{
	struct bih *info;
	long height;
	long i;
	long width;
	long rowbytes;
	unsigned char *rowbuf;
	unsigned char *dst;
	unsigned long n;
	struct bih *hdr;
	unsigned char *mem;
	unsigned long *pp;
	long ppb;
	long k;
	unsigned char *src2;
	unsigned char *vram;
	unsigned int j;
	unsigned int y;
	unsigned char *src;
	unsigned int w;
	unsigned int h;
	struct rect r;
	unsigned char pal[1024];

	if (String_Compare(b, DrawBitmapFile_Str_BM, 2) != 0)
		return;
	info = hdr = (struct bih *)(b + 14);
	if (hdr->size != 40)
		return;
	if (hdr->planes != 1)
		return;
	if (hdr->bitcount > 8)
		return;
	if (hdr->clrused > 256)
		return;
	n = *(unsigned long *)(b + 10);
	n -= 54;
	if (n > 1024)
		return;
	Mem_Copy(pal, b + 54, n);
	n >>= 2;
	pp = OFFSCREEN_BUFFER_4;
	for (i = 0; i < 256; i++)
		OFFSCREEN_BUFFER_4[i] = 0xff000000L;
	for (i = 0; i < n; i++)
		*pp++ = ((((unsigned long)pal[i * 4] << 8) + pal[i * 4 + 1]) << 8) + pal[i * 4 + 2];
	width = hdr->width;
	height = hdr->height;
	ppb = 8 / info->bitcount;
	rowbytes = (ppb * 4 - 1 + width) / (ppb * 4);
	rowbytes <<= 2;
	mem = Malloc(rowbytes * ppb);
	rowbuf = mem;
	b += n * 4 + 54;
	if (height > 240) {
		for (i = 0; i < height - 240; i++)
			b += rowbytes;
		height = 240;
	}
	n = 320;
	n *= height - 1;
	dst = OFFSCREEN_BUFFER_2 + n;
	for (i = 0; i < height; i++) {
		Mem_Copy(rowbuf, b, rowbytes);
		Gfx_ProcessSplashData(rowbuf, rowbytes, info->bitcount);
		if (width >= 320)
			Mem_Copy(dst, rowbuf, 320);
		else {
			for (k = 0; k < 320 / width; k++)
				Mem_Copy(dst + k * width, rowbuf, width);
			Mem_Copy(dst + k * width, rowbuf, 320 - k * width);
		}
		dst -= 320;
		b += rowbytes;
	}
	if (height < 240) {
		n += 320;
		src2 = OFFSCREEN_BUFFER_2;
		dst = OFFSCREEN_BUFFER_2 + n;
		for (i = height; i < 240; i++) {
			Mem_Copy(dst, src2, 320);
			src2 += 320;
			dst += 320;
		}
	}
	Free(mem);
	Gfx_DecodeImageToBuffer();
	if (IsPointOnScreen(p) == 0)
		return;
	w = hdr->width;
	h = hdr->height;
	vram = OFFSCREEN_BUFFER_1 + (p->x + p->y * 320L);
	src = OFFSCREEN_BUFFER_2;
	y = p->y;
	for (j = 0; j < h; j++) {
		if (y >= 240)
			break;
		Mem_Copy(vram, src, w);
		src += 320;
		vram += 320;
		y++;
	}
	r.y0 = p->y;
	r.x0 = p->x;
	r.x1 = p->x + w;
	r.y1 = p->y + h;
	SetChangeRect(&r);
	ChangePalette_Impl(3);
}
