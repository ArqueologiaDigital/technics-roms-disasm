/* Phase 6, lane_p6 helper M, round 4, module 283, form a: SndParam_AllocAndInsert retry (run r42: +3, the O3Xr
   listing had the ROM's structure).  Spots: (1) the ROM keeps the value (stack argument) in XIZ, so it pushes XIZ
   and its frame sits 4 higher; V4.23 used XIY: the value copied into a local v (a local copy wins XIZ);
   (2) the key: the ROM builds (a << 16) | (c << 8) first, then stores e and ors it in: a local t;
   (3) the bucket address computed twice (XIY for the test, XBC for the writes): the test through a pointer local b,
   the writes through ram_97d8[i]. */
/* cc900-module: SndParam_HeapAlloc */   /* scripts/analysis/cc900/module_calls.py v10 */

struct sprec { unsigned long key; long val; struct sprec *next; };
extern struct sprec *SndParam_HeapAlloc(unsigned int n);
extern void Debug_PrintString(char *);
extern void __cdecl Boot_HaltInstruction(int);
extern char SndParam_OutOfMemoryMsg[];
extern struct sprec * __near ram_97d8[];
extern int SndParam_AllocAndInsert(unsigned char a, unsigned char c, unsigned char e, long val);

int SndParam_AllocAndInsert(unsigned char a, unsigned char c, unsigned char e, long val)
{
	struct sprec *q;
	struct sprec *p;
	unsigned long key;
	unsigned long t;
	unsigned long k;
	unsigned int i;
	struct sprec **b;
	struct sprec *n;
	long v;

	p = SndParam_HeapAlloc(12);
	q = p;
	if (q == 0) {
		Debug_PrintString(SndParam_OutOfMemoryMsg);
		Boot_HaltInstruction(1);
	}
	t = ((unsigned long)a << 16) | ((unsigned long)c << 8);
	key = e;
	key |= t;
	k = key >> 8;
	i = ((((k & 0xf) * 513 + ((k >> 4) & 0xf)) * 513 + ((k >> 8) & 0xf)) * 513 + ((k >> 12) & 0xf)) % 0x7ff;
	b = &ram_97d8[i];
	v = val;
	if (*b == 0) {
		p->key = key;
		p->val = v;
		q->next = ram_97d8[i];
		ram_97d8[i] = q;
	} else {
		n = ram_97d8[i];
		while (n->next != 0)
			n = n->next;
		q->key = key;
		p->val = v;
		q->next = n->next;
		n->next = q;
	}
	return 0;
}
