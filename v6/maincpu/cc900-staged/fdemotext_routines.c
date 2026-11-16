/* Functions of demo/fdemotext_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

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
