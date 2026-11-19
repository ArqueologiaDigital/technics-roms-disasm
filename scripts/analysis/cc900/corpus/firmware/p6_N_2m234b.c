/* lane_p6 helper N, round 2, form b: module 234 (sequencer/sequencer_engine.s).
   SeqPart_ComputePlaybackDelta, form b against a: the two positions through pointer locals (the ROM's
   `lda xhl,(0x282c)` / `lda xix,(0x2830)`, `lda xde,(xiz+2)`), out[1] through a pointer.
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
	struct bo *cur;
	struct bo *end;
	unsigned int *d;
	unsigned int e;

	cur = &ram_282c;
	end = &ram_2830;
	d = &out[1];
	if (end->block == cur->block) {
		if (cur->offset > end->offset) {
			e = 0x64;
			goto err;
		}
		out[0] = 0;
		*d = end->offset - cur->offset;
		(*d)++;
		return 0;
	}
	out[0] = 0;
	*d = 0x100 - cur->offset;
	ram_282c.block = PartCtrl_ReadWord(cur->block);
	do {
		cur = &ram_282c;
		end = &ram_2830;
		if (end->block == cur->block) {
			d = &out[1];
			*d += end->offset;
			*d -= 5;
			(*d)++;
			if (*d >= 0xfb) {
				out[0]++;
				*d -= 0xfb;
			}
			return 0;
		}
		out[0]++;
		cur->block = PartCtrl_ReadWord(cur->block);
	} while (cur->block <= 0x4d8);
	e = 0x65;
err:
	SeqData_SetErrorCode(e);
	return -1;
}
