/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/fdemotext_routines_m265.c (2026-11-16-68-p6-r12)
   sha256 242acaf80aa2f69d34d491d477de5974cdb5336e442bab0fadbaeb0abf3d0704 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void sendCOMM(int, int, unsigned char *);
void FDemoText_SendResetMessage(unsigned char c)
{
	unsigned char b[6];

	b[0] = 0x82;
	b[1] = c;
	b[2] = 2;
	b[3] = 2;
	b[4] = 1;
	b[5] = 0xea;
	sendCOMM(0, 6, b);
	b[2] = 0x82;
	b[3] = 2;
	sendCOMM(0, 6, b);
	b[0] = 0x83;
	b[2] = 2;
	b[3] = 2;
	sendCOMM(0, 6, b);
	b[2] = 0x82;
	b[3] = 2;
	sendCOMM(0, 6, b);
}
