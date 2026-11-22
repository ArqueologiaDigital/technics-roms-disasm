/* lane_p6 helper P, round 30r1, form a: module 302 (audio/note_voice_mapping.s), the ring-buffer writers
   MidiRingBuf_WriteBytes / SysexRingBuf_WriteBytes / StoreAndAdvance_Prologue2.  One-spot retry of helper N's
   p6_N_29r1m302c (run r78, Xr, +15 each: the whole body agrees, frame and length included, but for the loop's
   entry test, where the ROM compares the INIT VALUE, `ld wa, 0:i3; cp wa, iz`, and V4.23 reloaded the counter
   from its frame slot).  Form a: the counter an unsigned int like n (no int-to-unsigned conversion in the test, so
   the copied entry test may take the init value as it is).
   cc900-options: -Xr
*/
/* cc900-module: MidiRingBuf_WriteByte RingBuffer_WriteByte SysexRingBuf_WriteByte */   /* scripts/analysis/cc900/module_calls.py v10 */
extern unsigned int __near ram_d0ac;
extern unsigned int __near ram_d8b2;
extern unsigned int __near ram_e0b8;
extern int RingBuffer_WriteByte(int);
extern int SysexRingBuf_WriteByte(int);
extern int MidiRingBuf_WriteByte(int);
extern void SysexRingBuf_Init(void);
extern void MidiRingBuf_Init(void);

int MidiRingBuf_WriteBytes(unsigned int n, unsigned char *buf)
{
	unsigned int i;

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

int SysexRingBuf_WriteBytes(unsigned int n, unsigned char *buf)
{
	unsigned int i;

	if (n == 0)
		return 0;
	if (n > ram_d8b2)
		SysexRingBuf_Init();
	for (i = 0; i < n; i++)
		SysexRingBuf_WriteByte(buf[i]);
	return 0;
}

int StoreAndAdvance_Prologue2(unsigned int n, unsigned char *buf)
{
	unsigned int i;

	if (n == 0)
		return 0;
	if (n > ram_e0b8)
		MidiRingBuf_Init();
	for (i = 0; i < n; i++)
		MidiRingBuf_WriteByte(buf[i]);
	return 0;
}
