/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_29r1m302a.c (2026-11-22-11-p6-r78)
   sha256 219065d56ccb5f31b0b66d4040676bd706889506a060e166fee4dee998d2fc9f (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned int __near ram_e0b8;
extern int MidiRingBuf_WriteByte(int);
extern void MidiRingBuf_Init(void);
int StoreAndAdvance_Prologue2(register unsigned int n, unsigned char *buf)
{
	int i;

	if (n == 0)
		return 0;
	if (n > ram_e0b8)
		MidiRingBuf_Init();
	for (i = 0; i < n; i++)
		MidiRingBuf_WriteByte(buf[i]);
	return 0;
}
