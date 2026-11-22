/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_30r1m302b.c (2026-11-22-13-p6-r80)
   sha256 34543b0f4f632382bef55ff218cfb0b013062a5e83bfcfe986d8652cdba0de14 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned int __near ram_e0b8;
extern int MidiRingBuf_WriteByte(int);
extern void MidiRingBuf_Init(void);
int StoreAndAdvance_Prologue2(unsigned int n, unsigned char *buf)
{
	int i;

	if (n == 0)
		return 0;
	if (n > ram_e0b8)
		MidiRingBuf_Init();
	for (i = 0; (unsigned int)i < n; i++)
		MidiRingBuf_WriteByte(buf[i]);
	return 0;
}
