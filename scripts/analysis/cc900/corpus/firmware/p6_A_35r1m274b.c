/* Probe round 35r1, helper A, form b: display/graphics_text_vga.s (module 274), xr_screen family.
   DisplayBuffer_Process as form a, with the length computed in one expression, the row offset in a plain local,
   and both loops written as while loops (bottom test entered by a jump). */

struct drect { unsigned int x0, y0, x1, y1; };
extern unsigned char OFFSCREEN_BUFFER_1[];
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void DisplayBuffer_Process(struct drect *);

void DisplayBuffer_Process(struct drect *r)
{
    unsigned long x0;
    unsigned long len;
    register unsigned long i;
    unsigned long o;

    x0 = r->x0 / 2 * 2;
    len = r->x1 / 2 * 2 - x0 + 2;
    i = r->y0;
    while (i <= r->y1 / 2) {
        o = i * 320 + x0;
        Mem_Copy((unsigned char *)0x1a0000L + o / 2 * 2, OFFSCREEN_BUFFER_1 + o, len);
        i++;
    }
    i = r->y1 / 2;
    while (i <= r->y1) {
        o = i * 320 + x0;
        Mem_Copy((unsigned char *)0x1a0000L + o / 2 * 2, OFFSCREEN_BUFFER_1 + o, len);
        i++;
    }
}
