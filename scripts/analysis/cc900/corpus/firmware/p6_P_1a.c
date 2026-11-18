/* Phase 6, lane_p6 (the lane itself, tag P), round 1, form a: FDemoText_LookupTableEntry of v10
   demo/fdemotext_routines.s.  The ROM scales the char index in WA (extz, sla 2), loads the __near pointer cell into
   XBC, then exts XWA and adds: pointer arithmetic with an int offset.  Run p6-r33's subscript `[ch]` gave
   ld BC,WA / (XWA+BC) instead (+3).  Form a: an int index added to the pointer. */

typedef unsigned char *ucp;

extern ucp *__near PART_RECORD_PTRS;

unsigned char *FDemoText_LookupTableEntry(unsigned char ch)
{
    return *(PART_RECORD_PTRS + (int)ch);
}
