/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sprintf_core_xs.c (2026-11-16-33-p6-r2)
   sha256 9375eba28fa29f3fadceda45783dd0991abcb6eeb9fd4b918e5f468f5b8aff26 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -XS -Xr */
extern char ram_3c224[];
void __cdecl Sprintf_InsertCarry(int v, int pos)
{
	if (pos < 32) ram_3c224[pos] += v;
	while (pos >= 32) pos--;
	while (ram_3c224[pos] >= 10 && pos > 0) {
		ram_3c224[pos - 1]++;
		ram_3c224[pos--] -= 10;
	}
}
