/* Phase 6, lane_p6 helper E, round 3, form b: the stdio close routines of v10 sequencer/smf_event_processor.s
   (built -Xr), under the firmware names.  Form a (p6_E_3a.c) has the same names; b swaps the handle-table
   compare and declares fr before slot.
   The (char) on the error store is what matched in SeqStep_ByteBlockF245 (round 1 form b). */

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
	int fr;
	int slot;

	if (h == 0 || h->open == 0 || h != ram_210b4[h->slot]) {
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

/* Calls the control method (+36) of handle h with (1, arg), or of every open handle when h is 0, OR-ing the
   results.  arg is a local the routine never sets. */
int __cdecl SeqStep_FileCloseExit(struct fd *h)
{
	long arg;
	int r;
	int i;

	r = 0;
	if (h != 0) {
		if (h->open != 0)
			return h->ops->ctl(h, 1, arg);
		FILE_ERROR = 25;
		return -1;
	}
	for (i = 0; i < 16; i++) {
		if (ram_210b4[i] != 0 && ram_210b4[i] != (struct fd *)-1)
			r |= ram_210b4[i]->ops->ctl(ram_210b4[i], 1, arg);
	}
	return r;
}
