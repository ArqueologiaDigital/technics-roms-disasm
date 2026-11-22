/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_29r1m302a.c (2026-11-22-11-p6-r78)
   sha256 219065d56ccb5f31b0b66d4040676bd706889506a060e166fee4dee998d2fc9f (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int __near ram_d0ac;
extern int RingBuffer_WriteByte(int);
int MidiRingBuf_WriteBytes(register unsigned int n, unsigned char *buf)
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
