/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/fdemotext_routines.c (2026-11-16-55-p6-r10)
   sha256 6ee42738e94979255222616e3758b0c1b3fd2f84fb7b88794ce2f7e5d985bce8 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
