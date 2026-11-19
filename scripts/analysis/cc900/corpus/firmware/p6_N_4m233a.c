/* lane_p6 helper N, round 4, form a: module 233 (sequencer/sequencer_engine.s), retry of p6_N_2m233a / b
   (p6-r43 Xr: +12).  SeqPart_ReadEventStream: the ROM reads the saved position as two word moves through the
   element's address (`lda xbc,(xbc+wa)`, signed 16-bit index after sla) and writes it back the same way (both
   words loaded first, the element address by exts + add), where V4.23 copied whole structs with ldiw and used
   unsigned 32-bit indexing.  Here: the table SIZED, both moves member by member through an element pointer.
   cc900-options: -O3 -Xr
*/

struct bo { unsigned int block; unsigned int offset; };
struct evrec { unsigned int count; unsigned char ev[6]; };
extern struct bo __near ram_23e0[16];
extern struct evrec __near ram_23c0;
extern void SeqPart_ReadNextEventByte(struct bo *, unsigned char *);

void SeqPart_ReadEventStream(unsigned char p, unsigned char c)
{
	unsigned char ev[8];
	struct bo pos;
	struct bo *t;
	unsigned char *s;
	unsigned char *d;
	unsigned char *e;
	unsigned int b;
	unsigned int o;

	t = &ram_23e0[(unsigned char)(p - 1)];
	pos.block = t->block;
	pos.offset = t->offset;
	for (;;) {
		SeqPart_ReadNextEventByte(&pos, ev);
		s = ev;
		if (*s == 0x81) {
			ram_23c0.count++;
			s[1] = 0;
			if (c == 0)
				break;
		} else {
			if (*s == 0x82)
				s[1] = 0;
			break;
		}
	}
	b = pos.block;
	o = pos.offset;
	t = &ram_23e0[(unsigned char)(p - 1)];
	t->block = b;
	t->offset = o;
	d = ram_23c0.ev;
	e = s + 6;
	do
		*d++ = *s++;
	while (s < e);
}
