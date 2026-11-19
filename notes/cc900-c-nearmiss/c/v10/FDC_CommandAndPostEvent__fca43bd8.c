/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_2m276a.c (2026-11-19-19-p6-r43)
   sha256 fca43bd802093dfcdfe570e7be9800982e4d16d94d302d970c4145f461e8fe47 (tar-sha256); compiled at -O3 -Xr */
#define EVT_PAGE_CHANGE 0x1c0001eL
struct fdccmd { int op; int f2; int b; int a; int c; int count; void *buf; };
extern int __cdecl FDC_CommandEntry(struct fdccmd *cmd);
extern unsigned char __near FDC_ERROR_CODE;
extern long ApPostEvent(long, long, long);
void FDC_CommandAndPostEvent(void)
{
	struct fdccmd cmd;

	cmd.op = 3;
	FDC_CommandEntry(&cmd);
	if (FDC_ERROR_CODE == 0xfc)
		ApPostEvent(-1, EVT_PAGE_CHANGE, 2);
	else
		ApPostEvent(-1, EVT_PAGE_CHANGE, 1);
}
