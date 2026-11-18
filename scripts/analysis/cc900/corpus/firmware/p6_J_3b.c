/* Phase 6, lane_p6 helper J, round 3, form b: as p6_J_3a.c with SndParam_ApplyMaskClamp's returns inside the
   chain written as goto out (one exit after the store) and Flash_GetSlotAddressAndSize keeping one base variable
   for flash and RAM (p) and no dest copy. */

extern int SndParam_LookupReadOnly(long);

void SndParam_ApplyMaskClamp(unsigned char *p, unsigned char *q)
{
	unsigned char c;

	if (SndParam_LookupReadOnly(0xc0) == 1)
		goto out;
	if (*q == 0x78)
		goto out;
	if (*p <= 0x7f) {
		*q &= 7;
		goto out;
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
		goto out;
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
out:
	;
}

extern unsigned char ram_300000[];
extern unsigned char ram_1e0000[];

int Flash_GetSlotAddressAndSize(unsigned char flags, unsigned int slot, unsigned char **dest, unsigned int *size)
{
	char r;
	unsigned long n;
	unsigned long off;
	unsigned char *top;
	unsigned char *p;
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
	*dest = n * 0x2927 + 0x4980 + top;
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
	p = ram_1e0000;
	if (!(flags & 2))
		goto rsmall;
	if (slot >= 1)
		goto bad;
	*dest = p + 18816;
	sz = 10535;
	goto store;
rsmall:
	if (slot >= 40)
		goto bad;
	*dest = p + off;
	sz = 470;
store:
	*size = sz;
	goto join;
}
