/* lane_p6 helper N, round 2, form a: module 233 (sequencer/sequencer_engine.s).
   SeqPart_ReadEventStream: reads the next event of part p from its saved {block, offset} position (the 4-byte
   table at 0x23e0, as in SeqPart_ClearSingle), skipping end marks 0x81 (counted at 0x23c0) while c is set; saves
   the position back and copies the event's 6 bytes after the counter.  Form a: both position moves as struct
   assignments.
   cc900-options: -O3 -Xr
*/

struct bo { unsigned int block; unsigned int offset; };
struct evrec { unsigned int count; unsigned char ev[6]; };
extern struct bo __near ram_23e0[];
extern struct evrec __near ram_23c0;
extern void SeqPart_ReadNextEventByte(struct bo *, unsigned char *);

void SeqPart_ReadEventStream(unsigned char p, unsigned char c)
{
	unsigned char ev[8];
	struct bo pos;
	unsigned char *s;
	unsigned char *d;
	unsigned char *e;

	pos = ram_23e0[(unsigned char)(p - 1)];
	for (;;) {
		SeqPart_ReadNextEventByte(&pos, ev);
		if (ev[0] == 0x81) {
			ram_23c0.count++;
			ev[1] = 0;
			if (c == 0)
				break;
		} else {
			if (ev[0] == 0x82)
				ev[1] = 0;
			break;
		}
	}
	ram_23e0[(unsigned char)(p - 1)] = pos;
	s = ev;
	d = ram_23c0.ev;
	e = ev + 6;
	do
		*d++ = *s++;
	while (s < e);
}
