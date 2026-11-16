/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_1b.c (2026-11-16-31-p6-r1b)
   sha256 f545fd217b726e00a01edbda07882c98420980af6c0fec92898ed4803639eb58 (tar-sha256); compiled at -O3 -XS -Xr */
extern char ram_3c224[];
void __cdecl Sprintf_InsertCarry(int v, int pos)
{
	if (pos < 32) ram_3c224[pos] += (char)v;
	while (pos >= 32) pos--;
	while (ram_3c224[pos] >= 10 && pos > 0) {
		ram_3c224[pos - 1]++;
		ram_3c224[pos] -= 10;
		pos--;
	}
}
