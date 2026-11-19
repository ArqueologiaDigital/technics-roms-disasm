/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_4m234a.c (2026-11-19-29-p6-r46)
   sha256 470c17df19ca1bd80b41c753d9708223f2d6e288e98c2a5e336c5dc1e81af112 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
