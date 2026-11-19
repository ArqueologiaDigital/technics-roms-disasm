/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_1m241a.c (2026-11-19-15-p6-r42)
   sha256 7e4397b429811c67af41447cd711a03b33ee60af3bfaa84c09fcc650a0303020 (tar-sha256); compiled at -Xr */
struct fdccmd { int op; int f2; int b; int a; int c; int count; void *buf; };
extern void SndTable_CalcSectorPosition(unsigned int n, int *c, int *b, int *a);
extern int __cdecl FDC_CommandEntry(struct fdccmd *cmd);
int FDC_ExecuteSectorCommand(unsigned int n, void *buf)
{
	int c;
	int b;
	int a;
	struct fdccmd cmd;

	SndTable_CalcSectorPosition(n, &c, &b, &a);
	cmd.op = 3;
	cmd.f2 = 0;
	cmd.b = b;
	cmd.a = a;
	cmd.c = c;
	cmd.count = 1;
	cmd.buf = buf;
	return FDC_CommandEntry(&cmd);
}
