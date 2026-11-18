/* Phase 6, lane_p6 helper J, round 3, module 273, form c: SetApTimer refinement.  r35's form a unchanged except
   (1) the declarations reordered u, cur, prev (for the ROM's XIZ / IX / IY) and (2) the scan pointer written as
   an integer sum, (long)(cur * 24) + base, for the ROM's muls / exts xiz / add xiz,xwa. */

struct apt { int prev; int next; unsigned long time; long obj; long target; long event; long param; };
extern struct apt ram_2f844[];
extern unsigned long ram_30444;
extern int ram_30448;
#define APT(n) ((struct apt *)((char *)ram_2f844 + (n) * 24))

void SetApTimer(unsigned long time, long obj, long target, long event, long param)
{
	struct apt *u;
	int cur;
	int prev;
	unsigned int i;
	struct apt *t;

	for (i = 0; i < 128; i++) {
		t = &ram_2f844[i];
		if (t->obj == -1) {
			t->time = ram_30444 + time;
			t->obj = obj;
			t->target = target;
			t->event = event;
			t->param = param;
			cur = ram_30448;
			if (cur == -1) {
				ram_30448 = i;
				break;
			}
			prev = -1;
			while ((u = (struct apt *)((long)(cur * 24) + (long)ram_2f844))->time <= t->time) {
				prev = cur;
				cur = u->next;
				if (cur == -1)
					break;
			}
			t->prev = prev;
			t->next = cur;
			if (prev != -1)
				APT(prev)->next = i;
			if (cur != -1)
				APT(cur)->prev = i;
			if (cur == ram_30448)
				ram_30448 = i;
			break;
		}
	}
	if (i == 128)
		for (;;)
			;
}
