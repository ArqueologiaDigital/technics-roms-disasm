/* Phase 6, lane_p6 helper K, round 2, module 239 (sequencer/smf_event_processor.s), form a: two of the floppy
   device's sector hooks, __cdecl (r, a, b, c, d, buf).  Both pass r's device byte (+4) and the arguments on to
   SeqStep_ParseVariableHeader(op, dev, b, a, c, d, buf) -- a and b swapped, as the ROM pushes them -- with op 3
   (read) or 4 (write).  SeqChan_ByteBlockC first reports a disk change (6) and, for a 2HD-type disk read of sector
   (0, 0, 1), probes with FDC_PROBE_FLAG set: on success it marks byte 16 of the sector, on failure it returns an
   empty sector (SeqChan_ByteBlockC_Str_Empty, 512 bytes); both return 0. */
/* cc900-module: SeqStep_ParseVariableHeader */   /* scripts/analysis/cc900/module_calls.py v10 */

struct rq { unsigned char drv; char p1; char p2; unsigned char fl3; unsigned char b4; unsigned char unit; };

extern int __near FDC_PROBE_FLAG;
extern char SeqChan_ByteBlockC_Str_Empty[];
extern int FDC_ReadDiskChangeStatus(void);
extern void FDC_ClearDiskChangeStatus(void);
extern unsigned char FDC_ReadDiskType(void);
extern void *__cdecl Mem_Copy(void *, void *, int);
extern int __cdecl SeqStep_ParseVariableHeader(int op, int dev, int b, int a, int c, int d, unsigned char *buf);
extern int __cdecl SeqChan_ByteBlockC(struct rq *r, int a, int b, int c, int d, unsigned char *buf);
extern int __cdecl SeqChan_ByteBlockD(struct rq *r, int a, int b, int c, int d, unsigned char *buf);

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

int __cdecl SeqChan_ByteBlockD(struct rq *r, int a, int b, int c, int d, unsigned char *buf)
{
	return SeqStep_ParseVariableHeader(4, r->b4, b, a, c, d, buf);
}
