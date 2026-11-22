/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_20r2m152a.c (2026-11-21-5-p6-r60)
   sha256 e8ba54658bc61a7bf4a80736b1579a3dd2be3748755cb1960eb3843e924d9cd0 (tar-sha256); compiled at -O3 -XS -Xr */
extern void SeWrtSnd_SetupNamingPage_Join4(unsigned int w);
void SeWrtSnd_OnColumn7(unsigned char a)
{
	unsigned int w;

	w = 0x8000;
	if ((a & 0x7f) == 0)
		w = 0;
	SeWrtSnd_SetupNamingPage_Join4(w);
}
