/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/graphics_text_vga.c (2026-11-16-55-p6-r10)
   sha256 69cfebfca3d96eb693bdd47e9fa743b089974c6fec4fb0a8e24fcee70dbf23ef (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct fs { unsigned int w, h; long x; };
void GetFrameSPSize(unsigned int i, unsigned int *w, unsigned int *h)
{
	struct fs *f = (struct fs *)0x934000 + i;

	*w = f->w;
	*h = f->h;
}
