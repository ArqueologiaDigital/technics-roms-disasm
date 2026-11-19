/* Phase 6, lane_p6 helper M, round 2, module 240 (sequencer/smf_event_processor.s), form a.
   FileIO_ReadNextDirEntry: the directory iterator over the 80 44-byte entries at 0x2358e (name at +0, size at +0x18,
   tag at +0x1a, 0xfefe = end).  Copies the 20-byte name to out+6 (terminated), the size widened to out+2, advances
   the caller's index; -1 at the end or for a null index.  The ROM indexes with muls (signed int index). */

struct dent { char name[24]; unsigned int size; unsigned int tag; char rest[16]; };
struct dinfo { int f0; unsigned long size; char name[22]; };
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern struct dent ram_2358e[];
extern int FileIO_ReadNextDirEntry(int *idx, struct dinfo *out);

int FileIO_ReadNextDirEntry(int *idx, struct dinfo *out)
{
	if (idx == 0)
		return -1;
	if (*idx >= 80 || ram_2358e[*idx].tag == 0xfefe)
		return -1;
	Mem_Copy(out->name, ram_2358e[*idx].name, 20);
	out->name[20] = 0;
	out->size = ram_2358e[*idx].size;
	(*idx)++;
	return 0;
}
