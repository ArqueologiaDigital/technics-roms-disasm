/* Phase 6, lane_p6 helper E, round 5, form b: SeqStep_FileCloseExit of v10 sequencer/smf_event_processor.s (built
   -Xr).  Run 87 gave the ROM's code except the handle-table index: the ROM scales a 16-bit index (`sla wa,2` and
   `(xbc+wa)`), V4.23 sign-extended the int index to 32 bits first.  Form a: unsigned int index; form b
   (p6_E_5b.c): the table read through a 16-bit byte offset. */

struct fd;

typedef int __cdecl CTLFN(struct fd *, int, long);

struct ops { char pad[36]; CTLFN *ctl; };
struct fd { char p0[4]; unsigned char open; unsigned char slot; char p6[8]; struct ops *ops; };

extern int FILE_ERROR;
extern struct fd *ram_210b4[];

#define TBL(i) (*(struct fd **)((char *)ram_210b4 + ((i) << 2)))

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
		if (TBL(i) != 0 && TBL(i) != (struct fd *)-1)
			r |= TBL(i)->ops->ctl(TBL(i), 1, arg);
	}
	return r;
}
