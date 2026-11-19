/* Phase 6, lane_p6 helper L, round 1, form a: module 238 (sequencer/smf_event_processor.s), an -Xr routine.
   - FatPath_Next83Component: __cdecl (both arguments on the stack, as its matched callers in
     cc900/smf_event_processor_m238_xr_d.c declare it); a blank-filled 8.3 name from the path at *pp, restarted
     while the name is ". " ; for loop with `continue` after the extension jump. */
/* (no module-local callee) */

extern void *__cdecl Memset(void *, int, unsigned int);
int __cdecl FatPath_Next83Component(char *dst, char **pp);

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
