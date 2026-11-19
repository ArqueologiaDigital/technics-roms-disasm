/* Phase 6, lane_p6 helper L, round 3, form b: module 241, FDC_ExecuteSectorCommand with all three pointer arguments
   in locals assigned just before the call, and the buffer field a pointer stored from a long local copy. */
/* cc900-module: SndTable_CalcSectorPosition */   /* scripts/analysis/cc900/module_calls.py v10 */

struct fdccmd { int op; int f2; int b; int a; int c; int count; void *buf; };
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
	int *pa;
	void *q;

	pc = &c;
	pb = &b;
	pa = &a;
	SndTable_CalcSectorPosition(n, pc, pb, pa);
	cmd.op = 3;
	cmd.f2 = 0;
	cmd.b = b;
	cmd.a = a;
	cmd.c = c;
	cmd.count = 1;
	q = buf;
	cmd.buf = q;
	return FDC_CommandEntry(&cmd);
}
