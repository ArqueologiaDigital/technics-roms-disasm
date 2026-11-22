/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_30r1m302b.c (2026-11-22-13-p6-r80)
   sha256 34543b0f4f632382bef55ff218cfb0b013062a5e83bfcfe986d8652cdba0de14 (tar-sha256); compiled at -Xr
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
		for (i = 0; (unsigned int)i < n; i++)
			RingBuffer_WriteByte(buf[i]);
		return 0;
	}
	return -1;
}
