/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_2m239a.c (2026-11-18-28-p6-r36)
   sha256 8c91049bb3c1528b763076ea8707f1b56c300e6356d11d4253dff04fee1111f4 (tar-sha256); compiled at -O3 -Xr */
struct rq { unsigned char drv; char p1; char p2; unsigned char fl3; unsigned char b4; unsigned char unit; };
extern int __near FDC_PROBE_FLAG;
extern char SeqChan_ByteBlockC_Str_Empty[];
extern int FDC_ReadDiskChangeStatus(void);
extern void FDC_ClearDiskChangeStatus(void);
extern unsigned char FDC_ReadDiskType(void);
extern void *__cdecl Mem_Copy(void *, void *, int);
extern int __cdecl SeqStep_ParseVariableHeader(int op, int dev, int b, int a, int c, int d, unsigned char *buf);
int __cdecl SeqChan_ByteBlockC(struct rq *r, int a, int b, int c, int d, unsigned char *buf)
{
	int rc;

	if (FDC_ReadDiskChangeStatus() != 0) {
		FDC_ClearDiskChangeStatus();
		return 6;
	}
	if (FDC_ReadDiskType() == 2 && a == 0 && b == 0 && c == 1) {
		FDC_PROBE_FLAG = -1;
		rc = SeqStep_ParseVariableHeader(3, r->b4, 0, 0, 1, 1, buf);
		FDC_PROBE_FLAG = 0;
		if (rc == 0) {
			buf[16] = 2;
			return 0;
		}
		Mem_Copy(buf, SeqChan_ByteBlockC_Str_Empty, 512);
		return 0;
	}
	return SeqStep_ParseVariableHeader(3, r->b4, b, a, c, d, buf);
}
