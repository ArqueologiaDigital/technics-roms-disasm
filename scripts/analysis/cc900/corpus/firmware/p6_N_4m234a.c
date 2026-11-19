/* lane_p6 helper N, round 4, form a: module 234 (sequencer/sequencer_engine.s), retry of p6_N_2m234a
   (p6-r43 O3Xr: +4).  SeqPart_ComputePlaybackDelta: V4.23 loads the left operand of `==` from memory into WA and
   compares with the right one; the ROM loads the cur block (0x282c) first and compares the end block (0x2830)
   against it -- so both block tests are written `cur == end` here.  The same-block branch is written with the
   in-range test first, so the error 0x64 goes out of line as in the ROM.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PartCtrl_ReadWord SeqData_SetErrorCode */

struct bo { unsigned int block; unsigned int offset; };
extern struct bo __near ram_282c;
extern struct bo __near ram_2830;
extern unsigned int PartCtrl_ReadWord(unsigned int n);
extern void SeqData_SetErrorCode(unsigned int);

int SeqPart_ComputePlaybackDelta(unsigned int *out)
{
	unsigned int e;

	if (ram_282c.block == ram_2830.block) {
		if (ram_282c.offset <= ram_2830.offset) {
			out[0] = 0;
			out[1] = ram_2830.offset - ram_282c.offset;
			out[1]++;
			return 0;
		}
		e = 0x64;
		goto err;
	}
	out[0] = 0;
	out[1] = 0x100 - ram_282c.offset;
	ram_282c.block = PartCtrl_ReadWord(ram_282c.block);
	do {
		if (ram_282c.block == ram_2830.block) {
			out[1] += ram_2830.offset;
			out[1] -= 5;
			out[1]++;
			if (out[1] >= 0xfb) {
				out[0]++;
				out[1] -= 0xfb;
			}
			return 0;
		}
		out[0]++;
		ram_282c.block = PartCtrl_ReadWord(ram_282c.block);
	} while (ram_282c.block <= 0x4d8);
	e = 0x65;
err:
	SeqData_SetErrorCode(e);
	return -1;
}
