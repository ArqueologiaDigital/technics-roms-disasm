/* Phase 6, lane_p6 helper K, round 3, module 308, form b of p6_K_3m308a.c: Malloc with the split block addressed
   past p's header ((char *)(p + 1) + sz) and the result returned as ++p (the ROM increments XIZ by 6 in place). */

struct blk { struct blk *next; unsigned int size; };

extern struct blk *ram_3d52c;
extern void TaskEvent_Wait(int);
extern void TaskEvent_Signal(int);
extern struct blk *Heap_Alloc(unsigned long);
extern unsigned char *__cdecl Malloc(unsigned int n);

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
