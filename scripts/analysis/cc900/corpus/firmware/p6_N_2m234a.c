/* lane_p6 helper N, round 2, form a: module 234 (sequencer/sequencer_engine.s).
   SeqPart_ComputePlaybackDelta: the distance from the {block, offset} position at 0x282c to the one at 0x2830 as
   {blocks, offset} in out[0..1] (256-byte blocks of 0xfb usable bytes, chained by PartCtrl_ReadWord, at most
   block 0x4d8): 0, or -1 after error 0x64 (end before start in one block) / 0x65 (chain runs out).  The ROM
   stores out[1] three times in a row (+= end offset, -= 5, ++): written so.
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

	if (ram_2830.block == ram_282c.block) {
		if (ram_282c.offset > ram_2830.offset) {
			e = 0x64;
			goto err;
		}
		out[0] = 0;
		out[1] = ram_2830.offset - ram_282c.offset;
		out[1]++;
		return 0;
	}
	out[0] = 0;
	out[1] = 0x100 - ram_282c.offset;
	ram_282c.block = PartCtrl_ReadWord(ram_282c.block);
	do {
		if (ram_2830.block == ram_282c.block) {
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
