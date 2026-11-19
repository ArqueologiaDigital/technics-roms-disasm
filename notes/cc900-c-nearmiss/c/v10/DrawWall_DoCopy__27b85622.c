/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_1m273b.c (2026-11-19-15-p6-r42)
   sha256 27b8562296593c324b178b766789eb79047182dd28bd128e5880a1af4620f70d (tar-sha256); compiled at -O3 -XS -Xr */
struct rect { int x0, y0, x1, y1; };
extern unsigned char *WALLPAPER_BITMAP;
extern unsigned char OFFSCREEN_BUFFER_1[];
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void SetChangeRect(struct rect *r);
void DrawWall_DoCopy(void)
{
	struct rect r;
	unsigned char *dst;
	unsigned char *src;

	src = WALLPAPER_BITMAP;
	dst = OFFSCREEN_BUFFER_1;
	Mem_Copy(dst, src, 0x9600);
	dst += 0x9600;
	src += 0x9600;
	Mem_Copy(dst, src, 0x9600);
	r.y0 = 0;
	r.x0 = 0;
	r.x1 = 319;
	r.y1 = 239;
	SetChangeRect(&r);
}
