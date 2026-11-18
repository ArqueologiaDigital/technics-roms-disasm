/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_3m308b.c (2026-11-18-28-p6-r36)
   sha256 b9ce2dd96382f08543717a9dd2deed91a027e02df7a2cd9547ab7f0a765f4b39 (tar-sha256); compiled at -O3 -Xr */
struct blk { struct blk *next; unsigned int size; };
extern struct blk *ram_3d52c;
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
extern struct blk *Heap_Alloc(unsigned long);
unsigned char *__cdecl Malloc(unsigned int n)
{
	struct blk *prev;
	unsigned int sz;
	struct blk *p;
	struct blk *q;

	sz = (n + 1) >> 1;
	sz += sz;
	TaskEvent_Wait(1);
	p = ram_3d52c;
	while (p != 0) {
		if (p->size >= sz)
			break;
		prev = p;
		p = p->next;
	}
	if (p != 0) {
		if (p->size - sz >= 10) {
			q = (struct blk *)((char *)(p + 1) + sz);
			q->next = p->next;
			q->size = p->size - 6 - sz;
			p->next = q;
			p->size = sz;
		}
		if (p == ram_3d52c)
			ram_3d52c = p->next;
		else
			prev->next = p->next;
	} else {
		p = Heap_Alloc(sz + 6);
		if (p == (struct blk *)0xffffffffUL) {
			TaskEvent_Signal(1);
			return 0;
		}
		p->next = 0;
		p->size = sz;
	}
	TaskEvent_Signal(1);
	return (unsigned char *)++p;
}
