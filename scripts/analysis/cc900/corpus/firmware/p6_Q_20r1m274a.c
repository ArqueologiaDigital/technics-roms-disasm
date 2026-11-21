/* helper Q, round 20r1, module 274 (display/graphics_text_vga.s): a glyph's descent from the 16-byte glyph records at
   0x945c00 (one constant-pointer scalar read, no element copy: bug 11 is about whole-element copies). */

struct glyph { long bits; int descent; int w; long rest; int pad; int pad2; };

int GetCharDescent(unsigned long c)
{
  return ((struct glyph *)0x945c00L)[c].descent;
}
