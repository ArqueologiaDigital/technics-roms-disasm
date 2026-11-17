/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_5b.c (2026-11-16-45-p6-r9)
   sha256 02668fddc4a7ae9f0dcae741aab0cb2afb9cebcd20d58654e0aa4bfa1965ed0a (tar-sha256); compiled at -O3 -Xr */
typedef unsigned char *ucp;
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
extern ucp __near SEQ_BLOCK_POOL;
void SeqStep_CopyPartData(unsigned int a, unsigned int b)
{
	unsigned char *src, *dst;
	unsigned long s, d;
	unsigned int i;

	src = SEQ_BLOCK_POOL;
	s = ((unsigned long)a - 1) << 8;
	dst = src;
	d = ((unsigned long)b - 1) << 8;
	i = 0;
	do {
		dst[(unsigned long)i + d] = src[(unsigned long)i + s];
		i++;
	} while (i < 0x100);
	PartCtrl_SetClearBit7(a, 0);
}
