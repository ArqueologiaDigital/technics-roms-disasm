/* lane_p6 helper G, round 25r1, form c: module 270 (audio/sound_navigation.s), MainGetPmemName (f99084, 196 B).
   Form a with rec declared before name (the other reading of the address-taken slot order), so that whichever
   order V4.23 uses, one of a / c puts rec in the lower frame slot like the ROM.
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

extern char __near ram_f9a2[];

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

	&rec;
	&name;
	rec = Malloc(8);
	name = Malloc(18);
	bank = BitMapOut_PrepRender_CheckBit1();
	rec->page = SndParam_LookupReadOnly(0x300);
	Strncpy(name, ram_f9a2, 17);
	if (bank == (rec->page - 1) >> 3) {
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
