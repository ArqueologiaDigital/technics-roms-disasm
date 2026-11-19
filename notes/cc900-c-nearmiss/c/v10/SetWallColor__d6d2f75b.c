/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_4m271a.c (2026-11-19-29-p6-r46)
   sha256 d6d2f75b0e94b203a6f85f6c0deb8195b69561ae0676c5409a0eadf8c707277d (tar-sha256); compiled at -O3 -Xr */
extern void ChangeWallPalette(int n);
void SetWallColor(int c)
{
	int n;

	switch (c) {
	case 0xf8:
		n = 2;
		break;
	case 2:
		n = 4;
		break;
	case 0xf9:
		n = 6;
		break;
	case 1:
		n = 8;
		break;
	default:
		n = 0;
	}
	ChangeWallPalette(n);
}
