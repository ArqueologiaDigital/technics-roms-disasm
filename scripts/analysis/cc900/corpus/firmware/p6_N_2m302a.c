/* lane_p6 helper N, round 2, form a: module 302 (audio/note_voice_mapping.s).
   FileIO_ReadVariableLengthData: reads a MIDI variable-length quantity byte by byte (TaskBuf_ReadNextByte),
   appending every byte to buf[*pos], and returns its value, or -1 at the end of the data.
   The ROM keeps the value, buf and pos in the frame: probably a file built without -O (both sets are compiled).
   cc900-options: -O3 -Xr
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
			c = TaskBuf_ReadNextByte();
			if (c < 0)
				return -1;
			buf[(*pos)++] = c;
			v = (v << 7) + (c & 0x7f);
		} while (c & 0x80);
	}
	return v;
}
