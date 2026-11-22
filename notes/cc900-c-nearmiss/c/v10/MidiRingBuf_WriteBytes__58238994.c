/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_29r1m302c.c (2026-11-22-11-p6-r78)
   sha256 582389946da6388bbf11fcbeb32b5646775038896770b8fbccebf5e9c3c0b7fb (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int __near ram_d0ac;
extern int RingBuffer_WriteByte(int);
int MidiRingBuf_WriteBytes(unsigned int n, unsigned char *buf)
{
	int i;

	if (n == 0)
		return 0;
	else if (n > ram_d0ac)
		return -1;
	else if (ram_d0ac > n) {
		for (i = 0; i < n; i++)
			RingBuffer_WriteByte(buf[i]);
		return 0;
	}
	return -1;
}
