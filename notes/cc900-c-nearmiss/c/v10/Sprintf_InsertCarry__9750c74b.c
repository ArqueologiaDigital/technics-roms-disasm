/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_1a.c (2026-11-16-32-p6-m18-olevels)
   sha256 9750c74bf124b2aa99540b8b4b6fdaab7ef7968b5c9e4dc00f22f063b001454d (tar-sha256); compiled at -O1 -Xr */
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
