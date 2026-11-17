/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/smf_event_processor_m238_xr.c (2026-11-16-111-p6-r22-staged)
   sha256 dd3925e55ba5b17268c1e18334141b467cec504b7b4028f2dd3cc77af4575978 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct buf;
typedef int __cdecl SECFN(long, struct buf *);
struct ops { char pad[20]; SECFN *wsec; };
struct geom { char pad[12]; long l12; char pad1[32]; unsigned int spf; char pad2[8]; unsigned char nfat; char pad3; };
struct vol { char pad[2]; unsigned char vflags; char p3; char pad1[10]; struct ops *ops; char pad2[8];
	struct geom *geom; };
struct buf { struct vol *vol; long sec; long l8; char pad[6]; unsigned int age; int stat; unsigned char flags;
	unsigned char idx; unsigned char drv; char pad2; unsigned char data[512]; };
struct vrec { char pad[20]; unsigned long datastart; unsigned long fatstart; unsigned long rootstart;
	unsigned long spc; unsigned int mask; unsigned int bps; unsigned int clbytes; char pad1[4];
	unsigned int rootsecs; char pad2[6]; unsigned int maxcl; };
struct vol2 { char pad[26]; struct vrec *vrec; };
struct fil { char p0; char p1; char p2; unsigned char flags3; char p4[14]; struct vol2 *vol; unsigned long pos;
	unsigned long start; struct vrec *vrec; char p34[4]; struct buf *lastbuf; unsigned int curclus; unsigned int cnt;
	unsigned int curidx; };
unsigned int __cdecl Fat_ReadEntry(struct fil *f, unsigned int n);
extern unsigned int __cdecl Fat_ReadEntry(struct fil *f, unsigned int n);
unsigned int __cdecl Fat_CountContiguousClusters(struct fil *f)
{
	unsigned int c;
	unsigned int last;
	unsigned int n;

	last = f->vrec->mask - 8;
	c = f->curclus;
	if (c == 0) {
		f->cnt = 0;
		return 0;
	}
	f->cnt = 1;
	while ((n = Fat_ReadEntry(f, c)) <= last) {
		if (++c != n)
			break;
		f->cnt++;
	}
	return f->cnt;
}
