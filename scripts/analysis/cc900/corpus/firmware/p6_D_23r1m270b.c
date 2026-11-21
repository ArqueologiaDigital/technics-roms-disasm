/* lane_p6 helper D, round 23r1, form b (= form a with the page compare's operands swapped): module 270 (audio/sound_navigation.s), MainGetPmemName (f99084, 196 B),
   the first root of roots23_B's stretch at f99084.  Helper B screened it out as hand assembly for its
   pushw_erp 0xfa / ldfr_berp / ldto_berp 0xfb, but those are `push qiz` and a byte variable homed in QIZ's high
   byte, which V4.23 does emit (19 promoted functions push / pop QIZ).
   Allocates an 8-byte panel-memory name record and an 18-byte name, fills the record (bank / page from
   SndParam 0x300 and the page in BitMapOut_PrepareRender_CheckBit1), copies 17 bytes of the name from 0xf9a2 and
   posts MT_PmemName and two MT_AutoFree.  Malloc / Strncpy take stack arguments (cdecl; the two Malloc pops are
   combined by V4.23).  Frame: rec, name in declaration order.
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
extern unsigned char BitMapOut_PrepareRender_CheckBit1(void);
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
	bank = BitMapOut_PrepareRender_CheckBit1();
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
