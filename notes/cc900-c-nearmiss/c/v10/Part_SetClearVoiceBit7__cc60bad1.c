/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_5m234a.c (2026-11-19-37-p6-r47)
   sha256 cc60bad19ae10448167216037fc218caf5a95e41a3bcf8f414c2d43efdc802c8 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char Part_ReadByteDirect(unsigned char, unsigned int);
extern void Part_WriteByte(unsigned char, unsigned int, unsigned char);
void Part_SetClearVoiceBit7(unsigned char s, unsigned char p, unsigned char on)
{
	unsigned char v;

	v = Part_ReadByteDirect(s, (unsigned char)((p - 1) * 3 + 0xd0));
	if (on != 0)
		v |= 0x80;
	else
		v &= ~0x80;
	Part_WriteByte(s, (unsigned char)((p - 1) * 3 + 0xd0), v);
}
