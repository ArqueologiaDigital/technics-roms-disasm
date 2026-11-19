/* Phase 6, lane_p6 helper M, round 4, module 240, form b: FileIO_ReadNextDirEntry retry (alternative to
   p6_M_4m240a.c).  idx copied into a pointer local after the null test (a local copy wins the XIZ home); entries as
   (char *)base + i * 44 as in form a. */

struct dent { char name[24]; unsigned int size; unsigned int tag; char rest[16]; };
struct dinfo { int f0; unsigned long size; char name[22]; };
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern struct dent ram_2358e[];
extern int FileIO_ReadNextDirEntry(int *idx, struct dinfo *out);

#define DENT(i) ((struct dent *)((char *)ram_2358e + (i) * 44))

int FileIO_ReadNextDirEntry(int *idx, struct dinfo *out)
{
	int *ip;

	if (idx == 0)
		return -1;
	ip = idx;
	if (*ip >= 80 || DENT(*ip)->tag == 0xfefe)
		return -1;
	Mem_Copy(out->name, DENT(*ip)->name, 20);
	out->name[20] = 0;
	out->size = DENT(*ip)->size;
	(*ip)++;
	return 0;
}
