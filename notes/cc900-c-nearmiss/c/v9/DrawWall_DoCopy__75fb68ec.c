/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/drawing_primitives_m0.c (2026-11-19-29-p6-r46)
   sha256 75fb68eccf34206d06d567633269b812833e1087d62510cf99edd48a965fb0c3 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
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
	r.x0 = r.y0 = 0;
	r.x1 = 319;
	r.y1 = 239;
	SetChangeRect(&r);
}
