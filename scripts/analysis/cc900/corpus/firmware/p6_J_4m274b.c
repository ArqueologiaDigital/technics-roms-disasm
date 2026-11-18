/* Phase 6, lane_p6 helper J, round 4, module 274, form b: ConvertStrings without gotos (break to a common
   terminator after the loop). */
/* cc900-module: HexCharToNibble */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char HexCharToNibble(int c);

void ConvertStrings(unsigned char *src, unsigned char *dst)
{
	for (;;) {
		if (*src == '~') {
			if (*++src == 0)
				break;
			*dst = HexCharToNibble(*src) << 4;
			if (*++src == 0)
				break;
			*dst += HexCharToNibble(*src);
		} else if (*src == 0) {
			*dst = *src;
			return;
		} else if (*src < 0x20)
			*dst = ' ';
		else
			*dst = *src;
		src++;
		dst++;
	}
	*dst = 0;
}
