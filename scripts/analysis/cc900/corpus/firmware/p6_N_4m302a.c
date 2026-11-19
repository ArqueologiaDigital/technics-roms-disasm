/* lane_p6 helper N, round 4, form a: module 302 (audio/note_voice_mapping.s), retry of p6_N_2m302a
   (p6-r43 Xr: +33).  FileIO_ReadVariableLengthData: the only difference was the second read's test -- the ROM
   copies the result to WA and compares WA (`ld wa,hl; cp wa,0`), V4.23 compared HL: the test is written on the
   assignment expression, `(c = TaskBuf_ReadNextByte()) < 0`.
   cc900-options: -Xr
*/

extern int TaskBuf_ReadNextByte(void);

long FileIO_ReadVariableLengthData(unsigned int *pos, unsigned char *buf)
{
	long v;
	int c;

	v = TaskBuf_ReadNextByte();
	if (v < 0)
		return -1;
	buf[(*pos)++] = v;
	if (v & 0x80) {
		v &= 0x7f;
		do {
			if ((c = TaskBuf_ReadNextByte()) < 0)
				return -1;
			buf[(*pos)++] = c;
			v = (v << 7) + (c & 0x7f);
		} while (c & 0x80);
	}
	return v;
}
