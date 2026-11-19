/* HELD BACK (lane_p6, 2026-11-19): see v10/maincpu/cc900-staged/smf_event_processor_m238_xr.c.
   Functions of sequencer/smf_event_processor.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern void *__cdecl Memset(void *, int, unsigned int);
int __cdecl FatPath_Next83Component(char *dst, char **pp);
extern int __cdecl FatPath_Next83Component(char *dst, char **pp);

int __cdecl FatPath_Next83Component(char *dst, char **pp)
{
	int r;
	int i;

	do {
		Memset(dst, ' ', 11);
		dst[11] = 0;
		r = 0;
		if (**pp == '/' || **pp == '\\')
			*pp += 1;
		for (i = 0; i < 11; i++) {
			if (**pp == 0)
				break;
			if (**pp == '/' || **pp == '\\') {
				r = 1;
				break;
			}
			if (**pp == '.') {
				if (i > 1 || (i == 1 && dst[0] != '.')) {
					i = 7;
					*pp += 1;
					continue;
				}
			}
			dst[i] = **pp;
			*pp += 1;
		}
		if (**pp == '/' || **pp == '\\')
			r = 1;
		else if (**pp != 0)
			r = -1;
	} while (dst[0] == '.' && dst[1] == ' ');
	return r;
}
