/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_4m276b.c (2026-11-19-29-p6-r46)
   sha256 dc6cd5d494c0dd961b6b54979a17dc073d47d62a2fecb5a303be4779646d5164 (tar-sha256); compiled at -Xr */
#define EVT_PAGE_CHANGE 0x1c0001eL
struct fdccmd { int op; int f2; int b; int a; int c; int count; void *buf; };
extern int __cdecl FDC_CommandEntry(struct fdccmd *cmd);
extern unsigned char __near FDC_ERROR_CODE;
extern long ApPostEvent(long, long, long);
void FDC_CommandAndPostEvent(void)
{
	struct fdccmd cmd;
	unsigned char e;

	cmd.op = 3;
	FDC_CommandEntry(&cmd);
	e = FDC_ERROR_CODE;
	if (e == 0xfc)
		ApPostEvent(-1, EVT_PAGE_CHANGE, 2);
	else
		ApPostEvent(-1, EVT_PAGE_CHANGE, 1);
}
