/* Phase 6, lane_p6 helper M, round 2, module 283 (audio/sndparam_routines.s), form a.
   SndParam_AllocAndInsert: allocate a 12-byte {key, value, next} node, key = (a << 16) | (c << 8) | e, hash the
   key's nibbles 2..5 (base 513, mod 0x7ff) into the bucket table ram_97d8 and link the node there (at the head of
   an empty bucket, else after the chain's last node); halts on out of memory.  The ROM keeps the node pointer in
   two frame locals (p +8, q +4; key +12) and writes the key through p in one branch and q in the other; the
   value pointer (4th argument, on the stack) and &p->val / &q->next are loaded before the branch. */
/* cc900-module: SndParam_HeapAlloc */

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
	unsigned long k;
	unsigned int i;
	struct sprec *t;

	p = SndParam_HeapAlloc(12);
	q = p;
	if (q == 0) {
		Debug_PrintString(SndParam_OutOfMemoryMsg);
		Boot_HaltInstruction(1);
	}
	key = e;
	key |= ((unsigned long)a << 16) | ((unsigned long)c << 8);
	k = key >> 8;
	i = ((((k & 0xf) * 513 + ((k >> 4) & 0xf)) * 513 + ((k >> 8) & 0xf)) * 513 + ((k >> 12) & 0xf)) % 0x7ff;
	if (ram_97d8[i] == 0) {
		p->key = key;
		p->val = val;
		q->next = ram_97d8[i];
		ram_97d8[i] = q;
	} else {
		t = ram_97d8[i];
		while (t->next != 0)
			t = t->next;
		q->key = key;
		p->val = val;
		q->next = t->next;
		t->next = q;
	}
	return 0;
}
