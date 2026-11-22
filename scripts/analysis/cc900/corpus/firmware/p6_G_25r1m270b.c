/* lane_p6 helper G, round 25r1, form b: module 270 (audio/sound_navigation.s), MainGetPmemName (f99084, 196 B).
   Retry of p6_E_24r1m270a/b (run p6-r69, +1: V4.23 homed rec in XIZ and kept bank in the frame; the ROM keeps rec
   and name in the frame and homes the byte bank in QIZ).  This form declares bank `register` (and nothing else),
   to give it the only callee-saved home; the name source is a __near cell, pushed as two words like the ROM.
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
	register unsigned char bank;
	unsigned int first;

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
