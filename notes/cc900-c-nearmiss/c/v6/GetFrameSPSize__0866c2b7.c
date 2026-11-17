/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/graphics_text_vga_m274.c (2026-11-16-68-p6-r12)
   sha256 0866c2b7aa868d3bcc2c8cf87e8cc42c575974fa788641d4bad8b27d424f2f1d (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct fs { unsigned int w, h; long x; };
void GetFrameSPSize(unsigned int i, unsigned int *w, unsigned int *h)
{
	struct fs *f = (struct fs *)0x934000 + i;

	*w = f->w;
	*h = f->h;
}
