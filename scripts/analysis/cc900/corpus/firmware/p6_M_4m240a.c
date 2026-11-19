/* Phase 6, lane_p6 helper M, round 4, module 240, form a: FileIO_ReadNextDirEntry retry (run r42: +1 @Xr, frame).
   The ROM: frame 4 (only out spilled), idx tested through a copy in XBC and then kept in XIZ, every entry address as
   a 16-bit `muls wa,44` from the field's own base (`cpw (base+0x1a + wa)`, `ld bc,(base+0x18 + wa)`, exts + add for
   the Mem_Copy source).  This form: idx as a `register` parameter, the entries addressed as (char *)base + i * 44
   (int arithmetic gives muls instead of the C9H_mullu V4.23 called for &base[i]). */

struct dent { char name[24]; unsigned int size; unsigned int tag; char rest[16]; };
struct dinfo { int f0; unsigned long size; char name[22]; };
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern struct dent ram_2358e[];
extern int FileIO_ReadNextDirEntry(int *idx, struct dinfo *out);

#define DENT(i) ((struct dent *)((char *)ram_2358e + (i) * 44))

int FileIO_ReadNextDirEntry(register int *idx, struct dinfo *out)
{
	if (idx == 0)
		return -1;
	if (*idx >= 80 || DENT(*idx)->tag == 0xfefe)
		return -1;
	Mem_Copy(out->name, DENT(*idx)->name, 20);
	out->name[20] = 0;
	out->size = DENT(*idx)->size;
	(*idx)++;
	return 0;
}
