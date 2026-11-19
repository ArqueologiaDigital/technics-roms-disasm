/* Phase 6, lane_p6 helper L, round 3, form a: module 241.  Retry of FDC_ExecuteSectorCommand (round 1 Xr: +7).
   The ROM computes &c and &b (into XHL, XDE) before it pushes &a, so the two register arguments go through
   pointer locals assigned just before the call (today's idiom 1).  The buffer field is a long assigned through a
   cast (the ROM stores the buffer via XWA, not straight from XIZ). */
/* cc900-module: SndTable_CalcSectorPosition */   /* scripts/analysis/cc900/module_calls.py v10 */

struct fdccmd { int op; int f2; int b; int a; int c; int count; long buf; };
extern void SndTable_CalcSectorPosition(unsigned int n, int *c, int *b, int *a);
extern int __cdecl FDC_CommandEntry(struct fdccmd *cmd);
extern int FDC_ExecuteSectorCommand(unsigned int n, void *buf);

int FDC_ExecuteSectorCommand(unsigned int n, void *buf)
{
	int c;
	int b;
	int a;
	struct fdccmd cmd;
	int *pc;
	int *pb;

	pc = &c;
	pb = &b;
	SndTable_CalcSectorPosition(n, pc, pb, &a);
	cmd.op = 3;
	cmd.f2 = 0;
	cmd.b = b;
	cmd.a = a;
	cmd.c = c;
	cmd.count = 1;
	cmd.buf = (long)buf;
	return FDC_CommandEntry(&cmd);
}
