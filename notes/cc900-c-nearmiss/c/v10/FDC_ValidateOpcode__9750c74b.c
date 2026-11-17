/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_1a.c (2026-11-16-31-p6-r1b)
   sha256 9750c74bf124b2aa99540b8b4b6fdaab7ef7968b5c9e4dc00f22f063b001454d (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near FDC_CMD_OPCODE;
unsigned char FDC_ValidateOpcode(void)
{
	unsigned char c;

	if (FDC_CMD_OPCODE == 79 || FDC_CMD_OPCODE == 51 || FDC_CMD_OPCODE == 52 || FDC_CMD_OPCODE == 71
	    || FDC_CMD_OPCODE == 53)
		return 0;
	c = FDC_CMD_OPCODE & 31;
	if (c == 30 || c == 29 || c == 25) return 0;
	if (c == 16) return 1;
	if (c == 17) return 0;
	if (c > 15 || c < 2) return 1;
	return 0;
}
