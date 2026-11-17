/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_1a.c (2026-11-16-43-sub-r1)
   sha256 4bc0178b46d1ffb547ace75007900fa7f89605d5dc169b4831cf3f861ece1a66 (name+funcs); compiled at -O3 -Xr */
extern unsigned int ram_4136a[];
void Voice_ClearLFO_ActiveFlag(unsigned char part) { *(unsigned int *)((char *)ram_4136a + part * 0x11f) &= ~0x2000; }
