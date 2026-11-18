/* Phase 6, lane_p6 helper J, round 1, form b: Flash_GetSlotAddressAndSize (m306) without gotos -- every branch
   stores its own size and result, for -O3 cross-jumping to share the tails the ROM shares; the flash base copied
   into a second pointer (the ROM keeps it in XIZ and XDE).  SndParam_ApplyMaskClamp with the 0xf0 split as a
   nested if. */

extern int SndParam_LookupReadOnly(long);

void SndParam_ApplyMaskClamp(unsigned char *p, unsigned char *q)
{
	unsigned char c;

	if (SndParam_LookupReadOnly(0xc0) == 1)
		return;
	if (*q == 0x78)
		return;
	if (*p < 0x80) {
		*q &= 7;
		return;
	}
	if (*q == 7) {
		*p &= 0x7f;
		c = 0x70;
	} else {
		if (*p < 0xf0) {
			if (*q == 0) {
				*p &= 0x7f;
				c = 0x10;
				goto store;
			}
			if (*q == 5) {
				*p &= 0x7f;
				c = 0x15;
				goto store;
			}
		} else {
			if (*q <= 1) {
				*p &= 0x0f;
				*q = (*q & 1) | 0x40;
				return;
			}
			if (*q == 6) {
				*p = 0;
				c = 0x50;
				goto store;
			}
			if (*q == 5) {
				*p &= 3;
				c = 0x55;
				goto store;
			}
		}
		*p = 0;
		c = 0;
	}
store:
	*q = c;
}

extern unsigned char ram_300000[];
extern unsigned char ram_1e0000[];

int Flash_GetSlotAddressAndSize(unsigned char flags, unsigned int slot, unsigned char **dest, unsigned int *size)
{
	char r;
	unsigned long n;
	unsigned long off;
	unsigned char *base;
	unsigned char *p;

	r = 0;
	n = slot;
	off = n * 470 + 16;
	if (flags & 1) {
		base = ram_300000;
		base += 0xb0400L;
		p = base;
		if (flags & 2) {
			if (slot < 4) {
				*dest = n * 0x2927 + 0x4980 + base;
				*size = 10535;
			} else
				r = 0xff;
		} else {
			if (slot < 40) {
				*dest = off + p;
				*size = 470;
			} else
				r = 0xff;
		}
	} else {
		base = ram_1e0000;
		if (flags & 2) {
			if (slot < 1) {
				*dest = base + 18816;
				*size = 10535;
			} else
				r = 0xff;
		} else {
			if (slot < 40) {
				*dest = base + off;
				*size = 470;
			} else
				r = 0xff;
		}
	}
	return r;
}
