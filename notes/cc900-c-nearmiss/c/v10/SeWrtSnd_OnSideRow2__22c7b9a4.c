/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_14m152a.c (2026-11-19-92-p6-r57)
   sha256 22c7b9a48171c72ebec27ce931d00035feba8eb9fe66fe2fd75f038fbcd9b8ea (tar-sha256); compiled at -O3 -XS -Xr */
extern void SeWrtSnd_ClearName_Join(void);
void SeWrtSnd_OnSideRow2(unsigned char a)
{
	if (a != 0)
		return;
	SeWrtSnd_ClearName_Join();
}
