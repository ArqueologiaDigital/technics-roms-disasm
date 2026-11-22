/* lane_p6 helper E, round 24r1, form b: module 270 (audio/sound_navigation.s), MainGetPmemName (f99084, 196 B).
   Form a with the page compare's operands swapped (as p6_D_23r1m270b).  The callee keeps the short C name:
   cc900-name: BitMapOut_PrepRender_CheckBit1=BitMapOut_PrepareRender_CheckBit1
   cc900-options: -O3 -Xr
*/

#define EVT_PMEM_NAME  0x1c00022L
#define EVT_AUTO_FREE  0x1e00023L

struct pmname {
	unsigned int first;
	unsigned int page;
	char *name;
};

extern void *__cdecl Malloc(unsigned int);
extern char *__cdecl Strncpy(char *, char *, int);
extern unsigned char BitMapOut_PrepRender_CheckBit1(void);
extern unsigned char BitMapOut_GetRenderMode(void);
extern int SndParam_LookupReadOnly(long);
extern long ApPostEvent(long, long, void *);

long MainGetPmemName(void)
{
	struct pmname *rec;
	char *name;
	unsigned char bank;
	unsigned int first;

	rec = Malloc(8);
	name = Malloc(18);
	bank = BitMapOut_PrepRender_CheckBit1();
	rec->page = SndParam_LookupReadOnly(0x300);
	Strncpy(name, (char *)0xf9a2L, 17);
	if ((rec->page - 1) >> 3 == bank) {
		if (BitMapOut_GetRenderMode() & 0x80)
			first = 0;
		else
			first = 1;
	} else {
		rec->page = (unsigned char)(bank * 8 + 1);
		first = 0;
	}
	rec->first = first;
	rec->name = name;
	name[17] = 0;
	ApPostEvent(-1L, EVT_PMEM_NAME, rec);
	ApPostEvent(-1L, EVT_AUTO_FREE, rec);
	ApPostEvent(-1L, EVT_AUTO_FREE, name);
	return 0;
}
