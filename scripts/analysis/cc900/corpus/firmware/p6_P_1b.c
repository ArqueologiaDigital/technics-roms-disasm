/* Phase 6, lane_p6 (tag P), round 1, form b: FDemoText_LookupTableEntry (see p6_P_1a.c): the byte offset as an int
   added to a char pointer. */

typedef unsigned char *ucp;

extern ucp *__near PART_RECORD_PTRS;

unsigned char *FDemoText_LookupTableEntry(unsigned char ch)
{
    return *(ucp *)((char *)PART_RECORD_PTRS + ((int)ch << 2));
}
