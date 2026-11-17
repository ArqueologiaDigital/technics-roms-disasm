/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_E_1a.c (2026-11-16-55-p6-r10)
   sha256 7b4aee5b81f515a2e1f7fc404589f1222422e467e9e824ce753bf2d256f1e49c (tar-sha256); compiled at -O3 -Xr */
int __cdecl Sprintf_FFixed_DataTable(char *p)
{
	for (;;) {
		if (*p == 0)
			return 1;
		if (*p++ != '0')
			return 0;
	}
}
