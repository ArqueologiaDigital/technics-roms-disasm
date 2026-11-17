/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_E_3a.c (2026-11-16-87-p6-r15)
   sha256 edccf9bafc5463c74d72f517fd68e6616fcc4f1c721cd32c706c64a583b20870 (tar-sha256); compiled at -O3 -XS -Xr */
struct fd;
typedef int __cdecl CLOSEFN(struct fd *);
typedef int __cdecl CTLFN(struct fd *, int, long);
struct ops { char pad[20]; CLOSEFN *close; char pad1[12]; CTLFN *ctl; };
struct fd { char p0[4]; unsigned char open; unsigned char slot; char p6[8]; struct ops *ops; };
extern int FILE_ERROR;
extern struct fd *ram_210b4[];
extern unsigned char ram_210f4;
extern int __cdecl SeqStep_FreeMemory(void *p);
extern void __cdecl SeqStep_FileNopA(int n);
extern void __cdecl SeqStep_FileNopB(void);
int __cdecl SeqStep_FileCloseInner(struct fd *h)
{
	int r;
	int slot;
	int fr;

	if (h == 0 || h->open == 0 || ram_210b4[h->slot] != h) {
		FILE_ERROR = 0x11;
		return -1;
	}
	r = h->ops->close(h);
	if (r != 0)
		FILE_ERROR = (char)r;
	ram_210f4++;
	ram_210b4[h->slot] = 0;
	slot = h->slot;
	fr = SeqStep_FreeMemory(h);
	if (fr != 0 && r == 0)
		FILE_ERROR = 0x26;
	SeqStep_FileNopA(slot + 100);
	SeqStep_FileNopB();
	if (r != 0 || fr != 0)
		return -1;
	return 0;
}
