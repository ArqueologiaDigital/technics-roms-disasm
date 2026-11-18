/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_1m273a.c (2026-11-18-12-p6-r35)
   sha256 67745fa4f984377e224b8676d6fd4313c43623c5bb056a1cb7225a660dbf72ac (tar-sha256); compiled at -O3 -Xr */
struct apt { int prev; int next; unsigned long time; long obj; long target; long event; long param; };
extern struct apt ram_2f844[];
extern unsigned long ram_30444;
extern int ram_30448;
#define APT(n) ((struct apt *)((char *)ram_2f844 + (n) * 24))
void SetApTimer(unsigned long time, long obj, long target, long event, long param)
{
	unsigned int i;
	int prev;
	int cur;
	struct apt *t;
	struct apt *u;

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
			while ((u = APT(cur))->time <= t->time) {
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
