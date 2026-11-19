/* Phase 6, lane_p6 helper L, round 1, form b: module 238, FatPath_Next83Component with `(*pp)++` and the character
   loop spelled `if (i < 11) do ... while (++i < 11)` (the ROM tests the bound at the entry and after the step). */
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
			(*pp)++;
		i = 0;
		if (i < 11)
			do {
				if (**pp == 0)
					break;
				if (**pp == '/' || **pp == '\\') {
					r = 1;
					break;
				}
				if (**pp == '.') {
					if (i > 1 || (i == 1 && dst[0] != '.')) {
						i = 7;
						(*pp)++;
						continue;
					}
				}
				dst[i] = **pp;
				(*pp)++;
			} while (++i < 11);
		if (**pp == '/' || **pp == '\\')
			r = 1;
		else if (**pp != 0)
			r = -1;
	} while (dst[0] == '.' && dst[1] == ' ');
	return r;
}
