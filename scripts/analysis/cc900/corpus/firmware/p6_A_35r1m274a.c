/* Probe round 35r1, helper A, form a: display/graphics_text_vga.s (module 274), xr_screen family.
   DisplayBuffer_Process(r): copy the rectangle r (x0, y0, x1, y1; x rounded down to even) from the 320-byte-wide
   off-screen buffer to VRAM at 0x1a0000, rows y0 .. y1 / 2 and then y1 / 2 .. y1 (the middle row twice).
   The row is a `register` local (XIZ); x0 / the length are frame locals (declared in reverse slot order), the
   length built in place (`len -= x0; len += 2`). */

struct drect { unsigned int x0, y0, x1, y1; };
extern unsigned char OFFSCREEN_BUFFER_1[];
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void DisplayBuffer_Process(struct drect *);

void DisplayBuffer_Process(struct drect *r)
{
    unsigned long x0;
    unsigned long len;
    register unsigned long i;

    x0 = r->x0 / 2 * 2;
    len = r->x1 / 2 * 2;
    len -= x0;
    len += 2;
    for (i = r->y0; i <= r->y1 / 2; i++)
        Mem_Copy((unsigned char *)0x1a0000L + (i * 320 + x0) / 2 * 2, OFFSCREEN_BUFFER_1 + i * 320 + x0, len);
    for (i = r->y1 / 2; i <= r->y1; i++)
        Mem_Copy((unsigned char *)0x1a0000L + (i * 320 + x0) / 2 * 2, OFFSCREEN_BUFFER_1 + i * 320 + x0, len);
}
