/* Phase 6, lane_p6 helper K, round 5, module 234 (sequencer/sequencer_engine.s, -O3 -Xr), form a:
   SeqPart_InitVoiceChannelConfig.  Copies the song range cells (0x232a, 0x232a - 0x2328 + 1, 0x2316 -> 0x2318),
   flags whether the CHORD (13) and RHYTHM (16) tracks found by Part_FindVoiceByByte are in the track mask 0x2316
   (bytes 0x1d72 / 0x1d73), then for every track 1..16 in the mask copies its 4-byte record from the table at 0x23e0
   (field by field, through a frame local) to the 8-byte-record table at 0x2474, and to entry 19 of that table
   (0x250c) when it is the CHORD track (0x231c).  The hand source spells all these cells as decimal addresses and
   reaches 0x1d72 / 0x1d73 / 0x2474 / 0x250c through computed addresses (lda), so this form writes them as
   constant-address pointers (#define); no whole-element struct copies (V4.23 bug 11).  1 << (v - 1) with sla
   (plain int 1); the mask as the left operand of & (V4.23 puts the right operand in the register). */
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
extern unsigned char Part_FindVoiceByByte(unsigned int, unsigned int);

#define FLAG_CHORD (*(unsigned char *)0x1d72)
#define FLAG_RHYTHM (*(unsigned char *)0x1d73)
#define SRC ((struct rec4 *)0x23e0)
#define DST ((struct rec8 *)0x2474)

void SeqPart_InitVoiceChannelConfig(void)
{
	struct rec4 t;
	unsigned char v;
	unsigned char b;
	unsigned char c;
	unsigned char k;

	ram_1d76 = ram_232a;
	ram_1d78 = ram_232a - ram_2328 + 1;
	ram_2318 = ram_2316;
	v = Part_FindVoiceByByte(0, 13);
	if (v != 0xff) {
		if (ram_2316 & (1 << (v - 1)))
			FLAG_CHORD = 1;
		else
			FLAG_CHORD = 0;
	}
	v = Part_FindVoiceByByte(0, 16);
	if (v != 0xff) {
		if (ram_2316 & (1 << (v - 1)))
			FLAG_RHYTHM = 1;
		else
			FLAG_RHYTHM = 0;
	}
	for (b = 1, c = 0; b <= 16; b++, c++) {
		if ((ram_2316 & (1 << c)) == 0)
			continue;
		k = b - 1;
		t.a = SRC[k].a;
		t.b = SRC[k].b;
		DST[k].a = t.a;
		DST[k].b = t.b;
		if (b == ram_231c) {
			DST[19].a = t.a;
			DST[19].b = t.b;
		}
	}
}
