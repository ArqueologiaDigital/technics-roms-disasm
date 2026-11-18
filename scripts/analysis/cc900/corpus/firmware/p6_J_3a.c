/* Phase 6, lane_p6 helper J, round 3, form a: refinements from run r35 of SndParam_ApplyMaskClamp (m303, +19 at
   O3Xr: V4.23 laid the shared `*q = c` tail and the epilogue in the middle, the ROM keeps the default
   `*p = 0; c = 0` block, the store and the epilogue last -- here the default is the final else, reached by goto
   from the 0xef branch) and Flash_GetSlotAddressAndSize (m306, -Xr look, +23: the ROM keeps n = slot without a
   reload, a spilled copy of dest below n in the frame, and lays its blocks big-flash / out-of-range + return /
   small-flash / big-RAM / small-RAM / size store -- written with gotos in that order; the flash base in two
   variables (XIZ, XDE), the RAM base in a third). */

extern int SndParam_LookupReadOnly(long);

void SndParam_ApplyMaskClamp(unsigned char *p, unsigned char *q)
{
	unsigned char c;

	if (SndParam_LookupReadOnly(0xc0) == 1)
		return;
	if (*q == 0x78)
		return;
	if (*p <= 0x7f) {
		*q &= 7;
		return;
	}
	if (*q == 7) {
		*p &= 0x7f;
		c = 0x70;
	} else if (*p <= 0xef) {
		if (*q == 0) {
			*p &= 0x7f;
			c = 0x10;
		} else if (*q == 5) {
			*p &= 0x7f;
			c = 0x15;
		} else
			goto def;
	} else if (*q <= 1) {
		*p &= 0x0f;
		*q = (*q & 1) | 0x40;
		return;
	} else if (*q == 6) {
		*p = 0;
		c = 0x50;
	} else if (*q == 5) {
		*p &= 3;
		c = 0x55;
	} else {
def:
		*p = 0;
		c = 0;
	}
	*q = c;
}

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
