/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sprintf_core_m0.c (2026-11-16-68-p6-r12)
   sha256 cea2fdcca9e340cec9b2ea1007bcc7c6d4f466a83a77d28f46a6de92dcac6556 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
int __cdecl Sprintf_FFixed_DataTable(char *p)
{
	for (;;) {
		if (*p == 0)
			return 1;
		if (*p++ != '0')
			return 0;
	}
}
