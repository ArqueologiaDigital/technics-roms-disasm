/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_5a.c (2026-11-16-45-p6-r9)
   sha256 0a24d3abb3ad01135d3ba1544257bdeae1dc14fc21da9794d409ad64bba47312 (tar-sha256); compiled at -O3 -Xr */
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
	for (i = 0; i < 0x100; i++) dst[(unsigned long)i + d] = src[(unsigned long)i + s];
	PartCtrl_SetClearBit7(a, 0);
}
