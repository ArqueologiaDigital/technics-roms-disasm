/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_3a.c (2026-11-18-28-p6-r36)
   sha256 586142f0605d04179017193af1b107187ec164838a7d80616edf01bee153966c (tar-sha256); compiled at -O3 -Xr */
extern unsigned char ram_300000[];
extern unsigned char ram_1e0000[];
int Flash_GetSlotAddressAndSize(unsigned char flags, unsigned int slot, unsigned char **dest, unsigned int *size)
{
	char r;
	unsigned char **dp;
	unsigned long n;
	unsigned long off;
	unsigned char *top;
	unsigned char *p;
	unsigned char *q;
	unsigned int sz;

	r = 0;
	off = (n = slot) * 470 + 16;
	if (!(flags & 1))
		goto ram;
	top = ram_300000 + 0xb0400L;
	p = top;
	if (!(flags & 2))
		goto fsmall;
	if (slot >= 4)
		goto bad;
	dp = dest;
	*dp = n * 0x2927 + 0x4980 + top;
	sz = 10535;
	goto store;
bad:
	r = 0xff;
join:
	return r;
fsmall:
	if (slot >= 40)
		goto bad;
	*dest = off + p;
	sz = 470;
	goto store;
ram:
	q = ram_1e0000;
	if (!(flags & 2))
		goto rsmall;
	if (slot >= 1)
		goto bad;
	*dest = q + 18816;
	sz = 10535;
	goto store;
rsmall:
	if (slot >= 40)
		goto bad;
	*dest = q + off;
	sz = 470;
store:
	*size = sz;
	goto join;
}
