/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/smf_event_processor_m239_xr.c (2026-11-18-33-p6-r37)
   sha256 a626394f74925750a17470500f2793ee7d939ee87002a1bac46e8652c59963d9 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
struct rq { unsigned char drv; char p1; char p2; unsigned char fl3; unsigned char b4; unsigned char unit; };
extern int __cdecl SeqStep_ParseVariableHeader(int op, int dev, int b, int a, int c, int d, unsigned char *buf);
int __cdecl SeqChan_ByteBlockD(struct rq *r, int a, int b, int c, int d, unsigned char *buf)
{
	return SeqStep_ParseVariableHeader(4, r->b4, b, a, c, d, buf);
}
