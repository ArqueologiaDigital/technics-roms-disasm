/* Phase 6, lane_p6 helper J, round 4, module 274 (display/graphics_text_vga.s, -O3 -Xr), form a: ConvertStrings.
   Copy a display string: "~hh" becomes the byte 0xhh, a control character a space, and the NUL is copied.  The
   ROM lays the "~" block with its own NUL exit, then the NUL copy whose return carries the epilogue (V4.23 puts
   the epilogue after the last explicit return), then the printable test: written with a goto in that order.
   src is kept in XIZ, dst in the frame. */
/* cc900-module: HexCharToNibble */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char HexCharToNibble(int c);

void ConvertStrings(unsigned char *src, unsigned char *dst)
{
	for (;;) {
		if (*src == '~') {
			src++;
			if (*src == 0)
				goto term;
			*dst = HexCharToNibble(*src) << 4;
			src++;
			if (*src == 0)
				goto term;
			*dst += HexCharToNibble(*src);
			goto next;
term:
			*dst = 0;
			return;
		}
		if (*src == 0) {
			*dst = *src;
			return;
		}
		if (*src < 0x20)
			*dst = ' ';
		else
			*dst = *src;
next:
		src++;
		dst += 1;
	}
}
