/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/graphics_text_vga.c (2026-11-16-45-p6-r9)
   sha256 6bf076a5c28046dcbb9a56457a016223a2be57ad8439b7b2e97d96984741c1cf (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct fs { unsigned int w, h; long x; };
void GetFrameSPSize(unsigned int i, unsigned int *w, unsigned int *h)
{
	struct fs *f = (struct fs *)0x934000 + i;

	*w = f->w;
	*h = f->h;
}
