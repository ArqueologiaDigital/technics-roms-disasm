/* Phase 6, lane_p6 helper K, round 5, module 234, form b of p6_K_5m234a.c: SeqPart_InitVoiceChannelConfig with the
   flag bytes and both tables as __near externs, the source record addressed through a pointer local, and the
   frame record t written through a pointer (the ROM holds &t in XIX and &t.b in XIY). */
/* cc900-module: Part_FindVoiceByByte */   /* scripts/analysis/cc900/module_calls.py v10 */

struct rec4 { int a, b; };
struct rec8 { int a, b; char pad[4]; };

extern unsigned int __near ram_232a;
extern unsigned int __near ram_2328;
extern unsigned int __near ram_1d76;
extern unsigned int __near ram_1d78;
extern unsigned int __near ram_2316;
extern unsigned int __near ram_2318;
extern unsigned char __near ram_231c;
extern unsigned char __near ram_1d72;
extern unsigned char __near ram_1d73;
extern struct rec4 __near ram_23e0[];
extern struct rec8 __near ram_2474[];
extern unsigned char Part_FindVoiceByByte(unsigned int, unsigned int);

void SeqPart_InitVoiceChannelConfig(void)
{
	struct rec4 t;
	unsigned char v;
	unsigned char b;
	unsigned char c;
	unsigned char k;
	struct rec4 *s;
	struct rec4 *pt;

	ram_1d76 = ram_232a;
	ram_1d78 = ram_232a - ram_2328 + 1;
	ram_2318 = ram_2316;
	v = Part_FindVoiceByByte(0, 13);
	if (v != 0xff) {
		if (ram_2316 & (1 << (v - 1)))
			ram_1d72 = 1;
		else
			ram_1d72 = 0;
	}
	v = Part_FindVoiceByByte(0, 16);
	if (v != 0xff) {
		if (ram_2316 & (1 << (v - 1)))
			ram_1d73 = 1;
		else
			ram_1d73 = 0;
	}
	for (b = 1, c = 0; b <= 16; b++, c++) {
		if ((ram_2316 & (1 << c)) == 0)
			continue;
		pt = &t;
		k = b - 1;
		s = &ram_23e0[k];
		pt->a = s->a;
		pt->b = s->b;
		ram_2474[k].a = pt->a;
		ram_2474[k].b = pt->b;
		if (b == ram_231c) {
			ram_2474[19].a = pt->a;
			ram_2474[19].b = pt->b;
		}
	}
}
