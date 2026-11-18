/* Phase 6, lane_p6 helper K, round 3, module 308 (audio/note_voice_mapping.s), form a: Malloc(n), __cdecl, the
   firmware heap's first-fit allocator.  Blocks carry a 6-byte header {next, size}; the free list head is the long
   at 0x3d52c; the request is rounded up to even (written as two statements: the ROM stores the half and adds it to
   the cell).  A block at least 10 bytes larger is split; a miss asks Heap_Alloc for size + 6 and fails with 0 when
   it returns -1.  TaskEvent_Wait / _Signal(1) guard the list.  Returns the address past the header. */

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
			q = (struct blk *)((char *)p + sz + 6);
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
	return (unsigned char *)(p + 1);
}
