/* Phase 6, lane_p6 helper J, round 1, form a: SndParam_ApplyMaskClamp (m303) and Flash_GetSlotAddressAndSize
   (m306), both audio/note_voice_mapping.s; no module-local callees. */

extern int SndParam_LookupReadOnly(long);

/* p: the parameter byte (XIZ); q: its mode byte, kept in the frame.  The ROM shares one `*p = 0; c = 0` tail
   (cross-jumping, -O3) and writes `*p &= 0x7f` as res 7. */
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
		} else {
			*p = 0;
			c = 0;
		}
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
		*p = 0;
		c = 0;
	}
	*q = c;
}

/* The address and size of one slot: flags bit 0 = flash (0x300000 + 0xb0400) else RAM (0x1e0000), bit 1 = the
   one big slot kind (10535 bytes) else the 470-byte slots.  Returns 0, or -1 when the slot is out of range.
   The ROM's Math_Multiply32 calls are the long multiplies (runtime C9H_mullu); it looks -Xr (no folding of
   base + 0xb0400, r read back from the frame). */
extern unsigned char ram_300000[];
extern unsigned char ram_1e0000[];

int Flash_GetSlotAddressAndSize(unsigned char flags, unsigned int slot, unsigned char **dest, unsigned int *size)
{
	char r;
	unsigned long n;
	unsigned long off;
	unsigned char *base;
	unsigned int sz;

	r = 0;
	n = slot;
	off = n * 470 + 16;
	if (flags & 1) {
		base = ram_300000 + 0xb0400L;
		if (flags & 2) {
			if (slot >= 4)
				goto bad;
			*dest = n * 0x2927 + 0x4980 + base;
			sz = 10535;
		} else {
			if (slot >= 40)
				goto bad;
			*dest = off + base;
			sz = 470;
		}
	} else {
		base = ram_1e0000;
		if (flags & 2) {
			if (slot >= 1)
				goto bad;
			*dest = base + 18816;
			sz = 10535;
		} else {
			if (slot >= 40)
				goto bad;
			*dest = base + off;
			sz = 470;
		}
	}
	*size = sz;
	return r;
bad:
	r = 0xff;
	return r;
}
