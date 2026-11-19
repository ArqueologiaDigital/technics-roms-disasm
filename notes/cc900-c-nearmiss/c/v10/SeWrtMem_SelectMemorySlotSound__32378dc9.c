/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_2m129a.c (2026-11-19-19-p6-r43)
   sha256 32378dc9228e44ae21e6a84bdb4e9f965843a58b76181062ede977b1d86bf4b5 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_LoadMasterPtr(unsigned char *m);
extern unsigned char __near PANEL_PART_RT1[];
extern unsigned char __near PANEL_PART_RT2[];
extern unsigned char __near PANEL_PART_LEFT[];
extern void SndParam_ApplyProgramChange(unsigned char *);
extern void __cdecl SeMenu_DisplayPartValue(int, int, int);
void SeWrtMem_SelectMemorySlotSound(unsigned char n)
{
	unsigned char s[6];
	unsigned char m;
	unsigned char q;
	unsigned char r;
	unsigned char *p;

	SeMenu_LoadMasterPtr(&m);
	q = n / 20;
	r = n % 20;
	if (q != 0)
		q = 17;
	else
		q = 16;
	s[0] = q;
	s[1] = r;
	s[2] = m;
	SndParam_ApplyProgramChange(s);
	q = s[3];
	r = s[4];
	if (m == 1)
		p = PANEL_PART_RT2;
	else if (m == 2)
		p = PANEL_PART_LEFT;
	else
		p = PANEL_PART_RT1;
	p[0] = q;
	p[1] = r;
	SeMenu_DisplayPartValue(m, q, r);
}
