/* Phase 6, lane_p6 (tag P), round 1, form c: FDemoText_LookupTableEntry (see p6_P_1a.c): an int local index,
   subscripted. */

typedef unsigned char *ucp;

extern ucp *__near PART_RECORD_PTRS;

unsigned char *FDemoText_LookupTableEntry(unsigned char ch)
{
    int i;

    i = ch;
    return PART_RECORD_PTRS[i];
}
