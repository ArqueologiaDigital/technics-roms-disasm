/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_E_1b.c (2026-11-16-53-p6-r11)
   sha256 af9144b9a9bddfd9059a29fa80db190b75b8eb25bbb020704296290ca40e1b5a (tar-sha256); compiled at -Xr */
void __cdecl SeqStep_FileSectorDone(unsigned int v, unsigned char **pp)
{
	*(*pp)++ = v & 0xff;
	*(*pp)++ = v >> 8;
}
