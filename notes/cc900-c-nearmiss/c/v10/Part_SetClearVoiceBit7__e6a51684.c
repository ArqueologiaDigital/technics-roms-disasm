/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_6m234a.c (2026-11-19-49-p6-r49)
   sha256 e6a5168479918795ea530fb9e23aea0c130fea87bad146698930a85222c34e2d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char Part_ReadByteDirect(unsigned char, unsigned int);
extern void Part_WriteByte(unsigned char, unsigned int, unsigned char);
void Part_SetClearVoiceBit7(unsigned char s, unsigned char p, unsigned char on)
{
	unsigned char v;

	v = Part_ReadByteDirect(s, (unsigned char)((unsigned char)(p * 3 - 3) + 0xd0));
	if (on != 0)
		v |= 0x80;
	else
		v &= ~0x80;
	Part_WriteByte(s, (unsigned char)((unsigned char)(p * 3 - 3) + 0xd0), v);
}
